# 产品断货点监控模型使用指南
# Product Stockout Point Monitoring Model User Guide

## 概述 / Overview

产品断货点监控模型是一个基于产品、仓库/区域仓维度的库存监控和断货预警系统。通过综合分析在途库存、海外仓库存、销售数据和区域分配比例，实时计算断货点和可售天数，提供精准的库存风险预警。

The Product Stockout Point Monitoring Model is an inventory monitoring and stockout warning system based on product and warehouse/regional warehouse dimensions. By comprehensively analyzing in-transit inventory, overseas warehouse inventory, sales data, and regional allocation ratios, it calculates stockout points and available days in real-time, providing accurate inventory risk warnings.

## 核心特性 / Core Features

### 1. 业务模式隔离
- **JH（聚合）模式**：集中发货模式
- **LX（零星）模式**：零星发货模式
- **FBA模式**：亚马逊FBA仓库模式
- **数据隔离**：FBA与JH/LX数据完全隔离统计
- **智能合并**：JH+LX合并计算海外仓库存，FBA单独统计

### 2. 库存来源追踪
- **在途库存**：按业务模式从JH、LX、FBA发货单聚合
- **海外仓库存**：JH+LX合并统计，FBA单独统计
- **仓库维度**：库存数据精确到具体仓库
- **区域仓聚合**：通过区域仓-仓库绑定关系汇总到区域维度

### 3. 断货点计算
- **多维度销量**：支持7天、30天日均销量计算
- **区域分配比例**：基于订单区域比例拆分销量
- **可售天数**：库存量 ÷ 区域日均销量
- **风险等级**：SAFE（安全）、WARNING（预警）、DANGER（危险）、STOCKOUT（已断货）

### 4. 历史数据回溯
- **按天快照**：每日生成监控快照
- **历史回溯**：支持指定日期范围回溯数据
- **执行日志**：完整的任务执行记录和统计

## 数据模型 / Data Models

### 1. 区域仓维度表 (dw_dim_regional_warehouse)

区域仓是多个仓库的逻辑分组，用于按地理区域进行库存管理。

```sql
CREATE TABLE `dw_dim_regional_warehouse` (
    `regional_warehouse_key` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `regional_warehouse_id` BIGINT NOT NULL,
    `regional_warehouse_code` VARCHAR(64) NOT NULL,
    `regional_warehouse_name` VARCHAR(128) NOT NULL,
    `region` VARCHAR(64) NOT NULL, -- 地区：US_WEST/US_EAST/US_CENTRAL/US_SOUTH
    `country` VARCHAR(64),
    `status` VARCHAR(20) DEFAULT 'ACTIVE',
    ...
);
```

### 2. 区域仓-仓库绑定关系表 (regional_warehouse_binding)

定义区域仓与具体仓库的绑定关系，支持业务模式隔离。

```sql
CREATE TABLE `regional_warehouse_binding` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `regional_warehouse_id` BIGINT NOT NULL,
    `warehouse_id` BIGINT NOT NULL,
    `warehouse_code` VARCHAR(64) NOT NULL,
    `business_mode` ENUM('JH', 'LX', 'FBA') NOT NULL,
    `priority` INT DEFAULT 1,
    `is_active` TINYINT(1) DEFAULT 1,
    ...
);
```

### 3. 发货单表 (shipment_order)

记录JH、LX、FBA三种业务模式的发货单，用于计算在途库存。

```sql
CREATE TABLE `shipment_order` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `order_no` VARCHAR(64) NOT NULL,
    `product_id` BIGINT NOT NULL,
    `product_sku` VARCHAR(100) NOT NULL,
    `warehouse_id` BIGINT NOT NULL,
    `business_mode` ENUM('JH', 'LX', 'FBA') NOT NULL,
    `quantity` INT NOT NULL,
    `status` ENUM('DRAFT', 'CONFIRMED', 'SHIPPED', 'IN_TRANSIT', 'ARRIVED', 'CANCELLED'),
    `ship_date` DATE,
    `expected_arrival_date` DATE,
    ...
);
```

### 4. 海外仓库存表 (overseas_warehouse_inventory)

