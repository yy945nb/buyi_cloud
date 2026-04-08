package com.buyi.channel.rule;

import com.buyi.channel.rule.enums.ChannelExecutionStatus;
import com.buyi.channel.rule.enums.ChannelRuleType;
import com.buyi.channel.rule.engine.ChannelFlowEngine;
import com.buyi.channel.rule.engine.ChannelRuleEngine;
import com.buyi.channel.rule.metrics.ChannelRuleMetrics;
import com.buyi.channel.rule.model.*;
import com.buyi.channel.rule.validator.ChannelRuleValidator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 渠道规则引擎集成测试
 * Channel Rule Engine Integration Tests
 *
 * 覆盖真实业务场景：
 * 1. 电商订单价格计算流程
 * 2. 库存预警判断流程
 * 3. 会员等级评估流程
 * 4. 多条件路由流程
 * 5. 带重试的不稳定规则流程
 * 6. 带验证的完整流程
 * 7. 指标收集验证
 * 8. 复杂脚本业务逻辑
 * 9. 渠道规则结果统计
 * 10. 全链路：验证→执行→指标
 */
@DisplayName("ChannelRule 集成测试 - 真实业务场景")
class ChannelRuleIntegrationTest {

    private ChannelRuleEngine ruleEngine;
    private ChannelFlowEngine flowEngine;
    private ChannelRuleValidator validator;

    @BeforeEach
    void setUp() {
        ruleEngine = new ChannelRuleEngine();
        flowEngine = new ChannelFlowEngine(ruleEngine);
        validator = new ChannelRuleValidator();
    }

    // ==================== 场景1：电商订单价格计算 ====================

