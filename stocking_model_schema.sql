-- ===========================================
-- 备货模型数据库表结构
-- Stocking Model Database Schema
-- ===========================================

-- 1. 商品备货配置表
-- Product Stock Configuration Table
CREATE TABLE IF NOT EXISTS `product_stock_config` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku` VARCHAR(100) NOT NULL COMMENT '商品SKU',
    `product_name` VARCHAR(255) COMMENT '商品名称',
    `category` ENUM('S', 'A', 'B', 'C') NOT NULL DEFAULT 'B' COMMENT '商品SABC分类',
    `shipping_region` ENUM('US_WEST', 'US_EAST', 'US_CENTRAL', 'US_SOUTH') COMMENT '发货区域',
    `safety_stock_days` INT COMMENT '自定义安全库存天数',
    `stocking_coefficient` DECIMAL(5,2) COMMENT '自定义备货浮动系数',
    `production_days` INT DEFAULT 15 COMMENT '生产周期（天）',
    `current_inventory` INT DEFAULT 0 COMMENT '当前库存数量',
    `in_transit_inventory` INT DEFAULT 0 COMMENT '在途库存数量',
    `min_order_quantity` INT COMMENT '最小订货量',
    `max_order_quantity` INT COMMENT '最大订货量',
    `auto_stocking_enabled` TINYINT(1) DEFAULT 1 COMMENT '是否启用自动备货',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_sku` (`sku`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_category` (`category`),
    INDEX `idx_shipping_region` (`shipping_region`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品备货配置表';

-- 2. 销售历史汇总表
-- Sales History Summary Table
CREATE TABLE IF NOT EXISTS `sales_history_summary` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku` VARCHAR(100) NOT NULL COMMENT '商品SKU',
    `data_date` DATE NOT NULL COMMENT '数据日期',
    `total_sales_7days` INT DEFAULT 0 COMMENT '7天总销量',
    `total_sales_15days` INT DEFAULT 0 COMMENT '15天总销量',
    `total_sales_30days` INT DEFAULT 0 COMMENT '30天总销量',
    `daily_avg_7days` DECIMAL(10,4) COMMENT '7天日均销量',
    `daily_avg_15days` DECIMAL(10,4) COMMENT '15天日均销量',
    `daily_avg_30days` DECIMAL(10,4) COMMENT '30天日均销量',
    `weighted_daily_avg` DECIMAL(10,4) COMMENT '加权日均销量',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY `uk_sku_date` (`sku`, `data_date`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_data_date` (`data_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售历史汇总表';

-- 3. 每日销售明细表
-- Daily Sales Detail Table
CREATE TABLE IF NOT EXISTS `daily_sales_detail` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku` VARCHAR(100) NOT NULL COMMENT '商品SKU',
    `sales_date` DATE NOT NULL COMMENT '销售日期',
    `quantity` INT DEFAULT 0 COMMENT '销量',
    `amount` DECIMAL(12,2) DEFAULT 0 COMMENT '销售金额',
    `is_outlier` TINYINT(1) DEFAULT 0 COMMENT '是否为噪点数据',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY `uk_sku_date` (`sku`, `sales_date`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_sales_date` (`sales_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日销售明细表';

-- 4. 备货计算结果表
-- Stocking Calculation Result Table
CREATE TABLE IF NOT EXISTS `stocking_result` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku` VARCHAR(100) NOT NULL COMMENT '商品SKU',
    `product_name` VARCHAR(255) COMMENT '商品名称',
    `model_type` ENUM('MONTHLY', 'WEEKLY_FIXED', 'STOCKOUT_EMERGENCY') NOT NULL COMMENT '备货模型类型',
    `category` ENUM('S', 'A', 'B', 'C') COMMENT '商品SABC分类',
    `shipping_region` ENUM('US_WEST', 'US_EAST', 'US_CENTRAL', 'US_SOUTH') COMMENT '发货区域',
    `calculation_date` DATE NOT NULL COMMENT '计算日期',
    `daily_avg_sales` DECIMAL(10,4) COMMENT '日均销量',
    `recommended_quantity` INT COMMENT '建议备货量',
    `adjusted_quantity` INT COMMENT '调整后备货量',
    `final_quantity` INT COMMENT '最终备货量',
    `current_inventory` INT COMMENT '计算时的当前库存',
    `in_transit_inventory` INT COMMENT '计算时的在途库存',
    `suggested_ship_date` DATE COMMENT '建议发货日期',
    `expected_arrival_date` DATE COMMENT '预计到货日期',
    `stocking_cycle_days` INT COMMENT '备货周期（天）',
    `safety_stock_days` INT COMMENT '安全库存天数',
    `stocking_coefficient` DECIMAL(5,2) COMMENT '备货浮动系数',
    `is_emergency` TINYINT(1) DEFAULT 0 COMMENT '是否紧急备货',
    `urgency_note` VARCHAR(500) COMMENT '紧急程度说明',
    `reason` TEXT COMMENT '备货原因/说明',
    `stockout_risk_days` INT COMMENT '断货风险天数',
    `expected_stockout_quantity` INT COMMENT '预计断货量',
    `status` ENUM('PENDING', 'APPROVED', 'REJECTED', 'EXECUTED') DEFAULT 'PENDING' COMMENT '状态',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_sku` (`sku`),
    INDEX `idx_calculation_date` (`calculation_date`),
    INDEX `idx_model_type` (`model_type`),
    INDEX `idx_is_emergency` (`is_emergency`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='备货计算结果表';

-- 5. 发货计划表
-- Shipment Plan Table
CREATE TABLE IF NOT EXISTS `shipment_plan` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku` VARCHAR(100) NOT NULL COMMENT '商品SKU',
    `ship_date` DATE NOT NULL COMMENT '发货日期',
    `quantity` INT NOT NULL COMMENT '发货数量',
    `shipping_region` ENUM('US_WEST', 'US_EAST', 'US_CENTRAL', 'US_SOUTH') COMMENT '发货区域',
    `shipping_days` INT COMMENT '海运天数',
    `expected_arrival_date` DATE COMMENT '预计到货日期',
    `actual_arrival_date` DATE COMMENT '实际到货日期',
    `status` ENUM('PLANNED', 'SHIPPED', 'IN_TRANSIT', 'ARRIVED', 'CANCELLED') DEFAULT 'PLANNED' COMMENT '状态',
    `stocking_result_id` BIGINT COMMENT '关联的备货结果ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_sku` (`sku`),
    INDEX `idx_ship_date` (`ship_date`),
    INDEX `idx_expected_arrival_date` (`expected_arrival_date`),
    INDEX `idx_status` (`status`),
    INDEX `idx_stocking_result_id` (`stocking_result_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='发货计划表';

-- 6. 发货区域配置表
-- Shipping Region Configuration Table
CREATE TABLE IF NOT EXISTS `shipping_region_config` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `region_code` VARCHAR(20) NOT NULL COMMENT '区域代码',
    `region_name` VARCHAR(50) NOT NULL COMMENT '区域名称',
    `shipping_days` INT NOT NULL COMMENT '海运天数',
    `stockout_monitor_days` INT NOT NULL COMMENT '断货监控提前天数',
    `description` VARCHAR(255) COMMENT '描述',
    `is_active` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_region_code` (`region_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='发货区域配置表';

-- 初始化发货区域配置数据
INSERT INTO `shipping_region_config` (`region_code`, `region_name`, `shipping_days`, `stockout_monitor_days`, `description`) VALUES
('US_WEST', '美西', 35, 25, 'US West Coast (Los Angeles, Seattle)'),
('US_EAST', '美东', 50, 35, 'US East Coast (New York, Miami)'),
('US_CENTRAL', '美中', 45, 32, 'US Central (Chicago, Dallas)'),
('US_SOUTH', '美南', 48, 34, 'US South (Houston, Atlanta)')
ON DUPLICATE KEY UPDATE `update_time` = CURRENT_TIMESTAMP;

-- 7. SABC分类配置表
-- SABC Category Configuration Table
CREATE TABLE IF NOT EXISTS `sabc_category_config` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `category_code` CHAR(1) NOT NULL COMMENT '分类代码',
    `category_name` VARCHAR(50) NOT NULL COMMENT '分类名称',
    `default_safety_stock_days` INT NOT NULL COMMENT '默认安全库存天数',
    `default_stocking_coefficient` DECIMAL(5,2) NOT NULL COMMENT '默认备货浮动系数',
    `description` VARCHAR(255) COMMENT '描述',
    `is_active` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_category_code` (`category_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='SABC分类配置表';

-- 初始化SABC分类配置数据
INSERT INTO `sabc_category_config` (`category_code`, `category_name`, `default_safety_stock_days`, `default_stocking_coefficient`, `description`) VALUES
('S', '畅销品', 45, 1.30, 'S类 - 销量占比前20%，利润贡献高'),
('A', '次畅销品', 35, 1.20, 'A类 - 销量占比20%-40%'),
('B', '一般商品', 25, 1.10, 'B类 - 销量占比40%-70%'),
('C', '滞销品', 15, 1.00, 'C类 - 销量占比70%-100%')
ON DUPLICATE KEY UPDATE `update_time` = CURRENT_TIMESTAMP;

-- 8. 备货模型执行日志表
-- Stocking Model Execution Log Table
CREATE TABLE IF NOT EXISTS `stocking_execution_log` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `batch_id` VARCHAR(64) NOT NULL COMMENT '批次ID',
    `model_type` ENUM('MONTHLY', 'WEEKLY_FIXED', 'STOCKOUT_EMERGENCY') NOT NULL COMMENT '备货模型类型',
    `execution_date` DATETIME NOT NULL COMMENT '执行时间',
    `total_products` INT DEFAULT 0 COMMENT '处理商品总数',
    `success_count` INT DEFAULT 0 COMMENT '成功数量',
    `error_count` INT DEFAULT 0 COMMENT '失败数量',
    `emergency_count` INT DEFAULT 0 COMMENT '紧急备货数量',
    `total_stocking_quantity` INT DEFAULT 0 COMMENT '总备货量',
    `execution_time_ms` BIGINT COMMENT '执行耗时（毫秒）',
    `status` ENUM('RUNNING', 'COMPLETED', 'FAILED') DEFAULT 'RUNNING' COMMENT '执行状态',
    `error_message` TEXT COMMENT '错误信息',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_batch_id` (`batch_id`),
    INDEX `idx_execution_date` (`execution_date`),
    INDEX `idx_model_type` (`model_type`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='备货模型执行日志表';
