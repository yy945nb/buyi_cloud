# Processing Engine (流程处理引擎)

## 概述 (Overview)

Processing Engine 是一个强大的流程处理引擎，专门设计用于解析和执行 `processing.json` 格式的规则流程配置文件。它支持条件转换、优先级排序、多种动作类型以及变量在规则间的传递。

## 核心特性 (Core Features)

- ✅ **JSON配置驱动** - 通过JSON配置文件定义完整的规则流程
- ✅ **条件转换** - 支持基于JEXL表达式的条件转换
- ✅ **优先级排序** - 多个转换条件时按优先级选择
- ✅ **多动作类型** - 支持SCRIPT和API两种动作类型
- ✅ **变量传递** - 变量在规则和动作间自动传递
- ✅ **工具函数** - 内置丰富的工具函数支持
- ✅ **执行保护** - 支持最大执行深度和超时控制
- ✅ **执行跟踪** - 详细的执行轨迹记录

## 快速开始 (Quick Start)

### 1. 基本使用

```java
import com.buyi.ruleengine.processing.service.ProcessingConfigLoader;
import com.buyi.ruleengine.processing.service.ProcessingEngine;
import com.buyi.ruleengine.processing.model.ProcessingConfig;
import com.buyi.ruleengine.processing.model.ProcessingContext;

// 创建加载器和引擎
ProcessingConfigLoader loader = new ProcessingConfigLoader();
ProcessingEngine engine = new ProcessingEngine();

// 从文件加载配置
ProcessingConfig config = loader.loadFromFile("rule/processing.json");
// 或从类路径资源加载
// ProcessingConfig config = loader.loadFromResource("rule/processing.json");

// 加载配置到引擎
engine.loadConfig(config);

// 准备输入变量
Map<String, Object> variables = new HashMap<>();
variables.put("userId", "123");
variables.put("verified", true);
variables.put("items", itemsList);

// 执行流程
ProcessingContext result = engine.execute(variables);

// 检查结果
if (result.isSuccess()) {
    System.out.println("Status: " + result.getVariable("status"));
    System.out.println("Message: " + result.getVariable("confirmationMessage"));
}
```

### 2. JSON配置格式

```json
{
  "version": "1.0",
  "entryPoint": "validate-order",
  "globalSettings": {
    "maxExecutionDepth": 50,
    "timeout": 30000
  },
  "rules": [
    {
      "ruleId": "validate-order",
      "description": "验证订单并获取用户数据",
      "actions": [
        {
          "actionId": "fetch-user-data",
          "type": "API",
          "config": {
            "url": "https://api.example.com/users/${userId}",
            "method": "GET",
            "headers": {"Accept": "application/json"}
          },
          "outputVariable": "userApiResponse",
          "continueOnError": false
        },
        {
          "actionId": "calculate-total",
          "type": "SCRIPT",
          "config": {
            "expression": "util:roundTo(subtotal + tax, 2)"
          },
          "outputVariable": "total"
        }
      ],
      "transitions": [
        {
          "condition": "!verified",
          "targetRule": "verification-required",
          "priority": 1
        },
        {
          "condition": "verified",
          "targetRule": "calculate-totals",
          "priority": 2
        }
      ]
    },
    {
      "ruleId": "high-value-order",
      "description": "高价值订单处理",
      "terminal": true,
      "actions": [
        {
          "actionId": "set-status",
          "type": "SCRIPT",
          "config": {
            "expression": "'APPROVED_HIGH_VALUE'"
          },
          "outputVariable": "status"
        }
      ]
    }
  ]
}
```

## 配置详解 (Configuration Details)

### 顶层配置

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| version | String | 否 | 配置版本 |
| entryPoint | String | 是 | 入口规则ID |
| globalSettings | Object | 否 | 全局设置 |
| rules | Array | 是 | 规则列表 |

### 全局设置 (globalSettings)

| 字段 | 类型 | 默认值 | 说明 |
|------|------|------|------|
| maxExecutionDepth | int | 50 | 最大执行深度（防止无限循环） |
| timeout | long | 30000 | 执行超时时间（毫秒） |

### 规则配置 (rule)

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| ruleId | String | 是 | 规则唯一标识 |
| description | String | 否 | 规则描述 |
| terminal | boolean | 否 | 是否为终止节点 |
| actions | Array | 否 | 动作列表 |
| transitions | Array | 否 | 转换列表 |

### 动作配置 (action)

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| actionId | String | 是 | 动作唯一标识 |
| type | String | 是 | 动作类型：SCRIPT 或 API |
| config | Object | 是 | 动作配置 |
| outputVariable | String | 否 | 输出变量名 |
| outputExpression | String | 否 | 输出表达式（提取结果中的特定值） |
| continueOnError | boolean | 否 | 错误时是否继续执行 |

### 转换配置 (transition)

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| condition | String | 否 | 条件表达式（空则默认通过） |
| targetRule | String | 是 | 目标规则ID |
| priority | int | 否 | 优先级（数字越小优先级越高） |

## 动作类型 (Action Types)

### SCRIPT 动作

执行JEXL表达式脚本。

**配置示例：**
```json
{
  "actionId": "calculate-tax",
  "type": "SCRIPT",
  "config": {
    "expression": "util:roundTo(subtotal * 0.1, 2)"
  },
  "outputVariable": "tax"
}
```

