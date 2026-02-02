# 存储过程说明: sp_sync_cos_goods_sku_params_daily

## 功能概述

该存储过程用于同步商品SKU参数，包括销量、库存等关键指标，支持三种店铺类型：
- **JH (聚货)店铺**: 通过鲸汇系统获取订单和库存数据
- **FBA (亚马逊物流)店铺**: 通过领星系统获取亚马逊FBA订单和库存数据
- **MP (多平台)店铺**: 通过领星系统获取多平台订单数据

## 核心特性

1. **幂等性设计**: 支持多次执行，使用UPSERT模式确保数据一致性
2. **加权日均销量**: 采用科学的加权算法计算日均销量
3. **多店铺类型支持**: 统一处理JH、FBA、MP三种店铺类型
4. **精确库存同步**: FBA使用最新同步日期的库存，JH使用最新海外仓库存
5. **健壮的数据处理**: 完善的异常处理和数据类型转换

## 店铺映射规则

### JH店铺映射
```
amf_jh_shop.id -> cos_shop.platform_shop_id -> cos_shop.id
```
- 使用JH店铺ID直接匹配cos_shop的platform_shop_id
- 只处理status=1（正常状态）的店铺

### FBA店铺映射
```
amf_lx_shop.store_id -> cos_shop.external_id
```
- 使用领星店铺的store_id匹配cos_shop的external_id
- 使用MIN(id)进行唯一化处理
- 排除type='test'的测试店铺
- 只处理status=1（启用状态）的店铺
- 销量日期使用shipment_date_utc字段

### MP店铺映射
```
amf_lx_mporders.store_id -> cos_shop.external_id
```
- 使用订单中的store_id匹配cos_shop的external_id
- 使用MIN(id)进行唯一化处理
- 排除type='test'的测试店铺
- 只处理is_delete=0的订单
- 销量日期使用global_create_time字段（需先解析为DATETIME）

## 销量计算规则

### 时间范围
- **7天销量**: 最近7天（不含当天）
- **15天销量**: 最近15天（不含当天）
- **30天销量**: 最近30天（不含当天）

### 日均销量加权公式
```
日均销量 = (7天销量/7) × 0.5 + (15天销量/15) × 0.3 + (30天销量/30) × 0.2
```

这个公式的设计考虑了：
- 近期销量权重更高（7天占50%）
- 中期销量次之（15天占30%）
- 长期销量作为参考（30天占20%）

### 各店铺类型的销量日期字段
- **JH店铺**: 使用 `delivery_time` (发货时间)
- **FBA店铺**: 使用 `shipment_date_utc` (UTC发货时间)
- **MP店铺**: 使用 `global_create_time` (全局创建时间，需解析为DATETIME)

## 库存计算规则

### FBA库存
- 使用 `amf_lx_fbadetail` 表的 `available_total` 字段
- 按照 `sid` (店铺ID) 和 `seller_sku` 分组
- 取最大 `sync_date` 的记录（最新同步的库存数据）
- 确保数据是最新的库存状态

### JH库存
- 使用 `amf_jh_shop_warehouse_stock` 表的 `available_qty` 字段
- 按照 `shop_id` 和 `warehouse_sku` 分组
- 汇总所有仓库的可用库存
- 只统计 `available_qty > 0` 的记录

### MP库存
- 目前MP店铺暂无专门的库存数据源
- 库存字段设置为0

## 数据粒度保证

存储过程确保以下粒度的唯一性：
```
company_id + shop_id + sku_id + monitor_date + deleted = 0
```

这意味着对于同一个公司、同一个店铺、同一个SKU、同一个监控日期，只会有一条有效记录（deleted=0）。

## 使用方法

### 基本用法

#### 1. 创建存储过程
```sql
SOURCE /path/to/sp_sync_cos_goods_sku_params_daily.sql;
```

#### 2. 使用当前日期执行同步
```sql
CALL sp_sync_cos_goods_sku_params_daily(NULL);
```

#### 3. 指定日期执行同步
```sql
CALL sp_sync_cos_goods_sku_params_daily('2026-02-01');
```

### 定时任务配置

建议配置每日定时任务自动执行：

