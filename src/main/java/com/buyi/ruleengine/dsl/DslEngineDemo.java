package com.buyi.ruleengine.dsl;

import com.buyi.ruleengine.dsl.engine.DslRuleChainEngine;
import com.buyi.ruleengine.dsl.model.DslExecutionContext;
import com.buyi.ruleengine.dsl.model.DslNode;
import com.buyi.ruleengine.dsl.model.DslRuleChain;
import com.buyi.ruleengine.dsl.parser.DslParser;

import java.util.HashMap;
import java.util.Map;

/**
 * DSL规则链引擎示例
 * DSL Rule Chain Engine Demo
 * 
 * 演示如何使用DSL解析器和执行引擎来定义和执行规则链
 */
public class DslEngineDemo {
    
    public static void main(String[] args) {
        System.out.println("=".repeat(60));
        System.out.println("Buyi DSL Rule Chain Engine Demo");
        System.out.println("=".repeat(60));
        
        // 示例1: 简单计算
        demoSimpleCalculation();
        
        // 示例2: 条件分支
        demoConditionalBranching();
        
        // 示例3: 多步骤流程
        demoMultiStepProcess();
        
        // 示例4: 订单处理流程
        demoOrderProcessing();
    }
    
    /**
     * 示例1: 简单计算
     */
    private static void demoSimpleCalculation() {
        System.out.println("\n" + "-".repeat(60));
        System.out.println("Demo 1: Simple Calculation");
        System.out.println("-".repeat(60));
        
        String dsl = 
            "chain {\n" +
            "    id: \"simple_calc\"\n" +
            "    name: \"简单计算\"\n" +
            "    \n" +
            "    start -> multiply\n" +
            "    \n" +
            "    node multiply {\n" +
            "        type: rule\n" +
            "        expression: `a * b + c`\n" +
            "        output: \"result\"\n" +
            "    }\n" +
            "}";
        
        DslParser parser = new DslParser();
        DslRuleChainEngine engine = new DslRuleChainEngine();
        
        DslRuleChain chain = parser.parse(dsl);
        
        Map<String, Object> params = new HashMap<>();
        params.put("a", 10);
        params.put("b", 5);
        params.put("c", 8);
        
        DslExecutionContext context = engine.execute(chain, params);
        
        System.out.println("Input: a=10, b=5, c=8");
        System.out.println("Expression: a * b + c");
        System.out.println("Result: " + context.getVariable("result"));
        System.out.println("Success: " + context.isSuccess());
        System.out.println("Execution Time: " + context.getTotalExecutionTime() + "ms");
    }
    
    /**
     * 示例2: 条件分支
     */
    private static void demoConditionalBranching() {
        System.out.println("\n" + "-".repeat(60));
        System.out.println("Demo 2: Conditional Branching");
        System.out.println("-".repeat(60));
        
        String dsl = 
            "chain {\n" +
            "    id: \"grade_check\"\n" +
            "    name: \"成绩等级判断\"\n" +
            "    \n" +
            "    start -> checkGrade\n" +
            "    \n" +
            "    condition checkGrade {\n" +
            "        expression: `score >= 90`\n" +
            "        then: gradeA\n" +
            "        else: checkGradeB\n" +
            "    }\n" +
            "    \n" +
            "    node gradeA {\n" +
            "        type: rule\n" +
            "        expression: `\"A\"`\n" +
            "        output: \"grade\"\n" +
            "    }\n" +
            "    \n" +
            "    condition checkGradeB {\n" +
            "        expression: `score >= 80`\n" +
            "        then: gradeB\n" +
            "        else: checkGradeC\n" +
            "    }\n" +
            "    \n" +
            "    node gradeB {\n" +
            "        type: rule\n" +
            "        expression: `\"B\"`\n" +
            "        output: \"grade\"\n" +
            "    }\n" +
            "    \n" +
            "    condition checkGradeC {\n" +
            "        expression: `score >= 60`\n" +
            "        then: gradeC\n" +
            "        else: gradeF\n" +
            "    }\n" +
            "    \n" +
            "    node gradeC {\n" +
            "        type: rule\n" +
            "        expression: `\"C\"`\n" +
            "        output: \"grade\"\n" +
            "    }\n" +
            "    \n" +
            "    node gradeF {\n" +
            "        type: rule\n" +
            "        expression: `\"F\"`\n" +
            "        output: \"grade\"\n" +
            "    }\n" +
            "}";
        
        DslParser parser = new DslParser();
        DslRuleChainEngine engine = new DslRuleChainEngine();
        
        DslRuleChain chain = parser.parse(dsl);
        
        int[] scores = {95, 85, 70, 50};
        
        for (int score : scores) {
            Map<String, Object> params = new HashMap<>();
            params.put("score", score);
            
            DslExecutionContext context = engine.execute(chain, params);
            
            System.out.println("Score: " + score + " -> Grade: " + context.getVariable("grade"));
        }
    }
    
