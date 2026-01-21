package com.buyi.ruleengine;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.executor.JavaExpressionExecutor;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import com.buyi.ruleengine.model.RuleFlow;
import com.buyi.ruleengine.service.FlowEngine;
import com.buyi.ruleengine.service.RuleEngine;
import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * 优先级排序功能单元测试
 * Priority-based Sorting Unit Tests
 */
public class PrioritySortingTest {
    
    private RuleEngine ruleEngine;
    private FlowEngine flowEngine;
    
    @Before
    public void setUp() {
        ruleEngine = new RuleEngine();
        ruleEngine.registerExecutor(new JavaExpressionExecutor());
        flowEngine = new FlowEngine(ruleEngine);
    }
    
    @Test
    public void testPrioritySortingEnabled() {
        // 测试启用优先级排序
        assertTrue(flowEngine.isEnablePrioritySorting()); // 默认启用
        
        flowEngine.setEnablePrioritySorting(false);
        assertFalse(flowEngine.isEnablePrioritySorting());
        
        flowEngine.setEnablePrioritySorting(true);
        assertTrue(flowEngine.isEnablePrioritySorting());
    }
    
    @Test
    public void testFlowExecutionWithPriority() {
        // 创建规则配置，使用不同的优先级
        RuleConfig rule1 = new RuleConfig();
        rule1.setRuleCode("RULE1");
        rule1.setRuleName("规则1");
        rule1.setRuleType(RuleType.JAVA_EXPR);
        rule1.setRuleContent("a * 2"); // a = 10 -> 20
        rule1.setPriority(10); // 低优先级
        flowEngine.registerRule(rule1);
        
        RuleConfig rule2 = new RuleConfig();
        rule2.setRuleCode("RULE2");
        rule2.setRuleName("规则2");
        rule2.setRuleType(RuleType.JAVA_EXPR);
        rule2.setRuleContent("RULE1_result + 5"); // 20 + 5 = 25
        rule2.setPriority(5); // 更低优先级
        flowEngine.registerRule(rule2);
        
        RuleConfig rule3 = new RuleConfig();
        rule3.setRuleCode("RULE3");
        rule3.setRuleName("规则3");
        rule3.setRuleType(RuleType.JAVA_EXPR);
        rule3.setRuleContent("a + 100"); // a = 10 -> 110
        rule3.setPriority(100); // 高优先级
        flowEngine.registerRule(rule3);
        
        // 创建流程，步骤顺序与优先级相反
        RuleFlow flow = new RuleFlow();
        flow.setFlowCode("PRIORITY_TEST_FLOW");
        flow.setFlowName("优先级测试流程");
        
        List<RuleFlow.FlowStep> steps = new ArrayList<>();
        
        RuleFlow.FlowStep step1 = new RuleFlow.FlowStep();
        step1.setStep(1);
        step1.setRuleCode("RULE1");
        step1.setOnSuccess("next");
        steps.add(step1);
        
        RuleFlow.FlowStep step2 = new RuleFlow.FlowStep();
        step2.setStep(2);
        step2.setRuleCode("RULE2");
        step2.setOnSuccess("next");
        steps.add(step2);
        
        RuleFlow.FlowStep step3 = new RuleFlow.FlowStep();
        step3.setStep(3);
        step3.setRuleCode("RULE3");
        step3.setOnSuccess("complete");
        steps.add(step3);
        
        flow.setSteps(steps);
        
        // 准备输入参数
        Map<String, Object> params = new HashMap<>();
        params.put("a", 10);
        
        RuleContext context = new RuleContext(params);
        
        // 执行流程（启用优先级排序）
        flowEngine.setEnablePrioritySorting(true);
        context = flowEngine.executeFlow(flow, context);
        
        // 验证执行结果
        assertTrue(context.isSuccess());
        // 由于优先级排序，实际执行顺序应该是: RULE3 (100) -> RULE1 (10) -> RULE2 (5)
        // RULE3 先执行: 10 + 100 = 110
        assertEquals(110, context.getResult());
    }
    
    @Test
    public void testFlowExecutionWithoutPriority() {
        // 创建规则配置
        RuleConfig rule1 = new RuleConfig();
        rule1.setRuleCode("RULE_A");
        rule1.setRuleName("规则A");
        rule1.setRuleType(RuleType.JAVA_EXPR);
        rule1.setRuleContent("x * 2"); // x = 5 -> 10
        rule1.setPriority(50);
        flowEngine.registerRule(rule1);
        
        RuleConfig rule2 = new RuleConfig();
        rule2.setRuleCode("RULE_B");
        rule2.setRuleName("规则B");
        rule2.setRuleType(RuleType.JAVA_EXPR);
        rule2.setRuleContent("RULE_A_result + 10"); // 10 + 10 = 20
        rule2.setPriority(100); // 更高优先级
        flowEngine.registerRule(rule2);
        
        // 创建流程
        RuleFlow flow = new RuleFlow();
        flow.setFlowCode("NO_PRIORITY_FLOW");
        flow.setFlowName("无优先级流程");
        
        List<RuleFlow.FlowStep> steps = new ArrayList<>();
        
        RuleFlow.FlowStep step1 = new RuleFlow.FlowStep();
        step1.setStep(1);
        step1.setRuleCode("RULE_A");
        step1.setOnSuccess("next");
        steps.add(step1);
        
        RuleFlow.FlowStep step2 = new RuleFlow.FlowStep();
        step2.setStep(2);
        step2.setRuleCode("RULE_B");
        step2.setOnSuccess("complete");
        steps.add(step2);
        
        flow.setSteps(steps);
        
        // 准备输入参数
        Map<String, Object> params = new HashMap<>();
        params.put("x", 5);
        
        RuleContext context = new RuleContext(params);
        
        // 禁用优先级排序
        flowEngine.setEnablePrioritySorting(false);
        context = flowEngine.executeFlow(flow, context);
        
        // 验证执行结果
        assertTrue(context.isSuccess());
        // 按原始顺序执行: RULE_A -> RULE_B
        // RULE_A: 5 * 2 = 10
        // RULE_B: 10 + 10 = 20
        assertEquals(20, context.getResult());
    }
    
