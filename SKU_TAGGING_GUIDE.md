# SKU标签系统开发文档
# SKU Tagging System Development Guide

## 概述 (Overview)

SKU标签系统是跨境电商平台的商品档案（SKU）域核心功能，支持基于规则的自动打标和人工打标，提供标签查询API供下游系统（备货、促销等）使用。

The SKU Tagging System is a core feature of the cross-border e-commerce platform's product archive (SKU) domain, supporting both rule-based automatic tagging and manual tagging, with query APIs for downstream systems (inventory management, promotions, etc.).

## 核心特性 (Core Features)

- ✅ **标签元数据管理** - 标签组和标签值配置，支持单选/多选类型
- ✅ **规则引擎打标** - 基于规则自动为SKU打标签，支持优先级、版本控制
- ✅ **人工打标** - 支持人工覆盖规则打标，包含原因和有效期
- ✅ **历史审计** - 完整记录标签变更历史，可追溯
- ✅ **批量处理** - 支持批量SKU的规则执行
- ✅ **查询API** - 提供标签查询接口，支持分页和过滤
- ✅ **货盘S/A/B/C标签** - 预置货盘等级标签组和示例规则

## 架构设计 (Architecture)

```
┌─────────────────────────────────────────────────────────────┐
│                    SKU Tagging System                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │  Tag Service │  │TagRuleService│  │TagQueryService│    │
│  │              │  │              │  │              │    │
│  │ - tagSku()   │  │ - register() │  │ - query()    │    │
│  │ - removeTag()│  │ - execute()  │  │ - filter()   │    │
│  │ - getHistory│  │ - batch()    │  │ - stats()    │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                 │                  │             │
│         └─────────────────┴──────────────────┘             │
│                           │                                 │
│                 ┌─────────▼──────────┐                     │
│                 │   Rule Engine      │                     │
│                 │   (JEXL, SQL, API) │                     │
│                 └────────────────────┘                     │
└─────────────────────────────────────────────────────────────┘
                           │
                 ┌─────────▼──────────┐
                 │   Database Tables  │
                 ├────────────────────┤
                 │ sku_tag_group      │
                 │ sku_tag_value      │
                 │ sku_tag_result     │
                 │ sku_tag_history    │
                 │ sku_tag_rule       │
                 └────────────────────┘
```

## 数据模型 (Data Model)

### 1. sku_tag_group (标签组配置表)

存储标签组元数据，定义标签的分类和类型。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 标签组ID |
| tag_group_code | varchar(64) | 标签组编码（唯一） |
| tag_group_name | varchar(128) | 标签组名称 |
| tag_type | varchar(32) | 标签类型：SINGLE(单选), MULTI(多选) |
| description | varchar(512) | 标签组描述 |
| status | tinyint | 状态：0-禁用，1-启用 |

**示例数据：**
```sql
INSERT INTO sku_tag_group (tag_group_code, tag_group_name, tag_type, description)
VALUES ('CARGO_GRADE', '货盘等级', 'SINGLE', '商品货盘等级分类：S级(优质)、A级(良好)、B级(一般)、C级(较差)');
```

### 2. sku_tag_value (标签值配置表)

存储标签组下的具体标签值。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 标签值ID |
| tag_group_id | bigint | 标签组ID |
| tag_value_code | varchar(64) | 标签值编码 |
| tag_value_name | varchar(128) | 标签值名称 |
| sort_order | int | 排序顺序 |
| status | tinyint | 状态：0-禁用，1-启用 |

**示例数据：**
```sql
INSERT INTO sku_tag_value (tag_group_id, tag_value_code, tag_value_name, sort_order)
VALUES 
  (1, 'S', 'S级货盘', 1),
  (1, 'A', 'A级货盘', 2),
  (1, 'B', 'B级货盘', 3),
  (1, 'C', 'C级货盘', 4);
```

### 3. sku_tag_result (SKU标签结果表)

存储SKU当前生效的标签。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 标签结果ID |
| sku_id | varchar(128) | SKU编码 |
| tag_group_id | bigint | 标签组ID |
| tag_value_id | bigint | 标签值ID |
| source | varchar(32) | 标签来源：RULE(规则), MANUAL(人工) |
| rule_code | varchar(64) | 规则编码（来源为RULE时） |
| rule_version | int | 规则版本（来源为RULE时） |
| operator | varchar(64) | 操作人（来源为MANUAL时） |
| reason | varchar(512) | 打标原因 |
| is_active | tinyint | 是否生效：0-失效，1-生效 |
| valid_from | datetime | 有效期开始时间 |
| valid_to | datetime | 有效期结束时间 |
| update_time | datetime | 更新时间 |

