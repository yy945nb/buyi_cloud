package com.buyi.channel.rule;

import com.buyi.channel.rule.enums.ChannelRuleType;
import com.buyi.channel.rule.executor.ExpressionExecutor;
import com.buyi.channel.rule.model.ChannelRule;
import com.buyi.channel.rule.model.ChannelRuleContext;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 表达式执行器测试
 * Expression Executor Tests
 *
 * 覆盖场景：
 * 1. 算术运算（加减乘除、取模）
 * 2. 比较运算
 * 3. 逻辑运算
 * 4. 字符串操作
 * 5. 三元表达式
 * 6. 空值处理
 * 7. 表达式缓存
 * 8. 条件评估API
 * 9. toBoolean转换
 * 10. 参数覆盖
 */
@DisplayName("ExpressionExecutor 表达式执行器测试")
class ExpressionExecutorTest {

    private ExpressionExecutor executor;

    @BeforeEach
    void setUp() {
        executor = new ExpressionExecutor();
    }

    // ==================== 算术运算 ====================

    @Test
    @DisplayName("加法")
    void testAddition() {
        assertExprResult("a + b", map("a", 10, "b", 20), 30);
    }

    @Test
    @DisplayName("减法")
    void testSubtraction() {
        assertExprResult("a - b", map("a", 50, "b", 20), 30);
    }

    @Test
    @DisplayName("乘法")
    void testMultiplication() {
        assertExprResult("a * b", map("a", 6, "b", 7), 42);
    }

    @Test
    @DisplayName("除法")
    void testDivision() {
        assertExprResult("a / b", map("a", 100.0, "b", 4.0), 25.0);
    }

    @Test
    @DisplayName("取模")
    void testModulo() {
        assertExprResult("a % b", map("a", 17, "b", 5), 2);
    }

    @Test
    @DisplayName("复合算术")
    void testCompoundArithmetic() {
        assertExprResult("(a + b) * c - d", map("a", 2, "b", 3, "c", 4, "d", 1), 19);
    }

    @Test
    @DisplayName("浮点数计算")
    void testFloatingPoint() {
        ChannelRule rule = makeRule("price * 0.85");
        Map<String, Object> params = map("price", 200.0);
        ChannelRuleContext ctx = new ChannelRuleContext(params);

        executor.execute(rule, ctx);

        assertTrue(ctx.isSuccess());
        assertEquals(170.0, (double) ctx.getResult(), 0.001);
    }

    // ==================== 比较运算 ====================

    @Test
    @DisplayName("大于")
    void testGreaterThan() {
        assertExprResult("a > b", map("a", 10, "b", 5), true);
    }

    @Test
    @DisplayName("小于")
    void testLessThan() {
        assertExprResult("a < b", map("a", 3, "b", 8), true);
    }

    @Test
    @DisplayName("等于")
    void testEquals() {
        assertExprResult("a == b", map("a", 42, "b", 42), true);
    }

    @Test
    @DisplayName("不等于")
    void testNotEquals() {
        assertExprResult("a != b", map("a", 1, "b", 2), true);
    }

    @Test
    @DisplayName("大于等于")
    void testGreaterOrEqual() {
        assertExprResult("a >= b", map("a", 10, "b", 10), true);
    }

    // ==================== 逻辑运算 ====================

    @Test
    @DisplayName("与运算")
    void testLogicalAnd() {
        assertExprResult("a && b", map("a", true, "b", true), true);
        assertExprResult("a && b", map("a", true, "b", false), false);
    }

    @Test
    @DisplayName("或运算")
    void testLogicalOr() {
        assertExprResult("a || b", map("a", false, "b", true), true);
        assertExprResult("a || b", map("a", false, "b", false), false);
    }

    @Test
    @DisplayName("非运算")
    void testLogicalNot() {
        assertExprResult("!a", map("a", false), true);
    }

