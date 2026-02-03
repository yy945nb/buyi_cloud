# 产品断货点监控实施指南
# Product Stockout Monitoring Implementation Guide

## 概述 / Overview

本文档详细说明产品维度的断货点监控实现方案，包括区域仓和FBA仓的库存计算，以及按业务模式隔离的在途库存统计。

This document provides detailed implementation guide for product-level stockout point monitoring, including inventory calculation for regional warehouses and FBA warehouses, with business mode isolation for in-transit inventory.

## 业务模式隔离 / Business Mode Isolation

### 两种业务模式 / Two Business Modes

#### 1. 区域仓模式 (JH_LX)
- **海外仓现有库存**：JH仓 + LX仓合并统计
  - 数据源：`amf_jh_warehouse_stock` + `amf_lx_warehouse_stock`
  - 按产品SKU聚合，合并两个仓库的库存数量
  
- **在途库存**：JH发货单 + LX发货单合并统计
  - JH数据源：`amf_jh_shipment` + `amf_jh_shipment_sku`
  - LX数据源：`amf_lx_owmsshipment` + `amf_lx_owmsshipment_products`
  - 按产品SKU聚合，合并两种发货模式的在途数量

#### 2. FBA模式 (FBA)
- **海外仓现有库存**：FBA平台可用库存
  - 数据源：`amf_lx_fbadetail.available_total`
  - 完全独立统计，不与区域仓模式混合
  
- **在途库存**：FBA发货单
  - 数据源：`amf_lx_fbashipment` + `amf_lx_fbashipment_item`
  - 独立统计，与区域仓模式完全隔离

### 隔离原则 / Isolation Principles

```
区域仓模式 (JH_LX):
  海外仓库存 = JH仓库存 + LX仓库存
  在途库存 = JH发货单 + LX发货单
  监控记录: business_mode = 'JH_LX'

FBA模式 (FBA):
  海外仓库存 = FBA可用库存
  在途库存 = FBA发货单
  监控记录: business_mode = 'FBA'
  
数据完全隔离，不相互影响
```

## 国内仓库存共享 / Domestic Inventory Sharing

### 数据源
- 表：`amf_jh_company_stock`
- 字段：
  - `local_sku`: 本地SKU（国内仓SKU）
  - `remaining_num`: 余单数量
  - `stock_num`: 实物库存数量
  - `sync_date`: 数据同步日期

### 查询逻辑

```sql
-- 查询国内仓库存（按monitor_date取最近一次sync_date）
WITH latest_sync AS (
    SELECT 
        local_sku,
        company_id,
        MAX(sync_date) as latest_sync_date
    FROM amf_jh_company_stock
    WHERE sync_date <= :monitor_date  -- 监控日期
      AND (:company_id IS NULL OR company_id = :company_id)
    GROUP BY local_sku, company_id
)
SELECT 
    s.local_sku,
    s.company_id,
    SUM(s.remaining_num) as domestic_remaining_qty,
    SUM(s.stock_num) as domestic_actual_stock_qty,
    ls.latest_sync_date as sync_date,
    m.product_sku  -- 需要映射到产品SKU
FROM amf_jh_company_stock s
INNER JOIN latest_sync ls 
    ON s.local_sku = ls.local_sku 
    AND s.company_id = ls.company_id
    AND s.sync_date = ls.latest_sync_date
LEFT JOIN sku_mapping m ON s.local_sku = m.local_sku
GROUP BY s.local_sku, s.company_id, ls.latest_sync_date, m.product_sku;
```

### 共享使用
国内仓库存数据在两种业务模式下共享使用：
- JH_LX模式的监控记录包含相同的`domestic_remaining_qty`和`domestic_actual_stock_qty`
- FBA模式的监控记录也包含相同的国内仓库存数据
- 用于计算总库存和可用库存时的参考

## 数据模型 / Data Models

### 1. ProductStockoutMonitoring (产品断货点监控)

