package com.buyi.ruleengine;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.executor.JavaExpressionExecutor;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import com.buyi.ruleengine.model.RuleFlow;
import com.buyi.ruleengine.service.FlowEngine;
import com.buyi.ruleengine.service.JsonConfigLoader;
import com.buyi.ruleengine.service.RuleEngine;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * JSON配置和优先级功能演示
 * JSON Configuration and Priority Features Demonstration
 */
public class JsonPriorityDemo {
    
    public static void main(String[] args) {
        System.out.println("=== JSON Configuration and Priority Features Demo ===\n");
        
        // 演示1：从JSON加载规则配置
        demonstrateJsonLoading();
        
        // 演示2：优先级排序
        demonstratePrioritySorting();
        
        // 演示3：规则间结果传递
        demonstrateResultPassing();
        
        System.out.println("\n=== All demonstrations completed successfully ===");
    }
    
    /**
     * 演示1：从JSON字符串加载规则配置
     */
    private static void demonstrateJsonLoading() {
        System.out.println("--- Demo 1: Loading Rules from JSON ---");
        
        JsonConfigLoader loader = new JsonConfigLoader();
        
        // 从JSON字符串加载规则
        String ruleJson = "{\n" +
                "  \"ruleCode\": \"CALC_DISCOUNT\",\n" +
                "  \"ruleName\": \"计算折扣\",\n" +
                "  \"ruleType\": \"JAVA_EXPR\",\n" +
                "  \"ruleContent\": \"price * (1 - discount / 100)\",\n" +
                "  \"priority\": 100,\n" +
                "  \"status\": 1\n" +
                "}";
        
        RuleConfig rule = loader.loadRuleConfigFromString(ruleJson);
        System.out.println("Loaded rule: " + rule.getRuleCode());
        System.out.println("Priority: " + rule.getPriority());
        System.out.println("Type: " + rule.getRuleType());
        
        // 执行规则
        RuleEngine ruleEngine = new RuleEngine();
        ruleEngine.registerExecutor(new JavaExpressionExecutor());
        
        Map<String, Object> params = new HashMap<>();
        params.put("price", 100.0);
        params.put("discount", 20.0);
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        System.out.println("Calculation result: " + context.getResult());
        System.out.println("Status: " + (context.isSuccess() ? "SUCCESS" : "FAILURE"));
        System.out.println();
    }
    
    /**
     * 演示2：优先级排序功能
     */
    private static void demonstratePrioritySorting() {
        System.out.println("--- Demo 2: Priority-based Sorting ---");
        
        RuleEngine ruleEngine = new RuleEngine();
        ruleEngine.registerExecutor(new JavaExpressionExecutor());
        
        FlowEngine flowEngine = new FlowEngine(ruleEngine);
        flowEngine.setEnablePrioritySorting(true);
        
        // 创建三个规则，优先级不同
        RuleConfig lowPriorityRule = new RuleConfig();
        lowPriorityRule.setRuleCode("LOW_PRIORITY");
        lowPriorityRule.setRuleName("低优先级规则");
        lowPriorityRule.setRuleType(RuleType.JAVA_EXPR);
        lowPriorityRule.setRuleContent("value * 2");
        lowPriorityRule.setPriority(10);
        flowEngine.registerRule(lowPriorityRule);
        
        RuleConfig highPriorityRule = new RuleConfig();
        highPriorityRule.setRuleCode("HIGH_PRIORITY");
        highPriorityRule.setRuleName("高优先级规则");
        highPriorityRule.setRuleType(RuleType.JAVA_EXPR);
        highPriorityRule.setRuleContent("value + 100");
        highPriorityRule.setPriority(100);
        flowEngine.registerRule(highPriorityRule);
        
        RuleConfig mediumPriorityRule = new RuleConfig();
        mediumPriorityRule.setRuleCode("MEDIUM_PRIORITY");
        mediumPriorityRule.setRuleName("中优先级规则");
        mediumPriorityRule.setRuleType(RuleType.JAVA_EXPR);
        mediumPriorityRule.setRuleContent("HIGH_PRIORITY_result + 50");
        mediumPriorityRule.setPriority(50);
        flowEngine.registerRule(mediumPriorityRule);
        
        // 创建流程 - 注意步骤顺序与优先级不同
        RuleFlow flow = new RuleFlow();
        flow.setFlowCode("PRIORITY_DEMO_FLOW");
        flow.setFlowName("优先级演示流程");
        
        List<RuleFlow.FlowStep> steps = new ArrayList<>();
        
        RuleFlow.FlowStep step1 = new RuleFlow.FlowStep();
        step1.setStep(1);
        step1.setRuleCode("LOW_PRIORITY");
        step1.setOnSuccess("next");
        steps.add(step1);
        
        RuleFlow.FlowStep step2 = new RuleFlow.FlowStep();
        step2.setStep(2);
        step2.setRuleCode("MEDIUM_PRIORITY");
        step2.setOnSuccess("next");
        steps.add(step2);
        
        RuleFlow.FlowStep step3 = new RuleFlow.FlowStep();
        step3.setStep(3);
        step3.setRuleCode("HIGH_PRIORITY");
        step3.setOnSuccess("complete");
        steps.add(step3);
        
        flow.setSteps(steps);
        
        // 执行流程
        Map<String, Object> params = new HashMap<>();
        params.put("value", 10);
        
        RuleContext context = new RuleContext(params);
        
        System.out.println("Original step order: LOW -> MEDIUM -> HIGH");
        System.out.println("Execution order (by priority): HIGH (100) -> MEDIUM (50) -> LOW (10)");
        
        context = flowEngine.executeFlow(flow, context);
        
        System.out.println("Final result: " + context.getResult());
        System.out.println("Execution trace:");
        System.out.println("  HIGH_PRIORITY: 10 + 100 = 110");
        System.out.println("  MEDIUM_PRIORITY: 110 + 50 = 160");
        System.out.println("  LOW_PRIORITY: ignored (HIGH_PRIORITY completed the flow)");
        System.out.println();
    }
    
