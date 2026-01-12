# 促销模型设计文档 (Promotion Model Design Document)

## 概述 (Overview)

本促销模型旨在为布艺云平台（buyi_cloud）提供一个灵活、可扩展的促销管理系统，支持多种促销类型和复杂的促销规则配置。

## 设计目标 (Design Goals)

1. **多样性**: 支持多种促销类型（折扣、满减、满赠、优惠券、限时抢购等）
2. **灵活性**: 提供灵活的规则配置，满足各种业务场景
3. **可扩展性**: 易于添加新的促销类型和规则
4. **性能优化**: 合理的索引设计，支持高并发查询
5. **数据追踪**: 完整的促销使用记录和统计分析
6. **可控性**: 预算控制、次数限制、库存管理等

## 数据模型 (Data Model)

### 1. promotion_activity (促销活动主表)

**用途**: 存储促销活动的基本信息和配置

**关键字段**:
- `activity_no`: 活动唯一编号
- `activity_type`: 活动类型（DISCOUNT/FULL_REDUCTION/FULL_GIFT/COUPON/FLASH_SALE/BUNDLE）
- `status`: 活动状态（草稿/待开始/进行中/已结束/已停用）
- `start_time`, `end_time`: 活动时间范围
- `priority`: 优先级，用于多促销叠加时的计算顺序
- `can_stack`: 是否可与其他促销叠加
- `total_budget`: 总预算控制
- `per_user_limit_count`: 单用户使用次数限制

**适用范围控制**:
- `apply_platform`: 适用平台（Amazon、Walmart等）
- `apply_shop`: 适用店铺
- `apply_country`: 适用国家
- `apply_user_type`: 适用用户类型（全部/新用户/VIP等）

### 2. promotion_rule (促销规则表)

**用途**: 定义促销活动的具体计算规则

**规则类型**:
- `THRESHOLD`: 门槛条件（满X元、满Y件）
- `DISCOUNT`: 折扣规则（百分比折扣、固定金额减免）
- `GIFT`: 赠品规则
- `REDUCTION`: 减免规则

**关键字段**:
- `condition_type`: 条件类型（金额/数量/无条件）
- `condition_value`: 条件值
- `discount_type`: 优惠类型（百分比/固定金额/一口价/免运费）
- `discount_value`: 优惠值
- `max_discount_amount`: 最大优惠金额限制
- `step_rule`: 是否阶梯规则（如每满100减10）

### 3. promotion_product (促销商品关联表)

**用途**: 定义哪些商品参与促销活动

**商品范围类型**:
- `ALL`: 全部商品
- `CATEGORY`: 按分类
- `BRAND`: 按品牌
- `SKU`: 指定SKU
- `SPU`: 指定SPU
- `EXCLUDE`: 排除特定商品

**限时抢购支持**:
- `stock_quantity`: 促销库存
- `sold_quantity`: 已售数量
- `limit_per_user`: 每用户限购数量

### 4. promotion_coupon (优惠券表)

**用途**: 管理优惠券类型的促销

**优惠券类型**:
- `UNIVERSAL`: 通用券
- `PRODUCT`: 商品券
- `SHIPPING`: 运费券
- `CASH`: 代金券

**关键字段**:
- `coupon_code`: 优惠券代码（唯一）
- `discount_type`: 优惠类型（百分比/固定金额）
- `min_order_amount`: 最低订单金额
- `total_quantity`: 总发行量
- `per_user_limit`: 每用户领取限制
- `valid_days`: 有效天数

### 5. promotion_user_coupon (用户优惠券表)

**用途**: 记录用户领取和使用优惠券的情况

**使用状态**:
- `0`: 未使用
- `1`: 已使用
- `2`: 已过期
- `3`: 已作废

**关键字段**:
- `valid_start_time`, `valid_end_time`: 有效期
- `use_time`: 使用时间
- `order_no`: 关联订单号
- `discount_amount`: 实际优惠金额

### 6. promotion_usage_record (促销使用记录表)

**用途**: 记录促销活动的使用情况，用于限制和统计

