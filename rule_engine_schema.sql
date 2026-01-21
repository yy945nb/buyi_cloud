-- Rule Engine Database Schema
-- 规则引擎数据库表结构

-- ----------------------------
-- Table structure for rule_config
-- 规则配置表
-- ----------------------------
DROP TABLE IF EXISTS `rule_config`;
CREATE TABLE `rule_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `rule_code` varchar(64) NOT NULL COMMENT '规则编码',
  `rule_name` varchar(128) NOT NULL COMMENT '规则名称',
  `rule_type` varchar(32) NOT NULL COMMENT '规则类型：JAVA_EXPR(Java表达式), SQL_QUERY(SQL查询), API_CALL(API接口调用)',
  `rule_content` text NOT NULL COMMENT '规则内容：表达式/SQL语句/API配置',
  `rule_params` json DEFAULT NULL COMMENT '规则参数配置（JSON格式）',
  `description` varchar(512) DEFAULT NULL COMMENT '规则描述',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `priority` int DEFAULT '0' COMMENT '优先级（数字越大优先级越高）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rule_code` (`rule_code`),
  KEY `idx_rule_type` (`rule_type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='规则配置表';

-- ----------------------------
-- Table structure for rule_flow
-- 规则流程编排表
-- ----------------------------
DROP TABLE IF EXISTS `rule_flow`;
CREATE TABLE `rule_flow` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '流程ID',
  `flow_code` varchar(64) NOT NULL COMMENT '流程编码',
  `flow_name` varchar(128) NOT NULL COMMENT '流程名称',
  `flow_config` json NOT NULL COMMENT '流程配置（包含规则执行顺序、条件跳转等）',
  `description` varchar(512) DEFAULT NULL COMMENT '流程描述',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_flow_code` (`flow_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='规则流程编排表';

-- ----------------------------
-- Table structure for rule_execution_log
-- 规则执行日志表
-- ----------------------------
DROP TABLE IF EXISTS `rule_execution_log`;
CREATE TABLE `rule_execution_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `flow_code` varchar(64) DEFAULT NULL COMMENT '流程编码',
  `rule_code` varchar(64) NOT NULL COMMENT '规则编码',
  `rule_type` varchar(32) NOT NULL COMMENT '规则类型',
  `input_params` json DEFAULT NULL COMMENT '输入参数',
  `output_result` text DEFAULT NULL COMMENT '输出结果',
  `execution_time` int DEFAULT NULL COMMENT '执行时间（毫秒）',
  `status` tinyint NOT NULL COMMENT '执行状态：0-失败，1-成功',
  `error_message` text DEFAULT NULL COMMENT '错误信息',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_flow_code` (`flow_code`),
  KEY `idx_rule_code` (`rule_code`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='规则执行日志表';

-- ----------------------------
-- Example data for demonstration
-- 示例数据
-- ----------------------------

-- 示例1：Java表达式规则 - 计算折扣价格
INSERT INTO `rule_config` (`rule_code`, `rule_name`, `rule_type`, `rule_content`, `rule_params`, `description`, `status`, `priority`)
VALUES ('CALC_DISCOUNT_PRICE', '计算折扣价格', 'JAVA_EXPR', 'price * (1 - discount / 100)', 
        '{"inputs": ["price", "discount"], "output": "finalPrice"}',
        '根据原价和折扣百分比计算最终价格', 1, 100);

-- 示例2：SQL查询规则 - 查询库存数量
INSERT INTO `rule_config` (`rule_code`, `rule_name`, `rule_type`, `rule_content`, `rule_params`, `description`, `status`, `priority`)
VALUES ('QUERY_STOCK', '查询库存数量', 'SQL_QUERY', 
        'SELECT SUM(quantity) as stock FROM amf_jh_stock WHERE shop = ? AND warehouse_sku = ?',
        '{"inputs": ["shop", "warehouse_sku"], "output": "stock"}',
        '查询指定店铺和SKU的库存总数', 1, 100);

-- 示例3：API调用规则 - 调用外部价格接口
INSERT INTO `rule_config` (`rule_code`, `rule_name`, `rule_type`, `rule_content`, `rule_params`, `description`, `status`, `priority`)
VALUES ('API_GET_PRICE', '获取商品价格', 'API_CALL',
        '{"url": "http://api.example.com/price", "method": "GET", "headers": {"Content-Type": "application/json"}}',
        '{"inputs": ["sku"], "output": "price"}',
        '通过API获取商品价格信息', 1, 100);

-- 示例流程：订单价格计算流程
INSERT INTO `rule_flow` (`flow_code`, `flow_name`, `flow_config`, `description`, `status`)
VALUES ('ORDER_PRICE_FLOW', '订单价格计算流程',
        '{
          "steps": [
            {
              "step": 1,
              "ruleCode": "QUERY_STOCK",
              "condition": null,
              "onSuccess": "next",
              "onFailure": "abort"
            },
            {
              "step": 2,
              "ruleCode": "API_GET_PRICE",
              "condition": "stock > 0",
              "onSuccess": "next",
              "onFailure": "abort"
            },
            {
              "step": 3,
              "ruleCode": "CALC_DISCOUNT_PRICE",
              "condition": null,
              "onSuccess": "complete",
              "onFailure": "abort"
            }
          ]
        }',
        '完整的订单价格计算流程：检查库存->获取价格->计算折扣', 1);
