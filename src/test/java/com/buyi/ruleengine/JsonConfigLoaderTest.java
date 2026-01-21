package com.buyi.ruleengine;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleFlow;
import com.buyi.ruleengine.service.JsonConfigLoader;
import org.junit.Before;
import org.junit.Test;

import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * JSON配置加载器单元测试
 * JSON Configuration Loader Unit Tests
 */
public class JsonConfigLoaderTest {
    
    private JsonConfigLoader loader;
    
    @Before
    public void setUp() {
        loader = new JsonConfigLoader();
    }
    
    @Test
    public void testLoadRuleConfigFromString() {
        // 测试从JSON字符串加载规则配置
        String json = "{\n" +
                "  \"ruleCode\": \"CALC_PRICE\",\n" +
                "  \"ruleName\": \"计算价格\",\n" +
                "  \"ruleType\": \"JAVA_EXPR\",\n" +
                "  \"ruleContent\": \"price * quantity\",\n" +
                "  \"description\": \"计算总价格\",\n" +
                "  \"status\": 1,\n" +
                "  \"priority\": 100\n" +
                "}";
        
        RuleConfig config = loader.loadRuleConfigFromString(json);
        
        assertNotNull(config);
        assertEquals("CALC_PRICE", config.getRuleCode());
        assertEquals("计算价格", config.getRuleName());
        assertEquals(RuleType.JAVA_EXPR, config.getRuleType());
        assertEquals("price * quantity", config.getRuleContent());
        assertEquals("计算总价格", config.getDescription());
        assertEquals(Integer.valueOf(1), config.getStatus());
        assertEquals(Integer.valueOf(100), config.getPriority());
    }
    
    @Test
    public void testLoadRuleConfigWithParams() {
        // 测试加载带参数的规则配置
        String json = "{\n" +
                "  \"ruleCode\": \"QUERY_STOCK\",\n" +
                "  \"ruleName\": \"查询库存\",\n" +
                "  \"ruleType\": \"SQL_QUERY\",\n" +
                "  \"ruleContent\": \"SELECT * FROM stock WHERE sku = ?\",\n" +
                "  \"priority\": 50,\n" +
                "  \"ruleParams\": {\n" +
                "    \"inputs\": [\"sku\"],\n" +
                "    \"output\": \"stockInfo\"\n" +
                "  }\n" +
                "}";
        
        RuleConfig config = loader.loadRuleConfigFromString(json);
        
        assertNotNull(config);
        assertEquals("QUERY_STOCK", config.getRuleCode());
        assertEquals(RuleType.SQL_QUERY, config.getRuleType());
        assertEquals(Integer.valueOf(50), config.getPriority());
        
        Map<String, Object> params = config.getRuleParams();
        assertNotNull(params);
        assertTrue(params.containsKey("inputs"));
        assertTrue(params.containsKey("output"));
    }
    
    @Test
    public void testLoadRuleConfigWithDefaultValues() {
        // 测试默认值设置
        String json = "{\n" +
                "  \"ruleCode\": \"SIMPLE_RULE\",\n" +
                "  \"ruleName\": \"简单规则\",\n" +
                "  \"ruleType\": \"JAVA_EXPR\",\n" +
                "  \"ruleContent\": \"a + b\"\n" +
                "}";
        
        RuleConfig config = loader.loadRuleConfigFromString(json);
        
        assertNotNull(config);
        assertEquals(Integer.valueOf(1), config.getStatus()); // 默认启用
        assertEquals(Integer.valueOf(0), config.getPriority()); // 默认优先级
    }
    
    @Test
    public void testLoadFlowConfigFromString() {
        // 测试从JSON字符串加载流程配置
        String json = "{\n" +
                "  \"flowCode\": \"TEST_FLOW\",\n" +
                "  \"flowName\": \"测试流程\",\n" +
                "  \"description\": \"测试流程描述\",\n" +
                "  \"status\": 1,\n" +
                "  \"steps\": [\n" +
                "    {\n" +
                "      \"step\": 1,\n" +
                "      \"ruleCode\": \"RULE1\",\n" +
                "      \"condition\": null,\n" +
                "      \"onSuccess\": \"next\",\n" +
                "      \"onFailure\": \"abort\"\n" +
                "    },\n" +
                "    {\n" +
                "      \"step\": 2,\n" +
                "      \"ruleCode\": \"RULE2\",\n" +
                "      \"condition\": \"RULE1_result > 0\",\n" +
                "      \"onSuccess\": \"complete\",\n" +
                "      \"onFailure\": \"abort\"\n" +
                "    }\n" +
                "  ]\n" +
                "}";
        
        RuleFlow flow = loader.loadFlowConfigFromString(json);
        
        assertNotNull(flow);
        assertEquals("TEST_FLOW", flow.getFlowCode());
        assertEquals("测试流程", flow.getFlowName());
        assertEquals("测试流程描述", flow.getDescription());
        assertEquals(Integer.valueOf(1), flow.getStatus());
        
        List<RuleFlow.FlowStep> steps = flow.getSteps();
        assertNotNull(steps);
        assertEquals(2, steps.size());
        
        RuleFlow.FlowStep step1 = steps.get(0);
        assertEquals(1, step1.getStep());
        assertEquals("RULE1", step1.getRuleCode());
        assertNull(step1.getCondition());
        assertEquals("next", step1.getOnSuccess());
        assertEquals("abort", step1.getOnFailure());
        
        RuleFlow.FlowStep step2 = steps.get(1);
        assertEquals(2, step2.getStep());
        assertEquals("RULE2", step2.getRuleCode());
        assertEquals("RULE1_result > 0", step2.getCondition());
        assertEquals("complete", step2.getOnSuccess());
    }
    
    @Test
    public void testLoadFlowConfigWithDefaultValues() {
        // 测试流程配置的默认值
        String json = "{\n" +
                "  \"flowCode\": \"DEFAULT_FLOW\",\n" +
                "  \"flowName\": \"默认流程\",\n" +
                "  \"steps\": [\n" +
                "    {\n" +
                "      \"step\": 1,\n" +
                "      \"ruleCode\": \"RULE1\"\n" +
                "    }\n" +
                "  ]\n" +
                "}";
        
        RuleFlow flow = loader.loadFlowConfigFromString(json);
        
        assertNotNull(flow);
        assertEquals(Integer.valueOf(1), flow.getStatus()); // 默认启用
        
        RuleFlow.FlowStep step = flow.getSteps().get(0);
        assertEquals("next", step.getOnSuccess()); // 默认继续
        assertEquals("abort", step.getOnFailure()); // 默认中止
    }
    
    @Test
    public void testLoadRuleConfigWithPriority() {
        // 测试加载带优先级的规则配置
        String json = "{\n" +
                "  \"ruleCode\": \"HIGH_PRIORITY_RULE\",\n" +
                "  \"ruleName\": \"高优先级规则\",\n" +
                "  \"ruleType\": \"JAVA_EXPR\",\n" +
                "  \"ruleContent\": \"a * b\",\n" +
                "  \"priority\": 999\n" +
                "}";
        
        RuleConfig config = loader.loadRuleConfigFromString(json);
        
        assertNotNull(config);
        assertEquals(Integer.valueOf(999), config.getPriority());
    }
}