记录海外仓现有库存，按业务模式区分JH_LX合并和FBA单独。

```sql
CREATE TABLE `overseas_warehouse_inventory` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `product_id` BIGINT NOT NULL,
    `product_sku` VARCHAR(100) NOT NULL,
    `warehouse_id` BIGINT NOT NULL,
    `business_mode` ENUM('JH_LX', 'FBA') NOT NULL,
    `on_hand_quantity` INT DEFAULT 0,
    `available_quantity` INT DEFAULT 0,
    `data_date` DATE NOT NULL,
    ...
);
```

### 5. 订单区域比例表 (order_regional_proportion)

记录产品在各区域仓的订单占比，用于销量拆分。

```sql
CREATE TABLE `order_regional_proportion` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `product_sku` VARCHAR(100) NOT NULL,
    `regional_warehouse_id` BIGINT NOT NULL,
    `sales_quantity_7days` INT,
    `sales_quantity_30days` INT,
    `proportion_7days` DECIMAL(5,4),
    `proportion_30days` DECIMAL(5,4),
    `weighted_proportion` DECIMAL(5,4),
    `calculation_date` DATE NOT NULL,
    ...
);
```

### 6. 产品断货点监控表 (product_stockout_monitoring)

核心监控指标表，存储每日快照数据。

```sql
CREATE TABLE `product_stockout_monitoring` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `product_sku` VARCHAR(100) NOT NULL,
    `regional_warehouse_id` BIGINT NOT NULL,
    `business_mode` ENUM('JH_LX', 'FBA') NOT NULL,
    `snapshot_date` DATE NOT NULL,
    
    -- 库存指标
    `overseas_inventory` INT DEFAULT 0,
    `in_transit_inventory` INT DEFAULT 0,
    `total_inventory` INT DEFAULT 0,
    `available_inventory` INT DEFAULT 0,
    
    -- 销量指标
    `daily_avg_sales` DECIMAL(10,4),
    `regional_daily_sales` DECIMAL(10,4),
    
    -- 断货点指标
    `stockout_point` INT DEFAULT 0,
    `available_days` DECIMAL(10,2),
    `stockout_risk_days` INT DEFAULT 0,
    `is_stockout_risk` TINYINT(1) DEFAULT 0,
    `risk_level` ENUM('SAFE', 'WARNING', 'DANGER', 'STOCKOUT'),
    
    UNIQUE KEY `uk_monitoring` (`product_sku`, `regional_warehouse_id`, `business_mode`, `snapshot_date`),
    ...
);
```

## 指标计算逻辑 / Calculation Logic

### 1. 在途库存计算

从发货单表聚合计算在途库存：

```sql
-- 计算在途库存（按产品、仓库、业务模式分组）
SELECT 
  product_id,
  product_sku,
  warehouse_id,
  warehouse_code,
  business_mode,
  SUM(quantity - COALESCE(received_quantity, 0)) as in_transit_quantity
FROM shipment_order
WHERE status IN ('SHIPPED', 'IN_TRANSIT')
  AND ship_date <= ?  -- 截止日期
GROUP BY product_id, product_sku, warehouse_id, warehouse_code, business_mode
```

### 2. 海外仓库存计算

按业务模式分别统计：

```sql
-- JH+LX合并统计
SELECT 
  product_sku,
  warehouse_id,
  'JH_LX' as business_mode,
  SUM(on_hand_quantity) as on_hand_quantity,
  SUM(available_quantity) as available_quantity
FROM overseas_warehouse_inventory
WHERE data_date = ?
  AND business_mode = 'JH_LX'
GROUP BY product_sku, warehouse_id

UNION ALL

-- FBA单独统计
SELECT 
  product_sku,
  warehouse_id,
  'FBA' as business_mode,
  SUM(on_hand_quantity) as on_hand_quantity,
  SUM(available_quantity) as available_quantity
FROM overseas_warehouse_inventory
WHERE data_date = ?
  AND business_mode = 'FBA'
GROUP BY product_sku, warehouse_id
```

### 3. 订单区域比例计算

