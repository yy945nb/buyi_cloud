package com.buyi.channel.rule;

import com.buyi.channel.rule.enums.ChannelRuleType;
import com.buyi.channel.rule.exception.ChannelRuleValidationException;
import com.buyi.channel.rule.model.ChannelRule;
import com.buyi.channel.rule.model.ChannelRuleFlow;
import com.buyi.channel.rule.validator.ChannelRuleValidator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 渠道规则验证器测试
 * Channel Rule Validator Tests
 *
 * 覆盖场景：
 * 1. 规则验证 - 正常配置
 * 2. 规则验证 - 空规则代码
 * 3. 规则验证 - 空规则类型
 * 4. 规则验证 - 空规则内容
 * 5. 规则验证 - 负重试次数
 * 6. 规则验证 - 负超时时间
 * 7. 流程验证 - 正常配置
 * 8. 流程验证 - 空流程
 * 9. 流程验证 - 空步骤
 * 10. 流程验证 - 引用不存在的规则
 * 11. 流程验证 - 无效的onSuccess/onFailure值
 * 12. 流程验证 - 重复步骤编号
 * 13. 验证并抛出异常
 */
@DisplayName("ChannelRuleValidator 规则验证器测试")
class ChannelRuleValidatorTest {

    private ChannelRuleValidator validator;

    @BeforeEach
    void setUp() {
        validator = new ChannelRuleValidator();
    }

    // ==================== 规则验证 ====================

    @Test
    @DisplayName("有效规则 - 无验证错误")
    void testValidRule() {
        ChannelRule rule = new ChannelRule("VALID", "有效规则", ChannelRuleType.EXPRESSION, "1 + 1");
        List<String> errors = validator.validateRule(rule);
        assertTrue(errors.isEmpty(), "Valid rule should have no errors: " + errors);
    }

    @Test
    @DisplayName("空规则 - 报错")
    void testNullRule() {
        List<String> errors = validator.validateRule(null);
        assertFalse(errors.isEmpty());
        assertTrue(errors.get(0).contains("null"));
    }

    @Test
    @DisplayName("空规则代码 - 报错")
    void testEmptyRuleCode() {
        ChannelRule rule = new ChannelRule("", "空代码", ChannelRuleType.EXPRESSION, "1 + 1");
        List<String> errors = validator.validateRule(rule);
        assertTrue(errors.stream().anyMatch(e -> e.contains("code")));
    }

    @Test
    @DisplayName("null规则代码 - 报错")
    void testNullRuleCode() {
        ChannelRule rule = new ChannelRule(null, "空代码", ChannelRuleType.EXPRESSION, "1 + 1");
        List<String> errors = validator.validateRule(rule);
        assertTrue(errors.stream().anyMatch(e -> e.contains("code")));
    }

    @Test
    @DisplayName("空规则类型 - 报错")
    void testNullRuleType() {
        ChannelRule rule = new ChannelRule("TEST", "测试", null, "1 + 1");
        List<String> errors = validator.validateRule(rule);
        assertTrue(errors.stream().anyMatch(e -> e.contains("type")));
    }

    @Test
    @DisplayName("空规则内容 - 报错")
    void testEmptyRuleContent() {
        ChannelRule rule = new ChannelRule("TEST", "测试", ChannelRuleType.EXPRESSION, "");
        List<String> errors = validator.validateRule(rule);
        assertTrue(errors.stream().anyMatch(e -> e.contains("content")));
    }

    @Test
    @DisplayName("null规则内容 - 报错")
    void testNullRuleContent() {
        ChannelRule rule = new ChannelRule("TEST", "测试", ChannelRuleType.EXPRESSION, null);
        List<String> errors = validator.validateRule(rule);
        assertTrue(errors.stream().anyMatch(e -> e.contains("content")));
    }

