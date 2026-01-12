# 促销模型实施指南 (Promotion Model Implementation Guide)

## 目录
1. [快速开始](#快速开始)
2. [数据库部署](#数据库部署)
3. [常见使用场景](#常见使用场景)
4. [API接口建议](#api接口建议)
5. [测试用例](#测试用例)

## 快速开始

### 1. 数据库部署

```bash
# 连接到MySQL数据库
mysql -u your_username -p your_database

# 执行SQL文件
source promotion_model.sql

# 或使用命令行直接执行
mysql -u your_username -p your_database < promotion_model.sql
```

### 2. 验证安装

```sql
-- 查看所有促销相关表
SHOW TABLES LIKE 'promotion_%';

-- 应该看到7个表：
-- promotion_activity
-- promotion_rule
-- promotion_product
-- promotion_coupon
-- promotion_user_coupon
-- promotion_usage_record
-- promotion_statistics

-- 查看示例数据
SELECT * FROM promotion_activity;
```

## 常见使用场景

### 场景1：创建全场折扣活动

```sql
-- 1. 创建活动
INSERT INTO promotion_activity (
    activity_no, 
    activity_name, 
    activity_type,
    activity_desc,
    priority,
    status,
    start_time,
    end_time,
    apply_user_type,
    can_stack,
    per_user_limit_count
) VALUES (
    'DISCOUNT2026001',
    '春季大促全场8折',
    'DISCOUNT',
    '春季促销活动，全场商品8折优惠，最多优惠200元',
    10,
    1,  -- 待开始
    '2026-03-01 00:00:00',
    '2026-03-31 23:59:59',
    'ALL',
    1,
    NULL  -- 不限制次数
);

-- 2. 添加折扣规则
SET @activity_id = LAST_INSERT_ID();

INSERT INTO promotion_rule (
    activity_id,
    rule_type,
    condition_type,
    discount_type,
    discount_value,
    max_discount_amount
) VALUES (
    @activity_id,
    'DISCOUNT',
    'NONE',  -- 无门槛
    'PERCENTAGE',
    80.00,  -- 8折
    200.00  -- 最多优惠200元
);

-- 3. 设置参与商品（可选，不设置表示全部商品）
INSERT INTO promotion_product (
    activity_id,
    product_scope_type,
    scope_value
) VALUES (
    @activity_id,
    'ALL',  -- 全部商品
    NULL
);
```

### 场景2：创建满减活动

```sql
-- 1. 创建满减活动
INSERT INTO promotion_activity (
    activity_no,
    activity_name,
    activity_type,
    priority,
    status,
    start_time,
    end_time,
    apply_user_type,
    can_stack
) VALUES (
    'REDUCTION2026001',
    '满300减50',
    'FULL_REDUCTION',
    20,
    1,
    '2026-02-01 00:00:00',
    '2026-02-28 23:59:59',
    'ALL',
    0  -- 不可叠加
);

SET @activity_id = LAST_INSERT_ID();

-- 2. 添加满减规则（可以添加多档）
-- 满300减50
INSERT INTO promotion_rule (
    activity_id,
    rule_type,
    condition_type,
    condition_value,
    discount_type,
    discount_value,
    rule_order
) VALUES (
    @activity_id,
    'REDUCTION',
    'AMOUNT',
    300.00,
    'FIXED_AMOUNT',
    50.00,
    1
);

-- 满500减100
INSERT INTO promotion_rule (
    activity_id,
    rule_type,
    condition_type,
    condition_value,
    discount_type,
    discount_value,
    rule_order
) VALUES (
    @activity_id,
    'REDUCTION',
    'AMOUNT',
    500.00,
    'FIXED_AMOUNT',
    100.00,
    2
);
```

### 场景3：创建限时秒杀活动

```sql
-- 1. 创建秒杀活动
INSERT INTO promotion_activity (
    activity_no,
    activity_name,
    activity_type,
    priority,
    status,
    start_time,
    end_time,
    total_limit_count
) VALUES (
    'FLASH2026001',
    '每日10点秒杀',
    'FLASH_SALE',
    30,
    1,
    '2026-02-01 10:00:00',
    '2026-02-01 11:00:00',
    100  -- 总共100个名额
);

SET @activity_id = LAST_INSERT_ID();

-- 2. 添加秒杀商品
INSERT INTO promotion_product (
    activity_id,
    product_scope_type,
    company_sku,
    warehouse_sku,
    product_name,
    original_price,
    promotion_price,
    stock_quantity,
    limit_per_user
) VALUES (
    @activity_id,
    'SKU',
    'COMPANY-SKU-001',
    'WAREHOUSE-SKU-001',
    '热销商品A',
    299.00,
    99.00,  -- 秒杀价
    100,    -- 秒杀库存
    2       -- 每人限购2件
);
```

### 场景4：创建优惠券

```sql
-- 1. 创建优惠券活动
INSERT INTO promotion_activity (
    activity_no,
    activity_name,
    activity_type,
    priority,
    status,
    start_time,
    end_time,
    apply_user_type
) VALUES (
    'COUPON2026001',
    '新用户专享券',
    'COUPON',
    15,
    1,
    '2026-01-01 00:00:00',
    '2026-12-31 23:59:59',
    'NEW'  -- 仅新用户
);

SET @activity_id = LAST_INSERT_ID();

-- 2. 创建优惠券
INSERT INTO promotion_coupon (
    activity_id,
    coupon_code,
    coupon_name,
    coupon_type,
    discount_type,
    discount_value,
    min_order_amount,
    max_discount_amount,
    total_quantity,
    per_user_limit,
    valid_days
) VALUES (
    @activity_id,
    'NEWUSER100',
    '新用户100元券',
    'UNIVERSAL',
    'FIXED_AMOUNT',
    100.00,
    200.00,  -- 满200可用
    100.00,
    5000,    -- 总共5000张
    1,       -- 每人限领1张
    30       -- 30天有效期
);
```

### 场景5：用户领取优惠券

```sql
-- 用户领取优惠券
SET @coupon_id = 1;
SET @user_id = 1001;

-- 1. 检查用户是否已领取
SELECT COUNT(*) as received_count 
FROM promotion_user_coupon 
WHERE coupon_id = @coupon_id AND user_id = @user_id;

-- 2. 创建用户优惠券记录
INSERT INTO promotion_user_coupon (
    coupon_id,
    user_id,
    user_key,
    receive_time,
    valid_start_time,
    valid_end_time,
    use_status
) VALUES (
    @coupon_id,
    @user_id,
    'USER_KEY_1001',
    NOW(),
    NOW(),
    DATE_ADD(NOW(), INTERVAL 30 DAY),
    0  -- 未使用
);

-- 3. 更新优惠券发放数量
UPDATE promotion_coupon 
SET issued_quantity = issued_quantity + 1 
WHERE id = @coupon_id;
```

### 场景6：订单使用促销

```sql
-- 记录订单使用促销
INSERT INTO promotion_usage_record (
    activity_id,
    user_id,
    user_key,
    order_no,
    usage_type,
    product_sku,
    product_name,
    quantity,
    original_amount,
    discount_amount,
    final_amount,
    use_time,
    status
) VALUES (
    1,                    -- 活动ID
    1001,                 -- 用户ID
    'USER_KEY_1001',      -- 用户标识
    'ORDER202601120001',  -- 订单号
    'ORDER',              -- 订单级促销
    'SKU-001',
    '商品名称',
    2,
    500.00,               -- 原价
    50.00,                -- 优惠金额
    450.00,               -- 最终金额
    NOW(),
    1                     -- 正常
);

-- 更新活动使用统计
UPDATE promotion_activity 
SET used_count = used_count + 1,
    used_budget = used_budget + 50.00
WHERE id = 1;
```

## API接口建议

### 1. 促销活动管理接口

```
POST   /api/promotion/activities          创建促销活动
GET    /api/promotion/activities          查询促销活动列表
GET    /api/promotion/activities/{id}     查询促销活动详情
PUT    /api/promotion/activities/{id}     更新促销活动
DELETE /api/promotion/activities/{id}     删除促销活动
POST   /api/promotion/activities/{id}/start   启动促销活动
POST   /api/promotion/activities/{id}/stop    停止促销活动
```

### 2. 促销规则接口

```
POST   /api/promotion/activities/{id}/rules       添加促销规则
GET    /api/promotion/activities/{id}/rules       查询促销规则
PUT    /api/promotion/rules/{ruleId}              更新促销规则
DELETE /api/promotion/rules/{ruleId}              删除促销规则
```

### 3. 促销商品接口

```
POST   /api/promotion/activities/{id}/products    添加促销商品
GET    /api/promotion/activities/{id}/products    查询促销商品
DELETE /api/promotion/products/{productId}        删除促销商品
GET    /api/promotion/products/check/{sku}        检查商品促销
```

### 4. 优惠券接口

```
POST   /api/promotion/coupons                创建优惠券
GET    /api/promotion/coupons                查询优惠券列表
GET    /api/promotion/coupons/{code}         查询优惠券详情
POST   /api/promotion/coupons/{code}/receive 领取优惠券
POST   /api/promotion/coupons/{code}/use     使用优惠券
GET    /api/promotion/user/coupons           查询用户优惠券
```

### 5. 促销计算接口

```
POST   /api/promotion/calculate              计算订单促销
POST   /api/promotion/validate               验证促销有效性
GET    /api/promotion/available              查询可用促销
```

### 6. 统计分析接口

```
GET    /api/promotion/statistics/{id}        查询促销统计
GET    /api/promotion/reports                促销效果报表
GET    /api/promotion/usage-records          促销使用记录
```

## 测试用例

### 测试用例1：折扣促销计算

```sql
-- 场景：全场8折，最多优惠100元
-- 测试数据
SET @original_price = 600.00;
SET @discount_rate = 0.80;
SET @max_discount = 100.00;

-- 计算
SET @discount_amount = @original_price * (1 - @discount_rate);
SET @final_discount = IF(@discount_amount > @max_discount, @max_discount, @discount_amount);
SET @final_price = @original_price - @final_discount;

-- 验证结果
SELECT 
    @original_price as original_price,
    @discount_amount as calculated_discount,
    @final_discount as final_discount,
    @final_price as final_price;

-- 预期结果：
-- original_price: 600.00
-- calculated_discount: 120.00
-- final_discount: 100.00  (因为超过最大优惠)
-- final_price: 500.00
```

### 测试用例2：满减促销计算

```sql
-- 场景：满300减50，满500减100
-- 测试1：订单金额299元
SET @order_amount = 299.00;
SELECT 
    CASE 
        WHEN @order_amount >= 500 THEN 100.00
        WHEN @order_amount >= 300 THEN 50.00
        ELSE 0
    END as discount;
-- 预期结果：0

-- 测试2：订单金额350元
SET @order_amount = 350.00;
SELECT 
    CASE 
        WHEN @order_amount >= 500 THEN 100.00
        WHEN @order_amount >= 300 THEN 50.00
        ELSE 0
    END as discount;
-- 预期结果：50.00

-- 测试3：订单金额520元
SET @order_amount = 520.00;
SELECT 
    CASE 
        WHEN @order_amount >= 500 THEN 100.00
        WHEN @order_amount >= 300 THEN 50.00
        ELSE 0
    END as discount;
-- 预期结果：100.00
```

### 测试用例3：优惠券使用限制

```sql
-- 测试优惠券使用条件
SET @order_amount = 150.00;
SET @coupon_min_amount = 200.00;
SET @coupon_value = 50.00;

SELECT 
    @order_amount as order_amount,
    @coupon_min_amount as min_required,
    IF(@order_amount >= @coupon_min_amount, 
       @coupon_value, 
       0) as coupon_discount,
    IF(@order_amount >= @coupon_min_amount, 
       'Can Use', 
       'Cannot Use') as status;

-- 预期结果：Cannot Use（订单金额不足）
```

### 测试用例4：查询有效促销活动

```sql
-- 查询当前时间有效的促销活动
SELECT 
    a.id,
    a.activity_no,
    a.activity_name,
    a.activity_type,
    a.status,
    a.start_time,
    a.end_time,
    CASE 
        WHEN a.status != 2 THEN 'Status Invalid'
        WHEN NOW() < a.start_time THEN 'Not Started'
        WHEN NOW() > a.end_time THEN 'Ended'
        WHEN a.total_limit_count IS NOT NULL 
             AND a.used_count >= a.total_limit_count THEN 'Quota Exhausted'
        ELSE 'Valid'
    END as validity
FROM promotion_activity a
WHERE a.status = 2
  AND NOW() BETWEEN a.start_time AND a.end_time
  AND (a.total_limit_count IS NULL OR a.used_count < a.total_limit_count);
```

### 测试用例5：库存检查（限时抢购）

```sql
-- 检查秒杀商品库存
SELECT 
    p.id,
    p.product_name,
    p.stock_quantity,
    p.sold_quantity,
    p.limit_per_user,
    (p.stock_quantity - p.sold_quantity) as available_stock,
    CASE 
        WHEN (p.stock_quantity - p.sold_quantity) <= 0 THEN 'Sold Out'
        WHEN (p.stock_quantity - p.sold_quantity) <= 10 THEN 'Low Stock'
        ELSE 'Available'
    END as stock_status
FROM promotion_product p
WHERE p.activity_id = 1
  AND p.product_scope_type = 'SKU';
```

## 性能优化建议

### 1. 缓存策略

```python
# 伪代码示例
def get_active_promotions():
    # 缓存键
    cache_key = "active_promotions"
    
    # 从缓存获取
    cached_data = redis.get(cache_key)
    if cached_data:
        return cached_data
    
    # 从数据库查询
    promotions = db.query("""
        SELECT * FROM promotion_activity 
        WHERE status = 2 
        AND NOW() BETWEEN start_time AND end_time
    """)
    
    # 存入缓存，5分钟过期
    redis.setex(cache_key, 300, promotions)
    
    return promotions
```

### 2. 批量查询优化

```sql
-- 不推荐：N+1查询
SELECT * FROM promotion_activity WHERE id = 1;
SELECT * FROM promotion_rule WHERE activity_id = 1;
SELECT * FROM promotion_product WHERE activity_id = 1;

-- 推荐：一次查询
SELECT 
    a.*,
    r.id as rule_id,
    r.discount_type,
    r.discount_value,
    p.id as product_id,
    p.product_name
FROM promotion_activity a
LEFT JOIN promotion_rule r ON a.id = r.activity_id
LEFT JOIN promotion_product p ON a.id = p.activity_id
WHERE a.id = 1;
```

### 3. 索引使用

```sql
-- 使用索引查询
EXPLAIN SELECT * FROM promotion_activity 
WHERE status = 2 
AND start_time <= NOW() 
AND end_time >= NOW();

-- 确保使用了 idx_status_time 索引
```

## 常见问题

### Q1: 如何处理促销叠加？

A: 通过 `can_stack` 字段控制，按 `priority` 排序后依次计算。

### Q2: 如何防止库存超卖？

A: 使用乐观锁或数据库行锁：
```sql
UPDATE promotion_product 
SET sold_quantity = sold_quantity + 1 
WHERE id = ? 
AND (stock_quantity - sold_quantity) >= 1;
```

### Q3: 如何处理退款？

A: 更新使用记录：
```sql
UPDATE promotion_usage_record 
SET status = 2,
    refund_amount = ?,
    refund_time = NOW() 
WHERE order_no = ?;
```

### Q4: 如何统计促销效果？

A: 使用 `promotion_statistics` 表，通过定时任务每天统计。

## 下一步

1. 根据实际业务需求调整表结构
2. 实现API接口
3. 添加单元测试
4. 配置监控告警
5. 优化性能和索引

---

更多详细信息请参考：
- **PROMOTION_MODEL_DESIGN.md** - 完整设计文档
- **promotion_model.sql** - SQL脚本
- **promotion_model_diagram.txt** - ER图
