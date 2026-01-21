# 规则引擎与标签系统集成指南
# Rule Engine and Tag System Integration Guide

## 概述 (Overview)

本文档详细说明规则引擎的数据计算逻辑如何与标签系统的业务场景相结合，帮助理解两个系统的协同工作方式。

This document explains in detail how the rule engine's data calculation logic integrates with the tag system's business scenarios, helping to understand how the two systems work together.

## 核心集成点 (Core Integration Points)

### 1. 规则引擎作为标签系统的计算引擎

标签系统通过 `TagRuleService` 调用规则引擎来执行业务规则计算，规则引擎提供三种计算能力：

```
┌─────────────────────────────────────────────────────────┐
│              SKU Tag System (标签系统)                   │
│                                                          │
│  ┌──────────────────────────────────────────────┐      │
│  │         TagRuleService                        │      │
│  │  - 业务标签规则管理                           │      │
│  │  - SKU标签结果生成                            │      │
│  └──────────────┬───────────────────────────────┘      │
│                 │                                        │
│                 │ 调用规则计算                            │
│                 ▼                                        │
│  ┌──────────────────────────────────────────────┐      │
│  │         Rule Engine (规则引擎)                 │      │
│  │                                                │      │
│  │  ┌──────────────┐  ┌──────────────┐          │      │
│  │  │ Java表达式    │  │  SQL查询     │          │      │
│  │  │ 业务逻辑计算  │  │  数据库计算  │  ...     │      │
│  │  └──────────────┘  └──────────────┘          │      │
│  └──────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘
```

### 2. 三种数据计算方式的应用场景

#### 2.1 Java表达式计算 (JAVA_EXPR)

**使用场景：** 基于已知SKU属性进行逻辑判断和数学计算

**典型应用：**
- 货盘等级分类（基于销量、利润率、周转天数）
- 商品定价策略（基于成本、竞争对手价格）
- 库存预警等级（基于当前库存、销售速度）

**示例：货盘S级判定规则**
```java
// 规则内容：Java表达式
String ruleContent = "sales_volume >= 1000 && profit_rate >= 0.3 && turnover_days <= 15";

// SKU数据（从数据仓库或业务系统获取）
Map<String, Object> skuData = new HashMap<>();
skuData.put("sales_volume", 1200);      // 月销量
skuData.put("profit_rate", 0.35);       // 利润率35%
skuData.put("turnover_days", 12);       // 周转天数12天

// 规则引擎计算 → 结果：true → 打标为S级
```

**集成流程：**
```
1. TagRuleService.executeRulesForSku()
   ↓
2. 将SkuTagRule转换为RuleConfig
   ↓
3. RuleEngine.executeRule(ruleConfig, context)
   ↓
4. JavaExpressionExecutor执行表达式计算
   ↓
5. 返回计算结果(true/false)
   ↓
6. TagService.tagSku() 写入标签结果
```

#### 2.2 SQL查询计算 (SQL_QUERY)

**使用场景：** 需要从数据库聚合计算或关联查询的场景

**典型应用：**
- 基于历史订单数据计算销量趋势
- 跨表关联计算综合得分
- 实时库存查询和动态计算

**示例：基于订单历史计算热销标签**
```java
// 规则内容：SQL查询
String ruleContent = 
    "SELECT " +
    "  CASE " +
    "    WHEN SUM(quantity) >= 1000 THEN 'HOT' " +
    "    WHEN SUM(quantity) >= 500 THEN 'WARM' " +
    "    ELSE 'COLD' " +
    "  END as sales_tag " +
    "FROM orders " +
    "WHERE sku_id = ? AND order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)";

// 规则参数：SKU ID
Map<String, Object> params = new HashMap<>();
params.put("inputs", Arrays.asList("sku_id"));

// SKU数据
Map<String, Object> skuData = new HashMap<>();
skuData.put("sku_id", "SKU-12345");

// 规则引擎执行SQL → 返回 sales_tag = 'HOT' → 打标为热销
```

**集成流程：**
```
1. TagRuleService.executeRulesForSku()
   ↓
2. RuleEngine.executeRule() with SQL_QUERY type
   ↓
3. SqlQueryExecutor执行数据库查询
   ↓
4. 返回查询结果（如：销量等级）
   ↓
5. 根据查询结果确定标签值
   ↓
6. TagService.tagSku() 写入标签结果
```

