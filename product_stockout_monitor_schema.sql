-- ===========================================
-- 基于产品的断货点监控模型 - 数据库架构
-- Product-Based Stockout Monitoring Model - Database Schema
-- ===========================================
-- 
-- 本文件包含产品级别断货点监控模型的数据库表结构和存储过程
-- 用于集成国内仓余单/实物库存数据(amf_jh_company_stock)

-- ----------------------------
-- 1. 产品级别断货点监控快照表 (每日快照)
-- Product-Level Stockout Monitoring Snapshot Table (Daily Snapshot)
-- ----------------------------
DROP TABLE IF EXISTS `cos_oos_spu_monitor_daily`;
CREATE TABLE `cos_oos_spu_monitor_daily` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` BIGINT NOT NULL COMMENT '企业ID',
  `commodity_id` BIGINT NOT NULL COMMENT '产品ID（国内仓SPU）',
  `commodity_code` VARCHAR(128) COMMENT '产品编码',
  `monitor_date` DATE NOT NULL COMMENT '监控日期（快照日期）',
  
  -- 国内仓库存数据（来自amf_jh_company_stock）
  `domestic_remaining_qty` INT NOT NULL DEFAULT 0 COMMENT '国内仓余单数量 = SUM(remaining_num)',
  `domestic_actual_stock_qty` INT NOT NULL DEFAULT 0 COMMENT '国内仓实物库存 = SUM(stock_num)',
  `domestic_stock_sync_date` DATE COMMENT '国内仓库存同步日期（amf_jh_company_stock.sync_date）',
  
  -- 海外仓库存数据（聚合自SKU级别）
  `platform_total_onhand` INT NOT NULL DEFAULT 0 COMMENT '平台可售库存总量（所有SKU汇总）',
  `domestic_available_spu` INT NOT NULL DEFAULT 0 COMMENT '国内仓可用库存（wms_commodity_stock）',
  `open_intransit_qty` INT NOT NULL DEFAULT 0 COMMENT '直补在途未收数量（所有SKU汇总）',
  
  -- 需求与风险指标
  `weighted_daily_demand` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '加权日消耗率（所有SKU汇总）',
  `doc_days` DECIMAL(12,2) COMMENT '覆盖天数 = (platform_total_onhand + domestic_actual_stock_qty) / weighted_daily_demand',
  `oos_date_estimate` DATE COMMENT '预计断货日期',
  
  -- 建议补货量
  `suggest_transfer_qty` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '建议直补量',
  `suggest_produce_qty` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '建议生产量',
  
  -- 风险等级
  `risk_level` TINYINT NOT NULL DEFAULT 0 COMMENT '风险等级：0正常，1安全区，2需要生产，3直补来不及，4已断货',
  `risk_reason` TEXT COMMENT '风险原因说明',
  
  -- SKU数量统计
  `active_sku_count` INT NOT NULL DEFAULT 0 COMMENT '活跃SKU数量',
  `high_risk_sku_count` INT NOT NULL DEFAULT 0 COMMENT '高风险SKU数量',
  
  -- 元数据
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` BIGINT COMMENT '创建人',
  `deleted` BIGINT NOT NULL DEFAULT 0 COMMENT '删除标记：0=未删除，大于0：删除时间戳',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_commodity_date` (`company_id`, `commodity_id`, `monitor_date`, `deleted`),
  KEY `idx_company_date` (`company_id`, `monitor_date`),
  KEY `idx_commodity_date` (`commodity_id`, `monitor_date`),
  KEY `idx_risk_level` (`risk_level`, `monitor_date`),
  KEY `idx_oos_date` (`oos_date_estimate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC 
COMMENT='产品级别断货点监控快照表（日粒度，SPU维度）';

-- ----------------------------
-- 2. 国内仓库存索引优化
-- Optimize amf_jh_company_stock table indexes
-- ----------------------------
-- 为amf_jh_company_stock表添加索引以提升查询性能
ALTER TABLE `amf_jh_company_stock` 
  ADD INDEX IF NOT EXISTS `idx_sync_date` (`sync_date`),
  ADD INDEX IF NOT EXISTS `idx_local_sku` (`local_sku`),
  ADD INDEX IF NOT EXISTS `idx_sync_date_local_sku` (`sync_date`, `local_sku`);