    /**
     * 示例3: 多步骤流程
     */
    private static void demoMultiStepProcess() {
        System.out.println("\n" + "-".repeat(60));
        System.out.println("Demo 3: Multi-Step Process");
        System.out.println("-".repeat(60));
        
        String dsl = 
            "chain {\n" +
            "    id: \"price_calculation\"\n" +
            "    name: \"价格计算流程\"\n" +
            "    \n" +
            "    start -> step1\n" +
            "    \n" +
            "    // 步骤1: 计算基础价格\n" +
            "    node step1 {\n" +
            "        type: rule\n" +
            "        expression: `unitPrice * quantity`\n" +
            "        output: \"basePrice\"\n" +
            "        next: step2\n" +
            "    }\n" +
            "    \n" +
            "    // 步骤2: 应用折扣\n" +
            "    node step2 {\n" +
            "        type: rule\n" +
            "        expression: `basePrice * (1 - discount / 100)`\n" +
            "        output: \"discountedPrice\"\n" +
            "        next: step3\n" +
            "    }\n" +
            "    \n" +
            "    // 步骤3: 添加税费\n" +
            "    node step3 {\n" +
            "        type: rule\n" +
            "        expression: `discountedPrice * (1 + tax / 100)`\n" +
            "        output: \"finalPrice\"\n" +
            "    }\n" +
            "}";
        
        DslParser parser = new DslParser();
        DslRuleChainEngine engine = new DslRuleChainEngine();
        
        DslRuleChain chain = parser.parse(dsl);
        
        Map<String, Object> params = new HashMap<>();
        params.put("unitPrice", 100.0);
        params.put("quantity", 5);
        params.put("discount", 20.0);
        params.put("tax", 13.0);
        
        DslExecutionContext context = engine.execute(chain, params);
        
        System.out.println("Input:");
        System.out.println("  Unit Price: $100");
        System.out.println("  Quantity: 5");
        System.out.println("  Discount: 20%");
        System.out.println("  Tax: 13%");
        System.out.println("\nCalculation Steps:");
        System.out.println("  Step 1 - Base Price: $" + context.getVariable("basePrice"));
        System.out.println("  Step 2 - After Discount: $" + context.getVariable("discountedPrice"));
        System.out.println("  Step 3 - Final Price (with tax): $" + context.getVariable("finalPrice"));
    }
    
    /**
     * 示例4: 订单处理流程
     */
    private static void demoOrderProcessing() {
        System.out.println("\n" + "-".repeat(60));
        System.out.println("Demo 4: Order Processing");
        System.out.println("-".repeat(60));
        
        String dsl = 
            "chain {\n" +
            "    id: \"order_process\"\n" +
            "    name: \"订单处理\"\n" +
            "    \n" +
            "    start -> checkStock\n" +
            "    \n" +
            "    node checkStock {\n" +
            "        type: rule\n" +
            "        expression: `stock >= quantity`\n" +
            "        output: \"hasStock\"\n" +
            "        next: stockDecision\n" +
            "    }\n" +
            "    \n" +
            "    condition stockDecision {\n" +
            "        expression: `hasStock == true`\n" +
            "        then: calcPrice\n" +
            "        else: outOfStock\n" +
            "    }\n" +
            "    \n" +
            "    node outOfStock {\n" +
            "        type: rule\n" +
            "        expression: `\"OUT_OF_STOCK\"`\n" +
            "        output: \"status\"\n" +
            "    }\n" +
            "    \n" +
            "    node calcPrice {\n" +
            "        type: rule\n" +
            "        expression: `price * quantity`\n" +
            "        output: \"totalPrice\"\n" +
            "        next: vipCheck\n" +
            "    }\n" +
            "    \n" +
            "    condition vipCheck {\n" +
            "        expression: `isVip == true`\n" +
            "        then: vipDiscount\n" +
            "        else: normalPrice\n" +
            "    }\n" +
            "    \n" +
            "    node vipDiscount {\n" +
            "        type: rule\n" +
            "        expression: `totalPrice * 0.8`\n" +
            "        output: \"finalPrice\"\n" +
            "        next: success\n" +
            "    }\n" +
            "    \n" +
            "    node normalPrice {\n" +
            "        type: rule\n" +
            "        expression: `totalPrice`\n" +
            "        output: \"finalPrice\"\n" +
            "        next: success\n" +
            "    }\n" +
            "    \n" +
            "    node success {\n" +
            "        type: rule\n" +
            "        expression: `\"SUCCESS\"`\n" +
            "        output: \"status\"\n" +
            "    }\n" +
            "}";
        
        DslParser parser = new DslParser();
        DslRuleChainEngine engine = new DslRuleChainEngine();
        
        DslRuleChain chain = parser.parse(dsl);
        
        // 场景1: VIP用户，库存充足
        System.out.println("\nScenario 1: VIP customer with sufficient stock");
        Map<String, Object> scenario1 = new HashMap<>();
        scenario1.put("stock", 100);
        scenario1.put("quantity", 5);
        scenario1.put("price", 100.0);
        scenario1.put("isVip", true);
        
        DslExecutionContext ctx1 = engine.execute(chain, scenario1);
        System.out.println("  Status: " + ctx1.getVariable("status"));
        System.out.println("  Final Price: $" + ctx1.getVariable("finalPrice") + " (20% VIP discount applied)");
        
        // 场景2: 普通用户，库存充足
        System.out.println("\nScenario 2: Regular customer with sufficient stock");
        Map<String, Object> scenario2 = new HashMap<>();
        scenario2.put("stock", 100);
        scenario2.put("quantity", 5);
        scenario2.put("price", 100.0);
        scenario2.put("isVip", false);
        
        DslExecutionContext ctx2 = engine.execute(chain, scenario2);
        System.out.println("  Status: " + ctx2.getVariable("status"));
        System.out.println("  Final Price: $" + ctx2.getVariable("finalPrice") + " (no discount)");
        
        // 场景3: 库存不足
        System.out.println("\nScenario 3: Insufficient stock");
        Map<String, Object> scenario3 = new HashMap<>();
        scenario3.put("stock", 2);
        scenario3.put("quantity", 5);
        scenario3.put("price", 100.0);
        scenario3.put("isVip", true);
        
        DslExecutionContext ctx3 = engine.execute(chain, scenario3);
        System.out.println("  Status: " + ctx3.getVariable("status"));
        System.out.println("  Final Price: " + ctx3.getVariable("finalPrice"));
        
        System.out.println("\n" + "=".repeat(60));
        System.out.println("Demo completed successfully!");
        System.out.println("=".repeat(60));
    }
}
