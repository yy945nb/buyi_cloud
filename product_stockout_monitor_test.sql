-- ===========================================
-- 产品断货点监控模型 - 测试与验证脚本
-- Product Stockout Monitoring Model - Test & Validation Script
-- ===========================================

-- 本脚本用于验证产品断货点监控模型的正确性和性能

-- ----------------------------
-- 1. 环境检查 (Environment Check)
-- ----------------------------

-- 1.1 检查必要的表是否存在
SELECT 
  'Table Existence Check' AS test_category,
  CASE 
    WHEN COUNT(*) = 5 THEN 'PASS'
    ELSE 'FAIL'
  END AS test_result,
  CONCAT('Found ', COUNT(*), ' out of 5 required tables') AS details
FROM information_schema.tables 
WHERE table_schema = DATABASE()
  AND table_name IN (
    'amf_jh_company_stock',
    'pms_commodity_sku',
    'cos_oos_monitor_daily',
    'cos_oos_spu_monitor_daily',
    'v_domestic_stock_to_product'
  );

-- 1.2 检查amf_jh_company_stock索引
SELECT 
  'Index Check - amf_jh_company_stock' AS test_category,
  CASE 
    WHEN COUNT(*) >= 3 THEN 'PASS'
    ELSE 'FAIL'
  END AS test_result,
  CONCAT('Found ', COUNT(*), ' indexes (expected: 3+)') AS details
FROM information_schema.statistics
WHERE table_schema = DATABASE()
  AND table_name = 'amf_jh_company_stock'
  AND index_name IN ('idx_sync_date', 'idx_local_sku', 'idx_sync_date_local_sku');

-- 1.3 检查存储过程是否存在
SELECT 
  'Stored Procedure Check' AS test_category,
  CASE 
    WHEN COUNT(*) = 1 THEN 'PASS'
    ELSE 'FAIL'
  END AS test_result,
  CONCAT('Found ', COUNT(*), ' stored procedures') AS details
FROM information_schema.routines
WHERE routine_schema = DATABASE()
  AND routine_name = 'sp_calculate_spu_stockout_snapshot';

-- ----------------------------
-- 2. 数据质量检查 (Data Quality Check)
-- ----------------------------

-- 2.1 检查amf_jh_company_stock数据
SELECT 
  'Data Check - amf_jh_company_stock' AS test_category,
  CASE 
    WHEN COUNT(*) > 0 THEN 'PASS'
    ELSE 'FAIL'
  END AS test_result,
  CONCAT(
    'Records: ', COUNT(*), 
    ', Latest sync_date: ', COALESCE(MAX(sync_date), 'NULL'),
    ', Distinct SKUs: ', COUNT(DISTINCT local_sku)
  ) AS details
FROM amf_jh_company_stock;

-- 2.2 检查local_sku映射覆盖率
SELECT 
  'Mapping Coverage Check' AS test_category,
  CASE 
    WHEN mapped_rate >= 0.8 THEN 'PASS'
    WHEN mapped_rate >= 0.5 THEN 'WARNING'
    ELSE 'FAIL'
  END AS test_result,
  CONCAT(
    'Total SKUs: ', total_skus,
    ', Mapped: ', mapped_skus,
    ', Coverage: ', ROUND(mapped_rate * 100, 2), '%'
  ) AS details
FROM (
  SELECT 
    COUNT(DISTINCT s.local_sku) AS total_skus,
    COUNT(DISTINCT CASE WHEN ps.commodity_id IS NOT NULL THEN s.local_sku END) AS mapped_skus,
    COUNT(DISTINCT CASE WHEN ps.commodity_id IS NOT NULL THEN s.local_sku END) / 
      NULLIF(COUNT(DISTINCT s.local_sku), 0) AS mapped_rate
  FROM amf_jh_company_stock s
  LEFT JOIN pms_commodity_sku ps ON (
    s.local_sku = ps.custom_code OR s.local_sku = ps.commodity_sku_code
  )
  WHERE ps.use_status = 0 AND ps.sale_status = 0
) t;

