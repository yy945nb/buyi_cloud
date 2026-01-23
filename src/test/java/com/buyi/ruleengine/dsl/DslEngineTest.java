package com.buyi.ruleengine.dsl;

import com.buyi.ruleengine.dsl.engine.DslRuleChainEngine;
import com.buyi.ruleengine.dsl.model.DslExecutionContext;
import com.buyi.ruleengine.dsl.model.DslNode;
import com.buyi.ruleengine.dsl.model.DslRuleChain;
import com.buyi.ruleengine.dsl.parser.DslParseException;
import com.buyi.ruleengine.dsl.parser.DslParser;
import org.junit.Before;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * DSL解析器和引擎单元测试
 * DSL Parser and Engine Unit Tests
 */
public class DslEngineTest {
    
    private DslParser parser;
    private DslRuleChainEngine engine;
    
    @Before
    public void setUp() {
        parser = new DslParser();
        engine = new DslRuleChainEngine();
    }
    
    @Test
    public void testSimpleChainParsing() {
        String dsl = 
            "chain {\n" +
            "    id: \"test_chain\"\n" +
            "    name: \"测试链\"\n" +
            "    version: \"1.0.0\"\n" +
            "    \n" +
            "    start -> calculatePrice\n" +
            "    \n" +
            "    node calculatePrice {\n" +
            "        type: rule\n" +
            "        expression: `price * quantity`\n" +
            "        output: \"totalPrice\"\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        
        assertNotNull(chain);
        assertEquals("test_chain", chain.getChainId());
        assertEquals("测试链", chain.getChainName());
        assertEquals("1.0.0", chain.getVersion());
        assertTrue(chain.getNodeList().size() >= 1);
    }
    
    @Test
    public void testChainExecution() {
        String dsl = 
            "chain {\n" +
            "    id: \"calc_chain\"\n" +
            "    name: \"计算链\"\n" +
            "    \n" +
            "    start -> multiply\n" +
            "    \n" +
            "    node multiply {\n" +
            "        type: rule\n" +
            "        expression: `a * b`\n" +
            "        output: \"result\"\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        
        Map<String, Object> params = new HashMap<>();
        params.put("a", 5);
        params.put("b", 10);
        
        DslExecutionContext context = engine.execute(chain, params);
        
        assertTrue(context.isSuccess());
        assertEquals(50, context.getVariable("result"));
    }
    
    @Test
    public void testConditionNode() {
        String dsl = 
            "chain {\n" +
            "    id: \"condition_chain\"\n" +
            "    name: \"条件链\"\n" +
            "    \n" +
            "    start -> checkValue\n" +
            "    \n" +
            "    condition checkValue {\n" +
            "        expression: `value > 10`\n" +
            "        then: highPath\n" +
            "        else: lowPath\n" +
            "    }\n" +
            "    \n" +
            "    node highPath {\n" +
            "        type: rule\n" +
            "        expression: `value * 2`\n" +
            "        output: \"result\"\n" +
            "    }\n" +
            "    \n" +
            "    node lowPath {\n" +
            "        type: rule\n" +
            "        expression: `value + 5`\n" +
            "        output: \"result\"\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        
        // 测试条件为真的情况
        Map<String, Object> highParams = new HashMap<>();
        highParams.put("value", 20);
        DslExecutionContext highContext = engine.execute(chain, highParams);
        
        assertTrue(highContext.isSuccess());
        assertEquals(40, highContext.getVariable("result"));
        
        // 测试条件为假的情况
        Map<String, Object> lowParams = new HashMap<>();
        lowParams.put("value", 5);
        DslExecutionContext lowContext = engine.execute(chain, lowParams);
        
        assertTrue(lowContext.isSuccess());
        assertEquals(10, lowContext.getVariable("result"));
    }
    
    @Test
    public void testChainWithConfig() {
        String dsl = 
            "chain {\n" +
            "    id: \"config_chain\"\n" +
            "    name: \"配置链\"\n" +
            "    \n" +
            "    config {\n" +
            "        maxDepth: 50\n" +
            "        executionTimeout: 30000\n" +
            "        enableLogging: true\n" +
            "    }\n" +
            "    \n" +
            "    start -> simpleRule\n" +
            "    \n" +
            "    node simpleRule {\n" +
            "        type: rule\n" +
            "        expression: `1 + 1`\n" +
            "        output: \"sum\"\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        
        assertEquals(50, chain.getMaxExecutionDepth());
        assertEquals(30000, chain.getExecutionTimeout());
        assertTrue(chain.isEnableLogging());
    }
    