```java
public class ProductStockoutMonitoring {
    // 基本信息
    private Long productId;                    // 产品ID
    private String productSku;                 // 产品SKU
    private String productName;                // 产品名称
    private Long companyId;                    // 公司ID
    private Long warehouseId;                  // 仓库ID（可选）
    private Long regionalWarehouseId;          // 区域仓ID
    private String regionalWarehouseCode;      // 区域仓编码
    private BusinessMode businessMode;         // 业务模式（JH_LX/FBA）
    private LocalDate snapshotDate;            // 快照日期
    
    // 库存指标
    private Integer overseasInventory;         // 海外仓现有库存
    private Integer inTransitInventory;        // 在途库存
    private Integer domesticRemainingQty;      // 国内仓余单数量
    private Integer domesticActualStockQty;    // 国内仓实物库存数量
    private Integer totalInventory;            // 总库存（海外+在途）
    private Integer availableInventory;        // 可用库存
    
    // 销量指标
    private BigDecimal dailyAvgSales;          // 日均销量
    private BigDecimal regionalProportion;     // 区域销量占比
    private BigDecimal regionalDailySales;     // 区域日均销量
    
    // 周期参数
    private Integer safetyStockDays;           // 安全库存天数
    private Integer stockingCycleDays;         // 备货周期天数
    private Integer shippingDays;              // 发货天数
    private Integer leadTimeDays;              // 总提前期
    
    // 断货点指标
    private Integer stockoutPoint;             // 断货点数量
    private BigDecimal availableDays;          // 可售天数
    private Integer stockoutRiskDays;          // 断货风险天数
    private Boolean isStockoutRisk;            // 是否有断货风险
    private RiskLevel riskLevel;               // 风险等级
}
```

### 2. DomesticInventoryAgg (国内仓库存聚合)

```java
public class DomesticInventoryAgg {
    private String productSku;         // 产品SKU
    private String localSku;           // 本地SKU
    private Long companyId;            // 公司ID
    private Integer remainingQty;      // 余单数量
    private Integer actualStockQty;    // 实物库存数量
    private LocalDate syncDate;        // 数据同步日期
    private LocalDate monitorDate;     // 监控日期
}
```

### 3. RegionalWarehouseParams (区域仓参数)

```java
public class RegionalWarehouseParams {
    private Long regionalWarehouseId;      // 区域仓ID
    private String regionalWarehouseCode;  // 区域仓编码
    private String regionalWarehouseName;  // 区域仓名称
    private Integer safetyStockDays;       // 安全库存天数（默认30天）
    private Integer stockingCycleDays;     // 备货周期天数（默认30天）
    private Integer shippingDays;          // 发货天数（不同区域不同）
    private Integer productionDays;        // 生产天数
    private Integer leadTimeDays;          // 总提前期天数
}
```

## 区域仓参数配置 / Regional Warehouse Parameters

### 参数说明

不同区域仓的发货天数（海运时间）不同，需要单独配置：

| 区域仓编码 | 区域名称 | 安全库存天数 | 备货周期 | 发货天数 | 总提前期 |
|-----------|---------|------------|---------|---------|---------|
| RW_US_WEST | 美西区域仓 | 30天 | 30天 | 35天 | 65天 |
| RW_US_EAST | 美东区域仓 | 30天 | 30天 | 50天 | 80天 |
| RW_US_CENTRAL | 美中区域仓 | 30天 | 30天 | 45天 | 75天 |
| RW_US_SOUTH | 美南区域仓 | 30天 | 30天 | 48天 | 78天 |

### 配置查询

```sql
-- 查询区域仓参数配置
SELECT 
    regional_warehouse_id,
    regional_warehouse_code,
    safety_stock_days,
    stocking_cycle_days,
    shipping_days,
    lead_time_days
FROM regional_warehouse_params
WHERE is_active = 1
  AND :monitor_date BETWEEN effective_date AND expiry_date
  AND regional_warehouse_id = :regional_warehouse_id;
```

## 字段计算公式 / Field Calculation Formulas

### 1. 海外仓库存 (Overseas Inventory)