**支持的表达式特性：**
- 基本运算：`+`, `-`, `*`, `/`, `%`
- 比较运算：`==`, `!=`, `<`, `>`, `<=`, `>=`
- 逻辑运算：`&&`, `||`, `!`
- 三元运算：`condition ? valueIfTrue : valueIfFalse`
- 对象属性访问：`object.property`
- 字符串操作：`'Hello ' + name`

### API 动作

执行HTTP API调用。

**配置示例：**
```json
{
  "actionId": "fetch-user",
  "type": "API",
  "config": {
    "url": "https://api.example.com/users/${userId}",
    "method": "GET",
    "headers": {
      "Accept": "application/json",
      "Authorization": "Bearer ${token}"
    }
  },
  "outputVariable": "userData"
}
```

**支持的HTTP方法：** GET, POST, PUT, DELETE

**变量替换：** 使用 `${variableName}` 格式在URL、headers和body中引用变量

## 工具函数 (Utility Functions)

使用命名空间语法 `util:functionName()` 调用工具函数。

### 数学函数

| 函数 | 说明 | 示例 |
|------|------|------|
| roundTo(value, decimals) | 四舍五入到指定小数位 | `util:roundTo(3.14159, 2)` → `3.14` |
| max(a, b) | 返回最大值 | `util:max(10, 20)` → `20` |
| min(a, b) | 返回最小值 | `util:min(10, 20)` → `10` |
| abs(value) | 绝对值 | `util:abs(-5)` → `5` |
| ceil(value) | 向上取整 | `util:ceil(3.2)` → `4` |
| floor(value) | 向下取整 | `util:floor(3.8)` → `3` |

### 字符串函数

| 函数 | 说明 | 示例 |
|------|------|------|
| concat(values...) | 字符串连接 | `util:concat('Hello', ' ', 'World')` |
| substring(str, start, end) | 获取子串 | `util:substring('Hello', 0, 3)` → `'Hel'` |
| toUpperCase(str) | 转大写 | `util:toUpperCase('hello')` → `'HELLO'` |
| toLowerCase(str) | 转小写 | `util:toLowerCase('HELLO')` → `'hello'` |
| trim(str) | 去除首尾空格 | `util:trim(' text ')` → `'text'` |

### 其他函数

| 函数 | 说明 | 示例 |
|------|------|------|
| uuid() | 生成UUID | `util:uuid()` → `'550e8400-e29b...'` |
| timestamp() | 获取当前时间戳 | `util:timestamp()` |
| isEmpty(value) | 检查是否为空 | `util:isEmpty(name)` |
| isNotEmpty(value) | 检查是否不为空 | `util:isNotEmpty(name)` |
| isNull(value) | 检查是否为null | `util:isNull(value)` |
| nvl(value, default) | 空值替换 | `util:nvl(name, 'Unknown')` |
| iif(condition, trueVal, falseVal) | 条件表达式 | `util:iif(age > 18, 'Adult', 'Minor')` |

## 执行流程 (Execution Flow)

1. **加载配置** - 解析JSON配置文件
2. **验证配置** - 检查入口点和规则引用是否有效
3. **开始执行** - 从entryPoint指定的规则开始
4. **执行动作** - 按顺序执行规则中的所有动作
5. **检查转换** - 按优先级评估转换条件
6. **跳转规则** - 跳转到匹配的目标规则
7. **终止执行** - 到达terminal规则或无匹配转换时结束

## 执行结果 (Execution Result)

```java
ProcessingContext result = engine.execute(variables);

// 检查执行状态
boolean success = result.isSuccess();
String error = result.getErrorMessage();

// 获取输出变量
Object status = result.getVariable("status");
Map<String, Object> allVars = result.getAllVariables();

// 获取执行跟踪
List<ExecutionTrace> traces = result.getExecutionTraces();
long executionTime = result.getTotalExecutionTime();
```

## 最佳实践 (Best Practices)

1. **规则命名** - 使用清晰的kebab-case命名，如 `validate-order`
2. **条件优先级** - 更具体的条件使用更高优先级（更小的数字）
3. **错误处理** - 对于非关键动作设置 `continueOnError: true`
4. **变量命名** - 使用有意义的变量名便于跟踪调试
5. **终止节点** - 确保所有执行路径都能到达terminal规则
6. **超时设置** - 根据API调用数量合理设置timeout
7. **深度控制** - 对于复杂流程适当增加maxExecutionDepth

## 示例场景 (Example Scenarios)

### 订单处理流程

参见 `src/main/resources/rule/processing.json` 文件，展示了一个完整的订单处理流程：
- 验证用户身份
- 获取用户信息（API调用）
- 计算订单总额
- 根据订单金额分流处理
- 生成确认消息

### 运行示例

```bash
# 编译项目
mvn clean compile

# 运行示例程序
mvn exec:java -Dexec.mainClass="com.buyi.ruleengine.processing.ProcessingEngineDemo"

# 运行测试
mvn test -Dtest=ProcessingEngineTest
```

## 与现有规则引擎的关系

Processing Engine 是对现有 Rule Engine 的补充：

| 特性 | Rule Engine | Processing Engine |
|------|-------------|-------------------|
| 配置格式 | 代码/数据库 | JSON文件 |
| 流程控制 | 步骤序列 | 条件转换 |
| 规则类型 | JAVA_EXPR, SQL_QUERY, API_CALL | SCRIPT, API |
| 变量传递 | 手动通过result_key | 自动通过outputVariable |
| 适用场景 | 简单计算、数据查询 | 复杂业务流程 |

## 许可证 (License)

本项目为Buyi Cloud项目的一部分，遵循项目统一许可证。
