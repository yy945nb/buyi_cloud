# Buyi 规则引擎 (Buyi Rule Engine)

## 概述 (Overview)

Buyi规则引擎是一个灵活、可配置的业务规则执行框架，支持通过配置流程进行规则结果计算。规则引擎支持三种类型的规则执行：

1. **Java表达式** - 使用JEXL执行Java表达式
2. **SQL查询** - 执行数据库SQL查询
3. **API接口调用** - 调用HTTP RESTful API接口

## 核心特性 (Core Features)

- ✅ **多类型规则支持** - Java表达式、SQL查询、API调用
- ✅ **流程编排** - 支持多步骤规则流程配置
- ✅ **条件执行** - 支持基于条件的规则执行
- ✅ **错误处理** - 完善的错误处理和日志记录
- ✅ **灵活配置** - 通过数据库或代码配置规则
- ✅ **执行日志** - 记录规则执行历史和性能指标

## 架构设计 (Architecture)

```
┌─────────────────────────────────────────────┐
│          RuleEngine (规则引擎)               │
├─────────────────────────────────────────────┤
│  - registerExecutor()                       │
│  - executeRule()                            │
└──────────────┬──────────────────────────────┘
               │
               ├──────────────────┬──────────────────┬─────────────────┐
               │                  │                  │                 │
        ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐   ┌─────▼─────┐
        │   Java表达式  │   │   SQL查询    │   │  API调用     │   │  自定义... │
        │   Executor   │   │   Executor   │   │  Executor    │   │  Executor │
        └─────────────┘   └─────────────┘   └─────────────┘   └───────────┘

┌─────────────────────────────────────────────┐
│          FlowEngine (流程引擎)               │
├─────────────────────────────────────────────┤
│  - registerRule()                           │
│  - executeFlow()                            │
└─────────────────────────────────────────────┘
```

## 快速开始 (Quick Start)

### 1. 配置数据库

执行SQL脚本创建规则引擎所需的表：

```bash
mysql -u username -p database < rule_engine_schema.sql
```

### 2. 初始化规则引擎

```java
// 创建规则引擎实例
RuleEngine ruleEngine = new RuleEngine();

// 注册执行器
ruleEngine.registerExecutor(new JavaExpressionExecutor());
ruleEngine.registerExecutor(new SqlQueryExecutor(jdbcUrl, username, password));
ruleEngine.registerExecutor(new ApiCallExecutor());
```

### 3. 执行简单规则

```java
// 创建规则配置
RuleConfig rule = new RuleConfig();
rule.setRuleCode("CALC_DISCOUNT");
rule.setRuleName("计算折扣价格");
rule.setRuleType(RuleType.JAVA_EXPR);
rule.setRuleContent("price * (1 - discount / 100)");

// 准备输入参数
Map<String, Object> params = new HashMap<>();
params.put("price", 100.0);
params.put("discount", 20.0);

// 执行规则
RuleContext context = new RuleContext(params);
context = ruleEngine.executeRule(rule, context);

// 获取结果
System.out.println("Result: " + context.getResult()); // 输出: 80.0
```

### 4. 执行规则流程

```java
// 创建流程引擎
FlowEngine flowEngine = new FlowEngine(ruleEngine);

// 注册规则
flowEngine.registerRule(rule1);
flowEngine.registerRule(rule2);
flowEngine.registerRule(rule3);

// 创建流程配置
RuleFlow flow = new RuleFlow();
flow.setFlowCode("ORDER_FLOW");
flow.setFlowName("订单处理流程");
flow.setSteps(steps);

// 执行流程
RuleContext result = flowEngine.executeFlow(flow, initialContext);
```

## 规则类型详解 (Rule Types)

### 1. Java表达式规则 (Java Expression)

使用Apache Commons JEXL进行表达式计算。

**示例：**
```java
// 简单计算
"a + b"

// 折扣计算
"price * (1 - discount / 100)"

// 条件判断
"stock > minStock && price < maxPrice"

// 复杂表达式
"(basePrice + tax) * quantity * (1 - discount / 100)"
```

