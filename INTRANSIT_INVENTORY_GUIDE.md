# 在途库存按仓库维度聚合实现指南
# In-Transit Inventory Aggregation by Warehouse Dimension Implementation Guide

## 概述 / Overview

本文档说明了基于产品的断货点监控模型中，在途库存按仓库维度聚合的计算口径与实现方案。

该方案支持两种模式：
1. **区域仓模式（REGIONAL）**：JH发货单 + LX海外仓发货单
2. **FBA模式（FBA）**：FBA平台发货单

## 数据源表结构 / Data Source Table Structure

### 1. JH发货单（鲸汇系统）

**主表**：`amf_jh_shipment`
- `id`: 发货单ID
- `warehouse_id`: 目的仓库ID
- `warehouse_name`: 目的仓库名称
- `shipment_date`: 发货日期
- `status`: 发货单状态（0=进行中，2=已完成）
- `ship_qty`: 总发货数量
- `receive_qty`: 总收货数量

**明细表**：`amf_jh_shipment_sku`
- `property_shipment_id`: 关联主表ID
- `shop_id`: 店铺ID
- `warehouse_sku`: 仓库SKU编码
- `ship_qty`: SKU发货数量
- `receive_qty`: SKU收货数量

### 2. LX海外仓发货单（领星系统）

**主表**：`amf_lx_shipment` (也称为 amf_lx_owmsshipment)
- `id`: 发货单ID
- `s_wid`: 发货仓库ID
- `r_wid`: 收货仓库ID（目的仓库）
- `r_wname`: 收货仓库名称
- `status`: 状态（50=待收货）
- `real_delivery_time`: 实际发货时间戳
- `estimated_time`: 预计到达时间

**明细表**：`amf_lx_shipment_products`
- `shipment_id`: 关联主表ID
- `sku`: SKU编码
- `stock_num`: 库存数量（发货数量）
- `receive_num`: 已收货数量
- `s_wid`: 发货仓库ID

### 3. FBA发货单（亚马逊FBA）

**主表**：`amf_lx_fbashipment`
- `id`: 发货单ID
- `wid`: 仓库ID
- `destination_fulfillment_center_id`: 目的FBA仓库ID
- `shipment_time`: 发货日期
- `status`: 发货单状态
- `is_delete`: 是否删除（0=否）

**明细表**：`amf_lx_fbashipment_item`
- `shipment_id`: 关联主表ID
- `sku`: 卖家SKU
- `num`: 发货数量
- `shipment_status`: 发货状态（WORKING=进行中，CLOSED=已关闭）
- `wid`: 仓库ID
- `destination_fulfillment_center_id`: 目的FBA仓库ID

## 在途库存计算口径 / In-Transit Inventory Calculation Criteria

### 1. 区域仓模式 - JH发货单在途库存

**聚合维度**：`(warehouse_id, sku_code)`

**筛选条件**：
- `shipment_date <= monitor_date`（发货日期小于等于监控日期）
- `status != 2`（状态不为已完成）
- `(ship_qty - receive_qty) > 0`（未收齐）

**计算公式**：
```sql
SELECT 
  s.warehouse_id,
  s.warehouse_name,
  sku.warehouse_sku as sku_code,
  SUM(sku.ship_qty - IFNULL(sku.receive_qty, 0)) as open_intransit_qty,
  COUNT(DISTINCT s.id) as shipment_count,
  MIN(s.shipment_date) as earliest_shipment_date
FROM amf_jh_shipment s
INNER JOIN amf_jh_shipment_sku sku ON s.id = sku.property_shipment_id
WHERE s.shipment_date <= :monitor_date
  AND s.status != 2
  AND (sku.ship_qty - IFNULL(sku.receive_qty, 0)) > 0
GROUP BY s.warehouse_id, s.warehouse_name, sku.warehouse_sku
```

**说明**：
- 以`warehouse_id`为目的仓库
- `warehouse_sku`需映射到标准产品SKU编码
- 在途数量 = 发货数量 - 已收货数量

### 2. 区域仓模式 - LX OWMS海外仓发货单在途库存

**聚合维度**：`(r_wid, sku)`

**筛选条件**：
- `real_delivery_time <= monitor_date`（实际发货时间小于等于监控日期）
- `status = 50`（待收货状态）
- `(stock_num - receive_num) > 0`（未收齐）

**计算公式**：
```sql
SELECT 
  s.r_wid as warehouse_id,
  s.r_wname as warehouse_name,
  p.sku as sku_code,
  SUM(p.stock_num - IFNULL(p.receive_num, 0)) as open_intransit_qty,
  COUNT(DISTINCT s.id) as shipment_count,
  MIN(FROM_UNIXTIME(s.real_delivery_time)) as earliest_shipment_date,
  MAX(s.estimated_time) as latest_expected_arrival_date
FROM amf_lx_shipment s
INNER JOIN amf_lx_shipment_products p ON s.id = p.shipment_id
WHERE FROM_UNIXTIME(s.real_delivery_time) <= :monitor_date
  AND s.status = 50
  AND (p.stock_num - IFNULL(p.receive_num, 0)) > 0
GROUP BY s.r_wid, s.r_wname, p.sku
```

