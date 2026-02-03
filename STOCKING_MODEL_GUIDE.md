# 备货模型引擎使用指南
# Stocking Model Engine User Guide

## 概述 / Overview

本备货引擎提供三种备货模型，用于智能计算商品备货需求：

1. **月度备货模型 (Monthly Stocking Model)** - 基于SABC分类的月度备货计划
2. **每周固定备货模型 (Weekly Fixed Stocking Model)** - 固定7天周期的备货
3. **断货点临时备货模型 (Stockout Emergency Stocking Model)** - 基于断货风险的紧急备货

**新增功能**：
- ✨ **仓库维度在途库存计算** - 支持按仓库维度聚合JH、LX OWMS和FBA发货单的在途库存
- ✨ **模式隔离** - 区分区域仓模式（REGIONAL）和FBA模式的库存计算
- ✨ **多仓库监控** - 同时监控多个仓库的断货风险
- 详见[在途库存计算指南](INTRANSIT_INVENTORY_GUIDE.md)

## 核心功能 / Core Features

### 1. 月度备货模型

**适用场景**：适合A、B、C类商品的常规月度备货计划

**计算逻辑**：
- 基于SABC分类定义不同的安全库存天数和备货浮动系数
- 使用加权平均日销计算（30天20%、15天30%、7天50%）
- 备货量 = 日均销 × (月度周期30天 + 安全库存天数) × 备货浮动系数 - 当前库存

**SABC分类默认参数**：
| 分类 | 名称 | 安全库存天数 | 备货浮动系数 |
|------|------|-------------|-------------|
| S | 畅销品 | 45天 | 1.3 |
| A | 次畅销品 | 35天 | 1.2 |
| B | 一般商品 | 25天 | 1.1 |
| C | 滞销品 | 15天 | 1.0 |

### 2. 每周固定备货模型

**适用场景**：适合S类畅销品，保持高周转率

**计算逻辑**：
- 固定备货周期7天
- 基于历史30天、15天、7天数据计算加权平均日销
- 排除噪点值（超过3倍标准差的数据点）
- 权重分配：20% × 30天 + 30% × 15天 + 50% × 7天
- 备货量 = 日均销 × 7 × 备货浮动系数

### 3. 断货点临时备货模型

**适用场景**：检测到断货风险时的紧急备货

**计算逻辑**：
- 基于现有断货点分析服务预测未来断货风险
- **支持按仓库维度计算在途库存**（详见[在途库存计算指南](INTRANSIT_INVENTORY_GUIDE.md)）
- 考虑不同发货区域的海运时间差异
- 根据风险等级和紧急程度计算备货量
- 紧急备货系数：1.2

**在途库存计算**：
- **区域仓模式**：聚合JH发货单和LX OWMS海外仓发货单
  - JH：按warehouse_id和sku聚合，筛选status != 2的未完成发货单
  - LX OWMS：按r_wid和sku聚合，筛选status = 50的待收货发货单
- **FBA模式**：聚合FBA发货单
  - 按wid/destination_fulfillment_center_id和sku聚合
  - 筛选shipment_status = 'WORKING'的在途发货单

**发货区域配置**：
| 区域 | 名称 | 海运时间 | 监控提前天数 |
|------|------|---------|-------------|
| US_WEST | 美西 | 35天 | 25天 |
| US_EAST | 美东 | 50天 | 35天 |
| US_CENTRAL | 美中 | 45天 | 32天 |
| US_SOUTH | 美南 | 48天 | 34天 |

## 使用示例 / Usage Examples

### 基本使用

```java
// 创建备货引擎
StockingEngine engine = new StockingEngine();

// 配置商品信息
ProductStockConfig config = new ProductStockConfig();
config.setProductId(1001L);
config.setSku("SKU-001");
config.setProductName("测试产品");
config.setCategory(ProductCategory.S);
config.setShippingRegion(ShippingRegion.US_EAST);
config.setCurrentInventory(1000);
config.setInTransitInventory(500);
config.setProductionDays(20);

// 配置销售历史
SalesHistoryData salesHistory = new SalesHistoryData();
salesHistory.setProductId(1001L);
salesHistory.setSku("SKU-001");
salesHistory.setTotalSales30Days(3000);
salesHistory.setTotalSales15Days(1500);
salesHistory.setTotalSales7Days(700);

// 计算月度备货
StockingResult result = engine.calculateMonthlyStocking(config, salesHistory, LocalDate.now());

// 输出结果
System.out.println("建议备货量: " + result.getFinalQuantity());
System.out.println("建议发货日期: " + result.getSuggestedShipDate());
System.out.println("预计到货日期: " + result.getExpectedArrivalDate());
```

