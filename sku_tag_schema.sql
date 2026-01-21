-- SKU Tagging System Database Schema
-- SKU标签系统数据库表结构

-- ----------------------------
-- Table structure for sku_tag_group
-- 标签组配置表
-- ----------------------------
DROP TABLE IF EXISTS `sku_tag_group`;
CREATE TABLE `sku_tag_group` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签组ID',
  `tag_group_code` varchar(64) NOT NULL COMMENT '标签组编码',
  `tag_group_name` varchar(128) NOT NULL COMMENT '标签组名称',
  `tag_type` varchar(32) NOT NULL DEFAULT 'SINGLE' COMMENT '标签类型：SINGLE(单选), MULTI(多选)',
  `description` varchar(512) DEFAULT NULL COMMENT '标签组描述',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tag_group_code` (`tag_group_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='SKU标签组配置表';

-- ----------------------------
-- Table structure for sku_tag_value
-- 标签值配置表
-- ----------------------------
DROP TABLE IF EXISTS `sku_tag_value`;
CREATE TABLE `sku_tag_value` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签值ID',
  `tag_group_id` bigint NOT NULL COMMENT '标签组ID',
  `tag_value_code` varchar(64) NOT NULL COMMENT '标签值编码',
  `tag_value_name` varchar(128) NOT NULL COMMENT '标签值名称',
  `sort_order` int DEFAULT '0' COMMENT '排序顺序',
  `description` varchar(512) DEFAULT NULL COMMENT '标签值描述',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_group_value` (`tag_group_id`, `tag_value_code`),
  KEY `idx_tag_group_id` (`tag_group_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='SKU标签值配置表';

