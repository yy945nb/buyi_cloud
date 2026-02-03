# 断货点监控模型实施清单
# Stock-Out Monitoring Model Implementation Checklist

## 快速开始 / Quick Start

### 步骤1: 创建数据库表结构
```bash
mysql -u username -p database < stockout_monitoring_schema.sql
```

### 步骤2: 初始化配置数据
参考 `stockout_monitoring_test.sql` 中的测试数据准备部分，配置：
1. 区域仓配置 (region_warehouse_config)
2. 仓库映射 (warehouse_mapping)
3. 区域仓绑定关系 (region_warehouse_binding)
4. 区域订单比例 (region_order_ratio_config)

### 步骤3: 准备基础数据
确保 `pms_commodity_sku_params` 表有每日数据：
```sql
INSERT INTO pms_commodity_sku_params
    (company_id, commodity_id, commodity_code, commodity_sku_id, 
     commodity_sku_code, data_date, daily_sale_qty, remaining_qty, 
     open_intransit_qty, safety_days, shipping_days, production_days)
SELECT ...
FROM your_sales_inventory_source;
```

### 步骤4: 执行每日同步
```sql
-- 同步SKU级快照
CALL sp_sync_pms_commodity_sku_region_wh_params_daily(1, CURDATE());

-- 同步SPU级快照
CALL sp_sync_pms_commodity_region_wh_params_daily(1, CURDATE());
```

### 步骤5: 查询断货风险
```sql
-- 查询高风险SKU
SELECT 
    business_mode,
    region_warehouse_code,
    commodity_sku_code,
    available_days,
    oos_date_est,
    gap_qty,
    risk_level
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1
  AND monitor_date = CURDATE()
  AND risk_level IN ('CRITICAL', 'HIGH')
ORDER BY available_days;
```

## 核心表说明 / Core Tables

### 快照表 (Snapshot Tables)
| 表名 | 说明 | 关键字段 |
|-----|------|---------|
| pms_commodity_sku_region_warehouse_params | SKU区域仓维度快照（核心） | monitor_date, business_mode, region_warehouse_id, warehouse_id, commodity_sku_id |
| pms_commodity_region_warehouse_params | SPU区域仓维度快照 | monitor_date, business_mode, region_warehouse_id, warehouse_id, commodity_id |

### 参数表 (Parameter Tables)
| 表名 | 说明 | 关键字段 |
|-----|------|---------|
| pms_commodity_params | SPU日参数 | commodity_id, data_date, daily_sale_qty, remaining_qty |
| pms_commodity_sku_params | SKU日参数 | commodity_sku_id, data_date, daily_sale_qty, remaining_qty |

### 配置表 (Configuration Tables)
| 表名 | 说明 | 关键字段 |
|-----|------|---------|
| region_warehouse_config | 区域仓配置 | region_warehouse_id, warehouse_type (FBA/REGIONAL) |
| region_warehouse_binding | 区域仓-仓库绑定 | region_warehouse_id, warehouse_id |
| warehouse_mapping | 仓库映射 | source_system (JH/LX/OWMS/FBA), external_warehouse_code |
| region_order_ratio_config | 区域订单比例 | region_warehouse_id, order_ratio |

## 存储过程 / Stored Procedures

### sp_sync_pms_commodity_sku_region_wh_params_daily
**功能**: 同步SKU区域仓日参数，生成每日快照

**参数**:
- `p_company_id`: 企业ID
- `p_monitor_date`: 监控日期

**示例**:
```sql
CALL sp_sync_pms_commodity_sku_region_wh_params_daily(1, '2024-02-03');
```

### sp_sync_pms_commodity_region_wh_params_daily
**功能**: 从SKU快照聚合到SPU级别

**参数**:
- `p_company_id`: 企业ID
- `p_monitor_date`: 监控日期

**示例**:
```sql
CALL sp_sync_pms_commodity_region_wh_params_daily(1, '2024-02-03');
```

### sp_sync_jh_shop_to_cos_shop
**功能**: 同步JH店铺到cos_shop

**示例**:
```sql
CALL sp_sync_jh_shop_to_cos_shop();
```

### sp_sync_jh_warehouse_relation
**功能**: 同步JH仓库关系到cos_shop_warehouse_relation

**示例**:
```sql
CALL sp_sync_jh_warehouse_relation();
```

## 断货点计算公式 / ROP Calculation Formulas

```
区域日均销量 = daily_sale_qty × region_order_ratio

安全库存数量 = 区域日均销量 × safety_days

再订货点(ROP) = 区域日均销量 × (shipping_days + production_days + safety_days)

总可用库存 = onhand_qty + in_transit_qty

缺口数量 = ROP - 总可用库存

可售天数 = 总可用库存 / 区域日均销量

预计断货日期 = monitor_date + 可售天数
```

## 风险等级 / Risk Levels

| 风险等级 | 可售天数 | 说明 |
|---------|---------|------|
| CRITICAL | ≤ 7天 | 极高风险，立即补货 |
| HIGH | 8-15天 | 高风险，紧急安排 |
| MEDIUM | 16-30天 | 中风险，正常计划 |
| LOW | > 30天 | 低风险，库存充足 |

## 业务模式差异 / Business Mode Differences

### FBA模式
- 库存来源: FBA平台库存
- 在途来源: FBA shipment
- 默认区域比例: 100%
- 仓库类型: 逻辑仓

