-- ============================================================
-- 存储过程: sp_sync_cos_goods_sku_params_daily
-- 功能: 同步商品SKU参数（销量、库存等），支持JH/FBA/MP三种店铺类型
-- 创建时间: 2026-02-02
-- 说明: 该存储过程实现幂等性，支持多次执行，并按照加权公式计算日均销量
-- ============================================================

DELIMITER $$

-- 如果存储过程已存在则删除
DROP PROCEDURE IF EXISTS `sp_sync_cos_goods_sku_params_daily`$$

CREATE PROCEDURE `sp_sync_cos_goods_sku_params_daily`(
    IN p_monitor_date DATE  -- 监控日期参数，用于计算销量和库存
)
BEGIN
    DECLARE v_today DATE;
    DECLARE v_7days_ago DATE;
    DECLARE v_15days_ago DATE;
    DECLARE v_30days_ago DATE;
    
    -- 异常处理声明
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 发生错误时回滚事务
        ROLLBACK;
        -- 可选：记录错误日志
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error in sp_sync_cos_goods_sku_params_daily';
    END;
    
    -- 设置监控日期，如果未传入则使用当前日期
    SET v_today = IFNULL(p_monitor_date, CURDATE());
    SET v_7days_ago = DATE_SUB(v_today, INTERVAL 7 DAY);
    SET v_15days_ago = DATE_SUB(v_today, INTERVAL 15 DAY);
    SET v_30days_ago = DATE_SUB(v_today, INTERVAL 30 DAY);
    
    -- 开始事务
    START TRANSACTION;
    
    -- ============================================================
    -- 1. 创建临时表：存储店铺映射关系（JH店铺）
    -- 说明：JH店铺通过 amf_jh_shop.id -> cos_shop.platform_shop_id -> cos_shop.id
    -- ============================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_jh_shop_mapping;
    CREATE TEMPORARY TABLE tmp_jh_shop_mapping (
        amf_shop_id INT,
        cos_shop_id BIGINT,
        company_id BIGINT,
        INDEX idx_amf_shop(amf_shop_id),
        INDEX idx_cos_shop(cos_shop_id)
    ) ENGINE=MEMORY;
    
    INSERT INTO tmp_jh_shop_mapping (amf_shop_id, cos_shop_id, company_id)
    SELECT 
        jh.id AS amf_shop_id,
        cs.id AS cos_shop_id,
        cs.company_id
    FROM amf_jh_shop jh
    INNER JOIN cos_shop cs ON jh.id = cs.platform_shop_id AND cs.deleted = 0
    WHERE jh.status = 1;  -- 只处理正常状态的店铺
    
    -- ============================================================
    -- 2. 创建临时表：存储店铺映射关系（FBA店铺）
    -- 说明：FBA店铺通过 amf_lx_shop.store_id -> cos_shop.external_id，使用MIN(id)唯一化
    --      过滤掉type='test'的测试店铺
    -- ============================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_fba_shop_mapping;
    CREATE TEMPORARY TABLE tmp_fba_shop_mapping (
        store_id VARCHAR(50),
        cos_shop_id BIGINT,
        company_id BIGINT,
        INDEX idx_store(store_id),
        INDEX idx_cos_shop(cos_shop_id)
    ) ENGINE=MEMORY;
    
    INSERT INTO tmp_fba_shop_mapping (store_id, cos_shop_id, company_id)
    SELECT 
        lx.store_id,
        MIN(cs.id) AS cos_shop_id,  -- 使用MIN(id)唯一化
        cs.company_id
    FROM amf_lx_shop lx
    INNER JOIN cos_shop cs ON lx.store_id = cs.external_id 
        AND (cs.type IS NULL OR cs.type != 'test')  -- 排除测试店铺
        AND cs.deleted = 0
    WHERE lx.status = 1  -- 只处理启用状态的店铺
    GROUP BY lx.store_id, cs.company_id;
    
    -- ============================================================
    -- 3. 创建临时表：存储店铺映射关系（MP店铺）
    -- 说明：MP店铺通过 amf_lx_mporders.store_id -> cos_shop.external_id，使用MIN(id)唯一化
    --      过滤掉type='test'的测试店铺
    -- ============================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_mp_shop_mapping;
    CREATE TEMPORARY TABLE tmp_mp_shop_mapping (
        store_id VARCHAR(50),
        cos_shop_id BIGINT,
        company_id BIGINT,
        INDEX idx_store(store_id),
        INDEX idx_cos_shop(cos_shop_id)
    ) ENGINE=MEMORY;
    
    INSERT INTO tmp_mp_shop_mapping (store_id, cos_shop_id, company_id)
    SELECT 
        DISTINCT mp.store_id,
        MIN(cs.id) AS cos_shop_id,  -- 使用MIN(id)唯一化
        cs.company_id
    FROM amf_lx_mporders mp
    INNER JOIN cos_shop cs ON mp.store_id = cs.external_id 
        AND (cs.type IS NULL OR cs.type != 'test')  -- 排除测试店铺
        AND cs.deleted = 0
    WHERE mp.is_delete = 0  -- 只处理未删除的订单
    GROUP BY mp.store_id, cs.company_id;
    
    -- ============================================================
    -- 4. 计算JH店铺的销量数据（按delivery_time统计）
    -- ============================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_jh_sales;
    CREATE TEMPORARY TABLE tmp_jh_sales (
        company_id BIGINT,
        shop_id BIGINT,
        sku_id VARCHAR(100),
        sales_7d INT DEFAULT 0,
        sales_15d INT DEFAULT 0,
        sales_30d INT DEFAULT 0,
        INDEX idx_key(company_id, shop_id, sku_id)
    ) ENGINE=MEMORY;
    
    INSERT INTO tmp_jh_sales (company_id, shop_id, sku_id, sales_7d, sales_15d, sales_30d)
    SELECT 
        sm.company_id,
        sm.cos_shop_id AS shop_id,
        IFNULL(jo.warehouse_sku, cgi.warehouse_sku) AS sku_id,
        SUM(CASE 
            WHEN DATE(jo.delivery_time) >= v_7days_ago AND DATE(jo.delivery_time) < v_today 
            THEN IFNULL(jo.warehouse_sku_num, jo.quantity_ordered) 
            ELSE 0 
        END) AS sales_7d,
        SUM(CASE 
            WHEN DATE(jo.delivery_time) >= v_15days_ago AND DATE(jo.delivery_time) < v_today 
            THEN IFNULL(jo.warehouse_sku_num, jo.quantity_ordered) 
            ELSE 0 
        END) AS sales_15d,
        SUM(CASE 
            WHEN DATE(jo.delivery_time) >= v_30days_ago AND DATE(jo.delivery_time) < v_today 
            THEN IFNULL(jo.warehouse_sku_num, jo.quantity_ordered) 
            ELSE 0 
        END) AS sales_30d
    FROM amf_jh_orders jo
    INNER JOIN tmp_jh_shop_mapping sm ON jo.shop_id = sm.amf_shop_id
    LEFT JOIN amf_jh_company_goods cg ON jo.company_sku = cg.company_sku AND jo.warehouse_sku IS NULL
    LEFT JOIN amf_jh_company_goods_item cgi ON cg.id = cgi.company_product_id
    WHERE jo.order_status = 'FH'  -- 已发货状态
        AND jo.delivery_time IS NOT NULL
        AND DATE(jo.delivery_time) >= v_30days_ago
        AND DATE(jo.delivery_time) < v_today
        AND IFNULL(jo.warehouse_sku, cgi.warehouse_sku) IS NOT NULL
    GROUP BY sm.company_id, sm.cos_shop_id, IFNULL(jo.warehouse_sku, cgi.warehouse_sku);
    
    -- ============================================================
    -- 5. 计算FBA店铺的销量数据（按shipment_date_utc统计）
    -- ============================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_fba_sales;
    CREATE TEMPORARY TABLE tmp_fba_sales (
        company_id BIGINT,
        shop_id BIGINT,
        sku_id VARCHAR(100),
        sales_7d INT DEFAULT 0,
        sales_15d INT DEFAULT 0,
        sales_30d INT DEFAULT 0,
        INDEX idx_key(company_id, shop_id, sku_id)
    ) ENGINE=MEMORY;
    
    INSERT INTO tmp_fba_sales (company_id, shop_id, sku_id, sales_7d, sales_15d, sales_30d)
    SELECT 
        sm.company_id,
        sm.cos_shop_id AS shop_id,
        IFNULL(lp.sku, IF(ai.local_sku = '', ai.seller_sku, ai.local_sku)) AS sku_id,
        SUM(CASE 
            WHEN STR_TO_DATE(ao.shipment_date_utc, '%Y-%m-%d %H:%i:%s') >= v_7days_ago 
                AND STR_TO_DATE(ao.shipment_date_utc, '%Y-%m-%d %H:%i:%s') < v_today 
            THEN ai.quantity_ordered 
            ELSE 0 
        END) AS sales_7d,
        SUM(CASE 
            WHEN STR_TO_DATE(ao.shipment_date_utc, '%Y-%m-%d %H:%i:%s') >= v_15days_ago 
                AND STR_TO_DATE(ao.shipment_date_utc, '%Y-%m-%d %H:%i:%s') < v_today 
            THEN ai.quantity_ordered 
            ELSE 0 
        END) AS sales_15d,
        SUM(CASE 
            WHEN STR_TO_DATE(ao.shipment_date_utc, '%Y-%m-%d %H:%i:%s') >= v_30days_ago 
                AND STR_TO_DATE(ao.shipment_date_utc, '%Y-%m-%d %H:%i:%s') < v_today 
            THEN ai.quantity_ordered 
            ELSE 0 
        END) AS sales_30d
    FROM amf_lx_amzorder ao
    INNER JOIN amf_lx_amzorder_item ai ON ao.id = ai.amzorder_id
    INNER JOIN amf_lx_shop lx ON ao.sid = lx.store_id
    INNER JOIN tmp_fba_shop_mapping sm ON lx.store_id = sm.store_id
    LEFT JOIN amf_lx_products lp ON ai.local_sku = lp.sku
    WHERE ao.fulfillment_channel = 'AFN'  -- FBA订单
        AND ao.shipment_date_utc IS NOT NULL
        AND STR_TO_DATE(ao.shipment_date_utc, '%Y-%m-%d %H:%i:%s') >= v_30days_ago
        AND STR_TO_DATE(ao.shipment_date_utc, '%Y-%m-%d %H:%i:%s') < v_today
        AND IFNULL(lp.sku, IF(ai.local_sku = '', ai.seller_sku, ai.local_sku)) IS NOT NULL
    GROUP BY sm.company_id, sm.cos_shop_id, IFNULL(lp.sku, IF(ai.local_sku = '', ai.seller_sku, ai.local_sku));
    
    -- ============================================================
    -- 6. 计算MP店铺的销量数据（按global_create_time统计）
    -- 说明：需要先将global_create_time解析为DATETIME类型，然后统计销量
    -- ============================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_mp_sales;
    CREATE TEMPORARY TABLE tmp_mp_sales (
        company_id BIGINT,
        shop_id BIGINT,
        sku_id VARCHAR(100),
        sales_7d INT DEFAULT 0,
        sales_15d INT DEFAULT 0,
        sales_30d INT DEFAULT 0,
        INDEX idx_key(company_id, shop_id, sku_id)
    ) ENGINE=MEMORY;
    
    INSERT INTO tmp_mp_sales (company_id, shop_id, sku_id, sales_7d, sales_15d, sales_30d)
    SELECT 
        sm.company_id,
        sm.cos_shop_id AS shop_id,
        IFNULL(mi.local_sku, mi.msku) AS sku_id,
        SUM(CASE 
            WHEN STR_TO_DATE(mp.global_create_time, '%Y-%m-%d %H:%i:%s') >= v_7days_ago 
                AND STR_TO_DATE(mp.global_create_time, '%Y-%m-%d %H:%i:%s') < v_today 
            THEN mi.quantity 
            ELSE 0 
        END) AS sales_7d,
        SUM(CASE 
            WHEN STR_TO_DATE(mp.global_create_time, '%Y-%m-%d %H:%i:%s') >= v_15days_ago 
                AND STR_TO_DATE(mp.global_create_time, '%Y-%m-%d %H:%i:%s') < v_today 
            THEN mi.quantity 
            ELSE 0 
        END) AS sales_15d,
        SUM(CASE 
            WHEN STR_TO_DATE(mp.global_create_time, '%Y-%m-%d %H:%i:%s') >= v_30days_ago 
                AND STR_TO_DATE(mp.global_create_time, '%Y-%m-%d %H:%i:%s') < v_today 
            THEN mi.quantity 
            ELSE 0 
        END) AS sales_30d
    FROM amf_lx_mporders mp
    INNER JOIN amf_lx_mporders_item mi ON mp.global_order_no = mi.global_order_no
    INNER JOIN tmp_mp_shop_mapping sm ON mp.store_id = sm.store_id
    WHERE mp.status = 6  -- 已完成状态
        AND mp.is_delete = 0
        AND mp.global_create_time IS NOT NULL
        AND STR_TO_DATE(mp.global_create_time, '%Y-%m-%d %H:%i:%s') >= v_30days_ago
        AND STR_TO_DATE(mp.global_create_time, '%Y-%m-%d %H:%i:%s') < v_today
        AND mp.platform_code IN ('10001', '10002')  -- 特定平台
        AND IFNULL(mi.local_sku, mi.msku) IS NOT NULL
    GROUP BY sm.company_id, sm.cos_shop_id, IFNULL(mi.local_sku, mi.msku);
    
    -- ============================================================
    -- 7. 获取FBA库存数据（使用最大sync_date的available_total）
    -- ============================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_fba_inventory;
    CREATE TEMPORARY TABLE tmp_fba_inventory (
        company_id BIGINT,
        shop_id BIGINT,
        sku_id VARCHAR(100),
        platform_inventory INT DEFAULT 0,
        INDEX idx_key(company_id, shop_id, sku_id)
    ) ENGINE=MEMORY;
    
    -- 先找出每个店铺+SKU的最大sync_date
    INSERT INTO tmp_fba_inventory (company_id, shop_id, sku_id, platform_inventory)
    SELECT 
        sm.company_id,
        sm.cos_shop_id AS shop_id,
        fba.seller_sku AS sku_id,
        fba.available_total AS platform_inventory
    FROM (
        -- 子查询：获取每个店铺+SKU的最大sync_date
        SELECT 
            sid,
            seller_sku,
            MAX(sync_date) AS max_sync_date
        FROM amf_lx_fbadetail
        WHERE sync_date IS NOT NULL
            AND isdel = 0
        GROUP BY sid, seller_sku
    ) latest
    INNER JOIN amf_lx_fbadetail fba 
        ON latest.sid = fba.sid 
        AND latest.seller_sku = fba.seller_sku 
        AND latest.max_sync_date = fba.sync_date
    INNER JOIN amf_lx_shop lx ON fba.sid = lx.store_id
    INNER JOIN tmp_fba_shop_mapping sm ON lx.store_id = sm.store_id
    WHERE fba.isdel = 0;
    
    -- ============================================================
    -- 8. 获取JH店铺的海外仓库存数据（最新库存）
    -- 说明：使用 amf_jh_shop_warehouse_stock 表的 available_qty 字段
    -- ============================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_jh_inventory;
    CREATE TEMPORARY TABLE tmp_jh_inventory (
        company_id BIGINT,
        shop_id BIGINT,
        sku_id VARCHAR(100),
        platform_inventory INT DEFAULT 0,
        INDEX idx_key(company_id, shop_id, sku_id)
    ) ENGINE=MEMORY;
    
    -- 使用最新的海外仓库存数据（按shop_id分组汇总）
    INSERT INTO tmp_jh_inventory (company_id, shop_id, sku_id, platform_inventory)
    SELECT 
        sm.company_id,
        sm.cos_shop_id AS shop_id,
        ws.warehouse_sku AS sku_id,
        SUM(ws.available_qty) AS platform_inventory
    FROM amf_jh_shop_warehouse_stock ws
    INNER JOIN tmp_jh_shop_mapping sm ON ws.shop_id = sm.amf_shop_id
    WHERE ws.available_qty > 0
    GROUP BY sm.company_id, sm.cos_shop_id, ws.warehouse_sku;
    
    -- ============================================================
    -- 9. 合并所有数据并插入/更新目标表
    -- 说明：使用UPSERT模式，确保幂等性
    -- 加权公式：7天销量/7*0.5 + 15天销量/15*0.3 + 30天销量/30*0.2
    -- ============================================================
    
    -- 确保目标表存在
    CREATE TABLE IF NOT EXISTS cos_goods_sku_params (
        id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
        company_id BIGINT NOT NULL COMMENT '公司ID',
        shop_id BIGINT NOT NULL COMMENT '店铺ID（关联cos_shop.id）',
        sku_id VARCHAR(100) NOT NULL COMMENT 'SKU编码',
        monitor_date DATE NOT NULL COMMENT '监控日期',
        sales_7d INT DEFAULT 0 COMMENT '7天销量',
        sales_15d INT DEFAULT 0 COMMENT '15天销量',
        sales_30d INT DEFAULT 0 COMMENT '30天销量',
        daily_avg_sales DECIMAL(10,2) DEFAULT 0.00 COMMENT '日均销量（加权）',
        platform_inventory INT DEFAULT 0 COMMENT '平台库存',
        deleted BIGINT NOT NULL DEFAULT 0 COMMENT '删除标记：0=未删除',
        create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        PRIMARY KEY (id),
        UNIQUE KEY uk_company_shop_sku_date (company_id, shop_id, sku_id, monitor_date, deleted),
        KEY idx_monitor_date (monitor_date),
        KEY idx_company_id (company_id),
        KEY idx_shop_id (shop_id),
        KEY idx_sku_id (sku_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品SKU参数表（销量、库存等）';
    
    -- 合并JH销量数据
    INSERT INTO cos_goods_sku_params (
        company_id, shop_id, sku_id, monitor_date,
        sales_7d, sales_15d, sales_30d, daily_avg_sales,
        platform_inventory, deleted
    )
    SELECT 
        js.company_id,
        js.shop_id,
        js.sku_id,
        v_today AS monitor_date,
        js.sales_7d,
        js.sales_15d,
        js.sales_30d,
        ROUND(
            (js.sales_7d / 7.0 * 0.5) + 
            (js.sales_15d / 15.0 * 0.3) + 
            (js.sales_30d / 30.0 * 0.2),
            2
        ) AS daily_avg_sales,
        IFNULL(ji.platform_inventory, 0) AS platform_inventory,
        0 AS deleted
    FROM tmp_jh_sales js
    LEFT JOIN tmp_jh_inventory ji 
        ON js.company_id = ji.company_id 
        AND js.shop_id = ji.shop_id 
        AND js.sku_id = ji.sku_id
    ON DUPLICATE KEY UPDATE
        sales_7d = VALUES(sales_7d),
        sales_15d = VALUES(sales_15d),
        sales_30d = VALUES(sales_30d),
        daily_avg_sales = VALUES(daily_avg_sales),
        platform_inventory = VALUES(platform_inventory),
        update_time = CURRENT_TIMESTAMP;
    
    -- 合并FBA销量数据
    INSERT INTO cos_goods_sku_params (
        company_id, shop_id, sku_id, monitor_date,
        sales_7d, sales_15d, sales_30d, daily_avg_sales,
        platform_inventory, deleted
    )
    SELECT 
        fs.company_id,
        fs.shop_id,
        fs.sku_id,
        v_today AS monitor_date,
        fs.sales_7d,
        fs.sales_15d,
        fs.sales_30d,
        ROUND(
            (fs.sales_7d / 7.0 * 0.5) + 
            (fs.sales_15d / 15.0 * 0.3) + 
            (fs.sales_30d / 30.0 * 0.2),
            2
        ) AS daily_avg_sales,
        IFNULL(fi.platform_inventory, 0) AS platform_inventory,
        0 AS deleted
    FROM tmp_fba_sales fs
    LEFT JOIN tmp_fba_inventory fi 
        ON fs.company_id = fi.company_id 
        AND fs.shop_id = fi.shop_id 
        AND fs.sku_id = fi.sku_id
    ON DUPLICATE KEY UPDATE
        sales_7d = VALUES(sales_7d),
        sales_15d = VALUES(sales_15d),
        sales_30d = VALUES(sales_30d),
        daily_avg_sales = VALUES(daily_avg_sales),
        platform_inventory = VALUES(platform_inventory),
        update_time = CURRENT_TIMESTAMP;
    
    -- 合并MP销量数据（MP店铺无特定库存数据）
    INSERT INTO cos_goods_sku_params (
        company_id, shop_id, sku_id, monitor_date,
        sales_7d, sales_15d, sales_30d, daily_avg_sales,
        platform_inventory, deleted
    )
    SELECT 
        ms.company_id,
        ms.shop_id,
        ms.sku_id,
        v_today AS monitor_date,
        ms.sales_7d,
        ms.sales_15d,
        ms.sales_30d,
        ROUND(
            (ms.sales_7d / 7.0 * 0.5) + 
            (ms.sales_15d / 15.0 * 0.3) + 
            (ms.sales_30d / 30.0 * 0.2),
            2
        ) AS daily_avg_sales,
        0 AS platform_inventory,  -- MP店铺暂无库存数据
        0 AS deleted
    FROM tmp_mp_sales ms
    ON DUPLICATE KEY UPDATE
        sales_7d = VALUES(sales_7d),
        sales_15d = VALUES(sales_15d),
        sales_30d = VALUES(sales_30d),
        daily_avg_sales = VALUES(daily_avg_sales),
        platform_inventory = VALUES(platform_inventory),
        update_time = CURRENT_TIMESTAMP;
    
    -- 清理临时表
    DROP TEMPORARY TABLE IF EXISTS tmp_jh_shop_mapping;
    DROP TEMPORARY TABLE IF EXISTS tmp_fba_shop_mapping;
    DROP TEMPORARY TABLE IF EXISTS tmp_mp_shop_mapping;
    DROP TEMPORARY TABLE IF EXISTS tmp_jh_sales;
    DROP TEMPORARY TABLE IF EXISTS tmp_fba_sales;
    DROP TEMPORARY TABLE IF EXISTS tmp_mp_sales;
    DROP TEMPORARY TABLE IF EXISTS tmp_fba_inventory;
    DROP TEMPORARY TABLE IF EXISTS tmp_jh_inventory;
    
    -- 提交事务
    COMMIT;
    
END$$

DELIMITER ;

-- ============================================================
-- 使用示例
-- ============================================================
-- 按当前日期执行同步
-- CALL sp_sync_cos_goods_sku_params_daily(NULL);

-- 指定日期执行同步
-- CALL sp_sync_cos_goods_sku_params_daily('2026-02-01');
