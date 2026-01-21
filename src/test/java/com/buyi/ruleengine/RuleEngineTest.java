package com.buyi.ruleengine;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.executor.JavaExpressionExecutor;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import com.buyi.ruleengine.service.RuleEngine;
import org.junit.Before;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * 规则引擎单元测试
 * Rule Engine Unit Tests
 */
public class RuleEngineTest {
    
    private RuleEngine ruleEngine;
    
    @Before
    public void setUp() {
        ruleEngine = new RuleEngine();
        ruleEngine.registerExecutor(new JavaExpressionExecutor());
    }
    
    @Test
    public void testSimpleCalculation() {
        // 测试简单计算：2 + 3
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("ADD_TWO_NUMBERS");
        rule.setRuleName("加法");
        rule.setRuleType(RuleType.JAVA_EXPR);
        rule.setRuleContent("a + b");
        
        Map<String, Object> params = new HashMap<>();
        params.put("a", 2);
        params.put("b", 3);
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertTrue(context.isSuccess());
        assertEquals(5, context.getResult());
    }
    
    @Test
    public void testDiscountCalculation() {
        // 测试折扣计算
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("CALC_DISCOUNT");
        rule.setRuleName("计算折扣价格");
        rule.setRuleType(RuleType.JAVA_EXPR);
        rule.setRuleContent("price * (1 - discount / 100)");
        
        Map<String, Object> params = new HashMap<>();
        params.put("price", 100.0);
        params.put("discount", 20.0);
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertTrue(context.isSuccess());
        assertEquals(80.0, context.getResult());
    }
    
    @Test
    public void testConditionalExpression() {
        // 测试条件表达式
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("CHECK_INVENTORY");
        rule.setRuleName("检查库存");
        rule.setRuleType(RuleType.JAVA_EXPR);
        rule.setRuleContent("stock > minStock");
        
        Map<String, Object> params = new HashMap<>();
        params.put("stock", 50);
        params.put("minStock", 10);
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertTrue(context.isSuccess());
        assertTrue((Boolean) context.getResult());
    }
    
    @Test
    public void testComplexExpression() {
        // 测试复杂表达式
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("CALC_FINAL_PRICE");
        rule.setRuleName("计算最终价格");
        rule.setRuleType(RuleType.JAVA_EXPR);
        rule.setRuleContent("(basePrice + tax) * quantity * (1 - discount / 100)");
        
        Map<String, Object> params = new HashMap<>();
        params.put("basePrice", 100.0);
        params.put("tax", 10.0);
        params.put("quantity", 5);
        params.put("discount", 10.0);
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertTrue(context.isSuccess());
        // (100 + 10) * 5 * (1 - 0.1) = 110 * 5 * 0.9 = 495
        assertEquals(495.0, context.getResult());
    }
    
    @Test
    public void testInvalidExpression() {
        // 测试无效表达式
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("INVALID_RULE");
        rule.setRuleName("无效规则");
        rule.setRuleType(RuleType.JAVA_EXPR);
        rule.setRuleContent("invalid syntax +++");
        
        Map<String, Object> params = new HashMap<>();
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertFalse(context.isSuccess());
        assertNotNull(context.getErrorMessage());
    }
    
    @Test
    public void testMissingParameter() {
        // 测试缺少参数
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("MISSING_PARAM");
        rule.setRuleName("缺少参数");
        rule.setRuleType(RuleType.JAVA_EXPR);
        rule.setRuleContent("a + b");
        
        Map<String, Object> params = new HashMap<>();
        params.put("a", 10);
        // Missing 'b' parameter
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertFalse(context.isSuccess());
        assertNotNull(context.getErrorMessage());
    }
}
