# 基于产品的断货点监控模型指南
# Product-Based Stockout Monitoring Model Guide

## 概述 / Overview

本文档介绍如何将国内仓余单/实物库存数据（`amf_jh_company_stock`）集成到"基于产品的断货点监控模型"中。

**核心目标**：
- 在产品级别（SPU维度）汇总断货风险监控数据
- 整合国内仓余单数量（remaining_num）和实物库存（stock_num）
- 提供产品级别的补货建议和风险预警

## 数据源说明 / Data Sources

### 1. 国内仓库存数据源
**表名**：`amf_jh_company_stock`

| 字段名 | 类型 | 说明 |
|--------|------|------|
| local_sku | VARCHAR(255) | 本地SKU编码 |
| remaining_num | INT | 余单数量 |
| stock_num | INT | 实物库存数量 |
| sync_date | DATE | 数据同步日期 |
| order_date | VARCHAR(255) | 订单日期 |
| business | VARCHAR(255) | 业务类型 |
| account | VARCHAR(255) | 账户 |
| factory_code | VARCHAR(255) | 工厂代码 |

**数据特点**：
- 每日同步一次，通过`sync_date`标识
- 同一个`local_sku`可能有多条记录（不同业务线、不同工厂）
- 需要按`local_sku`聚合：
  - `remaining_qty = SUM(remaining_num)` - 总余单数量
  - `actual_stock_qty = SUM(stock_num)` - 总实物库存

### 2. SKU映射表
**表名**：`pms_commodity_sku`

| 字段名 | 类型 | 说明 |
|--------|------|------|
| commodity_id | BIGINT | 产品ID（SPU） |
| commodity_code | VARCHAR(128) | 产品编码 |
| commodity_sku_code | VARCHAR(128) | 产品SKU编码 |
| custom_code | VARCHAR(128) | 自定义编码 |
| company_id | BIGINT | 企业ID |
| use_status | TINYINT | 删除状态（0-未删除, 1-已删除） |
| sale_status | TINYINT | 销售状态（0-在售, 1-禁售） |

**映射规则**：
```sql
amf_jh_company_stock.local_sku = pms_commodity_sku.custom_code 
  OR 
amf_jh_company_stock.local_sku = pms_commodity_sku.commodity_sku_code
```

仅匹配在售且未删除的SKU：
- `use_status = 0` (未删除)
- `sale_status = 0` (在售)

### 3. SKU级别断货监控数据
**表名**：`cos_oos_monitor_daily`

提供SKU维度的断货监控数据，包括：
- `platform_onhand` - 平台可售库存
- `daily_demand` - 日消耗率
- `domestic_available_spu` - 国内仓可用库存
- `open_intransit_qty` - 在途库存
- `risk_level` - 风险等级
- `suggest_transfer_final` - 建议直补量
- `suggest_produce` - 建议生产量

## 产品级别快照表结构 / Product-Level Snapshot Table

### 表名：`cos_oos_spu_monitor_daily`

**核心字段说明**：

| 字段组 | 字段名 | 说明 |
|--------|--------|------|
| **标识字段** | company_id | 企业ID |
| | commodity_id | 产品ID（SPU） |
| | commodity_code | 产品编码 |
| | monitor_date | 监控日期（快照日期） |
| **国内仓数据** | domestic_remaining_qty | 国内仓余单数量 = SUM(remaining_num) |
| | domestic_actual_stock_qty | 国内仓实物库存 = SUM(stock_num) |
| | domestic_stock_sync_date | 库存同步日期 |
| **海外仓数据** | platform_total_onhand | 平台总可售库存（所有SKU汇总） |
| | domestic_available_spu | 国内仓可用库存 |
| | open_intransit_qty | 在途未收数量 |
| **需求指标** | weighted_daily_demand | 加权日消耗率（所有SKU汇总） |
| | doc_days | 覆盖天数 |
| | oos_date_estimate | 预计断货日期 |
| **补货建议** | suggest_transfer_qty | 建议直补量 |
| | suggest_produce_qty | 建议生产量 |
| **风险评估** | risk_level | 风险等级（0-4） |
| | risk_reason | 风险原因说明 |
| **统计数据** | active_sku_count | 活跃SKU数量 |
| | high_risk_sku_count | 高风险SKU数量 |

### 风险等级定义