    /**
     * 演示3：规则间结果传递
     */
    private static void demonstrateResultPassing() {
        System.out.println("--- Demo 3: Inter-rule Result Passing ---");
        
        RuleEngine ruleEngine = new RuleEngine();
        ruleEngine.registerExecutor(new JavaExpressionExecutor());
        
        FlowEngine flowEngine = new FlowEngine(ruleEngine);
        
        // 创建规则链：验证 -> 计算基础价格 -> 应用折扣
        RuleConfig validateRule = new RuleConfig();
        validateRule.setRuleCode("VALIDATE");
        validateRule.setRuleName("验证输入");
        validateRule.setRuleType(RuleType.JAVA_EXPR);
        validateRule.setRuleContent("quantity > 0 && quantity <= 100");
        flowEngine.registerRule(validateRule);
        
        RuleConfig calcBaseRule = new RuleConfig();
        calcBaseRule.setRuleCode("CALC_BASE");
        calcBaseRule.setRuleName("计算基础价格");
        calcBaseRule.setRuleType(RuleType.JAVA_EXPR);
        calcBaseRule.setRuleContent("quantity * unitPrice");
        flowEngine.registerRule(calcBaseRule);
        
        RuleConfig applyDiscountRule = new RuleConfig();
        applyDiscountRule.setRuleCode("APPLY_DISCOUNT");
        applyDiscountRule.setRuleName("应用折扣");
        applyDiscountRule.setRuleType(RuleType.JAVA_EXPR);
        applyDiscountRule.setRuleContent("CALC_BASE_result * (1 - discount / 100)");
        //                                ^^^^^^^^^^^^^^^^^
        //                                使用上一步的结果
        flowEngine.registerRule(applyDiscountRule);
        
        // 创建流程
        RuleFlow flow = new RuleFlow();
        flow.setFlowCode("RESULT_PASSING_DEMO");
        flow.setFlowName("结果传递演示");
        
        List<RuleFlow.FlowStep> steps = new ArrayList<>();
        
        RuleFlow.FlowStep step1 = new RuleFlow.FlowStep();
        step1.setStep(1);
        step1.setRuleCode("VALIDATE");
        step1.setOnSuccess("next");
        step1.setOnFailure("abort");
        steps.add(step1);
        
        RuleFlow.FlowStep step2 = new RuleFlow.FlowStep();
        step2.setStep(2);
        step2.setRuleCode("CALC_BASE");
        step2.setCondition("VALIDATE_result == true");
        step2.setOnSuccess("next");
        steps.add(step2);
        
        RuleFlow.FlowStep step3 = new RuleFlow.FlowStep();
        step3.setStep(3);
        step3.setRuleCode("APPLY_DISCOUNT");
        step3.setCondition("discount != null && discount > 0");
        step3.setOnSuccess("complete");
        steps.add(step3);
        
        flow.setSteps(steps);
        
        // 执行流程
        Map<String, Object> params = new HashMap<>();
        params.put("quantity", 5);
        params.put("unitPrice", 100.0);
        params.put("discount", 10.0);
        
        RuleContext context = new RuleContext(params);
        
        System.out.println("Input: quantity=5, unitPrice=100, discount=10%");
        
        context = flowEngine.executeFlow(flow, context);
        
        System.out.println("\nExecution chain:");
        System.out.println("  Step 1 - VALIDATE: " + context.getInput("VALIDATE_result"));
        System.out.println("  Step 2 - CALC_BASE: " + context.getInput("CALC_BASE_result") + " (5 * 100)");
        System.out.println("  Step 3 - APPLY_DISCOUNT: " + context.getResult() + " (500 * 0.9)");
        System.out.println("\nFinal result: " + context.getResult());
        System.out.println();
    }
}