-- ----------------------------
-- 3. local_sku到产品SKU映射视图
-- Local SKU to Product SKU Mapping View
-- ----------------------------
-- 创建映射视图，用于将amf_jh_company_stock.local_sku映射到pms_commodity_sku
DROP VIEW IF EXISTS `v_domestic_stock_to_product`;
CREATE VIEW `v_domestic_stock_to_product` AS
SELECT 
  s.local_sku,
  ps.commodity_id,
  ps.commodity_code,
  ps.commodity_sku_code,
  ps.custom_code,
  ps.company_id,
  s.remaining_num,
  s.stock_num,
  s.sync_date,
  s.order_date,
  s.business,
  s.account,
  s.factory_code
FROM amf_jh_company_stock s
LEFT JOIN pms_commodity_sku ps ON (
  -- 映射规则：local_sku匹配custom_code或commodity_sku_code
  s.local_sku = ps.custom_code 
  OR s.local_sku = ps.commodity_sku_code
)
WHERE ps.use_status = 0  -- 未删除的SKU
  AND ps.sale_status = 0  -- 在售状态
  AND s.sync_date IS NOT NULL;

-- ----------------------------
-- 4. 存储过程：计算产品级别断货点监控快照
-- Stored Procedure: Calculate Product-Level Stockout Monitoring Snapshot
-- ----------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_calculate_spu_stockout_snapshot`$$

CREATE PROCEDURE `sp_calculate_spu_stockout_snapshot`(
  IN p_monitor_date DATE,
  IN p_company_id BIGINT
)
BEGIN
  /*
   * 功能说明：
   * 计算指定日期的产品级别断货点监控快照
   * 
   * 参数：
   *   p_monitor_date - 监控日期，如果为NULL则使用当前日期
   *   p_company_id   - 企业ID，如果为NULL则处理所有企业
   * 
   * 实现逻辑：
   * 1. 从amf_jh_company_stock获取最近的sync_date数据
   * 2. 按local_sku聚合remaining_num和stock_num
   * 3. 通过v_domestic_stock_to_product映射到产品
   * 4. 聚合SKU级别的断货监控数据到产品级别
   * 5. 计算风险等级和建议补货量
   * 
   * 幂等性：使用INSERT ... ON DUPLICATE KEY UPDATE确保可重复执行
   */
  
  DECLARE v_monitor_date DATE;
  DECLARE v_latest_sync_date DATE;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    -- 错误处理：回滚事务
    ROLLBACK;
    RESIGNAL;
  END;
  
  -- 设置默认值
  SET v_monitor_date = IFNULL(p_monitor_date, CURDATE());
  
  -- 查找最近的sync_date（不晚于monitor_date）
  SELECT MAX(sync_date) INTO v_latest_sync_date
  FROM amf_jh_company_stock
  WHERE sync_date <= v_monitor_date;
  
  -- 如果没有找到数据，退出
  IF v_latest_sync_date IS NULL THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = '没有找到国内仓库存数据（amf_jh_company_stock）';
  END IF;
  
  -- 开启事务
  START TRANSACTION;
  
  -- 插入或更新产品级别快照数据
  INSERT INTO cos_oos_spu_monitor_daily (
    company_id,
    commodity_id,
    commodity_code,
    monitor_date,
    domestic_remaining_qty,
    domestic_actual_stock_qty,
    domestic_stock_sync_date,
    platform_total_onhand,
    domestic_available_spu,
    open_intransit_qty,
    weighted_daily_demand,
    doc_days,
    oos_date_estimate,
    suggest_transfer_qty,
    suggest_produce_qty,
    risk_level,
    risk_reason,
    active_sku_count,
    high_risk_sku_count,
    create_by,
    deleted
  )
  SELECT 
    -- 基础信息
    COALESCE(v.company_id, p_company_id, 0) AS company_id,
    v.commodity_id,
    v.commodity_code,
    v_monitor_date AS monitor_date,
    
    -- 国内仓库存（从amf_jh_company_stock聚合）
    COALESCE(SUM(v.remaining_num), 0) AS domestic_remaining_qty,
    COALESCE(SUM(v.stock_num), 0) AS domestic_actual_stock_qty,
    v_latest_sync_date AS domestic_stock_sync_date,
    
    -- 海外仓库存（从SKU级别汇总）
    COALESCE(SUM(sku.platform_onhand), 0) AS platform_total_onhand,
    COALESCE(MAX(sku.domestic_available_spu), 0) AS domestic_available_spu,
    COALESCE(SUM(sku.open_intransit_qty), 0) AS open_intransit_qty,
    
    -- 需求指标
    COALESCE(SUM(sku.daily_demand), 0) AS weighted_daily_demand,
    
    -- 覆盖天数计算
    CASE 
      WHEN COALESCE(SUM(sku.daily_demand), 0) > 0 THEN
        (COALESCE(SUM(sku.platform_onhand), 0) + COALESCE(SUM(v.stock_num), 0)) / SUM(sku.daily_demand)
      ELSE NULL
    END AS doc_days,
    
    -- 预计断货日期
    CASE 
      WHEN COALESCE(SUM(sku.daily_demand), 0) > 0 THEN
        DATE_ADD(v_monitor_date, INTERVAL FLOOR(
          (COALESCE(SUM(sku.platform_onhand), 0) + COALESCE(SUM(v.stock_num), 0)) / SUM(sku.daily_demand)
        ) DAY)
      ELSE NULL
    END AS oos_date_estimate,
    
    -- 建议补货量（从SKU级别汇总）
    COALESCE(SUM(sku.suggest_transfer_final), 0) AS suggest_transfer_qty,
    COALESCE(SUM(sku.suggest_produce), 0) AS suggest_produce_qty,
    
    -- 风险等级（取最高风险）
    COALESCE(MAX(sku.risk_level), 0) AS risk_level,
    
    -- 风险原因
    CASE 
      WHEN MAX(sku.risk_level) >= 4 THEN '已断货'
      WHEN MAX(sku.risk_level) = 3 THEN '直补来不及'
      WHEN MAX(sku.risk_level) = 2 THEN '需要生产'
      WHEN MAX(sku.risk_level) = 1 THEN '安全区'
      ELSE '正常'
    END AS risk_reason,
    
    -- SKU统计
    COUNT(DISTINCT sku.sku_id) AS active_sku_count,
    SUM(CASE WHEN sku.risk_level >= 3 THEN 1 ELSE 0 END) AS high_risk_sku_count,
    
    -- 元数据
    NULL AS create_by,
    0 AS deleted
    
  FROM v_domestic_stock_to_product v
  LEFT JOIN cos_oos_monitor_daily sku ON (
    v.commodity_id = sku.commodity_id
    AND sku.monitor_date = v_monitor_date
    AND sku.deleted = 0
  )
  WHERE v.sync_date = v_latest_sync_date
    AND (p_company_id IS NULL OR v.company_id = p_company_id)
    AND v.commodity_id IS NOT NULL
  GROUP BY 
    v.company_id,
    v.commodity_id,
    v.commodity_code
  
  -- 幂等性：如果记录已存在则更新
  ON DUPLICATE KEY UPDATE
    domestic_remaining_qty = VALUES(domestic_remaining_qty),
    domestic_actual_stock_qty = VALUES(domestic_actual_stock_qty),
    domestic_stock_sync_date = VALUES(domestic_stock_sync_date),
    platform_total_onhand = VALUES(platform_total_onhand),
    domestic_available_spu = VALUES(domestic_available_spu),
    open_intransit_qty = VALUES(open_intransit_qty),
    weighted_daily_demand = VALUES(weighted_daily_demand),
    doc_days = VALUES(doc_days),
    oos_date_estimate = VALUES(oos_date_estimate),
    suggest_transfer_qty = VALUES(suggest_transfer_qty),
    suggest_produce_qty = VALUES(suggest_produce_qty),
    risk_level = VALUES(risk_level),
    risk_reason = VALUES(risk_reason),
    active_sku_count = VALUES(active_sku_count),
    high_risk_sku_count = VALUES(high_risk_sku_count),
    update_time = CURRENT_TIMESTAMP;
  
  -- 提交事务
  COMMIT;
  
  -- 返回处理结果
  SELECT 
    v_monitor_date AS monitor_date,
    v_latest_sync_date AS sync_date_used,
    COUNT(*) AS records_processed,
    SUM(CASE WHEN risk_level >= 3 THEN 1 ELSE 0 END) AS high_risk_count
  FROM cos_oos_spu_monitor_daily
  WHERE monitor_date = v_monitor_date
    AND deleted = 0
    AND (p_company_id IS NULL OR company_id = p_company_id);
    
END$$

DELIMITER ;

-- ----------------------------
-- 5. 校验SQL查询
-- Validation SQL Queries
-- ----------------------------

-- 查询示例1：查看指定日期的产品级别断货监控数据
-- SELECT * FROM cos_oos_spu_monitor_daily 
-- WHERE monitor_date = '2024-01-01' 
-- AND deleted = 0
-- ORDER BY risk_level DESC, weighted_daily_demand DESC;

-- 查询示例2：查看高风险产品
-- SELECT 
--   commodity_id,
--   commodity_code,
--   monitor_date,
--   domestic_actual_stock_qty,
--   platform_total_onhand,
--   weighted_daily_demand,
--   doc_days,
--   oos_date_estimate,
--   risk_level,
--   risk_reason
-- FROM cos_oos_spu_monitor_daily
-- WHERE monitor_date = CURDATE()
-- AND risk_level >= 3
-- AND deleted = 0
-- ORDER BY risk_level DESC, doc_days ASC;

-- 查询示例3：验证国内仓库存数据聚合准确性
-- SELECT 
--   v.commodity_id,
--   v.commodity_code,
--   COUNT(*) AS local_sku_count,
--   SUM(v.remaining_num) AS total_remaining,
--   SUM(v.stock_num) AS total_stock,
--   s.domestic_remaining_qty,
--   s.domestic_actual_stock_qty,
--   s.monitor_date
-- FROM v_domestic_stock_to_product v
-- JOIN cos_oos_spu_monitor_daily s ON (
--   v.commodity_id = s.commodity_id 
--   AND s.monitor_date = CURDATE()
-- )
-- WHERE v.sync_date = (SELECT MAX(sync_date) FROM amf_jh_company_stock WHERE sync_date <= CURDATE())
-- GROUP BY v.commodity_id, v.commodity_code, s.domestic_remaining_qty, s.domestic_actual_stock_qty, s.monitor_date;

-- ----------------------------
-- 6. 使用说明
-- Usage Instructions
-- ----------------------------

/*
存储过程调用示例：

1. 计算今天的快照（所有企业）：
   CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);

2. 计算指定日期的快照（所有企业）：
   CALL sp_calculate_spu_stockout_snapshot('2024-01-01', NULL);

3. 计算指定企业的快照：
   CALL sp_calculate_spu_stockout_snapshot(CURDATE(), 123);

4. 重新计算已存在的快照（幂等性）：
   CALL sp_calculate_spu_stockout_snapshot('2024-01-01', NULL);
   -- 多次执行结果一致

索引使用说明：
- idx_sync_date: 快速定位最新的sync_date
- idx_local_sku: 快速查找特定SKU的库存
- idx_sync_date_local_sku: 组合索引，优化聚合查询性能

性能优化建议：
1. 定期清理历史快照数据（保留90天或更长）
2. 使用批量处理：每天凌晨统一执行快照计算
3. 监控存储过程执行时间，必要时添加分区表
4. 考虑为大表添加分区：按monitor_date月度分区
*/
