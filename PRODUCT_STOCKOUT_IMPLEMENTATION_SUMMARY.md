# 产品断货点监控实施总结
# Product Stockout Monitoring Implementation Summary

## 实施概述 / Implementation Overview

本次实施完成了产品维度的断货点监控功能，支持区域仓和FBA仓的库存计算，并按业务模式（JH_LX和FBA）隔离计算库存与在途。

This implementation completes the product-level stockout monitoring feature, supporting inventory calculation for regional warehouses and FBA warehouses, with business mode isolation (JH_LX and FBA) for inventory and in-transit calculations.

## 核心特性 / Core Features

### 1. 业务模式隔离 / Business Mode Isolation

**区域仓模式 (JH_LX)**
- 海外仓库存 = JH仓 + LX仓 合并
- 在途库存 = JH发货单 + LX发货单 合并
- 数据来源：
  - `amf_jh_warehouse_stock` (JH仓库存)
  - `amf_lx_warehouse_stock` (LX仓库存)
  - `amf_jh_shipment` + `amf_jh_shipment_sku` (JH发货单)
  - `amf_lx_owmsshipment` + `amf_lx_owmsshipment_products` (LX发货单)

**FBA模式 (FBA)**
- 海外仓库存 = FBA平台可用库存 (独立)
- 在途库存 = FBA发货单 (独立)
- 数据来源：
  - `amf_lx_fbadetail.available_total` (FBA库存)
  - `amf_lx_fbashipment` + `amf_lx_fbashipment_item` (FBA发货单)

### 2. 国内仓库存共享 / Domestic Inventory Sharing

国内仓库存在两种业务模式下共享使用：
- 数据来源：`amf_jh_company_stock`
- 字段：`remaining_num` (余单数量), `stock_num` (实物库存)
- 查询逻辑：按 monitor_date 取 <= monitor_date 的最近一次 sync_date
- 按 local_sku 聚合并映射到 product_sku

### 3. 区域仓参数配置 / Regional Warehouse Parameters

支持按区域仓配置不同的参数：
- 安全库存天数 (safety_stock_days)
- 备货周期天数 (stocking_cycle_days)
- 发货天数/海运时间 (shipping_days)
- 总提前期 (lead_time_days)

不同区域仓的配置示例：
| 区域仓 | 安全库存 | 备货周期 | 发货天数 | 总提前期 |
|--------|---------|---------|---------|---------|
| 美西 (RW_US_WEST) | 30天 | 30天 | 35天 | 65天 |
| 美东 (RW_US_EAST) | 30天 | 30天 | 50天 | 80天 |
| 美中 (RW_US_CENTRAL) | 30天 | 30天 | 45天 | 75天 |
| 美南 (RW_US_SOUTH) | 30天 | 30天 | 48天 | 78天 |

## 数据模型变更 / Data Model Changes

### 1. ProductStockoutMonitoring 增强

新增字段：
```java
private Long companyId;                    // 公司ID (支持多公司)
private Long warehouseId;                  // 仓库ID (可选)
private Integer domesticRemainingQty;      // 国内仓余单数量
private Integer domesticActualStockQty;    // 国内仓实物库存数量
```

### 2. 新增 DomesticInventoryAgg 模型

用于国内仓库存聚合：
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

### 3. 新增 RegionalWarehouseParams 模型

用于区域仓参数配置：
```java
public class RegionalWarehouseParams {
    private Long regionalWarehouseId;      // 区域仓ID
    private String regionalWarehouseCode;  // 区域仓编码
    private Integer safetyStockDays;       // 安全库存天数
    private Integer stockingCycleDays;     // 备货周期天数
    private Integer shippingDays;          // 发货天数
    private Integer leadTimeDays;          // 总提前期天数
}
```

## 数据库变更 / Database Changes

### 1. product_stockout_monitoring 表增强

```sql
ALTER TABLE product_stockout_monitoring
ADD COLUMN company_id BIGINT COMMENT '公司ID',
ADD COLUMN warehouse_id BIGINT COMMENT '仓库ID（可选）',
ADD COLUMN domestic_remaining_qty INT DEFAULT 0 COMMENT '国内仓余单数量',
ADD COLUMN domestic_actual_stock_qty INT DEFAULT 0 COMMENT '国内仓实物库存数量',
ADD INDEX idx_company_id (company_id),
ADD INDEX idx_warehouse_id (warehouse_id);
```