#### JH_LX模式
```sql
-- 海外仓库存 = JH仓 + LX仓
SELECT 
    product_sku,
    SUM(stock_quantity) as overseas_inventory
FROM (
    -- JH仓库存
    SELECT 
        product_sku,
        SUM(stock_qty) as stock_quantity
    FROM amf_jh_warehouse_stock
    WHERE data_date = :snapshot_date
    GROUP BY product_sku
    
    UNION ALL
    
    -- LX仓库存
    SELECT 
        product_sku,
        SUM(stock_qty) as stock_quantity
    FROM amf_lx_warehouse_stock
    WHERE data_date = :snapshot_date
    GROUP BY product_sku
) combined
GROUP BY product_sku;
```

#### FBA模式
```sql
-- FBA海外仓库存
SELECT 
    product_sku,
    available_total as overseas_inventory
FROM amf_lx_fbadetail
WHERE data_date = :snapshot_date;
```

### 2. 在途库存 (In-Transit Inventory)

#### JH_LX模式
```sql
-- 在途库存 = JH发货单 + LX发货单
SELECT 
    product_sku,
    SUM(intransit_quantity) as in_transit_inventory
FROM (
    -- JH发货单
    SELECT 
        s.product_sku,
        SUM(si.quantity - COALESCE(si.received_quantity, 0)) as intransit_quantity
    FROM amf_jh_shipment s
    JOIN amf_jh_shipment_sku si ON s.id = si.shipment_id
    WHERE s.status IN ('SHIPPED', 'IN_TRANSIT')
      AND s.ship_date <= :snapshot_date
    GROUP BY s.product_sku
    
    UNION ALL
    
    -- LX OWMS发货单
    SELECT 
        s.product_sku,
        SUM(sp.quantity - COALESCE(sp.received_quantity, 0)) as intransit_quantity
    FROM amf_lx_owmsshipment s
    JOIN amf_lx_owmsshipment_products sp ON s.id = sp.shipment_id
    WHERE s.status IN ('SHIPPED', 'IN_TRANSIT')
      AND s.ship_date <= :snapshot_date
    GROUP BY s.product_sku
) combined
GROUP BY product_sku;
```

#### FBA模式
```sql
-- FBA在途库存
SELECT 
    s.product_sku,
    SUM(si.quantity - COALESCE(si.received_quantity, 0)) as in_transit_inventory
FROM amf_lx_fbashipment s
JOIN amf_lx_fbashipment_item si ON s.id = si.shipment_id
WHERE s.status IN ('SHIPPED', 'IN_TRANSIT')
  AND s.ship_date <= :snapshot_date
GROUP BY s.product_sku;
```

### 3. 总库存 (Total Inventory)
```
总库存 = 海外仓库存 + 在途库存
total_inventory = overseas_inventory + in_transit_inventory
```

### 4. 区域日均销量 (Regional Daily Sales)
```
区域日均销量 = 产品日均销量 × 区域销量占比
regional_daily_sales = product_daily_sale_qty × region_sales_ratio
```

产品日均销量来自：`pms_commodity_sku_params.daily_sale_qty`
区域销量占比来自：`order_regional_proportion.weighted_proportion`

### 5. 断货点 (Stockout Point)
```
断货点数量 = 区域日均销量 × 总提前期天数
stockout_point = regional_daily_sales × lead_time_days
```

### 6. 可售天数 (Available Days)
```
可售天数 = 可用库存 ÷ 区域日均销量
available_days = available_inventory ÷ regional_daily_sales
```

### 7. 断货风险天数 (Stockout Risk Days)
```
断货风险天数 = 可售天数 - (总提前期 + 安全库存天数)
stockout_risk_days = available_days - (lead_time_days + safety_stock_days)
```

### 8. 风险等级 (Risk Level)
```
if (可售天数 <= 0)
    风险等级 = STOCKOUT（已断货）
else if (可售天数 < 安全库存天数 × 0.5)
    风险等级 = DANGER（危险）
else if (可售天数 < 安全库存天数)
    风险等级 = WARNING（预警）
else
    风险等级 = SAFE（安全）
```