**说明**：
- 以`r_wid`为收货仓库（目的仓库）
- `real_delivery_time`为Unix时间戳，需转换为日期
- `status = 50`表示待收货状态

### 3. FBA模式 - FBA发货单在途库存

**聚合维度**：`(wid, destination_fulfillment_center_id, sku)`

**筛选条件**：
- `shipment_time <= monitor_date`（发货时间小于等于监控日期）
- `shipment_status = 'WORKING'`（进行中状态）
- `is_delete = 0`（未删除）
- `num > 0`（数量大于0）

**计算公式**：
```sql
SELECT 
  item.wid,
  item.destination_fulfillment_center_id,
  item.sku as sku_code,
  SUM(item.num) as open_intransit_qty,
  COUNT(DISTINCT s.id) as shipment_count,
  MIN(s.shipment_time) as earliest_shipment_date,
  MAX(s.expected_arrival_date) as latest_expected_arrival_date
FROM amf_lx_fbashipment s
INNER JOIN amf_lx_fbashipment_item item ON s.id = item.shipment_id
WHERE s.shipment_time <= :monitor_date
  AND item.shipment_status = 'WORKING'
  AND s.is_delete = 0
  AND item.num > 0
GROUP BY item.wid, item.destination_fulfillment_center_id, item.sku
```

**说明**：
- `wid`为发货仓库，`destination_fulfillment_center_id`为目的FBA仓库
- 使用`destination_fulfillment_center_id`映射到逻辑仓库ID
- `shipment_status = 'WORKING'`表示在途未完成

## 仓库映射配置 / Warehouse Mapping Configuration

为统一不同系统的仓库标识，需要建立仓库映射表：

**表名**：`dw_warehouse_mapping`

**字段说明**：
- `warehouse_id`: 统一仓库ID（数据仓库主键）
- `warehouse_code`: 仓库编码
- `warehouse_name`: 仓库名称
- `warehouse_type`: 仓库类型（FBA/REGIONAL）
- `source_system`: 来源系统（JH/LX）
- `source_warehouse_id`: 源系统仓库ID
- `source_warehouse_name`: 源系统仓库名称

**示例配置**：
```sql
INSERT INTO dw_warehouse_mapping VALUES
  -- JH系统仓库
  (1001, 'CAJW06', 'CAJW06仓', 'REGIONAL', 'JH', 11129, 'CAJW06', 'US_WEST', 'US'),
  (1002, 'CG-MJJ', 'CG仓-Meijiajia', 'REGIONAL', 'JH', 10568, 'CG仓-Meijiajia', 'US_EAST', 'US'),
  
  -- LX系统欧洲仓
  (2001, 'EUWE', '欧洲DE EUWE', 'REGIONAL', 'LX', 9488, '欧洲DE EUWE', 'EU', 'DE'),
  (2002, 'UKNH02', '欧洲UK UKNH02', 'REGIONAL', 'LX', 9487, '欧洲UK UKNH02', 'EU', 'UK'),
  
  -- FBA仓
  (3001, 'FBA_US', 'FBA美国仓', 'FBA', 'LX', 4000, 'FBA', 'US', 'US');
```

## 现有库存按仓库维度聚合 / Current Inventory Aggregation by Warehouse

### 1. 区域仓模式

**数据源**：
- JH海外仓库存：`amf_jh_warehouse_stock`
  - 字段：`warehouse_name`, `warehouse_sku`, `out_available_qty`
- LX海外仓库存：`amf_lx_warehouse_stock`
  - 字段：`wid`, `sku`, `product_valid_num`

**聚合逻辑**：
```sql
-- JH海外仓库存
SELECT 
  wm.warehouse_id,
  wm.warehouse_code,
  wm.warehouse_name,
  'REGIONAL' as mode,
  jws.warehouse_sku as sku_code,
  SUM(jws.out_available_qty) as available_quantity
FROM amf_jh_warehouse_stock jws
INNER JOIN dw_warehouse_mapping wm 
  ON wm.source_system = 'JH' 
  AND wm.source_warehouse_name = jws.warehouse_name
WHERE jws.out_available_qty > 0
GROUP BY wm.warehouse_id, wm.warehouse_code, wm.warehouse_name, jws.warehouse_sku

UNION ALL

-- LX海外仓库存
SELECT 
  wm.warehouse_id,
  wm.warehouse_code,
  wm.warehouse_name,
  'REGIONAL' as mode,
  lws.sku as sku_code,
  SUM(lws.product_valid_num) as available_quantity
FROM amf_lx_warehouse_stock lws
INNER JOIN dw_warehouse_mapping wm 
  ON wm.source_system = 'LX' 
  AND wm.source_warehouse_id = lws.wid
WHERE lws.product_valid_num > 0
GROUP BY wm.warehouse_id, wm.warehouse_code, wm.warehouse_name, lws.sku
```