### 2. 新增 regional_warehouse_params 表

```sql
CREATE TABLE regional_warehouse_params (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    regional_warehouse_id BIGINT NOT NULL,
    regional_warehouse_code VARCHAR(64) NOT NULL,
    safety_stock_days INT DEFAULT 30,
    stocking_cycle_days INT DEFAULT 30,
    shipping_days INT DEFAULT 45,
    lead_time_days INT DEFAULT 75,
    effective_date DATE NOT NULL,
    expiry_date DATE DEFAULT '9999-12-31',
    is_active TINYINT(1) DEFAULT 1,
    ...
);
```

## 服务层实现 / Service Layer Implementation

### 1. DomesticInventoryService

功能：
- 查询国内仓库存（按产品SKU聚合）
- 支持公司ID过滤
- 自动选择最近的sync_date数据
- SKU映射和聚合

核心方法：
```java
Map<String, DomesticInventoryAgg> queryDomesticInventory(
    LocalDate monitorDate, 
    Long companyId
);

DomesticInventoryAgg queryDomesticInventoryBySku(
    String productSku, 
    LocalDate monitorDate, 
    Long companyId
);
```

## ETL流程 / ETL Process

### SQL存储过程：sp_generate_stockout_monitoring_snapshot

功能特性：
1. **幂等性**：使用 `ON DUPLICATE KEY UPDATE` 保证可重复执行
2. **参数化**：支持指定 snapshot_date, company_id, regional_warehouse_id
3. **事务管理**：完整的事务控制和错误回滚
4. **错误处理**：异常捕获和日志记录
5. **自动计算**：自动计算所有派生字段

执行示例：
```sql
-- 生成今天的监控快照（所有公司和区域仓）
CALL sp_generate_stockout_monitoring_snapshot(
    CURDATE(),  -- snapshot_date
    NULL,       -- company_id
    NULL,       -- regional_warehouse_id
    @success_count,
    @error_count,
    @batch_id
);

SELECT @batch_id, @success_count, @error_count;
```

### ETL执行步骤

1. **初始化**：生成批次ID，记录执行开始日志
2. **生成JH_LX模式快照**：
   - 合并JH和LX的海外仓库存
   - 合并JH和LX的在途库存
   - 关联国内仓库存
   - 关联产品销量和区域占比
   - 关联区域仓参数
3. **生成FBA模式快照**：
   - 查询FBA平台库存（独立）
   - 查询FBA在途库存（独立）
   - 关联国内仓库存
   - 关联产品销量和区域占比
   - 关联区域仓参数
4. **计算派生字段**：
   - total_inventory = overseas_inventory + in_transit_inventory
   - available_inventory = overseas_inventory
   - regional_daily_sales = daily_avg_sales × regional_proportion
   - stockout_point = regional_daily_sales × lead_time_days
   - available_days = available_inventory ÷ regional_daily_sales
   - stockout_risk_days = available_days - (lead_time_days + safety_stock_days)
   - is_stockout_risk, risk_level
5. **完成并记录**：提交事务，更新执行日志

## 字段计算公式 / Calculation Formulas

### 1. 海外仓库存
```
JH_LX模式: overseas_inventory = SUM(JH仓库存) + SUM(LX仓库存)
FBA模式: overseas_inventory = FBA_available_total
```

### 2. 在途库存
```
JH_LX模式: in_transit_inventory = SUM(JH发货单) + SUM(LX发货单)
FBA模式: in_transit_inventory = SUM(FBA发货单)
```

### 3. 区域日均销量
```
regional_daily_sales = product_daily_sale_qty × region_sales_ratio
```

### 4. 断货点
```
stockout_point = regional_daily_sales × lead_time_days
```

### 5. 可售天数
```
available_days = available_inventory ÷ regional_daily_sales
```

### 6. 断货风险天数
```
stockout_risk_days = available_days - (lead_time_days + safety_stock_days)
```

### 7. 风险等级
```
if (available_days <= 0)
    risk_level = STOCKOUT
else if (available_days < safety_stock_days × 0.5)
    risk_level = DANGER
else if (available_days < safety_stock_days)
    risk_level = WARNING
else
    risk_level = SAFE
```

