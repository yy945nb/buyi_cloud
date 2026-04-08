package com.buyi.channel.rule;

import com.buyi.channel.rule.enums.ChannelExecutionStatus;
import com.buyi.channel.rule.enums.ChannelRuleType;
import com.buyi.channel.rule.exception.ChannelRuleException;
import com.buyi.channel.rule.engine.ChannelRuleEngine;
import com.buyi.channel.rule.executor.ChannelRuleExecutor;
import com.buyi.channel.rule.metrics.ChannelRuleMetrics;
import com.buyi.channel.rule.model.ChannelRule;
import com.buyi.channel.rule.model.ChannelRuleContext;
import com.buyi.channel.rule.model.ChannelRuleResult;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 渠道规则引擎核心测试
 * Channel Rule Engine Core Tests
 *
 * 覆盖场景：
 * 1. 基本表达式计算
 * 2. 条件判断
 * 3. 脚本执行
 * 4. 重试机制
 * 5. 超时控制
 * 6. 禁用规则跳过
 * 7. 执行器注册与查找
 * 8. 空值和异常处理
 * 9. 指标收集
 * 10. 输出变量存储
 */
@DisplayName("ChannelRuleEngine 核心引擎测试")
class ChannelRuleEngineTest {

    private ChannelRuleEngine engine;

    @BeforeEach
    void setUp() {
        engine = new ChannelRuleEngine();
    }

    // ==================== 基本表达式计算 ====================

    @Test
    @DisplayName("简单加法计算")
    void testSimpleAddition() {
        ChannelRule rule = new ChannelRule("ADD", "加法", ChannelRuleType.EXPRESSION, "a + b");

        Map<String, Object> params = new HashMap<>();
        params.put("a", 2);
        params.put("b", 3);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals(5, result.getResult());
    }

    @Test
    @DisplayName("折扣价格计算")
    void testDiscountCalculation() {
        ChannelRule rule = new ChannelRule("DISCOUNT", "折扣", ChannelRuleType.EXPRESSION,
                "price * (1 - discount / 100)");

        Map<String, Object> params = new HashMap<>();
        params.put("price", 100.0);
        params.put("discount", 20.0);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals(80.0, result.getResult());
    }

    @Test
    @DisplayName("复杂表达式计算 - 最终价格")
    void testComplexExpression() {
        ChannelRule rule = new ChannelRule("FINAL_PRICE", "最终价格", ChannelRuleType.EXPRESSION,
                "(basePrice + tax) * quantity * (1 - discount / 100)");

        Map<String, Object> params = new HashMap<>();
        params.put("basePrice", 100.0);
        params.put("tax", 10.0);
        params.put("quantity", 5);
        params.put("discount", 10.0);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals(495.0, result.getResult());
    }

    @Test
    @DisplayName("字符串拼接表达式")
    void testStringExpression() {
        ChannelRule rule = new ChannelRule("CONCAT", "拼接", ChannelRuleType.EXPRESSION,
                "firstName + ' ' + lastName");

        Map<String, Object> params = new HashMap<>();
        params.put("firstName", "John");
        params.put("lastName", "Doe");
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals("John Doe", result.getResult());
    }

    // ==================== 条件判断 ====================

    @Test
    @DisplayName("条件判断 - 库存检查")
    void testConditionInventoryCheck() {
        ChannelRule rule = new ChannelRule("CHECK_STOCK", "库存检查", ChannelRuleType.CONDITION,
                "stock > minStock");

        Map<String, Object> params = new HashMap<>();
        params.put("stock", 50);
        params.put("minStock", 10);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals(true, result.getResult());
    }

    @Test
    @DisplayName("条件判断 - 库存不足")
    void testConditionInsufficientStock() {
        ChannelRule rule = new ChannelRule("CHECK_STOCK", "库存检查", ChannelRuleType.CONDITION,
                "stock > minStock");

        Map<String, Object> params = new HashMap<>();
        params.put("stock", 5);
        params.put("minStock", 10);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals(false, result.getResult());
    }

    @Test
    @DisplayName("条件判断 - 复合条件")
    void testCompoundCondition() {
        ChannelRule rule = new ChannelRule("COMPOUND", "复合", ChannelRuleType.CONDITION,
                "age >= 18 && income > 5000");

        Map<String, Object> params = new HashMap<>();
        params.put("age", 25);
        params.put("income", 8000);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals(true, result.getResult());
    }

    // ==================== 脚本执行 ====================