## 状态过滤 / Status Filtering

### 发货单状态过滤
在计算在途库存时，只统计以下状态的发货单：
- `SHIPPED`: 已发货
- `IN_TRANSIT`: 在途中

排除状态：
- `DRAFT`: 草稿
- `CONFIRMED`: 已确认（但未发货）
- `ARRIVED`: 已到货
- `CANCELLED`: 已取消

### 时间窗口
- **监控日期 (snapshot_date)**: 快照生成日期
- **发货日期过滤**: `ship_date <= snapshot_date`
- **国内仓同步日期**: `sync_date <= monitor_date`（取最近一次）

## ETL流程 / ETL Process

### 快照生成流程

```java
// 1. 生成每日监控快照
MonitoringSnapshotService snapshotService = new MonitoringSnapshotService();
SnapshotExecutionResult result = snapshotService.generateDailySnapshot(LocalDate.now());

// 2. 历史数据回溯
List<SnapshotExecutionResult> results = 
    snapshotService.backfillHistoricalSnapshots(startDate, endDate);
```

### 幂等性保证
ETL过程支持幂等执行，可以重复运行同一天的快照生成：

```sql
-- 使用 INSERT ... ON DUPLICATE KEY UPDATE 保证幂等性
INSERT INTO product_stockout_monitoring (
    product_sku, regional_warehouse_id, business_mode, snapshot_date,
    overseas_inventory, in_transit_inventory, ...
) VALUES (?, ?, ?, ?, ?, ?, ...)
ON DUPLICATE KEY UPDATE
    overseas_inventory = VALUES(overseas_inventory),
    in_transit_inventory = VALUES(in_transit_inventory),
    ... -- 更新所有字段
    update_time = CURRENT_TIMESTAMP;
```

唯一键约束：
```
UNIQUE KEY `uk_monitoring` (
    `product_sku`, 
    `regional_warehouse_id`, 
    `business_mode`, 
    `snapshot_date`
)
```

## SQL示例 / SQL Examples

### 查询产品监控数据
```sql
-- 查询单个产品在所有区域仓和业务模式的监控数据
SELECT 
    product_sku,
    regional_warehouse_code,
    business_mode,
    overseas_inventory,
    in_transit_inventory,
    domestic_remaining_qty,
    domestic_actual_stock_qty,
    total_inventory,
    regional_daily_sales,
    available_days,
    stockout_risk_days,
    risk_level
FROM product_stockout_monitoring
WHERE product_sku = 'TEST-SKU-001'
  AND snapshot_date = CURDATE()
ORDER BY regional_warehouse_code, business_mode;
```

### 查询高风险产品
```sql
-- 查询有断货风险的产品列表
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
  AND is_stockout_risk = 1
ORDER BY available_days ASC, regional_warehouse_code;
```

### 按公司查询
```sql
-- 查询指定公司的监控数据
SELECT 
    company_id,
    product_sku,
    regional_warehouse_code,
    business_mode,
    total_inventory,
    available_days,
    risk_level
FROM product_stockout_monitoring
WHERE snapshot_date = CURDATE()
  AND company_id = 1
  AND risk_level != 'SAFE'
ORDER BY risk_level DESC, available_days ASC;
```

### 趋势分析
```sql
-- 查询产品库存变化趋势（最近7天）
SELECT 
    snapshot_date,
    product_sku,
    regional_warehouse_code,
    business_mode,
    overseas_inventory,
    in_transit_inventory,
    total_inventory,
    available_days,
    risk_level
FROM product_stockout_monitoring
WHERE product_sku = 'TEST-SKU-001'
  AND snapshot_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
  AND regional_warehouse_code = 'RW_US_WEST'
ORDER BY snapshot_date DESC, business_mode;
```

## 服务接口 / Service Interfaces