**记录内容**:
- 订单信息（订单号、订单项ID）
- 商品信息（SKU、名称、数量）
- 金额信息（原始金额、优惠金额、最终金额）
- 优惠券使用情况
- 退款处理

### 7. promotion_statistics (促销统计表)

**用途**: 按天统计促销活动的效果数据

**统计指标**:
- `order_count`: 订单数量
- `order_amount`: 订单金额
- `discount_amount`: 优惠金额
- `participant_count`: 参与用户数
- `product_quantity`: 商品销售数量
- `conversion_rate`: 转化率
- `avg_order_amount`: 平均订单金额

## 促销类型详解 (Promotion Types)

### 1. 折扣促销 (DISCOUNT)

**场景**: 全场8折、特定商品7折等

**配置示例**:
```sql
-- 活动配置
activity_type = 'DISCOUNT'

-- 规则配置
rule_type = 'DISCOUNT'
condition_type = 'NONE'  -- 无门槛
discount_type = 'PERCENTAGE'
discount_value = 80.00  -- 8折
max_discount_amount = 100.00  -- 最多优惠100元
```

### 2. 满减促销 (FULL_REDUCTION)

**场景**: 满100减20、满200减50等

**配置示例**:
```sql
-- 活动配置
activity_type = 'FULL_REDUCTION'

-- 规则配置
rule_type = 'REDUCTION'
condition_type = 'AMOUNT'
condition_value = 100.00  -- 满100元
discount_type = 'FIXED_AMOUNT'
discount_value = 20.00  -- 减20元
```

### 3. 满赠促销 (FULL_GIFT)

**场景**: 买3件送1件、满500送赠品等

**配置示例**:
```sql
-- 活动配置
activity_type = 'FULL_GIFT'

-- 规则配置
rule_type = 'GIFT'
condition_type = 'QUANTITY'
condition_value = 3  -- 满3件
gift_product_sku = 'GIFT-001'  -- 赠品SKU
gift_quantity = 1  -- 赠送1件
```

### 4. 优惠券促销 (COUPON)

**场景**: 新用户券、满减券、运费券等

**配置示例**:
```sql
-- 活动配置
activity_type = 'COUPON'
apply_user_type = 'NEW'  -- 新用户专享

-- 优惠券配置
coupon_type = 'UNIVERSAL'  -- 通用券
discount_type = 'FIXED_AMOUNT'
discount_value = 50.00  -- 50元
min_order_amount = 100.00  -- 满100元可用
```

### 5. 限时抢购 (FLASH_SALE)

**场景**: 秒杀活动、每日特价等

**配置示例**:
```sql
-- 活动配置
activity_type = 'FLASH_SALE'
start_time = '2026-01-20 10:00:00'
end_time = '2026-01-20 12:00:00'
total_limit_count = 100  -- 总共100个名额

-- 商品配置
stock_quantity = 100  -- 促销库存
limit_per_user = 2  -- 每人限购2件
original_price = 299.00
promotion_price = 199.00
```

### 6. 组合套餐 (BUNDLE)

**场景**: 买A+B只需XX元等

**配置示例**:
```sql
-- 活动配置
activity_type = 'BUNDLE'

-- 商品配置（多条记录）
product_scope_type = 'SKU'
scope_value = 'SKU-A,SKU-B,SKU-C'  -- 组合商品列表

-- 规则配置
discount_type = 'FIXED_PRICE'
discount_value = 399.00  -- 组合价
```

## 业务流程 (Business Process)

### 1. 创建促销活动流程

```
1. 创建活动基本信息 (promotion_activity)
   ↓
2. 配置促销规则 (promotion_rule)
   ↓
3. 设置参与商品 (promotion_product)
   ↓
4. 如果是优惠券活动，创建优惠券 (promotion_coupon)
   ↓
5. 审核并启用活动
```

### 2. 订单促销计算流程

```
1. 用户下单，系统获取购物车商品
   ↓
2. 查询当前有效的促销活动 (status=2, 时间范围内)
   ↓
3. 按优先级排序促销活动
   ↓
4. 逐个计算促销优惠
   - 检查商品是否参与
   - 检查用户资格
   - 检查使用次数限制
   - 计算优惠金额
   ↓
5. 处理促销叠加逻辑 (can_stack)
   ↓
6. 应用优惠券 (如果有)
   ↓
7. 计算最终订单金额
   ↓
8. 记录促销使用情况 (promotion_usage_record)
```

