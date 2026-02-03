-- ===========================================
-- 断货点监控模型测试SQL
-- Stock-Out Monitoring Model Test SQL
-- ===========================================

-- 说明：本文件包含测试用例和验证SQL，用于验证断货点监控模型的功能
-- Description: This file contains test cases and validation SQL for the stock-out monitoring model

-- ===========================================
-- 测试数据准备
-- Test Data Preparation
-- ===========================================

-- 1. 插入测试区域仓配置
INSERT INTO region_warehouse_config 
    (company_id, region_warehouse_id, region_warehouse_code, region_warehouse_name, 
     region_code, country_code, warehouse_type, is_active)
VALUES
    (1, 1001, 'RW_US_WEST', '美西区域仓', 'US_WEST', 'US', 'REGIONAL', 1),
    (1, 1002, 'RW_US_EAST', '美东区域仓', 'US_EAST', 'US', 'REGIONAL', 1),
    (1, 2001, 'FBA_US_WEST', 'FBA美西', 'US_WEST', 'US', 'FBA', 1),
    (1, 2002, 'FBA_US_EAST', 'FBA美东', 'US_EAST', 'US', 'FBA', 1)
ON DUPLICATE KEY UPDATE update_time = CURRENT_TIMESTAMP;

-- 2. 插入测试仓库映射（假设wms_warehouse已有数据，这里使用虚拟ID）
INSERT INTO warehouse_mapping
    (company_id, warehouse_id, source_system, external_warehouse_code, 
     external_warehouse_name, mapping_type, is_active)
VALUES
    (1, 3001, 'JH', 'JH_WH_001', 'JH美西仓', 'PHYSICAL', 1),
    (1, 3002, 'LX', 'LX_WH_001', 'LX美西仓', 'PHYSICAL', 1),
    (1, 3003, 'JH', 'JH_WH_002', 'JH美东仓', 'PHYSICAL', 1),
    (1, 4001, 'FBA', 'FBA_LAX1', 'FBA洛杉矶仓', 'LOGICAL', 1),
    (1, 4002, 'FBA', 'FBA_JFK1', 'FBA纽约仓', 'LOGICAL', 1)
ON DUPLICATE KEY UPDATE update_time = CURRENT_TIMESTAMP;

-- 3. 插入测试区域仓绑定关系
INSERT INTO region_warehouse_binding
    (company_id, region_warehouse_id, warehouse_id, warehouse_code, 
     warehouse_name, binding_type, priority, is_active)
VALUES
    (1, 1001, 3001, 'JH_WH_001', 'JH美西仓', 'STORAGE', 1, 1),
    (1, 1001, 3002, 'LX_WH_001', 'LX美西仓', 'STORAGE', 2, 1),
    (1, 1002, 3003, 'JH_WH_002', 'JH美东仓', 'STORAGE', 1, 1),
    (1, 2001, 4001, 'FBA_LAX1', 'FBA洛杉矶仓', 'STORAGE', 1, 1),
    (1, 2002, 4002, 'FBA_JFK1', 'FBA纽约仓', 'STORAGE', 1, 1)
ON DUPLICATE KEY UPDATE update_time = CURRENT_TIMESTAMP;

-- 4. 插入测试区域订单比例
INSERT INTO region_order_ratio_config
    (company_id, commodity_id, commodity_sku_id, region_warehouse_id, 
     region_code, order_ratio, effective_date, is_active)
VALUES
    (1, NULL, NULL, 1001, 'US_WEST', 0.3000, '2024-01-01', 1),
    (1, NULL, NULL, 1002, 'US_EAST', 0.2500, '2024-01-01', 1),
    (1, NULL, NULL, 2001, 'US_WEST', 0.2500, '2024-01-01', 1),
    (1, NULL, NULL, 2002, 'US_EAST', 0.2000, '2024-01-01', 1)
ON DUPLICATE KEY UPDATE update_time = CURRENT_TIMESTAMP;

-- 5. 插入测试SKU参数数据
INSERT INTO pms_commodity_sku_params
    (company_id, commodity_id, commodity_code, commodity_sku_id, 
     commodity_sku_code, data_date, platform_sale_num, daily_sale_qty, 
     platform_sale_days, remaining_qty, open_intransit_qty, 
     safety_days, shipping_days, production_days)
