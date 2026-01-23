# Buyi DSL规则链引擎 (Buyi DSL Rule Chain Engine)

## 概述 (Overview)

Buyi DSL规则链引擎是一套用于定义和执行业务规则链的领域特定语言(DSL)系统。通过简洁直观的DSL语法，您可以定义复杂的规则流程，包括条件判断、分支、循环等逻辑控制。

## 核心特性 (Core Features)

- ✅ **自定义DSL语法** - 简洁直观的规则链定义语法
- ✅ **多种节点类型** - 支持规则节点、条件节点、分支节点、合并节点
- ✅ **表达式求值** - 基于JEXL的强大表达式引擎
- ✅ **变量传递** - 支持规则间的变量传递和结果引用
- ✅ **执行追踪** - 详细的执行日志和追踪信息
- ✅ **超时控制** - 支持执行超时和深度限制
- ✅ **注释支持** - 支持单行注释(//, #)和块注释(/* */)
- ✅ **错误处理** - 完善的错误处理和继续执行选项

## DSL语法 (DSL Syntax)

### 基本结构

```dsl
chain {
    id: "rule_chain_id"
    name: "规则链名称"
    version: "1.0.0"
    description: "规则链描述"
    
    config {
        maxDepth: 100
        executionTimeout: 60000
        enableLogging: true
    }
    
    start -> firstNode
    
    node firstNode {
        type: rule
        expression: `a + b`
        output: "result"
        next: nextNode
    }
    
    // 更多节点...
    
    end
}
```

### 链配置 (Chain Configuration)

| 属性 | 说明 | 默认值 |
|------|------|--------|
| id | 规则链唯一标识 | 必填 |
| name | 规则链名称 | 必填 |
| version | 版本号 | 1.0.0 |
| description | 描述 | 可选 |

### 全局配置 (Config Block)

```dsl
config {
    maxDepth: 100           // 最大执行深度，防止无限循环
    executionTimeout: 60000 // 执行超时时间(毫秒)
    enableLogging: true     // 是否启用日志
}
```

### 节点类型 (Node Types)

#### 1. 规则节点 (Rule Node)

执行表达式计算的节点。

```dsl
node calculatePrice {
    type: rule
    expression: `price * quantity * (1 - discount / 100)`
    output: "finalPrice"
    next: nextNode
}
```

#### 2. 条件节点 (Condition Node)

根据条件判断执行不同分支。

```dsl
condition checkStock {
    expression: `stock >= requiredQuantity`
    then: processOrder
    else: outOfStock
}
```

#### 3. 分支节点 (Fork Node)

并行执行多个分支。

```dsl
fork parallelProcess {
    branches: [branch1, branch2, branch3]
    next: joinNode
}
```

#### 4. 合并节点 (Join Node)

等待多个分支完成后继续执行。

```dsl
join mergeResults {
    waitFor: [branch1, branch2, branch3]
    next: finalStep
}
```

#### 5. 开始/结束节点 (Start/End Node)

```dsl
start -> firstNode

// 或使用块语法
start {
    next: firstNode
}

end
```

### 节点属性 (Node Properties)

| 属性 | 说明 | 适用节点 |
|------|------|----------|
| type | 节点类型(rule/condition/fork/join) | 所有节点 |
| expression | 执行表达式 | rule, condition |
| condition | 条件表达式 | condition |
| output | 输出变量名 | rule |
| next | 下一个节点 | rule, fork, join |
| then | 条件为真时的下一个节点 | condition |
| else | 条件为假时的下一个节点 | condition |
| branches | 分支节点列表 | fork |
| waitFor | 等待的分支节点列表 | join |
| params | 节点参数 | 所有节点 |
| timeout | 超时时间(毫秒) | 所有节点 |
| retry | 重试次数 | 所有节点 |
| onError | 错误处理(continue/abort) | 所有节点 |

### 表达式语法 (Expression Syntax)

表达式使用JEXL语法，支持：

```dsl
// 算术运算
expression: `a + b`
expression: `price * quantity`
expression: `total / count`

// 比较运算
expression: `stock > minStock`
expression: `price >= 100 && price <= 500`

// 逻辑运算
expression: `isVip && hasDiscount`
expression: `!isEmpty`

// 三元运算
expression: `score >= 60 ? "PASS" : "FAIL"`

// 字符串
expression: `"Hello, " + name`

// 引用前一步结果
expression: `previousStep_result * 2`
```

### 注释 (Comments)

```dsl
// 单行注释

# 井号注释

/* 
 * 块注释
 * 可以跨越多行
 */
```

## 快速开始 (Quick Start)

### 1. 解析DSL

```java
import com.buyi.ruleengine.dsl.parser.DslParser;
import com.buyi.ruleengine.dsl.model.DslRuleChain;

DslParser parser = new DslParser();

// 从字符串解析
String dsl = "chain { ... }";
DslRuleChain chain = parser.parse(dsl);

// 从文件解析
DslRuleChain chain = parser.parseFile("path/to/chain.dsl");
```

### 2. 执行规则链

```java
import com.buyi.ruleengine.dsl.engine.DslRuleChainEngine;
import com.buyi.ruleengine.dsl.model.DslExecutionContext;

DslRuleChainEngine engine = new DslRuleChainEngine();

// 准备输入参数
Map<String, Object> params = new HashMap<>();
params.put("price", 100.0);
params.put("quantity", 5);
params.put("discount", 20.0);

// 执行规则链
DslExecutionContext context = engine.execute(chain, params);

// 获取结果
if (context.isSuccess()) {
    Object result = context.getVariable("finalPrice");
    System.out.println("Final Price: " + result);
} else {
    System.out.println("Error: " + context.getErrorMessage());
}
```

## 完整示例 (Complete Examples)

### 示例1: 订单价格计算

```dsl
chain {
    id: "order_price"
    name: "订单价格计算"
    
    start -> calcBase
    
    node calcBase {
        type: rule
        expression: `unitPrice * quantity`
        output: "basePrice"
        next: applyDiscount
    }
    
    node applyDiscount {
        type: rule
        expression: `basePrice * (1 - discount / 100)`
        output: "discountedPrice"
        next: addTax
    }
    
    node addTax {
        type: rule
        expression: `discountedPrice * 1.13`
        output: "finalPrice"
    }
}
```

### 示例2: 会员折扣判断

```dsl
chain {
    id: "member_discount"
    name: "会员折扣"
    
    start -> checkMember
    
    condition checkMember {
        expression: `memberLevel == "VIP"`
        then: vipDiscount
        else: checkGold
    }
    
    node vipDiscount {
        type: rule
        expression: `price * 0.7`
        output: "finalPrice"
    }
    
    condition checkGold {
        expression: `memberLevel == "GOLD"`
        then: goldDiscount
        else: normalPrice
    }
    
    node goldDiscount {
        type: rule
        expression: `price * 0.85`
        output: "finalPrice"
    }
    
    node normalPrice {
        type: rule
        expression: `price * 0.95`
        output: "finalPrice"
    }
}
```

### 示例3: 库存检查流程

```dsl
chain {
    id: "stock_check"
    name: "库存检查流程"
    
    config {
        maxDepth: 50
        executionTimeout: 30000
    }
    
    start -> checkStock
    
    node checkStock {
        type: rule
        expression: `availableStock >= requiredQuantity`
        output: "hasStock"
        next: stockDecision
    }
    
    condition stockDecision {
        expression: `hasStock == true`
        then: reserveStock
        else: notifyOutOfStock
    }
    
    node reserveStock {
        type: rule
        expression: `"RESERVED"`
        output: "status"
    }
    
    node notifyOutOfStock {
        type: rule
        expression: `"OUT_OF_STOCK"`
        output: "status"
    }
}
```

## 执行上下文 (Execution Context)

执行上下文包含以下信息：

```java
DslExecutionContext context = engine.execute(chain, params);

// 检查执行状态
context.isSuccess();           // 是否成功
context.getErrorMessage();     // 错误信息

// 获取变量
context.getVariable("key");    // 获取单个变量
context.getVariables();        // 获取所有变量

// 获取执行信息
context.getResult();           // 最终结果
context.getTotalExecutionTime(); // 总执行时间(毫秒)
context.getExecutionDepth();   // 执行深度
context.getExecutionTraces();  // 执行追踪列表
```

## 错误处理 (Error Handling)

### 节点级别错误处理

```dsl
node riskyOperation {
    type: rule
    expression: `dangerousCalculation()`
    output: "result"
    onError: continue    // 出错时继续执行下一个节点
    next: nextNode
}
```

### 解析错误

```java
try {
    DslRuleChain chain = parser.parse(dsl);
} catch (DslParseException e) {
    System.out.println("Parse error at line " + e.getLineNumber());
    System.out.println("Error: " + e.getMessage());
}
```

## 最佳实践 (Best Practices)

1. **命名规范** - 使用清晰的节点ID和变量名
2. **合理分层** - 将复杂逻辑拆分为多个节点
3. **添加注释** - 为关键节点添加描述
4. **设置超时** - 为耗时操作设置合理的超时时间
5. **错误处理** - 使用onError处理可能失败的节点
6. **测试验证** - 编写测试用例验证规则链逻辑

## 运行示例 (Run Example)

```bash
# 编译项目
mvn clean compile

# 运行示例
mvn exec:java -Dexec.mainClass="com.buyi.ruleengine.dsl.DslEngineDemo"

# 运行测试
mvn test -Dtest=DslEngineTest
```

## 依赖项 (Dependencies)

- Apache Commons JEXL 3.3 - 表达式引擎
- SLF4J + Logback - 日志框架

## 许可证 (License)

本项目为Buyi Cloud项目的一部分，遵循项目统一许可证。
