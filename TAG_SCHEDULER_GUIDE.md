# 标签调度系统使用指南
# Tag Scheduling System User Guide

## 概述 (Overview)

标签调度系统是Buyi规则引擎的扩展模块，提供基于规则的自动化标签计算和调度功能。系统支持：

- **定时调度**: 支持@hourly、@daily、@weekly等时间表达式
- **手动触发**: 支持手动触发任务执行
- **批量处理**: 支持大批量数据分批处理
- **多数据源**: 支持本地数据、SQL查询、API调用三种数据源
- **执行日志**: 完整的任务执行日志记录

## 架构设计 (Architecture)

```
┌─────────────────────────────────────────────────────────────────┐
│              Tag Scheduling System (标签调度系统)                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐      │
│  │         TagCalculationScheduler                       │      │
│  │  - 任务注册/启用/禁用                                  │      │
│  │  - 定时调度管理                                        │      │
│  │  - 手动触发执行                                        │      │
│  │  - 执行日志记录                                        │      │
│  └──────────────┬───────────────────────────────────────┘      │
│                 │                                                │
│                 │ 调用规则计算                                    │
│                 ▼                                                │
│  ┌──────────────────────────────────────────────────────┐      │
│  │         TagRuleService                                │      │
│  │  - 标签规则管理                                        │      │
│  │  - 规则执行                                            │      │
│  │  - 批量打标                                            │      │
│  └──────────────┬───────────────────────────────────────┘      │
│                 │                                                │
│                 │ 使用规则引擎                                    │
│                 ▼                                                │
│  ┌──────────────────────────────────────────────────────┐      │
│  │         RuleEngine (规则引擎)                          │      │
│  │  ┌──────────────┐  ┌──────────────┐                  │      │
│  │  │ Java表达式    │  │  SQL查询     │  ...             │      │
│  │  └──────────────┘  └──────────────┘                  │      │
│  └──────────────────────────────────────────────────────┘      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 快速开始 (Quick Start)

### 1. 初始化服务

```java
// 创建基础服务
TagService tagService = new TagService();
TagRuleService ruleService = new TagRuleService(tagService);

// 创建调度器
TagCalculationScheduler scheduler = new TagCalculationScheduler(ruleService);
```

### 2. 从JSON加载并注册规则

```java
// 创建规则配置加载器
TagRuleConfigLoader ruleLoader = new TagRuleConfigLoader();

// 从JSON文件加载规则
List<SkuTagRule> rules = ruleLoader.loadRuleConfigs("tag_rules_config.json");

// 注册并发布规则
for (SkuTagRule rule : rules) {
    ruleService.registerRule(rule);
    ruleService.publishRule(rule.getRuleCode(), rule.getVersion(), "system");
}
```

### 3. 从JSON加载并注册调度任务

```java
// 创建任务配置加载器
ScheduledJobConfigLoader jobLoader = new ScheduledJobConfigLoader();

// 从JSON文件加载任务
List<ScheduledTagJob> jobs = jobLoader.loadJobConfigs("scheduled_jobs.json");

// 注册任务
for (ScheduledTagJob job : jobs) {
    scheduler.registerJob(job);
}
```

### 4. 启动调度器

```java
// 启用任务
scheduler.enableJob("CARGO_GRADE_DAILY_JOB");

// 启动调度器
scheduler.start();

// 检查运行状态
if (scheduler.isRunning()) {
    System.out.println("调度器已启动");
}
```

### 5. 手动触发任务

```java
// 使用配置的数据源触发任务
TagJobExecutionLog log = scheduler.triggerJob("CARGO_GRADE_DAILY_JOB");

// 使用自定义数据触发任务
List<Map<String, Object>> customData = new ArrayList<>();
Map<String, Object> sku = new HashMap<>();
sku.put("sku_id", "SKU-001");
sku.put("sales_volume", 1500);
sku.put("profit_rate", 0.35);
sku.put("turnover_days", 10);
customData.add(sku);

log = scheduler.triggerJobWithData("CARGO_GRADE_DAILY_JOB", customData);

// 检查执行结果
System.out.println("状态: " + log.getStatus());
System.out.println("成功: " + log.getSuccessCount());
System.out.println("耗时: " + log.getDuration() + "ms");
```

### 6. 查询执行日志

```java
// 获取所有日志
List<TagJobExecutionLog> allLogs = scheduler.getExecutionLogs(null, 10);

// 获取特定任务的日志
List<TagJobExecutionLog> jobLogs = scheduler.getExecutionLogs("CARGO_GRADE_DAILY_JOB", 5);
```

### 7. 停止调度器

```java
// 停止调度（保留配置）
scheduler.stop();