    @Test
    @DisplayName("多行脚本执行")
    void testScriptExecution() {
        ChannelRule rule = new ChannelRule("SCRIPT_CALC", "脚本", ChannelRuleType.SCRIPT,
                "var result = 0; for (var i : items) { result = result + i; }; result");

        Map<String, Object> params = new HashMap<>();
        params.put("items", new int[]{1, 2, 3, 4, 5});
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals(15, result.getResult());
    }

    @Test
    @DisplayName("脚本 - 条件赋值")
    void testScriptConditionalAssignment() {
        ChannelRule rule = new ChannelRule("TIER_CALC", "等级", ChannelRuleType.SCRIPT,
                "if (score >= 90) { 'A' } else if (score >= 80) { 'B' } else { 'C' }");

        Map<String, Object> params = new HashMap<>();
        params.put("score", 85);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals("B", result.getResult());
    }

    // ==================== 重试机制 ====================

    @Test
    @DisplayName("重试 - 首次成功无需重试")
    void testRetryNotNeeded() {
        ChannelRule rule = new ChannelRule("RETRY_OK", "重试测试", ChannelRuleType.EXPRESSION, "a + b");
        rule.setMaxRetries(3);

        Map<String, Object> params = new HashMap<>();
        params.put("a", 1);
        params.put("b", 2);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals(3, result.getResult());
        assertEquals(0, result.getTotalRetries());
    }

    @Test
    @DisplayName("重试 - 失败并重试后仍然失败")
    void testRetryExhausted() {
        ChannelRule rule = new ChannelRule("RETRY_FAIL", "重试失败", ChannelRuleType.EXPRESSION,
                "undefined_var + 1");
        rule.setMaxRetries(2);
        rule.setRetryDelayMs(10); // 短延迟用于测试

        Map<String, Object> params = new HashMap<>();
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertFalse(result.isSuccess());
        assertEquals(2, result.getTotalRetries());
    }

    // ==================== 超时控制 ====================

    @Test
    @DisplayName("超时 - 正常执行不超时")
    void testNoTimeout() {
        ChannelRule rule = new ChannelRule("FAST", "快速", ChannelRuleType.EXPRESSION, "1 + 1");
        rule.setTimeoutMs(5000);

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertNotEquals(ChannelExecutionStatus.TIMEOUT, result.getStatus());
    }

    // ==================== 禁用规则 ====================

    @Test
    @DisplayName("禁用规则 - 应该被跳过")
    void testDisabledRuleSkipped() {
        ChannelRule rule = new ChannelRule("DISABLED", "已禁用", ChannelRuleType.EXPRESSION, "a + b");
        rule.setStatus(0);

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertEquals(ChannelExecutionStatus.SKIPPED, result.getStatus());
    }

    // ==================== 执行器注册 ====================

    @Test
    @DisplayName("自动注册默认执行器 - Expression, Condition, Script")
    void testDefaultExecutorsRegistered() {
        Map<ChannelRuleType, ChannelRuleExecutor> registry = engine.getExecutorRegistry();

        assertTrue(registry.containsKey(ChannelRuleType.EXPRESSION));
        assertTrue(registry.containsKey(ChannelRuleType.CONDITION));
        assertTrue(registry.containsKey(ChannelRuleType.SCRIPT));
    }

    @Test
    @DisplayName("未注册的规则类型 - 返回错误")
    void testUnregisteredRuleType() {
        ChannelRule rule = new ChannelRule("GROOVY_TEST", "Groovy", ChannelRuleType.GROOVY, "1 + 1");

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertFalse(result.isSuccess());
        assertNotNull(ctx.getErrorMessage());
        assertTrue(ctx.getErrorMessage().contains("No executor registered"));
    }

    @Test
    @DisplayName("自定义执行器注册")
    void testCustomExecutorRegistration() {
        ChannelRuleExecutor customExecutor = new ChannelRuleExecutor() {
            @Override
            public void execute(ChannelRule rule, ChannelRuleContext context) {
                context.setResult("custom_result");
                context.setSuccess(true);
            }

            @Override
            public ChannelRuleType getSupportedType() {
                return ChannelRuleType.GROOVY;
            }
        };

        engine.registerExecutor(customExecutor);

        ChannelRule rule = new ChannelRule("GROOVY_RULE", "Groovy", ChannelRuleType.GROOVY, "1 + 1");
        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertEquals("custom_result", result.getResult());
    }

    // ==================== 空值和异常处理 ====================