```sql
-- 方式1: 使用MySQL Event Scheduler
CREATE EVENT IF NOT EXISTS evt_sync_cos_goods_sku_params_daily
ON SCHEDULE EVERY 1 DAY
STARTS CONCAT(CURDATE() + INTERVAL 1 DAY, ' 02:00:00')
DO CALL sp_sync_cos_goods_sku_params_daily(NULL);

-- 方式2: 使用操作系统的cron job
-- 在crontab中添加：
-- 0 2 * * * mysql -u username -p password database_name -e "CALL sp_sync_cos_goods_sku_params_daily(NULL);"
```

## 目标表结构

存储过程会自动创建目标表 `cos_goods_sku_params`，包含以下字段：

| 字段名 | 类型 | 说明 |
|-------|------|------|
| id | BIGINT | 主键，自增 |
| company_id | BIGINT | 公司ID |
| shop_id | BIGINT | 店铺ID（关联cos_shop.id） |
| sku_id | VARCHAR(100) | SKU编码 |
| monitor_date | DATE | 监控日期 |
| sales_7d | INT | 7天销量 |
| sales_15d | INT | 15天销量 |
| sales_30d | INT | 30天销量 |
| daily_avg_sales | DECIMAL(10,2) | 日均销量（加权） |
| platform_inventory | INT | 平台库存 |
| deleted | BIGINT | 删除标记：0=未删除 |
| create_time | DATETIME | 创建时间 |
| update_time | DATETIME | 更新时间 |

### 唯一索引
```sql
UNIQUE KEY uk_company_shop_sku_date (company_id, shop_id, sku_id, monitor_date, deleted)
```

## 性能优化

1. **临时表使用**: 使用MEMORY引擎的临时表加速数据处理
2. **索引优化**: 临时表上创建适当的索引
3. **分步处理**: 将JH、FBA、MP数据分别处理，避免复杂JOIN
4. **批量操作**: 使用INSERT ... ON DUPLICATE KEY UPDATE实现批量UPSERT

## 异常处理

存储过程包含完善的异常处理机制：
- 发生错误时自动回滚事务
- 返回错误信息
- 确保数据一致性

## 数据验证

执行后可以通过以下SQL验证数据：

```sql
-- 查看最新同步的数据
SELECT 
    company_id,
    shop_id,
    sku_id,
    monitor_date,
    sales_7d,
    sales_15d,
    sales_30d,
    daily_avg_sales,
    platform_inventory,
    update_time
FROM cos_goods_sku_params
WHERE monitor_date = CURDATE()
    AND deleted = 0
ORDER BY update_time DESC
LIMIT 100;

-- 统计各店铺的SKU数量
SELECT 
    shop_id,
    COUNT(DISTINCT sku_id) AS sku_count,
    SUM(platform_inventory) AS total_inventory,
    AVG(daily_avg_sales) AS avg_daily_sales
FROM cos_goods_sku_params
WHERE monitor_date = CURDATE()
    AND deleted = 0
GROUP BY shop_id;
```

## 注意事项

1. **首次执行**: 首次执行时会自动创建目标表
2. **历史数据**: 支持重新计算历史数据，指定历史日期即可
3. **数据准确性**: 确保源表数据完整且准确
4. **执行时间**: 建议在业务低峰期执行（如凌晨2点）
5. **监控日志**: 建议记录每次执行的结果和耗时

## 维护建议

1. **定期检查**: 定期检查存储过程执行情况
2. **数据归档**: 定期归档历史数据
3. **性能监控**: 监控存储过程执行时间
4. **索引维护**: 定期优化表索引

## 故障排查

### 常见问题

1. **店铺映射失败**
   - 检查 amf_jh_shop, amf_lx_shop, cos_shop 表的映射关系
   - 确认 platform_shop_id 和 external_id 字段是否正确填充

2. **销量数据为0**
   - 检查订单表中是否有指定日期范围的数据
   - 确认订单状态筛选条件是否正确
   - 验证日期字段格式和解析是否正确

3. **库存数据不准确**
   - FBA: 检查 amf_lx_fbadetail 表的 sync_date 是否最新
   - JH: 检查 amf_jh_shop_warehouse_stock 表的数据更新情况

4. **执行时间过长**
   - 检查表的索引是否存在
   - 考虑增加临时表的内存限制
   - 评估是否需要分批处理大量数据

## 版本历史

- **v1.0** (2026-02-02): 初始版本
  - 支持JH、FBA、MP三种店铺类型
  - 实现加权日均销量计算
  - 支持FBA和JH库存同步
  - 确保幂等性和数据一致性

## 技术支持

如有问题或建议，请联系技术团队。
