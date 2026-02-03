-- ===========================================
-- 产品断货点监控 - ETL存储过程
-- Product Stockout Monitoring - ETL Stored Procedures
-- ===========================================

DELIMITER $$

-- ===========================================
-- 存储过程: 生成产品断货点监控快照
-- Stored Procedure: Generate Product Stockout Monitoring Snapshot
-- ===========================================

DROP PROCEDURE IF EXISTS `sp_generate_stockout_monitoring_snapshot`$$

CREATE PROCEDURE `sp_generate_stockout_monitoring_snapshot`(
    IN p_snapshot_date DATE,
    IN p_company_id BIGINT,
    IN p_regional_warehouse_id BIGINT,
    OUT p_success_count INT,
    OUT p_error_count INT,
    OUT p_batch_id VARCHAR(64)
)
BEGIN
    DECLARE v_error_code VARCHAR(10);
    DECLARE v_error_msg TEXT;
    DECLARE v_execution_start DATETIME;
    DECLARE v_execution_end DATETIME;
    DECLARE v_duration_ms BIGINT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_code = RETURNED_SQLSTATE,
            v_error_msg = MESSAGE_TEXT;
        
        SET p_error_count = p_error_count + 1;
        
        -- 更新执行日志为失败
        UPDATE monitoring_execution_log
        SET status = 'FAILED',
            error_count = p_error_count,
            error_message = CONCAT('Error Code: ', v_error_code, ' - ', v_error_msg),
            duration_ms = TIMESTAMPDIFF(MICROSECOND, v_execution_start, NOW()) / 1000
        WHERE batch_id = p_batch_id;
        
        -- 回滚事务
        ROLLBACK;
    END;
    
    -- 初始化变量
    SET p_success_count = 0;
    SET p_error_count = 0;
    SET v_execution_start = NOW();
    
    -- 生成批次ID
    SET p_batch_id = CONCAT('SNAPSHOT_', DATE_FORMAT(p_snapshot_date, '%Y%m%d'), '_', UNIX_TIMESTAMP() * 1000);
    
    -- 记录执行开始日志
    INSERT INTO monitoring_execution_log (
        batch_id, task_type, snapshot_date, execution_time, status
    ) VALUES (
        p_batch_id, 'DAILY_SNAPSHOT', p_snapshot_date, v_execution_start, 'RUNNING'
    );
    
    START TRANSACTION;
    
    -- ===========================================
    -- 步骤1: 生成JH_LX模式的监控快照
    -- ===========================================
    
    INSERT INTO product_stockout_monitoring (
        product_id, product_sku, product_name, company_id, 
        regional_warehouse_id, regional_warehouse_code, 
        business_mode, snapshot_date,
        overseas_inventory, in_transit_inventory,
        domestic_remaining_qty, domestic_actual_stock_qty,
        total_inventory, available_inventory,
        daily_avg_sales, regional_proportion, regional_daily_sales,
        safety_stock_days, stocking_cycle_days, shipping_days, lead_time_days,
        stockout_point, safety_stock_quantity, available_days, stockout_risk_days,
        is_stockout_risk, risk_level
    )
    SELECT 
        p.product_id,
        p.product_sku,
        p.product_name,
        COALESCE(p_company_id, p.company_id) as company_id,
        rw.regional_warehouse_id,
        rw.regional_warehouse_code,
        'JH_LX' as business_mode,
        p_snapshot_date as snapshot_date,
        
        -- 海外仓库存 (JH + LX 合并)
        COALESCE(
            (SELECT SUM(stock_qty)
             FROM (
                 SELECT SUM(jh.stock_num) as stock_qty
                 FROM amf_jh_warehouse_stock jh
                 JOIN regional_warehouse_binding rwb ON jh.warehouse_id = rwb.warehouse_id
                 WHERE jh.warehouse_sku = p.product_sku
                   AND rwb.regional_warehouse_id = rw.regional_warehouse_id
                   AND rwb.business_mode IN ('JH', 'LX')
                   AND rwb.is_active = 1
                 
                 UNION ALL
                 
                 SELECT SUM(lx.product_valid_num) as stock_qty
                 FROM amf_lx_warehouse_stock lx
                 JOIN regional_warehouse_binding rwb ON lx.wid = rwb.warehouse_id
                 WHERE lx.sku = p.product_sku
                   AND rwb.regional_warehouse_id = rw.regional_warehouse_id
                   AND rwb.business_mode IN ('JH', 'LX')
                   AND rwb.is_active = 1
             ) combined_stock),
            0
        ) as overseas_inventory,
        
        -- 在途库存 (JH + LX 发货单合并)
        COALESCE(
            (SELECT SUM(intransit_qty)
             FROM (
                 -- JH 发货单
                 SELECT SUM(jhs.quantity - COALESCE(jhs.received_quantity, 0)) as intransit_qty
                 FROM amf_jh_shipment jh
                 JOIN amf_jh_shipment_sku jhs ON jh.id = jhs.shipment_id
                 JOIN regional_warehouse_binding rwb ON jh.warehouse_id = rwb.warehouse_id
                 WHERE jhs.sku = p.product_sku
                   AND rwb.regional_warehouse_id = rw.regional_warehouse_id
                   AND rwb.business_mode = 'JH'
                   AND jh.status IN ('SHIPPED', 'IN_TRANSIT')
                   AND jh.ship_date <= p_snapshot_date
                 
                 UNION ALL
                 
                 -- LX OWMS 发货单
                 SELECT SUM(lxs.quantity - COALESCE(lxs.received_quantity, 0)) as intransit_qty
                 FROM amf_lx_owmsshipment lx
                 JOIN amf_lx_owmsshipment_products lxs ON lx.id = lxs.shipment_id
                 JOIN regional_warehouse_binding rwb ON lx.warehouse_id = rwb.warehouse_id
                 WHERE lxs.sku = p.product_sku
                   AND rwb.regional_warehouse_id = rw.regional_warehouse_id
                   AND rwb.business_mode = 'LX'
                   AND lx.status IN ('SHIPPED', 'IN_TRANSIT')
                   AND lx.ship_date <= p_snapshot_date
             ) combined_intransit),
            0
        ) as in_transit_inventory,
        
        -- 国内仓库存 (共享数据)
        COALESCE(di.remaining_qty, 0) as domestic_remaining_qty,
        COALESCE(di.actual_stock_qty, 0) as domestic_actual_stock_qty,
        
        -- 总库存和可用库存
        0 as total_inventory,  -- 后续计算
        0 as available_inventory,  -- 后续计算
        
        -- 销量指标
        COALESCE(psp.daily_sale_qty, 0) as daily_avg_sales,
        COALESCE(orp.weighted_proportion, 0) as regional_proportion,
        0 as regional_daily_sales,  -- 后续计算
        
        -- 周期参数
        COALESCE(rwp.safety_stock_days, 30) as safety_stock_days,
        COALESCE(rwp.stocking_cycle_days, 30) as stocking_cycle_days,
        COALESCE(rwp.shipping_days, 45) as shipping_days,
        COALESCE(rwp.lead_time_days, 75) as lead_time_days,
        
        -- 断货点指标 (后续计算)
        0 as stockout_point,
        0 as safety_stock_quantity,
        0 as available_days,
        0 as stockout_risk_days,
        0 as is_stockout_risk,
        'SAFE' as risk_level
        
    FROM (
        SELECT DISTINCT 
            c.id as product_id,
            cs.sku as product_sku,
            c.product_name,
            cs.company_id
        FROM pms_commodity c
        JOIN pms_commodity_sku cs ON c.id = cs.commodity_id
        WHERE (p_company_id IS NULL OR cs.company_id = p_company_id)
          AND cs.status = 'ACTIVE'
    ) p
    
    CROSS JOIN (
        SELECT 
            regional_warehouse_id,
            regional_warehouse_code
        FROM dw_dim_regional_warehouse
        WHERE is_current = 1
          AND status = 'ACTIVE'
          AND (p_regional_warehouse_id IS NULL OR regional_warehouse_id = p_regional_warehouse_id)
    ) rw
    
    LEFT JOIN (
        -- 国内仓库存聚合
        SELECT 
            local_sku as product_sku,
            SUM(remaining_num) as remaining_qty,
            SUM(stock_num) as actual_stock_qty
        FROM amf_jh_company_stock
        WHERE sync_date = (
            SELECT MAX(sync_date) 
            FROM amf_jh_company_stock 
            WHERE sync_date <= p_snapshot_date
        )
        GROUP BY local_sku
    ) di ON p.product_sku = di.product_sku
    
    LEFT JOIN pms_commodity_sku_params psp 
        ON p.product_sku = psp.sku 
        AND psp.param_date = p_snapshot_date
    
    LEFT JOIN order_regional_proportion orp 
        ON p.product_sku = orp.product_sku 
        AND rw.regional_warehouse_id = orp.regional_warehouse_id
        AND orp.calculation_date = p_snapshot_date
    
    LEFT JOIN regional_warehouse_params rwp 
        ON rw.regional_warehouse_id = rwp.regional_warehouse_id
        AND rwp.is_active = 1
        AND p_snapshot_date BETWEEN rwp.effective_date AND rwp.expiry_date
    
    ON DUPLICATE KEY UPDATE
        overseas_inventory = VALUES(overseas_inventory),
        in_transit_inventory = VALUES(in_transit_inventory),
        domestic_remaining_qty = VALUES(domestic_remaining_qty),
        domestic_actual_stock_qty = VALUES(domestic_actual_stock_qty),
        daily_avg_sales = VALUES(daily_avg_sales),
        regional_proportion = VALUES(regional_proportion),
        safety_stock_days = VALUES(safety_stock_days),
        stocking_cycle_days = VALUES(stocking_cycle_days),
        shipping_days = VALUES(shipping_days),
        lead_time_days = VALUES(lead_time_days),
        update_time = CURRENT_TIMESTAMP;
    
    SET p_success_count = p_success_count + ROW_COUNT();
    
    -- ===========================================
    -- 步骤2: 生成FBA模式的监控快照
    -- ===========================================
    
    INSERT INTO product_stockout_monitoring (
        product_id, product_sku, product_name, company_id,
        regional_warehouse_id, regional_warehouse_code,
        business_mode, snapshot_date,
        overseas_inventory, in_transit_inventory,
        domestic_remaining_qty, domestic_actual_stock_qty,
        total_inventory, available_inventory,
        daily_avg_sales, regional_proportion, regional_daily_sales,
        safety_stock_days, stocking_cycle_days, shipping_days, lead_time_days,
        stockout_point, safety_stock_quantity, available_days, stockout_risk_days,
        is_stockout_risk, risk_level
    )
    SELECT 
        p.product_id,
        p.product_sku,
        p.product_name,
        COALESCE(p_company_id, p.company_id) as company_id,
        rw.regional_warehouse_id,
        rw.regional_warehouse_code,
        'FBA' as business_mode,
        p_snapshot_date as snapshot_date,
        
        -- FBA 海外仓库存 (available_total)
        COALESCE(fba.available_total, 0) as overseas_inventory,
        
        -- FBA 在途库存
        COALESCE(
            (SELECT SUM(fbas.quantity - COALESCE(fbas.received_quantity, 0))
             FROM amf_lx_fbashipment fba_ship
             JOIN amf_lx_fbashipment_item fbas ON fba_ship.id = fbas.shipment_id
             WHERE fbas.sku = p.product_sku
               AND fba_ship.status IN ('SHIPPED', 'IN_TRANSIT')
               AND fba_ship.ship_date <= p_snapshot_date),
            0
        ) as in_transit_inventory,
        
        -- 国内仓库存 (共享数据)
        COALESCE(di.remaining_qty, 0) as domestic_remaining_qty,
        COALESCE(di.actual_stock_qty, 0) as domestic_actual_stock_qty,
        
        -- 总库存和可用库存
        0 as total_inventory,
        0 as available_inventory,
        
        -- 销量指标
        COALESCE(psp.daily_sale_qty, 0) as daily_avg_sales,
        COALESCE(orp.weighted_proportion, 0) as regional_proportion,
        0 as regional_daily_sales,
        
        -- 周期参数
        COALESCE(rwp.safety_stock_days, 30) as safety_stock_days,
        COALESCE(rwp.stocking_cycle_days, 30) as stocking_cycle_days,
        COALESCE(rwp.shipping_days, 45) as shipping_days,
        COALESCE(rwp.lead_time_days, 75) as lead_time_days,
        
        -- 断货点指标
        0 as stockout_point,
        0 as safety_stock_quantity,
        0 as available_days,
        0 as stockout_risk_days,
        0 as is_stockout_risk,
        'SAFE' as risk_level
        
    FROM (
        SELECT DISTINCT 
            c.id as product_id,
            cs.sku as product_sku,
            c.product_name,
            cs.company_id
        FROM pms_commodity c
        JOIN pms_commodity_sku cs ON c.id = cs.commodity_id
        WHERE (p_company_id IS NULL OR cs.company_id = p_company_id)
          AND cs.status = 'ACTIVE'
    ) p
    
    CROSS JOIN (
        SELECT 
            regional_warehouse_id,
            regional_warehouse_code
        FROM dw_dim_regional_warehouse
        WHERE is_current = 1
          AND status = 'ACTIVE'
          AND (p_regional_warehouse_id IS NULL OR regional_warehouse_id = p_regional_warehouse_id)
    ) rw
    
    LEFT JOIN (
        -- FBA库存
        SELECT 
            sku as product_sku,
            SUM(available_total) as available_total
        FROM amf_lx_fbadetail
        WHERE data_date = p_snapshot_date
        GROUP BY sku
    ) fba ON p.product_sku = fba.product_sku
    
    LEFT JOIN (
        -- 国内仓库存聚合
        SELECT 
            local_sku as product_sku,
            SUM(remaining_num) as remaining_qty,
            SUM(stock_num) as actual_stock_qty
        FROM amf_jh_company_stock
        WHERE sync_date = (
            SELECT MAX(sync_date) 
            FROM amf_jh_company_stock 
            WHERE sync_date <= p_snapshot_date
        )
        GROUP BY local_sku
    ) di ON p.product_sku = di.product_sku
    
    LEFT JOIN pms_commodity_sku_params psp 
        ON p.product_sku = psp.sku 
        AND psp.param_date = p_snapshot_date
    
    LEFT JOIN order_regional_proportion orp 
        ON p.product_sku = orp.product_sku 
        AND rw.regional_warehouse_id = orp.regional_warehouse_id
        AND orp.calculation_date = p_snapshot_date
    
    LEFT JOIN regional_warehouse_params rwp 
        ON rw.regional_warehouse_id = rwp.regional_warehouse_id
        AND rwp.is_active = 1
        AND p_snapshot_date BETWEEN rwp.effective_date AND rwp.expiry_date
    
    ON DUPLICATE KEY UPDATE
        overseas_inventory = VALUES(overseas_inventory),
        in_transit_inventory = VALUES(in_transit_inventory),
        domestic_remaining_qty = VALUES(domestic_remaining_qty),
        domestic_actual_stock_qty = VALUES(domestic_actual_stock_qty),
        daily_avg_sales = VALUES(daily_avg_sales),
        regional_proportion = VALUES(regional_proportion),
        safety_stock_days = VALUES(safety_stock_days),
        stocking_cycle_days = VALUES(stocking_cycle_days),
        shipping_days = VALUES(shipping_days),
        lead_time_days = VALUES(lead_time_days),
        update_time = CURRENT_TIMESTAMP;
    
    SET p_success_count = p_success_count + ROW_COUNT();
    
    -- ===========================================
    -- 步骤3: 计算派生字段
    -- ===========================================
    
    UPDATE product_stockout_monitoring
    SET 
        -- 计算总库存
        total_inventory = overseas_inventory + in_transit_inventory,
        
        -- 计算可用库存 (简化：使用海外仓库存)
        available_inventory = overseas_inventory,
        
        -- 计算区域日均销量
        regional_daily_sales = daily_avg_sales * regional_proportion,
        
        -- 计算断货点
        stockout_point = FLOOR(daily_avg_sales * regional_proportion * lead_time_days),
        
        -- 计算安全库存数量
        safety_stock_quantity = FLOOR(daily_avg_sales * regional_proportion * safety_stock_days),
        
        -- 计算可售天数
        available_days = CASE 
            WHEN daily_avg_sales * regional_proportion > 0 
            THEN overseas_inventory / (daily_avg_sales * regional_proportion)
            ELSE 999 
        END,
        
        -- 计算断货风险天数
        stockout_risk_days = CASE 
            WHEN daily_avg_sales * regional_proportion > 0 
            THEN FLOOR(overseas_inventory / (daily_avg_sales * regional_proportion)) - (lead_time_days + safety_stock_days)
            ELSE 999 
        END,
        
        -- 判断是否有断货风险
        is_stockout_risk = CASE 
            WHEN daily_avg_sales * regional_proportion > 0 
                 AND overseas_inventory / (daily_avg_sales * regional_proportion) < (lead_time_days + safety_stock_days)
            THEN 1 
            ELSE 0 
        END,
        
        -- 计算风险等级
        risk_level = CASE 
            WHEN daily_avg_sales * regional_proportion <= 0 THEN 'SAFE'
            WHEN overseas_inventory / (daily_avg_sales * regional_proportion) <= 0 THEN 'STOCKOUT'
            WHEN overseas_inventory / (daily_avg_sales * regional_proportion) < safety_stock_days * 0.5 THEN 'DANGER'
            WHEN overseas_inventory / (daily_avg_sales * regional_proportion) < safety_stock_days THEN 'WARNING'
            ELSE 'SAFE'
        END
        
    WHERE snapshot_date = p_snapshot_date
      AND (p_company_id IS NULL OR company_id = p_company_id)
      AND (p_regional_warehouse_id IS NULL OR regional_warehouse_id = p_regional_warehouse_id);
    
    COMMIT;
    
    -- 记录执行完成
    SET v_execution_end = NOW();
    SET v_duration_ms = TIMESTAMPDIFF(MICROSECOND, v_execution_start, v_execution_end) / 1000;
    
    UPDATE monitoring_execution_log
    SET status = 'COMPLETED',
        total_products = p_success_count,
        success_count = p_success_count,
        error_count = p_error_count,
        warning_count = (
            SELECT COUNT(*) 
            FROM product_stockout_monitoring 
            WHERE snapshot_date = p_snapshot_date 
              AND risk_level = 'WARNING'
        ),
        danger_count = (
            SELECT COUNT(*) 
            FROM product_stockout_monitoring 
            WHERE snapshot_date = p_snapshot_date 
              AND risk_level IN ('DANGER', 'STOCKOUT')
        ),
        duration_ms = v_duration_ms
    WHERE batch_id = p_batch_id;
    