    @Test
    @DisplayName("复合逻辑")
    void testCompoundLogic() {
        assertExprResult("(age >= 18) && (score > 60)",
                map("age", 20, "score", 85), true);
        assertExprResult("(age >= 18) && (score > 60)",
                map("age", 15, "score", 85), false);
    }

    // ==================== 字符串操作 ====================

    @Test
    @DisplayName("字符串拼接")
    void testStringConcatenation() {
        assertExprResult("first + ' ' + last", map("first", "Hello", "last", "World"), "Hello World");
    }

    @Test
    @DisplayName("字符串长度")
    void testStringLength() {
        assertExprResult("str.length()", map("str", "hello"), 5);
    }

    // ==================== 三元表达式 ====================

    @Test
    @DisplayName("三元表达式 - 真值")
    void testTernaryTrue() {
        assertExprResult("x > 0 ? 'positive' : 'non-positive'",
                map("x", 5), "positive");
    }

    @Test
    @DisplayName("三元表达式 - 假值")
    void testTernaryFalse() {
        assertExprResult("x > 0 ? 'positive' : 'non-positive'",
                map("x", -1), "non-positive");
    }

    // ==================== 空值处理 ====================

    @Test
    @DisplayName("空表达式")
    void testNullExpression() {
        ChannelRule rule = makeRule(null);
        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());

        executor.execute(rule, ctx);