```sql
-- 计算产品在各区域的销量占比
WITH regional_sales AS (
    SELECT 
        product_sku,
        regional_warehouse_id,
        SUM(CASE WHEN sales_date >= DATE_SUB(?, INTERVAL 7 DAY) THEN quantity ELSE 0 END) as qty_7d,
        SUM(CASE WHEN sales_date >= DATE_SUB(?, INTERVAL 30 DAY) THEN quantity ELSE 0 END) as qty_30d
    FROM daily_sales_detail
    WHERE sales_date <= ?
    GROUP BY product_sku, regional_warehouse_id
),
total_sales AS (
    SELECT 
        product_sku,
        SUM(qty_7d) as total_7d,
        SUM(qty_30d) as total_30d
    FROM regional_sales
    GROUP BY product_sku
)
SELECT 
    r.product_sku,
    r.regional_warehouse_id,
    r.qty_7d,
    r.qty_30d,
    r.qty_7d / NULLIF(t.total_7d, 0) as proportion_7d,
    r.qty_30d / NULLIF(t.total_30d, 0) as proportion_30d,
    (r.qty_7d / NULLIF(t.total_7d, 0)) * 0.5 + (r.qty_30d / NULLIF(t.total_30d, 0)) * 0.5 as weighted_proportion
FROM regional_sales r
JOIN total_sales t ON r.product_sku = t.product_sku
```

### 4. 日均销量计算

```
日均销量7天 = SUM(7天销量) / 7
日均销量30天 = SUM(30天销量) / 30
加权日均销量 = 日均销量7天 * 50% + 日均销量30天 * 50%
```

### 5. 区域日均销量计算

```
区域日均销量 = 加权日均销量 × 区域销量占比
```

### 6. 断货点计算

```
提前期 = 备货周期天数 + 发货天数
断货点数量 = 区域日均销量 × 提前期
安全库存数量 = 区域日均销量 × 安全库存天数
可售天数 = 可用库存 ÷ 区域日均销量
断货风险天数 = 可售天数 - (提前期 + 安全库存天数)
```

### 7. 风险等级判断

```
if (可售天数 <= 0)
    风险等级 = STOCKOUT（已断货）
else if (可售天数 < 安全库存天数 * 0.5)
    风险等级 = DANGER（危险）
else if (可售天数 < 安全库存天数)
    风险等级 = WARNING（预警）
else
    风险等级 = SAFE（安全）
```

## 使用示例 / Usage Examples

### 1. 生成每日监控快照

```java
// 创建监控快照服务
MonitoringSnapshotService snapshotService = new MonitoringSnapshotService();

// 生成今天的监控快照
MonitoringSnapshotService.SnapshotExecutionResult result = 
    snapshotService.generateDailySnapshot(LocalDate.now());

// 查看执行结果
System.out.println("批次ID: " + result.getBatchId());
System.out.println("处理产品数: " + result.getTotalProducts());
System.out.println("成功数: " + result.getSuccessCount());
System.out.println("预警数: " + result.getWarningCount());
System.out.println("严重风险数: " + result.getDangerCount());
System.out.println("执行耗时: " + result.getDurationMs() + "ms");
```

### 2. 历史数据回溯

```java
// 回溯过去7天的监控数据
LocalDate startDate = LocalDate.now().minusDays(7);
LocalDate endDate = LocalDate.now().minusDays(1);

List<MonitoringSnapshotService.SnapshotExecutionResult> results = 
    snapshotService.backfillHistoricalSnapshots(startDate, endDate);

// 查看每天的执行结果
for (MonitoringSnapshotService.SnapshotExecutionResult r : results) {
    System.out.println(String.format("%s: 成功%d, 预警%d, 危险%d",
        r.getSnapshotDate(), r.getSuccessCount(), 
        r.getWarningCount(), r.getDangerCount()));
}
```

### 3. 计算单个产品的断货点

