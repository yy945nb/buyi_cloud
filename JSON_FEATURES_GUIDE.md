# JSON配置和动态功能指南
# JSON Configuration and Dynamic Features Guide

本文档介绍规则引擎的JSON配置、优先级排序和动态SQL功能。
This document introduces JSON configuration, priority-based sorting, and dynamic SQL features in the rule engine.

## 目录 (Table of Contents)

1. [JSON配置加载](#json配置加载)
2. [优先级排序](#优先级排序)
3. [规则间结果传递](#规则间结果传递)
4. [动态SQL拼接](#动态sql拼接)
5. [完整示例](#完整示例)

---

## JSON配置加载

### 1. 加载单个规则配置

```java
import com.buyi.ruleengine.service.JsonConfigLoader;
import com.buyi.ruleengine.model.RuleConfig;

JsonConfigLoader loader = new JsonConfigLoader();

// 从文件加载
RuleConfig rule = loader.loadRuleConfig("path/to/rule.json");

// 从字符串加载
String jsonString = "{\"ruleCode\":\"CALC_PRICE\",\"ruleName\":\"计算价格\",...}";
RuleConfig rule = loader.loadRuleConfigFromString(jsonString);
```

### 2. 规则配置JSON格式

```json
{
  "ruleCode": "CALC_DISCOUNT_PRICE",
  "ruleName": "计算折扣价格",
  "ruleType": "JAVA_EXPR",
  "ruleContent": "price * (1 - discount / 100)",
  "description": "根据原价和折扣百分比计算最终价格",
  "status": 1,
  "priority": 100,
  "ruleParams": {
    "inputs": ["price", "discount"],
    "output": "finalPrice"
  }
}
```

### 3. 加载多个规则配置

```java
List<RuleConfig> rules = loader.loadRuleConfigs("path/to/rules.json");

// JSON格式为数组
// [
//   {"ruleCode": "RULE1", ...},
//   {"ruleCode": "RULE2", ...}
// ]
```

### 4. 加载流程配置

```java
RuleFlow flow = loader.loadFlowConfig("path/to/flow.json");

// 或从字符串加载
RuleFlow flow = loader.loadFlowConfigFromString(jsonString);
```

### 5. 流程配置JSON格式

```json
{
  "flowCode": "ORDER_PRICE_CALCULATION_FLOW",
  "flowName": "订单价格计算流程",
  "description": "完整的订单价格计算流程",
  "status": 1,
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
      "ruleCode": "GET_BASE_PRICE",
      "condition": "QUERY_STOCK_result != null",
      "onSuccess": "next",
      "onFailure": "abort"
    }
  ]
}
```

---

## 优先级排序

### 1. 启用/禁用优先级排序

```java
FlowEngine flowEngine = new FlowEngine(ruleEngine);

// 启用优先级排序（默认启用）
flowEngine.setEnablePrioritySorting(true);

// 禁用优先级排序（按原始步骤顺序执行）
flowEngine.setEnablePrioritySorting(false);

// 检查是否启用
boolean enabled = flowEngine.isEnablePrioritySorting();
```

### 2. 优先级配置

在规则配置中设置`priority`字段：

```json
{
  "ruleCode": "HIGH_PRIORITY_RULE",
  "ruleName": "高优先级规则",
  "ruleType": "JAVA_EXPR",
  "ruleContent": "a + b",
  "priority": 100
}
```

- **数值越大，优先级越高** (Higher number = Higher priority)
- 默认优先级为 0
- 相同优先级的规则按原始步骤顺序执行

### 3. 优先级排序示例

```java
// 创建规则
RuleConfig rule1 = new RuleConfig();
rule1.setRuleCode("RULE1");
rule1.setPriority(10);  // 低优先级
flowEngine.registerRule(rule1);

RuleConfig rule2 = new RuleConfig();
rule2.setRuleCode("RULE2");
rule2.setPriority(100); // 高优先级
flowEngine.registerRule(rule2);

RuleConfig rule3 = new RuleConfig();
rule3.setRuleCode("RULE3");
rule3.setPriority(50);  // 中等优先级
flowEngine.registerRule(rule3);

// 执行流程时，实际执行顺序将是：RULE2 (100) -> RULE3 (50) -> RULE1 (10)
RuleContext result = flowEngine.executeFlow(flow, context);
```

### 4. 使用场景

优先级排序适用于：
- 需要先执行验证规则，再执行业务规则
- 需要先执行高频查询，再执行低频查询
- 需要先执行轻量级规则，再执行重量级规则

---

## 规则间结果传递

### 1. 自动结果传递

规则引擎自动将每个步骤的执行结果保存到上下文中，供后续步骤使用：

```java
// 步骤1：计算基础价格
RuleConfig rule1 = new RuleConfig();
rule1.setRuleCode("CALC_BASE");
rule1.setRuleContent("price * quantity");

// 步骤2：应用折扣（使用步骤1的结果）
RuleConfig rule2 = new RuleConfig();
rule2.setRuleCode("APPLY_DISCOUNT");
rule2.setRuleContent("CALC_BASE_result * (1 - discount / 100)");
//                    ^^^^^^^^^^^^^^^^
//                    引用上一步的结果
```

### 2. 结果命名规则

规则执行结果保存为：`{ruleCode}_result`

例如：
- 规则代码为 `QUERY_STOCK`，结果键为 `QUERY_STOCK_result`
- 规则代码为 `GET_PRICE`，结果键为 `GET_PRICE_result`

### 3. 在条件中使用结果

```json
{
  "step": 2,
  "ruleCode": "NEXT_RULE",
  "condition": "QUERY_STOCK_result != null && QUERY_STOCK_result.stock > 0",
  "onSuccess": "next",
  "onFailure": "abort"
}
```

### 4. 完整示例

```java
// 创建三个规则
RuleConfig validateRule = new RuleConfig();
validateRule.setRuleCode("VALIDATE_ORDER");
validateRule.setRuleContent("quantity > 0 && quantity <= 100");
flowEngine.registerRule(validateRule);

RuleConfig calcTotalRule = new RuleConfig();
calcTotalRule.setRuleCode("CALC_TOTAL");
calcTotalRule.setRuleContent("quantity * price");
flowEngine.registerRule(calcTotalRule);

RuleConfig discountRule = new RuleConfig();
discountRule.setRuleCode("APPLY_DISCOUNT");
discountRule.setRuleContent("CALC_TOTAL_result * (1 - discount / 100)");
flowEngine.registerRule(discountRule);

// 创建流程
RuleFlow flow = new RuleFlow();
// ... 添加步骤 ...

// 执行
Map<String, Object> params = new HashMap<>();
params.put("quantity", 5);
params.put("price", 100.0);
params.put("discount", 10.0);

RuleContext context = new RuleContext(params);
context = flowEngine.executeFlow(flow, context);

// 结果：450.0 (5 * 100 * 0.9)
System.out.println(context.getResult());
```

---

## 动态SQL拼接

### 1. 基础配置

在规则参数中添加`dynamicSql`配置：

```json
{
  "ruleCode": "DYNAMIC_QUERY",
  "ruleType": "SQL_QUERY",
  "ruleContent": "SELECT * FROM products",
  "ruleParams": {
    "dynamicSql": {
      "whereConditions": [...],
      "orderBy": "price",
      "orderDirection": "ASC",
      "limit": 10
    }
  }
}
```

### 2. 动态WHERE条件

#### 配置格式

```json
"whereConditions": [
  {
    "field": "category",
    "operator": "=",
    "paramName": "category"
  },
  {
    "field": "price",
    "operator": ">=",
    "paramName": "minPrice"
  }
]
```

#### 支持的操作符

- `=` - 等于
- `>` - 大于
- `<` - 小于
- `>=` - 大于等于
- `<=` - 小于等于
- `!=` - 不等于
- `LIKE` - 模糊匹配

#### 可选条件

如果参数值为`null`，该条件将被忽略：

```java
Map<String, Object> params = new HashMap<>();
params.put("category", "electronics");  // 会添加到WHERE条件
params.put("minPrice", null);           // 不会添加到WHERE条件

// 生成的SQL: SELECT * FROM products WHERE category = ?
```

### 3. 动态ORDER BY

```json
"dynamicSql": {
  "orderBy": "price",
  "orderDirection": "DESC"
}
```

- `orderBy`: 排序字段
- `orderDirection`: `ASC` 或 `DESC`

### 4. 动态LIMIT

```json
"dynamicSql": {
  "limit": 10
}
```

### 5. 完整示例

#### JSON配置

```json
{
  "ruleCode": "SEARCH_PRODUCTS",
  "ruleName": "搜索商品",
  "ruleType": "SQL_QUERY",
  "ruleContent": "SELECT * FROM products",
  "ruleParams": {
    "dynamicSql": {
      "whereConditions": [
        {
          "field": "category",
          "operator": "=",
          "paramName": "category"
        },
        {
          "field": "price",
          "operator": ">=",
          "paramName": "minPrice"
        },
        {
          "field": "price",
          "operator": "<=",
          "paramName": "maxPrice"
        },
        {
          "field": "name",
          "operator": "LIKE",
          "paramName": "searchName"
        }
      ],
      "orderBy": "price",
      "orderDirection": "ASC",
      "limit": 20
    }
  }
}
```

#### Java代码

```java
// 加载规则
RuleConfig rule = loader.loadRuleConfig("search_products.json");

// 准备参数
Map<String, Object> params = new HashMap<>();
params.put("category", "electronics");
params.put("minPrice", 100.0);
params.put("maxPrice", 1000.0);
params.put("searchName", "%phone%");

RuleContext context = new RuleContext(params);

// 执行查询
context = ruleEngine.executeRule(rule, context);

// 生成的SQL:
// SELECT * FROM products 
// WHERE category = ? AND price >= ? AND price <= ? AND name LIKE ?
// ORDER BY price ASC
// LIMIT 20
```

### 6. 安全性

动态SQL功能使用`PreparedStatement`防止SQL注入：
- 所有参数值使用参数绑定，不直接拼接到SQL中
- 字段名和表名不从用户输入获取，而是从配置文件获取
- 支持的操作符在代码中硬编码，不接受任意输入

---

## 完整示例

### 场景：订单价格计算系统

#### 1. 定义规则（JSON）

**validate_order.json**
```json
{
  "ruleCode": "VALIDATE_ORDER",
  "ruleName": "验证订单",
  "ruleType": "JAVA_EXPR",
  "ruleContent": "quantity > 0 && quantity <= 100",
  "priority": 200
}
```

**query_stock.json**
```json
{
  "ruleCode": "QUERY_STOCK",
  "ruleName": "查询库存",
  "ruleType": "SQL_QUERY",
  "ruleContent": "SELECT * FROM stock",
  "priority": 150,
  "ruleParams": {
    "dynamicSql": {
      "whereConditions": [
        {
          "field": "sku",
          "operator": "=",
          "paramName": "sku"
        },
        {
          "field": "warehouse",
          "operator": "=",
          "paramName": "warehouse"
        }
      ]
    }
  }
}
```

**calc_price.json**
```json
{
  "ruleCode": "CALC_PRICE",
  "ruleName": "计算价格",
  "ruleType": "JAVA_EXPR",
  "ruleContent": "quantity * price",
  "priority": 100
}
```

**apply_discount.json**
```json
{
  "ruleCode": "APPLY_DISCOUNT",
  "ruleName": "应用折扣",
  "ruleType": "JAVA_EXPR",
  "ruleContent": "CALC_PRICE_result * (1 - discount / 100)",
  "priority": 50
}
```

**order_flow.json**
```json
{
  "flowCode": "ORDER_CALCULATION_FLOW",
  "flowName": "订单计算流程",
  "description": "完整的订单价格计算流程",
  "steps": [
    {
      "step": 1,
      "ruleCode": "VALIDATE_ORDER",
      "onSuccess": "next",
      "onFailure": "abort"
    },
    {
      "step": 2,
      "ruleCode": "QUERY_STOCK",
      "condition": "VALIDATE_ORDER_result == true",
      "onSuccess": "next",
      "onFailure": "abort"
    },
    {
      "step": 3,
      "ruleCode": "CALC_PRICE",
      "condition": "QUERY_STOCK_result != null && QUERY_STOCK_result.quantity >= quantity",
      "onSuccess": "next",
      "onFailure": "abort"
    },
    {
      "step": 4,
      "ruleCode": "APPLY_DISCOUNT",
      "condition": "discount != null && discount > 0",
      "onSuccess": "complete",
      "onFailure": "next"
    }
  ]
}
```

#### 2. 使用代码

```java
import com.buyi.ruleengine.service.*;
import com.buyi.ruleengine.model.*;
import com.buyi.ruleengine.executor.*;

public class OrderCalculationExample {
    
    public static void main(String[] args) throws Exception {
        // 1. 初始化规则引擎
        RuleEngine ruleEngine = new RuleEngine();
        ruleEngine.registerExecutor(new JavaExpressionExecutor());
        ruleEngine.registerExecutor(new SqlQueryExecutor(
            "jdbc:mysql://localhost:3306/mydb",
            "user",
            "password"
        ));
        
        // 2. 初始化流程引擎
        FlowEngine flowEngine = new FlowEngine(ruleEngine);
        flowEngine.setEnablePrioritySorting(true); // 启用优先级排序
        
        // 3. 加载配置
        JsonConfigLoader loader = new JsonConfigLoader();
        
        // 加载规则
        RuleConfig validateRule = loader.loadRuleConfig("validate_order.json");
        RuleConfig queryStockRule = loader.loadRuleConfig("query_stock.json");
        RuleConfig calcPriceRule = loader.loadRuleConfig("calc_price.json");
        RuleConfig discountRule = loader.loadRuleConfig("apply_discount.json");
        
        // 注册规则
        flowEngine.registerRule(validateRule);
        flowEngine.registerRule(queryStockRule);
        flowEngine.registerRule(calcPriceRule);
        flowEngine.registerRule(discountRule);
        
        // 加载流程
        RuleFlow flow = loader.loadFlowConfig("order_flow.json");
        
        // 4. 准备输入参数
        Map<String, Object> params = new HashMap<>();
        params.put("quantity", 5);
        params.put("price", 100.0);
        params.put("discount", 10.0);
        params.put("sku", "PROD-12345");
        params.put("warehouse", "WH-001");
        
        // 5. 执行流程
        RuleContext context = new RuleContext(params);
        context = flowEngine.executeFlow(flow, context);
        
        // 6. 处理结果
        if (context.isSuccess()) {
            System.out.println("订单计算成功");
            System.out.println("最终价格: " + context.getResult());
            
            // 访问中间结果
            System.out.println("验证结果: " + context.getInput("VALIDATE_ORDER_result"));
            System.out.println("库存信息: " + context.getInput("QUERY_STOCK_result"));
            System.out.println("原始价格: " + context.getInput("CALC_PRICE_result"));
        } else {
            System.err.println("订单计算失败: " + context.getErrorMessage());
        }
    }
}
```

#### 3. 执行流程

由于启用了优先级排序，实际执行顺序为：

1. **VALIDATE_ORDER** (priority: 200) - 验证订单数量
2. **QUERY_STOCK** (priority: 150) - 查询库存
3. **CALC_PRICE** (priority: 100) - 计算总价
4. **APPLY_DISCOUNT** (priority: 50) - 应用折扣

#### 4. 结果传递链

```
quantity=5, price=100 
    ↓
VALIDATE_ORDER → result: true
    ↓
QUERY_STOCK → result: {quantity: 100, ...}
    ↓
CALC_PRICE (使用 QUERY_STOCK_result) → result: 500
    ↓
APPLY_DISCOUNT (使用 CALC_PRICE_result) → result: 450
```

---

## 最佳实践

### 1. JSON配置管理

- 将规则配置和流程配置分开存放
- 使用版本控制管理配置文件
- 为不同环境使用不同的配置目录

### 2. 优先级设计

- 验证规则使用高优先级（200+）
- 数据查询规则使用中等优先级（100-199）
- 计算规则使用低优先级（50-99）
- 输出规则使用最低优先级（0-49）

### 3. 动态SQL

- 只对必要的字段使用动态条件
- 避免在生产环境直接使用用户输入作为字段名
- 为动态查询添加合理的LIMIT
- 在性能关键场景考虑禁用动态SQL，使用预定义SQL

### 4. 错误处理

- 总是检查`context.isSuccess()`
- 使用`onFailure`策略控制错误传播
- 记录执行日志便于问题排查

---

## 参考资料

- [RULE_ENGINE_README.md](../../../RULE_ENGINE_README.md) - 规则引擎完整文档
- [示例配置](../examples/) - 各种配置示例
- [单元测试](../../../test/java/com/buyi/ruleengine/) - 功能测试示例
