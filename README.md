# buyi_cloud

## Database Schema & Integration

This repository contains the database schema and integration logic for the Buyi Cloud platform.

### AMF → COS Data Synchronization (AMF → COS 数据同步)

#### JH In-Transit Stock Sync (鲸汇在途库存同步)

**Purpose / 用途:**
- Synchronizes in-transit (not yet arrived) shipment quantities from AMF JH (Jinghui) shipment data to COS goods SKU in-transit stock table.
- 将AMF鲸汇（JH）系统中的在途（尚未到达）发货数量同步到COS商品SKU在途库存表。

**Stored Procedure / 存储过程:**
```sql
CALL sp_sync_jh_intransit_stock_to_cos(p_company_id, p_days);
```

**Parameters / 参数:**
- `p_company_id` (BIGINT): Company ID filter. Use NULL to sync all companies. / 企业ID筛选。使用NULL同步所有企业。
- `p_days` (INT): Number of days to look back for shipment data. / 回溯天数用于获取发货数据。

**Example Usage / 使用示例:**
```sql
-- Sync last 30 days of in-transit stock for all companies
-- 同步所有企业最近30天的在途库存
CALL sp_sync_jh_intransit_stock_to_cos(NULL, 30);

-- Sync last 60 days for company ID 12345
-- 同步企业ID 12345最近60天的数据
CALL sp_sync_jh_intransit_stock_to_cos(12345, 60);
```

**Data Sources / 数据源:**
- `amf_jh_shipment`: JH shipment master table / JH发货主表
- `amf_jh_shipment_sku`: JH shipment SKU detail table / JH发货SKU明细表

**Target Table / 目标表:**
- `cos_goods_sku_intransit_stock`: COS goods SKU in-transit stock table / COS商品SKU在途库存表

**Mapping Logic / 映射逻辑:**
1. **SKU Mapping / SKU映射:**
   - Maps `amf_jh_shipment_sku.warehouse_sku` to `cos_goods_sku.id`
   - 将 `amf_jh_shipment_sku.warehouse_sku` 映射到 `cos_goods_sku.id`
   - Matches via `cos_goods_sku.supplier_sku_code` or `cos_goods_sku.sku_code`
   - 通过 `cos_goods_sku.supplier_sku_code` 或 `cos_goods_sku.sku_code` 匹配

2. **Shop Mapping / 店铺映射:**
   - Maps `amf_jh_shipment_sku.shop_id` to `cos_shop.id`
   - 将 `amf_jh_shipment_sku.shop_id` 映射到 `cos_shop.id`
   - Matches via `cos_shop.platform_shop_id`
   - 通过 `cos_shop.platform_shop_id` 匹配

3. **In-Transit Definition / 在途定义:**
   - Records where `ship_qty > receive_qty` (not fully received)
   - 发货数量大于收货数量的记录（未完全收货）

**Monitoring & Logs / 监控与日志:**

View sync history: / 查看同步历史：
```sql
SELECT * FROM cos_sync_jh_intransit_log 
ORDER BY sync_time DESC 
LIMIT 10;
```

View unmapped records: / 查看未映射的记录：
```sql
SELECT * FROM cos_sync_jh_unmapped_records 
WHERE sync_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
ORDER BY sync_time DESC;
```

View aggregated in-transit stock summary: / 查看汇总的在途库存：
```sql
SELECT * FROM v_jh_intransit_stock_summary 
WHERE company_id = 12345;
```

**Features / 特性:**
- ✅ Idempotent execution (can be run multiple times safely) / 幂等执行（可安全多次运行）
- ✅ Tracks unmapped SKUs and shops for data quality / 跟踪未映射的SKU和店铺以保证数据质量
- ✅ Comprehensive sync logging / 全面的同步日志
- ✅ Helper view for quick analysis / 辅助视图用于快速分析
- ✅ Performance optimized with indexes / 通过索引优化性能

---

## Database Structure / 数据库结构

See `buyi_platform_dev.sql` for complete schema definition. / 完整的数据库架构定义请参见 `buyi_platform_dev.sql`。