```java
// 创建计算服务
StockoutPointCalculationService calculationService = 
    new StockoutPointCalculationService();

// 计算产品断货点
ProductStockoutMonitoring monitoring = calculationService.calculateStockoutPoint(
    "TEST-SKU-001",              // 产品SKU
    1001L,                       // 产品ID
    "测试产品",                   // 产品名称
    1L,                          // 区域仓ID
    "RW_US_WEST",                // 区域仓编码
    BusinessMode.JH_LX,          // 业务模式
    LocalDate.now()              // 快照日期
);

// 查看监控指标
System.out.println("总库存: " + monitoring.getTotalInventory());
System.out.println("在途库存: " + monitoring.getInTransitInventory());
System.out.println("海外仓库存: " + monitoring.getOverseasInventory());
System.out.println("区域日均销量: " + monitoring.getRegionalDailySales());
System.out.println("可售天数: " + monitoring.getAvailableDays());
System.out.println("断货点: " + monitoring.getStockoutPoint());
System.out.println("风险等级: " + monitoring.getRiskLevel());
```

### 4. 查询监控数据

```sql
-- 查询某个产品在所有区域仓的最新监控数据
SELECT 
    product_sku,
    regional_warehouse_code,
    business_mode,
    total_inventory,
    regional_daily_sales,
    available_days,
    risk_level
FROM product_stockout_monitoring
WHERE product_sku = 'TEST-SKU-001'
  AND snapshot_date = CURDATE()
ORDER BY regional_warehouse_code, business_mode;

-- 查询高风险产品列表
SELECT 
    product_sku,
    product_name,
    regional_warehouse_code,
    business_mode,
    available_days,
    stockout_risk_days,
    risk_level
FROM product_stockout_monitoring
WHERE snapshot_date = CURDATE()
  AND risk_level IN ('DANGER', 'STOCKOUT')
ORDER BY available_days ASC;

-- 统计各风险等级的产品数量
SELECT 
    risk_level,
    business_mode,
    COUNT(*) as product_count,
    SUM(CASE WHEN is_stockout_risk = 1 THEN 1 ELSE 0 END) as stockout_risk_count
FROM product_stockout_monitoring
WHERE snapshot_date = CURDATE()
GROUP BY risk_level, business_mode
ORDER BY risk_level;
```

## 业务模式隔离说明 / Business Mode Isolation

### 模式隔离原则

1. **FBA模式独立**
   - FBA使用亚马逊FBA仓库，库存数据来自亚马逊平台
   - 发货和库存管理完全独立
   - 在监控表中单独记录，business_mode = 'FBA'

2. **JH+LX模式合并**
   - JH（聚合）和LX（零星）使用同样的海外仓
   - 库存数据需要合并计算
   - 在监控表中合并记录，business_mode = 'JH_LX'

3. **在途库存统计**
   - JH发货单：在途库存按JH模式统计
   - LX发货单：在途库存按LX模式统计
   - FBA发货单：在途库存按FBA模式统计
   - 聚合时，JH+LX的在途库存合并

### 数据流转示例

```
原始发货单数据：
├─ JH发货单 → 在途库存(JH) → 合并为在途库存(JH_LX)
├─ LX发货单 → 在途库存(LX) → 合并为在途库存(JH_LX)
└─ FBA发货单 → 在途库存(FBA) → 保持独立

原始库存数据：
├─ JH仓库库存 → 海外仓库存(JH_LX)
├─ LX仓库库存 → 海外仓库存(JH_LX)
└─ FBA平台库存 → 海外仓库存(FBA)

监控快照数据：
├─ 产品A + 区域仓1 + JH_LX → 监控记录1
└─ 产品A + 区域仓1 + FBA → 监控记录2
```

## 周期参数配置 / Cycle Parameters

不同区域仓的发货天数（海运时间）不同：

| 区域仓编码 | 区域名称 | 发货天数 | 监控提前天数 |
|-----------|---------|---------|------------|
| RW_US_WEST | 美西区域仓 | 35天 | 25天 |
| RW_US_EAST | 美东区域仓 | 50天 | 35天 |
| RW_US_CENTRAL | 美中区域仓 | 45天 | 32天 |
| RW_US_SOUTH | 美南区域仓 | 48天 | 34天 |

默认周期参数：
- **安全库存天数**：30天
- **备货周期天数**：30天
- **发货天数**：根据区域仓配置

## 数据回溯说明 / Data Backfill Guide

### 回溯某天的监控数据

要查询历史某天的监控快照，只需指定snapshot_date：

