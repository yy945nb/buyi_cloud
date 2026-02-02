-- ============================================================================
-- 存储过程: sp_sync_cos_goods_sku_params_daily
-- 功能说明: 同步商品SKU日均销量和平台库存参数
-- 创建日期: 2026-02-02
-- ============================================================================
-- 功能详情:
-- 1. 从三个来源系统同步销量数据:
--    - JH系统 (鲸汇): 使用 amf_jh_orders, 通过 amf_jh_shop → cos_shop 映射
--    - FBA系统: 使用 amf_lx_amzorder, 通过 amf_lx_shop.store_id → cos_shop.external_id
--    - MP系统 (MarketPlace): 使用 amf_lx_mporders, 通过 store_id → cos_shop.external_id
-- 2. 计算加权日均销量: 7天销量/7*0.5 + 15天销量/15*0.3 + 30天销量/30*0.2
-- 3. 同步平台库存:
--    - FBA: 使用最新 sync_date 的 amf_lx_fbadetail.available_total
--    - JH: 使用最新海外仓库存 amf_jh_shop_warehouse_stock
-- 4. 保证幂等性和数据一致性
-- ============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_sync_cos_goods_sku_params_daily`$$

CREATE PROCEDURE `sp_sync_cos_goods_sku_params_daily`(
    IN p_monitor_date DATE  -- 监控日期参数，用于指定计算哪一天的数据
)
BEGIN
    -- 声明变量
    DECLARE v_today DATE;
    DECLARE v_7days_ago DATE;
    DECLARE v_15days_ago DATE;
    DECLARE v_30days_ago DATE;
    DECLARE v_error_msg VARCHAR(500);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Error occurred: ', v_error_msg) AS error_message;
    END;
    
    -- 初始化日期变量
    SET v_today = IFNULL(p_monitor_date, CURDATE());
    SET v_7days_ago = DATE_SUB(v_today, INTERVAL 7 DAY);
    SET v_15days_ago = DATE_SUB(v_today, INTERVAL 15 DAY);
    SET v_30days_ago = DATE_SUB(v_today, INTERVAL 30 DAY);
    
    -- 开始事务
    START TRANSACTION;
    
    -- ========================================================================
    -- 步骤1: 创建临时表存储JH系统销量数据
    -- ========================================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_jh_sales;
    CREATE TEMPORARY TABLE tmp_jh_sales (
        company_id BIGINT,
        shop_id BIGINT,
        sku_code VARCHAR(128),
        sku_id BIGINT,
        sale_qty_today INT DEFAULT 0,
        sale_qty_7days INT DEFAULT 0,
        sale_qty_15days INT DEFAULT 0,
        sale_qty_30days INT DEFAULT 0,
        PRIMARY KEY (company_id, shop_id, sku_code)
    ) ENGINE=MEMORY;
    
    -- 插入JH系统销量数据
    -- JH店铺映射: amf_jh_shop.id → cos_shop.platform_shop_id → cos_shop.id
    -- 注意: 原始需求提到 extend_id 字段，但当前schema中使用 id 字段
    -- 如果未来添加 extend_id，需要修改为: jhs.extend_id = cs.platform_shop_id
    INSERT INTO tmp_jh_sales (company_id, shop_id, sku_code, sku_id, sale_qty_today, sale_qty_7days, sale_qty_15days, sale_qty_30days)
    SELECT 
        cs.company_id,
        cs.id AS shop_id,
        csku.sku_code,
        csku.id AS sku_id,
        -- 今日销量
        SUM(CASE WHEN DATE(jo.delivery_time) = v_today THEN jo.warehouse_sku_num ELSE 0 END) AS sale_qty_today,
        -- 7天销量
        SUM(CASE WHEN DATE(jo.delivery_time) >= v_7days_ago AND DATE(jo.delivery_time) <= v_today THEN jo.warehouse_sku_num ELSE 0 END) AS sale_qty_7days,
        -- 15天销量
        SUM(CASE WHEN DATE(jo.delivery_time) >= v_15days_ago AND DATE(jo.delivery_time) <= v_today THEN jo.warehouse_sku_num ELSE 0 END) AS sale_qty_15days,
        -- 30天销量
        SUM(CASE WHEN DATE(jo.delivery_time) >= v_30days_ago AND DATE(jo.delivery_time) <= v_today THEN jo.warehouse_sku_num ELSE 0 END) AS sale_qty_30days
    FROM amf_jh_orders jo
    INNER JOIN amf_jh_shop jhs ON jo.shop_id = jhs.id
    INNER JOIN cos_shop cs ON jhs.id = cs.platform_shop_id
    INNER JOIN cos_goods_sku csku ON cs.id = csku.shop_id 
        AND jo.warehouse_sku = csku.sku_code
        AND csku.is_delete = 0
    WHERE jo.order_status = 'FH'  -- 只统计已发货订单
        AND jo.delivery_time IS NOT NULL
        AND DATE(jo.delivery_time) >= v_30days_ago
        AND DATE(jo.delivery_time) <= v_today
        AND jo.warehouse_sku IS NOT NULL
        AND jo.warehouse_sku != ''
    GROUP BY cs.company_id, cs.id, csku.sku_code, csku.id;
    
    -- ========================================================================
    -- 步骤2: 创建临时表存储FBA系统销量数据
    -- ========================================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_fba_sales;
    CREATE TEMPORARY TABLE tmp_fba_sales (
        company_id BIGINT,
        shop_id BIGINT,
        sku_code VARCHAR(128),
        sku_id BIGINT,
        sale_qty_today INT DEFAULT 0,
        sale_qty_7days INT DEFAULT 0,
        sale_qty_15days INT DEFAULT 0,
        sale_qty_30days INT DEFAULT 0,
        PRIMARY KEY (company_id, shop_id, sku_code)
    ) ENGINE=MEMORY;
    
    -- 插入FBA系统销量数据
    -- FBA店铺映射: amf_lx_shop.store_id → cos_shop.external_id (cos_shop.type=1, MIN(id)唯一化)
    -- 销量日期使用: shipment_date_utc (需要健壮解析)
    INSERT INTO tmp_fba_sales (company_id, shop_id, sku_code, sku_id, sale_qty_today, sale_qty_7days, sale_qty_15days, sale_qty_30days)
    SELECT 
        cs.company_id,
        cs.id AS shop_id,
        csku.sku_code,
        csku.id AS sku_id,
        -- 今日销量
        SUM(CASE 
            WHEN DATE(STR_TO_DATE(TRIM(ao.shipment_date_utc), '%Y-%m-%d %H:%i:%s')) = v_today 
            THEN aoi.quantity_ordered 
            ELSE 0 
        END) AS sale_qty_today,
        -- 7天销量
        SUM(CASE 
            WHEN DATE(STR_TO_DATE(TRIM(ao.shipment_date_utc), '%Y-%m-%d %H:%i:%s')) >= v_7days_ago 
                AND DATE(STR_TO_DATE(TRIM(ao.shipment_date_utc), '%Y-%m-%d %H:%i:%s')) <= v_today 
            THEN aoi.quantity_ordered 
            ELSE 0 
        END) AS sale_qty_7days,
        -- 15天销量
        SUM(CASE 
            WHEN DATE(STR_TO_DATE(TRIM(ao.shipment_date_utc), '%Y-%m-%d %H:%i:%s')) >= v_15days_ago 
                AND DATE(STR_TO_DATE(TRIM(ao.shipment_date_utc), '%Y-%m-%d %H:%i:%s')) <= v_today 
            THEN aoi.quantity_ordered 
            ELSE 0 
        END) AS sale_qty_15days,
        -- 30天销量
        SUM(CASE 
            WHEN DATE(STR_TO_DATE(TRIM(ao.shipment_date_utc), '%Y-%m-%d %H:%i:%s')) >= v_30days_ago 
                AND DATE(STR_TO_DATE(TRIM(ao.shipment_date_utc), '%Y-%m-%d %H:%i:%s')) <= v_today 
            THEN aoi.quantity_ordered 
            ELSE 0 
        END) AS sale_qty_30days
    FROM amf_lx_amzorder ao
    INNER JOIN amf_lx_amzorder_item aoi ON ao.id = aoi.amzorder_id
    INNER JOIN amf_lx_shop lxs ON ao.sid = lxs.store_id
    INNER JOIN (
        -- 获取每个external_id的最小shop_id，确保唯一性
        SELECT external_id, MIN(id) AS id
        FROM cos_shop
        WHERE type = '1'  -- FBA类型
            AND deleted = 0
        GROUP BY external_id
    ) cs_min ON lxs.store_id = cs_min.external_id
    INNER JOIN cos_shop cs ON cs_min.id = cs.id
    INNER JOIN cos_goods_sku csku ON cs.id = csku.shop_id 
        AND aoi.local_sku = csku.sku_code
        AND csku.is_delete = 0
    WHERE ao.fulfillment_channel = 'AFN'  -- 只统计FBA订单
        AND ao.shipment_date_utc IS NOT NULL
        AND ao.shipment_date_utc != ''
        -- 使用健壮的日期解析和过滤
        AND STR_TO_DATE(TRIM(ao.shipment_date_utc), '%Y-%m-%d %H:%i:%s') IS NOT NULL
        AND DATE(STR_TO_DATE(TRIM(ao.shipment_date_utc), '%Y-%m-%d %H:%i:%s')) >= v_30days_ago
        AND DATE(STR_TO_DATE(TRIM(ao.shipment_date_utc), '%Y-%m-%d %H:%i:%s')) <= v_today
        AND aoi.local_sku IS NOT NULL
        AND aoi.local_sku != ''
    GROUP BY cs.company_id, cs.id, csku.sku_code, csku.id;
    
    -- ========================================================================
    -- 步骤3: 创建临时表存储MP系统销量数据
    -- ========================================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_mp_sales;
    CREATE TEMPORARY TABLE tmp_mp_sales (
        company_id BIGINT,
        shop_id BIGINT,
        sku_code VARCHAR(128),
        sku_id BIGINT,
        sale_qty_today INT DEFAULT 0,
        sale_qty_7days INT DEFAULT 0,
        sale_qty_15days INT DEFAULT 0,
        sale_qty_30days INT DEFAULT 0,
        PRIMARY KEY (company_id, shop_id, sku_code)
    ) ENGINE=MEMORY;
    
    -- 插入MP系统销量数据
    -- MP店铺映射: amf_lx_mporders.store_id → cos_shop.external_id (cos_shop.type=1, MIN(id)唯一化)
    -- 销量日期使用: global_create_time 字段，先解析为 DATETIME
    INSERT INTO tmp_mp_sales (company_id, shop_id, sku_code, sku_id, sale_qty_today, sale_qty_7days, sale_qty_15days, sale_qty_30days)
    SELECT 
        cs.company_id,
        cs.id AS shop_id,
        csku.sku_code,
        csku.id AS sku_id,
        -- 今日销量
        SUM(CASE 
            WHEN DATE(STR_TO_DATE(TRIM(mpo.global_create_time), '%Y-%m-%d %H:%i:%s')) = v_today 
            THEN mpoi.quantity 
            ELSE 0 
        END) AS sale_qty_today,
        -- 7天销量
        SUM(CASE 
            WHEN DATE(STR_TO_DATE(TRIM(mpo.global_create_time), '%Y-%m-%d %H:%i:%s')) >= v_7days_ago 
                AND DATE(STR_TO_DATE(TRIM(mpo.global_create_time), '%Y-%m-%d %H:%i:%s')) <= v_today 
            THEN mpoi.quantity 
            ELSE 0 
        END) AS sale_qty_7days,
        -- 15天销量
        SUM(CASE 
            WHEN DATE(STR_TO_DATE(TRIM(mpo.global_create_time), '%Y-%m-%d %H:%i:%s')) >= v_15days_ago 
                AND DATE(STR_TO_DATE(TRIM(mpo.global_create_time), '%Y-%m-%d %H:%i:%s')) <= v_today 
            THEN mpoi.quantity 
            ELSE 0 
        END) AS sale_qty_15days,
        -- 30天销量
        SUM(CASE 
            WHEN DATE(STR_TO_DATE(TRIM(mpo.global_create_time), '%Y-%m-%d %H:%i:%s')) >= v_30days_ago 
                AND DATE(STR_TO_DATE(TRIM(mpo.global_create_time), '%Y-%m-%d %H:%i:%s')) <= v_today 
            THEN mpoi.quantity 
            ELSE 0 
        END) AS sale_qty_30days
    FROM amf_lx_mporders mpo
    INNER JOIN amf_lx_mporders_item mpoi ON mpo.global_order_no = mpoi.global_order_no
    INNER JOIN amf_lx_shop lxs ON mpo.store_id = lxs.store_id
    INNER JOIN (
        -- 获取每个external_id的最小shop_id，确保唯一性
        SELECT external_id, MIN(id) AS id
        FROM cos_shop
        WHERE type = '1'  -- MP也使用type=1
            AND deleted = 0
        GROUP BY external_id
    ) cs_min ON lxs.store_id = cs_min.external_id
    INNER JOIN cos_shop cs ON cs_min.id = cs.id
    INNER JOIN cos_goods_sku csku ON cs.id = csku.shop_id 
        AND mpoi.local_sku = csku.sku_code
        AND csku.is_delete = 0
    WHERE mpo.status = 6  -- 已完成状态
        AND mpo.global_create_time IS NOT NULL
        AND mpo.global_create_time != ''
        -- 使用健壮的日期解析和过滤
        AND STR_TO_DATE(TRIM(mpo.global_create_time), '%Y-%m-%d %H:%i:%s') IS NOT NULL
        AND DATE(STR_TO_DATE(TRIM(mpo.global_create_time), '%Y-%m-%d %H:%i:%s')) >= v_30days_ago
        AND DATE(STR_TO_DATE(TRIM(mpo.global_create_time), '%Y-%m-%d %H:%i:%s')) <= v_today
        AND mpoi.local_sku IS NOT NULL
        AND mpoi.local_sku != ''
    GROUP BY cs.company_id, cs.id, csku.sku_code, csku.id;
    
    -- ========================================================================
    -- 步骤4: 合并所有销量数据并计算加权日均销量
    -- ========================================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_all_sales;
    CREATE TEMPORARY TABLE tmp_all_sales (
        company_id BIGINT,
        shop_id BIGINT,
        sku_code VARCHAR(128),
        sku_id BIGINT,
        sale_qty_today INT DEFAULT 0,
        sale_qty_7days INT DEFAULT 0,
        sale_qty_15days INT DEFAULT 0,
        sale_qty_30days INT DEFAULT 0,
        daily_sales DECIMAL(10,4) DEFAULT 0.0000,
        PRIMARY KEY (company_id, shop_id, sku_id)
    ) ENGINE=MEMORY;
    
    -- 合并三个来源的销量数据
    INSERT INTO tmp_all_sales (company_id, shop_id, sku_code, sku_id, sale_qty_today, sale_qty_7days, sale_qty_15days, sale_qty_30days, daily_sales)
    SELECT 
        company_id,
        shop_id,
        sku_code,
        sku_id,
        SUM(sale_qty_today) AS sale_qty_today,
        SUM(sale_qty_7days) AS sale_qty_7days,
        SUM(sale_qty_15days) AS sale_qty_15days,
        SUM(sale_qty_30days) AS sale_qty_30days,
        -- 加权日均销量计算: 7天销量/7*0.5 + 15天销量/15*0.3 + 30天销量/30*0.2
        ROUND(
            (SUM(sale_qty_7days) / 7.0 * 0.5) + 
            (SUM(sale_qty_15days) / 15.0 * 0.3) + 
            (SUM(sale_qty_30days) / 30.0 * 0.2),
            4
        ) AS daily_sales
    FROM (
        SELECT company_id, shop_id, sku_code, sku_id, sale_qty_today, sale_qty_7days, sale_qty_15days, sale_qty_30days
        FROM tmp_jh_sales
        UNION ALL
        SELECT company_id, shop_id, sku_code, sku_id, sale_qty_today, sale_qty_7days, sale_qty_15days, sale_qty_30days
        FROM tmp_fba_sales
        UNION ALL
        SELECT company_id, shop_id, sku_code, sku_id, sale_qty_today, sale_qty_7days, sale_qty_15days, sale_qty_30days
        FROM tmp_mp_sales
    ) combined
    GROUP BY company_id, shop_id, sku_code, sku_id;
    
    -- ========================================================================
    -- 步骤5: 创建临时表存储平台库存数据
    -- ========================================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_platform_stock;
    CREATE TEMPORARY TABLE tmp_platform_stock (
        shop_id BIGINT,
        sku_code VARCHAR(128),
        available_stock INT DEFAULT 0,
        PRIMARY KEY (shop_id, sku_code)
    ) ENGINE=MEMORY;
    
    -- 插入FBA平台库存 - 使用最大sync_date的available_total
    INSERT INTO tmp_platform_stock (shop_id, sku_code, available_stock)
    SELECT 
        cs.id AS shop_id,
        fba.seller_sku AS sku_code,
        fba.available_total AS available_stock
    FROM (
        -- 获取每个店铺+SKU的最新sync_date
        SELECT 
            sid,
            seller_sku,
            MAX(sync_date) AS max_sync_date
        FROM amf_lx_fbadetail
        WHERE sync_date IS NOT NULL
        GROUP BY sid, seller_sku
    ) max_sync
    INNER JOIN amf_lx_fbadetail fba 
        ON max_sync.sid = fba.sid 
        AND max_sync.seller_sku = fba.seller_sku 
        AND max_sync.max_sync_date = fba.sync_date
    INNER JOIN amf_lx_shop lxs ON fba.sid = lxs.s_id
    INNER JOIN (
        SELECT external_id, MIN(id) AS id
        FROM cos_shop
        WHERE type = '1'
            AND deleted = 0
        GROUP BY external_id
    ) cs_min ON lxs.store_id = cs_min.external_id
    INNER JOIN cos_shop cs ON cs_min.id = cs.id;
    
    -- 插入JH海外仓库存 - 使用最新库存（基于update_time）
    INSERT INTO tmp_platform_stock (shop_id, sku_code, available_stock)
    SELECT 
        cs.id AS shop_id,
        jws.warehouse_sku AS sku_code,
        jws.available_qty AS available_stock
    FROM (
        -- 获取每个店铺+SKU的最新数据（基于update_time）
        SELECT 
            shop_id,
            warehouse_sku,
            MAX(update_time) AS max_update_time
        FROM amf_jh_shop_warehouse_stock
        WHERE update_time IS NOT NULL
        GROUP BY shop_id, warehouse_sku
    ) max_jh
    INNER JOIN amf_jh_shop_warehouse_stock jws 
        ON max_jh.shop_id = jws.shop_id 
        AND max_jh.warehouse_sku = jws.warehouse_sku 
        AND max_jh.max_update_time = jws.update_time
    INNER JOIN amf_jh_shop jhs ON jws.shop_id = jhs.id
    INNER JOIN cos_shop cs ON jhs.id = cs.platform_shop_id
    WHERE cs.deleted = 0
    ON DUPLICATE KEY UPDATE 
        available_stock = available_stock + VALUES(available_stock);
    
    -- ========================================================================
    -- 步骤6: 删除当前日期的旧数据 (保证幂等性)
    -- ========================================================================
    DELETE FROM cos_goods_sku_daily_sale 
    WHERE sync_date = v_today 
        AND deleted = 0;
    
    -- ========================================================================
    -- 步骤7: 插入最终数据到目标表
    -- ========================================================================
    INSERT INTO cos_goods_sku_daily_sale (
        id,
        company_id,
        shop_id,
        goods_id,
        skc_id,
        sku_id,
        sku_code,
        daily_sales,
        expected_daily_sales,
        sync_date,
        create_time,
        update_time,
        deleted
    )
    SELECT 
        generate_snowflake_id() AS id,  -- 使用雪花算法生成ID
        tas.company_id,
        tas.shop_id,
        csku.spu_id AS goods_id,
        csku.skc_id,
        tas.sku_id,
        tas.sku_code,
        tas.daily_sales,
        tas.daily_sales AS expected_daily_sales,  -- 暂时使用相同值
        v_today AS sync_date,
        NOW() AS create_time,
        NOW() AS update_time,
        0 AS deleted
    FROM tmp_all_sales tas
    INNER JOIN cos_goods_sku csku ON tas.sku_id = csku.id
    ON DUPLICATE KEY UPDATE
        daily_sales = VALUES(daily_sales),
        expected_daily_sales = VALUES(expected_daily_sales),
        update_time = NOW();
    
    -- ========================================================================
    -- 步骤8: 更新库存表 (如果需要同步库存数据)
    -- ========================================================================
    -- 注意: 这里可以根据业务需求选择是否更新cos_goods_sku_stock表
    -- 暂时注释，因为不确定是否需要在这个存储过程中更新库存
    /*
    INSERT INTO cos_goods_sku_stock (
        id,
        company_id,
        shop_id,
        goods_id,
        sku_id,
        sale_stock_num,
        sync_date,
        create_time,
        update_time,
        deleted
    )
    SELECT 
        generate_snowflake_id() AS id,
        cs.company_id,
        tps.shop_id,
        csku.spu_id AS goods_id,
        csku.id AS sku_id,
        tps.available_stock AS sale_stock_num,
        v_today AS sync_date,
        NOW() AS create_time,
        NOW() AS update_time,
        0 AS deleted
    FROM tmp_platform_stock tps
    INNER JOIN cos_shop cs ON tps.shop_id = cs.id
    INNER JOIN cos_goods_sku csku ON tps.shop_id = csku.shop_id 
        AND tps.sku_code = csku.sku_code
    WHERE cs.deleted = 0
        AND csku.is_delete = 0
    ON DUPLICATE KEY UPDATE
        sale_stock_num = VALUES(sale_stock_num),
        update_time = NOW();
    */
    
    -- 清理临时表
    DROP TEMPORARY TABLE IF EXISTS tmp_jh_sales;
    DROP TEMPORARY TABLE IF EXISTS tmp_fba_sales;
    DROP TEMPORARY TABLE IF EXISTS tmp_mp_sales;
    DROP TEMPORARY TABLE IF EXISTS tmp_all_sales;
    DROP TEMPORARY TABLE IF EXISTS tmp_platform_stock;
    
    -- 提交事务
    COMMIT;
    
    -- 返回执行结果
    SELECT 
        CONCAT('Procedure completed successfully for date: ', v_today) AS result_message,
        (SELECT COUNT(*) FROM cos_goods_sku_daily_sale WHERE sync_date = v_today AND deleted = 0) AS records_inserted;
    
END$$

DELIMITER ;

-- ============================================================================
-- 使用示例:
-- ============================================================================
-- 1. 同步今天的数据:
-- CALL sp_sync_cos_goods_sku_params_daily(NULL);
--
-- 2. 同步指定日期的数据:
-- CALL sp_sync_cos_goods_sku_params_daily('2026-02-01');
-- ============================================================================