    @Test
    @DisplayName("负重试次数 - 报错")
    void testNegativeRetries() {
        ChannelRule rule = new ChannelRule("TEST", "测试", ChannelRuleType.EXPRESSION, "1 + 1");
        rule.setMaxRetries(-1);
        List<String> errors = validator.validateRule(rule);
        assertTrue(errors.stream().anyMatch(e -> e.contains("retries")));
    }

    @Test
    @DisplayName("负超时时间 - 报错")
    void testNegativeTimeout() {
        ChannelRule rule = new ChannelRule("TEST", "测试", ChannelRuleType.EXPRESSION, "1 + 1");
        rule.setTimeoutMs(-1);
        List<String> errors = validator.validateRule(rule);
        assertTrue(errors.stream().anyMatch(e -> e.contains("Timeout")));
    }

    @Test
    @DisplayName("负重试延迟 - 报错")
    void testNegativeRetryDelay() {
        ChannelRule rule = new ChannelRule("TEST", "测试", ChannelRuleType.EXPRESSION, "1 + 1");
        rule.setRetryDelayMs(-1);
        List<String> errors = validator.validateRule(rule);
        assertTrue(errors.stream().anyMatch(e -> e.contains("delay")));
    }

    @Test
    @DisplayName("多个错误同时报出")
    void testMultipleErrors() {
        ChannelRule rule = new ChannelRule(null, null, null, null);
        rule.setMaxRetries(-1);
        List<String> errors = validator.validateRule(rule);
        assertTrue(errors.size() >= 3, "Should have at least 3 errors: " + errors);
    }

    // ==================== 流程验证 ====================