-- ----------------------------
-- 3. 功能测试 (Functional Tests)
-- ----------------------------

-- 3.1 测试视图v_domestic_stock_to_product
SELECT 
  'View Test - v_domestic_stock_to_product' AS test_category,
  CASE 
    WHEN COUNT(*) > 0 THEN 'PASS'
    ELSE 'FAIL'
  END AS test_result,
  CONCAT(
    'Records: ', COUNT(*),
    ', Products: ', COUNT(DISTINCT commodity_id),
    ', Latest sync_date: ', MAX(sync_date)
  ) AS details
FROM v_domestic_stock_to_product
WHERE commodity_id IS NOT NULL;

-- 3.2 测试存储过程执行（不实际插入数据，仅验证语法）
-- 注意：以下为测试示例，实际执行时请取消注释
/*
CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);

SELECT 
  'Stored Procedure Execution' AS test_category,
  'PASS' AS test_result,
  CONCAT(
    'Records created: ', COUNT(*),
    ' for date: ', CURDATE()
  ) AS details
FROM cos_oos_spu_monitor_daily
WHERE monitor_date = CURDATE()
  AND deleted = 0;
*/

-- ----------------------------
-- 4. 聚合准确性验证 (Aggregation Accuracy Validation)
-- ----------------------------

-- 4.1 验证国内仓库存聚合准确性
-- 对比原始数据汇总与快照表数据
SELECT 
  '聚合准确性验证' AS validation_type,
  v.commodity_id,
  v.commodity_code,
  COUNT(DISTINCT v.local_sku) AS local_sku_count,
  SUM(v.remaining_num) AS calc_remaining,
  SUM(v.stock_num) AS calc_stock,
  s.domestic_remaining_qty AS snapshot_remaining,
  s.domestic_actual_stock_qty AS snapshot_stock,
  CASE 
    WHEN ABS(SUM(v.remaining_num) - s.domestic_remaining_qty) <= 1 
     AND ABS(SUM(v.stock_num) - s.domestic_actual_stock_qty) <= 1 
    THEN 'PASS'
    ELSE 'FAIL'
  END AS accuracy_check,
  SUM(v.remaining_num) - s.domestic_remaining_qty AS remaining_diff,
  SUM(v.stock_num) - s.domestic_actual_stock_qty AS stock_diff
FROM v_domestic_stock_to_product v
JOIN cos_oos_spu_monitor_daily s ON (
  v.commodity_id = s.commodity_id 
  AND s.monitor_date = (SELECT MAX(monitor_date) FROM cos_oos_spu_monitor_daily)
  AND s.deleted = 0
)
WHERE v.sync_date = (
  SELECT MAX(sync_date) 
  FROM amf_jh_company_stock 
  WHERE sync_date <= (SELECT MAX(monitor_date) FROM cos_oos_spu_monitor_daily)
)
GROUP BY 
  v.commodity_id, 
  v.commodity_code, 
  s.domestic_remaining_qty, 
  s.domestic_actual_stock_qty
LIMIT 100;

-- ----------------------------
-- 5. 幂等性测试 (Idempotency Test)
-- ----------------------------

-- 5.1 幂等性测试说明
/*
幂等性测试步骤：
1. 执行存储过程第一次
   CALL sp_calculate_spu_stockout_snapshot('2024-01-15', NULL);

2. 记录第一次结果
   SELECT * FROM cos_oos_spu_monitor_daily 
   WHERE monitor_date = '2024-01-15' AND deleted = 0
   INTO OUTFILE '/tmp/first_run.csv';

3. 执行存储过程第二次（相同参数）
   CALL sp_calculate_spu_stockout_snapshot('2024-01-15', NULL);

4. 记录第二次结果
   SELECT * FROM cos_oos_spu_monitor_daily 
   WHERE monitor_date = '2024-01-15' AND deleted = 0
   INTO OUTFILE '/tmp/second_run.csv';

5. 对比两次结果
   diff /tmp/first_run.csv /tmp/second_run.csv
   
预期结果：
- 两次结果应该完全相同（除了update_time字段）
- 记录数量相同
- 所有字段值相同
*/