    @Test
    public void testPriorityWithSameValue() {
        // 测试相同优先级的规则按步骤顺序执行
        RuleConfig rule1 = new RuleConfig();
        rule1.setRuleCode("SAME_PRIORITY_1");
        rule1.setRuleName("相同优先级1");
        rule1.setRuleType(RuleType.JAVA_EXPR);
        rule1.setRuleContent("n + 1"); // n = 1 -> 2
        rule1.setPriority(50);
        flowEngine.registerRule(rule1);
        
        RuleConfig rule2 = new RuleConfig();
        rule2.setRuleCode("SAME_PRIORITY_2");
        rule2.setRuleName("相同优先级2");
        rule2.setRuleType(RuleType.JAVA_EXPR);
        rule2.setRuleContent("SAME_PRIORITY_1_result * 3"); // 2 * 3 = 6
        rule2.setPriority(50); // 相同优先级
        flowEngine.registerRule(rule2);
        
        // 创建流程
        RuleFlow flow = new RuleFlow();
        flow.setFlowCode("SAME_PRIORITY_FLOW");
        flow.setFlowName("相同优先级流程");
        
        List<RuleFlow.FlowStep> steps = new ArrayList<>();
        
        RuleFlow.FlowStep step1 = new RuleFlow.FlowStep();
        step1.setStep(1);
        step1.setRuleCode("SAME_PRIORITY_1");
        step1.setOnSuccess("next");
        steps.add(step1);
        
        RuleFlow.FlowStep step2 = new RuleFlow.FlowStep();
        step2.setStep(2);
        step2.setRuleCode("SAME_PRIORITY_2");
        step2.setOnSuccess("complete");
        steps.add(step2);
        
        flow.setSteps(steps);
        
        // 准备输入参数
        Map<String, Object> params = new HashMap<>();
        params.put("n", 1);
        
        RuleContext context = new RuleContext(params);
        
        // 启用优先级排序
        flowEngine.setEnablePrioritySorting(true);
        context = flowEngine.executeFlow(flow, context);
        
        // 验证执行结果 - 相同优先级应保持原始步骤顺序
        assertTrue(context.isSuccess());
        assertEquals(6, context.getResult());
    }
    
    @Test
    public void testResultPassingBetweenRules() {
        // 测试规则间结果传递（这个功能已经存在，这里验证它仍然工作）
        RuleConfig rule1 = new RuleConfig();
        rule1.setRuleCode("CALC_BASE");
        rule1.setRuleName("计算基数");
        rule1.setRuleType(RuleType.JAVA_EXPR);
        rule1.setRuleContent("price * quantity");
        rule1.setPriority(100);
        flowEngine.registerRule(rule1);
        
        RuleConfig rule2 = new RuleConfig();
        rule2.setRuleCode("APPLY_DISCOUNT");
        rule2.setRuleName("应用折扣");
        rule2.setRuleType(RuleType.JAVA_EXPR);
        rule2.setRuleContent("CALC_BASE_result * (1 - discount / 100)");
        rule2.setPriority(50);
        flowEngine.registerRule(rule2);
        
        // 创建流程
        RuleFlow flow = new RuleFlow();
        flow.setFlowCode("RESULT_PASSING_FLOW");
        flow.setFlowName("结果传递流程");
        
        List<RuleFlow.FlowStep> steps = new ArrayList<>();
        
        RuleFlow.FlowStep step1 = new RuleFlow.FlowStep();
        step1.setStep(1);
        step1.setRuleCode("CALC_BASE");
        step1.setOnSuccess("next");
        steps.add(step1);
        
        RuleFlow.FlowStep step2 = new RuleFlow.FlowStep();
        step2.setStep(2);
        step2.setRuleCode("APPLY_DISCOUNT");
        step2.setOnSuccess("complete");
        steps.add(step2);
        
        flow.setSteps(steps);
        
        // 准备输入参数
        Map<String, Object> params = new HashMap<>();
        params.put("price", 100.0);
        params.put("quantity", 5);
        params.put("discount", 10.0);
        
        RuleContext context = new RuleContext(params);
        
        // 执行流程
        context = flowEngine.executeFlow(flow, context);
        
        // 验证执行结果
        assertTrue(context.isSuccess());
        // price * quantity = 100 * 5 = 500
        // 500 * (1 - 10/100) = 500 * 0.9 = 450
        assertEquals(450.0, context.getResult());
        
        // 验证中间结果被保存到上下文中
        assertEquals(500.0, context.getInput("CALC_BASE_result"));
    }
}