### REGIONAL模式
- 库存来源: JH海外仓 + LX海外仓
- 在途来源: JH shipment + LX发货单
- 默认区域比例: 25%（可配置）
- 仓库类型: 物理仓

## 常用查询 / Common Queries

### 1. 查看今日高风险SKU
```sql
SELECT 
    business_mode,
    region_warehouse_name,
    commodity_sku_code,
    available_days,
    gap_qty,
    risk_level
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1
  AND monitor_date = CURDATE()
  AND risk_level IN ('CRITICAL', 'HIGH')
ORDER BY available_days;
```

### 2. 按区域仓汇总库存
```sql
SELECT 
    region_warehouse_code,
    business_mode,
    SUM(onhand_qty) as total_onhand,
    SUM(in_transit_qty) as total_in_transit,
    AVG(available_days) as avg_available_days,
    COUNT(*) as sku_count
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1
  AND monitor_date = CURDATE()
GROUP BY region_warehouse_code, business_mode;
```

### 3. 计算补货需求
```sql
SELECT 
    commodity_sku_code,
    gap_qty,
    region_daily_sale_qty,
    CEIL(gap_qty + region_daily_sale_qty * (shipping_days + production_days)) as recommended_order_qty,
    risk_level
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1
  AND monitor_date = CURDATE()
  AND gap_qty > 0
ORDER BY risk_level, gap_qty DESC;
```

### 4. 7天趋势分析
```sql
SELECT 
    monitor_date,
    risk_level,
    COUNT(*) as sku_count
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1
  AND monitor_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY monitor_date, risk_level
ORDER BY monitor_date DESC, risk_level;
```

## 定时任务配置 / Scheduled Job Configuration

### Linux Cron示例
```bash
# 每天凌晨1点执行SKU快照同步
0 1 * * * /usr/bin/mysql -u username -ppassword database -e "CALL sp_sync_pms_commodity_sku_region_wh_params_daily(1, CURDATE());"

# 每天凌晨1:30执行SPU快照同步
30 1 * * * /usr/bin/mysql -u username -ppassword database -e "CALL sp_sync_pms_commodity_region_wh_params_daily(1, CURDATE());"
```

### MySQL Event Scheduler示例
```sql
-- 启用事件调度器
SET GLOBAL event_scheduler = ON;

-- 创建每日同步事件
DELIMITER $$

CREATE EVENT IF NOT EXISTS evt_sync_stockout_monitoring_daily
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 1 HOUR)
DO
BEGIN
    -- 同步SKU快照
    CALL sp_sync_pms_commodity_sku_region_wh_params_daily(1, CURDATE());
    
    -- 同步SPU快照
    CALL sp_sync_pms_commodity_region_wh_params_daily(1, CURDATE());
END$$

DELIMITER ;
```

## 数据维护 / Data Maintenance

### 历史数据归档
```sql
-- 将3个月前的数据归档到历史表
CREATE TABLE pms_commodity_sku_region_warehouse_params_archive 
LIKE pms_commodity_sku_region_warehouse_params;

INSERT INTO pms_commodity_sku_region_warehouse_params_archive
SELECT * FROM pms_commodity_sku_region_warehouse_params
WHERE monitor_date < DATE_SUB(CURDATE(), INTERVAL 90 DAY);

DELETE FROM pms_commodity_sku_region_warehouse_params
WHERE monitor_date < DATE_SUB(CURDATE(), INTERVAL 90 DAY);
```

### 数据质量检查
```sql
-- 检查缺失数据
SELECT 
    'Missing warehouse_id' as issue,
    COUNT(*) as count
FROM pms_commodity_sku_region_warehouse_params
WHERE warehouse_id IS NULL
  AND monitor_date = CURDATE()
UNION ALL
SELECT 
    'Negative available_days' as issue,
    COUNT(*) as count
FROM pms_commodity_sku_region_warehouse_params
WHERE available_days < 0
  AND monitor_date = CURDATE();
```

## 性能优化建议 / Performance Optimization

1. **分区表**: 按monitor_date分区，提升历史查询性能
2. **索引优化**: 已创建必要的复合索引，定期ANALYZE TABLE
3. **数据归档**: 定期归档历史数据（建议保留90天）
4. **批量处理**: 使用批量INSERT减少单条写入
5. **缓存策略**: 对于频繁查询的数据，考虑应用层缓存

## 故障排查 / Troubleshooting

### 问题1: 存储过程执行失败
**解决方案**:
- 检查pms_commodity_sku_params是否有当天数据
- 检查配置表是否正确初始化
- 查看MySQL错误日志

### 问题2: 快照数据为空
**解决方案**:
- 确认region_warehouse_config有active记录
- 确认region_warehouse_binding正确配置
- 检查company_id参数是否正确

### 问题3: 风险等级计算异常
**解决方案**:
- 检查daily_sale_qty和region_order_ratio是否合理
- 验证safety_days, shipping_days, production_days配置
- 检查available_days计算是否有除零错误

## 相关文档 / Related Documentation

- [详细使用指南](STOCKOUT_MONITORING_GUIDE.md)
- [测试SQL](stockout_monitoring_test.sql)
- [数据库Schema](stockout_monitoring_schema.sql)
- [备货模型指南](STOCKING_MODEL_GUIDE.md)
- [数据仓库指南](DATA_WAREHOUSE_GUIDE.md)

## 技术支持 / Support

如有问题，请提交GitHub Issue或联系技术团队。