| 等级 | 名称 | 说明 |
|------|------|------|
| 0 | 正常 | 库存充足，无风险 |
| 1 | 安全区 | 库存在安全范围内 |
| 2 | 需要生产 | 需要安排生产 |
| 3 | 直补来不及 | 生产周期不足，需紧急处理 |
| 4 | 已断货 | 已经断货或即将断货 |

## 数据处理流程 / Data Processing Flow

### 流程图

```
┌─────────────────────────────┐
│ amf_jh_company_stock        │
│ (国内仓库存源数据)          │
│ - local_sku                 │
│ - remaining_num             │
│ - stock_num                 │
│ - sync_date                 │
└──────────┬──────────────────┘
           │
           │ 1. 按monitor_date取最近sync_date
           │ 2. 按local_sku聚合
           ↓
┌─────────────────────────────┐
│ v_domestic_stock_to_product │
│ (映射视图)                  │
│ - 映射到pms_commodity_sku   │
│ - 关联commodity_id          │
└──────────┬──────────────────┘
           │
           │ 3. 按commodity_id聚合
           │ 4. 关联SKU级别监控数据
           ↓
┌─────────────────────────────┐
│ cos_oos_monitor_daily       │
│ (SKU级别监控)               │
│ - platform_onhand           │
│ - daily_demand              │
│ - risk_level                │
└──────────┬──────────────────┘
           │
           │ 5. 汇总到产品级别
           │ 6. 计算风险指标
           ↓
┌─────────────────────────────┐
│ cos_oos_spu_monitor_daily   │
│ (产品级别监控快照)          │
│ + domestic_remaining_qty    │
│ + domestic_actual_stock_qty │
│ + risk_level (产品级)       │
└─────────────────────────────┘
```

### 计算逻辑

#### 1. 国内仓库存聚合
```sql
-- 对于每个产品（commodity_id），聚合所有关联的local_sku库存
domestic_remaining_qty = SUM(amf_jh_company_stock.remaining_num)
domestic_actual_stock_qty = SUM(amf_jh_company_stock.stock_num)
```

#### 2. 覆盖天数计算
```sql
doc_days = (platform_total_onhand + domestic_actual_stock_qty) / weighted_daily_demand
```

其中：
- `platform_total_onhand`：所有SKU的平台可售库存汇总
- `domestic_actual_stock_qty`：国内仓实物库存
- `weighted_daily_demand`：所有SKU的加权日消耗率汇总

#### 3. 预计断货日期
```sql
oos_date_estimate = monitor_date + FLOOR(doc_days) DAYS
```

#### 4. 风险等级确定
```sql
risk_level = MAX(所有关联SKU的risk_level)
-- 取最高风险等级作为产品级别风险
```

## 仓库处理说明 / Warehouse Handling

### 国内仓与海外仓区分

本模型中的仓库处理逻辑：

1. **国内仓数据**：
   - 来源：`amf_jh_company_stock`
   - 范围：所有国内仓库存（不区分具体warehouse_id）
   - 存储位置：产品级别快照表（`cos_oos_spu_monitor_daily`）
   - 字段：`domestic_remaining_qty`, `domestic_actual_stock_qty`

2. **海外仓数据**：
   - 来源：SKU级别监控表（`cos_oos_monitor_daily`）
   - 按shop_id和仓库区分
   - 汇总方式：按commodity_id聚合所有SKU的平台库存

3. **逻辑说明**：
   - 国内仓不区分warehouse_id，统一作为"国内仓"整体
   - 如需区分具体仓库，可在后续扩展中通过`amf_jh_company_stock.warehouse_name`字段实现
   - 当前实现：产品级别保存国内仓汇总数据

### 数据存储策略

```
产品级别（SPU）
├── 国内仓总库存（不分仓库）
│   ├── domestic_remaining_qty
│   └── domestic_actual_stock_qty
└── 海外仓总库存（汇总所有SKU）
    ├── platform_total_onhand
    └── open_intransit_qty
```

## 存储过程使用 / Stored Procedure Usage

### 存储过程：`sp_calculate_spu_stockout_snapshot`

**功能**：计算指定日期的产品级别断货点监控快照

**参数**：
- `p_monitor_date` (DATE) - 监控日期，NULL则使用当前日期
- `p_company_id` (BIGINT) - 企业ID，NULL则处理所有企业

**调用示例**：