#### 2.3 API调用计算 (API_CALL)

**使用场景：** 依赖外部系统或第三方服务的计算

**典型应用：**
- 调用外部价格服务获取竞争对手价格
- 调用物流API计算配送时效
- 调用风控系统获取风险评分

**示例：调用外部服务获取商品质量评级**
```java
// 规则内容：API配置
String apiConfig = 
    "{" +
    "  \"url\": \"http://quality-service.internal/api/grade?sku={sku_id}\"," +
    "  \"method\": \"GET\"," +
    "  \"headers\": {\"Authorization\": \"Bearer {token}\"}," +
    "  \"responseField\": \"grade\"" +
    "}";

// SKU数据
Map<String, Object> skuData = new HashMap<>();
skuData.put("sku_id", "SKU-12345");
skuData.put("token", "xyz123...");

// 规则引擎调用API → 返回 grade = 'PREMIUM' → 打标为优质商品
```

**集成流程：**
```
1. TagRuleService.executeRulesForSku()
   ↓
2. RuleEngine.executeRule() with API_CALL type
   ↓
3. ApiCallExecutor发起HTTP请求
   ↓
4. 解析API返回结果
   ↓
5. 根据API返回值确定标签
   ↓
6. TagService.tagSku() 写入标签结果
```

## 业务场景与计算规则结合示例

### 场景1：智能货盘分级系统

**业务需求：**
根据商品的销售表现自动分级，用于差异化运营策略。

**数据来源：**
- 销量数据：月销量、季度销量
- 财务数据：利润率、毛利率
- 物流数据：周转天数、库存天数

**规则设计：**

```java
// S级货盘：高销量、高利润、快周转
SkuTagRule ruleS = new SkuTagRule();
ruleS.setRuleType("JAVA_EXPR");
ruleS.setRuleContent(
    "sales_volume >= 1000 && " +
    "profit_rate >= 0.3 && " +
    "turnover_days <= 15"
);
ruleS.setPriority(100);  // 最高优先级
ruleS.setTagValueId(TAG_VALUE_S);

// A级货盘：较好销量、良好利润
SkuTagRule ruleA = new SkuTagRule();
ruleA.setRuleType("JAVA_EXPR");
ruleA.setRuleContent(
    "sales_volume >= 500 && " +
    "profit_rate >= 0.2 && " +
    "turnover_days <= 30"
);
ruleA.setPriority(90);
ruleA.setTagValueId(TAG_VALUE_A);

// B级货盘：一般销量
SkuTagRule ruleB = new SkuTagRule();
ruleB.setRuleType("JAVA_EXPR");
ruleB.setRuleContent(
    "sales_volume >= 100 && " +
    "profit_rate >= 0.1 && " +
    "turnover_days <= 60"
);
ruleB.setPriority(80);
ruleB.setTagValueId(TAG_VALUE_B);

// C级货盘：低销量或滞销
SkuTagRule ruleC = new SkuTagRule();
ruleC.setRuleType("JAVA_EXPR");
ruleC.setRuleContent(
    "sales_volume < 100 || " +
    "profit_rate < 0.1 || " +
    "turnover_days > 60"
);
ruleC.setPriority(70);
ruleC.setTagValueId(TAG_VALUE_C);
```

**执行流程：**

```java
// 1. 准备SKU数据（从数据仓库获取）
Map<String, Object> skuData = prepareSkuData("SKU-12345");
// 返回：{sales_volume: 1200, profit_rate: 0.35, turnover_days: 12}

// 2. 执行规则计算
TagRuleService ruleService = new TagRuleService(tagService);
SkuTagResult result = ruleService.executeRulesForSku(
    "SKU-12345", 
    CARGO_GRADE_TAG_GROUP_ID, 
    skuData
);

// 3. 规则引擎按优先级执行：
//    - 尝试S级规则：1200>=1000 && 0.35>=0.3 && 12<=15 → true
//    - 匹配成功，打标为S级，停止后续规则评估

// 4. 标签结果写入数据库
// sku_tag_result: {sku_id: SKU-12345, tag_value: S, source: RULE}
```

### 场景2：动态定价策略标签

**业务需求：**
根据市场竞争情况和库存状况，自动标记商品的定价策略。

**规则设计：组合Java表达式和API调用**

