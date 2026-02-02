-- ============================================================================
-- 测试和验证脚本：cos_goods_sku_params 存储过程
-- ============================================================================

-- 第一部分：模拟测试数据
-- ============================================================================

-- 创建测试场景 1：同一 sku_code 有多个版本（历史记录）
-- 预期：应该选择最新的未删除记录

-- 场景说明：
-- sku_code='TEST-SKU-001' 有 3 条记录：
-- - id=1: 旧记录，已删除
-- - id=2: 旧记录，未删除，旧的 spu_id=100
-- - id=3: 最新记录，未删除，新的 spu_id=200
-- 预期结果：应该选择 id=3, spu_id=200

/*
INSERT INTO cos_goods_sku (id, company_id, shop_id, spu_id, sku_code, sku_name, is_delete, sync_date, create_time)
VALUES 
    (1, 1001, 2001, 100, 'TEST-SKU-001', '测试商品1-旧版已删', 1, '2024-01-01 10:00:00', '2024-01-01 10:00:00'),
    (2, 1001, 2001, 100, 'TEST-SKU-001', '测试商品1-旧版', 0, '2024-01-02 10:00:00', '2024-01-02 10:00:00'),
    (3, 1001, 2001, 200, 'TEST-SKU-001', '测试商品1-最新版', 0, '2024-01-03 10:00:00', '2024-01-03 10:00:00');
*/

-- 创建测试场景 2：正常单一记录
/*
INSERT INTO cos_goods_sku (id, company_id, shop_id, spu_id, sku_code, sku_name, is_delete, sync_date, create_time)
VALUES 
    (10, 1001, 2001, 300, 'TEST-SKU-002', '测试商品2', 0, '2024-01-03 10:00:00', '2024-01-03 10:00:00');
*/

-- 创建测试场景 3：同一 sku_code 多个未删除记录（数据质量问题）
-- 预期：选择最新同步的记录
/*
INSERT INTO cos_goods_sku (id, company_id, shop_id, spu_id, sku_code, sku_name, is_delete, sync_date, create_time)
VALUES 
    (20, 1001, 2002, 400, 'TEST-SKU-003', '测试商品3-版本1', 0, '2024-01-01 10:00:00', '2024-01-01 10:00:00'),
    (21, 1001, 2002, 500, 'TEST-SKU-003', '测试商品3-版本2', 0, '2024-01-02 10:00:00', '2024-01-02 10:00:00'),
    (22, 1001, 2002, 600, 'TEST-SKU-003', '测试商品3-版本3', 0, '2024-01-03 10:00:00', '2024-01-03 10:00:00');
*/

-- 第二部分：执行存储过程
-- ============================================================================

-- 同步测试日期的数据
CALL sp_sync_cos_goods_sku_params_daily('2024-01-15');

-- 第三部分：验证结果
-- ============================================================================

-- 验证 1：检查选择的记录是否正确
SELECT 
    'Scenario 1: Multiple versions with delete flag' AS test_case,
    p.*,
    CASE 
        WHEN p.sku_id = 3 AND p.spu_id = 200 THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result
FROM cos_goods_sku_params p
WHERE p.sku_code = 'TEST-SKU-001'
  AND p.monitor_date = '2024-01-15'
  AND p.deleted = 0;

SELECT 
    'Scenario 2: Single record' AS test_case,
    p.*,
    CASE 
        WHEN p.sku_id = 10 AND p.spu_id = 300 THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result
FROM cos_goods_sku_params p
WHERE p.sku_code = 'TEST-SKU-002'
  AND p.monitor_date = '2024-01-15'
  AND p.deleted = 0;

SELECT 
    'Scenario 3: Multiple active versions' AS test_case,
    p.*,
    CASE 
        WHEN p.sku_id = 22 AND p.spu_id = 600 THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result
FROM cos_goods_sku_params p
WHERE p.sku_code = 'TEST-SKU-003'
  AND p.monitor_date = '2024-01-15'
  AND p.deleted = 0;

-- 验证 2：检查 sku_id 和 spu_id 的一致性
SELECT 
    'Consistency Check' AS test_case,
    p.sku_code,
    p.sku_id AS params_sku_id,
    p.spu_id AS params_spu_id,
    k.id AS actual_sku_id,
    k.spu_id AS actual_spu_id,
    CASE 
        WHEN p.sku_id = k.id AND p.spu_id = k.spu_id THEN 'PASS'
        WHEN k.id IS NULL THEN 'FAIL - SKU not found'
        WHEN p.sku_id != k.id THEN 'FAIL - sku_id mismatch'
        WHEN p.spu_id != k.spu_id THEN 'FAIL - spu_id mismatch'
        ELSE 'UNKNOWN'
    END AS test_result
FROM cos_goods_sku_params p
LEFT JOIN cos_goods_sku k ON p.sku_id = k.id
WHERE p.monitor_date = '2024-01-15'
  AND p.deleted = 0
  AND p.sku_code LIKE 'TEST-SKU-%';

-- 验证 3：检查是否有重复记录
SELECT 
    'Duplicate Check' AS test_case,
    company_id,
    shop_id,
    sku_id,
    monitor_date,
    deleted,
    COUNT(*) AS record_count,
    CASE 
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL - Duplicate found'
    END AS test_result
FROM cos_goods_sku_params
WHERE monitor_date = '2024-01-15'
  AND sku_code LIKE 'TEST-SKU-%'
GROUP BY company_id, shop_id, sku_id, monitor_date, deleted;