-- ----------------------------
-- Table structure for sku_tag_result
-- SKU标签结果表
-- ----------------------------
DROP TABLE IF EXISTS `sku_tag_result`;
CREATE TABLE `sku_tag_result` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签结果ID',
  `sku_id` varchar(128) NOT NULL COMMENT 'SKU编码',
  `tag_group_id` bigint NOT NULL COMMENT '标签组ID',
  `tag_value_id` bigint NOT NULL COMMENT '标签值ID',
  `source` varchar(32) NOT NULL COMMENT '标签来源：RULE(规则), MANUAL(人工)',
  `rule_code` varchar(64) DEFAULT NULL COMMENT '规则编码（来源为RULE时）',
  `rule_version` int DEFAULT NULL COMMENT '规则版本（来源为RULE时）',
  `operator` varchar(64) DEFAULT NULL COMMENT '操作人（来源为MANUAL时）',
  `reason` varchar(512) DEFAULT NULL COMMENT '打标原因',
  `is_active` tinyint NOT NULL DEFAULT '1' COMMENT '是否生效：0-失效，1-生效',
  `valid_from` datetime DEFAULT NULL COMMENT '有效期开始时间',
  `valid_to` datetime DEFAULT NULL COMMENT '有效期结束时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sku_tag_group` (`sku_id`, `tag_group_id`, `is_active`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_tag_group_id` (`tag_group_id`),
  KEY `idx_tag_value_id` (`tag_value_id`),
  KEY `idx_source` (`source`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_update_time` (`update_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='SKU标签结果表';

-- ----------------------------
-- Table structure for sku_tag_history
-- SKU标签历史记录表
-- ----------------------------
DROP TABLE IF EXISTS `sku_tag_history`;
CREATE TABLE `sku_tag_history` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '历史记录ID',
  `sku_id` varchar(128) NOT NULL COMMENT 'SKU编码',
  `tag_group_id` bigint NOT NULL COMMENT '标签组ID',
  `old_tag_value_id` bigint DEFAULT NULL COMMENT '旧标签值ID',
  `new_tag_value_id` bigint DEFAULT NULL COMMENT '新标签值ID',
  `source` varchar(32) NOT NULL COMMENT '标签来源：RULE(规则), MANUAL(人工)',
  `rule_code` varchar(64) DEFAULT NULL COMMENT '规则编码（来源为RULE时）',
  `rule_version` int DEFAULT NULL COMMENT '规则版本（来源为RULE时）',
  `operator` varchar(64) DEFAULT NULL COMMENT '操作人（来源为MANUAL时）',
  `reason` varchar(512) DEFAULT NULL COMMENT '变更原因',
  `operation_type` varchar(32) NOT NULL COMMENT '操作类型：CREATE(新增), UPDATE(更新), DELETE(删除)',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_tag_group_id` (`tag_group_id`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_operation_type` (`operation_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='SKU标签历史记录表';

-- ----------------------------
-- Table structure for sku_tag_rule
-- SKU标签规则表
-- ----------------------------
DROP TABLE IF EXISTS `sku_tag_rule`;
CREATE TABLE `sku_tag_rule` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `rule_code` varchar(64) NOT NULL COMMENT '规则编码',
  `rule_name` varchar(128) NOT NULL COMMENT '规则名称',
  `tag_group_id` bigint NOT NULL COMMENT '标签组ID',
  `tag_value_id` bigint NOT NULL COMMENT '标签值ID',
  `rule_type` varchar(32) NOT NULL COMMENT '规则类型：JAVA_EXPR, SQL_QUERY, API_CALL',
  `rule_content` text NOT NULL COMMENT '规则内容：表达式/SQL/API配置',
  `rule_params` json DEFAULT NULL COMMENT '规则参数配置',
  `scope_config` json DEFAULT NULL COMMENT '适用范围配置（站点/店铺/国家/类目等）',
  `priority` int DEFAULT '0' COMMENT '优先级（数字越大优先级越高）',
  `version` int NOT NULL DEFAULT '1' COMMENT '规则版本',
  `status` varchar(32) NOT NULL DEFAULT 'DRAFT' COMMENT '状态：DRAFT(草稿), ENABLED(启用), DISABLED(停用)',
  `description` varchar(512) DEFAULT NULL COMMENT '规则描述',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新人',
  `published_time` datetime DEFAULT NULL COMMENT '发布时间',
  `published_user` varchar(64) DEFAULT NULL COMMENT '发布人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rule_code_version` (`rule_code`, `version`),
  KEY `idx_tag_group_id` (`tag_group_id`),
  KEY `idx_status` (`status`),
  KEY `idx_priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='SKU标签规则表';

-- ----------------------------
-- Initialize Cargo Grade Tag Group and Values
-- 初始化货盘等级标签组和标签值
-- ----------------------------

-- Insert Tag Group: CARGO_GRADE
INSERT INTO `sku_tag_group` (`tag_group_code`, `tag_group_name`, `tag_type`, `description`, `status`, `create_user`)
VALUES ('CARGO_GRADE', '货盘等级', 'SINGLE', '商品货盘等级分类：S级(优质)、A级(良好)、B级(一般)、C级(较差)', 1, 'system');

-- Get the inserted tag group id (will be used in values insertion)
SET @tag_group_id = LAST_INSERT_ID();

-- Insert Tag Values: S, A, B, C
INSERT INTO `sku_tag_value` (`tag_group_id`, `tag_value_code`, `tag_value_name`, `sort_order`, `description`, `status`)
VALUES 
  (@tag_group_id, 'S', 'S级货盘', 1, '优质货盘：销量高、利润好、周转快', 1),
  (@tag_group_id, 'A', 'A级货盘', 2, '良好货盘：销量较好、利润可观', 1),
  (@tag_group_id, 'B', 'B级货盘', 3, '一般货盘：销量一般、利润一般', 1),
  (@tag_group_id, 'C', 'C级货盘', 4, '较差货盘：销量低、周转慢、需优化', 1);

-- ----------------------------
-- Example Tag Rules for Cargo Grade
-- 货盘等级标签规则示例
-- ----------------------------

-- Example Rule 1: S级货盘 - 高销量高利润
INSERT INTO `sku_tag_rule` (`rule_code`, `rule_name`, `tag_group_id`, `tag_value_id`, `rule_type`, `rule_content`, `rule_params`, `priority`, `status`, `description`, `create_user`)
SELECT 
  'CARGO_GRADE_S_RULE',
  '货盘S级规则',
  stg.id,
  stv.id,
  'JAVA_EXPR',
  'sales_volume >= 1000 && profit_rate >= 0.3 && turnover_days <= 15',
  '{"inputs": ["sales_volume", "profit_rate", "turnover_days"]}',
  100,
  'DRAFT',
  '销量>=1000且利润率>=30%且周转天数<=15天，判定为S级货盘',
  'system'
FROM 
  sku_tag_group stg
  JOIN sku_tag_value stv ON stg.id = stv.tag_group_id
WHERE 
  stg.tag_group_code = 'CARGO_GRADE' 
  AND stv.tag_value_code = 'S';

-- Example Rule 2: A级货盘 - 较好销量和利润
INSERT INTO `sku_tag_rule` (`rule_code`, `rule_name`, `tag_group_id`, `tag_value_id`, `rule_type`, `rule_content`, `rule_params`, `priority`, `status`, `description`, `create_user`)
SELECT 
  'CARGO_GRADE_A_RULE',
  '货盘A级规则',
  stg.id,
  stv.id,
  'JAVA_EXPR',
  'sales_volume >= 500 && profit_rate >= 0.2 && turnover_days <= 30',
  '{"inputs": ["sales_volume", "profit_rate", "turnover_days"]}',
  90,
  'DRAFT',
  '销量>=500且利润率>=20%且周转天数<=30天，判定为A级货盘',
  'system'
FROM 
  sku_tag_group stg
  JOIN sku_tag_value stv ON stg.id = stv.tag_group_id
WHERE 
  stg.tag_group_code = 'CARGO_GRADE' 
  AND stv.tag_value_code = 'A';

-- Example Rule 3: B级货盘 - 一般销量
INSERT INTO `sku_tag_rule` (`rule_code`, `rule_name`, `tag_group_id`, `tag_value_id`, `rule_type`, `rule_content`, `rule_params`, `priority`, `status`, `description`, `create_user`)
SELECT 
  'CARGO_GRADE_B_RULE',
  '货盘B级规则',
  stg.id,
  stv.id,
  'JAVA_EXPR',
  'sales_volume >= 100 && profit_rate >= 0.1 && turnover_days <= 60',
  '{"inputs": ["sales_volume", "profit_rate", "turnover_days"]}',
  80,
  'DRAFT',
  '销量>=100且利润率>=10%且周转天数<=60天，判定为B级货盘',
  'system'
FROM 
  sku_tag_group stg
  JOIN sku_tag_value stv ON stg.id = stv.tag_group_id
WHERE 
  stg.tag_group_code = 'CARGO_GRADE' 
  AND stv.tag_value_code = 'B';

-- Example Rule 4: C级货盘 - 低销量或滞销
INSERT INTO `sku_tag_rule` (`rule_code`, `rule_name`, `tag_group_id`, `tag_value_id`, `rule_type`, `rule_content`, `rule_params`, `priority`, `status`, `description`, `create_user`)
SELECT 
  'CARGO_GRADE_C_RULE',
  '货盘C级规则',
  stg.id,
  stv.id,
  'JAVA_EXPR',
  'sales_volume < 100 || profit_rate < 0.1 || turnover_days > 60',
  '{"inputs": ["sales_volume", "profit_rate", "turnover_days"]}',
  70,
  'DRAFT',
  '销量<100或利润率<10%或周转天数>60天，判定为C级货盘',
  'system'
FROM 
  sku_tag_group stg
  JOIN sku_tag_value stv ON stg.id = stv.tag_group_id
WHERE 
  stg.tag_group_code = 'CARGO_GRADE' 
  AND stv.tag_value_code = 'C';