-- 5.2 验证唯一键约束
SELECT 
  'Unique Key Constraint Test' AS test_category,
  CASE 
    WHEN COUNT(*) = COUNT(DISTINCT CONCAT(company_id, '-', commodity_id, '-', monitor_date, '-', deleted))
    THEN 'PASS'
    ELSE 'FAIL'
  END AS test_result,
  CONCAT(
    'Total records: ', COUNT(*),
    ', Unique combinations: ', COUNT(DISTINCT CONCAT(company_id, '-', commodity_id, '-', monitor_date, '-', deleted))
  ) AS details
FROM cos_oos_spu_monitor_daily;

-- ----------------------------
-- 6. 性能测试 (Performance Test)
-- ----------------------------

-- 6.1 测试存储过程执行时间
/*
SET @start_time = NOW();
CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);
SET @end_time = NOW();

SELECT 
  'Performance Test - Execution Time' AS test_category,
  CASE 
    WHEN TIMESTAMPDIFF(SECOND, @start_time, @end_time) <= 60 THEN 'PASS'
    WHEN TIMESTAMPDIFF(SECOND, @start_time, @end_time) <= 300 THEN 'WARNING'
    ELSE 'FAIL'
  END AS test_result,
  CONCAT(
    'Execution time: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds'
  ) AS details;
*/

-- 6.2 索引使用情况分析
EXPLAIN 
SELECT 
  s.local_sku,
  ps.commodity_id,
  SUM(s.remaining_num) AS total_remaining,
  SUM(s.stock_num) AS total_stock
FROM amf_jh_company_stock s
LEFT JOIN pms_commodity_sku ps ON (
  s.local_sku = ps.custom_code OR s.local_sku = ps.commodity_sku_code
)
WHERE s.sync_date = (SELECT MAX(sync_date) FROM amf_jh_company_stock)
  AND ps.use_status = 0
  AND ps.sale_status = 0
GROUP BY s.local_sku, ps.commodity_id;

-- ----------------------------
-- 7. 边界条件测试 (Edge Case Tests)
-- ----------------------------

-- 7.1 测试空数据处理
-- 验证当没有国内仓库存数据时的处理
/*
-- 备份数据
CREATE TEMPORARY TABLE temp_stock_backup AS 
SELECT * FROM amf_jh_company_stock;

-- 清空数据
DELETE FROM amf_jh_company_stock;

-- 执行存储过程（应该返回错误）
CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);
-- 预期：抛出异常 "没有找到国内仓库存数据（amf_jh_company_stock）"

-- 恢复数据
INSERT INTO amf_jh_company_stock SELECT * FROM temp_stock_backup;
DROP TEMPORARY TABLE temp_stock_backup;
*/

-- 7.2 测试未映射的SKU处理
SELECT 
  'Unmapped SKU Handling' AS test_category,
  COUNT(DISTINCT s.local_sku) AS unmapped_skus,
  SUM(s.remaining_num) AS total_remaining,
  SUM(s.stock_num) AS total_stock,
  CASE 
    WHEN COUNT(DISTINCT s.local_sku) = 0 THEN 'PASS - No unmapped SKUs'
    ELSE CONCAT('INFO - ', COUNT(DISTINCT s.local_sku), ' SKUs not mapped')
  END AS result
FROM amf_jh_company_stock s
LEFT JOIN pms_commodity_sku ps ON (
  s.local_sku = ps.custom_code OR s.local_sku = ps.commodity_sku_code
)
WHERE ps.commodity_id IS NULL
  AND s.sync_date = (SELECT MAX(sync_date) FROM amf_jh_company_stock);