        assertTrue(ctx.isSuccess());
        assertNull(ctx.getResult());
    }

    @Test
    @DisplayName("空字符串表达式")
    void testEmptyExpression() {
        ChannelRule rule = makeRule("");
        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());

        executor.execute(rule, ctx);

        assertTrue(ctx.isSuccess());
        assertNull(ctx.getResult());
    }

    @Test
    @DisplayName("无效表达式 - 语法错误")
    void testInvalidSyntax() {
        ChannelRule rule = makeRule("+++invalid");
        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());

        executor.execute(rule, ctx);

        assertFalse(ctx.isSuccess());
        assertNotNull(ctx.getErrorMessage());
    }

    // ==================== 表达式缓存 ====================

    @Test
    @DisplayName("表达式缓存 - 重复表达式使用缓存")
    void testExpressionCaching() {
        String expression = "a + b";
        ChannelRule rule = makeRule(expression);

        // 第一次执行
        ChannelRuleContext ctx1 = new ChannelRuleContext(map("a", 1, "b", 2));
        executor.execute(rule, ctx1);
        assertEquals(1, executor.getCacheSize());

        // 第二次使用相同表达式
        ChannelRuleContext ctx2 = new ChannelRuleContext(map("a", 10, "b", 20));
        executor.execute(rule, ctx2);
        assertEquals(1, executor.getCacheSize()); // 缓存大小不变

        assertTrue(ctx1.isSuccess());
        assertEquals(3, ctx1.getResult());
        assertTrue(ctx2.isSuccess());
        assertEquals(30, ctx2.getResult());
    }

    @Test
    @DisplayName("缓存清除")
    void testCacheClear() {
        ChannelRule rule = makeRule("1 + 1");
        executor.execute(rule, new ChannelRuleContext(new HashMap<>()));

        assertEquals(1, executor.getCacheSize());
        executor.clearCache();
        assertEquals(0, executor.getCacheSize());
    }

    // ==================== 条件评估API ====================

    @Test
    @DisplayName("条件评估 - 返回true")
    void testEvaluateConditionTrue() {
        assertTrue(executor.evaluateCondition("x > 5", map("x", 10)));
    }

    @Test
    @DisplayName("条件评估 - 返回false")
    void testEvaluateConditionFalse() {
        assertFalse(executor.evaluateCondition("x > 5", map("x", 2)));
    }

    @Test
    @DisplayName("条件评估 - 无效表达式返回false")
    void testEvaluateConditionInvalid() {
        assertFalse(executor.evaluateCondition("+++invalid", new HashMap<>()));
    }

    @Test
    @DisplayName("条件评估 - null变量返回false")
    void testEvaluateConditionNullVars() {
        assertFalse(executor.evaluateCondition("x > 5", null));
    }

    // ==================== toBoolean转换 ====================

    @Test
    @DisplayName("toBoolean - null转为false")
    void testToBooleanNull() {
        assertFalse(ExpressionExecutor.toBoolean(null));
    }

    @Test
    @DisplayName("toBoolean - Boolean值直接返回")
    void testToBooleanBoolean() {
        assertTrue(ExpressionExecutor.toBoolean(true));
        assertFalse(ExpressionExecutor.toBoolean(false));
    }

    @Test
    @DisplayName("toBoolean - 数字非零为true")
    void testToBooleanNumber() {
        assertTrue(ExpressionExecutor.toBoolean(1));
        assertTrue(ExpressionExecutor.toBoolean(-1));
        assertTrue(ExpressionExecutor.toBoolean(0.5));
        assertFalse(ExpressionExecutor.toBoolean(0));
        assertFalse(ExpressionExecutor.toBoolean(0.0));
    }

    @Test
    @DisplayName("toBoolean - 字符串转换")
    void testToBooleanString() {
        assertTrue(ExpressionExecutor.toBoolean("hello"));
        assertTrue(ExpressionExecutor.toBoolean("true"));
        assertFalse(ExpressionExecutor.toBoolean("false"));
        assertFalse(ExpressionExecutor.toBoolean("0"));
        assertFalse(ExpressionExecutor.toBoolean(""));
    }

    @Test
    @DisplayName("toBoolean - 其他对象为true")
    void testToBooleanObject() {
        assertTrue(ExpressionExecutor.toBoolean(new Object()));
    }

    // ==================== 参数覆盖 ====================

    @Test
    @DisplayName("规则参数覆盖上下文变量")
    void testRuleParamsOverride() {
        ChannelRule rule = makeRule("factor * base");
        Map<String, Object> ruleParams = new HashMap<>();
        ruleParams.put("factor", 3);
        rule.setRuleParams(ruleParams);

        Map<String, Object> ctxParams = map("base", 10, "factor", 99); // ctx has factor=99
        ChannelRuleContext ctx = new ChannelRuleContext(ctxParams);

        executor.execute(rule, ctx);

        assertTrue(ctx.isSuccess());
        // Rule params loaded AFTER context variables, so ruleParams wins
        assertEquals(30, ctx.getResult());
    }

    // ==================== 输出变量 ====================

    @Test
    @DisplayName("输出变量存储")
    void testOutputVariableStorage() {
        ChannelRule rule = makeRule("a * 2");
        rule.setOutputVariable("doubled");

        ChannelRuleContext ctx = new ChannelRuleContext(map("a", 5));
        executor.execute(rule, ctx);

        assertTrue(ctx.isSuccess());
        assertEquals(10, ctx.getVariable("doubled"));
        assertEquals(10, ctx.getStepResult("EXPR_TEST"));
    }

    // ==================== Helper methods ====================

    private ChannelRule makeRule(String expression) {
        return new ChannelRule("EXPR_TEST", "表达式测试", ChannelRuleType.EXPRESSION, expression);
    }

    private void assertExprResult(String expression, Map<String, Object> params, Object expected) {
        ChannelRule rule = makeRule(expression);
        ChannelRuleContext ctx = new ChannelRuleContext(params);
        executor.execute(rule, ctx);
        assertTrue(ctx.isSuccess(), "Expression should succeed: " + expression);
        assertEquals(expected, ctx.getResult(), "Expression result mismatch: " + expression);
    }

    @SafeVarargs
    private static Map<String, Object> map(Object... keyValues) {
        Map<String, Object> m = new HashMap<>();
        for (int i = 0; i < keyValues.length; i += 2) {
            m.put((String) keyValues[i], keyValues[i + 1]);
        }
        return m;
    }
}