```java
// 步骤1：调用外部API获取竞争对手价格
SkuTagRule priceCheckRule = new SkuTagRule();
priceCheckRule.setRuleCode("CHECK_COMPETITOR_PRICE");
priceCheckRule.setRuleType("API_CALL");
priceCheckRule.setRuleContent(
    "{" +
    "  \"url\": \"http://market-api/price?sku={sku_id}\"," +
    "  \"method\": \"GET\"," +
    "  \"responseField\": \"competitor_avg_price\"" +
    "}"
);

// 步骤2：基于价格和库存计算定价策略
SkuTagRule pricingStrategyRule = new SkuTagRule();
pricingStrategyRule.setRuleType("JAVA_EXPR");
pricingStrategyRule.setRuleContent(
    // 使用上一步API调用的结果
    "current_price < competitor_avg_price * 0.9 && stock_days > 60 ? 'CLEARANCE' : " +
    "current_price > competitor_avg_price * 1.1 && stock_days < 15 ? 'PREMIUM' : " +
    "'STANDARD'"
);
```

**数据流转：**

```
外部API (竞争对手价格)
       ↓
规则引擎计算 (ApiCallExecutor)
       ↓
结合SKU自身数据 (当前价格、库存天数)
       ↓
规则引擎计算 (JavaExpressionExecutor)
       ↓
确定定价策略标签 (CLEARANCE/PREMIUM/STANDARD)
       ↓
写入标签结果表
```

### 场景3：库存预警等级标签

**业务需求：**
根据库存量、销售速度、补货周期，自动标记库存预警等级。

**规则设计：结合SQL查询和Java表达式**

```java
// 步骤1：查询历史销售速度
SkuTagRule salesVelocityRule = new SkuTagRule();
salesVelocityRule.setRuleCode("CALC_SALES_VELOCITY");
salesVelocityRule.setRuleType("SQL_QUERY");
salesVelocityRule.setRuleContent(
    "SELECT " +
    "  AVG(daily_sales) as avg_daily_sales " +
    "FROM (" +
    "  SELECT DATE(order_date) as date, SUM(quantity) as daily_sales " +
    "  FROM orders " +
    "  WHERE sku_id = ? AND order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
    "  GROUP BY DATE(order_date)" +
    ") t"
);

// 步骤2：计算库存预警等级
SkuTagRule inventoryAlertRule = new SkuTagRule();
inventoryAlertRule.setRuleType("JAVA_EXPR");
inventoryAlertRule.setRuleContent(
    // 库存可用天数 = 当前库存 / 日均销量
    "stock_quantity / avg_daily_sales < lead_time ? 'CRITICAL' : " +
    "stock_quantity / avg_daily_sales < lead_time * 2 ? 'WARNING' : " +
    "stock_quantity / avg_daily_sales < lead_time * 3 ? 'NORMAL' : " +
    "'SUFFICIENT'"
);
```

**执行示例：**

```java
// 1. 执行SQL查询获取日均销量
// SQL结果：avg_daily_sales = 50

// 2. 结合当前库存数据
Map<String, Object> skuData = new HashMap<>();
skuData.put("stock_quantity", 300);     // 当前库存300件
skuData.put("avg_daily_sales", 50);     // 日均销量50件
skuData.put("lead_time", 7);            // 补货周期7天

// 3. 执行Java表达式计算
// 库存可用天数 = 300 / 50 = 6天
// 6 < 7 → 匹配CRITICAL规则
// 结果：打标为CRITICAL（紧急缺货预警）
```

## 规则优先级与冲突处理

### 优先级机制

当多个规则同时匹配时，系统按优先级选择：

```java
// 定义规则优先级
public class RulePriorityExample {
    
    public static void setupRules(TagRuleService ruleService) {
        // 高优先级规则：精确匹配
        SkuTagRule preciseRule = new SkuTagRule();
        preciseRule.setPriority(100);
        preciseRule.setRuleContent("category == 'electronics' && brand == 'Apple'");
        
        // 中优先级规则：类目匹配
        SkuTagRule categoryRule = new SkuTagRule();
        categoryRule.setPriority(80);
        categoryRule.setRuleContent("category == 'electronics'");
        
        // 低优先级规则：通用规则
        SkuTagRule generalRule = new SkuTagRule();
        generalRule.setPriority(50);
        generalRule.setRuleContent("sales_volume > 0");
        
        // 注册规则
        ruleService.registerRule(preciseRule);
        ruleService.registerRule(categoryRule);
        ruleService.registerRule(generalRule);
    }
}
```