### 2. FBA模式

**数据源**：
- FBA平台库存：`amf_lx_fbadetail`
  - 字段：`seller_sku`, `available_total`

**聚合逻辑**：
```sql
SELECT 
  wm.warehouse_id,
  wm.warehouse_code,
  wm.warehouse_name,
  'FBA' as mode,
  fba.seller_sku as sku_code,
  SUM(fba.available_total) as available_quantity
FROM amf_lx_fbadetail fba
INNER JOIN dw_warehouse_mapping wm 
  ON wm.warehouse_type = 'FBA'
WHERE fba.available_total > 0
GROUP BY wm.warehouse_id, wm.warehouse_code, wm.warehouse_name, fba.seller_sku
```

## 模式隔离 / Mode Isolation

在数据仓库的`dw_fact_inventory`表和`dw_intransit_inventory`表中，通过`mode`字段区分：
- `mode = 'REGIONAL'`：区域仓模式（JH + LX OWMS）
- `mode = 'FBA'`：FBA模式

这样可以：
1. 独立计算各模式的库存和在途库存
2. 支持按模式生成不同的备货建议
3. 便于分析不同模式的库存周转效率

## 使用示例 / Usage Example

### Java代码示例

```java
// 创建在途库存服务
IntransitInventoryService intransitService = new IntransitInventoryService();

// 设置监控日期
LocalDate monitorDate = LocalDate.now();

// 加载仓库映射
Map<Long, WarehouseMapping> warehouseMapping = loadWarehouseMappings();

// 计算所有在途库存
Map<String, IntransitInventory> allIntransit = 
    intransitService.aggregateAllIntransit(monitorDate, warehouseMapping);

// 获取特定仓库和SKU的在途库存
Long warehouseId = 1001L;
String skuCode = "WL-FZ-39-W";
Integer intransitQty = intransitService.getIntransitQuantity(
    warehouseId, skuCode, monitorDate, warehouseMapping);

System.out.println("仓库 " + warehouseId + " SKU " + skuCode + 
    " 的在途库存数量：" + intransitQty);

// 按模式查询
List<IntransitInventory> regionalIntransit = 
    intransitService.getIntransitByMode("REGIONAL", monitorDate, warehouseMapping);

List<IntransitInventory> fbaIntransit = 
    intransitService.getIntransitByMode("FBA", monitorDate, warehouseMapping);
```

### SQL查询示例

```sql
-- 查询某仓库某SKU的总在途库存（所有来源）
SELECT 
  warehouse_id,
  warehouse_name,
  sku_code,
  mode,
  SUM(intransit_quantity) as total_intransit_qty,
  SUM(shipment_count) as total_shipment_count,
  MIN(earliest_shipment_date) as earliest_shipment,
  MAX(latest_expected_arrival_date) as latest_arrival
FROM dw_intransit_inventory
WHERE date_key = 20260203
  AND warehouse_id = 1001
  AND sku_code = 'WL-FZ-39-W'
GROUP BY warehouse_id, warehouse_name, sku_code, mode;

-- 查询区域仓模式的在途库存汇总
SELECT 
  mode,
  warehouse_id,
  warehouse_name,
  COUNT(DISTINCT sku_code) as sku_count,
  SUM(intransit_quantity) as total_intransit_qty
FROM dw_intransit_inventory
WHERE date_key = 20260203
  AND mode = 'REGIONAL'
GROUP BY mode, warehouse_id, warehouse_name
ORDER BY total_intransit_qty DESC;
```

## 注意事项 / Important Notes

1. **时间戳转换**：LX系统的`real_delivery_time`是Unix时间戳（秒），需要使用`FROM_UNIXTIME()`函数转换

2. **状态码含义**：
   - JH: `status = 0`（进行中），`status = 2`（已完成）
   - LX: `status = 50`（待收货）
   - FBA: `shipment_status = 'WORKING'`（进行中），`'CLOSED'`（已关闭）

3. **NULL值处理**：收货数量可能为NULL，计算时需使用`IFNULL(receive_qty, 0)`

4. **SKU映射**：不同系统的SKU字段名称不同：
   - JH: `warehouse_sku`
   - LX: `sku`
   - FBA: `sku` 或 `seller_sku`

5. **仓库映射**：需要提前配置好仓库映射表，确保各系统的仓库ID能正确映射到统一的warehouse_id

6. **数据更新频率**：建议每日更新在途库存数据，确保断货监控的及时性

## 相关文档 / Related Documentation

- [备货模型引擎使用指南](STOCKING_MODEL_GUIDE.md)
- [数据仓库私有化部署方案](DATA_WAREHOUSE_GUIDE.md)
- [断货点分析服务](../src/main/java/com/buyi/ruleengine/service/StockoutPointService.java)