END$$

DELIMITER ;

-- ===========================================
-- 使用示例 / Usage Examples
-- ===========================================

/*
-- 生成今天的监控快照（所有公司和区域仓）
CALL sp_generate_stockout_monitoring_snapshot(
    CURDATE(),  -- snapshot_date
    NULL,       -- company_id (NULL表示所有公司)
    NULL,       -- regional_warehouse_id (NULL表示所有区域仓)
    @success_count,
    @error_count,
    @batch_id
);
SELECT @batch_id, @success_count, @error_count;

-- 生成指定日期的监控快照
CALL sp_generate_stockout_monitoring_snapshot(
    '2024-01-15',  -- snapshot_date
    1,             -- company_id (指定公司)
    1,             -- regional_warehouse_id (指定区域仓)
    @success_count,
    @error_count,
    @batch_id
);
SELECT @batch_id, @success_count, @error_count;

-- 查看执行日志
SELECT * FROM monitoring_execution_log 
WHERE batch_id = @batch_id;

-- 查看生成的监控数据
SELECT * FROM product_stockout_monitoring
WHERE snapshot_date = CURDATE()
  AND risk_level IN ('WARNING', 'DANGER', 'STOCKOUT')
ORDER BY risk_level DESC, available_days ASC
LIMIT 20;
*/