    @Test
    @DisplayName("空规则 - 抛出异常")
    void testNullRule() {
        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        assertThrows(ChannelRuleException.class, () -> engine.executeRule(null, ctx));
    }

    @Test
    @DisplayName("空上下文 - 抛出异常")
    void testNullContext() {
        ChannelRule rule = new ChannelRule("TEST", "测试", ChannelRuleType.EXPRESSION, "1");
        assertThrows(ChannelRuleException.class, () -> engine.executeRule(rule, null));
    }

    @Test
    @DisplayName("无效表达式 - 执行失败")
    void testInvalidExpression() {
        ChannelRule rule = new ChannelRule("INVALID", "无效", ChannelRuleType.EXPRESSION,
                "invalid syntax +++");

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertFalse(result.isSuccess());
        assertNotNull(ctx.getErrorMessage());
    }

    @Test
    @DisplayName("缺少变量 - 执行失败")
    void testMissingVariable() {
        ChannelRule rule = new ChannelRule("MISSING", "缺少变量", ChannelRuleType.EXPRESSION,
                "a + b");

        Map<String, Object> params = new HashMap<>();
        params.put("a", 10);
        // 'b' missing
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertFalse(result.isSuccess());
    }

    @Test
    @DisplayName("空表达式 - 返回null结果")
    void testEmptyExpression() {
        ChannelRule rule = new ChannelRule("EMPTY", "空表达式", ChannelRuleType.EXPRESSION, "");

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertTrue(result.isSuccess());
        assertNull(result.getResult());
    }

    // ==================== 指标收集 ====================

    @Test
    @DisplayName("指标 - 成功执行记录")
    void testMetricsRecordSuccess() {
        ChannelRule rule = new ChannelRule("METRIC_OK", "指标", ChannelRuleType.EXPRESSION, "1 + 1");

        engine.executeRule(rule, new ChannelRuleContext(new HashMap<>()));
        engine.executeRule(rule, new ChannelRuleContext(new HashMap<>()));

        ChannelRuleMetrics.MetricSnapshot snapshot = engine.getMetrics().getMetricSnapshot("METRIC_OK");

        assertEquals(2, snapshot.getTotalExecutions());
        assertEquals(2, snapshot.getSuccessCount());
        assertEquals(0, snapshot.getFailureCount());
    }

    @Test
    @DisplayName("指标 - 失败执行记录")
    void testMetricsRecordFailure() {
        ChannelRule rule = new ChannelRule("METRIC_FAIL", "指标失败", ChannelRuleType.EXPRESSION,
                "unknown + 1");

        engine.executeRule(rule, new ChannelRuleContext(new HashMap<>()));

        ChannelRuleMetrics.MetricSnapshot snapshot = engine.getMetrics().getMetricSnapshot("METRIC_FAIL");

        assertEquals(1, snapshot.getTotalExecutions());
        assertEquals(0, snapshot.getSuccessCount());
        assertEquals(1, snapshot.getFailureCount());
    }

    // ==================== 输出变量 ====================

    @Test
    @DisplayName("输出变量 - 结果自动存储到上下文")
    void testOutputVariable() {
        ChannelRule rule = new ChannelRule("OUT_VAR", "输出", ChannelRuleType.EXPRESSION, "a * 2");
        rule.setOutputVariable("doubledValue");

        Map<String, Object> params = new HashMap<>();
        params.put("a", 5);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        engine.executeRule(rule, ctx);

        assertEquals(10, ctx.getVariable("doubledValue"));
        assertEquals(10, ctx.getStepResult("OUT_VAR"));
    }

    // ==================== 追踪记录 ====================

    @Test
    @DisplayName("追踪 - 执行后产生追踪记录")
    void testExecutionTraces() {
        ChannelRule rule = new ChannelRule("TRACE", "追踪", ChannelRuleType.EXPRESSION, "1 + 1");

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = engine.executeRule(rule, ctx);

        assertFalse(result.getTraces().isEmpty());
        assertTrue(result.getTraces().get(0).isSuccess());
    }

    @Test
    @DisplayName("追踪 - 记录执行时间")
    void testTraceRecordsDuration() {
        ChannelRule rule = new ChannelRule("TRACE_TIME", "追踪时间", ChannelRuleType.EXPRESSION, "1 + 1");

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        engine.executeRule(rule, ctx);

        assertTrue(ctx.getTraces().get(0).getDurationMs() >= 0);
    }
}