    @Test
    @DisplayName("场景1: 电商订单 - 完整价格计算流程")
    void testECommerceOrderPricing() {
        // 步骤1: 计算商品总价
        ChannelRule calcTotal = new ChannelRule("CALC_TOTAL", "商品总价",
                ChannelRuleType.EXPRESSION, "unitPrice * quantity");
        calcTotal.setOutputVariable("subtotal");

        // 步骤2: 计算运费（满200免运费）
        ChannelRule calcShipping = new ChannelRule("CALC_SHIPPING", "运费",
                ChannelRuleType.EXPRESSION, "subtotal >= 200 ? 0 : 15");
        calcShipping.setOutputVariable("shipping");

        // 步骤3: 计算折扣（VIP 9折）
        ChannelRule calcDiscount = new ChannelRule("CALC_DISCOUNT", "折扣",
                ChannelRuleType.EXPRESSION, "subtotal * discountRate");
        calcDiscount.setOutputVariable("discountAmount");

        // 步骤4: 计算最终价格
        ChannelRule calcFinal = new ChannelRule("CALC_FINAL", "最终价",
                ChannelRuleType.EXPRESSION, "subtotal - discountAmount + shipping");
        calcFinal.setOutputVariable("finalPrice");

        flowEngine.registerRule(calcTotal);
        flowEngine.registerRule(calcShipping);
        flowEngine.registerRule(calcDiscount);
        flowEngine.registerRule(calcFinal);

        // 构建流程
        ChannelRuleFlow flow = new ChannelRuleFlow("ORDER_PRICING", "订单定价流程");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "CALC_TOTAL"));
        flow.addStep(new ChannelRuleFlow.FlowStep(2, "CALC_SHIPPING"));

        ChannelRuleFlow.FlowStep discountStep = new ChannelRuleFlow.FlowStep(3, "CALC_DISCOUNT");
        discountStep.setCondition("isVip");
        flow.addStep(discountStep);

        flow.addStep(new ChannelRuleFlow.FlowStep(4, "CALC_FINAL"));

        // 场景A: VIP用户购买多件
        Map<String, Object> vipParams = new HashMap<>();
        vipParams.put("unitPrice", 50.0);
        vipParams.put("quantity", 5);
        vipParams.put("isVip", true);
        vipParams.put("discountRate", 0.1);

        ChannelRuleContext vipCtx = new ChannelRuleContext(vipParams);
        ChannelRuleResult vipResult = flowEngine.executeFlow(flow, vipCtx);

        assertTrue(vipResult.isSuccess());
        assertEquals(250.0, vipCtx.getVariable("subtotal"));
        assertEquals(0, vipCtx.getVariable("shipping")); // 满200免运费
        assertEquals(25.0, vipCtx.getVariable("discountAmount")); // 10%折扣
        assertEquals(225.0, vipCtx.getVariable("finalPrice")); // 250 - 25 + 0

        // 场景B: 非VIP小额订单
        Map<String, Object> normalParams = new HashMap<>();
        normalParams.put("unitPrice", 30.0);
        normalParams.put("quantity", 2);
        normalParams.put("isVip", false);
        normalParams.put("discountRate", 0.0);
        normalParams.put("discountAmount", 0.0); // 默认值，非VIP跳过折扣步骤

        ChannelRuleContext normalCtx = new ChannelRuleContext(normalParams);
        ChannelRuleResult normalResult = flowEngine.executeFlow(flow, normalCtx);

        assertTrue(normalResult.isSuccess());
        assertEquals(60.0, normalCtx.getVariable("subtotal"));
        assertEquals(15, normalCtx.getVariable("shipping")); // 不满200需要运费
        assertEquals(75.0, normalCtx.getVariable("finalPrice")); // 60 - 0 + 15
    }

    // ==================== 场景2：库存预警判断 ====================

    @Test
    @DisplayName("场景2: 库存预警 - 多级别告警判断")
    void testInventoryAlertFlow() {
        // 步骤1: 计算库存可用天数
        ChannelRule calcDays = new ChannelRule("CALC_DAYS", "可用天数",
                ChannelRuleType.EXPRESSION, "currentStock / dailySales");
        calcDays.setOutputVariable("availableDays");

        // 步骤2: 判断是否紧急缺货
        ChannelRule checkCritical = new ChannelRule("CHECK_CRITICAL", "紧急",
                ChannelRuleType.CONDITION, "availableDays < 3");
        checkCritical.setOutputVariable("isCritical");

        // 步骤3: 判断是否预警
        ChannelRule checkWarning = new ChannelRule("CHECK_WARNING", "预警",
                ChannelRuleType.CONDITION, "availableDays < 7");
        checkWarning.setOutputVariable("isWarning");

        // 步骤4: 计算建议补货量
        ChannelRule calcReorder = new ChannelRule("CALC_REORDER", "补货量",
                ChannelRuleType.EXPRESSION, "dailySales * 30 - currentStock");
        calcReorder.setOutputVariable("reorderQuantity");

        flowEngine.registerRule(calcDays);
        flowEngine.registerRule(checkCritical);
        flowEngine.registerRule(checkWarning);
        flowEngine.registerRule(calcReorder);

        ChannelRuleFlow flow = new ChannelRuleFlow("INVENTORY_ALERT", "库存预警流程");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "CALC_DAYS"));
        flow.addStep(new ChannelRuleFlow.FlowStep(2, "CHECK_CRITICAL"));
        flow.addStep(new ChannelRuleFlow.FlowStep(3, "CHECK_WARNING"));
        flow.addStep(new ChannelRuleFlow.FlowStep(4, "CALC_REORDER"));

        // 场景: 低库存
        Map<String, Object> params = new HashMap<>();
        params.put("currentStock", 20.0);
        params.put("dailySales", 10.0);

        ChannelRuleContext ctx = new ChannelRuleContext(params);
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        assertEquals(2.0, ctx.getVariable("availableDays")); // 20/10=2天
        assertEquals(true, ctx.getVariable("isCritical")); // <3 紧急
        assertEquals(true, ctx.getVariable("isWarning")); // <7 预警
        assertEquals(280.0, ctx.getVariable("reorderQuantity")); // 10*30-20=280
    }

    // ==================== 场景3：会员等级评估 ====================

    @Test
    @DisplayName("场景3: 会员等级 - 积分+消费额评估")
    void testMemberTierEvaluation() {
        // 步骤1: 计算总积分
        ChannelRule calcPoints = new ChannelRule("CALC_POINTS", "积分",
                ChannelRuleType.EXPRESSION, "purchaseAmount * 10 + loginDays * 5");
        calcPoints.setOutputVariable("totalPoints");

        // 步骤2: 评估等级
        ChannelRule evalTier = new ChannelRule("EVAL_TIER", "等级",
                ChannelRuleType.SCRIPT,
                "if (totalPoints >= 10000) { 'DIAMOND' } " +
                        "else if (totalPoints >= 5000) { 'GOLD' } " +
                        "else if (totalPoints >= 1000) { 'SILVER' } " +
                        "else { 'BRONZE' }");
        evalTier.setOutputVariable("memberTier");

        // 步骤3: 计算折扣率
        ChannelRule calcDiscountRate = new ChannelRule("CALC_RATE", "折扣率",
                ChannelRuleType.SCRIPT,
                "if (memberTier == 'DIAMOND') { 0.15 } " +
                        "else if (memberTier == 'GOLD') { 0.10 } " +
                        "else if (memberTier == 'SILVER') { 0.05 } " +
                        "else { 0.0 }");
        calcDiscountRate.setOutputVariable("discountRate");

        flowEngine.registerRule(calcPoints);
        flowEngine.registerRule(evalTier);
        flowEngine.registerRule(calcDiscountRate);

        ChannelRuleFlow flow = new ChannelRuleFlow("MEMBER_EVAL", "会员评估流程");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "CALC_POINTS"));
        flow.addStep(new ChannelRuleFlow.FlowStep(2, "EVAL_TIER"));
        flow.addStep(new ChannelRuleFlow.FlowStep(3, "CALC_RATE"));

        // 高级会员
        Map<String, Object> params = new HashMap<>();
        params.put("purchaseAmount", 800.0);
        params.put("loginDays", 200);

        ChannelRuleContext ctx = new ChannelRuleContext(params);
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        // 800*10 + 200*5 = 9000
        assertEquals(9000.0, ctx.getVariable("totalPoints"));
        assertEquals("GOLD", ctx.getVariable("memberTier"));
        assertEquals(0.10, ctx.getVariable("discountRate"));
    }

    // ==================== 场景4：多条件路由 ====================

    @Test
    @DisplayName("场景4: 多条件路由 - 根据条件选择性执行")
    void testConditionalRouting() {
        ChannelRule freeShip = new ChannelRule("FREE_SHIP", "免运费", ChannelRuleType.EXPRESSION, "0");
        freeShip.setOutputVariable("shippingFee");

        ChannelRule normalShip = new ChannelRule("NORMAL_SHIP", "正常运费", ChannelRuleType.EXPRESSION, "10");
        normalShip.setOutputVariable("shippingFee");

        ChannelRule expressShip = new ChannelRule("EXPRESS_SHIP", "加急运费", ChannelRuleType.EXPRESSION, "25");
        expressShip.setOutputVariable("shippingFee");

        flowEngine.registerRule(freeShip);
        flowEngine.registerRule(normalShip);
        flowEngine.registerRule(expressShip);

        ChannelRuleFlow flow = new ChannelRuleFlow("SHIPPING_ROUTE", "运费路由");

        // 条件1: 满500免运费
        ChannelRuleFlow.FlowStep step1 = new ChannelRuleFlow.FlowStep(1, "FREE_SHIP");
        step1.setCondition("orderAmount >= 500");
        step1.setOnSuccess("complete");
        flow.addStep(step1);

        // 条件2: 加急配送
        ChannelRuleFlow.FlowStep step2 = new ChannelRuleFlow.FlowStep(2, "EXPRESS_SHIP");
        step2.setCondition("isExpress");
        step2.setOnSuccess("complete");
        flow.addStep(step2);

        // 默认: 正常运费
        ChannelRuleFlow.FlowStep step3 = new ChannelRuleFlow.FlowStep(3, "NORMAL_SHIP");
        flow.addStep(step3);

        // 测试免运费场景
        flowEngine.setEnablePrioritySorting(false);
        Map<String, Object> params1 = new HashMap<>();
        params1.put("orderAmount", 600);
        params1.put("isExpress", false);

        ChannelRuleContext ctx1 = new ChannelRuleContext(params1);
        flowEngine.executeFlow(flow, ctx1);
        assertEquals(0, ctx1.getVariable("shippingFee"));

        // 测试正常运费场景
        Map<String, Object> params2 = new HashMap<>();
        params2.put("orderAmount", 100);
        params2.put("isExpress", false);

        ChannelRuleContext ctx2 = new ChannelRuleContext(params2);
        flowEngine.executeFlow(flow, ctx2);
        assertEquals(10, ctx2.getVariable("shippingFee"));
    }

    // ==================== 场景5：带验证的完整流程 ====================

    @Test
    @DisplayName("场景5: 全链路 - 验证→执行→指标")
    void testFullPipelineWithValidation() {
        // 创建规则
        ChannelRule rule1 = new ChannelRule("CALC_TAX", "税金", ChannelRuleType.EXPRESSION,
                "price * taxRate");
        rule1.setOutputVariable("tax");

        ChannelRule rule2 = new ChannelRule("CALC_TOTAL", "总计", ChannelRuleType.EXPRESSION,
                "price + tax");
        rule2.setOutputVariable("total");

        // 验证规则
        List<String> errors1 = validator.validateRule(rule1);
        List<String> errors2 = validator.validateRule(rule2);
        assertTrue(errors1.isEmpty());
        assertTrue(errors2.isEmpty());

        // 注册规则
        flowEngine.registerRule(rule1);
        flowEngine.registerRule(rule2);

        // 创建流程
        ChannelRuleFlow flow = new ChannelRuleFlow("TAX_CALC", "税金计算");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "CALC_TAX"));
        flow.addStep(new ChannelRuleFlow.FlowStep(2, "CALC_TOTAL"));

        // 验证流程
        List<String> flowErrors = validator.validateFlow(flow, flowEngine.getRuleCache());
        assertTrue(flowErrors.isEmpty(), "Flow validation errors: " + flowErrors);

        // 执行流程
        Map<String, Object> params = new HashMap<>();
        params.put("price", 100.0);
        params.put("taxRate", 0.13);

        ChannelRuleContext ctx = new ChannelRuleContext(params);
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        // 验证结果
        assertTrue(result.isSuccess());
        assertEquals(13.0, (double) ctx.getVariable("tax"), 0.001);
        assertEquals(113.0, (double) ctx.getVariable("total"), 0.001);

        // 验证指标
        ChannelRuleMetrics.MetricSnapshot taxMetric = ruleEngine.getMetrics().getMetricSnapshot("CALC_TAX");
        assertEquals(1, taxMetric.getTotalExecutions());
        assertEquals(1, taxMetric.getSuccessCount());

        ChannelRuleMetrics.MetricSnapshot totalMetric = ruleEngine.getMetrics().getMetricSnapshot("CALC_TOTAL");
        assertEquals(1, totalMetric.getTotalExecutions());
    }

    // ==================== 场景6：复杂脚本业务逻辑 ====================

    @Test
    @DisplayName("场景6: 复杂脚本 - 阶梯定价")
    void testComplexScriptTierPricing() {
        ChannelRule tierPricing = new ChannelRule("TIER_PRICE", "阶梯定价",
                ChannelRuleType.SCRIPT,
                "var total = 0; " +
                        "if (quantity <= 10) { total = quantity * unitPrice; } " +
                        "else if (quantity <= 50) { total = 10 * unitPrice + (quantity - 10) * unitPrice * 0.9; } " +
                        "else { total = 10 * unitPrice + 40 * unitPrice * 0.9 + (quantity - 50) * unitPrice * 0.8; }; " +
                        "total");
        tierPricing.setOutputVariable("tierTotal");

        Map<String, Object> params = new HashMap<>();
        params.put("unitPrice", 100.0);
        params.put("quantity", 60);

        ChannelRuleContext ctx = new ChannelRuleContext(params);
        ChannelRuleResult result = ruleEngine.executeRule(tierPricing, ctx);

        assertTrue(result.isSuccess());
        // 10*100 + 40*100*0.9 + 10*100*0.8 = 1000 + 3600 + 800 = 5400
        assertEquals(5400.0, ctx.getVariable("tierTotal"));
    }

    // ==================== 场景7：结果统计 ====================

    @Test
    @DisplayName("场景7: ChannelRuleResult统计")
    void testResultStatistics() {
        // 成功规则
        ChannelRule goodRule = new ChannelRule("GOOD", "好", ChannelRuleType.EXPRESSION, "1 + 1");
        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = ruleEngine.executeRule(goodRule, ctx);

        assertTrue(result.isSuccess());
        assertEquals(ChannelExecutionStatus.SUCCESS, result.getStatus());
        assertTrue(result.getExecutionTimeMs() >= 0);
        assertFalse(result.getTraces().isEmpty());
    }

    // ==================== 场景8：指标累计 ====================

    @Test
    @DisplayName("场景8: 指标累计 - 多次执行后统计")
    void testMetricsAccumulation() {
        ChannelRule rule = new ChannelRule("METRIC_RULE", "指标规则", ChannelRuleType.EXPRESSION, "x + 1");

        // 执行多次
        for (int i = 0; i < 5; i++) {
            ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
            ctx.setVariable("x", i);
            ruleEngine.executeRule(rule, ctx);
        }

        ChannelRuleMetrics.MetricSnapshot snapshot = ruleEngine.getMetrics().getMetricSnapshot("METRIC_RULE");
        assertEquals(5, snapshot.getTotalExecutions());
        assertEquals(5, snapshot.getSuccessCount());
        assertEquals(0, snapshot.getFailureCount());
    }

    // ==================== 场景9：带重试的规则 ====================

    @Test
    @DisplayName("场景9: 重试规则 - 重试次数记录到指标")
    void testRetryWithMetrics() {
        ChannelRule rule = new ChannelRule("RETRY_METRIC", "重试指标", ChannelRuleType.EXPRESSION,
                "undefined_x + 1");
        rule.setMaxRetries(2);
        rule.setRetryDelayMs(10);

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ruleEngine.executeRule(rule, ctx);

        ChannelRuleMetrics.MetricSnapshot snapshot = ruleEngine.getMetrics().getMetricSnapshot("RETRY_METRIC");
        assertEquals(1, snapshot.getTotalExecutions());
        assertEquals(0, snapshot.getSuccessCount());
        assertEquals(1, snapshot.getFailureCount());
        assertEquals(2, snapshot.getTotalRetries());
    }

    // ==================== 场景10：禁用规则在流程中 ====================

    @Test
    @DisplayName("场景10: 禁用规则 - 在流程中被跳过")
    void testDisabledRuleInFlow() {
        ChannelRule rule1 = new ChannelRule("ENABLED", "启用", ChannelRuleType.EXPRESSION, "100");
        rule1.setOutputVariable("val1");

        ChannelRule rule2 = new ChannelRule("DISABLED", "禁用", ChannelRuleType.EXPRESSION, "200");
        rule2.setOutputVariable("val2");
        rule2.setStatus(0);

        ChannelRule rule3 = new ChannelRule("ALSO_ENABLED", "也启用", ChannelRuleType.EXPRESSION, "300");
        rule3.setOutputVariable("val3");

        flowEngine.registerRule(rule1);
        flowEngine.registerRule(rule2);
        flowEngine.registerRule(rule3);

        ChannelRuleFlow flow = new ChannelRuleFlow("MIXED_FLOW", "混合流程");
        flow.addStep(new ChannelRuleFlow.FlowStep(1, "ENABLED"));
        flow.addStep(new ChannelRuleFlow.FlowStep(2, "DISABLED"));
        flow.addStep(new ChannelRuleFlow.FlowStep(3, "ALSO_ENABLED"));

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        ChannelRuleResult result = flowEngine.executeFlow(flow, ctx);

        assertTrue(result.isSuccess());
        assertEquals(100, ctx.getVariable("val1"));
        // disabled rule result stored as step result with SKIPPED status
        assertEquals(300, ctx.getVariable("val3"));
    }

    // ==================== 场景11：指标重置 ====================

    @Test
    @DisplayName("场景11: 指标重置")
    void testMetricsReset() {
        ChannelRule rule = new ChannelRule("RESET_TEST", "重置", ChannelRuleType.EXPRESSION, "1+1");
        ruleEngine.executeRule(rule, new ChannelRuleContext(new HashMap<>()));

        assertNotNull(ruleEngine.getMetrics().getMetricSnapshot("RESET_TEST"));
        assertEquals(1, ruleEngine.getMetrics().getMetricSnapshot("RESET_TEST").getTotalExecutions());

        ruleEngine.getMetrics().reset();
        assertEquals(0, ruleEngine.getMetrics().getMetricSnapshot("RESET_TEST").getTotalExecutions());
    }

    // ==================== 场景12：模型toString ====================

    @Test
    @DisplayName("场景12: 模型toString - 不抛异常")
    void testModelToString() {
        ChannelRule rule = new ChannelRule("TEST", "测试", ChannelRuleType.EXPRESSION, "1+1");
        assertNotNull(rule.toString());

        ChannelRuleContext ctx = new ChannelRuleContext(new HashMap<>());
        assertNotNull(ctx.toString());

        ChannelRuleFlow flow = new ChannelRuleFlow("FLOW", "流程");
        assertNotNull(flow.toString());

        ChannelRuleFlow.FlowStep step = new ChannelRuleFlow.FlowStep(1, "RULE");
        assertNotNull(step.toString());
    }
}
