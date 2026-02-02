# 存储过程文档: sp_sync_cos_goods_sku_params_daily

## 概述
此存储过程用于同步商品SKU的日均销量和平台库存参数到 `cos_goods_sku_daily_sale` 表中。

## 功能说明

### 1. 数据来源
存储过程从三个不同的系统源汇总销量数据：

#### 1.1 JH系统（鲸汇系统）
- **源表**: `amf_jh_orders`
- **店铺映射**: `amf_jh_shop.id` → `cos_shop.platform_shop_id` → `cos_shop.id`
  - **注意**: 原始需求提到 `extend_id` 字段，但当前schema中不存在该字段，因此使用 `id` 字段
  - 如果未来添加 `extend_id` 字段，需要修改映射为: `amf_jh_shop.extend_id` → `cos_shop.platform_shop_id`
- **SKU字段**: `warehouse_sku`
- **数量字段**: `warehouse_sku_num`
- **日期字段**: `delivery_time` (发货时间)
- **过滤条件**: `order_status = 'FH'` (已发货)

#### 1.2 FBA系统（亚马逊FBA）
- **源表**: `amf_lx_amzorder` + `amf_lx_amzorder_item`
- **店铺映射**: `amf_lx_shop.store_id` → `cos_shop.external_id` (WHERE `cos_shop.type='1'`)
- **唯一化**: 使用 `MIN(id)` 对相同 `external_id` 的店铺去重
- **SKU字段**: `local_sku`
- **数量字段**: `quantity_ordered`
- **日期字段**: `shipment_date_utc` (UTC发货时间)
- **过滤条件**: `fulfillment_channel = 'AFN'` (亚马逊配送)

#### 1.3 MP系统（MarketPlace订单）
- **源表**: `amf_lx_mporders` + `amf_lx_mporders_item`
- **店铺映射**: `amf_lx_mporders.store_id` → `cos_shop.external_id` (WHERE `cos_shop.type='1'`)
- **唯一化**: 使用 `MIN(id)` 对相同 `external_id` 的店铺去重
- **SKU字段**: `local_sku`
- **数量字段**: `quantity`
- **日期字段**: `global_create_time` (全局创建时间)
- **过滤条件**: `status = 6` (已完成)

### 2. 销量计算

#### 2.1 时间区间
- **今日销量**: 当天 (v_today)
- **7天销量**: v_today - 7天 到 v_today
- **15天销量**: v_today - 15天 到 v_today
- **30天销量**: v_today - 30天 到 v_today

#### 2.2 加权日均销量公式
```
daily_sales = (7天销量/7 × 0.5) + (15天销量/15 × 0.3) + (30天销量/30 × 0.2)
```

**权重说明**:
- 7天数据权重: 50% (最近数据，最重要)
- 15天数据权重: 30% (中期趋势)
- 30天数据权重: 20% (长期趋势)

### 3. 平台库存

#### 3.1 FBA平台库存
- **源表**: `amf_lx_fbadetail`
- **取值逻辑**: 取最大 `sync_date` 对应的 `available_total`
- **映射**: 通过 `amf_lx_shop` 关联到 `cos_shop`

#### 3.2 JH海外仓库存
- **源表**: `amf_jh_shop_warehouse_stock`
- **取值逻辑**: 取最新 `update_time` 对应的 `available_qty`
- **映射**: 通过 `amf_jh_shop` 的 `platform_shop_id` 关联到 `cos_shop`

### 4. 数据唯一性保证

#### 4.1 唯一键约束
目标表 `cos_goods_sku_daily_sale` 的唯一键：
```sql
UNIQUE KEY `uk_sku_date` (`shop_id`, `sku_id`, `sku_code`, `sync_date`, `deleted`)
```

#### 4.2 幂等性实现
- 每次执行前删除当天的旧数据
- 使用 `ON DUPLICATE KEY UPDATE` 处理冲突

### 5. 执行流程

```
1. 初始化日期变量
2. 创建临时表 tmp_jh_sales (JH销量)
3. 创建临时表 tmp_fba_sales (FBA销量)
4. 创建临时表 tmp_mp_sales (MP销量)
5. 合并三个源的数据 → tmp_all_sales
6. 计算加权日均销量
7. 收集平台库存数据 → tmp_platform_stock
8. 删除目标表当天旧数据
9. 插入/更新最终数据
10. 清理临时表
11. 提交事务
```

## 使用方法

### 调用示例

#### 1. 同步今天的数据
```sql
CALL sp_sync_cos_goods_sku_params_daily(NULL);
```

#### 2. 同步指定日期的数据
```sql
CALL sp_sync_cos_goods_sku_params_daily('2026-02-01');
```

### 返回结果
存储过程执行后会返回两个字段：
- `result_message`: 执行结果消息
- `records_inserted`: 插入的记录数

## 异常处理
- 使用事务保证数据一致性
- 发生错误时自动回滚
- 错误信息通过 `error_message` 返回

## 性能优化

### 1. 临时表优化
- 使用 MEMORY 引擎加速查询
- 为临时表创建主键索引

### 2. 日期解析优化
- 使用 `STR_TO_DATE` 函数健壮解析日期
- 预先过滤非法日期数据

### 3. JOIN优化
- 使用子查询预先去重 (MIN(id))
- 避免分组放大问题

## 注意事项

1. **数据类型**: 确保日期字段使用正确的格式
2. **NULL处理**: 日期字段必须非空且非空字符串
3. **事务**: 整个过程在一个事务中执行
4. **ID生成**: 使用 `generate_snowflake_id()` 函数生成唯一ID
5. **删除标记**: 只处理 `deleted=0` 的有效数据

## 依赖

### 函数依赖
- `generate_snowflake_id()`: 生成雪花ID

### 表依赖
**源表**:
- amf_jh_orders
- amf_jh_shop
- amf_lx_amzorder
- amf_lx_amzorder_item
- amf_lx_shop
- amf_lx_mporders
- amf_lx_mporders_item
- amf_lx_fbadetail
- amf_jh_shop_warehouse_stock

**目标表**:
- cos_goods_sku_daily_sale

**关联表**:
- cos_shop
- cos_goods_sku

## 维护建议

1. **定期执行**: 建议每天执行一次，通常在凌晨
2. **数据清理**: 定期清理过期的历史数据
3. **监控**: 监控执行时间和插入记录数
4. **日志**: 记录每次执行的结果

## 版本历史

- **v1.0** (2026-02-02): 初始版本
  - 实现三源数据汇总
  - 实现加权日均销量计算
  - 实现平台库存同步