VALUES
    -- 测试SKU 1: 低库存高风险
    (1, 1001, 'PROD001', 10001, 'SKU001', CURDATE(), 700, 10.0, 70, 50, 30, 15, 30, 15),
    -- 测试SKU 2: 正常库存
    (1, 1001, 'PROD001', 10002, 'SKU002', CURDATE(), 300, 5.0, 60, 500, 200, 15, 30, 15),
    -- 测试SKU 3: 高库存低风险
    (1, 1002, 'PROD002', 10003, 'SKU003', CURDATE(), 150, 2.0, 75, 1000, 500, 15, 30, 15),
    -- 测试SKU 4: 零销量
    (1, 1003, 'PROD003', 10004, 'SKU004', CURDATE(), 0, 0.0, 100, 100, 0, 15, 30, 15)
ON DUPLICATE KEY UPDATE update_time = CURRENT_TIMESTAMP;

-- ===========================================
-- 测试用例执行
-- Test Case Execution
-- ===========================================

-- 测试用例1: 执行SKU区域仓日参数同步
SELECT '测试用例1: 执行SKU区域仓日参数同步' AS test_case;
CALL sp_sync_pms_commodity_sku_region_wh_params_daily(1, CURDATE());

-- 测试用例2: 执行SPU区域仓日参数同步
SELECT '测试用例2: 执行SPU区域仓日参数同步' AS test_case;
CALL sp_sync_pms_commodity_region_wh_params_daily(1, CURDATE());

-- ===========================================
-- 验证查询
-- Validation Queries
-- ===========================================

-- 验证1: 查看生成的SKU快照数据
SELECT '验证1: 查看生成的SKU快照数据（前10条）' AS validation;
SELECT 
    monitor_date,
    business_mode,
    region_warehouse_code,
    warehouse_code,
    commodity_sku_code,
    onhand_qty,
    in_transit_qty,
    total_available_qty,
    region_order_ratio,
    region_daily_sale_qty,
    safety_stock_qty,
    rop_qty,
    gap_qty,
    available_days,
    risk_level
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE()
ORDER BY risk_level, available_days
LIMIT 10;

-- 验证2: 按业务模式统计
SELECT '验证2: 按业务模式统计' AS validation;
SELECT 
    business_mode,
    COUNT(DISTINCT commodity_sku_id) as sku_count,
    COUNT(DISTINCT warehouse_id) as warehouse_count,
    SUM(onhand_qty) as total_onhand,
    SUM(in_transit_qty) as total_in_transit,
    AVG(available_days) as avg_available_days,
    SUM(CASE WHEN risk_level = 'CRITICAL' THEN 1 ELSE 0 END) as critical_count,
    SUM(CASE WHEN risk_level = 'HIGH' THEN 1 ELSE 0 END) as high_count,
    SUM(CASE WHEN risk_level = 'MEDIUM' THEN 1 ELSE 0 END) as medium_count,
    SUM(CASE WHEN risk_level = 'LOW' THEN 1 ELSE 0 END) as low_count
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE()
GROUP BY business_mode;

-- 验证3: 高风险SKU清单
SELECT '验证3: 高风险SKU清单（CRITICAL & HIGH）' AS validation;
SELECT 
    business_mode,
    region_warehouse_code,
    warehouse_name,
    commodity_sku_code,
    onhand_qty,
    in_transit_qty,
    total_available_qty,
    region_daily_sale_qty,
    available_days,
    oos_date_est,
    gap_qty,
    risk_level
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 
  AND monitor_date = CURDATE()
  AND risk_level IN ('CRITICAL', 'HIGH')
ORDER BY 
    CASE risk_level WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 END,
    available_days ASC;

-- 验证4: 区域仓库存分布
SELECT '验证4: 区域仓库存分布' AS validation;
SELECT 
    region_warehouse_code,
    region_warehouse_name,
    business_mode,
    COUNT(DISTINCT commodity_sku_id) as sku_count,
    SUM(onhand_qty) as total_onhand,
    SUM(in_transit_qty) as total_in_transit,
    SUM(total_available_qty) as total_available,
    SUM(region_daily_sale_qty) as total_daily_sales,
    AVG(available_days) as avg_available_days,
    SUM(gap_qty) as total_gap_qty
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE()
GROUP BY region_warehouse_code, region_warehouse_name, business_mode
ORDER BY business_mode, total_gap_qty DESC;

