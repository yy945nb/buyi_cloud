-- Scheduled Tag Job Database Schema
-- 标签计算调度任务数据库表结构

-- ----------------------------
-- Table structure for scheduled_tag_job
-- 标签计算调度任务表
-- ----------------------------
DROP TABLE IF EXISTS `scheduled_tag_job`;
CREATE TABLE `scheduled_tag_job` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_code` varchar(64) NOT NULL COMMENT '任务编码',
  `job_name` varchar(128) NOT NULL COMMENT '任务名称',
  `tag_group_id` bigint NOT NULL COMMENT '标签组ID',
  `cron_expression` varchar(64) DEFAULT NULL COMMENT 'Cron表达式（@hourly/@daily/@weekly/毫秒数）',
  `data_source_type` varchar(32) DEFAULT NULL COMMENT '数据源类型：SQL(SQL查询), API(外部API), LOCAL(本地数据)',
  `data_source_config` text DEFAULT NULL COMMENT '数据源配置（SQL语句/API地址/JSON数据）',
  `job_params` json DEFAULT NULL COMMENT '任务参数配置（JSON格式）',
  `batch_size` int DEFAULT '1000' COMMENT '批处理大小',
  `max_retries` int DEFAULT '3' COMMENT '最大重试次数',
  `timeout_seconds` int DEFAULT '3600' COMMENT '超时时间（秒）',
  `status` varchar(32) NOT NULL DEFAULT 'DISABLED' COMMENT '状态：ENABLED(启用), DISABLED(禁用), PAUSED(暂停)',
  `description` varchar(512) DEFAULT NULL COMMENT '任务描述',
  `last_execute_time` datetime DEFAULT NULL COMMENT '上次执行时间',
  `last_execute_status` varchar(32) DEFAULT NULL COMMENT '上次执行状态',
  `last_execute_duration` bigint DEFAULT NULL COMMENT '上次执行耗时（毫秒）',
  `last_success_count` int DEFAULT NULL COMMENT '上次成功数量',
  `last_failure_count` int DEFAULT NULL COMMENT '上次失败数量',
  `next_execute_time` datetime DEFAULT NULL COMMENT '下次执行时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_job_code` (`job_code`),
  KEY `idx_tag_group_id` (`tag_group_id`),
  KEY `idx_status` (`status`),
  KEY `idx_next_execute_time` (`next_execute_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='标签计算调度任务表';

-- ----------------------------
-- Table structure for tag_job_execution_log
-- 任务执行日志表
-- ----------------------------
DROP TABLE IF EXISTS `tag_job_execution_log`;
CREATE TABLE `tag_job_execution_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `job_id` bigint NOT NULL COMMENT '任务ID',
  `job_code` varchar(64) NOT NULL COMMENT '任务编码',
  `tag_group_id` bigint NOT NULL COMMENT '标签组ID',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `duration` bigint DEFAULT NULL COMMENT '执行耗时（毫秒）',
  `status` varchar(32) NOT NULL COMMENT '执行状态：RUNNING(执行中), SUCCESS(成功), FAILURE(失败), TIMEOUT(超时)',
  `total_count` int DEFAULT NULL COMMENT '总处理数量',
  `success_count` int DEFAULT NULL COMMENT '成功数量',
  `failure_count` int DEFAULT NULL COMMENT '失败数量',
  `skipped_count` int DEFAULT NULL COMMENT '跳过数量',
  `error_message` text DEFAULT NULL COMMENT '错误信息',
  `execution_params` json DEFAULT NULL COMMENT '执行参数',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_job_id` (`job_id`),
  KEY `idx_job_code` (`job_code`),
  KEY `idx_tag_group_id` (`tag_group_id`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='标签计算任务执行日志表';

-- ----------------------------
-- Example data for demonstration
-- 示例数据
-- ----------------------------

-- 示例1：货盘等级每日计算任务
INSERT INTO `scheduled_tag_job` (`job_code`, `job_name`, `tag_group_id`, `cron_expression`, `data_source_type`, `batch_size`, `status`, `description`, `create_user`)
VALUES (
  'CARGO_GRADE_DAILY_JOB', 
  '货盘等级每日计算任务', 
  1, 
  '@daily', 
  'SQL',
  1000,
  'DISABLED',
  '每天凌晨执行货盘等级计算，根据销量、利润率、周转天数对SKU进行分级打标', 
  'system'
);

-- 示例2：库存预警每小时计算任务
INSERT INTO `scheduled_tag_job` (`job_code`, `job_name`, `tag_group_id`, `cron_expression`, `data_source_type`, `batch_size`, `status`, `description`, `create_user`)
VALUES (
  'INVENTORY_ALERT_HOURLY_JOB', 
  '库存预警每小时计算任务', 
  3, 
  '@hourly', 
  'SQL',
  500,
  'DISABLED',
  '每小时执行库存预警计算，根据库存量、日均销量、补货周期对SKU进行预警等级打标', 
  'system'
);

-- 示例3：定价策略每周计算任务
INSERT INTO `scheduled_tag_job` (`job_code`, `job_name`, `tag_group_id`, `cron_expression`, `data_source_type`, `batch_size`, `status`, `description`, `create_user`)
VALUES (
  'PRICING_STRATEGY_WEEKLY_JOB', 
  '定价策略每周计算任务', 
  2, 
  '@weekly', 
  'SQL',
  500,
  'DISABLED',
  '每周执行定价策略计算，根据库存、库龄、季节性等因素对SKU进行定价策略打标', 
  'system'
);