-- ----------------------------
-- 8. 综合报告 (Summary Report)
-- ----------------------------

-- 8.1 最新快照数据统计
SELECT 
  '数据统计报告' AS report_type,
  monitor_date,
  COUNT(*) AS total_products,
  SUM(domestic_remaining_qty) AS total_remaining_qty,
  SUM(domestic_actual_stock_qty) AS total_actual_stock,
  SUM(platform_total_onhand) AS total_platform_stock,
  AVG(doc_days) AS avg_coverage_days,
  SUM(CASE WHEN risk_level = 0 THEN 1 ELSE 0 END) AS normal_count,
  SUM(CASE WHEN risk_level = 1 THEN 1 ELSE 0 END) AS safe_count,
  SUM(CASE WHEN risk_level = 2 THEN 1 ELSE 0 END) AS need_produce_count,
  SUM(CASE WHEN risk_level = 3 THEN 1 ELSE 0 END) AS urgent_count,
  SUM(CASE WHEN risk_level = 4 THEN 1 ELSE 0 END) AS stockout_count
FROM cos_oos_spu_monitor_daily
WHERE monitor_date = (SELECT MAX(monitor_date) FROM cos_oos_spu_monitor_daily)
  AND deleted = 0
GROUP BY monitor_date;

-- 8.2 数据质量指标
SELECT 
  '数据质量指标' AS report_type,
  COUNT(*) AS total_records,
  COUNT(CASE WHEN domestic_remaining_qty > 0 THEN 1 END) AS has_remaining_qty,
  COUNT(CASE WHEN domestic_actual_stock_qty > 0 THEN 1 END) AS has_actual_stock,
  COUNT(CASE WHEN platform_total_onhand > 0 THEN 1 END) AS has_platform_stock,
  COUNT(CASE WHEN weighted_daily_demand > 0 THEN 1 END) AS has_demand,
  COUNT(CASE WHEN doc_days IS NOT NULL THEN 1 END) AS has_coverage_days,
  ROUND(AVG(active_sku_count), 2) AS avg_sku_per_product
FROM cos_oos_spu_monitor_daily
WHERE monitor_date = (SELECT MAX(monitor_date) FROM cos_oos_spu_monitor_daily)
  AND deleted = 0;

-- ----------------------------
-- 9. 测试结论与建议 (Test Conclusion & Recommendations)
-- ----------------------------

/*
测试结论标准：

1. 环境检查 (Environment Check)
   - 所有必要的表、索引、存储过程都应该存在
   - 状态：PASS/FAIL

2. 数据质量 (Data Quality)
   - amf_jh_company_stock有数据且sync_date不为空
   - local_sku映射覆盖率 >= 80% (PASS), >= 50% (WARNING), < 50% (FAIL)

3. 功能测试 (Functional Tests)
   - 视图v_domestic_stock_to_product可以正常查询
   - 存储过程可以成功执行
   - 快照表有正确的数据

4. 准确性验证 (Accuracy Validation)
   - 聚合数据与原始数据差异 <= 1（允许浮点误差）

5. 幂等性测试 (Idempotency Test)
   - 多次执行相同参数的存储过程，结果一致
   - 没有重复记录

6. 性能测试 (Performance Test)
   - 存储过程执行时间 <= 60秒 (PASS), <= 300秒 (WARNING), > 300秒 (FAIL)
   - 索引被正确使用（EXPLAIN结果显示使用索引）

推荐操作：
1. 定期执行本测试脚本验证数据质量
2. 在生产环境部署前，完成所有测试用例
3. 设置监控告警，当测试失败时及时通知
4. 定期清理历史快照数据（建议保留90天）

*/

-- 最后输出测试完成消息
SELECT '========================================' AS message
UNION ALL SELECT '产品断货点监控模型测试脚本执行完成'
UNION ALL SELECT '请查看上述各项测试结果'
UNION ALL SELECT '========================================';