-- 验证5: 补货需求计算
SELECT '验证5: 补货需求计算（缺口>0）' AS validation;
SELECT 
    business_mode,
    region_warehouse_code,
    warehouse_name,
    commodity_sku_code,
    gap_qty,
    region_daily_sale_qty,
    shipping_days,
    production_days,
    -- 建议订货量 = 缺口 + (运输+生产周期)的销量
    CEIL(gap_qty + region_daily_sale_qty * (shipping_days + production_days)) as recommended_order_qty,
    risk_level,
    oos_date_est
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 
  AND monitor_date = CURDATE()
  AND gap_qty > 0
ORDER BY risk_level, gap_qty DESC
LIMIT 20;

-- 验证6: SPU级别汇总数据
SELECT '验证6: SPU级别汇总数据' AS validation;
SELECT 
    monitor_date,
    business_mode,
    region_warehouse_code,
    warehouse_code,
    commodity_code,
    onhand_qty,
    in_transit_qty,
    total_available_qty,
    region_daily_sale_qty,
    available_days,
    risk_level
FROM pms_commodity_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE()
ORDER BY risk_level, available_days
LIMIT 10;

-- 验证7: FBA vs 区域仓对比
SELECT '验证7: FBA vs 区域仓对比' AS validation;
SELECT 
    business_mode,
    risk_level,
    COUNT(*) as sku_count,
    SUM(gap_qty) as total_gap_qty,
    AVG(available_days) as avg_available_days,
    MIN(available_days) as min_available_days,
    MAX(available_days) as max_available_days
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE()
GROUP BY business_mode, risk_level
ORDER BY business_mode, 
    CASE risk_level 
        WHEN 'CRITICAL' THEN 1 
        WHEN 'HIGH' THEN 2 
        WHEN 'MEDIUM' THEN 3 
        ELSE 4 
    END;

-- 验证8: 数据完整性检查
SELECT '验证8: 数据完整性检查' AS validation;
SELECT 
    'Total SKU records' as check_item,
    COUNT(*) as count
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE()
UNION ALL
SELECT 
    'Records with NULL warehouse_id' as check_item,
    COUNT(*) as count
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE()
  AND warehouse_id IS NULL
UNION ALL
SELECT 
    'Records with negative available_days' as check_item,
    COUNT(*) as count
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE()
  AND available_days < 0
UNION ALL
SELECT 
    'Records with NULL risk_level' as check_item,
    COUNT(*) as count
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE()
  AND risk_level IS NULL;

-- ===========================================
-- 性能测试查询
-- Performance Test Queries
-- ===========================================

-- 性能测试1: 索引使用检查
SELECT '性能测试1: 查询执行计划（检查索引使用）' AS perf_test;
EXPLAIN
SELECT 
    business_mode,
    commodity_sku_code,
    risk_level,
    available_days
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 
  AND monitor_date = CURDATE()
  AND risk_level IN ('CRITICAL', 'HIGH')
  AND warehouse_id = 3001
ORDER BY available_days;

-- 性能测试2: 时间范围查询
SELECT '性能测试2: 7天趋势查询性能' AS perf_test;
SELECT 
    monitor_date,
    COUNT(*) as record_count,
    SUM(CASE WHEN risk_level = 'CRITICAL' THEN 1 ELSE 0 END) as critical_count
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 
  AND monitor_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY monitor_date
ORDER BY monitor_date DESC;

-- ===========================================
-- 清理测试数据（可选）
-- Cleanup Test Data (Optional)
-- ===========================================

-- 注意：执行以下语句会删除测试数据，仅在测试环境使用
-- Note: The following statements will delete test data, use only in test environment

-- 取消注释以下语句来清理测试数据
-- Uncomment the following statements to clean up test data

/*
DELETE FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE();

DELETE FROM pms_commodity_region_warehouse_params
WHERE company_id = 1 AND monitor_date = CURDATE();

DELETE FROM pms_commodity_sku_params
WHERE company_id = 1 AND data_date = CURDATE();

DELETE FROM region_order_ratio_config WHERE company_id = 1;
DELETE FROM region_warehouse_binding WHERE company_id = 1;
DELETE FROM warehouse_mapping WHERE company_id = 1;
DELETE FROM region_warehouse_config WHERE company_id = 1;
*/

SELECT '测试完成 / Test completed' AS status;
