-- ============================================================
-- Buyi Cloud 数据仓库 DDL 脚本
-- Data Warehouse Schema for Buyi Cloud
-- 
-- 说明: 本脚本创建数据仓库所需的所有表结构
-- 包括: 维度表、事实表、聚合表
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. 维度表 (Dimension Tables)
-- ============================================================

-- ----------------------------
-- 时间维度表 (Date Dimension)
-- ----------------------------
DROP TABLE IF EXISTS `dw_dim_date`;
CREATE TABLE `dw_dim_date` (
  `date_key` INT NOT NULL COMMENT '日期键 YYYYMMDD',
  `full_date` DATE NOT NULL COMMENT '完整日期',
  `year` INT NOT NULL COMMENT '年份',
  `quarter` INT NOT NULL COMMENT '季度 1-4',
  `month` INT NOT NULL COMMENT '月份 1-12',
  `week` INT NOT NULL COMMENT '周数 1-53',
  `day_of_month` INT NOT NULL COMMENT '月中第几天',
  `day_of_week` INT NOT NULL COMMENT '周中第几天 1-7',
  `day_of_year` INT NOT NULL COMMENT '年中第几天',
  `is_weekend` TINYINT NOT NULL DEFAULT 0 COMMENT '是否周末 0-否 1-是',
  `is_holiday` TINYINT NOT NULL DEFAULT 0 COMMENT '是否节假日 0-否 1-是',
  `year_month` VARCHAR(7) NOT NULL COMMENT '年月 YYYY-MM',
  `year_quarter` VARCHAR(7) NOT NULL COMMENT '年季度 YYYY-Q1',
  PRIMARY KEY (`date_key`),
  KEY `idx_full_date` (`full_date`),
  KEY `idx_year_month` (`year_month`),
  KEY `idx_year_quarter` (`year_quarter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='时间维度表';

-- ----------------------------
-- 商品维度表 (Product Dimension) - SCD Type 2
-- ----------------------------
DROP TABLE IF EXISTS `dw_dim_product`;
CREATE TABLE `dw_dim_product` (
  `product_key` BIGINT NOT NULL AUTO_INCREMENT COMMENT '商品代理键（数仓主键）',
  `product_id` BIGINT NOT NULL COMMENT '商品业务ID（源系统主键）',
  `sku_code` VARCHAR(64) NOT NULL COMMENT 'SKU编码',
  `spu_code` VARCHAR(64) DEFAULT NULL COMMENT 'SPU编码',
  `product_name` VARCHAR(256) NOT NULL COMMENT '商品名称',
  `category_id` BIGINT DEFAULT NULL COMMENT '分类ID',
  `category_name` VARCHAR(128) DEFAULT NULL COMMENT '分类名称',
  `brand` VARCHAR(128) DEFAULT NULL COMMENT '品牌',
  `supplier_id` BIGINT DEFAULT NULL COMMENT '供应商ID',
  `supplier_name` VARCHAR(128) DEFAULT NULL COMMENT '供应商名称',
  `cost_price` DECIMAL(12,2) DEFAULT NULL COMMENT '成本价',
  `list_price` DECIMAL(12,2) DEFAULT NULL COMMENT '标价',
  `weight` DECIMAL(10,3) DEFAULT NULL COMMENT '重量(kg)',
  `volume` DECIMAL(10,3) DEFAULT NULL COMMENT '体积(m³)',
  `status` VARCHAR(20) DEFAULT NULL COMMENT '状态',
  `effective_date` DATE NOT NULL COMMENT '生效日期（SCD Type 2）',
  `expiry_date` DATE NOT NULL DEFAULT '9999-12-31' COMMENT '失效日期（SCD Type 2）',
  `is_current` TINYINT NOT NULL DEFAULT 1 COMMENT '是否当前版本 0-否 1-是',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`product_key`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_sku_code` (`sku_code`),
  KEY `idx_is_current` (`is_current`),
  KEY `idx_effective_date` (`effective_date`, `expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品维度表（SCD Type 2）';

-- ----------------------------
-- 店铺维度表 (Shop Dimension) - SCD Type 2
-- ----------------------------
DROP TABLE IF EXISTS `dw_dim_shop`;
CREATE TABLE `dw_dim_shop` (
  `shop_key` BIGINT NOT NULL AUTO_INCREMENT COMMENT '店铺代理键（数仓主键）',
  `shop_id` BIGINT NOT NULL COMMENT '店铺业务ID（源系统主键）',
  `shop_code` VARCHAR(64) NOT NULL COMMENT '店铺编码',
  `shop_name` VARCHAR(128) NOT NULL COMMENT '店铺名称',
  `platform` VARCHAR(64) DEFAULT NULL COMMENT '平台 Amazon/eBay/Shopee等',
  `marketplace` VARCHAR(64) DEFAULT NULL COMMENT '站点',
  `region` VARCHAR(64) DEFAULT NULL COMMENT '地区',
  `country` VARCHAR(64) DEFAULT NULL COMMENT '国家',
  `currency` VARCHAR(10) DEFAULT NULL COMMENT '币种',
  `timezone` VARCHAR(64) DEFAULT NULL COMMENT '时区',
  `status` VARCHAR(20) DEFAULT NULL COMMENT '状态',
  `effective_date` DATE NOT NULL COMMENT '生效日期（SCD Type 2）',
  `expiry_date` DATE NOT NULL DEFAULT '9999-12-31' COMMENT '失效日期（SCD Type 2）',
  `is_current` TINYINT NOT NULL DEFAULT 1 COMMENT '是否当前版本 0-否 1-是',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`shop_key`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_shop_code` (`shop_code`),
  KEY `idx_platform` (`platform`),
  KEY `idx_is_current` (`is_current`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='店铺维度表（SCD Type 2）';

-- ----------------------------
-- 仓库维度表 (Warehouse Dimension) - SCD Type 2
-- ----------------------------
DROP TABLE IF EXISTS `dw_dim_warehouse`;
CREATE TABLE `dw_dim_warehouse` (
  `warehouse_key` BIGINT NOT NULL AUTO_INCREMENT COMMENT '仓库代理键（数仓主键）',
  `warehouse_id` BIGINT NOT NULL COMMENT '仓库业务ID（源系统主键）',
  `warehouse_code` VARCHAR(64) NOT NULL COMMENT '仓库编码',
  `warehouse_name` VARCHAR(128) NOT NULL COMMENT '仓库名称',
  `warehouse_type` VARCHAR(32) DEFAULT NULL COMMENT '仓库类型 FBA/FBM/自营仓/海外仓',
  `country` VARCHAR(64) DEFAULT NULL COMMENT '国家',
  `region` VARCHAR(64) DEFAULT NULL COMMENT '地区',
  `city` VARCHAR(64) DEFAULT NULL COMMENT '城市',
  `address` VARCHAR(256) DEFAULT NULL COMMENT '地址',
  `status` VARCHAR(20) DEFAULT NULL COMMENT '状态',
  `effective_date` DATE NOT NULL COMMENT '生效日期（SCD Type 2）',
  `expiry_date` DATE NOT NULL DEFAULT '9999-12-31' COMMENT '失效日期（SCD Type 2）',
  `is_current` TINYINT NOT NULL DEFAULT 1 COMMENT '是否当前版本 0-否 1-是',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`warehouse_key`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_warehouse_code` (`warehouse_code`),
  KEY `idx_warehouse_type` (`warehouse_type`),
  KEY `idx_is_current` (`is_current`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='仓库维度表（SCD Type 2）';

-- ----------------------------
-- 地区维度表 (Region Dimension)
-- ----------------------------
DROP TABLE IF EXISTS `dw_dim_region`;
CREATE TABLE `dw_dim_region` (
  `region_key` BIGINT NOT NULL AUTO_INCREMENT COMMENT '地区代理键（数仓主键）',
  `region_id` BIGINT DEFAULT NULL COMMENT '地区业务ID（源系统主键）',
  `country_code` VARCHAR(10) NOT NULL COMMENT '国家编码 ISO 3166-1',
  `country_name` VARCHAR(64) NOT NULL COMMENT '国家名称',
  `state_code` VARCHAR(32) DEFAULT NULL COMMENT '州/省编码',
  `state_name` VARCHAR(64) DEFAULT NULL COMMENT '州/省名称',
  `city_name` VARCHAR(64) DEFAULT NULL COMMENT '城市名称',
  `postal_code` VARCHAR(20) DEFAULT NULL COMMENT '邮编',
  `continent` VARCHAR(32) DEFAULT NULL COMMENT '洲 Asia/Europe/North America等',
  `is_current` TINYINT NOT NULL DEFAULT 1 COMMENT '是否当前版本 0-否 1-是',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`region_key`),
  KEY `idx_country_code` (`country_code`),
  KEY `idx_state_code` (`state_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='地区维度表';

-- ============================================================
-- 2. 事实表 (Fact Tables)
-- ============================================================

-- ----------------------------
-- 销售事实表 (Sales Fact) - 事务事实表
-- ----------------------------
DROP TABLE IF EXISTS `dw_fact_sales`;
CREATE TABLE `dw_fact_sales` (
  `sales_key` BIGINT NOT NULL AUTO_INCREMENT COMMENT '销售键（数仓主键）',
  `date_key` INT NOT NULL COMMENT '日期键',
  `product_key` BIGINT NOT NULL COMMENT '商品键',
  `shop_key` BIGINT NOT NULL COMMENT '店铺键',
  `warehouse_key` BIGINT DEFAULT NULL COMMENT '仓库键',
  `region_key` BIGINT DEFAULT NULL COMMENT '地区键（收货地区）',
  `order_id` VARCHAR(64) NOT NULL COMMENT '订单号',
  `order_item_id` VARCHAR(64) DEFAULT NULL COMMENT '订单项ID',
  `quantity` INT NOT NULL DEFAULT 1 COMMENT '销售数量',
  `unit_price` DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '单价',
  `gross_amount` DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '销售总额（原价）',
  `discount_amount` DECIMAL(12,2) DEFAULT 0 COMMENT '折扣金额',
  `net_amount` DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '净销售额（实收）',
  `cost_amount` DECIMAL(12,2) DEFAULT NULL COMMENT '成本金额',
  `profit_amount` DECIMAL(12,2) DEFAULT NULL COMMENT '利润金额',
  `shipping_fee` DECIMAL(12,2) DEFAULT 0 COMMENT '运费',
  `platform_fee` DECIMAL(12,2) DEFAULT 0 COMMENT '平台费用',
  `order_status` VARCHAR(32) DEFAULT NULL COMMENT '订单状态',
  `payment_method` VARCHAR(32) DEFAULT NULL COMMENT '支付方式',
  `create_time` DATETIME NOT NULL COMMENT '订单创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`sales_key`),
  UNIQUE KEY `uk_order_item` (`order_id`, `order_item_id`),
  KEY `idx_date_key` (`date_key`),
  KEY `idx_product_key` (`product_key`),
  KEY `idx_shop_key` (`shop_key`),
  KEY `idx_warehouse_key` (`warehouse_key`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='销售事实表';

-- ----------------------------
-- 库存事实表 (Inventory Fact) - 周期快照事实表
-- ----------------------------
DROP TABLE IF EXISTS `dw_fact_inventory`;
CREATE TABLE `dw_fact_inventory` (
  `inventory_key` BIGINT NOT NULL AUTO_INCREMENT COMMENT '库存键（数仓主键）',
  `date_key` INT NOT NULL COMMENT '日期键（快照日期）',
  `product_key` BIGINT NOT NULL COMMENT '商品键',
  `warehouse_key` BIGINT NOT NULL COMMENT '仓库键',
  `shop_key` BIGINT DEFAULT NULL COMMENT '店铺键（FBA库存关联店铺）',
  `on_hand_quantity` INT NOT NULL DEFAULT 0 COMMENT '在库数量',
  `available_quantity` INT NOT NULL DEFAULT 0 COMMENT '可用数量',
  `reserved_quantity` INT DEFAULT 0 COMMENT '预留数量',
  `in_transit_quantity` INT DEFAULT 0 COMMENT '在途数量',
  `pending_quantity` INT DEFAULT 0 COMMENT '待入库数量',
  `unit_cost` DECIMAL(12,2) DEFAULT NULL COMMENT '单位成本',
  `inventory_value` DECIMAL(14,2) DEFAULT NULL COMMENT '库存价值',
  `days_of_supply` INT DEFAULT NULL COMMENT '库存可供天数',
  `turnover_days` INT DEFAULT NULL COMMENT '周转天数',
  `last_inbound_date` DATE DEFAULT NULL COMMENT '最后入库日期',
  `last_outbound_date` DATE DEFAULT NULL COMMENT '最后出库日期',
  `snapshot_time` DATETIME NOT NULL COMMENT '快照时间',
  PRIMARY KEY (`inventory_key`),
  UNIQUE KEY `uk_date_product_warehouse` (`date_key`, `product_key`, `warehouse_key`),
  KEY `idx_date_key` (`date_key`),
  KEY `idx_product_key` (`product_key`),
  KEY `idx_warehouse_key` (`warehouse_key`),
  KEY `idx_shop_key` (`shop_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存事实表（日快照）';

-- ----------------------------
-- 采购事实表 (Purchase Fact) - 事务事实表
-- ----------------------------
DROP TABLE IF EXISTS `dw_fact_purchase`;
CREATE TABLE `dw_fact_purchase` (
  `purchase_key` BIGINT NOT NULL AUTO_INCREMENT COMMENT '采购键（数仓主键）',
  `date_key` INT NOT NULL COMMENT '日期键（采购日期）',
  `product_key` BIGINT NOT NULL COMMENT '商品键',
  `warehouse_key` BIGINT NOT NULL COMMENT '目标仓库键',
  `supplier_key` BIGINT DEFAULT NULL COMMENT '供应商键',
  `purchase_order_id` VARCHAR(64) NOT NULL COMMENT '采购单号',
  `quantity` INT NOT NULL COMMENT '采购数量',
  `unit_cost` DECIMAL(12,2) NOT NULL COMMENT '采购单价',
  `total_cost` DECIMAL(14,2) NOT NULL COMMENT '采购总金额',
  `freight_cost` DECIMAL(12,2) DEFAULT 0 COMMENT '运费',
  `other_cost` DECIMAL(12,2) DEFAULT 0 COMMENT '其他费用',
  `order_status` VARCHAR(32) DEFAULT NULL COMMENT '订单状态',
  `expected_date` DATE DEFAULT NULL COMMENT '预计到货日期',
  `actual_date` DATE DEFAULT NULL COMMENT '实际到货日期',
  `lead_time_days` INT DEFAULT NULL COMMENT '采购周期(天)',
  `create_time` DATETIME NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`purchase_key`),
  KEY `idx_date_key` (`date_key`),
  KEY `idx_product_key` (`product_key`),
  KEY `idx_warehouse_key` (`warehouse_key`),
  KEY `idx_purchase_order_id` (`purchase_order_id`),
  KEY `idx_order_status` (`order_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购事实表';

-- ============================================================
-- 3. 聚合表 (Aggregation Tables)
-- ============================================================

-- ----------------------------
-- 日销售汇总表 (Daily Sales Aggregation)
-- ----------------------------
DROP TABLE IF EXISTS `dw_agg_sales_daily`;
CREATE TABLE `dw_agg_sales_daily` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `date_key` INT NOT NULL COMMENT '日期键',
  `product_key` BIGINT NOT NULL COMMENT '商品键',
  `shop_key` BIGINT NOT NULL COMMENT '店铺键',
  `order_count` INT NOT NULL DEFAULT 0 COMMENT '订单数',
  `quantity_sold` INT NOT NULL DEFAULT 0 COMMENT '销售数量',
  `gross_amount` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '销售总额',
  `net_amount` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '净销售额',
  `cost_amount` DECIMAL(14,2) DEFAULT 0 COMMENT '成本总额',
  `profit_amount` DECIMAL(14,2) DEFAULT 0 COMMENT '利润总额',
  `profit_rate` DECIMAL(5,2) DEFAULT 0 COMMENT '利润率%',
  `avg_order_value` DECIMAL(12,2) DEFAULT 0 COMMENT '客单价',
  `return_quantity` INT DEFAULT 0 COMMENT '退货数量',
  `return_amount` DECIMAL(14,2) DEFAULT 0 COMMENT '退货金额',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_date_product_shop` (`date_key`, `product_key`, `shop_key`),
  KEY `idx_date_key` (`date_key`),
  KEY `idx_product_key` (`product_key`),
  KEY `idx_shop_key` (`shop_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='日销售汇总表';

-- ----------------------------
-- 周销售汇总表 (Weekly Sales Aggregation)
-- ----------------------------
DROP TABLE IF EXISTS `dw_agg_sales_weekly`;
CREATE TABLE `dw_agg_sales_weekly` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `year` INT NOT NULL COMMENT '年份',
  `week` INT NOT NULL COMMENT '周数 1-53',
  `product_key` BIGINT NOT NULL COMMENT '商品键',
  `shop_key` BIGINT NOT NULL COMMENT '店铺键',
  `order_count` INT NOT NULL DEFAULT 0 COMMENT '订单数',
  `quantity_sold` INT NOT NULL DEFAULT 0 COMMENT '销售数量',
  `gross_amount` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '销售总额',
  `net_amount` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '净销售额',
  `cost_amount` DECIMAL(14,2) DEFAULT 0 COMMENT '成本总额',
  `profit_amount` DECIMAL(14,2) DEFAULT 0 COMMENT '利润总额',
  `profit_rate` DECIMAL(5,2) DEFAULT 0 COMMENT '利润率%',
  `avg_daily_sales` DECIMAL(12,2) DEFAULT 0 COMMENT '日均销售额',
  `wow_growth_rate` DECIMAL(5,2) DEFAULT NULL COMMENT '周环比增长率%',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_year_week_product_shop` (`year`, `week`, `product_key`, `shop_key`),
  KEY `idx_year_week` (`year`, `week`),
  KEY `idx_product_key` (`product_key`),
  KEY `idx_shop_key` (`shop_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='周销售汇总表';

-- ----------------------------
-- 月销售汇总表 (Monthly Sales Aggregation)
-- ----------------------------
DROP TABLE IF EXISTS `dw_agg_sales_monthly`;
CREATE TABLE `dw_agg_sales_monthly` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `year` INT NOT NULL COMMENT '年份',
  `month` INT NOT NULL COMMENT '月份 1-12',
  `product_key` BIGINT NOT NULL COMMENT '商品键',
  `shop_key` BIGINT NOT NULL COMMENT '店铺键',
  `order_count` INT NOT NULL DEFAULT 0 COMMENT '订单数',
  `quantity_sold` INT NOT NULL DEFAULT 0 COMMENT '销售数量',
  `gross_amount` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '销售总额',
  `net_amount` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '净销售额',
  `cost_amount` DECIMAL(14,2) DEFAULT 0 COMMENT '成本总额',
  `profit_amount` DECIMAL(14,2) DEFAULT 0 COMMENT '利润总额',
  `profit_rate` DECIMAL(5,2) DEFAULT 0 COMMENT '利润率%',
  `avg_daily_sales` DECIMAL(12,2) DEFAULT 0 COMMENT '日均销售额',
  `mom_growth_rate` DECIMAL(5,2) DEFAULT NULL COMMENT '月环比增长率%',
  `yoy_growth_rate` DECIMAL(5,2) DEFAULT NULL COMMENT '同比增长率%',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_year_month_product_shop` (`year`, `month`, `product_key`, `shop_key`),
  KEY `idx_year_month` (`year`, `month`),
  KEY `idx_product_key` (`product_key`),
  KEY `idx_shop_key` (`shop_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='月销售汇总表';

-- ----------------------------
-- 库存汇总表 (Inventory Aggregation)
-- ----------------------------
DROP TABLE IF EXISTS `dw_agg_inventory`;
CREATE TABLE `dw_agg_inventory` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `date_key` INT NOT NULL COMMENT '日期键',
  `warehouse_key` BIGINT NOT NULL COMMENT '仓库键',
  `total_sku_count` INT NOT NULL DEFAULT 0 COMMENT 'SKU数量',
  `total_on_hand` INT NOT NULL DEFAULT 0 COMMENT '总在库数量',
  `total_available` INT NOT NULL DEFAULT 0 COMMENT '总可用数量',
  `total_value` DECIMAL(16,2) DEFAULT 0 COMMENT '库存总价值',
  `avg_turnover_days` DECIMAL(10,2) DEFAULT NULL COMMENT '平均周转天数',
  `stockout_sku_count` INT DEFAULT 0 COMMENT '缺货SKU数',
  `overstock_sku_count` INT DEFAULT 0 COMMENT '滞销SKU数',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_date_warehouse` (`date_key`, `warehouse_key`),
  KEY `idx_date_key` (`date_key`),
  KEY `idx_warehouse_key` (`warehouse_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存汇总表';

-- ============================================================
-- 4. ETL元数据表 (ETL Metadata Tables)
-- ============================================================

-- ----------------------------
-- ETL任务日志表
-- ----------------------------
DROP TABLE IF EXISTS `dw_etl_job_log`;
CREATE TABLE `dw_etl_job_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `job_name` VARCHAR(128) NOT NULL COMMENT '任务名称',
  `job_type` VARCHAR(32) NOT NULL COMMENT '任务类型 FULL/INCREMENTAL',
  `source_table` VARCHAR(128) DEFAULT NULL COMMENT '源表',
  `target_table` VARCHAR(128) DEFAULT NULL COMMENT '目标表',
  `start_time` DATETIME NOT NULL COMMENT '开始时间',
  `end_time` DATETIME DEFAULT NULL COMMENT '结束时间',
  `duration_seconds` INT DEFAULT NULL COMMENT '耗时(秒)',
  `records_read` BIGINT DEFAULT 0 COMMENT '读取记录数',
  `records_written` BIGINT DEFAULT 0 COMMENT '写入记录数',
  `records_rejected` BIGINT DEFAULT 0 COMMENT '拒绝记录数',
  `status` VARCHAR(20) NOT NULL COMMENT '状态 RUNNING/SUCCESS/FAILED',
  `error_message` TEXT DEFAULT NULL COMMENT '错误信息',
  PRIMARY KEY (`id`),
  KEY `idx_job_name` (`job_name`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ETL任务日志表';

-- ----------------------------
-- 数据质量检查表
-- ----------------------------
DROP TABLE IF EXISTS `dw_data_quality_check`;
CREATE TABLE `dw_data_quality_check` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `check_name` VARCHAR(128) NOT NULL COMMENT '检查名称',
  `check_type` VARCHAR(32) NOT NULL COMMENT '检查类型 COMPLETENESS/ACCURACY/CONSISTENCY',
  `table_name` VARCHAR(128) NOT NULL COMMENT '表名',
  `column_name` VARCHAR(64) DEFAULT NULL COMMENT '列名',
  `check_rule` TEXT NOT NULL COMMENT '检查规则',
  `check_time` DATETIME NOT NULL COMMENT '检查时间',
  `total_records` BIGINT DEFAULT 0 COMMENT '总记录数',
  `passed_records` BIGINT DEFAULT 0 COMMENT '通过记录数',
  `failed_records` BIGINT DEFAULT 0 COMMENT '失败记录数',
  `pass_rate` DECIMAL(5,2) DEFAULT 0 COMMENT '通过率%',
  `status` VARCHAR(20) NOT NULL COMMENT '状态 PASS/FAIL/WARNING',
  `details` TEXT DEFAULT NULL COMMENT '详细信息',
  PRIMARY KEY (`id`),
  KEY `idx_check_name` (`check_name`),
  KEY `idx_table_name` (`table_name`),
  KEY `idx_check_time` (`check_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据质量检查表';

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 初始化数据
-- ============================================================

-- 插入默认记录（用于处理空值情况）
INSERT INTO `dw_dim_product` (`product_key`, `product_id`, `sku_code`, `product_name`, `status`, `effective_date`, `is_current`) 
VALUES (1, 0, 'UNKNOWN', '未知商品', 'ACTIVE', '2020-01-01', 1)
ON DUPLICATE KEY UPDATE `product_name` = '未知商品';

INSERT INTO `dw_dim_shop` (`shop_key`, `shop_id`, `shop_code`, `shop_name`, `status`, `effective_date`, `is_current`) 
VALUES (1, 0, 'UNKNOWN', '未知店铺', 'ACTIVE', '2020-01-01', 1)
ON DUPLICATE KEY UPDATE `shop_name` = '未知店铺';

INSERT INTO `dw_dim_warehouse` (`warehouse_key`, `warehouse_id`, `warehouse_code`, `warehouse_name`, `status`, `effective_date`, `is_current`) 
VALUES (1, 0, 'UNKNOWN', '未知仓库', 'ACTIVE', '2020-01-01', 1)
ON DUPLICATE KEY UPDATE `warehouse_name` = '未知仓库';

INSERT INTO `dw_dim_region` (`region_key`, `country_code`, `country_name`, `continent`, `is_current`) 
VALUES (1, 'XX', '未知地区', 'Unknown', 1)
ON DUPLICATE KEY UPDATE `country_name` = '未知地区';