    @Test
    @DisplayName("有效流程 - 无验证错误")
    void testValidFlow() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试流程");
        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "RULE1");
        flow.addStep(step);

        Map<String, ChannelRule> cache = new HashMap<>();
        cache.put("RULE1", new ChannelRule("RULE1", "规则1", ChannelRuleType.EXPRESSION, "1+1"));

        List<String> errors = validator.validateFlow(flow, cache);
        assertTrue(errors.isEmpty(), "Valid flow should have no errors: " + errors);
    }

    @Test
    @DisplayName("空流程 - 报错")
    void testNullFlow() {
        List<String> errors = validator.validateFlow(null, null);
        assertFalse(errors.isEmpty());
        assertTrue(errors.get(0).contains("null"));
    }

    @Test
    @DisplayName("空流程代码 - 报错")
    void testEmptyFlowCode() {
        ChannelRuleFlow flow = new ChannelRuleFlow("", "空代码");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "RULE1"));

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().anyMatch(e -> e.contains("Flow code")));
    }

    @Test
    @DisplayName("空步骤 - 报错")
    void testEmptySteps() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "空步骤");

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().anyMatch(e -> e.contains("at least one step")));
    }

    @Test
    @DisplayName("引用不存在的规则 - 报错")
    void testMissingRuleReference() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试流程");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "NON_EXISTENT"));

        Map<String, ChannelRule> cache = new HashMap<>();
        List<String> errors = validator.validateFlow(flow, cache);
        assertTrue(errors.stream().anyMatch(e -> e.contains("Rule not found")));
    }

    @Test
    @DisplayName("无效的onSuccess值 - 报错")
    void testInvalidOnSuccess() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试流程");
        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "RULE1");
        step.setOnSuccess("invalid_value");
        flow.addStep(step);

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().anyMatch(e -> e.contains("onSuccess")));
    }

    @Test
    @DisplayName("无效的onFailure值 - 报错")
    void testInvalidOnFailure() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试流程");
        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "RULE1");
        step.setOnFailure("invalid_value");
        flow.addStep(step);

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().anyMatch(e -> e.contains("onFailure")));
    }

    @Test
    @DisplayName("重复步骤编号 - 报错")
    void testDuplicateStepNumbers() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试流程");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "RULE1"));
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "RULE2")); // 重复步骤号

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().anyMatch(e -> e.contains("Duplicate step")));
    }

    @Test
    @DisplayName("空步骤规则代码 - 报错")
    void testEmptyStepRuleCode() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试流程");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, ""));

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().anyMatch(e -> e.contains("empty rule code")));
    }

    @Test
    @DisplayName("非正执行深度 - 报错")
    void testNonPositiveMaxDepth() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试流程");
        flow.setMaxExecutionDepth(0);
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "RULE1"));

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().anyMatch(e -> e.contains("depth")));
    }

    @Test
    @DisplayName("非正超时时间 - 报错")
    void testNonPositiveTimeout() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试流程");
        flow.setExecutionTimeoutMs(0);
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "RULE1"));

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().anyMatch(e -> e.contains("timeout")));
    }

    // ==================== 验证并抛出异常 ====================

    @Test
    @DisplayName("validateAndThrow - 有效规则不抛异常")
    void testValidateAndThrowValid() {
        ChannelRule rule = new ChannelRule("VALID", "有效", ChannelRuleType.EXPRESSION, "1+1");
        assertDoesNotThrow(() -> validator.validateAndThrow(rule));
    }

    @Test
    @DisplayName("validateAndThrow - 无效规则抛出异常")
    void testValidateAndThrowInvalid() {
        ChannelRule rule = new ChannelRule(null, null, null, null);
        ChannelRuleValidationException ex = assertThrows(
                ChannelRuleValidationException.class,
                () -> validator.validateAndThrow(rule));

        assertNotNull(ex.getValidationErrors());
        assertFalse(ex.getValidationErrors().isEmpty());
    }

    @Test
    @DisplayName("validateFlowAndThrow - 有效流程不抛异常")
    void testValidateFlowAndThrowValid() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "RULE1"));
        Map<String, ChannelRule> cache = new HashMap<>();
        cache.put("RULE1", new ChannelRule("RULE1", "规则1", ChannelRuleType.EXPRESSION, "1+1"));

        assertDoesNotThrow(() -> validator.validateFlowAndThrow(flow, cache));
    }

    @Test
    @DisplayName("validateFlowAndThrow - 无效流程抛出异常")
    void testValidateFlowAndThrowInvalid() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试");
        // No steps added

        assertThrows(ChannelRuleValidationException.class,
                () -> validator.validateFlowAndThrow(flow, null));
    }

    // ==================== 有效的onSuccess/onFailure值 ====================

    @Test
    @DisplayName("有效的onSuccess=next - 无错误")
    void testValidOnSuccessNext() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试");
        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "RULE1");
        step.setOnSuccess("next");
        flow.addStep(step);

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().noneMatch(e -> e.contains("onSuccess")));
    }

    @Test
    @DisplayName("有效的onSuccess=complete - 无错误")
    void testValidOnSuccessComplete() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试");
        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "RULE1");
        step.setOnSuccess("complete");
        flow.addStep(step);

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().noneMatch(e -> e.contains("onSuccess")));
    }

    @Test
    @DisplayName("有效的onFailure=abort - 无错误")
    void testValidOnFailureAbort() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试");
        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "RULE1");
        step.setOnFailure("abort");
        flow.addStep(step);

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().noneMatch(e -> e.contains("onFailure")));
    }

    @Test
    @DisplayName("有效的onFailure=continue - 无错误")
    void testValidOnFailureContinue() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试");
        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "RULE1");
        step.setOnFailure("continue");
        flow.addStep(step);

        List<String> errors = validator.validateFlow(flow, null);
        assertTrue(errors.stream().noneMatch(e -> e.contains("onFailure")));
    }

    // ==================== null ruleCache 不做引用检查 ====================

    @Test
    @DisplayName("null ruleCache时跳过规则引用检查")
    void testNullRuleCacheSkipsReferenceCheck() {
        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW1", "测试");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "ANY_RULE"));

        List<String> errors = validator.validateFlow(flow, null);
        // Should not contain "Rule not found" since cache is null
        assertTrue(errors.stream().noneMatch(e -> e.contains("Rule not found")));
    }
}
