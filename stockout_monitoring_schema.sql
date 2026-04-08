-- ===========================================
-- 产品断货点监控模型数据库表结构
-- Product Stockout Point Monitoring Model Database Schema
-- ===========================================

-- 1. 区域仓维度表
-- Regional Warehouse Dimension Table
CREATE TABLE IF NOT EXISTS `dw_dim_regional_warehouse` (
    `regional_warehouse_key` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '区域仓代理键（数仓主键）',
    `regional_warehouse_id` BIGINT NOT NULL COMMENT '区域仓业务ID',
    `regional_warehouse_code` VARCHAR(64) NOT NULL COMMENT '区域仓编码',
    `regional_warehouse_name` VARCHAR(128) NOT NULL COMMENT '区域仓名称',
    `region` VARCHAR(64) NOT NULL COMMENT '地区（US_WEST/US_EAST/US_CENTRAL/US_SOUTH等）',
    `country` VARCHAR(64) DEFAULT NULL COMMENT '国家',
    `description` VARCHAR(255) COMMENT '描述',
    `status` VARCHAR(20) DEFAULT 'ACTIVE' COMMENT '状态',
    `effective_date` DATE NOT NULL COMMENT '生效日期（SCD Type 2）',
    `expiry_date` DATE NOT NULL DEFAULT '9999-12-31' COMMENT '失效日期（SCD Type 2）',
    `is_current` TINYINT NOT NULL DEFAULT 1 COMMENT '是否当前版本 0-否 1-是',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_regional_warehouse_code` (`regional_warehouse_code`, `is_current`),
    INDEX `idx_regional_warehouse_id` (`regional_warehouse_id`),
    INDEX `idx_region` (`region`),
    INDEX `idx_is_current` (`is_current`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='区域仓维度表';

-- 2. 区域仓-仓库绑定关系表
-- Regional Warehouse to Warehouse Binding Table
CREATE TABLE IF NOT EXISTS `regional_warehouse_binding` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `regional_warehouse_id` BIGINT NOT NULL COMMENT '区域仓ID',
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID',
    `warehouse_code` VARCHAR(64) NOT NULL COMMENT '仓库编码',
    `business_mode` ENUM('JH', 'LX', 'FBA') NOT NULL COMMENT '业务模式',
    `priority` INT DEFAULT 1 COMMENT '优先级（数字越小优先级越高）',
    `is_active` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `effective_date` DATE NOT NULL COMMENT '生效日期',
    `expiry_date` DATE DEFAULT '9999-12-31' COMMENT '失效日期',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_binding` (`regional_warehouse_id`, `warehouse_id`, `business_mode`),
    INDEX `idx_regional_warehouse_id` (`regional_warehouse_id`),
    INDEX `idx_warehouse_id` (`warehouse_id`),
    INDEX `idx_business_mode` (`business_mode`),
    INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='区域仓-仓库绑定关系表';

-- 2.1 区域仓参数配置表
-- Regional Warehouse Parameters Configuration Table
CREATE TABLE IF NOT EXISTS `regional_warehouse_params` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `regional_warehouse_id` BIGINT NOT NULL COMMENT '区域仓ID',
    `regional_warehouse_code` VARCHAR(64) NOT NULL COMMENT '区域仓编码',
    `safety_stock_days` INT DEFAULT 30 COMMENT '安全库存天数',
    `stocking_cycle_days` INT DEFAULT 30 COMMENT '备货周期天数',
    `shipping_days` INT DEFAULT 45 COMMENT '发货天数（海运时间）',
    `production_days` INT DEFAULT 0 COMMENT '生产天数',
    `lead_time_days` INT DEFAULT 75 COMMENT '总提前期天数（备货+发货）',
    `effective_date` DATE NOT NULL COMMENT '生效日期',
    `expiry_date` DATE DEFAULT '9999-12-31' COMMENT '失效日期',
    `is_active` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_params` (`regional_warehouse_id`, `effective_date`),
    INDEX `idx_regional_warehouse_code` (`regional_warehouse_code`),
    INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='区域仓参数配置表';

-- 3. 发货单表（用于在途库存统计）
-- Shipment Order Table (for in-transit inventory calculation)
CREATE TABLE IF NOT EXISTS `shipment_order` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `order_no` VARCHAR(64) NOT NULL COMMENT '发货单号',
    `product_id` BIGINT NOT NULL COMMENT '产品ID',
    `product_sku` VARCHAR(100) NOT NULL COMMENT '产品SKU',
    `warehouse_id` BIGINT NOT NULL COMMENT '目标仓库ID',
    `warehouse_code` VARCHAR(64) NOT NULL COMMENT '目标仓库编码',
    `business_mode` ENUM('JH', 'LX', 'FBA') NOT NULL COMMENT '业务模式（JH-聚合/LX-零星/FBA-亚马逊）',
    `quantity` INT NOT NULL DEFAULT 0 COMMENT '发货数量',
    `shipped_quantity` INT DEFAULT 0 COMMENT '已发数量',
    `received_quantity` INT DEFAULT 0 COMMENT '已收数量',
    `ship_date` DATE COMMENT '发货日期',
    `expected_arrival_date` DATE COMMENT '预计到货日期',
    `actual_arrival_date` DATE COMMENT '实际到货日期',
    `status` ENUM('DRAFT', 'CONFIRMED', 'SHIPPED', 'IN_TRANSIT', 'ARRIVED', 'CANCELLED') DEFAULT 'DRAFT' COMMENT '状态',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_order_no` (`order_no`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_product_sku` (`product_sku`),
    INDEX `idx_warehouse_id` (`warehouse_id`),
    INDEX `idx_business_mode` (`business_mode`),
    INDEX `idx_status` (`status`),
    INDEX `idx_ship_date` (`ship_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='发货单表';

-- 4. 海外仓库存表
-- Overseas Warehouse Inventory Table
CREATE TABLE IF NOT EXISTS `overseas_warehouse_inventory` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `product_id` BIGINT NOT NULL COMMENT '产品ID',
    `product_sku` VARCHAR(100) NOT NULL COMMENT '产品SKU',
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID',
    `warehouse_code` VARCHAR(64) NOT NULL COMMENT '仓库编码',
    `business_mode` ENUM('JH_LX', 'FBA') NOT NULL COMMENT '业务模式（JH_LX合并/FBA单独）',
    `on_hand_quantity` INT NOT NULL DEFAULT 0 COMMENT '现有库存数量',
    `available_quantity` INT DEFAULT 0 COMMENT '可用数量',
    `reserved_quantity` INT DEFAULT 0 COMMENT '预留/锁定数量',
    `data_date` DATE NOT NULL COMMENT '数据日期（快照日期）',
    `snapshot_time` DATETIME NOT NULL COMMENT '快照时间',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_inventory` (`product_sku`, `warehouse_code`, `business_mode`, `data_date`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_warehouse_id` (`warehouse_id`),
    INDEX `idx_business_mode` (`business_mode`),
    INDEX `idx_data_date` (`data_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='海外仓库存表';

-- 5. 订单区域比例表
-- Order Regional Proportion Table
CREATE TABLE IF NOT EXISTS `order_regional_proportion` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `product_id` BIGINT NOT NULL COMMENT '产品ID',
    `product_sku` VARCHAR(100) NOT NULL COMMENT '产品SKU',
    `regional_warehouse_id` BIGINT NOT NULL COMMENT '区域仓ID',
    `region` VARCHAR(64) NOT NULL COMMENT '区域',
    `calculation_date` DATE NOT NULL COMMENT '计算日期',
    `order_count_7days` INT DEFAULT 0 COMMENT '7天订单数',
    `order_count_30days` INT DEFAULT 0 COMMENT '30天订单数',
    `sales_quantity_7days` INT DEFAULT 0 COMMENT '7天销量',
    `sales_quantity_30days` INT DEFAULT 0 COMMENT '30天销量',
    `proportion_7days` DECIMAL(5,4) DEFAULT 0 COMMENT '7天区域占比',
    `proportion_30days` DECIMAL(5,4) DEFAULT 0 COMMENT '30天区域占比',
    `weighted_proportion` DECIMAL(5,4) DEFAULT 0 COMMENT '加权区域占比',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_product_region_date` (`product_sku`, `regional_warehouse_id`, `calculation_date`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_regional_warehouse_id` (`regional_warehouse_id`),
    INDEX `idx_calculation_date` (`calculation_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单区域比例表';

-- 6. 产品断货点监控表（核心监控指标表）
-- Product Stockout Point Monitoring Table
CREATE TABLE IF NOT EXISTS `product_stockout_monitoring` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `product_id` BIGINT NOT NULL COMMENT '产品ID',
    `product_sku` VARCHAR(100) NOT NULL COMMENT '产品SKU',
    `product_name` VARCHAR(255) COMMENT '产品名称',
    `company_id` BIGINT COMMENT '公司ID',
    `warehouse_id` BIGINT COMMENT '仓库ID（可选，用于仓库级别监控）',
    `regional_warehouse_id` BIGINT NOT NULL COMMENT '区域仓ID',
    `regional_warehouse_code` VARCHAR(64) NOT NULL COMMENT '区域仓编码',
    `business_mode` ENUM('JH_LX', 'FBA') NOT NULL COMMENT '业务模式（JH_LX合并/FBA单独）',
    `snapshot_date` DATE NOT NULL COMMENT '快照日期',
    
    -- 库存指标
    `overseas_inventory` INT DEFAULT 0 COMMENT '海外仓现有库存',
    `in_transit_inventory` INT DEFAULT 0 COMMENT '在途库存',
    `domestic_remaining_qty` INT DEFAULT 0 COMMENT '国内仓余单数量',
    `domestic_actual_stock_qty` INT DEFAULT 0 COMMENT '国内仓实物库存数量',
    `total_inventory` INT DEFAULT 0 COMMENT '总库存（海外+在途）',
    `available_inventory` INT DEFAULT 0 COMMENT '可用库存',
    
    -- 销量指标
    `daily_avg_sales` DECIMAL(10,4) DEFAULT 0 COMMENT '日均销量',
    `daily_avg_sales_7days` DECIMAL(10,4) DEFAULT 0 COMMENT '7天日均销量',
    `daily_avg_sales_30days` DECIMAL(10,4) DEFAULT 0 COMMENT '30天日均销量',
    `regional_proportion` DECIMAL(5,4) DEFAULT 0 COMMENT '区域销量占比',
    `regional_daily_sales` DECIMAL(10,4) DEFAULT 0 COMMENT '区域日均销量（总销量*区域占比）',
    
    -- 周期参数
    `safety_stock_days` INT DEFAULT 30 COMMENT '安全库存天数',
    `stocking_cycle_days` INT DEFAULT 30 COMMENT '备货周期天数',
    `shipping_days` INT DEFAULT 45 COMMENT '发货天数（海运时间）',
    `lead_time_days` INT DEFAULT 75 COMMENT '总提前期（备货+发货）',
    
    -- 断货点指标
    `stockout_point` INT DEFAULT 0 COMMENT '断货点数量（日均销量*提前期）',
    `safety_stock_quantity` INT DEFAULT 0 COMMENT '安全库存数量',
    `available_days` DECIMAL(10,2) DEFAULT 0 COMMENT '可售天数（库存/日均销量）',
    `stockout_risk_days` INT DEFAULT 0 COMMENT '断货风险天数（负数表示已断货）',
    `is_stockout_risk` TINYINT(1) DEFAULT 0 COMMENT '是否有断货风险',
    `risk_level` ENUM('SAFE', 'WARNING', 'DANGER', 'STOCKOUT') DEFAULT 'SAFE' COMMENT '风险等级',
    
    -- 余单数据
    `pending_order_quantity` INT DEFAULT 0 COMMENT '余单数量',
    
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY `uk_monitoring` (`product_sku`, `regional_warehouse_id`, `business_mode`, `snapshot_date`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_company_id` (`company_id`),
    INDEX `idx_warehouse_id` (`warehouse_id`),
    INDEX `idx_regional_warehouse_id` (`regional_warehouse_id`),
    INDEX `idx_business_mode` (`business_mode`),
    INDEX `idx_snapshot_date` (`snapshot_date`),
    INDEX `idx_is_stockout_risk` (`is_stockout_risk`),
    INDEX `idx_risk_level` (`risk_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品断货点监控表';

-- 7. 监控任务执行日志表
-- Monitoring Task Execution Log Table
CREATE TABLE IF NOT EXISTS `monitoring_execution_log` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `batch_id` VARCHAR(64) NOT NULL COMMENT '批次ID',
    `task_type` ENUM('DAILY_SNAPSHOT', 'HISTORICAL_BACKFILL') NOT NULL COMMENT '任务类型',
    `snapshot_date` DATE NOT NULL COMMENT '快照日期',
    `execution_time` DATETIME NOT NULL COMMENT '执行时间',
    `total_products` INT DEFAULT 0 COMMENT '处理产品总数',
    `success_count` INT DEFAULT 0 COMMENT '成功数量',
    `error_count` INT DEFAULT 0 COMMENT '失败数量',
    `warning_count` INT DEFAULT 0 COMMENT '风险预警数量',
    `danger_count` INT DEFAULT 0 COMMENT '严重风险数量',
    `duration_ms` BIGINT COMMENT '执行耗时（毫秒）',
    `status` ENUM('RUNNING', 'COMPLETED', 'FAILED') DEFAULT 'RUNNING' COMMENT '执行状态',
    `error_message` TEXT COMMENT '错误信息',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_batch_id` (`batch_id`),
    INDEX `idx_snapshot_date` (`snapshot_date`),
    INDEX `idx_execution_time` (`execution_time`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='监控任务执行日志表';

-- 初始化示例数据

-- 插入区域仓示例数据
INSERT INTO `dw_dim_regional_warehouse` 
    (`regional_warehouse_id`, `regional_warehouse_code`, `regional_warehouse_name`, `region`, `country`, `effective_date`) 
VALUES
    (1, 'RW_US_WEST', '美西区域仓', 'US_WEST', 'USA', '2024-01-01'),
    (2, 'RW_US_EAST', '美东区域仓', 'US_EAST', 'USA', '2024-01-01'),
    (3, 'RW_US_CENTRAL', '美中区域仓', 'US_CENTRAL', 'USA', '2024-01-01'),
    (4, 'RW_US_SOUTH', '美南区域仓', 'US_SOUTH', 'USA', '2024-01-01')
ON DUPLICATE KEY UPDATE `update_time` = CURRENT_TIMESTAMP;

-- 插入区域仓-仓库绑定关系示例数据
-- 注意：这里使用示例仓库ID，实际使用时需要根据真实仓库数据配置
INSERT INTO `regional_warehouse_binding` 
    (`regional_warehouse_id`, `warehouse_id`, `warehouse_code`, `business_mode`, `priority`, `effective_date`) 
VALUES
    -- 美西区域仓绑定
    (1, 101, 'WH_US_WEST_JH', 'JH', 1, '2024-01-01'),
    (1, 102, 'WH_US_WEST_LX', 'LX', 2, '2024-01-01'),
    (1, 103, 'WH_US_WEST_FBA', 'FBA', 3, '2024-01-01'),
    -- 美东区域仓绑定
    (2, 201, 'WH_US_EAST_JH', 'JH', 1, '2024-01-01'),
    (2, 202, 'WH_US_EAST_LX', 'LX', 2, '2024-01-01'),
    (2, 203, 'WH_US_EAST_FBA', 'FBA', 3, '2024-01-01')
ON DUPLICATE KEY UPDATE `update_time` = CURRENT_TIMESTAMP;

-- 插入区域仓参数配置示例数据
INSERT INTO `regional_warehouse_params`
    (`regional_warehouse_id`, `regional_warehouse_code`, `safety_stock_days`, `stocking_cycle_days`, `shipping_days`, `production_days`, `lead_time_days`, `effective_date`)
VALUES
    (1, 'RW_US_WEST', 30, 30, 35, 0, 65, '2024-01-01'),
    (2, 'RW_US_EAST', 30, 30, 50, 0, 80, '2024-01-01'),
    (3, 'RW_US_CENTRAL', 30, 30, 45, 0, 75, '2024-01-01'),
    (4, 'RW_US_SOUTH', 30, 30, 48, 0, 78, '2024-01-01')
ON DUPLICATE KEY UPDATE `update_time` = CURRENT_TIMESTAMP;