-- 验证 4：测试幂等性（多次执行相同日期）
CALL sp_sync_cos_goods_sku_params_daily('2024-01-15');
CALL sp_sync_cos_goods_sku_params_daily('2024-01-15');

SELECT 
    'Idempotency Check' AS test_case,
    sku_code,
    COUNT(*) AS record_count,
    CASE 
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL - Not idempotent'
    END AS test_result
FROM cos_goods_sku_params
WHERE monitor_date = '2024-01-15'
  AND sku_code LIKE 'TEST-SKU-%'
GROUP BY sku_code;

-- 第四部分：清理测试数据（可选）
-- ============================================================================

/*
-- 删除测试数据
DELETE FROM cos_goods_sku WHERE sku_code LIKE 'TEST-SKU-%';
DELETE FROM cos_goods_sku_params WHERE sku_code LIKE 'TEST-SKU-%';
*/

-- ============================================================================
-- 生产环境验证查询
-- ============================================================================

-- 查询 1：检测潜在问题 - 同一 sku_code 多个 spu_id
SELECT 
    '同一sku_code对应多个spu_id的记录' AS issue_type,
    company_id,
    shop_id,
    sku_code,
    COUNT(DISTINCT id) AS sku_count,
    COUNT(DISTINCT spu_id) AS spu_count,
    GROUP_CONCAT(DISTINCT id ORDER BY id DESC LIMIT 5) AS recent_sku_ids,
    GROUP_CONCAT(DISTINCT spu_id ORDER BY spu_id LIMIT 5) AS spu_ids,
    SUM(is_delete = 0) AS active_records,
    SUM(is_delete = 1) AS deleted_records
FROM cos_goods_sku
WHERE company_id IS NOT NULL
  AND shop_id IS NOT NULL
  AND sku_code IS NOT NULL
GROUP BY company_id, shop_id, sku_code
HAVING COUNT(DISTINCT spu_id) > 1
   OR (COUNT(DISTINCT id) > 1 AND SUM(is_delete = 0) > 1)
ORDER BY spu_count DESC, sku_count DESC
LIMIT 50;

-- 查询 2：验证 cos_goods_sku_params 数据质量
SELECT 
    '参数表与主表不一致的记录' AS issue_type,
    p.id AS params_id,
    p.company_id,
    p.shop_id,
    p.sku_code,
    p.sku_id AS params_sku_id,
    p.spu_id AS params_spu_id,
    k.id AS actual_sku_id,
    k.spu_id AS actual_spu_id,
    k.is_delete,
    p.monitor_date,
    CASE 
        WHEN k.id IS NULL THEN 'SKU记录不存在'
        WHEN p.sku_id != k.id THEN 'sku_id不匹配'
        WHEN p.spu_id IS NOT NULL AND k.spu_id IS NOT NULL AND p.spu_id != k.spu_id THEN 'spu_id不匹配'
        WHEN k.is_delete = 1 THEN '主数据已删除'
        ELSE '其他问题'
    END AS issue_description
FROM cos_goods_sku_params p
LEFT JOIN cos_goods_sku k ON p.sku_id = k.id
WHERE p.deleted = 0
  AND (k.id IS NULL 
       OR p.sku_id != k.id 
       OR (p.spu_id IS NOT NULL AND k.spu_id IS NOT NULL AND p.spu_id != k.spu_id))
ORDER BY p.monitor_date DESC, p.id DESC
LIMIT 100;

-- 查询 3：统计最近同步的数据量
SELECT 
    monitor_date,
    COUNT(*) AS total_records,
    COUNT(DISTINCT company_id) AS company_count,
    COUNT(DISTINCT shop_id) AS shop_count,
    COUNT(DISTINCT sku_id) AS sku_count,
    COUNT(DISTINCT spu_id) AS spu_count,
    SUM(deleted = 0) AS active_records,
    SUM(deleted = 1) AS deleted_records,
    MAX(sync_date) AS last_sync_time
FROM cos_goods_sku_params
WHERE monitor_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY monitor_date
ORDER BY monitor_date DESC;

-- 查询 4：检查唯一键冲突（不应该有结果）
SELECT 
    '唯一键冲突检查' AS issue_type,
    company_id,
    shop_id,
    sku_id,
    monitor_date,
    deleted,
    COUNT(*) AS duplicate_count,
    GROUP_CONCAT(id ORDER BY id) AS record_ids
FROM cos_goods_sku_params
GROUP BY company_id, shop_id, sku_id, monitor_date, deleted
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 50;

-- ============================================================================
-- 性能分析查询
-- ============================================================================

-- 分析窗口函数性能（EXPLAIN）
EXPLAIN 
SELECT 
    k.id AS sku_id,
    k.company_id,
    k.shop_id,
    k.spu_id,
    k.sku_code,
    ROW_NUMBER() OVER (
        PARTITION BY k.company_id, k.shop_id, k.sku_code
        ORDER BY k.is_delete ASC, k.sync_date DESC, k.create_time DESC, k.id DESC
    ) AS rn
FROM cos_goods_sku k
WHERE k.company_id IS NOT NULL
  AND k.shop_id IS NOT NULL
  AND k.sku_code IS NOT NULL;

-- 建议的索引（如果性能不佳）
/*
-- 为窗口函数优化的复合索引
CREATE INDEX idx_sku_window ON cos_goods_sku (
    company_id, shop_id, sku_code, 
    is_delete, sync_date, create_time, id
);

-- 或者分别创建索引
CREATE INDEX idx_sku_composite ON cos_goods_sku (company_id, shop_id, sku_code, is_delete);
CREATE INDEX idx_sync_date ON cos_goods_sku (sync_date);
*/