**支持的操作：**
- 算术运算：+, -, *, /, %
- 比较运算：==, !=, <, >, <=, >=
- 逻辑运算：&&, ||, !
- 三元运算：condition ? value1 : value2

### 2. SQL查询规则 (SQL Query)

执行数据库查询并返回结果。

**配置示例：**
```java
RuleConfig rule = new RuleConfig();
rule.setRuleType(RuleType.SQL_QUERY);
rule.setRuleContent("SELECT SUM(quantity) as stock FROM amf_jh_stock WHERE shop = ? AND warehouse_sku = ?");

Map<String, Object> params = new HashMap<>();
params.put("inputs", Arrays.asList("shop", "warehouse_sku"));
rule.setRuleParams(params);
```

**输入参数：**
- 通过RuleContext传入查询参数
- 按照inputs定义的顺序绑定到SQL的?占位符

**输出结果：**
- 单行结果：返回Map<String, Object>
- 多行结果：返回List<Map<String, Object>>

### 3. API接口调用规则 (API Call)

调用HTTP RESTful API接口。

**配置示例：**
```java
String apiConfig = "{"
    + "\"url\": \"http://api.example.com/price?sku={sku}\","
    + "\"method\": \"GET\","
    + "\"headers\": {\"Content-Type\": \"application/json\"}"
    + "}";

RuleConfig rule = new RuleConfig();
rule.setRuleType(RuleType.API_CALL);
rule.setRuleContent(apiConfig);
```

**支持的HTTP方法：**
- GET
- POST
- PUT
- DELETE

**参数替换：**
- URL参数：使用{paramName}格式
- Body参数：使用{paramName}格式

## 流程编排 (Flow Orchestration)

流程编排允许按顺序执行多个规则，支持条件跳转和错误处理。

### 流程步骤配置

```java
RuleFlow.FlowStep step = new RuleFlow.FlowStep();
step.setStep(1);                    // 步骤序号
step.setRuleCode("RULE_CODE");      // 规则编码
step.setCondition("stock > 0");     // 执行条件（可选）
step.setOnSuccess("next");          // 成功后动作：next/complete
step.setOnFailure("abort");         // 失败后动作：next/abort
```

### 流程控制

- **next**: 继续执行下一步
- **complete**: 完成流程，不再执行后续步骤
- **abort**: 中止流程

### 条件执行

使用Java表达式作为条件，条件为true时执行该步骤：

```java
step.setCondition("discount > 0 && discount <= 100");
```

## 数据库表结构 (Database Schema)

### rule_config (规则配置表)

存储规则定义和配置。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 规则ID |
| rule_code | varchar(64) | 规则编码（唯一） |
| rule_name | varchar(128) | 规则名称 |
| rule_type | varchar(32) | 规则类型 |
| rule_content | text | 规则内容 |
| rule_params | json | 规则参数 |
| status | tinyint | 状态（0-禁用，1-启用） |
| priority | int | 优先级 |

### rule_flow (规则流程表)

存储流程编排配置。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 流程ID |
| flow_code | varchar(64) | 流程编码（唯一） |
| flow_name | varchar(128) | 流程名称 |
| flow_config | json | 流程配置 |
| status | tinyint | 状态（0-禁用，1-启用） |

### rule_execution_log (执行日志表)

记录规则执行历史。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | 日志ID |
| flow_code | varchar(64) | 流程编码 |
| rule_code | varchar(64) | 规则编码 |
| input_params | json | 输入参数 |
| output_result | text | 输出结果 |
| execution_time | int | 执行时间（毫秒） |
| status | tinyint | 执行状态 |
| error_message | text | 错误信息 |

## 示例场景 (Use Cases)

### 场景1：订单价格计算