### 3. 优惠券领取和使用流程

```
领取流程:
1. 用户请求领取优惠券
   ↓
2. 检查优惠券状态和库存
   ↓
3. 检查用户领取次数限制
   ↓
4. 创建用户优惠券记录 (promotion_user_coupon)
   ↓
5. 更新优惠券已发放数量

使用流程:
1. 用户下单时输入优惠券代码
   ↓
2. 验证优惠券有效性
   - 是否属于该用户
   - 是否在有效期内
   - 是否满足使用条件
   ↓
3. 计算优惠金额
   ↓
4. 更新优惠券使用状态
   ↓
5. 记录使用情况
```

## 数据查询示例 (Query Examples)

### 1. 查询当前有效的促销活动

```sql
SELECT 
    a.*,
    COUNT(DISTINCT p.id) as product_count
FROM promotion_activity a
LEFT JOIN promotion_product p ON a.id = p.activity_id
WHERE a.status = 2  -- 进行中
  AND NOW() BETWEEN a.start_time AND a.end_time
  AND (a.total_limit_count IS NULL OR a.used_count < a.total_limit_count)
GROUP BY a.id
ORDER BY a.priority DESC;
```

### 2. 查询某商品参与的促销活动

```sql
SELECT 
    a.id,
    a.activity_no,
    a.activity_name,
    a.activity_type,
    r.discount_type,
    r.discount_value,
    p.promotion_price
FROM promotion_activity a
INNER JOIN promotion_product p ON a.id = p.activity_id
LEFT JOIN promotion_rule r ON a.id = r.activity_id
WHERE p.company_sku = 'WL-FZ-39-W'
  AND a.status = 2
  AND NOW() BETWEEN a.start_time AND a.end_time
  AND p.is_excluded = 0;
```

### 3. 查询用户可用的优惠券

```sql
SELECT 
    uc.*,
    c.coupon_name,
    c.discount_type,
    c.discount_value,
    c.min_order_amount,
    a.activity_name
FROM promotion_user_coupon uc
INNER JOIN promotion_coupon c ON uc.coupon_id = c.id
INNER JOIN promotion_activity a ON c.activity_id = a.id
WHERE uc.user_id = ?
  AND uc.use_status = 0  -- 未使用
  AND NOW() BETWEEN uc.valid_start_time AND uc.valid_end_time
  AND a.status = 2
ORDER BY uc.valid_end_time ASC;
```

### 4. 统计促销活动效果

```sql
SELECT 
    a.activity_no,
    a.activity_name,
    a.activity_type,
    SUM(s.order_count) as total_orders,
    SUM(s.order_amount) as total_revenue,
    SUM(s.discount_amount) as total_discount,
    SUM(s.participant_count) as total_participants,
    AVG(s.conversion_rate) as avg_conversion_rate
FROM promotion_activity a
LEFT JOIN promotion_statistics s ON a.id = s.activity_id
WHERE a.start_time >= '2026-01-01'
  AND a.end_time <= '2026-01-31'
GROUP BY a.id
ORDER BY total_revenue DESC;
```

### 5. 查询用户促销使用历史

```sql
SELECT 
    r.order_no,
    r.use_time,
    a.activity_name,
    r.product_name,
    r.original_amount,
    r.discount_amount,
    r.final_amount,
    r.coupon_code
FROM promotion_usage_record r
INNER JOIN promotion_activity a ON r.activity_id = a.id
WHERE r.user_id = ?
  AND r.status = 1  -- 正常
ORDER BY r.use_time DESC
LIMIT 20;
```

## 索引优化建议 (Index Optimization)

已创建的关键索引:

1. **promotion_activity**: 
   - `uk_activity_no`: 唯一索引，活动编号查询
   - `idx_activity_type`: 按类型查询
   - `idx_status_time`: 复合索引，查询当前有效活动
   - `idx_start_time`, `idx_end_time`: 时间范围查询