```sql
-- 1. 计算今天的快照（所有企业）
CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);

-- 2. 计算指定日期的快照
CALL sp_calculate_spu_stockout_snapshot('2024-01-15', NULL);

-- 3. 计算指定企业的快照
CALL sp_calculate_spu_stockout_snapshot(CURDATE(), 123);

-- 4. 重新计算已存在的快照（幂等性）
CALL sp_calculate_spu_stockout_snapshot('2024-01-15', NULL);
-- 多次执行结果一致
```

**返回结果**：
```
+---------------+----------------+-------------------+-----------------+
| monitor_date  | sync_date_used | records_processed | high_risk_count |
+---------------+----------------+-------------------+-----------------+
| 2024-01-15    | 2024-01-15     | 1250              | 23              |
+---------------+----------------+-------------------+-----------------+
```

### 幂等性保证

存储过程使用 `INSERT ... ON DUPLICATE KEY UPDATE` 语句，确保：
- 首次执行：插入新记录
- 重复执行：更新已有记录
- 结果一致：多次执行产生相同结果

```sql
-- 唯一键约束
UNIQUE KEY `uk_company_commodity_date` 
  (`company_id`, `commodity_id`, `monitor_date`, `deleted`)
```

## 查询示例 / Query Examples

### 1. 查看指定日期的产品监控数据

```sql
SELECT 
  commodity_id,
  commodity_code,
  monitor_date,
  domestic_remaining_qty,
  domestic_actual_stock_qty,
  platform_total_onhand,
  weighted_daily_demand,
  doc_days,
  oos_date_estimate,
  risk_level,
  risk_reason
FROM cos_oos_spu_monitor_daily 
WHERE monitor_date = '2024-01-15' 
  AND deleted = 0
ORDER BY risk_level DESC, doc_days ASC;
```

### 2. 查询高风险产品

```sql
SELECT 
  commodity_id,
  commodity_code,
  domestic_actual_stock_qty,
  platform_total_onhand,
  weighted_daily_demand,
  doc_days,
  oos_date_estimate,
  suggest_transfer_qty,
  suggest_produce_qty,
  active_sku_count,
  high_risk_sku_count,
  risk_reason
FROM cos_oos_spu_monitor_daily
WHERE monitor_date = CURDATE()
  AND risk_level >= 3
  AND deleted = 0
ORDER BY risk_level DESC, doc_days ASC;
```

### 3. 验证国内仓库存聚合准确性

```sql
SELECT 
  v.commodity_id,
  v.commodity_code,
  COUNT(DISTINCT v.local_sku) AS local_sku_count,
  SUM(v.remaining_num) AS calculated_remaining,
  SUM(v.stock_num) AS calculated_stock,
  s.domestic_remaining_qty AS snapshot_remaining,
  s.domestic_actual_stock_qty AS snapshot_stock,
  s.domestic_stock_sync_date,
  -- 验证差异
  SUM(v.remaining_num) - s.domestic_remaining_qty AS remaining_diff,
  SUM(v.stock_num) - s.domestic_actual_stock_qty AS stock_diff
FROM v_domestic_stock_to_product v
JOIN cos_oos_spu_monitor_daily s ON (
  v.commodity_id = s.commodity_id 
  AND s.monitor_date = CURDATE()
  AND s.deleted = 0
)
WHERE v.sync_date = (
  SELECT MAX(sync_date) 
  FROM amf_jh_company_stock 
  WHERE sync_date <= CURDATE()
)
GROUP BY 
  v.commodity_id, 
  v.commodity_code, 
  s.domestic_remaining_qty, 
  s.domestic_actual_stock_qty,
  s.domestic_stock_sync_date
HAVING 
  remaining_diff != 0 OR stock_diff != 0;
```

### 4. 对比产品级与SKU级风险

```sql
SELECT 
  spu.commodity_id,
  spu.commodity_code,
  spu.risk_level AS spu_risk_level,
  spu.active_sku_count,
  spu.high_risk_sku_count,
  COUNT(sku.id) AS total_sku_records,
  MAX(sku.risk_level) AS max_sku_risk_level,
  AVG(sku.risk_level) AS avg_sku_risk_level
FROM cos_oos_spu_monitor_daily spu
JOIN cos_oos_monitor_daily sku ON (
  spu.commodity_id = sku.commodity_id
  AND spu.monitor_date = sku.monitor_date
  AND sku.deleted = 0
)
WHERE spu.monitor_date = CURDATE()
  AND spu.deleted = 0
GROUP BY 
  spu.commodity_id,
  spu.commodity_code,
  spu.risk_level,
  spu.active_sku_count,
  spu.high_risk_sku_count;
```