    @Test
    public void testMultiNodeChain() {
        String dsl = 
            "chain {\n" +
            "    id: \"multi_node_chain\"\n" +
            "    name: \"多节点链\"\n" +
            "    \n" +
            "    start -> step1\n" +
            "    \n" +
            "    node step1 {\n" +
            "        type: rule\n" +
            "        expression: `a + 10`\n" +
            "        output: \"step1Result\"\n" +
            "        next: step2\n" +
            "    }\n" +
            "    \n" +
            "    node step2 {\n" +
            "        type: rule\n" +
            "        expression: `step1Result * 2`\n" +
            "        output: \"step2Result\"\n" +
            "        next: step3\n" +
            "    }\n" +
            "    \n" +
            "    node step3 {\n" +
            "        type: rule\n" +
            "        expression: `step2Result - 5`\n" +
            "        output: \"finalResult\"\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        
        Map<String, Object> params = new HashMap<>();
        params.put("a", 5);
        
        DslExecutionContext context = engine.execute(chain, params);
        
        assertTrue(context.isSuccess());
        // step1: 5 + 10 = 15
        // step2: 15 * 2 = 30
        // step3: 30 - 5 = 25
        assertEquals(15, context.getVariable("step1Result"));
        assertEquals(30, context.getVariable("step2Result"));
        assertEquals(25, context.getVariable("finalResult"));
    }
    
    @Test
    public void testDiscountCalculation() {
        String dsl = 
            "chain {\n" +
            "    id: \"discount_chain\"\n" +
            "    name: \"折扣计算链\"\n" +
            "    description: \"计算商品折扣价格\"\n" +
            "    \n" +
            "    start -> checkVip\n" +
            "    \n" +
            "    condition checkVip {\n" +
            "        expression: `isVip == true`\n" +
            "        then: vipDiscount\n" +
            "        else: normalDiscount\n" +
            "    }\n" +
            "    \n" +
            "    node vipDiscount {\n" +
            "        type: rule\n" +
            "        expression: `price * 0.8`\n" +
            "        output: \"finalPrice\"\n" +
            "    }\n" +
            "    \n" +
            "    node normalDiscount {\n" +
            "        type: rule\n" +
            "        expression: `price * 0.95`\n" +
            "        output: \"finalPrice\"\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        
        // VIP用户
        Map<String, Object> vipParams = new HashMap<>();
        vipParams.put("price", 100.0);
        vipParams.put("isVip", true);
        
        DslExecutionContext vipContext = engine.execute(chain, vipParams);
        assertTrue(vipContext.isSuccess());
        assertEquals(80.0, (Double) vipContext.getVariable("finalPrice"), 0.01);
        
        // 普通用户
        Map<String, Object> normalParams = new HashMap<>();
        normalParams.put("price", 100.0);
        normalParams.put("isVip", false);
        
        DslExecutionContext normalContext = engine.execute(chain, normalParams);
        assertTrue(normalContext.isSuccess());
        assertEquals(95.0, (Double) normalContext.getVariable("finalPrice"), 0.01);
    }
    
    @Test
    public void testCommentRemoval() {
        String dsl = 
            "// 这是单行注释\n" +
            "chain {\n" +
            "    id: \"comment_test\"\n" +
            "    name: \"注释测试\" // 行尾注释\n" +
            "    /* 这是块注释 */\n" +
            "    \n" +
            "    start -> simpleNode\n" +
            "    \n" +
            "    node simpleNode {\n" +
            "        type: rule\n" +
            "        expression: `1 + 1` // 计算表达式\n" +
            "        output: \"result\"\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        
        assertNotNull(chain);
        assertEquals("comment_test", chain.getChainId());
        assertEquals("注释测试", chain.getChainName());
    }
    
    @Test(expected = DslParseException.class)
    public void testInvalidDsl() {
        String dsl = "invalid dsl content";
        parser.parse(dsl);
    }
    
    @Test(expected = DslParseException.class)
    public void testEmptyDsl() {
        parser.parse("");
    }
    