### 1. DomesticInventoryService
```java
// 查询国内仓库存（按产品SKU聚合）
Map<String, DomesticInventoryAgg> queryDomesticInventory(
    LocalDate monitorDate, 
    Long companyId
);

// 查询单个产品SKU的国内仓库存
DomesticInventoryAgg queryDomesticInventoryBySku(
    String productSku, 
    LocalDate monitorDate, 
    Long companyId
);
```

### 2. OverseasInventoryService
```java
// 查询海外仓库存（按业务模式）
Map<String, Integer> queryOverseasInventory(
    String productSku, 
    BusinessMode businessMode, 
    LocalDate snapshotDate
);

// 批量查询海外仓库存
Map<String, Map<BusinessMode, Integer>> batchQueryOverseasInventory(
    List<String> productSkus, 
    LocalDate snapshotDate
);
```

### 3. InTransitInventoryService
```java
// 查询在途库存（按业务模式）
Map<String, Integer> queryInTransitInventory(
    String productSku, 
    BusinessMode businessMode, 
    LocalDate snapshotDate
);

// 批量查询在途库存
Map<String, Map<BusinessMode, Integer>> batchQueryInTransitInventory(
    List<String> productSkus, 
    LocalDate snapshotDate
);
```

### 4. MonitoringSnapshotService
```java
// 生成每日监控快照
SnapshotExecutionResult generateDailySnapshot(LocalDate snapshotDate);

// 历史数据回溯
List<SnapshotExecutionResult> backfillHistoricalSnapshots(
    LocalDate startDate, 
    LocalDate endDate
);
```

## 性能优化建议 / Performance Optimization

### 1. 索引优化
- 在 `product_sku`, `regional_warehouse_id`, `business_mode`, `snapshot_date` 上建立联合索引
- 在发货单表的 `status`, `ship_date` 上建立索引
- 在国内仓表的 `local_sku`, `sync_date` 上建立索引

### 2. 批量处理
- 使用批量插入代替逐条插入
- 批次大小建议：1000条/批次
- 使用事务保证数据一致性

### 3. 分区策略
- 对监控表按 `snapshot_date` 进行分区
- 保留最近3-6个月的数据在主表
- 历史数据归档到历史表

### 4. 缓存策略
- 区域仓配置数据可以缓存（变化频率低）
- 区域仓-仓库绑定关系可以缓存
- 区域仓参数配置可以缓存

## 常见问题 / FAQ

### Q1: 为什么JH和LX要合并统计？
A: JH（聚合）和LX（零星）虽然是不同的发货模式，但它们使用同样的海外仓库，库存是共享的。因此在计算海外仓现有库存时需要合并统计，以反映真实的库存可用情况。

### Q2: FBA模式的数据为什么要独立统计？
A: FBA使用亚马逊的仓库系统，与JH/LX的海外仓完全独立。FBA的库存、发货、物流等都由亚马逊管理，因此数据需要单独统计，避免与区域仓模式混淆。

### Q3: 国内仓库存如何在两种模式下共享？
A: 国内仓库存（余单和实物库存）是公司级别的数据，不区分发货模式。无论是区域仓模式（JH_LX）还是FBA模式，都可以使用相同的国内仓库存数据作为补货参考。

### Q4: 如何处理SKU映射关系？
A: 需要维护一个SKU映射表，将国内仓的 `local_sku` 映射到产品的 `product_sku`。如果没有映射表，可以通过产品主数据表进行关联匹配。

### Q5: 如何调整区域仓的参数？
A: 在 `regional_warehouse_params` 表中配置：
```sql
UPDATE regional_warehouse_params
SET safety_stock_days = 45,
    shipping_days = 40,
    lead_time_days = 70
WHERE regional_warehouse_id = 1
  AND is_active = 1;
```

## 相关文档 / Related Documentation

- [产品断货点监控模型使用指南](STOCKOUT_MONITORING_GUIDE.md)
- [数据仓库部署指南](DATA_WAREHOUSE_GUIDE.md)
- [备货模型引擎使用指南](STOCKING_MODEL_GUIDE.md)
- [在途库存统计指南](INTRANSIT_INVENTORY_GUIDE.md)