### 冲突处理策略

```
规则执行顺序（按优先级降序）：
1. 优先级100规则
2. 优先级80规则
3. 优先级50规则

匹配策略：
- 首次匹配即停止（First Match）
- 一旦某个规则返回true，立即应用该规则的标签值
- 不再评估后续低优先级规则

示例：
SKU数据: {category: 'electronics', brand: 'Apple', sales_volume: 100}

执行过程：
1. 评估优先级100规则：'electronics' == 'electronics' && 'Apple' == 'Apple' → true
2. 匹配成功！应用该规则的标签值
3. 停止评估，不再执行优先级80和50的规则
```

## 批量处理与性能优化

### 批量打标流程

```java
public class BatchTaggingExample {
    
    public static void batchProcessSKUs(TagRuleService ruleService) {
        // 1. 从数据仓库获取SKU列表及其计算指标
        List<Map<String, Object>> skuDataList = fetchSkuDataFromWarehouse();
        
        // 2. 批量执行规则
        Map<String, Integer> stats = ruleService.batchExecuteRules(
            CARGO_GRADE_TAG_GROUP_ID, 
            skuDataList
        );
        
        // 3. 统计结果
        // {total: 1000, success: 980, failure: 5, skipped: 15}
        // skipped: 已有人工标签的SKU（人工标签优先级更高）
    }
    
    private static List<Map<String, Object>> fetchSkuDataFromWarehouse() {
        // 从数据仓库批量查询SKU的计算指标
        // SELECT sku_id, sales_volume, profit_rate, turnover_days
        // FROM sku_metrics
        // WHERE update_time >= CURRENT_DATE - 1
        return dataWarehouse.query(...);
    }
}
```

### 性能优化建议

1. **数据预处理**
```java
// 一次性查询所有需要的数据，避免规则执行时的N+1查询
Map<String, Map<String, Object>> skuMetrics = 
    dataWarehouse.batchQueryMetrics(skuIds);
```

2. **规则缓存**
```java
// 缓存已发布的规则，避免每次都从数据库加载
List<SkuTagRule> cachedRules = ruleService.getEnabledRules(tagGroupId);
```

3. **并行处理**
```java
// 对于大批量数据，可以分片并行处理
List<List<Map<String, Object>>> chunks = partitionList(skuDataList, 1000);
chunks.parallelStream().forEach(chunk -> 
    ruleService.batchExecuteRules(tagGroupId, chunk)
);
```

## 人工打标与规则打标的协同

### 优先级策略

```
优先级：人工打标 > 规则打标

场景1：规则打标后，人工覆盖
├─ 规则执行：SKU-001 → C级（销量低）
└─ 人工覆盖：产品经理评估后调整为B级（新品有潜力）
   └─ 结果：tag_result表记录source=MANUAL

场景2：人工打标后，规则跳过
├─ 人工打标：SKU-002 → S级（重点商品）
└─ 批量规则执行：检测到人工标签，跳过该SKU
   └─ 结果：保留人工标签，不被规则覆盖
```

### 实现示例

```java
public class ManualOverrideExample {
    
    public static void demonstrateManualOverride(
            TagService tagService, 
            TagRuleService ruleService) {
        
        // 1. 规则自动打标
        Map<String, Object> skuData = new HashMap<>();
        skuData.put("sku_id", "SKU-12345");
        skuData.put("sales_volume", 50);      // 低销量
        skuData.put("profit_rate", 0.08);     // 低利润
        
        SkuTagResult ruleResult = ruleService.executeRulesForSku(
            "SKU-12345", CARGO_GRADE_TAG_GROUP_ID, skuData
        );
        // 结果：C级货盘（符合规则）
        
        // 2. 产品经理人工覆盖
        SkuTagResult manualResult = tagService.tagSku(
            "SKU-12345",
            CARGO_GRADE_TAG_GROUP_ID,
            TAG_VALUE_B,              // 调整为B级
            TagSource.MANUAL,
            null,                      // 无规则编码
            null,                      // 无规则版本
            "product_manager",         // 操作人
            "新品潜力商品，预期3个月后销量提升",  // 原因
            null,                      // 有效期开始
            null                       // 有效期结束
        );
        
        // 3. 标签历史记录
        // sku_tag_history表记录：
        // {
        //   operation_type: UPDATE,
        //   old_value: C级,
        //   new_value: B级,
        //   source: MANUAL,
        //   operator: product_manager,
        //   reason: 新品潜力商品...
        // }
        
        // 4. 后续批量规则执行
        List<Map<String, Object>> batchData = prepareBatchData();
        Map<String, Integer> stats = ruleService.batchExecuteRules(
            CARGO_GRADE_TAG_GROUP_ID, 
            batchData
        );
        // SKU-12345会被跳过，保留人工标签
        // stats: {skipped: 1, ...}
    }
}
```