**唯一约束：** (sku_id, tag_group_id, is_active) - 确保每个SKU在每个标签组下只有一个生效标签。

### 4. sku_tag_history (SKU标签历史记录表)

存储标签的所有变更历史，用于审计和追溯。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 历史记录ID |
| sku_id | varchar(128) | SKU编码 |
| tag_group_id | bigint | 标签组ID |
| old_tag_value_id | bigint | 旧标签值ID |
| new_tag_value_id | bigint | 新标签值ID |
| source | varchar(32) | 标签来源：RULE, MANUAL |
| rule_code | varchar(64) | 规则编码（来源为RULE时） |
| rule_version | int | 规则版本（来源为RULE时） |
| operator | varchar(64) | 操作人（来源为MANUAL时） |
| reason | varchar(512) | 变更原因 |
| operation_type | varchar(32) | 操作类型：CREATE, UPDATE, DELETE |
| create_time | datetime | 创建时间 |

### 5. sku_tag_rule (SKU标签规则表)

存储标签规则配置，用于自动打标。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 规则ID |
| rule_code | varchar(64) | 规则编码 |
| rule_name | varchar(128) | 规则名称 |
| tag_group_id | bigint | 标签组ID |
| tag_value_id | bigint | 标签值ID |
| rule_type | varchar(32) | 规则类型：JAVA_EXPR, SQL_QUERY, API_CALL |
| rule_content | text | 规则内容 |
| rule_params | json | 规则参数配置 |
| scope_config | json | 适用范围配置 |
| priority | int | 优先级（数字越大优先级越高） |
| version | int | 规则版本 |
| status | varchar(32) | 状态：DRAFT, ENABLED, DISABLED |
| published_time | datetime | 发布时间 |
| published_user | varchar(64) | 发布人 |

**唯一约束：** (rule_code, version) - 确保规则的版本唯一性。

## API使用指南 (API Guide)

### 1. TagService - 标签管理服务

#### 1.1 为SKU打标签

```java
TagService tagService = new TagService();

// 规则打标
SkuTagResult result = tagService.tagSku(
    "SKU-12345",           // SKU编码
    1L,                    // 标签组ID
    101L,                  // 标签值ID
    TagSource.RULE,        // 标签来源
    "CARGO_GRADE_S_RULE",  // 规则编码
    1,                     // 规则版本
    null,                  // 操作人（规则打标为null）
    "Rule: S级货盘规则",   // 原因
    null,                  // 有效期开始（null表示立即生效）
    null                   // 有效期结束（null表示永久有效）
);

// 人工打标
SkuTagResult manualResult = tagService.tagSku(
    "SKU-12345",
    1L,
    102L,
    TagSource.MANUAL,
    null,                  // 规则编码（人工打标为null）
    null,                  // 规则版本（人工打标为null）
    "admin",               // 操作人
    "人工调整为A级",       // 原因
    new Date(),            // 立即生效
    null                   // 永久有效
);
```

#### 1.2 查询SKU的标签

```java
// 查询指定标签组的标签
SkuTagResult tag = tagService.getActiveTag("SKU-12345", 1L);
System.out.println("Tag value ID: " + tag.getTagValueId());
System.out.println("Source: " + tag.getSource());

// 查询所有生效标签
List<SkuTagResult> allTags = tagService.getActiveTags("SKU-12345");
for (SkuTagResult t : allTags) {
    System.out.println("Tag group: " + t.getTagGroupId() + 
                       ", Value: " + t.getTagValueId());
}
```

#### 1.3 删除标签

```java
boolean removed = tagService.removeTag(
    "SKU-12345",
    1L,
    "admin",
    "商品已下架"
);
```

#### 1.4 查询标签历史

```java
// 查询指定标签组的历史
List<SkuTagHistory> history = tagService.getTagHistory("SKU-12345", 1L);

// 查询所有标签组的历史
List<SkuTagHistory> allHistory = tagService.getTagHistory("SKU-12345", null);

for (SkuTagHistory h : history) {
    System.out.println("Operation: " + h.getOperationType());
    System.out.println("Old value: " + h.getOldTagValueId());
    System.out.println("New value: " + h.getNewTagValueId());
    System.out.println("Source: " + h.getSource());
    System.out.println("Time: " + h.getCreateTime());
}
```

### 2. TagRuleService - 标签规则服务

#### 2.1 注册规则

