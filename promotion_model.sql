/*
 促销模型设计 (Promotion Model Design)
 
 设计目标：
 1. 支持多种促销类型（折扣、满减、满赠、优惠券等）
 2. 灵活的促销规则配置
 3. 促销与商品、订单的关联管理
 4. 促销使用记录和限制管理
 5. 支持促销活动的生命周期管理
 
 Date: 2026-01-12
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 表结构: promotion_activity (促销活动主表)
-- 用途: 存储促销活动的基本信息
-- ----------------------------
DROP TABLE IF EXISTS `promotion_activity`;
CREATE TABLE `promotion_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '促销活动ID',
  `activity_no` varchar(50) NOT NULL COMMENT '活动编号（唯一标识）',
  `activity_name` varchar(200) NOT NULL COMMENT '活动名称',
  `activity_type` varchar(20) NOT NULL COMMENT '活动类型：DISCOUNT(折扣)、FULL_REDUCTION(满减)、FULL_GIFT(满赠)、COUPON(优惠券)、FLASH_SALE(限时抢购)、BUNDLE(组合套餐)',
  `activity_desc` text COMMENT '活动描述',
  `priority` int DEFAULT 0 COMMENT '优先级（数值越大优先级越高，用于多个促销叠加时的计算顺序）',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '活动状态：0=草稿、1=待开始、2=进行中、3=已结束、4=已停用',
  `start_time` datetime NOT NULL COMMENT '活动开始时间',
  `end_time` datetime NOT NULL COMMENT '活动结束时间',
  `apply_platform` varchar(200) COMMENT '适用平台（多个用逗号分隔，如：AMAZON,WALMART,自营平台）',
  `apply_shop` varchar(500) COMMENT '适用店铺ID列表（多个用逗号分隔，为空表示全部店铺）',
  `apply_country` varchar(200) COMMENT '适用国家代码列表（多个用逗号分隔，如：US,UK,DE）',
  `apply_user_type` varchar(50) COMMENT '适用用户类型：ALL(全部用户)、NEW(新用户)、VIP(会员)、CUSTOM(自定义)',
  `can_stack` tinyint DEFAULT 0 COMMENT '是否可叠加：0=不可叠加、1=可叠加',
  `total_budget` decimal(18,2) DEFAULT NULL COMMENT '活动总预算',
  `used_budget` decimal(18,2) DEFAULT 0.00 COMMENT '已使用预算',
  `total_limit_count` int DEFAULT NULL COMMENT '活动总使用次数限制（为空表示不限制）',
  `used_count` int DEFAULT 0 COMMENT '已使用次数',
  `per_user_limit_count` int DEFAULT NULL COMMENT '每个用户使用次数限制（为空表示不限制）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user_id` bigint DEFAULT NULL COMMENT '创建人ID',
  `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_activity_no` (`activity_no`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_status_time` (`status`, `start_time`, `end_time`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_end_time` (`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='促销活动主表';

-- ----------------------------
-- 表结构: promotion_rule (促销规则表)
-- 用途: 存储每个促销活动的具体规则配置
-- ----------------------------
DROP TABLE IF EXISTS `promotion_rule`;
CREATE TABLE `promotion_rule` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `activity_id` bigint NOT NULL COMMENT '关联促销活动ID',
  `rule_type` varchar(20) NOT NULL COMMENT '规则类型：THRESHOLD(门槛条件)、DISCOUNT(折扣规则)、GIFT(赠品规则)、REDUCTION(减免规则)',
  `condition_type` varchar(20) DEFAULT NULL COMMENT '条件类型：AMOUNT(金额)、QUANTITY(数量)、NONE(无条件)',
  `condition_value` decimal(18,2) DEFAULT NULL COMMENT '条件值（如满100元、满3件）',
  `discount_type` varchar(20) DEFAULT NULL COMMENT '优惠类型：PERCENTAGE(百分比折扣)、FIXED_AMOUNT(固定金额减免)、FIXED_PRICE(一口价)、FREE_SHIPPING(免运费)',
  `discount_value` decimal(18,2) DEFAULT NULL COMMENT '优惠值（如8折=80.00、减10元=10.00）',
  `max_discount_amount` decimal(18,2) DEFAULT NULL COMMENT '最大优惠金额（用于折扣类型时限制最大优惠）',
  `gift_product_sku` varchar(100) DEFAULT NULL COMMENT '赠品SKU（满赠活动时使用）',
  `gift_quantity` int DEFAULT NULL COMMENT '赠品数量',
  `step_rule` tinyint DEFAULT 0 COMMENT '是否阶梯规则：0=否、1=是（如每满100减10）',
  `rule_order` int DEFAULT 0 COMMENT '规则顺序（同一活动下多条规则的执行顺序）',
  `rule_expression` text COMMENT '规则表达式（复杂规则可用JSON格式存储）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_rule_type` (`rule_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='促销规则表';

-- ----------------------------
-- 表结构: promotion_product (促销商品关联表)
-- 用途: 定义哪些商品参与促销活动
-- ----------------------------
DROP TABLE IF EXISTS `promotion_product`;
CREATE TABLE `promotion_product` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `activity_id` bigint NOT NULL COMMENT '关联促销活动ID',
  `product_scope_type` varchar(20) NOT NULL COMMENT '商品范围类型：ALL(全部商品)、CATEGORY(分类)、BRAND(品牌)、SKU(指定SKU)、SPU(指定SPU)、EXCLUDE(排除商品)',
  `scope_value` varchar(500) DEFAULT NULL COMMENT '范围值（如分类ID、品牌名称、SKU列表，多个用逗号分隔）',
  `company_sku` varchar(100) DEFAULT NULL COMMENT '公司SKU',
  `warehouse_sku` varchar(100) DEFAULT NULL COMMENT '仓库SKU',
  `sell_sku` varchar(100) DEFAULT NULL COMMENT '销售SKU',
  `product_name` varchar(255) DEFAULT NULL COMMENT '商品名称',
  `original_price` decimal(18,2) DEFAULT NULL COMMENT '原价',
  `promotion_price` decimal(18,2) DEFAULT NULL COMMENT '促销价',
  `stock_quantity` int DEFAULT NULL COMMENT '促销库存数量（限时抢购时使用）',
  `sold_quantity` int DEFAULT 0 COMMENT '已售数量',
  `limit_per_user` int DEFAULT NULL COMMENT '每用户限购数量',
  `is_excluded` tinyint DEFAULT 0 COMMENT '是否排除：0=参与促销、1=排除',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_company_sku` (`company_sku`),
  KEY `idx_warehouse_sku` (`warehouse_sku`),
  KEY `idx_sell_sku` (`sell_sku`),
  KEY `idx_scope_type_value` (`product_scope_type`, `scope_value`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='促销商品关联表';

-- ----------------------------
-- 表结构: promotion_coupon (优惠券表)
-- 用途: 管理优惠券类型的促销
-- ----------------------------
DROP TABLE IF EXISTS `promotion_coupon`;
CREATE TABLE `promotion_coupon` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '优惠券ID',
  `activity_id` bigint NOT NULL COMMENT '关联促销活动ID',
  `coupon_code` varchar(50) NOT NULL COMMENT '优惠券代码（唯一）',
  `coupon_name` varchar(200) NOT NULL COMMENT '优惠券名称',
  `coupon_type` varchar(20) NOT NULL COMMENT '券类型：UNIVERSAL(通用券)、PRODUCT(商品券)、SHIPPING(运费券)、CASH(代金券)',
  `discount_type` varchar(20) NOT NULL COMMENT '优惠类型：PERCENTAGE(百分比)、FIXED_AMOUNT(固定金额)',
  `discount_value` decimal(18,2) NOT NULL COMMENT '优惠值',
  `min_order_amount` decimal(18,2) DEFAULT NULL COMMENT '最低订单金额',
  `max_discount_amount` decimal(18,2) DEFAULT NULL COMMENT '最大优惠金额',
  `total_quantity` int DEFAULT NULL COMMENT '总发行量（为空表示不限制）',
  `issued_quantity` int DEFAULT 0 COMMENT '已发放数量',
  `used_quantity` int DEFAULT 0 COMMENT '已使用数量',
  `per_user_limit` int DEFAULT 1 COMMENT '每用户领取限制',
  `valid_days` int DEFAULT NULL COMMENT '有效天数（从领取日期开始计算，为空则使用活动时间）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0=停用、1=启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_coupon_code` (`coupon_code`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_coupon_type` (`coupon_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='优惠券表';

-- ----------------------------
-- 表结构: promotion_user_coupon (用户优惠券表)
-- 用途: 记录用户领取和使用优惠券的情况
-- ----------------------------
DROP TABLE IF EXISTS `promotion_user_coupon`;
CREATE TABLE `promotion_user_coupon` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `coupon_id` bigint NOT NULL COMMENT '关联优惠券ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `user_key` varchar(64) DEFAULT NULL COMMENT '用户唯一标识',
  `receive_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
  `valid_start_time` datetime NOT NULL COMMENT '有效开始时间',
  `valid_end_time` datetime NOT NULL COMMENT '有效结束时间',
  `use_status` tinyint NOT NULL DEFAULT 0 COMMENT '使用状态：0=未使用、1=已使用、2=已过期、3=已作废',
  `use_time` datetime DEFAULT NULL COMMENT '使用时间',
  `order_no` varchar(50) DEFAULT NULL COMMENT '关联订单号',
  `discount_amount` decimal(18,2) DEFAULT NULL COMMENT '实际优惠金额',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_user_key` (`user_key`),
  KEY `idx_use_status` (`use_status`),
  KEY `idx_order_no` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户优惠券表';

-- ----------------------------
-- 表结构: promotion_usage_record (促销使用记录表)
-- 用途: 记录促销活动的使用情况，用于限制和统计
-- ----------------------------
DROP TABLE IF EXISTS `promotion_usage_record`;
CREATE TABLE `promotion_usage_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `activity_id` bigint NOT NULL COMMENT '促销活动ID',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `user_key` varchar(64) DEFAULT NULL COMMENT '用户唯一标识',
  `order_no` varchar(50) NOT NULL COMMENT '订单号',
  `order_item_id` varchar(50) DEFAULT NULL COMMENT '订单项ID',
  `usage_type` varchar(20) NOT NULL COMMENT '使用类型：ORDER(订单级)、PRODUCT(商品级)、SHIPPING(运费)',
  `product_sku` varchar(100) DEFAULT NULL COMMENT '商品SKU',
  `product_name` varchar(255) DEFAULT NULL COMMENT '商品名称',
  `quantity` int DEFAULT NULL COMMENT '商品数量',
  `original_amount` decimal(18,2) NOT NULL COMMENT '原始金额',
  `discount_amount` decimal(18,2) NOT NULL COMMENT '优惠金额',
  `final_amount` decimal(18,2) NOT NULL COMMENT '最终金额',
  `coupon_code` varchar(50) DEFAULT NULL COMMENT '使用的优惠券代码',
  `use_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '使用时间',
  `status` tinyint DEFAULT 1 COMMENT '状态：0=已取消、1=正常、2=已退款',
  `refund_amount` decimal(18,2) DEFAULT 0.00 COMMENT '退款金额',
  `refund_time` datetime DEFAULT NULL COMMENT '退款时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_user_key` (`user_key`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_use_time` (`use_time`),
  KEY `idx_product_sku` (`product_sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='促销使用记录表';

-- ----------------------------
-- 表结构: promotion_statistics (促销统计表)
-- 用途: 按天统计促销活动的效果数据
-- ----------------------------
DROP TABLE IF EXISTS `promotion_statistics`;
CREATE TABLE `promotion_statistics` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `activity_id` bigint NOT NULL COMMENT '促销活动ID',
  `stat_date` date NOT NULL COMMENT '统计日期',
  `order_count` int DEFAULT 0 COMMENT '订单数量',
  `order_amount` decimal(18,2) DEFAULT 0.00 COMMENT '订单金额',
  `discount_amount` decimal(18,2) DEFAULT 0.00 COMMENT '优惠金额',
  `participant_count` int DEFAULT 0 COMMENT '参与用户数',
  `product_quantity` int DEFAULT 0 COMMENT '商品销售数量',
  `new_user_count` int DEFAULT 0 COMMENT '新用户数',
  `conversion_rate` decimal(10,4) DEFAULT 0.0000 COMMENT '转化率（%）',
  `avg_order_amount` decimal(18,2) DEFAULT 0.00 COMMENT '平均订单金额',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_activity_date` (`activity_id`, `stat_date`),
  KEY `idx_stat_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='促销统计表';

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- 示例数据插入 (Sample Data)
-- ----------------------------

-- 示例1: 全场8折促销活动
INSERT INTO `promotion_activity` (
  `activity_no`, `activity_name`, `activity_type`, `activity_desc`, 
  `priority`, `status`, `start_time`, `end_time`, 
  `apply_platform`, `apply_user_type`, `can_stack`, 
  `total_limit_count`, `per_user_limit_count`
) VALUES (
  'PROMO202601001', '新年全场8折优惠', 'DISCOUNT', '2026年新年促销，全场商品8折优惠',
  10, 1, '2026-01-01 00:00:00', '2026-01-31 23:59:59',
  'AMAZON,WALMART', 'ALL', 1,
  10000, 5
);

-- 为上述活动添加折扣规则
INSERT INTO `promotion_rule` (
  `activity_id`, `rule_type`, `condition_type`, `condition_value`,
  `discount_type`, `discount_value`, `max_discount_amount`
) VALUES (
  LAST_INSERT_ID(), 'DISCOUNT', 'NONE', NULL,
  'PERCENTAGE', 80.00, 100.00
);

-- 示例2: 满减促销活动
INSERT INTO `promotion_activity` (
  `activity_no`, `activity_name`, `activity_type`, `activity_desc`,
  `priority`, `status`, `start_time`, `end_time`,
  `apply_user_type`, `can_stack`, `per_user_limit_count`
) VALUES (
  'PROMO202601002', '满100减20优惠', 'FULL_REDUCTION', '订单金额满100元减20元',
  20, 1, '2026-01-15 00:00:00', '2026-02-15 23:59:59',
  'ALL', 0, 10
);

-- 为满减活动添加规则
INSERT INTO `promotion_rule` (
  `activity_id`, `rule_type`, `condition_type`, `condition_value`,
  `discount_type`, `discount_value`, `step_rule`
) VALUES (
  LAST_INSERT_ID(), 'REDUCTION', 'AMOUNT', 100.00,
  'FIXED_AMOUNT', 20.00, 0
);

-- 示例3: 优惠券促销
INSERT INTO `promotion_activity` (
  `activity_no`, `activity_name`, `activity_type`, `activity_desc`,
  `priority`, `status`, `start_time`, `end_time`,
  `apply_user_type`, `can_stack`
) VALUES (
  'PROMO202601003', '新用户专享券', 'COUPON', '新用户专享50元优惠券',
  15, 1, '2026-01-01 00:00:00', '2026-12-31 23:59:59',
  'NEW', 1
);

-- 创建优惠券
INSERT INTO `promotion_coupon` (
  `activity_id`, `coupon_code`, `coupon_name`, `coupon_type`,
  `discount_type`, `discount_value`, `min_order_amount`, 
  `max_discount_amount`, `total_quantity`, `per_user_limit`, `valid_days`
) VALUES (
  LAST_INSERT_ID(), 'NEWUSER50', '新用户50元券', 'UNIVERSAL',
  'FIXED_AMOUNT', 50.00, 100.00,
  50.00, 1000, 1, 30
);

-- 示例4: 限时抢购活动
INSERT INTO `promotion_activity` (
  `activity_no`, `activity_name`, `activity_type`, `activity_desc`,
  `priority`, `status`, `start_time`, `end_time`,
  `apply_user_type`, `can_stack`, `total_limit_count`
) VALUES (
  'PROMO202601004', '每日限时秒杀', 'FLASH_SALE', '每日10点限时秒杀，先到先得',
  30, 1, '2026-01-20 10:00:00', '2026-01-20 12:00:00',
  'ALL', 0, 100
);

-- 为限时抢购添加特价商品
INSERT INTO `promotion_product` (
  `activity_id`, `product_scope_type`, `company_sku`, `warehouse_sku`,
  `product_name`, `original_price`, `promotion_price`, 
  `stock_quantity`, `limit_per_user`
) VALUES (
  LAST_INSERT_ID(), 'SKU', 'WL-FZ-39-W', 'WL-HGFZ-BG47-B',
  '39寸经济款方桌', 299.00, 199.00,
  100, 2
);
