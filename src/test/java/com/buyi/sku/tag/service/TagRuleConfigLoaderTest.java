package com.buyi.sku.tag.service;

import com.buyi.sku.tag.model.SkuTagRule;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

/**
 * 标签规则JSON配置加载器单元测试
 * Tag Rule Config Loader Unit Tests
 */
public class TagRuleConfigLoaderTest {
    
    private TagRuleConfigLoader loader;
    
    @Before
    public void setUp() {
        loader = new TagRuleConfigLoader();
    }
    
    @Test
    public void testLoadRuleConfigFromString() {
        String jsonString = "{"
            + "\"ruleCode\":\"TEST_RULE\","
            + "\"ruleName\":\"测试规则\","
            + "\"tagGroupId\":1,"
            + "\"tagValueId\":101,"
            + "\"ruleType\":\"JAVA_EXPR\","
            + "\"ruleContent\":\"sales_volume >= 1000\","
            + "\"priority\":100,"
            + "\"status\":\"ENABLED\","
            + "\"description\":\"这是一个测试规则\""
            + "}";
        
        SkuTagRule rule = loader.loadRuleConfigFromString(jsonString);
        
        assertNotNull(rule);
        assertEquals("TEST_RULE", rule.getRuleCode());
        assertEquals("测试规则", rule.getRuleName());
        assertEquals(Long.valueOf(1L), rule.getTagGroupId());
        assertEquals(Long.valueOf(101L), rule.getTagValueId());
        assertEquals("JAVA_EXPR", rule.getRuleType());
        assertEquals("sales_volume >= 1000", rule.getRuleContent());
        assertEquals(Integer.valueOf(100), rule.getPriority());
        assertEquals("ENABLED", rule.getStatus());
        assertEquals("这是一个测试规则", rule.getDescription());
    }
    
    @Test
    public void testLoadRuleConfigsFromString() {
        String jsonString = "["
            + "{\"ruleCode\":\"RULE_1\",\"ruleName\":\"规则1\",\"tagGroupId\":1,\"tagValueId\":101,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"value >= 100\",\"priority\":100},"
            + "{\"ruleCode\":\"RULE_2\",\"ruleName\":\"规则2\",\"tagGroupId\":1,\"tagValueId\":102,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"value >= 50\",\"priority\":90},"
            + "{\"ruleCode\":\"RULE_3\",\"ruleName\":\"规则3\",\"tagGroupId\":1,\"tagValueId\":103,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"value < 50\",\"priority\":80}"
            + "]";
        
        List<SkuTagRule> rules = loader.loadRuleConfigsFromString(jsonString);
        
        assertNotNull(rules);
        assertEquals(3, rules.size());
        
        // Verify first rule
        assertEquals("RULE_1", rules.get(0).getRuleCode());
        assertEquals(Integer.valueOf(100), rules.get(0).getPriority());
        
        // Verify second rule
        assertEquals("RULE_2", rules.get(1).getRuleCode());
        assertEquals(Integer.valueOf(90), rules.get(1).getPriority());
        
        // Verify third rule
        assertEquals("RULE_3", rules.get(2).getRuleCode());
        assertEquals(Integer.valueOf(80), rules.get(2).getPriority());
    }
    
    @Test
    public void testLoadRuleConfigWithDefaults() {
        // Minimal config - only required fields
        String jsonString = "{"
            + "\"ruleCode\":\"MINIMAL_RULE\","
            + "\"ruleName\":\"最小配置规则\","
            + "\"tagGroupId\":1,"
            + "\"tagValueId\":101,"
            + "\"ruleType\":\"JAVA_EXPR\","
            + "\"ruleContent\":\"true\""
            + "}";
        
        SkuTagRule rule = loader.loadRuleConfigFromString(jsonString);
        
        assertNotNull(rule);
        assertEquals("MINIMAL_RULE", rule.getRuleCode());
        
        // Defaults should be set
        assertEquals(Integer.valueOf(0), rule.getPriority());
        assertEquals(Integer.valueOf(1), rule.getVersion());
        assertEquals("DRAFT", rule.getStatus());
    }
    
    @Test
    public void testLoadRuleConfigWithComplexExpression() {
        String jsonString = "{"
            + "\"ruleCode\":\"COMPLEX_RULE\","
            + "\"ruleName\":\"复杂表达式规则\","
            + "\"tagGroupId\":1,"
            + "\"tagValueId\":101,"
            + "\"ruleType\":\"JAVA_EXPR\","
            + "\"ruleContent\":\"sales_volume >= 1000 && profit_rate >= 0.3 && turnover_days <= 15\","
            + "\"priority\":100"
            + "}";
        
        SkuTagRule rule = loader.loadRuleConfigFromString(jsonString);
        
        assertNotNull(rule);
        assertEquals("sales_volume >= 1000 && profit_rate >= 0.3 && turnover_days <= 15", 
                rule.getRuleContent());
    }
    
    @Test
    public void testExportRuleConfig() {
        SkuTagRule rule = new SkuTagRule("EXPORT_RULE", "导出测试规则", 1L, 101L, "JAVA_EXPR", "value == 100");
        rule.setPriority(50);
        rule.setStatus("ENABLED");
        
        String json = loader.exportRuleConfig(rule);
        
        assertNotNull(json);
        assertTrue(json.contains("EXPORT_RULE"));
        assertTrue(json.contains("导出测试规则"));
        assertTrue(json.contains("JAVA_EXPR"));
        assertTrue(json.contains("value"));
        assertTrue(json.contains("100"));
    }
    
    @Test
    public void testLoadAndRegisterRules() {
        // Create TagRuleService for testing
        TagService tagService = new TagService();
        TagRuleService ruleService = new TagRuleService(tagService);
        
        // Prepare JSON string with rules
        String jsonString = "["
            + "{\"ruleCode\":\"AUTO_RULE_1\",\"ruleName\":\"自动注册规则1\",\"tagGroupId\":1,\"tagValueId\":101,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"value >= 100\",\"priority\":100,\"status\":\"ENABLED\"},"
            + "{\"ruleCode\":\"AUTO_RULE_2\",\"ruleName\":\"自动注册规则2\",\"tagGroupId\":1,\"tagValueId\":102,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"value >= 50\",\"priority\":90,\"status\":\"ENABLED\"}"
            + "]";
        
        // Load rules
        List<SkuTagRule> rules = loader.loadRuleConfigsFromString(jsonString);
        
        // Register rules
        for (SkuTagRule rule : rules) {
            ruleService.registerRule(rule);
            ruleService.publishRule(rule.getRuleCode(), rule.getVersion(), "test");
        }
        
        // Verify rules are registered and enabled
        List<SkuTagRule> enabledRules = ruleService.getEnabledRules(1L);
        assertEquals(2, enabledRules.size());
        
        // Cleanup
        ruleService.clearCache();
    }
}