```java
TagService tagService = new TagService();
TagRuleService tagRuleService = new TagRuleService(tagService);

// 创建规则
SkuTagRule rule = new SkuTagRule();
rule.setRuleCode("CARGO_GRADE_S_RULE");
rule.setRuleName("货盘S级规则");
rule.setTagGroupId(1L);
rule.setTagValueId(101L);  // S级标签值ID
rule.setRuleType("JAVA_EXPR");
rule.setRuleContent("sales_volume >= 1000 && profit_rate >= 0.3 && turnover_days <= 15");
rule.setPriority(100);
rule.setDescription("销量>=1000且利润率>=30%且周转天数<=15天");

// 设置规则参数
Map<String, Object> params = new HashMap<>();
params.put("inputs", Arrays.asList("sales_volume", "profit_rate", "turnover_days"));
rule.setRuleParams(params);

// 注册规则
Long ruleId = tagRuleService.registerRule(rule);
```

#### 2.2 发布规则

```java
// 发布规则（启用）
tagRuleService.publishRule("CARGO_GRADE_S_RULE", 1, "admin");

// 禁用规则
tagRuleService.disableRule("CARGO_GRADE_S_RULE", 1);
```

#### 2.3 执行规则为单个SKU打标

```java
// 准备SKU数据
Map<String, Object> skuData = new HashMap<>();
skuData.put("sku_id", "SKU-12345");
skuData.put("sales_volume", 1200);
skuData.put("profit_rate", 0.35);
skuData.put("turnover_days", 10);

// 执行规则
SkuTagResult result = tagRuleService.executeRulesForSku(
    "SKU-12345",
    1L,  // 标签组ID
    skuData
);

if (result != null) {
    System.out.println("Tagged with rule: " + result.getRuleCode());
    System.out.println("Tag value: " + result.getTagValueId());
}
```

#### 2.4 批量执行规则

```java
// 准备批量SKU数据
List<Map<String, Object>> batchData = new ArrayList<>();

for (int i = 1; i <= 100; i++) {
    Map<String, Object> sku = new HashMap<>();
    sku.put("sku_id", "SKU-" + i);
    sku.put("sales_volume", Math.random() * 2000);
    sku.put("profit_rate", Math.random() * 0.5);
    sku.put("turnover_days", (int)(Math.random() * 90));
    batchData.add(sku);
}

// 批量执行
Map<String, Integer> stats = tagRuleService.batchExecuteRules(1L, batchData);

System.out.println("Total: " + stats.get("total"));
System.out.println("Success: " + stats.get("success"));
System.out.println("Failure: " + stats.get("failure"));
System.out.println("Skipped: " + stats.get("skipped"));
```

#### 2.5 预览规则匹配

```java
// 预览规则将匹配哪些SKU
List<String> matchedSkus = tagRuleService.previewRuleMatches(rule, batchData);

System.out.println("Matched SKU count: " + matchedSkus.size());
for (String skuId : matchedSkus) {
    System.out.println("  - " + skuId);
}
```

### 3. TagQueryService - 标签查询服务

#### 3.1 查询SKU标签

```java
TagQueryService queryService = new TagQueryService(tagService);

// 查询单个SKU的所有标签
List<SkuTagResult> tags = queryService.querySkuTags("SKU-12345");

// 查询单个SKU指定标签组的标签
SkuTagResult tag = queryService.querySkuTag("SKU-12345", 1L);
```

#### 3.2 分页查询

```java
// 构建查询参数
TagQueryService.QueryParams params = new TagQueryService.QueryParams();
params.setTagGroupId(1L);
params.setTagValueId(101L);  // 查询S级货盘的SKU
params.setSource("RULE");    // 只查询规则打标的
params.setPage(1);
params.setPageSize(20);

// 执行查询
TagQueryService.PageResult<SkuTagResult> result = 
    queryService.queryTagsWithPagination(params);

System.out.println("Total: " + result.getTotal());
System.out.println("Total pages: " + result.getTotalPages());
for (SkuTagResult tag : result.getData()) {
    System.out.println("SKU: " + tag.getSkuId() + 
                       ", Value: " + tag.getTagValueId());
}
```

## 货盘S/A/B/C标签组示例 (Cargo Grade Example)

### 规则定义

系统预置了货盘等级标签组（CARGO_GRADE）和四个示例规则：

#### S级货盘规则
- **条件：** `sales_volume >= 1000 && profit_rate >= 0.3 && turnover_days <= 15`
- **说明：** 销量>=1000且利润率>=30%且周转天数<=15天
- **优先级：** 100

#### A级货盘规则
- **条件：** `sales_volume >= 500 && profit_rate >= 0.2 && turnover_days <= 30`
- **说明：** 销量>=500且利润率>=20%且周转天数<=30天
- **优先级：** 90

