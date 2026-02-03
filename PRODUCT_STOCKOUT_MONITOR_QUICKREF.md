# 产品断货点监控模型 - 快速参考
# Product Stockout Monitoring Model - Quick Reference

## 快速开始 / Quick Start

### 1. 安装部署
```sql
-- 导入产品断货点监控模型架构
mysql -u username -p database < product_stockout_monitor_schema.sql
```

### 2. 执行快照计算
```sql
-- 计算今天的快照
CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);

-- 计算指定日期的快照
CALL sp_calculate_spu_stockout_snapshot('2024-01-15', NULL);
```

### 3. 查询高风险产品
```sql
SELECT 
  commodity_id,
  commodity_code,
  domestic_actual_stock_qty,
  platform_total_onhand,
  doc_days,
  oos_date_estimate,
  risk_level,
  risk_reason
FROM cos_oos_spu_monitor_daily
WHERE monitor_date = CURDATE()
  AND risk_level >= 3
  AND deleted = 0
ORDER BY doc_days ASC;
```

## 常用SQL查询 / Common SQL Queries

### 查询产品库存概况
```sql
SELECT 
  commodity_id,
  commodity_code,
  monitor_date,
  -- 国内仓库存
  domestic_remaining_qty AS '余单数量',
  domestic_actual_stock_qty AS '实物库存',
  -- 海外仓库存
  platform_total_onhand AS '平台可售',
  -- 需求指标
  weighted_daily_demand AS '日均消耗',
  doc_days AS '覆盖天数',
  oos_date_estimate AS '预计断货日',
  -- 风险等级
  risk_level,
  risk_reason
FROM cos_oos_spu_monitor_daily
WHERE monitor_date = CURDATE()
  AND deleted = 0
ORDER BY risk_level DESC, doc_days ASC
LIMIT 50;
```

### 按风险等级统计
```sql
SELECT 
  risk_level,
  CASE risk_level
    WHEN 0 THEN '正常'
    WHEN 1 THEN '安全区'
    WHEN 2 THEN '需要生产'
    WHEN 3 THEN '直补来不及'
    WHEN 4 THEN '已断货'
  END AS risk_name,
  COUNT(*) AS product_count,
  SUM(domestic_actual_stock_qty) AS total_domestic_stock,
  SUM(platform_total_onhand) AS total_platform_stock,
  AVG(doc_days) AS avg_coverage_days
FROM cos_oos_spu_monitor_daily
WHERE monitor_date = CURDATE()
  AND deleted = 0
GROUP BY risk_level
ORDER BY risk_level DESC;
```

### 查询需要补货的产品
```sql
SELECT 
  commodity_id,
  commodity_code,
  suggest_transfer_qty AS '建议直补量',
  suggest_produce_qty AS '建议生产量',
  domestic_actual_stock_qty AS '国内仓库存',
  platform_total_onhand AS '平台库存',
  weighted_daily_demand AS '日均消耗',
  doc_days AS '剩余天数',
  risk_reason
FROM cos_oos_spu_monitor_daily
WHERE monitor_date = CURDATE()
  AND (suggest_transfer_qty > 0 OR suggest_produce_qty > 0)
  AND deleted = 0
ORDER BY risk_level DESC, doc_days ASC;
```

### 历史趋势查询（过去7天）
```sql
SELECT 
  monitor_date,
  COUNT(*) AS total_products,
  SUM(CASE WHEN risk_level >= 3 THEN 1 ELSE 0 END) AS high_risk_count,
  AVG(domestic_actual_stock_qty) AS avg_domestic_stock,
  AVG(platform_total_onhand) AS avg_platform_stock,
  AVG(doc_days) AS avg_coverage_days
FROM cos_oos_spu_monitor_daily
WHERE monitor_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
  AND deleted = 0
GROUP BY monitor_date
ORDER BY monitor_date DESC;
```

### 验证国内仓库存映射
```sql
-- 查看未映射的local_sku
SELECT DISTINCT 
  s.local_sku,
  SUM(s.remaining_num) AS total_remaining,
  SUM(s.stock_num) AS total_stock,
  s.sync_date
FROM amf_jh_company_stock s
LEFT JOIN pms_commodity_sku ps ON (
  s.local_sku = ps.custom_code OR s.local_sku = ps.commodity_sku_code
)
WHERE ps.commodity_id IS NULL
  AND s.sync_date = (SELECT MAX(sync_date) FROM amf_jh_company_stock)
GROUP BY s.local_sku, s.sync_date;
```

## 定时任务配置 / Scheduled Job Setup

### MySQL Event Scheduler
```sql
-- 启用事件调度器
SET GLOBAL event_scheduler = ON;

-- 创建每日凌晨3点执行的事件
CREATE EVENT evt_daily_spu_stockout_snapshot
ON SCHEDULE EVERY 1 DAY
STARTS DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 1 DAY), INTERVAL 3 HOUR)
DO
  CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);
```

### Linux Cron Job
```bash
# 添加到crontab
0 3 * * * /opt/scripts/spu_stockout_snapshot.sh

# Shell脚本内容 (/opt/scripts/spu_stockout_snapshot.sh)
#!/bin/bash
mysql -h localhost -u user -ppassword database <<EOF
CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);
EOF
```

