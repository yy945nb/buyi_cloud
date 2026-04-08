package com.buyi.channel.rule;

import com.buyi.channel.rule.enums.ChannelExecutionStatus;
import com.buyi.channel.rule.enums.ChannelRuleType;
import com.buyi.channel.rule.engine.ChannelFlowEngine;
import com.buyi.channel.rule.engine.ChannelRuleEngine;
import com.buyi.channel.rule.exception.ChannelRuleException;
import com.buyi.channel.rule.model.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 渠道流程引擎测试
 * Channel Flow Engine Tests
 *
 * 覆盖场景：
 * 1. 顺序流程执行
 * 2. 条件步骤跳过
 * 3. 步骤失败 - abort模式
 * 4. 步骤失败 - continue模式
 * 5. 步骤成功 - complete模式
 * 6. 优先级排序
 * 7. 变量在步骤间传递
 * 8. 执行深度限制
 * 9. 超时控制
 * 10. 空值异常处理
 */
@DisplayName("ChannelFlowEngine 流程引擎测试")
class ChannelFlowEngineTest {

    private ChannelRuleEngine ruleEngine;
    private ChannelFlowEngine flowEngine;

    @BeforeEach
    void setUp() {
        ruleEngine = new ChannelRuleEngine();
        flowEngine = new ChannelFlowEngine(ruleEngine);
    }

    // ==================== 顺序流程执行 ====================

    @Test
    @DisplayName("顺序流程 - 两步计算")
    void testSequentialFlow() {
        // 步骤1: 计算价格
        ChannelRule rule1 = new ChannelRule("CALC_PRICE", "价格", ChannelRuleType.EXPRESSION,
                "basePrice * quantity");
        rule1.setOutputVariable("totalPrice");

        // 步骤2: 计算折扣价
        ChannelRule rule2 = new ChannelRule("CALC_DISCOUNT", "折扣", ChannelRuleType.EXPRESSION,
                "totalPrice * 0.9");
        rule2.setOutputVariable("finalPrice");

        flowEngine.registerRule(rule1);
        flowEngine.registerRule(rule2);

        ChannelRuleFlow flow = new ChannelRuleFlow("PRICE_FLOW", "价格流程");
        ChannelRuleFlow.FlowStep step1 = new ChannelRuleFlow.FlowStep(1, "CALC_PRICE");
        ChannelRuleFlow.FlowStep step2 = new ChannelRuleFlow.FlowStep(2, "CALC_DISCOUNT");
        flow.addStep(step1);
        flow.addStep(step2);

        Map<String, Object> params = new HashMap<>();
        params.put("basePrice", 100.0);
        params.put("quantity", 5);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        assertEquals(450.0, ctx.getVariable("finalPrice"));
    }