    @Test(expected = DslParseException.class)
    public void testMissingChainId() {
        String dsl = 
            "chain {\n" +
            "    name: \"无ID链\"\n" +
            "    start -> node1\n" +
            "    node node1 {\n" +
            "        type: rule\n" +
            "        expression: `1`\n" +
            "    }\n" +
            "}";
        
        parser.parse(dsl);
    }
    
    @Test
    public void testExecutionTraces() {
        String dsl = 
            "chain {\n" +
            "    id: \"trace_chain\"\n" +
            "    name: \"追踪链\"\n" +
            "    \n" +
            "    start -> node1\n" +
            "    \n" +
            "    node node1 {\n" +
            "        type: rule\n" +
            "        expression: `10`\n" +
            "        output: \"value\"\n" +
            "        next: node2\n" +
            "    }\n" +
            "    \n" +
            "    node node2 {\n" +
            "        type: rule\n" +
            "        expression: `value * 2`\n" +
            "        output: \"result\"\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        DslExecutionContext context = engine.execute(chain, new HashMap<>());
        
        assertTrue(context.isSuccess());
        assertFalse(context.getExecutionTraces().isEmpty());
        assertTrue(context.getTotalExecutionTime() >= 0);
    }
    
    @Test
    public void testNodeParams() {
        String dsl = 
            "chain {\n" +
            "    id: \"params_chain\"\n" +
            "    name: \"参数链\"\n" +
            "    \n" +
            "    start -> calcNode\n" +
            "    \n" +
            "    node calcNode {\n" +
            "        type: rule\n" +
            "        expression: `base + bonus`\n" +
            "        output: \"total\"\n" +
            "        params {\n" +
            "            bonus: 100\n" +
            "        }\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        
        Map<String, Object> params = new HashMap<>();
        params.put("base", 50);
        
        DslExecutionContext context = engine.execute(chain, params);
        
        assertTrue(context.isSuccess());
        assertEquals(150L, context.getVariable("total"));
    }
    
    @Test
    public void testComplexExpression() {
        String dsl = 
            "chain {\n" +
            "    id: \"complex_expr_chain\"\n" +
            "    name: \"复杂表达式链\"\n" +
            "    \n" +
            "    start -> calculate\n" +
            "    \n" +
            "    node calculate {\n" +
            "        type: rule\n" +
            "        expression: `(price * quantity) * (1 - discount / 100)`\n" +
            "        output: \"finalPrice\"\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        
        Map<String, Object> params = new HashMap<>();
        params.put("price", 100.0);
        params.put("quantity", 5);
        params.put("discount", 20.0);
        
        DslExecutionContext context = engine.execute(chain, params);
        
        assertTrue(context.isSuccess());
        // (100 * 5) * (1 - 20/100) = 500 * 0.8 = 400
        assertEquals(400.0, (Double) context.getVariable("finalPrice"), 0.01);
    }
    
    @Test
    public void testStringExpressionResult() {
        String dsl = 
            "chain {\n" +
            "    id: \"string_chain\"\n" +
            "    name: \"字符串链\"\n" +
            "    \n" +
            "    start -> gradeNode\n" +
            "    \n" +
            "    condition gradeNode {\n" +
            "        expression: `score >= 60`\n" +
            "        then: passNode\n" +
            "        else: failNode\n" +
            "    }\n" +
            "    \n" +
            "    node passNode {\n" +
            "        type: rule\n" +
            "        expression: `\"PASS\"`\n" +
            "        output: \"grade\"\n" +
            "    }\n" +
            "    \n" +
            "    node failNode {\n" +
            "        type: rule\n" +
            "        expression: `\"FAIL\"`\n" +
            "        output: \"grade\"\n" +
            "    }\n" +
            "}";
        
        DslRuleChain chain = parser.parse(dsl);
        
        // 及格情况
        Map<String, Object> passParams = new HashMap<>();
        passParams.put("score", 75);
        DslExecutionContext passContext = engine.execute(chain, passParams);
        assertTrue(passContext.isSuccess());
        assertEquals("PASS", passContext.getVariable("grade"));
        
        // 不及格情况
        Map<String, Object> failParams = new HashMap<>();
        failParams.put("score", 50);
        DslExecutionContext failContext = engine.execute(chain, failParams);
        assertTrue(failContext.isSuccess());
        assertEquals("FAIL", failContext.getVariable("grade"));
    }
}