## 性能优化 / Performance Tuning

### 索引检查
```sql
-- 检查amf_jh_company_stock索引
SHOW INDEX FROM amf_jh_company_stock;

-- 如果索引不存在，手动添加
ALTER TABLE amf_jh_company_stock 
  ADD INDEX idx_sync_date (sync_date),
  ADD INDEX idx_local_sku (local_sku),
  ADD INDEX idx_sync_date_local_sku (sync_date, local_sku);
```

### 数据清理
```sql
-- 软删除90天前的历史数据
UPDATE cos_oos_spu_monitor_daily 
SET deleted = UNIX_TIMESTAMP()
WHERE monitor_date < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
  AND deleted = 0;

-- 物理删除已标记删除的数据（可选）
DELETE FROM cos_oos_spu_monitor_daily
WHERE deleted > 0
  AND deleted < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 30 DAY));
```

### 监控执行时间
```sql
-- 记录执行时间
SET @start_time = NOW();
CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);
SELECT TIMESTAMPDIFF(SECOND, @start_time, NOW()) AS execution_seconds;
```

## 故障排查 / Troubleshooting

### 问题1：没有找到国内仓库存数据
```sql
-- 检查amf_jh_company_stock是否有数据
SELECT 
  MAX(sync_date) AS latest_sync_date,
  COUNT(*) AS record_count,
  COUNT(DISTINCT local_sku) AS distinct_skus
FROM amf_jh_company_stock;
```

### 问题2：映射覆盖率低
```sql
-- 查看映射统计
SELECT 
  COUNT(DISTINCT s.local_sku) AS total_skus,
  COUNT(DISTINCT CASE WHEN ps.commodity_id IS NOT NULL THEN s.local_sku END) AS mapped_skus,
  ROUND(
    COUNT(DISTINCT CASE WHEN ps.commodity_id IS NOT NULL THEN s.local_sku END) * 100.0 / 
    COUNT(DISTINCT s.local_sku), 
    2
  ) AS coverage_percentage
FROM amf_jh_company_stock s
LEFT JOIN pms_commodity_sku ps ON (
  s.local_sku = ps.custom_code OR s.local_sku = ps.commodity_sku_code
)
WHERE ps.use_status = 0 AND ps.sale_status = 0;
```

### 问题3：快照数据不准确
```sql
-- 验证聚合准确性
SELECT 
  v.commodity_id,
  COUNT(*) AS local_sku_count,
  SUM(v.remaining_num) AS calculated_remaining,
  s.domestic_remaining_qty AS snapshot_remaining,
  SUM(v.remaining_num) - s.domestic_remaining_qty AS difference
FROM v_domestic_stock_to_product v
JOIN cos_oos_spu_monitor_daily s ON v.commodity_id = s.commodity_id
WHERE v.sync_date = s.domestic_stock_sync_date
  AND s.monitor_date = CURDATE()
  AND s.deleted = 0
GROUP BY v.commodity_id, s.domestic_remaining_qty
HAVING ABS(difference) > 1;
```

## 数据字典 / Data Dictionary

### cos_oos_spu_monitor_daily 主要字段

| 字段名 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| commodity_id | BIGINT | 产品ID | 12345 |
| monitor_date | DATE | 监控日期 | 2024-01-15 |
| domestic_remaining_qty | INT | 国内仓余单数量 | 500 |
| domestic_actual_stock_qty | INT | 国内仓实物库存 | 800 |
| platform_total_onhand | INT | 平台总库存 | 1200 |
| weighted_daily_demand | DECIMAL(12,2) | 日均消耗 | 25.50 |
| doc_days | DECIMAL(12,2) | 覆盖天数 | 78.43 |
| risk_level | TINYINT | 风险等级(0-4) | 2 |

### 风险等级说明

| 等级 | 名称 | 覆盖天数 | 处理建议 |
|------|------|----------|----------|
| 0 | 正常 | > 60天 | 保持监控 |
| 1 | 安全区 | 30-60天 | 关注趋势 |
| 2 | 需要生产 | 15-30天 | 安排生产计划 |
| 3 | 直补来不及 | 7-15天 | 紧急直补或备货 |
| 4 | 已断货 | < 7天 | 紧急处理 |

## 最佳实践 / Best Practices

1. **每日定时执行**：建议在凌晨3-5点执行快照计算
2. **监控执行状态**：记录执行日志，监控执行时间
3. **定期数据清理**：保留90天历史数据，定期清理旧数据
4. **映射维护**：定期检查和更新local_sku到产品的映射关系
5. **性能监控**：关注存储过程执行时间，必要时优化索引
6. **备份策略**：定期备份快照表数据

## 相关文档 / Related Documentation

- [完整指南](PRODUCT_STOCKOUT_MONITOR_GUIDE.md)
- [数据库架构](product_stockout_monitor_schema.sql)
- [测试脚本](product_stockout_monitor_test.sql)

## 联系支持 / Support

如遇问题，请：
1. 查看故障排查章节
2. 执行测试脚本验证环境
3. 联系技术支持团队
