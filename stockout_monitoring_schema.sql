-- ===========================================
-- 产品断货点监控模型数据库表结构
-- Stock-Out Point Monitoring Model Database Schema
-- ===========================================

-- 1. 产品SPU日参数表
-- Product SPU Daily Parameters Table
CREATE TABLE IF NOT EXISTS `pms_commodity_params` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `company_id` BIGINT NOT NULL COMMENT '企业ID',
    `commodity_id` BIGINT NOT NULL COMMENT '产品ID',
    `commodity_code` VARCHAR(128) NOT NULL COMMENT '产品编码',
    `data_date` DATE NOT NULL COMMENT '数据日期',
    
    -- 销售指标
    `platform_sale_num` INT DEFAULT 0 COMMENT '平台销量',
    `daily_sale_qty` DECIMAL(10,2) DEFAULT 0.00 COMMENT '日均销量',
    `platform_sale_days` INT DEFAULT 0 COMMENT '平台在售天数',
    
    -- 库存指标
    `remaining_qty` INT DEFAULT 0 COMMENT '剩余库存数量',
    `open_intransit_qty` INT DEFAULT 0 COMMENT '在途库存数量',
    
    -- 时间参数
    `safety_days` INT DEFAULT 0 COMMENT '安全库存天数',
    `shipping_days` INT DEFAULT 0 COMMENT '运输天数',
    `production_days` INT DEFAULT 0 COMMENT '生产周期天数',
    `stock_days` DECIMAL(10,2) DEFAULT 0.00 COMMENT '库存可售天数',
    
    -- 断货点指标
    `rop_qty` INT DEFAULT 0 COMMENT '再订货点数量(ROP)',
    `oos_platform_date` DATE COMMENT '预计平台断货日期',
    `risk_level` VARCHAR(20) COMMENT '风险等级: LOW/MEDIUM/HIGH/CRITICAL',
    
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY `uk_commodity_date` (`company_id`, `commodity_id`, `data_date`),
    INDEX `idx_commodity_code` (`commodity_code`),
    INDEX `idx_data_date` (`data_date`),
    INDEX `idx_risk_level` (`risk_level`),
    INDEX `idx_oos_date` (`oos_platform_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品SPU日参数表';

-- 2. 产品SKU日参数表
-- Product SKU Daily Parameters Table
CREATE TABLE IF NOT EXISTS `pms_commodity_sku_params` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `company_id` BIGINT NOT NULL COMMENT '企业ID',
    `commodity_id` BIGINT NOT NULL COMMENT '产品ID',
    `commodity_code` VARCHAR(128) COMMENT '产品编码',
    `commodity_sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
    `commodity_sku_code` VARCHAR(128) NOT NULL COMMENT 'SKU编码',
    `data_date` DATE NOT NULL COMMENT '数据日期',
    
    -- 销售指标
    `platform_sale_num` INT DEFAULT 0 COMMENT '平台销量',
    `daily_sale_qty` DECIMAL(10,2) DEFAULT 0.00 COMMENT '日均销量',
    `platform_sale_days` INT DEFAULT 0 COMMENT '平台在售天数',
    
    -- 库存指标
    `remaining_qty` INT DEFAULT 0 COMMENT '剩余库存数量',
    `open_intransit_qty` INT DEFAULT 0 COMMENT '在途库存数量',
    
    -- 时间参数
    `safety_days` INT DEFAULT 0 COMMENT '安全库存天数',
    `shipping_days` INT DEFAULT 0 COMMENT '运输天数',
    `production_days` INT DEFAULT 0 COMMENT '生产周期天数',
    `stock_days` DECIMAL(10,2) DEFAULT 0.00 COMMENT '库存可售天数',
    
    -- 断货点指标
    `rop_qty` INT DEFAULT 0 COMMENT '再订货点数量(ROP)',
    `oos_platform_date` DATE COMMENT '预计平台断货日期',
    `risk_level` VARCHAR(20) COMMENT '风险等级: LOW/MEDIUM/HIGH/CRITICAL',
    
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY `uk_sku_date` (`company_id`, `commodity_sku_id`, `data_date`),
    INDEX `idx_commodity_id` (`commodity_id`),
    INDEX `idx_sku_code` (`commodity_sku_code`),
    INDEX `idx_data_date` (`data_date`),
    INDEX `idx_risk_level` (`risk_level`),
    INDEX `idx_oos_date` (`oos_platform_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品SKU日参数表';

-- 3. 区域仓配置表
-- Regional Warehouse Configuration Table
CREATE TABLE IF NOT EXISTS `region_warehouse_config` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `company_id` BIGINT NOT NULL COMMENT '企业ID',
    `region_warehouse_id` BIGINT NOT NULL COMMENT '区域仓ID',
    `region_warehouse_code` VARCHAR(64) NOT NULL COMMENT '区域仓编码',
    `region_warehouse_name` VARCHAR(128) NOT NULL COMMENT '区域仓名称',
    `region_code` VARCHAR(32) COMMENT '区域代码(US_WEST/US_EAST等)',
    `country_code` VARCHAR(10) COMMENT '国家代码',
    `warehouse_type` VARCHAR(32) NOT NULL COMMENT '仓库类型: FBA/REGIONAL',
    `is_active` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY `uk_region_wh_code` (`company_id`, `region_warehouse_code`),
    INDEX `idx_company_id` (`company_id`),
    INDEX `idx_warehouse_type` (`warehouse_type`),
    INDEX `idx_region_code` (`region_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='区域仓配置表';

-- 4. 区域仓与仓库绑定关系表
-- Regional Warehouse to Warehouse Binding Table
CREATE TABLE IF NOT EXISTS `region_warehouse_binding` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `company_id` BIGINT NOT NULL COMMENT '企业ID',
    `region_warehouse_id` BIGINT NOT NULL COMMENT '区域仓ID',
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID（关联wms_warehouse.id）',
    `warehouse_code` VARCHAR(64) COMMENT '仓库编码',
    `warehouse_name` VARCHAR(128) COMMENT '仓库名称',
    `binding_type` VARCHAR(32) DEFAULT 'STORAGE' COMMENT '绑定类型: STORAGE(存储仓)/TRANSIT(中转仓)',
    `priority` INT DEFAULT 1 COMMENT '优先级，数值越小优先级越高',
    `is_active` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY `uk_region_wh_binding` (`company_id`, `region_warehouse_id`, `warehouse_id`),
    INDEX `idx_region_warehouse_id` (`region_warehouse_id`),
    INDEX `idx_warehouse_id` (`warehouse_id`),
    INDEX `idx_company_id` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='区域仓与仓库绑定关系表';

-- 5. 仓库映射表（处理第三方仓库编码到wms_warehouse的映射）
-- Warehouse Mapping Table
CREATE TABLE IF NOT EXISTS `warehouse_mapping` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `company_id` BIGINT NOT NULL COMMENT '企业ID',
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID（关联wms_warehouse.id）',
    `source_system` VARCHAR(32) NOT NULL COMMENT '来源系统: JH/LX/OWMS/FBA',
    `external_warehouse_id` VARCHAR(128) COMMENT '外部仓库ID',
    `external_warehouse_code` VARCHAR(128) COMMENT '外部仓库编码',
    `external_warehouse_name` VARCHAR(128) COMMENT '外部仓库名称',
    `mapping_type` VARCHAR(32) DEFAULT 'PHYSICAL' COMMENT '映射类型: PHYSICAL(物理仓)/LOGICAL(逻辑仓)',
    `is_active` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY `uk_source_external` (`company_id`, `source_system`, `external_warehouse_code`),
    INDEX `idx_warehouse_id` (`warehouse_id`),
    INDEX `idx_company_id` (`company_id`),
    INDEX `idx_source_system` (`source_system`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库映射表';

-- 6. 区域订单比例配置表
-- Regional Order Ratio Configuration Table
CREATE TABLE IF NOT EXISTS `region_order_ratio_config` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `company_id` BIGINT NOT NULL COMMENT '企业ID',
    `commodity_id` BIGINT COMMENT '产品ID（NULL表示全局默认）',
    `commodity_sku_id` BIGINT COMMENT 'SKU ID（NULL表示SPU级）',
    `region_warehouse_id` BIGINT NOT NULL COMMENT '区域仓ID',
    `region_code` VARCHAR(32) NOT NULL COMMENT '区域代码',
    `order_ratio` DECIMAL(5,4) NOT NULL DEFAULT 0.0000 COMMENT '订单比例（0-1之间）',
    `effective_date` DATE COMMENT '生效日期',
    `expiry_date` DATE COMMENT '失效日期',
    `is_active` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_commodity_id` (`commodity_id`),
    INDEX `idx_sku_id` (`commodity_sku_id`),
    INDEX `idx_region_warehouse` (`region_warehouse_id`),
    INDEX `idx_company_id` (`company_id`),
    INDEX `idx_dates` (`effective_date`, `expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='区域订单比例配置表';

-- 7. 产品SKU区域仓维度快照表（核心表）
-- Product SKU Regional Warehouse Dimension Snapshot Table
CREATE TABLE IF NOT EXISTS `pms_commodity_sku_region_warehouse_params` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `monitor_date` DATE NOT NULL COMMENT '监控日期',
    `company_id` BIGINT NOT NULL COMMENT '企业ID',
    
    -- 业务模式维度
    `business_mode` VARCHAR(32) NOT NULL COMMENT '业务模式: FBA/REGIONAL',
    
    -- 区域仓维度
    `region_warehouse_id` BIGINT NOT NULL COMMENT '区域仓ID',
    `region_warehouse_code` VARCHAR(64) COMMENT '区域仓编码',
    `region_code` VARCHAR(32) COMMENT '区域代码',
    
    -- 仓库维度
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID（关联wms_warehouse.id）',
    `warehouse_code` VARCHAR(64) COMMENT '仓库编码',
    `warehouse_name` VARCHAR(128) COMMENT '仓库名称',
    
    -- 产品维度
    `commodity_id` BIGINT NOT NULL COMMENT '产品ID',
    `commodity_code` VARCHAR(128) NOT NULL COMMENT '产品编码',
    `commodity_sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
    `commodity_sku_code` VARCHAR(128) NOT NULL COMMENT 'SKU编码',
    
    -- 库存指标
    `onhand_qty` INT DEFAULT 0 COMMENT '海外仓现有库存(onhand)',
    `in_transit_qty` INT DEFAULT 0 COMMENT '在途库存(in_transit)',
    `backlog_qty` INT DEFAULT 0 COMMENT '余单/未发货(backlog)',
    `total_available_qty` INT DEFAULT 0 COMMENT '总可用库存=onhand+in_transit',
    
    -- 销售指标
    `region_order_ratio` DECIMAL(5,4) DEFAULT 0.0000 COMMENT '区域订单比例',
    `daily_sale_qty` DECIMAL(10,2) DEFAULT 0.00 COMMENT '原始日均销量',
    `region_daily_sale_qty` DECIMAL(10,2) DEFAULT 0.00 COMMENT '区域日均销量=daily_sale_qty*region_order_ratio',
    
    -- 时间参数
    `safety_days` INT DEFAULT 0 COMMENT '安全库存天数',
    `shipping_days` INT DEFAULT 0 COMMENT '运输天数',
    `production_days` INT DEFAULT 0 COMMENT '生产周期天数',
    `stock_days` DECIMAL(10,2) DEFAULT 0.00 COMMENT '库存可售天数',
    
    -- 断货点计算
    `safety_stock_qty` INT DEFAULT 0 COMMENT '安全库存数量=region_daily_sale_qty*safety_days',
    `rop_qty` INT DEFAULT 0 COMMENT '再订货点ROP=region_daily_sale_qty*(shipping_days+production_days)+safety_stock_qty',
    `gap_qty` INT DEFAULT 0 COMMENT '缺口数量=rop_qty-total_available_qty',
    `available_days` DECIMAL(10,2) DEFAULT 0.00 COMMENT '可售天数=total_available_qty/region_daily_sale_qty',
    `oos_date_est` DATE COMMENT '预计断货日期=monitor_date+available_days',
    `risk_level` VARCHAR(20) COMMENT '风险等级: LOW/MEDIUM/HIGH/CRITICAL',
    
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY `uk_snapshot` (`monitor_date`, `company_id`, `business_mode`, `region_warehouse_id`, `warehouse_id`, `commodity_sku_id`),
    INDEX `idx_monitor_date` (`monitor_date`),
    INDEX `idx_company_id` (`company_id`),
    INDEX `idx_business_mode` (`business_mode`),
    INDEX `idx_region_warehouse` (`region_warehouse_id`),
    INDEX `idx_warehouse` (`warehouse_id`),
    INDEX `idx_commodity` (`commodity_id`),
    INDEX `idx_sku` (`commodity_sku_id`),
    INDEX `idx_sku_code` (`commodity_sku_code`),
    INDEX `idx_risk_level` (`risk_level`),
    INDEX `idx_oos_date` (`oos_date_est`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品SKU区域仓维度快照表';

-- 8. 产品SPU区域仓维度快照表（汇总表）
-- Product SPU Regional Warehouse Dimension Snapshot Table
CREATE TABLE IF NOT EXISTS `pms_commodity_region_warehouse_params` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `monitor_date` DATE NOT NULL COMMENT '监控日期',
    `company_id` BIGINT NOT NULL COMMENT '企业ID',
    
    -- 业务模式维度
    `business_mode` VARCHAR(32) NOT NULL COMMENT '业务模式: FBA/REGIONAL',
    
    -- 区域仓维度
    `region_warehouse_id` BIGINT NOT NULL COMMENT '区域仓ID',
    `region_warehouse_code` VARCHAR(64) COMMENT '区域仓编码',
    `region_code` VARCHAR(32) COMMENT '区域代码',
    
    -- 仓库维度
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID（关联wms_warehouse.id）',
    `warehouse_code` VARCHAR(64) COMMENT '仓库编码',
    `warehouse_name` VARCHAR(128) COMMENT '仓库名称',
    
    -- 产品维度
    `commodity_id` BIGINT NOT NULL COMMENT '产品ID',
    `commodity_code` VARCHAR(128) NOT NULL COMMENT '产品编码',
    
    -- 库存指标（SKU汇总）
    `onhand_qty` INT DEFAULT 0 COMMENT '海外仓现有库存(onhand)',
    `in_transit_qty` INT DEFAULT 0 COMMENT '在途库存(in_transit)',
    `backlog_qty` INT DEFAULT 0 COMMENT '余单/未发货(backlog)',
    `total_available_qty` INT DEFAULT 0 COMMENT '总可用库存=onhand+in_transit',
    
    -- 销售指标
    `region_order_ratio` DECIMAL(5,4) DEFAULT 0.0000 COMMENT '区域订单比例',
    `daily_sale_qty` DECIMAL(10,2) DEFAULT 0.00 COMMENT '原始日均销量',
    `region_daily_sale_qty` DECIMAL(10,2) DEFAULT 0.00 COMMENT '区域日均销量=daily_sale_qty*region_order_ratio',
    
    -- 时间参数
    `safety_days` INT DEFAULT 0 COMMENT '安全库存天数',
    `shipping_days` INT DEFAULT 0 COMMENT '运输天数',
    `production_days` INT DEFAULT 0 COMMENT '生产周期天数',
    `stock_days` DECIMAL(10,2) DEFAULT 0.00 COMMENT '库存可售天数',
    
    -- 断货点计算
    `safety_stock_qty` INT DEFAULT 0 COMMENT '安全库存数量',
    `rop_qty` INT DEFAULT 0 COMMENT '再订货点ROP',
    `gap_qty` INT DEFAULT 0 COMMENT '缺口数量',
    `available_days` DECIMAL(10,2) DEFAULT 0.00 COMMENT '可售天数',
    `oos_date_est` DATE COMMENT '预计断货日期',
    `risk_level` VARCHAR(20) COMMENT '风险等级: LOW/MEDIUM/HIGH/CRITICAL',
    
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY `uk_snapshot` (`monitor_date`, `company_id`, `business_mode`, `region_warehouse_id`, `warehouse_id`, `commodity_id`),
    INDEX `idx_monitor_date` (`monitor_date`),
    INDEX `idx_company_id` (`company_id`),
    INDEX `idx_business_mode` (`business_mode`),
    INDEX `idx_region_warehouse` (`region_warehouse_id`),
    INDEX `idx_warehouse` (`warehouse_id`),
    INDEX `idx_commodity` (`commodity_id`),
    INDEX `idx_commodity_code` (`commodity_code`),
    INDEX `idx_risk_level` (`risk_level`),
    INDEX `idx_oos_date` (`oos_date_est`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品SPU区域仓维度快照表';

-- ===========================================
-- 存储过程定义
-- Stored Procedures
-- ===========================================

DELIMITER $$

-- 存储过程1: 同步产品SKU区域仓日参数
-- Procedure 1: Sync Product SKU Regional Warehouse Daily Parameters
DROP PROCEDURE IF EXISTS `sp_sync_pms_commodity_sku_region_wh_params_daily`$$
CREATE PROCEDURE `sp_sync_pms_commodity_sku_region_wh_params_daily`(
    IN p_company_id BIGINT,
    IN p_monitor_date DATE
)
BEGIN
    DECLARE v_error_message VARCHAR(500);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Error: ', v_error_message) AS error_message;
    END;
    
    START TRANSACTION;
    
    -- 删除当天已有数据
    DELETE FROM pms_commodity_sku_region_warehouse_params
    WHERE company_id = p_company_id AND monitor_date = p_monitor_date;
    
    -- 插入区域仓模式数据（REGIONAL）
    -- 基于区域仓绑定关系聚合库存和在途
    INSERT INTO pms_commodity_sku_region_warehouse_params (
        monitor_date, company_id, business_mode,
        region_warehouse_id, region_warehouse_code, region_code,
        warehouse_id, warehouse_code, warehouse_name,
        commodity_id, commodity_code, commodity_sku_id, commodity_sku_code,
        onhand_qty, in_transit_qty, backlog_qty, total_available_qty,
        region_order_ratio, daily_sale_qty, region_daily_sale_qty,
        safety_days, shipping_days, production_days, stock_days,
        safety_stock_qty, rop_qty, gap_qty, available_days, oos_date_est, risk_level
    )
    SELECT
        p_monitor_date AS monitor_date,
        p_company_id AS company_id,
        'REGIONAL' AS business_mode,
        
        -- 区域仓维度
        rwc.region_warehouse_id,
        rwc.region_warehouse_code,
        rwc.region_code,
        
        -- 仓库维度
        rwb.warehouse_id,
        rwb.warehouse_code,
        rwb.warehouse_name,
        
        -- 产品维度
        sku_params.commodity_id,
        sku_params.commodity_code,
        sku_params.commodity_sku_id,
        sku_params.commodity_sku_code,
        
        -- 库存指标（这里需要实际对接JH+LX仓库存数据，暂用params中的数据）
        COALESCE(sku_params.remaining_qty, 0) AS onhand_qty,
        COALESCE(sku_params.open_intransit_qty, 0) AS in_transit_qty,
        0 AS backlog_qty, -- 待实现
        COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0) AS total_available_qty,
        
        -- 销售指标
        COALESCE(ratio.order_ratio, 0.25) AS region_order_ratio, -- 默认25%
        COALESCE(sku_params.daily_sale_qty, 0) AS daily_sale_qty,
        COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25) AS region_daily_sale_qty,
        
        -- 时间参数
        COALESCE(sku_params.safety_days, 15) AS safety_days,
        COALESCE(sku_params.shipping_days, 30) AS shipping_days,
        COALESCE(sku_params.production_days, 15) AS production_days,
        COALESCE(sku_params.stock_days, 0) AS stock_days,
        
        -- 断货点计算
        CEIL(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25) * COALESCE(sku_params.safety_days, 15)) AS safety_stock_qty,
        CEIL(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25) * 
            (COALESCE(sku_params.shipping_days, 30) + COALESCE(sku_params.production_days, 15) + COALESCE(sku_params.safety_days, 15))) AS rop_qty,
        CEIL(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25) * 
            (COALESCE(sku_params.shipping_days, 30) + COALESCE(sku_params.production_days, 15) + COALESCE(sku_params.safety_days, 15))) -
            (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) AS gap_qty,
        CASE 
            WHEN COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25) > 0 THEN
                (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) / 
                (COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25))
            ELSE 999
        END AS available_days,
        DATE_ADD(p_monitor_date, INTERVAL CAST(
            CASE 
                WHEN COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25) > 0 THEN
                    (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) / 
                    (COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25))
                ELSE 999
            END AS SIGNED) DAY) AS oos_date_est,
        CASE
            WHEN (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) / 
                NULLIF(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25), 0) <= 7 THEN 'CRITICAL'
            WHEN (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) / 
                NULLIF(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25), 0) <= 15 THEN 'HIGH'
            WHEN (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) / 
                NULLIF(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 0.25), 0) <= 30 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_level
    FROM
        pms_commodity_sku_params sku_params
        INNER JOIN region_warehouse_config rwc 
            ON rwc.company_id = p_company_id 
            AND rwc.warehouse_type = 'REGIONAL'
            AND rwc.is_active = 1
        INNER JOIN region_warehouse_binding rwb 
            ON rwb.company_id = p_company_id 
            AND rwb.region_warehouse_id = rwc.region_warehouse_id
            AND rwb.is_active = 1
        LEFT JOIN region_order_ratio_config ratio 
            ON ratio.company_id = p_company_id
            AND ratio.commodity_sku_id = sku_params.commodity_sku_id
            AND ratio.region_warehouse_id = rwc.region_warehouse_id
            AND (ratio.effective_date IS NULL OR ratio.effective_date <= p_monitor_date)
            AND (ratio.expiry_date IS NULL OR ratio.expiry_date >= p_monitor_date)
            AND ratio.is_active = 1
    WHERE
        sku_params.company_id = p_company_id
        AND sku_params.data_date = p_monitor_date;
    
    -- 插入FBA模式数据
    -- FBA模式使用FBA平台库存作为海外仓库存
    INSERT INTO pms_commodity_sku_region_warehouse_params (
        monitor_date, company_id, business_mode,
        region_warehouse_id, region_warehouse_code, region_code,
        warehouse_id, warehouse_code, warehouse_name,
        commodity_id, commodity_code, commodity_sku_id, commodity_sku_code,
        onhand_qty, in_transit_qty, backlog_qty, total_available_qty,
        region_order_ratio, daily_sale_qty, region_daily_sale_qty,
        safety_days, shipping_days, production_days, stock_days,
        safety_stock_qty, rop_qty, gap_qty, available_days, oos_date_est, risk_level
    )
    SELECT
        p_monitor_date AS monitor_date,
        p_company_id AS company_id,
        'FBA' AS business_mode,
        
        -- 区域仓维度（FBA逻辑仓）
        rwc.region_warehouse_id,
        rwc.region_warehouse_code,
        rwc.region_code,
        
        -- 仓库维度（FBA使用逻辑仓）
        rwb.warehouse_id,
        rwb.warehouse_code,
        rwb.warehouse_name,
        
        -- 产品维度
        sku_params.commodity_id,
        sku_params.commodity_code,
        sku_params.commodity_sku_id,
        sku_params.commodity_sku_code,
        
        -- 库存指标（FBA从平台库存获取）
        COALESCE(sku_params.remaining_qty, 0) AS onhand_qty,
        COALESCE(sku_params.open_intransit_qty, 0) AS in_transit_qty,
        0 AS backlog_qty,
        COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0) AS total_available_qty,
        
        -- 销售指标
        COALESCE(ratio.order_ratio, 1.0) AS region_order_ratio, -- FBA默认100%
        COALESCE(sku_params.daily_sale_qty, 0) AS daily_sale_qty,
        COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0) AS region_daily_sale_qty,
        
        -- 时间参数
        COALESCE(sku_params.safety_days, 15) AS safety_days,
        COALESCE(sku_params.shipping_days, 30) AS shipping_days,
        COALESCE(sku_params.production_days, 15) AS production_days,
        COALESCE(sku_params.stock_days, 0) AS stock_days,
        
        -- 断货点计算
        CEIL(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0) * COALESCE(sku_params.safety_days, 15)) AS safety_stock_qty,
        CEIL(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0) * 
            (COALESCE(sku_params.shipping_days, 30) + COALESCE(sku_params.production_days, 15) + COALESCE(sku_params.safety_days, 15))) AS rop_qty,
        CEIL(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0) * 
            (COALESCE(sku_params.shipping_days, 30) + COALESCE(sku_params.production_days, 15) + COALESCE(sku_params.safety_days, 15))) -
            (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) AS gap_qty,
        CASE 
            WHEN COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0) > 0 THEN
                (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) / 
                (COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0))
            ELSE 999
        END AS available_days,
        DATE_ADD(p_monitor_date, INTERVAL CAST(
            CASE 
                WHEN COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0) > 0 THEN
                    (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) / 
                    (COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0))
                ELSE 999
            END AS SIGNED) DAY) AS oos_date_est,
        CASE
            WHEN (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) / 
                NULLIF(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0), 0) <= 7 THEN 'CRITICAL'
            WHEN (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) / 
                NULLIF(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0), 0) <= 15 THEN 'HIGH'
            WHEN (COALESCE(sku_params.remaining_qty, 0) + COALESCE(sku_params.open_intransit_qty, 0)) / 
                NULLIF(COALESCE(sku_params.daily_sale_qty, 0) * COALESCE(ratio.order_ratio, 1.0), 0) <= 30 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_level
    FROM
        pms_commodity_sku_params sku_params
        INNER JOIN region_warehouse_config rwc 
            ON rwc.company_id = p_company_id 
            AND rwc.warehouse_type = 'FBA'
            AND rwc.is_active = 1
        INNER JOIN region_warehouse_binding rwb 
            ON rwb.company_id = p_company_id 
            AND rwb.region_warehouse_id = rwc.region_warehouse_id
            AND rwb.is_active = 1
        LEFT JOIN region_order_ratio_config ratio 
            ON ratio.company_id = p_company_id
            AND ratio.commodity_sku_id = sku_params.commodity_sku_id
            AND ratio.region_warehouse_id = rwc.region_warehouse_id
            AND (ratio.effective_date IS NULL OR ratio.effective_date <= p_monitor_date)
            AND (ratio.expiry_date IS NULL OR ratio.expiry_date >= p_monitor_date)
            AND ratio.is_active = 1
    WHERE
        sku_params.company_id = p_company_id
        AND sku_params.data_date = p_monitor_date;
    
    COMMIT;
    
    SELECT CONCAT('Successfully synced ', ROW_COUNT(), ' records for date: ', p_monitor_date) AS result;
END$$

-- 存储过程2: 同步产品SPU区域仓日参数（从SKU聚合）
-- Procedure 2: Sync Product SPU Regional Warehouse Daily Parameters
DROP PROCEDURE IF EXISTS `sp_sync_pms_commodity_region_wh_params_daily`$$
CREATE PROCEDURE `sp_sync_pms_commodity_region_wh_params_daily`(
    IN p_company_id BIGINT,
    IN p_monitor_date DATE
)
BEGIN
    DECLARE v_error_message VARCHAR(500);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Error: ', v_error_message) AS error_message;
    END;
    
    START TRANSACTION;
    
    -- 删除当天已有数据
    DELETE FROM pms_commodity_region_warehouse_params
    WHERE company_id = p_company_id AND monitor_date = p_monitor_date;
    
    -- 从SKU快照聚合到SPU级别
    INSERT INTO pms_commodity_region_warehouse_params (
        monitor_date, company_id, business_mode,
        region_warehouse_id, region_warehouse_code, region_code,
        warehouse_id, warehouse_code, warehouse_name,
        commodity_id, commodity_code,
        onhand_qty, in_transit_qty, backlog_qty, total_available_qty,
        region_order_ratio, daily_sale_qty, region_daily_sale_qty,
        safety_days, shipping_days, production_days, stock_days,
        safety_stock_qty, rop_qty, gap_qty, available_days, oos_date_est, risk_level
    )
    SELECT
        monitor_date,
        company_id,
        business_mode,
        region_warehouse_id,
        region_warehouse_code,
        region_code,
        warehouse_id,
        warehouse_code,
        warehouse_name,
        commodity_id,
        commodity_code,
        
        -- 聚合库存指标
        SUM(onhand_qty) AS onhand_qty,
        SUM(in_transit_qty) AS in_transit_qty,
        SUM(backlog_qty) AS backlog_qty,
        SUM(total_available_qty) AS total_available_qty,
        
        -- 销售指标（使用平均或加权）
        AVG(region_order_ratio) AS region_order_ratio,
        SUM(daily_sale_qty) AS daily_sale_qty,
        SUM(region_daily_sale_qty) AS region_daily_sale_qty,
        
        -- 时间参数（使用最大值作为保守估计）
        MAX(safety_days) AS safety_days,
        MAX(shipping_days) AS shipping_days,
        MAX(production_days) AS production_days,
        AVG(stock_days) AS stock_days,
        
        -- 断货点计算（重新计算）
        SUM(safety_stock_qty) AS safety_stock_qty,
        SUM(rop_qty) AS rop_qty,
        SUM(gap_qty) AS gap_qty,
        CASE 
            WHEN SUM(region_daily_sale_qty) > 0 THEN
                SUM(total_available_qty) / SUM(region_daily_sale_qty)
            ELSE 999
        END AS available_days,
        DATE_ADD(p_monitor_date, INTERVAL CAST(
            CASE 
                WHEN SUM(region_daily_sale_qty) > 0 THEN
                    SUM(total_available_qty) / SUM(region_daily_sale_qty)
                ELSE 999
            END AS SIGNED) DAY) AS oos_date_est,
        -- 风险等级取最严重的
        CASE
            WHEN MIN(CASE risk_level 
                WHEN 'CRITICAL' THEN 1 
                WHEN 'HIGH' THEN 2 
                WHEN 'MEDIUM' THEN 3 
                ELSE 4 END) = 1 THEN 'CRITICAL'
            WHEN MIN(CASE risk_level 
                WHEN 'CRITICAL' THEN 1 
                WHEN 'HIGH' THEN 2 
                WHEN 'MEDIUM' THEN 3 
                ELSE 4 END) = 2 THEN 'HIGH'
            WHEN MIN(CASE risk_level 
                WHEN 'CRITICAL' THEN 1 
                WHEN 'HIGH' THEN 2 
                WHEN 'MEDIUM' THEN 3 
                ELSE 4 END) = 3 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_level
    FROM
        pms_commodity_sku_region_warehouse_params
    WHERE
        company_id = p_company_id
        AND monitor_date = p_monitor_date
    GROUP BY
        monitor_date, company_id, business_mode,
        region_warehouse_id, region_warehouse_code, region_code,
        warehouse_id, warehouse_code, warehouse_name,
        commodity_id, commodity_code;
    
    COMMIT;
    
    SELECT CONCAT('Successfully synced ', ROW_COUNT(), ' SPU records for date: ', p_monitor_date) AS result;
END$$

-- 存储过程3: JH店铺同步到cos_shop
-- Procedure 3: Sync JH Shop to cos_shop
DROP PROCEDURE IF EXISTS `sp_sync_jh_shop_to_cos_shop`$$
CREATE PROCEDURE `sp_sync_jh_shop_to_cos_shop`()
BEGIN
    DECLARE v_error_message VARCHAR(500);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Error: ', v_error_message) AS error_message;
    END;
    
    START TRANSACTION;
    
    -- 从amf_jh_ecommerce同步JH平台店铺到cos_shop
    -- 注意：JH店铺通过extend_id字段关联
    -- 这里提供框架，实际逻辑需根据JH数据结构调整
    
    -- 示例：插入或更新JH店铺到cos_shop
    INSERT INTO cos_shop (
        id, external_id, channel_type, channel_model, channel_name,
        company_id, platform_shop_id, create_time, deleted
    )
    SELECT
        COALESCE(cs.id, jh.id) AS id,
        CAST(jh.id AS CHAR) AS external_id,
        99 AS channel_type, -- JH平台类型，需定义
        'JH' AS channel_model,
        jh.platform_name AS channel_name,
        jh.user_key AS company_id, -- 需映射到实际company_id
        jh.id AS platform_shop_id,
        NOW() AS create_time,
        0 AS deleted
    FROM
        amf_jh_ecommerce jh
        LEFT JOIN cos_shop cs ON cs.platform_shop_id = jh.id AND cs.channel_model = 'JH'
    WHERE
        jh.is_access = 1
        AND jh.status = 1
    ON DUPLICATE KEY UPDATE
        external_id = VALUES(external_id),
        channel_name = VALUES(channel_name),
        update_time = NOW();
    
    COMMIT;
    
    SELECT 'JH shops synced to cos_shop successfully' AS result;
END$$

-- 存储过程4: JH仓库关系同步到cos_shop_warehouse_relation
-- Procedure 4: Sync JH Warehouse Relations
DROP PROCEDURE IF EXISTS `sp_sync_jh_warehouse_relation`$$
CREATE PROCEDURE `sp_sync_jh_warehouse_relation`()
BEGIN
    DECLARE v_error_message VARCHAR(500);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Error: ', v_error_message) AS error_message;
    END;
    
    START TRANSACTION;
    
    -- 从amf_jh_shop_warehouse同步到cos_shop_warehouse_relation
    -- relation_type=4 表示发货仓
    INSERT INTO cos_shop_warehouse_relation (
        id, company_id, shop_id, warehouse_id, relation_type, priority,
        is_delete, create_time
    )
    SELECT
        CONCAT('JH_', jh_sw.id) AS id, -- 生成唯一ID
        COALESCE(cs.company_id, 0) AS company_id,
        cs.id AS shop_id,
        wm.warehouse_id AS warehouse_id,
        4 AS relation_type, -- 发货仓
        COALESCE(jh_sw.seq, 1) AS priority,
        CASE WHEN jh_sw.status = 1 THEN 0 ELSE 1 END AS is_delete,
        NOW() AS create_time
    FROM
        amf_jh_shop_warehouse jh_sw
        INNER JOIN cos_shop cs 
            ON cs.platform_shop_id = jh_sw.shopId 
            AND cs.channel_model = 'JH'
            AND cs.deleted = 0
        INNER JOIN warehouse_mapping wm 
            ON wm.source_system = 'JH'
            AND wm.external_warehouse_id = CAST(jh_sw.warehouse_id AS CHAR)
            AND wm.is_active = 1
    WHERE
        jh_sw.status = 1
    ON DUPLICATE KEY UPDATE
        priority = VALUES(priority),
        is_delete = VALUES(is_delete),
        update_time = NOW();
    
    COMMIT;
    
    SELECT 'JH warehouse relations synced successfully' AS result;
END$$

DELIMITER ;

-- ===========================================
-- 示例数据插入（测试用）
-- Sample Data Insertion (For Testing)
-- ===========================================

-- 插入示例区域仓配置
INSERT INTO `region_warehouse_config` 
    (`company_id`, `region_warehouse_id`, `region_warehouse_code`, `region_warehouse_name`, 
     `region_code`, `country_code`, `warehouse_type`, `is_active`)
VALUES
    (1, 1001, 'RW_US_WEST', '美西区域仓', 'US_WEST', 'US', 'REGIONAL', 1),
    (1, 1002, 'RW_US_EAST', '美东区域仓', 'US_EAST', 'US', 'REGIONAL', 1),
    (1, 2001, 'FBA_US_WEST', 'FBA美西', 'US_WEST', 'US', 'FBA', 1),
    (1, 2002, 'FBA_US_EAST', 'FBA美东', 'US_EAST', 'US', 'FBA', 1)
ON DUPLICATE KEY UPDATE `update_time` = CURRENT_TIMESTAMP;

-- 插入示例区域仓绑定关系（需要先有wms_warehouse数据）
-- INSERT INTO `region_warehouse_binding` ...

-- 插入示例仓库映射
-- INSERT INTO `warehouse_mapping` ...

-- 插入示例区域订单比例配置
INSERT INTO `region_order_ratio_config`
    (`company_id`, `commodity_id`, `commodity_sku_id`, `region_warehouse_id`, 
     `region_code`, `order_ratio`, `effective_date`, `is_active`)
VALUES
    (1, NULL, NULL, 1001, 'US_WEST', 0.3000, '2024-01-01', 1),
    (1, NULL, NULL, 1002, 'US_EAST', 0.2500, '2024-01-01', 1),
    (1, NULL, NULL, 2001, 'US_WEST', 0.2500, '2024-01-01', 1),
    (1, NULL, NULL, 2002, 'US_EAST', 0.2000, '2024-01-01', 1)
ON DUPLICATE KEY UPDATE `update_time` = CURRENT_TIMESTAMP;