## 下游系统使用标签结果

### 备货系统集成

```java
public class InventoryPlanningIntegration {
    
    public static void planInventory(TagQueryService queryService) {
        // 1. 查询S级和A级货盘（优先备货）
        List<SkuTagResult> highPrioritySkus = new ArrayList<>();
        
        // 查询S级
        TagQueryService.QueryParams paramsS = new TagQueryService.QueryParams();
        paramsS.setTagGroupId(CARGO_GRADE_TAG_GROUP_ID);
        paramsS.setTagValueId(TAG_VALUE_S);
        paramsS.setPageSize(100);
        
        TagQueryService.PageResult<SkuTagResult> resultS = 
            queryService.queryTagsWithPagination(paramsS);
        highPrioritySkus.addAll(resultS.getData());
        
        // 查询A级
        paramsS.setTagValueId(TAG_VALUE_A);
        TagQueryService.PageResult<SkuTagResult> resultA = 
            queryService.queryTagsWithPagination(paramsS);
        highPrioritySkus.addAll(resultA.getData());
        
        // 2. 根据货盘等级制定备货策略
        for (SkuTagResult tag : highPrioritySkus) {
            InventoryPlan plan = new InventoryPlan();
            plan.setSkuId(tag.getSkuId());
            
            if (TAG_VALUE_S.equals(tag.getTagValueId())) {
                // S级货盘：高备货量，短补货周期
                plan.setTargetStock(1000);
                plan.setReorderPoint(300);
                plan.setReorderCycle(7);
            } else {
                // A级货盘：中等备货量
                plan.setTargetStock(500);
                plan.setReorderPoint(150);
                plan.setReorderCycle(14);
            }
            
            // 保存备货计划
            inventoryService.savePlan(plan);
        }
    }
}
```

### 促销系统集成

```java
public class PromotionIntegration {
    
    public static void createClearanceCampaign(TagQueryService queryService) {
        // 1. 查询C级货盘（需要清库存）
        TagQueryService.QueryParams params = new TagQueryService.QueryParams();
        params.setTagGroupId(CARGO_GRADE_TAG_GROUP_ID);
        params.setTagValueId(TAG_VALUE_C);
        params.setSource("RULE");  // 只查规则打标的（排除人工调整的）
        
        TagQueryService.PageResult<SkuTagResult> result = 
            queryService.queryTagsWithPagination(params);
        
        // 2. 为C级货盘创建促销活动
        for (SkuTagResult tag : result.getData()) {
            Promotion promotion = new Promotion();
            promotion.setSkuId(tag.getSkuId());
            promotion.setType("CLEARANCE");
            promotion.setDiscountRate(0.3);  // 70折
            promotion.setStartDate(new Date());
            promotion.setEndDate(DateUtils.addDays(new Date(), 30));
            promotion.setReason("C级货盘清仓促销，标签更新时间：" + tag.getUpdateTime());
            
            // 创建促销
            promotionService.createPromotion(promotion);
        }
    }
}
```

## 总结 (Summary)

规则引擎与标签系统的集成提供了强大的业务能力：

1. **规则引擎提供计算能力**
   - Java表达式：灵活的业务逻辑计算
   - SQL查询：数据库聚合和关联计算
   - API调用：外部系统数据集成

2. **标签系统提供业务语义**
   - 将计算结果转化为业务标签
   - 支持人工干预和覆盖
   - 完整的历史审计追溯

3. **协同工作流程**
   - 规则引擎执行数据计算
   - 标签系统存储业务结果
   - 下游系统消费标签数据

4. **最佳实践**
   - 根据数据来源选择合适的规则类型
   - 合理设置规则优先级
   - 批量处理提升性能
   - 人工标签保护机制
   - 完整的可追溯性

这种集成设计使得系统既具有自动化能力（规则引擎），又保持业务灵活性（人工打标），同时确保所有操作可追溯（历史审计）。