```java
// 步骤1：查询库存
RuleConfig checkStock = new RuleConfig();
checkStock.setRuleCode("CHECK_STOCK");
checkStock.setRuleType(RuleType.SQL_QUERY);
checkStock.setRuleContent("SELECT quantity FROM inventory WHERE sku = ?");

// 步骤2：获取基础价格
RuleConfig getPrice = new RuleConfig();
getPrice.setRuleCode("GET_PRICE");
getPrice.setRuleType(RuleType.API_CALL);
getPrice.setRuleContent("{\"url\":\"http://api/price?sku={sku}\",\"method\":\"GET\"}");

// 步骤3：计算折扣价格
RuleConfig calcDiscount = new RuleConfig();
calcDiscount.setRuleCode("CALC_DISCOUNT");
calcDiscount.setRuleType(RuleType.JAVA_EXPR);
calcDiscount.setRuleContent("GET_PRICE_result * (1 - discount / 100)");

// 创建流程
RuleFlow flow = createFlow(checkStock, getPrice, calcDiscount);
RuleContext result = flowEngine.executeFlow(flow, context);
```

### 场景2：会员等级判断

```java
RuleConfig memberLevelRule = new RuleConfig();
memberLevelRule.setRuleCode("CALC_MEMBER_LEVEL");
memberLevelRule.setRuleType(RuleType.JAVA_EXPR);
memberLevelRule.setRuleContent(
    "totalAmount >= 10000 ? 'VIP' : " +
    "(totalAmount >= 5000 ? 'Gold' : " +
    "(totalAmount >= 1000 ? 'Silver' : 'Normal'))"
);
```

### 场景3：库存预警

```java
RuleConfig alertRule = new RuleConfig();
alertRule.setRuleCode("STOCK_ALERT");
alertRule.setRuleType(RuleType.JAVA_EXPR);
alertRule.setRuleContent("stock < minStock && stock > 0");
```

## 性能优化 (Performance)

1. **规则缓存** - FlowEngine内置规则配置缓存
2. **连接池** - SQL执行器建议使用连接池
3. **HTTP客户端复用** - API执行器使用连接复用
4. **表达式编译缓存** - JEXL引擎内置表达式缓存

## 扩展开发 (Extension)

### 自定义规则执行器

实现`RuleExecutor`接口：

```java
public class CustomExecutor implements RuleExecutor {
    @Override
    public RuleContext execute(RuleConfig ruleConfig, RuleContext context) {
        // 实现自定义逻辑
        return context;
    }
    
    @Override
    public boolean supports(RuleConfig ruleConfig) {
        return RuleType.CUSTOM.equals(ruleConfig.getRuleType());
    }
}

// 注册到引擎
ruleEngine.registerExecutor(new CustomExecutor());
```

## 最佳实践 (Best Practices)

1. **规则命名** - 使用清晰的规则编码，如：CALC_DISCOUNT_PRICE
2. **错误处理** - 始终检查context.isSuccess()
3. **参数验证** - 在规则执行前验证输入参数
4. **日志记录** - 记录关键规则执行日志到数据库
5. **性能监控** - 监控executionTime，优化慢规则
6. **规则版本** - 考虑规则版本管理和回滚机制

## 安全考虑 (Security)

1. **SQL注入** - 使用PreparedStatement避免SQL注入
2. **表达式注入** - 限制JEXL表达式的执行权限
3. **API安全** - 使用HTTPS和认证机制
4. **参数验证** - 验证所有输入参数
5. **权限控制** - 实现规则配置的访问控制

## 依赖项 (Dependencies)

- Apache Commons JEXL 3.3 - Java表达式引擎
- MySQL Connector 8.0.33 - 数据库连接
- Apache HttpClient 4.5.14 - HTTP客户端
- Gson 2.10.1 - JSON处理
- SLF4J + Logback - 日志框架

## 运行示例 (Run Example)

```bash
# 编译项目
mvn clean compile

# 运行示例
mvn exec:java -Dexec.mainClass="com.buyi.ruleengine.RuleEngineExample"

# 运行测试
mvn test
```

## 许可证 (License)

本项目为Buyi Cloud项目的一部分，遵循项目统一许可证。

## 联系方式 (Contact)

如有问题或建议，请通过GitHub Issue反馈。