```sql
-- 查询2024年1月15日的监控数据
SELECT * FROM product_stockout_monitoring
WHERE snapshot_date = '2024-01-15'
  AND product_sku = 'TEST-SKU-001';
```

### 重新生成历史数据

如果需要重新生成历史数据（例如修复数据或重新计算）：

```java
// 重新生成指定日期的快照
MonitoringSnapshotService snapshotService = new MonitoringSnapshotService();
LocalDate targetDate = LocalDate.of(2024, 1, 15);

SnapshotExecutionResult result = snapshotService.generateDailySnapshot(targetDate);
```

### 批量重新生成

```java
// 批量重新生成过去30天的数据
LocalDate startDate = LocalDate.now().minusDays(30);
LocalDate endDate = LocalDate.now().minusDays(1);

List<SnapshotExecutionResult> results = 
    snapshotService.backfillHistoricalSnapshots(startDate, endDate);
```

## 性能优化建议 / Performance Optimization

1. **索引优化**
   - 在product_sku、regional_warehouse_id、business_mode、snapshot_date上建立联合索引
   - 在发货单表的status、ship_date上建立索引

2. **批量处理**
   - 使用批量插入代替逐条插入
   - 合理设置批次大小（建议1000条/批次）

3. **分区策略**
   - 对监控表按snapshot_date进行分区
   - 保留最近3-6个月的数据在主表，历史数据归档

4. **缓存策略**
   - 区域仓配置数据可以缓存
   - 区域仓-仓库绑定关系可以缓存

## 监控和告警 / Monitoring and Alerting

### 执行监控

监控任务执行状态记录在monitoring_execution_log表：

```sql
-- 查询最近的执行日志
SELECT 
    batch_id,
    snapshot_date,
    execution_time,
    total_products,
    success_count,
    error_count,
    warning_count,
    danger_count,
    duration_ms,
    status
FROM monitoring_execution_log
ORDER BY execution_time DESC
LIMIT 10;
```

### 风险告警

```sql
-- 查询需要告警的高风险产品
SELECT 
    product_sku,
    product_name,
    regional_warehouse_code,
    business_mode,
    available_days,
    risk_level
FROM product_stockout_monitoring
WHERE snapshot_date = CURDATE()
  AND risk_level IN ('DANGER', 'STOCKOUT')
  AND is_stockout_risk = 1
ORDER BY available_days ASC;
```

## 常见问题 / FAQ

### Q1: 为什么JH和LX要合并统计？

A: JH（聚合）和LX（零星）虽然是不同的发货模式，但它们使用同样的海外仓库，库存是共享的。因此在计算海外仓现有库存时需要合并统计，以反映真实的库存可用情况。

### Q2: 如何处理多个仓库绑定到同一个区域仓？

A: 通过regional_warehouse_binding表维护绑定关系。在聚合到区域仓维度时，会将该区域仓下所有绑定仓库的库存数据累加。

### Q3: 可售天数和断货风险天数有什么区别？

A: 
- **可售天数** = 当前库存 ÷ 日均销量，表示库存还能支撑多少天
- **断货风险天数** = 可售天数 - (提前期 + 安全库存天数)，表示距离断货风险点还有多少天
- 当断货风险天数为负数时，表示已经进入风险期

### Q4: 如何调整安全库存天数和备货周期？

A: 可以在product_stock_config表中为每个产品单独配置：
```sql
UPDATE product_stock_config
SET safety_stock_days = 45,
    stocking_cycle_days = 35
WHERE sku = 'TEST-SKU-001';
```

### Q5: 监控快照应该多久生成一次？

A: 建议每天生成一次，在业务低峰期（如凌晨2-4点）执行。如果需要更实时的监控，可以增加生成频率，但需要考虑数据库负载。

## 相关文档 / Related Documentation

- [数据仓库部署指南](DATA_WAREHOUSE_GUIDE.md)
- [备货模型引擎使用指南](STOCKING_MODEL_GUIDE.md)
- [规则引擎开发文档](RULE_ENGINE_README.md)

## 技术支持 / Technical Support

如有问题或建议，请通过GitHub Issue反馈。