## 使用示例 / Usage Examples

### 1. 执行ETL生成快照

```sql
-- 生成今天的监控快照
CALL sp_generate_stockout_monitoring_snapshot(
    CURDATE(), NULL, NULL, @success, @error, @batch_id
);

-- 查看执行结果
SELECT @batch_id, @success, @error;

-- 查看执行日志
SELECT * FROM monitoring_execution_log WHERE batch_id = @batch_id;
```

### 2. 查询监控数据

```sql
-- 查询产品在所有区域仓和模式的监控数据
SELECT 
    product_sku,
    regional_warehouse_code,
    business_mode,
    overseas_inventory,
    in_transit_inventory,
    domestic_remaining_qty,
    domestic_actual_stock_qty,
    available_days,
    risk_level
FROM product_stockout_monitoring
WHERE product_sku = 'TEST-SKU-001'
  AND snapshot_date = CURDATE();
```

### 3. 查询高风险产品

```sql
-- 查询有断货风险的产品
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
ORDER BY available_days ASC;
```

## 测试 / Testing

### 单元测试

1. **DomesticInventoryServiceTest**: 测试国内仓库存服务
   - 查询国内仓库存
   - 按SKU查询
   - 数据验证
   - 默认值处理

2. **RegionalWarehouseParamsTest**: 测试区域仓参数模型
   - 默认值
   - 提前期计算
   - Getter/Setter
   - 不同区域仓参数

### 集成测试建议

1. 测试JH_LX模式的库存合并
2. 测试FBA模式的数据隔离
3. 测试国内仓库存共享
4. 测试ETL的幂等性
5. 测试不同区域仓参数的应用

## 文档 / Documentation

创建的文档：
1. **PRODUCT_STOCKOUT_IMPLEMENTATION_GUIDE.md**: 详细实施指南
   - 业务模式隔离说明
   - 数据源映射
   - 字段计算公式
   - SQL查询示例
   - 性能优化建议

2. **stockout_monitoring_etl_procedure.sql**: ETL存储过程
   - 完整的存储过程代码
   - 详细注释
   - 使用示例

3. **stockout_monitoring_schema.sql**: 数据库表结构
   - 表定义
   - 索引
   - 示例数据

## 性能考虑 / Performance Considerations

### 索引优化
- `product_sku`, `regional_warehouse_id`, `business_mode`, `snapshot_date` 联合索引
- `company_id`, `warehouse_id` 单独索引
- 发货单表的 `status`, `ship_date` 索引

### 批量处理
- 使用批量插入
- 批次大小：1000条/批次
- 事务管理

### 分区策略
- 按 `snapshot_date` 分区
- 保留3-6个月数据
- 历史数据归档

### 缓存策略
- 区域仓配置数据缓存
- 区域仓-仓库绑定关系缓存
- 区域仓参数配置缓存

## 总结 / Summary

本次实施完成了以下核心功能：

1. ✅ 业务模式隔离（JH_LX合并 vs FBA独立）
2. ✅ 国内仓库存共享机制
3. ✅ 区域仓参数配置
4. ✅ 增强的数据模型和数据库表结构
5. ✅ 完整的ETL存储过程
6. ✅ 详细的文档和使用示例
7. ✅ 单元测试覆盖

实施遵循了最小改动原则，所有变更都是增量式的，不影响现有功能。系统具有良好的可扩展性和维护性。

## 下一步建议 / Next Steps

1. 部署数据库变更（表结构和存储过程）
2. 配置区域仓参数数据
3. 建立SKU映射关系（local_sku -> product_sku）
4. 配置定时任务执行ETL
5. 建立监控告警机制
6. 性能测试和优化
7. 用户界面集成

## 相关文档 / Related Documents

- [PRODUCT_STOCKOUT_IMPLEMENTATION_GUIDE.md](PRODUCT_STOCKOUT_IMPLEMENTATION_GUIDE.md) - 详细实施指南
- [STOCKOUT_MONITORING_GUIDE.md](STOCKOUT_MONITORING_GUIDE.md) - 原有监控模型指南
- [stockout_monitoring_schema.sql](stockout_monitoring_schema.sql) - 数据库表结构
- [stockout_monitoring_etl_procedure.sql](stockout_monitoring_etl_procedure.sql) - ETL存储过程