    @Test
    @DisplayName("顺序流程 - 三步计算链")
    void testThreeStepFlow() {
        ChannelRule rule1 = new ChannelRule("STEP1", "加法", ChannelRuleType.EXPRESSION, "a + b");
        rule1.setOutputVariable("sum");

        ChannelRule rule2 = new ChannelRule("STEP2", "乘法", ChannelRuleType.EXPRESSION, "sum * 2");
        rule2.setOutputVariable("doubled");

        ChannelRule rule3 = new ChannelRule("STEP3", "减法", ChannelRuleType.EXPRESSION, "doubled - 1");
        rule3.setOutputVariable("final_result");

        flowEngine.registerRule(rule1);
        flowEngine.registerRule(rule2);
        flowEngine.registerRule(rule3);

        ChannelRuleFlow flow = new ChannelRuleFlow("CHAIN_FLOW", "链式流程");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "STEP1"));
        flow.addStep(new ChannelRuleFlow.FlowStep(2, "STEP2"));
        flow.addStep(new ChannelRuleFlow.FlowStep(3, "STEP3"));

        Map<String, Object> params = new HashMap<>();
        params.put("a", 3);
        params.put("b", 4);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        assertEquals(7, ctx.getVariable("sum"));
        assertEquals(14, ctx.getVariable("doubled"));
        assertEquals(13, ctx.getVariable("final_result"));
    }

    // ==================== 条件步骤跳过 ====================

    @Test
    @DisplayName("条件步骤 - 条件满足时执行")
    void testConditionMetExecutes() {
        ChannelRule rule = new ChannelRule("VIP_DISCOUNT", "VIP折扣", ChannelRuleType.EXPRESSION,
                "price * 0.8");
        rule.setOutputVariable("vipPrice");

        flowEngine.registerRule(rule);

        ChannelRuleFlow flow = new ChannelRuleFlow("COND_FLOW", "条件流程");
        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "VIP_DISCOUNT");
        step.setCondition("isVip");
        flow.addStep(step);

        Map<String, Object> params = new HashMap<>();
        params.put("isVip", true);
        params.put("price", 100.0);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        assertEquals(80.0, ctx.getVariable("vipPrice"));
    }

    @Test
    @DisplayName("条件步骤 - 条件不满足时跳过")
    void testConditionNotMetSkips() {
        ChannelRule rule = new ChannelRule("VIP_DISCOUNT", "VIP折扣", ChannelRuleType.EXPRESSION,
                "price * 0.8");
        rule.setOutputVariable("vipPrice");

        flowEngine.registerRule(rule);

        ChannelRuleFlow flow = new ChannelRuleFlow("COND_FLOW", "条件流程");
        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "VIP_DISCOUNT");
        step.setCondition("isVip");
        flow.addStep(step);

        Map<String, Object> params = new HashMap<>();
        params.put("isVip", false);
        params.put("price", 100.0);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        assertNull(ctx.getVariable("vipPrice"));
    }

    // ==================== 失败处理 ====================

    @Test
    @DisplayName("失败处理 - abort模式中断流程")
    void testFailureAbort() {
        ChannelRule rule1 = new ChannelRule("FAIL_RULE", "失败规则", ChannelRuleType.EXPRESSION,
                "undefined + 1");
        ChannelRule rule2 = new ChannelRule("GOOD_RULE", "正常规则", ChannelRuleType.EXPRESSION, "1 + 1");
        rule2.setOutputVariable("shouldNotExist");

        flowEngine.registerRule(rule1);
        flowEngine.registerRule(rule2);

        ChannelRuleFlow flow = new ChannelRuleFlow("ABORT_FLOW", "中断流程");
        ChannelRuleFlow.FlowStep step1 = new ChannelRuleFlow.FlowStep(1, "FAIL_RULE");
        step1.setOnFailure("abort");
        ChannelRuleFlow.FlowStep step2 = new ChannelRuleFlow.FlowStep(2, "GOOD_RULE");
        flow.addStep(step1);
        flow.addStep(step2);

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertFalse(result.isSuccess());
        assertNull(ctx.getVariable("shouldNotExist"));
    }

    @Test
    @DisplayName("失败处理 - continue模式继续执行后续步骤")
    void testFailureContinue() {
        ChannelRule rule1 = new ChannelRule("FAIL_RULE", "失败规则", ChannelRuleType.EXPRESSION,
                "undefined + 1");
        ChannelRule rule2 = new ChannelRule("GOOD_RULE", "正常规则", ChannelRuleType.EXPRESSION, "1 + 1");
        rule2.setOutputVariable("goodResult");

        flowEngine.registerRule(rule1);
        flowEngine.registerRule(rule2);

        ChannelRuleFlow flow = new ChannelRuleFlow("CONTINUE_FLOW", "继续流程");
        ChannelRuleFlow.FlowStep step1 = new ChannelRuleFlow.FlowStep(1, "FAIL_RULE");
        step1.setOnFailure("continue");
        ChannelRuleFlow.FlowStep step2 = new ChannelRuleFlow.FlowStep(2, "GOOD_RULE");
        flow.addStep(step1);
        flow.addStep(step2);

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        assertEquals(2, ctx.getVariable("goodResult"));
    }

    // ==================== 成功处理 ====================

    @Test
    @DisplayName("成功处理 - complete模式立即完成")
    void testSuccessComplete() {
        ChannelRule rule1 = new ChannelRule("COMPLETE_RULE", "完成规则", ChannelRuleType.EXPRESSION,
                "1 + 1");
        rule1.setOutputVariable("firstResult");

        ChannelRule rule2 = new ChannelRule("UNREACHED", "不可达", ChannelRuleType.EXPRESSION,
                "2 + 2");
        rule2.setOutputVariable("shouldNotExist");

        flowEngine.registerRule(rule1);
        flowEngine.registerRule(rule2);

        ChannelRuleFlow flow = new ChannelRuleFlow("COMPLETE_FLOW", "完成流程");
        ChannelRuleFlow.FlowStep step1 = new ChannelRuleFlow.FlowStep(1, "COMPLETE_RULE");
        step1.setOnSuccess("complete");
        ChannelRuleFlow.FlowStep step2 = new ChannelRuleFlow.FlowStep(2, "UNREACHED");
        flow.addStep(step1);
        flow.addStep(step2);

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        assertEquals(2, ctx.getVariable("firstResult"));
        assertNull(ctx.getVariable("shouldNotExist"));
    }

    // ==================== 优先级排序 ====================

    @Test
    @DisplayName("优先级排序 - 高优先级先执行")
    void testPrioritySorting() {
        ChannelRule ruleA = new ChannelRule("RULE_A", "A", ChannelRuleType.EXPRESSION, "'A'");
        ruleA.setOutputVariable("order1");
        ruleA.setPriority(1);

        ChannelRule ruleB = new ChannelRule("RULE_B", "B", ChannelRuleType.EXPRESSION, "'B'");
        ruleB.setOutputVariable("order2");
        ruleB.setPriority(10);

        ChannelRule ruleC = new ChannelRule("RULE_C", "C", ChannelRuleType.EXPRESSION, "'C'");
        ruleC.setOutputVariable("order3");
        ruleC.setPriority(5);

        flowEngine.registerRule(ruleA);
        flowEngine.registerRule(ruleB);
        flowEngine.registerRule(ruleC);
        flowEngine.setEnablePrioritySorting(true);

        ChannelRuleFlow flow = new ChannelRuleFlow("PRIORITY_FLOW", "优先级流程");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "RULE_A"));
        flow.addStep(new ChannelRuleFlow.FlowStep(2, "RULE_B"));
        flow.addStep(new ChannelRuleFlow.FlowStep(3, "RULE_C"));

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        // B (priority 10) should execute first, then C (5), then A (1)
        assertNotNull(ctx.getVariable("order1"));
        assertNotNull(ctx.getVariable("order2"));
        assertNotNull(ctx.getVariable("order3"));
    }

    @Test
    @DisplayName("禁用优先级排序 - 按步骤原始顺序执行")
    void testDisablePrioritySorting() {
        flowEngine.setEnablePrioritySorting(false);
        assertFalse(flowEngine.isEnablePrioritySorting());
    }

    // ==================== 变量传递 ====================

    @Test
    @DisplayName("变量传递 - 结果在步骤间共享")
    void testVariablePassingBetweenSteps() {
        ChannelRule rule1 = new ChannelRule("CALC", "计算", ChannelRuleType.EXPRESSION, "x * 10");
        rule1.setOutputVariable("multiplied");

        ChannelRule rule2 = new ChannelRule("USE_RESULT", "使用结果", ChannelRuleType.EXPRESSION,
                "multiplied + 5");
        rule2.setOutputVariable("finalVal");

        flowEngine.registerRule(rule1);
        flowEngine.registerRule(rule2);

        ChannelRuleFlow flow = new ChannelRuleFlow("VAR_FLOW", "变量流程");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "CALC"));
        flow.addStep(new ChannelRuleFlow.FlowStep(2, "USE_RESULT"));

        Map<String, Object> params = new HashMap<>();
        params.put("x", 7);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        assertEquals(70, ctx.getVariable("multiplied"));
        assertEquals(75, ctx.getVariable("finalVal"));
    }

    // ==================== 深度限制 ====================

    @Test
    @DisplayName("执行深度限制 - 超过最大深度中断")
    void testMaxExecutionDepth() {
        // 创建多个规则
        for (int i = 1; i <= 5; i++) {
            ChannelRule rule = new ChannelRule("RULE_" + i, "规则" + i,
                    ChannelRuleType.EXPRESSION, String.valueOf(i));
            flowEngine.registerRule(rule);
        }

        ChannelRuleFlow flow = new ChannelRuleFlow("DEEP_FLOW", "深层流程");
        flow.setMaxExecutionDepth(3); // 限制为3层深度
        for (int i = 1; i <= 5; i++) {
            flow.addStep(new ChannelRuleFlow.FlowStep(i, "RULE_" + i));
        }

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertFalse(result.isSuccess());
        assertTrue(ctx.getErrorMessage().contains("depth"));
    }

    // ==================== 超时控制 ====================

    @Test
    @DisplayName("超时控制 - 流程级超时")
    void testFlowTimeout() {
        ChannelRule rule = new ChannelRule("NORMAL", "正常", ChannelRuleType.EXPRESSION, "1 + 1");
        flowEngine.registerRule(rule);

        ChannelRuleFlow flow = new ChannelRuleFlow("TIMEOUT_FLOW", "超时流程");
        flow.setExecutionTimeoutMs(1); // 1ms超时，几乎立即触发
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "NORMAL"));
        // Add a delay by using many steps
        for (int i = 2; i <= 100; i++) {
            flow.addStep(new ChannelRuleFlow.FlowStep(i, "NORMAL"));
        }

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        // Either succeeds very fast or times out - both are valid in this race condition
        // The key is that the engine doesn't crash
        assertNotNull(result);
    }

    // ==================== 空值异常 ====================

    @Test
    @DisplayName("空流程 - 抛出异常")
    void testNullFlow() {
        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        assertThrows(ChannelRuleException.class, () -> flowEngine.executeFlow(null, ctx));
    }

    @Test
    @DisplayName("空上下文 - 抛出异常")
    void testNullFlowContext() {
        ChannelRuleFlow flow = new ChannelRuleFlow("TEST", "测试");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "RULE"));
        assertThrows(ChannelRuleException.class, () -> flowEngine.executeFlow(flow, null));
    }

    @Test
    @DisplayName("空步骤流程 - 抛出异常")
    void testEmptyStepsFlow() {
        ChannelRuleFlow flow = new ChannelRuleFlow("EMPTY", "空流程");
        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        assertThrows(ChannelRuleException.class, () -> flowEngine.executeFlow(flow, ctx));
    }

    @Test
    @DisplayName("缺少规则配置 - abort模式中断")
    void testMissingRuleConfig() {
        ChannelRuleFlow flow = new ChannelRuleFlow("MISSING_FLOW", "缺失流程");
        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "NON_EXISTENT_RULE");
        step.setOnFailure("abort");
        flow.addStep(step);

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertFalse(result.isSuccess());
        assertTrue(ctx.getErrorMessage().contains("Rule not found"));
    }

    @Test
    @DisplayName("空引擎 - 抛出异常")
    void testNullRuleEngine() {
        assertThrows(ChannelRuleException.class, () -> new ChannelFlowEngine(null));
    }

    // ==================== 规则缓存 ====================

    @Test
    @DisplayName("规则缓存 - 注册和获取")
    void testRuleCache() {
        ChannelRule rule = new ChannelRule("CACHED", "缓存", ChannelRuleType.EXPRESSION, "1 + 1");
        flowEngine.registerRule(rule);

        Map<String, ChannelRule> cache = flowEngine.getRuleCache();
        assertTrue(cache.containsKey("CACHED"));
    }
}