2. **promotion_product**:
   - `idx_activity_id`: 活动关联查询
   - `idx_company_sku`, `idx_warehouse_sku`, `idx_sell_sku`: 商品查询
   - `idx_scope_type_value`: 范围类型查询

3. **promotion_coupon**:
   - `uk_coupon_code`: 唯一索引，券码查询
   - `idx_activity_id`: 活动关联查询

4. **promotion_user_coupon**:
   - `idx_coupon_id`, `idx_user_id`: 用户券查询
   - `idx_use_status`: 状态筛选
   - `idx_order_no`: 订单关联

5. **promotion_usage_record**:
   - `idx_activity_id`, `idx_user_id`: 统计查询
   - `idx_order_no`: 订单查询
   - `idx_use_time`: 时间范围查询

## 扩展性考虑 (Scalability Considerations)

### 1. 水平拆分

当数据量增大时，可以考虑：
- 按时间分表：将历史促销活动和使用记录按月/年分表
- 按地区分表：不同国家/地区的促销数据独立存储

### 2. 缓存策略

高频查询数据建议缓存：
- 当前有效的促销活动列表
- 商品的促销价格信息
- 用户的可用优惠券列表

### 3. 读写分离

- 促销计算使用主库，确保数据一致性
- 统计查询使用从库，降低主库压力

### 4. 异步处理

- 促销统计数据异步计算
- 大批量优惠券发放使用消息队列

## 安全性考虑 (Security Considerations)

1. **防刷控制**:
   - 限制单用户促销使用次数
   - 限制IP访问频率
   - 验证码保护

2. **金额校验**:
   - 前后端双重校验优惠金额
   - 防止负数金额
   - 防止超额优惠

3. **优惠券安全**:
   - 券码复杂度要求
   - 防止券码暴力破解
   - 限制券的领取和使用频率

4. **并发控制**:
   - 限时抢购库存的乐观锁控制
   - 优惠券领取的并发控制
   - 预算消耗的原子性保证

## 与现有系统集成 (Integration with Existing System)

### 1. 订单表关联

在现有的订单表（如 `amf_jh_orders`）中，已有以下促销相关字段：
- `promotion_discount_money`: 促销折扣金额

建议添加关联字段：
- `promotion_activity_ids`: 参与的促销活动ID列表（JSON格式）
- `used_coupon_codes`: 使用的优惠券代码列表（JSON格式）

### 2. 商品表关联

在商品表（如 `amf_jh_company_goods`）中可以添加：
- `is_promotion`: 是否有促销（0/1）
- `promotion_price`: 当前促销价（冗余字段，定期更新）
- `promotion_label`: 促销标签（如"秒杀"、"特价"等）

### 3. 用户表关联

如果有用户表，可以添加：
- `user_level`: 用户等级（用于判断VIP等级）
- `first_order_time`: 首单时间（用于判断新用户）
- `total_orders`: 总订单数（用于用户分级）

## 监控指标 (Monitoring Metrics)

建议监控以下指标：

1. **实时指标**:
   - 当前活动数量
   - 实时订单转化率
   - 优惠券使用率
   - 库存剩余量（限时抢购）

2. **业务指标**:
   - 促销活动ROI（投入产出比）
   - 平均优惠金额
   - 用户参与率
   - 新用户获取成本

3. **技术指标**:
   - 促销计算响应时间
   - 数据库查询性能
   - 缓存命中率
   - 并发请求数

## 未来优化方向 (Future Enhancements)

1. **智能推荐**: 基于用户行为推荐合适的促销活动
2. **动态定价**: 根据库存、时间等因素动态调整促销力度
3. **个性化促销**: 为不同用户群体提供定制化促销
4. **A/B测试**: 支持促销效果的A/B测试
5. **跨平台联动**: 支持多平台促销活动的统一管理
6. **社交分享**: 支持促销活动的社交分享和裂变传播

## 总结 (Conclusion)

本促销模型设计提供了一个完整、灵活、可扩展的促销管理解决方案，涵盖了常见的促销类型和业务场景。通过合理的表结构设计和索引优化，能够支撑高并发的促销查询和计算需求。同时，完善的统计和记录功能，为促销效果分析和业务决策提供了数据支持。
