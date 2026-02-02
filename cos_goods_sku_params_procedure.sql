-- ============================================================================
-- Stored Procedure: sp_sync_cos_goods_sku_params_daily
-- Purpose: 同步 cos_goods_sku 数据到 cos_goods_sku_params 表，用于参数快照
-- 
-- 问题修复说明：
-- 1. 避免使用 MIN(k.id) + GROUP BY 导致 sku_id/spu_id 不匹配问题
-- 2. 使用窗口函数 ROW_NUMBER() 按优先级选择唯一记录
-- 3. 确保 sku_id 和 spu_id 来自同一行 cos_goods_sku 记录
-- 4. 处理软删除和重复 sku_code 场景
-- 
-- 选择策略：
-- - 优先选择未删除的记录 (is_delete = 0)
-- - 按同步时间降序 (sync_date DESC)
-- - 按创建时间降序 (create_time DESC)
-- - 按 ID 降序 (id DESC) - 确保选择最新记录
-- ============================================================================

-- ----------------------------
-- Table structure for cos_goods_sku_params
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_sku_params`;
CREATE TABLE `cos_goods_sku_params` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` bigint DEFAULT NULL COMMENT '公司ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `logic_shop_id` bigint DEFAULT NULL COMMENT '逻辑店铺ID',
  `logic_warehouse_id` bigint DEFAULT NULL COMMENT '逻辑仓库ID',
  `spu_id` bigint DEFAULT NULL COMMENT 'SPU ID - 必须与 sku_id 对应的 cos_goods_sku.spu_id 一致',
  `spu_code` varchar(128) DEFAULT NULL COMMENT 'SPU编码',
  `skc_id` bigint DEFAULT NULL COMMENT 'SKC ID',
  `sku_id` bigint DEFAULT NULL COMMENT 'SKU ID - 对应 cos_goods_sku.id',
  `sku_code` varchar(128) DEFAULT NULL COMMENT 'SKU编码',
  `sku_name` varchar(255) DEFAULT NULL COMMENT 'SKU名称',
  `supplier_sku_code` varchar(128) DEFAULT NULL COMMENT '供应商SKU编码',
  `sale_price` decimal(10,2) DEFAULT NULL COMMENT '销售价格',
  `color_size` varchar(128) DEFAULT NULL COMMENT '颜色尺码',
  `onsale_status` int DEFAULT NULL COMMENT '上架状态：[1:是、0:否]',
  `onsale_date` date DEFAULT NULL COMMENT '上架时间',
  `produce_days` int DEFAULT '30' COMMENT '生产周期(天)',
  `goods_level` varchar(64) DEFAULT NULL COMMENT '商品等级',
  `monitor_date` date NOT NULL COMMENT '监控日期',
  `sync_date` datetime DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sku_monitor` (`company_id`, `shop_id`, `sku_id`, `monitor_date`, `deleted`),
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_code` (`sku_code`) USING BTREE,
  KEY `idx_monitor_date` (`monitor_date`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品SKU参数快照表';

-- ----------------------------
-- Stored Procedure: sp_sync_cos_goods_sku_params_daily
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_sync_cos_goods_sku_params_daily`;

DELIMITER $$

CREATE PROCEDURE `sp_sync_cos_goods_sku_params_daily`(
    IN p_monitor_date DATE
)
BEGIN
    /*
     * 功能：将 cos_goods_sku 数据同步到 cos_goods_sku_params 表作为每日快照
     * 
     * 参数：
     *   p_monitor_date: 监控日期，默认为昨天
     * 
     * 核心逻辑：
     *   1. 使用 ROW_NUMBER() 窗口函数按优先级为每个 (company_id, shop_id, sku_code) 选择唯一记录
     *   2. 优先级：is_delete=0 > sync_date DESC > create_time DESC > id DESC
     *   3. 确保 sku_id 和 spu_id 来自同一行，避免聚合导致的不一致
     *   4. 使用 REPLACE INTO 实现幂等性
     * 
     * 修复说明：
     *   - 不使用 MIN(k.id) + GROUP BY，避免选错行
     *   - 不单独 JOIN cos_goods_spu 表覆盖 spu_id，保持数据来源一致性
     *   - 明确记录选择规则，处理软删除和历史数据
     */
    
    -- 设置默认监控日期为昨天
    IF p_monitor_date IS NULL THEN
        SET p_monitor_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY);
    END IF;
    
    -- 同步数据到 cos_goods_sku_params
    REPLACE INTO cos_goods_sku_params (
        company_id,
        shop_id,
        logic_shop_id,
        logic_warehouse_id,
        spu_id,
        spu_code,
        skc_id,
        sku_id,
        sku_code,
        sku_name,
        supplier_sku_code,
        sale_price,
        color_size,
        onsale_status,
        onsale_date,
        produce_days,
        goods_level,
        monitor_date,
        sync_date,
        deleted
    )
    SELECT 
        base.company_id,
        base.shop_id,
        base.logic_shop_id,
        base.logic_warehouse_id,
        base.spu_id,                    -- 直接从 cos_goods_sku 取 spu_id
        spu.spu_code,                   -- 从 cos_goods_spu 补充 spu_code
        base.skc_id,
        base.sku_id,                    -- 使用 cos_goods_sku.id 作为 sku_id
        base.sku_code,
        base.sku_name,
        base.supplier_sku_code,
        base.sale_price,
        base.color_size,
        base.onsale_status,
        base.onsale_date,
        base.produce_days,
        base.goods_level,
        p_monitor_date AS monitor_date,
        NOW() AS sync_date,
        base.is_delete AS deleted
    FROM (
        -- 子查询：使用窗口函数为每个唯一键选择最优记录
        SELECT 
            k.id AS sku_id,             -- cos_goods_sku.id 作为 sku_id
            k.company_id,
            k.shop_id,
            k.logic_shop_id,
            k.logic_warehouse_id,
            k.spu_id,                   -- 直接从 cos_goods_sku 取 spu_id，确保一致性
            k.skc_id,
            k.sku_code,
            k.sku_name,
            k.supplier_sku_code,
            k.sale_price,
            k.color_size,
            k.onsale_status,
            k.onsale_date,
            k.produce_days,
            k.goods_level,
            k.is_delete,
            -- 使用 ROW_NUMBER 按优先级选择唯一记录
            -- 优先级：未删除 > 最新同步 > 最新创建 > 最大ID
            ROW_NUMBER() OVER (
                PARTITION BY k.company_id, k.shop_id, k.sku_code
                ORDER BY 
                    k.is_delete ASC,           -- 优先选择未删除的记录
                    k.sync_date DESC,          -- 最新同步的记录
                    k.create_time DESC,        -- 最新创建的记录
                    k.id DESC                  -- 最大 ID（最新插入）
            ) AS rn
        FROM cos_goods_sku k
        WHERE k.company_id IS NOT NULL
          AND k.shop_id IS NOT NULL
          AND k.sku_code IS NOT NULL
    ) base
    LEFT JOIN cos_goods_spu spu 
        ON base.spu_id = spu.id           -- 关联 spu 表获取 spu_code，但不改变 spu_id
        AND spu.is_delete = 0
    WHERE base.rn = 1;                    -- 只选择优先级最高的记录
    
    -- 返回同步结果统计
    SELECT 
        p_monitor_date AS monitor_date,
        COUNT(*) AS synced_records,
        NOW() AS sync_time
    FROM cos_goods_sku_params
    WHERE monitor_date = p_monitor_date;
    
END$$

DELIMITER ;

-- ============================================================================
-- 验证查询：检测潜在的数据不一致问题
-- ============================================================================

-- 验证查询 1：检测同一 (company_id, shop_id, sku_code) 对应多个不同 spu_id 的情况
-- 说明：这种情况可能导致 MIN(id) 聚合时选错行
-- 使用方法：定期执行，如果有结果需要人工介入检查数据质量
/*
SELECT 
    company_id,
    shop_id,
    sku_code,
    COUNT(DISTINCT id) AS sku_count,
    COUNT(DISTINCT spu_id) AS spu_count,
    GROUP_CONCAT(DISTINCT id ORDER BY id) AS sku_ids,
    GROUP_CONCAT(DISTINCT spu_id ORDER BY spu_id) AS spu_ids,
    GROUP_CONCAT(DISTINCT is_delete ORDER BY is_delete) AS delete_flags
FROM cos_goods_sku
WHERE company_id IS NOT NULL
  AND shop_id IS NOT NULL
  AND sku_code IS NOT NULL
GROUP BY company_id, shop_id, sku_code
HAVING COUNT(DISTINCT spu_id) > 1
   OR (COUNT(DISTINCT id) > 1 AND SUM(is_delete = 0) > 1)
ORDER BY spu_count DESC, sku_count DESC
LIMIT 100;
*/

-- 验证查询 2：检查 cos_goods_sku_params 中 sku_id/spu_id 与 cos_goods_sku 是否一致
-- 说明：执行存储过程后，应该确保数据一致性
-- 使用方法：执行存储过程后立即运行，如果有结果说明存在不一致
/*
SELECT 
    p.id AS params_id,
    p.company_id,
    p.shop_id,
    p.sku_code,
    p.sku_id AS params_sku_id,
    p.spu_id AS params_spu_id,
    k.id AS actual_sku_id,
    k.spu_id AS actual_spu_id,
    p.monitor_date,
    CASE 
        WHEN k.id IS NULL THEN '主数据不存在'
        WHEN p.sku_id != k.id THEN 'sku_id不匹配'
        WHEN p.spu_id != k.spu_id THEN 'spu_id不匹配'
        ELSE '一致'
    END AS consistency_check
FROM cos_goods_sku_params p
LEFT JOIN cos_goods_sku k ON p.sku_id = k.id
WHERE p.deleted = 0
  AND (k.id IS NULL OR p.sku_id != k.id OR p.spu_id != k.spu_id)
ORDER BY p.monitor_date DESC, p.id DESC
LIMIT 100;
*/

-- 验证查询 3：检查是否存在重复记录（违反唯一键约束）
-- 说明：确保幂等性，同一 (company_id, shop_id, sku_id, monitor_date, deleted) 只有一条记录
/*
SELECT 
    company_id,
    shop_id,
    sku_id,
    monitor_date,
    deleted,
    COUNT(*) AS record_count
FROM cos_goods_sku_params
GROUP BY company_id, shop_id, sku_id, monitor_date, deleted
HAVING COUNT(*) > 1;
*/

-- ============================================================================
-- 使用示例
-- ============================================================================

-- 示例 1：同步昨天的数据（默认）
-- CALL sp_sync_cos_goods_sku_params_daily(NULL);

-- 示例 2：同步指定日期的数据
-- CALL sp_sync_cos_goods_sku_params_daily('2024-01-15');

-- 示例 3：同步今天的数据
-- CALL sp_sync_cos_goods_sku_params_daily(CURDATE());