#### B级货盘规则
- **条件：** `sales_volume >= 100 && profit_rate >= 0.1 && turnover_days <= 60`
- **说明：** 销量>=100且利润率>=10%且周转天数<=60天
- **优先级：** 80

#### C级货盘规则
- **条件：** `sales_volume < 100 || profit_rate < 0.1 || turnover_days > 60`
- **说明：** 销量<100或利润率<10%或周转天数>60天
- **优先级：** 70

### 使用示例

```java
// 1. 执行初始化SQL脚本创建标签组和规则
// mysql < sku_tag_schema.sql

// 2. 发布规则
tagRuleService.publishRule("CARGO_GRADE_S_RULE", 1, "system");
tagRuleService.publishRule("CARGO_GRADE_A_RULE", 1, "system");
tagRuleService.publishRule("CARGO_GRADE_B_RULE", 1, "system");
tagRuleService.publishRule("CARGO_GRADE_C_RULE", 1, "system");

// 3. 准备SKU数据并执行规则
Map<String, Object> skuData = new HashMap<>();
skuData.put("sku_id", "SKU-DEMO");
skuData.put("sales_volume", 1200);
skuData.put("profit_rate", 0.35);
skuData.put("turnover_days", 10);

// 4. 执行打标
SkuTagResult result = tagRuleService.executeRulesForSku(
    "SKU-DEMO",
    1L,  // CARGO_GRADE标签组ID
    skuData
);

// 5. 查询结果
System.out.println("货盘等级: " + result.getTagValueCode());  // 输出: S
```

## 规则冲突处理 (Rule Conflict Resolution)

当多条规则同时匹配一个SKU时，系统按以下策略处理：

1. **优先级排序：** 按规则的`priority`字段降序排列
2. **顺序执行：** 从高优先级到低优先级依次评估规则
3. **首次匹配：** 一旦有规则匹配成功，立即应用该规则并停止后续评估
4. **人工覆盖：** 人工打标的标签优先级高于规则打标，批量执行时会跳过已有人工标签的SKU

## 人工打标优先级策略 (Manual Tagging Priority)

1. **人工覆盖规则：** 人工打标会覆盖规则打标结果
2. **批量执行跳过：** 批量执行规则时，已有人工标签的SKU会被跳过
3. **回退到规则：** 删除人工标签后，可重新执行规则进行打标
4. **完整审计：** 所有人工打标操作都会记录操作人、原因、时间

## 下游系统集成 (Downstream Integration)

### 备货系统使用示例

```java
// 查询S级和A级货盘的SKU用于备货
TagQueryService.QueryParams params = new TagQueryService.QueryParams();
params.setTagGroupId(1L);  // CARGO_GRADE

// 分批查询S级SKU
params.setTagValueId(101L);  // S级
TagQueryService.PageResult<SkuTagResult> sSku = 
    queryService.queryTagsWithPagination(params);

// 分批查询A级SKU
params.setTagValueId(102L);  // A级
TagQueryService.PageResult<SkuTagResult> aSku = 
    queryService.queryTagsWithPagination(params);

// 根据货盘等级制定备货策略
for (SkuTagResult tag : sSku.getData()) {
    System.out.println("S级SKU: " + tag.getSkuId() + " - 优先备货");
}
```

### 促销系统使用示例

```java
// 查询B级和C级货盘用于促销清库存
TagQueryService.QueryParams params = new TagQueryService.QueryParams();
params.setTagGroupId(1L);

// 查询C级SKU
params.setTagValueId(104L);  // C级
TagQueryService.PageResult<SkuTagResult> cSku = 
    queryService.queryTagsWithPagination(params);

// 为C级货盘商品创建促销活动
for (SkuTagResult tag : cSku.getData()) {
    System.out.println("C级SKU: " + tag.getSkuId() + " - 促销清库存");
    // 创建促销...
}
```

## 数据库迁移 (Database Migration)

### 创建表结构

```bash
# 执行schema文件创建所有表
mysql -u username -p database < sku_tag_schema.sql
```

### 回滚策略

```sql
-- 回滚脚本：删除所有标签相关表
DROP TABLE IF EXISTS sku_tag_history;
DROP TABLE IF EXISTS sku_tag_result;
DROP TABLE IF EXISTS sku_tag_rule;
DROP TABLE IF EXISTS sku_tag_value;
DROP TABLE IF EXISTS sku_tag_group;
```

### 数据迁移

如果需要从旧系统迁移标签数据：

