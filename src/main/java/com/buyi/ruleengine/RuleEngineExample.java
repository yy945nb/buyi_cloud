package com.buyi.ruleengine;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.executor.ApiCallExecutor;
import com.buyi.ruleengine.executor.JavaExpressionExecutor;
import com.buyi.ruleengine.executor.SqlQueryExecutor;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import com.buyi.ruleengine.model.RuleFlow;
import com.buyi.ruleengine.service.FlowEngine;
import com.buyi.ruleengine.service.RuleEngine;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 规则引擎示例程序
 * Rule Engine Example Application
 */
public class RuleEngineExample {
    
    public static void main(String[] args) {
        System.out.println("=== Buyi Rule Engine Example ===\n");
        
        // 1. 初始化规则引擎
        RuleEngine ruleEngine = new RuleEngine();
        
        // 2. 注册执行器
        ruleEngine.registerExecutor(new JavaExpressionExecutor());
        // 注意：SQL和API执行器需要配置参数，这里仅作为示例
        // ruleEngine.registerExecutor(new SqlQueryExecutor("jdbc:mysql://localhost:3306/buyi_platform_dev", "user", "pass"));
        // ruleEngine.registerExecutor(new ApiCallExecutor());
        
        // 3. 示例1：Java表达式规则
        demonstrateJavaExpression(ruleEngine);
        
        // 4. 示例2：规则流程
        demonstrateRuleFlow(ruleEngine);
        
        System.out.println("\n=== Example completed ===");
    }
    
    /**
     * 示例1：Java表达式规则执行
     */
    private static void demonstrateJavaExpression(RuleEngine ruleEngine) {
        System.out.println("--- Example 1: Java Expression Rule ---");
        
        // 创建规则配置：计算折扣价格
        RuleConfig discountRule = new RuleConfig();
        discountRule.setRuleCode("CALC_DISCOUNT_PRICE");
        discountRule.setRuleName("计算折扣价格");
        discountRule.setRuleType(RuleType.JAVA_EXPR);
        discountRule.setRuleContent("price * (1 - discount / 100)");
        
        // 准备输入参数
        Map<String, Object> params = new HashMap<>();
        params.put("price", 100.0);
        params.put("discount", 20.0);  // 20% discount
        
        // 创建执行上下文
        RuleContext context = new RuleContext(params);
        
        // 执行规则
        context = ruleEngine.executeRule(discountRule, context);
        
        // 输出结果
        System.out.println("Input: price=" + params.get("price") + ", discount=" + params.get("discount") + "%");
        System.out.println("Output: finalPrice=" + context.getResult());
        System.out.println("Status: " + (context.isSuccess() ? "SUCCESS" : "FAILURE"));
        System.out.println("Execution Time: " + context.getExecutionTime() + "ms");
        System.out.println();
    }
    
    /**
     * 示例2：规则流程编排
     */
    private static void demonstrateRuleFlow(RuleEngine ruleEngine) {
        System.out.println("--- Example 2: Rule Flow ---");
        
        // 创建流程引擎
        FlowEngine flowEngine = new FlowEngine(ruleEngine);
        
        // 注册规则
        RuleConfig rule1 = new RuleConfig();
        rule1.setRuleCode("VALIDATE_ORDER");
        rule1.setRuleName("验证订单");
        rule1.setRuleType(RuleType.JAVA_EXPR);
        rule1.setRuleContent("quantity > 0 && quantity <= 100");
        flowEngine.registerRule(rule1);
        
        RuleConfig rule2 = new RuleConfig();
        rule2.setRuleCode("CALC_TOTAL_PRICE");
        rule2.setRuleName("计算总价");
        rule2.setRuleType(RuleType.JAVA_EXPR);
        rule2.setRuleContent("quantity * price");
        flowEngine.registerRule(rule2);
        
        RuleConfig rule3 = new RuleConfig();
        rule3.setRuleCode("APPLY_DISCOUNT");
        rule3.setRuleName("应用折扣");
        rule3.setRuleType(RuleType.JAVA_EXPR);
        rule3.setRuleContent("CALC_TOTAL_PRICE_result * (1 - discount / 100)");
        flowEngine.registerRule(rule3);
        
        // 创建流程配置
        RuleFlow flow = new RuleFlow();
        flow.setFlowCode("ORDER_CALCULATION_FLOW");
        flow.setFlowName("订单计算流程");
        
        List<RuleFlow.FlowStep> steps = new ArrayList<>();
        
        RuleFlow.FlowStep step1 = new RuleFlow.FlowStep();
        step1.setStep(1);
        step1.setRuleCode("VALIDATE_ORDER");
        step1.setOnSuccess("next");
        step1.setOnFailure("abort");
        steps.add(step1);
        
        RuleFlow.FlowStep step2 = new RuleFlow.FlowStep();
        step2.setStep(2);
        step2.setRuleCode("CALC_TOTAL_PRICE");
        step2.setOnSuccess("next");
        step2.setOnFailure("abort");
        steps.add(step2);
        
        RuleFlow.FlowStep step3 = new RuleFlow.FlowStep();
        step3.setStep(3);
        step3.setRuleCode("APPLY_DISCOUNT");
        step3.setCondition("discount != null && discount > 0");
        step3.setOnSuccess("complete");
        step3.setOnFailure("abort");
        steps.add(step3);
        
        flow.setSteps(steps);
        
        // 准备输入参数
        Map<String, Object> params = new HashMap<>();
        params.put("quantity", 5);
        params.put("price", 100.0);
        params.put("discount", 10.0);  // 10% discount
        
        // 创建执行上下文
        RuleContext context = new RuleContext(params);
        
        // 执行流程
        context = flowEngine.executeFlow(flow, context);
        
        // 输出结果
        System.out.println("Input: quantity=" + params.get("quantity") + 
                         ", price=" + params.get("price") + 
                         ", discount=" + params.get("discount") + "%");
        System.out.println("Final Result: " + context.getResult());
        System.out.println("Status: " + (context.isSuccess() ? "SUCCESS" : "FAILURE"));
        System.out.println();
    }
}