### 5. 趋势分析：过去7天的风险变化

```sql
SELECT 
  monitor_date,
  COUNT(*) AS total_products,
  SUM(CASE WHEN risk_level = 0 THEN 1 ELSE 0 END) AS normal_count,
  SUM(CASE WHEN risk_level = 1 THEN 1 ELSE 0 END) AS safe_count,
  SUM(CASE WHEN risk_level = 2 THEN 1 ELSE 0 END) AS need_produce_count,
  SUM(CASE WHEN risk_level = 3 THEN 1 ELSE 0 END) AS urgent_count,
  SUM(CASE WHEN risk_level = 4 THEN 1 ELSE 0 END) AS stockout_count,
  AVG(domestic_actual_stock_qty) AS avg_domestic_stock,
  AVG(doc_days) AS avg_coverage_days
FROM cos_oos_spu_monitor_daily
WHERE monitor_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
  AND deleted = 0
GROUP BY monitor_date
ORDER BY monitor_date DESC;
```

## 性能优化 / Performance Optimization

### 索引策略

#### 1. amf_jh_company_stock 表索引

```sql
-- 已添加的索引
ALTER TABLE amf_jh_company_stock 
  ADD INDEX idx_sync_date (sync_date),
  ADD INDEX idx_local_sku (local_sku),
  ADD INDEX idx_sync_date_local_sku (sync_date, local_sku);
```

**索引用途**：
- `idx_sync_date`：快速定位最新的sync_date
- `idx_local_sku`：按SKU查询库存
- `idx_sync_date_local_sku`：组合索引，优化聚合查询

#### 2. cos_oos_spu_monitor_daily 表索引

```sql
-- 主键和唯一键
PRIMARY KEY (id)
UNIQUE KEY uk_company_commodity_date (company_id, commodity_id, monitor_date, deleted)

-- 查询索引
KEY idx_company_date (company_id, monitor_date)
KEY idx_commodity_date (commodity_id, monitor_date)
KEY idx_risk_level (risk_level, monitor_date)
KEY idx_oos_date (oos_date_estimate)
```

**索引用途**：
- 唯一键：保证幂等性，防止重复记录
- `idx_company_date`：按企业查询历史数据
- `idx_commodity_date`：按产品查询历史数据
- `idx_risk_level`：快速筛选高风险产品
- `idx_oos_date`：按预计断货日期排序

### 性能建议

1. **定期数据清理**
   ```sql
   -- 删除90天前的历史数据（软删除）
   UPDATE cos_oos_spu_monitor_daily 
   SET deleted = UNIX_TIMESTAMP()
   WHERE monitor_date < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
     AND deleted = 0;
   ```

2. **批量处理时间**
   - 建议在凌晨3-5点执行日快照计算
   - 避开业务高峰期

3. **分区表优化**（可选）
   ```sql
   -- 如果数据量很大，可以考虑按月分区
   ALTER TABLE cos_oos_spu_monitor_daily
   PARTITION BY RANGE (TO_DAYS(monitor_date)) (
     PARTITION p202401 VALUES LESS THAN (TO_DAYS('2024-02-01')),
     PARTITION p202402 VALUES LESS THAN (TO_DAYS('2024-03-01')),
     -- ... 更多分区
   );
   ```

4. **执行时间监控**
   ```sql
   -- 记录执行时间
   SET @start_time = NOW();
   CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);
   SELECT TIMESTAMPDIFF(SECOND, @start_time, NOW()) AS execution_seconds;
   ```

## 定时任务配置 / Scheduled Job Configuration

### 每日自动执行快照计算

**方式1：MySQL Event Scheduler**

```sql
-- 启用事件调度器
SET GLOBAL event_scheduler = ON;

-- 创建每日凌晨3点执行的事件
DROP EVENT IF EXISTS evt_daily_spu_stockout_snapshot;

CREATE EVENT evt_daily_spu_stockout_snapshot
ON SCHEDULE EVERY 1 DAY
STARTS DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 1 DAY), INTERVAL 3 HOUR)
DO
  CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);

-- 查看事件状态
SHOW EVENTS WHERE Name = 'evt_daily_spu_stockout_snapshot';
```

**方式2：Cron Job (Linux)**

创建 shell 脚本 `/opt/scripts/spu_stockout_snapshot.sh`:

```bash
#!/bin/bash
# SPU断货点监控快照计算脚本

MYSQL_HOST="localhost"
MYSQL_USER="your_user"
MYSQL_PASS="your_password"
MYSQL_DB="buyi_platform_dev"
LOG_FILE="/var/log/spu_snapshot.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting SPU stockout snapshot calculation" >> $LOG_FILE

mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASS $MYSQL_DB <<EOF
CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);
EOF

if [ $? -eq 0 ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Success" >> $LOG_FILE
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed" >> $LOG_FILE
fi
```

添加到 crontab：
```bash
# 每天凌晨3点执行
0 3 * * * /opt/scripts/spu_stockout_snapshot.sh
```

## 故障排查 / Troubleshooting

### 常见问题

#### 1. 找不到国内仓库存数据

**错误信息**：
```
ERROR 1644 (45000): 没有找到国内仓库存数据（amf_jh_company_stock）
```

**解决方案**：
```sql
-- 检查amf_jh_company_stock表是否有数据
SELECT 
  MAX(sync_date) AS latest_sync,
  COUNT(*) AS record_count
FROM amf_jh_company_stock;

-- 如果没有数据，检查数据同步任务是否正常
```

#### 2. local_sku映射不到产品

**问题**：部分local_sku无法映射到commodity_id

**检查SQL**：
```sql
-- 查找未映射的local_sku
SELECT DISTINCT 
  s.local_sku,
  s.sync_date,
  SUM(s.remaining_num) AS total_remaining,
  SUM(s.stock_num) AS total_stock
FROM amf_jh_company_stock s
LEFT JOIN pms_commodity_sku ps ON (
  s.local_sku = ps.custom_code 
  OR s.local_sku = ps.commodity_sku_code
)
WHERE ps.commodity_id IS NULL
  AND s.sync_date = (SELECT MAX(sync_date) FROM amf_jh_company_stock)
GROUP BY s.local_sku, s.sync_date;
```

**解决方案**：
- 更新`pms_commodity_sku`表，补充缺失的映射关系
- 检查`custom_code`或`commodity_sku_code`是否正确

#### 3. 快照数据不准确

**验证方法**：
```sql
-- 对比原始数据和快照数据
SELECT 
  '原始数据' AS source,
  v.commodity_id,
  SUM(v.remaining_num) AS remaining_sum,
  SUM(v.stock_num) AS stock_sum
FROM v_domestic_stock_to_product v
WHERE v.sync_date = (SELECT MAX(sync_date) FROM amf_jh_company_stock WHERE sync_date <= CURDATE())
GROUP BY v.commodity_id

UNION ALL

SELECT 
  '快照数据' AS source,
  s.commodity_id,
  s.domestic_remaining_qty,
  s.domestic_actual_stock_qty
FROM cos_oos_spu_monitor_daily s
WHERE s.monitor_date = CURDATE()
  AND s.deleted = 0
ORDER BY commodity_id, source;
```

## 扩展功能 / Extended Features

### 未来可能的扩展

1. **区分具体仓库**
   - 在快照表中添加 `warehouse_id` 字段
   - 修改存储过程，支持按仓库分组

2. **历史趋势分析**
   - 创建视图或报表，展示产品库存趋势
   - 预测未来N天的库存情况

3. **智能补货建议**
   - 基于历史数据和季节性因素
   - 优化补货量和补货时机

4. **预警通知**
   - 当risk_level >= 3时发送邮件/短信通知
   - 集成钉钉、企业微信等即时通讯工具

5. **可视化仪表板**
   - 展示产品库存健康度
   - 风险产品分布地图
   - 补货计划看板

## 附录：数据字典 / Appendix: Data Dictionary

### 完整字段说明

详见 `product_stockout_monitor_schema.sql` 文件中的表结构定义。

### 相关表关系图

```
pms_commodity_sku (产品SKU表)
    ↓ (commodity_id)
cos_oos_spu_monitor_daily (产品级监控)
    ↑ (local_sku → commodity_id)
amf_jh_company_stock (国内仓库存)
    
cos_oos_monitor_daily (SKU级监控)
    ↓ (commodity_id聚合)
cos_oos_spu_monitor_daily (产品级监控)
```

## 联系与支持 / Contact & Support

如有问题或建议，请联系：
- 技术支持团队
- 提交Issue到代码仓库

---

**版本**：v1.0  
**最后更新**：2024-01-15  
**作者**：Buyi Tech Team