```sql
-- 示例：从旧系统迁移货盘等级数据
INSERT INTO sku_tag_result (sku_id, tag_group_id, tag_value_id, source, reason, is_active, create_time, update_time)
SELECT 
  old_sku.sku_code,
  1,  -- CARGO_GRADE标签组ID
  CASE old_sku.grade
    WHEN 'S' THEN 101
    WHEN 'A' THEN 102
    WHEN 'B' THEN 103
    WHEN 'C' THEN 104
  END,
  'MANUAL',
  '数据迁移',
  1,
  NOW(),
  NOW()
FROM old_sku_grade_table old_sku;
```

## 性能优化建议 (Performance Optimization)

1. **索引优化**
   - `sku_tag_result`表的`(sku_id, tag_group_id, is_active)`复合索引
   - `sku_tag_result`表的`update_time`索引用于增量查询
   - `sku_tag_history`表的`(sku_id, create_time)`复合索引

2. **批量处理**
   - 使用批量插入减少数据库交互
   - 合理设置批次大小（建议1000-5000条/批）

3. **缓存策略**
   - 缓存标签组和标签值配置（很少变更）
   - 缓存规则配置（发布后相对稳定）
   - 考虑使用Redis缓存热点SKU的标签

4. **查询优化**
   - 下游系统查询时使用分页
   - 使用`update_time`字段实现增量查询
   - 避免全表扫描，始终带上过滤条件

## 监控和日志 (Monitoring and Logging)

### 关键指标

1. **规则执行性能**
   - 单个SKU规则执行时间
   - 批量执行吞吐量（SKU数/秒）

2. **打标成功率**
   - 规则匹配率
   - 批量执行成功率

3. **人工干预率**
   - 人工打标占比
   - 人工覆盖规则的频率

### 日志记录

系统使用SLF4J记录以下关键操作：

```java
// 打标操作
logger.info("Tagging SKU: skuId={}, tagGroupId={}, tagValueId={}, source={}", ...);

// 规则执行
logger.info("Executing tag rules for SKU: skuId={}, tagGroupId={}", ...);

// 批量处理
logger.info("Batch rule execution completed: stats={}", ...);

// 错误日志
logger.error("Failed to execute rules for SKU: skuId={}", skuId, e);
```

## 测试 (Testing)

### 运行测试

```bash
# 运行所有标签服务测试
mvn test -Dtest=TagServiceTest

# 运行规则服务测试
mvn test -Dtest=TagRuleServiceTest

# 运行所有测试
mvn test
```

### 测试覆盖

- ✅ 标签创建和更新
- ✅ 人工覆盖规则
- ✅ 有效期验证
- ✅ 标签删除
- ✅ 历史审计
- ✅ 规则优先级
- ✅ 批量执行
- ✅ 规则预览

## 最佳实践 (Best Practices)

1. **规则设计**
   - 规则条件应简单明确，易于理解和维护
   - 优先级设置应考虑业务重要性
   - 定期评估规则效果，优化规则条件

2. **人工打标**
   - 始终填写清晰的原因说明
   - 必要时设置有效期，避免长期人工标签
   - 定期review人工标签，考虑转化为规则

3. **批量处理**
   - 选择业务低峰期执行大批量打标
   - 监控执行进度和错误率
   - 准备回滚方案

4. **下游使用**
   - 使用分页查询避免一次性加载大量数据
   - 通过`update_time`实现增量同步
   - 缓存标签数据减少查询压力

## 常见问题 (FAQ)

### Q1: 如何处理规则冲突？
A: 系统按优先级自动选择最高优先级的匹配规则。建议合理设置优先级，确保规则之间的逻辑清晰。

### Q2: 人工标签会被规则覆盖吗？
A: 不会。批量执行规则时会跳过已有人工标签的SKU。只有手动删除人工标签后才能重新应用规则。

### Q3: 如何回退规则更改？
A: 保留规则版本历史，需要回退时禁用新版本规则，启用旧版本规则，然后重新执行批量打标。

### Q4: 标签历史会无限增长吗？
A: 是的。建议定期归档或清理过期的历史记录（如1年前的数据），保留最近的审计数据即可。

### Q5: 如何确保数据一致性？
A: 使用数据库唯一约束确保同一SKU同一标签组只有一个生效标签。所有操作都记录历史便于追溯。

## 联系方式 (Contact)

如有问题或建议，请通过以下方式联系：
- GitHub Issue: https://github.com/yy945nb/buyi_cloud/issues
- Email: support@buyi.com

---

**版本：** 1.0.0  
**更新日期：** 2026-01-21