### 综合备货建议

```java
// 使用综合计算，自动检测断货风险并选择最优模型
StockingResult result = engine.calculateStocking(
    config, 
    salesHistory, 
    existingShipments,  // 已有发货计划
    StockingModelType.MONTHLY,  // 优先使用的模型
    LocalDate.now()
);

// 检查是否为紧急备货
if (Boolean.TRUE.equals(result.getIsEmergency())) {
    System.out.println("紧急！" + result.getUrgencyNote());
}
```

### 获取推荐备货建议

```java
// 根据商品分类自动选择最合适的备货模型
StockingResult result = engine.getRecommendedStocking(
    config, 
    salesHistory, 
    null,  // 无已有发货计划
    LocalDate.now()
);
```

### 批量计算

```java
List<ProductStockConfig> products = loadProducts();
Map<String, SalesHistoryData> salesHistoryMap = loadSalesHistory();

List<StockingResult> results = engine.batchCalculateStocking(
    products,
    salesHistoryMap,
    null,  // 发货计划映射
    StockingModelType.MONTHLY,
    LocalDate.now()
);

for (StockingResult result : results) {
    System.out.println("SKU: " + result.getSku() + 
        ", 备货量: " + result.getFinalQuantity());
}
```

## 自定义参数 / Custom Parameters

### 覆盖默认安全库存天数

```java
config.setSafetyStockDays(60);  // 覆盖分类默认值
```

### 覆盖默认备货浮动系数

```java
config.setStockingCoefficient(BigDecimal.valueOf(1.5));  // 覆盖分类默认值
```

### 设置最小/最大订货量

```java
config.setMinOrderQuantity(100);   // 最小订货量
config.setMaxOrderQuantity(10000); // 最大订货量
```

## API 参考 / API Reference

### StockingEngine

| 方法 | 描述 |
|------|------|
| `calculateMonthlyStocking()` | 计算月度备货 |
| `calculateWeeklyStocking()` | 计算每周固定备货 |
| `evaluateStockoutRisk()` | 评估断货风险并计算紧急备货 |
| `calculateStocking()` | 综合计算（自动检测风险） |
| `getRecommendedStocking()` | 获取推荐备货建议 |
| `getAllModelResults()` | 获取所有模型的计算结果（用于比较） |
| `batchCalculateStocking()` | 批量计算备货 |

### StockingResult

| 字段 | 描述 |
|------|------|
| `productId` | 商品ID |
| `sku` | 商品SKU |
| `modelType` | 备货模型类型 |
| `dailyAvgSales` | 日均销量 |
| `recommendedQuantity` | 建议备货量 |
| `adjustedQuantity` | 调整后备货量 |
| `finalQuantity` | 最终备货量 |
| `suggestedShipDate` | 建议发货日期 |
| `expectedArrivalDate` | 预计到货日期 |
| `isEmergency` | 是否紧急备货 |
| `urgencyNote` | 紧急程度说明 |
| `stockoutRiskDays` | 断货风险天数 |
| `reason` | 备货原因说明 |

## 数据库表结构 / Database Schema

参见 `stocking_model_schema.sql` 文件，包含以下表：

1. `product_stock_config` - 商品备货配置表
2. `sales_history_summary` - 销售历史汇总表
3. `daily_sales_detail` - 每日销售明细表
4. `stocking_result` - 备货计算结果表
5. `shipment_plan` - 发货计划表
6. `shipping_region_config` - 发货区域配置表
7. `sabc_category_config` - SABC分类配置表
8. `stocking_execution_log` - 备货模型执行日志表

## 注意事项 / Notes

1. **噪点排除**：对于小样本数据（如7天数据），3σ法则可能不够敏感，建议结合更多历史数据
2. **紧急备货优先**：当检测到紧急断货风险时，引擎会自动优先返回紧急备货建议
3. **区域差异**：不同发货区域的海运时间不同，会影响断货监控点和建议发货日期
4. **自动备货开关**：可通过 `autoStockingEnabled` 字段控制是否纳入自动备货计算
5. **在途库存计算**：系统支持按仓库维度聚合在途库存，详见[在途库存计算指南](INTRANSIT_INVENTORY_GUIDE.md)
6. **模式隔离**：区域仓模式（JH+LX）和FBA模式使用独立的在途库存计算和库存聚合逻辑
