# buyi_cloud

## Database Schema and Sync Procedures | 数据库架构和同步程序

This repository contains the database schema and synchronization procedures for the Buyi Cloud platform.

本仓库包含买衣云平台的数据库架构和同步程序。

---

## AMF(JH) → COS Sync Tasks | AMF(鲸汇) → COS 同步任务

### JH In-Transit Stock Sync | 鲸汇在途库存同步

**Purpose | 目的:**
Synchronize not-yet-arrived JH (AMF) shipment quantities into COS in-transit stock table.

将尚未到货的鲸汇(AMF)发货数量同步到COS在途库存表中。

**Stored Procedure | 存储过程:**
```sql
CALL sp_sync_jh_intransit_stock_to_cos(p_company_id, p_days);
```

**Parameters | 参数:**
- `p_company_id` (BIGINT): Company ID to sync for | 要同步的企业ID
- `p_days` (INT): Number of days to look back for updated shipments | 回溯天数，用于查找更新的发货单

**Functionality | 功能:**

1. **Data Source | 数据源:**
   - Source tables: `amf_jh_shipment`, `amf_jh_shipment_sku`
   - 源表：`amf_jh_shipment` (发货主表), `amf_jh_shipment_sku` (发货明细表)

2. **In-Transit Calculation | 在途计算:**
   - Only processes line items where `ship_qty > IFNULL(receive_qty, 0)`
   - 仅处理 `发货数量 > 收货数量` 的明细行

3. **Shop Mapping | 店铺映射:**
   - Maps JH shop to COS shop using TWO criteria:
     - `cos_shop.platform_shop_id = amf_jh_shipment_sku.shop_id`
     - `cos_shop.channel_name = amf_jh_shop.shop_show_name`
   - 使用两个条件映射鲸汇店铺到COS店铺：
     - `cos_shop.platform_shop_id = amf_jh_shipment_sku.shop_id`
     - `cos_shop.channel_name = amf_jh_shop.shop_show_name`

4. **SKU Mapping | SKU映射:**
   - Primary match: `cos_goods_sku.supplier_sku_code = warehouse_sku`
   - Fallback match: `cos_goods_sku.sku_code = warehouse_sku`
   - Tie-breaker: Uses `MAX(id)` when multiple matches found
   - 主要匹配：`cos_goods_sku.supplier_sku_code = warehouse_sku`
   - 备用匹配：`cos_goods_sku.sku_code = warehouse_sku`
   - 冲突解决：多个匹配时使用 `MAX(id)`

5. **Target Table | 目标表:**
   - Table: `cos_goods_sku_intransit_stock`
   - Idempotency: Uses unique key on (company_id, shop_id, sku_id, external_id, shipment_date, deleted)
   - Status: Sets `shipment_status = 0` (in-transit)
   - 表：`cos_goods_sku_intransit_stock`
   - 幂等性：使用唯一键 (company_id, shop_id, sku_id, external_id, shipment_date, deleted)
   - 状态：设置 `shipment_status = 0` (在途)

6. **Error Logging | 错误日志:**
   - Unmapped records are logged in `cos_intransit_stock_sync_log`
   - Reason codes:
     - `SHOP_NOT_MAPPED`: JH shop not found in COS
     - `SKU_NOT_MAPPED`: Warehouse SKU not found in COS
     - `SKU_MULTI_MATCH`: Multiple SKU matches (warning, uses MAX(id))
   - 未映射的记录记录在 `cos_intransit_stock_sync_log`
   - 原因代码：
     - `SHOP_NOT_MAPPED`: COS中未找到鲸汇店铺
     - `SKU_NOT_MAPPED`: COS中未找到仓库SKU
     - `SKU_MULTI_MATCH`: 多个SKU匹配（警告，使用MAX(id)）

**Usage Example | 使用示例:**
```sql
-- Sync last 7 days of shipments for company 1001
-- 同步企业1001最近7天的发货单
CALL sp_sync_jh_intransit_stock_to_cos(1001, 7);

-- Sync last 30 days of shipments
-- 同步最近30天的发货单
CALL sp_sync_jh_intransit_stock_to_cos(1001, 30);
```

**Monitoring | 监控:**
```sql
-- Check sync logs for errors
-- 查看同步错误日志
SELECT reason_code, COUNT(*) as count 
FROM cos_intransit_stock_sync_log 
WHERE create_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
GROUP BY reason_code;

-- View unmapped shops
-- 查看未映射的店铺
SELECT DISTINCT jh_shop_id, jh_shop_show_name, remark
FROM cos_intransit_stock_sync_log 
WHERE reason_code = 'SHOP_NOT_MAPPED'
  AND create_time >= DATE_SUB(NOW(), INTERVAL 1 DAY);

-- View unmapped SKUs
-- 查看未映射的SKU
SELECT DISTINCT warehouse_sku, remark
FROM cos_intransit_stock_sync_log 
WHERE reason_code = 'SKU_NOT_MAPPED'
  AND create_time >= DATE_SUB(NOW(), INTERVAL 1 DAY);
```

---

## Schema Files | 架构文件

- `buyi_platform_dev.sql`: Main database schema with tables, procedures, and functions | 主数据库架构（包含表、存储过程和函数）

---

## Contributing | 贡献

When adding new sync procedures, please ensure:
- Add appropriate error logging
- Implement idempotency mechanisms
- Update this README with bilingual documentation

添加新的同步程序时，请确保：
- 添加适当的错误日志
- 实现幂等性机制
- 更新本README并提供中英文文档

---