// 完全关闭调度器
scheduler.shutdown();
```

## JSON配置格式 (JSON Configuration Format)

### 标签规则配置 (Tag Rule Configuration)

```json
{
  "ruleCode": "CARGO_GRADE_S_RULE",
  "ruleName": "货盘S级规则",
  "tagGroupId": 1,
  "tagValueId": 101,
  "ruleType": "JAVA_EXPR",
  "ruleContent": "sales_volume >= 1000 && profit_rate >= 0.3 && turnover_days <= 15",
  "priority": 100,
  "status": "ENABLED",
  "description": "销量>=1000且利润率>=30%且周转天数<=15天，判定为S级货盘"
}
```

**字段说明：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| ruleCode | string | 是 | 规则编码（唯一） |
| ruleName | string | 是 | 规则名称 |
| tagGroupId | long | 是 | 标签组ID |
| tagValueId | long | 是 | 标签值ID |
| ruleType | string | 是 | 规则类型：JAVA_EXPR/SQL_QUERY/API_CALL |
| ruleContent | string | 是 | 规则内容（表达式/SQL/API配置） |
| priority | int | 否 | 优先级（默认0，数值越大优先级越高） |
| status | string | 否 | 状态：DRAFT/ENABLED/DISABLED（默认DRAFT） |
| description | string | 否 | 规则描述 |

### 调度任务配置 (Scheduled Job Configuration)

```json
{
  "jobCode": "CARGO_GRADE_DAILY_JOB",
  "jobName": "货盘等级每日计算任务",
  "tagGroupId": 1,
  "cronExpression": "@daily",
  "dataSourceType": "LOCAL",
  "dataSourceConfig": "[{\"sku_id\":\"SKU-001\",\"sales_volume\":1500}]",
  "batchSize": 1000,
  "maxRetries": 3,
  "timeoutSeconds": 3600,
  "status": "ENABLED",
  "description": "每天凌晨执行货盘等级计算"
}
```

**字段说明：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| jobCode | string | 是 | 任务编码（唯一） |
| jobName | string | 是 | 任务名称 |
| tagGroupId | long | 是 | 标签组ID |
| cronExpression | string | 否 | 调度表达式 |
| dataSourceType | string | 否 | 数据源类型：LOCAL/SQL/API |
| dataSourceConfig | string | 否 | 数据源配置 |
| batchSize | int | 否 | 批处理大小（默认1000） |
| maxRetries | int | 否 | 最大重试次数（默认3） |
| timeoutSeconds | int | 否 | 超时时间秒（默认3600） |
| status | string | 否 | 状态：ENABLED/DISABLED/PAUSED |
| description | string | 否 | 任务描述 |

## 调度表达式 (Cron Expression)

支持以下调度表达式：

| 表达式 | 说明 |
|--------|------|
| @minutely | 每分钟执行 |
| @hourly | 每小时执行 |
| @daily | 每天执行 |
| @weekly | 每周执行 |
| 数字 | 固定间隔（毫秒） |

示例：
- `@hourly`: 每小时整点执行
- `@daily`: 每天凌晨执行
- `60000`: 每60秒执行一次

## 数据源类型 (Data Source Types)

### 1. LOCAL - 本地数据

直接在配置中提供JSON格式的SKU数据：

```json
{
  "dataSourceType": "LOCAL",
  "dataSourceConfig": "[{\"sku_id\":\"SKU-001\",\"sales_volume\":1500,\"profit_rate\":0.35}]"
}
```

### 2. SQL - SQL查询（计划中）

通过SQL查询获取SKU数据：

```json
{
  "dataSourceType": "SQL",
  "dataSourceConfig": "SELECT sku_id, sales_volume, profit_rate FROM sku_metrics WHERE update_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)"
}
```

### 3. API - 外部API（计划中）

通过API接口获取SKU数据：

```json
{
  "dataSourceType": "API",
  "dataSourceConfig": "{\"url\":\"http://api.example.com/sku/metrics\",\"method\":\"GET\"}"
}
```

## 完整示例 (Complete Example)

参见 `TagSchedulerExample.java`，演示了：

1. 从JSON加载规则和任务配置
2. 手动触发任务执行
3. 使用自定义数据执行任务
4. 调度器生命周期管理
5. 执行日志查询

## 数据库表结构 (Database Schema)

执行 `scheduled_job_schema.sql` 创建所需的数据库表：

```bash
mysql -u username -p database < scheduled_job_schema.sql
```

## 最佳实践 (Best Practices)

1. **规则设计**: 按优先级从高到低设计规则，高优先级规则匹配后停止评估
2. **批量处理**: 大数据量场景设置合适的batchSize，避免内存溢出
3. **错误处理**: 总是检查执行日志的status字段
4. **人工覆盖**: 人工打标优先级高于规则打标，批量执行时会自动跳过
5. **日志监控**: 定期检查执行日志，监控任务执行状况

## 扩展开发 (Extension)

### 实现自定义数据源

```java
// 在TagCalculationScheduler中添加新的数据源类型处理
private List<Map<String, Object>> fetchSkuData(ScheduledTagJob job) {
    DataSourceType type = DataSourceType.fromCode(job.getDataSourceType());
    
    switch (type) {
        case LOCAL:
            return parseLocalData(job.getDataSourceConfig());
        case SQL:
            return executeSqlQuery(job.getDataSourceConfig());
        case API:
            return callExternalApi(job.getDataSourceConfig());
        default:
            return null;
    }
}
```

## 参考资料 (References)

- [RULE_ENGINE_README.md](RULE_ENGINE_README.md) - 规则引擎完整文档
- [RULE_TAG_INTEGRATION.md](RULE_TAG_INTEGRATION.md) - 规则引擎与标签系统集成指南
- [JSON_FEATURES_GUIDE.md](JSON_FEATURES_GUIDE.md) - JSON配置功能指南
