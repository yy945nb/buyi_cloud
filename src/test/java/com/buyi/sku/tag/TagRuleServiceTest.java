package com.buyi.sku.tag;

import com.buyi.sku.tag.enums.TagRuleStatus;
import com.buyi.sku.tag.enums.TagSource;
import com.buyi.sku.tag.model.SkuTagResult;
import com.buyi.sku.tag.model.SkuTagRule;
import com.buyi.sku.tag.service.TagRuleService;
import com.buyi.sku.tag.service.TagService;
import org.junit.Before;
import org.junit.Test;

import java.util.*;

import static org.junit.Assert.*;

/**
 * SKU标签规则服务测试
 * SKU Tag Rule Service Test
 */
public class TagRuleServiceTest {
    
    private TagService tagService;
    private TagRuleService tagRuleService;
    
    @Before
    public void setUp() {
        tagService = new TagService();
        tagRuleService = new TagRuleService(tagService);
    }
    
    @Test
    public void testRegisterRule() {
        SkuTagRule rule = new SkuTagRule();
        rule.setRuleCode("TEST_RULE");
        rule.setRuleName("Test Rule");
        rule.setTagGroupId(1L);
        rule.setTagValueId(101L);
        rule.setRuleType("JAVA_EXPR");
        rule.setRuleContent("sales_volume > 100");
        rule.setPriority(100);
        
        Long ruleId = tagRuleService.registerRule(rule);
        
        assertNotNull("Rule ID should not be null", ruleId);
        assertNotNull("Rule should have version", rule.getVersion());
        assertEquals("Rule should be in DRAFT status", TagRuleStatus.DRAFT.getCode(), 
                rule.getStatus());
    }
    
    @Test
    public void testPublishRule() {
        // Register rule
        SkuTagRule rule = createTestRule("PUBLISH_TEST", 1L, 101L, "sales_volume > 100", 100);
        tagRuleService.registerRule(rule);
        
        // Publish rule
        boolean published = tagRuleService.publishRule(rule.getRuleCode(), rule.getVersion(), "admin");
        
        assertTrue("Rule should be published successfully", published);
        
        // Verify rule status
        SkuTagRule retrieved = tagRuleService.getRule(rule.getRuleCode(), rule.getVersion());
        assertEquals("Rule should be ENABLED", TagRuleStatus.ENABLED.getCode(), 
                retrieved.getStatus());
        assertNotNull("Published time should be set", retrieved.getPublishedTime());
        assertEquals("Published user should be set", "admin", retrieved.getPublishedUser());
    }
    
    @Test
    public void testDisableRule() {
        // Register and publish rule
        SkuTagRule rule = createTestRule("DISABLE_TEST", 1L, 101L, "sales_volume > 100", 100);
        tagRuleService.registerRule(rule);
        tagRuleService.publishRule(rule.getRuleCode(), rule.getVersion(), "admin");
        
        // Disable rule
        boolean disabled = tagRuleService.disableRule(rule.getRuleCode(), rule.getVersion());
        
        assertTrue("Rule should be disabled successfully", disabled);
        
        // Verify rule status
        SkuTagRule retrieved = tagRuleService.getRule(rule.getRuleCode(), rule.getVersion());
        assertEquals("Rule should be DISABLED", TagRuleStatus.DISABLED.getCode(), 
                retrieved.getStatus());
    }
    
    @Test
    public void testExecuteRulesForSku_SingleRule() {
        Long tagGroupId = 1L;
        Long tagValueId = 101L;
        
        // Register and publish rule
        SkuTagRule rule = createTestRule("SINGLE_RULE", tagGroupId, tagValueId, 
                "sales_volume >= 500", 100);
        tagRuleService.registerRule(rule);
        tagRuleService.publishRule(rule.getRuleCode(), rule.getVersion(), "system");
        
        // Execute rule for SKU
        Map<String, Object> skuData = new HashMap<>();
        skuData.put("sku_id", "SKU-001");
        skuData.put("sales_volume", 600);
        
        SkuTagResult result = tagRuleService.executeRulesForSku("SKU-001", tagGroupId, skuData);
        
        assertNotNull("Result should not be null", result);
        assertEquals("Tag value should match rule", tagValueId, result.getTagValueId());
        assertEquals("Source should be RULE", TagSource.RULE.getCode(), result.getSource());
        assertEquals("Rule code should be recorded", rule.getRuleCode(), result.getRuleCode());
    }
    
    @Test
    public void testExecuteRulesForSku_PriorityOrdering() {
        Long tagGroupId = 1L;
        
        // Register multiple rules with different priorities
        SkuTagRule ruleS = createTestRule("RULE_S", tagGroupId, 101L, 
                "sales_volume >= 1000 && profit_rate >= 0.3", 100);
        SkuTagRule ruleA = createTestRule("RULE_A", tagGroupId, 102L, 
                "sales_volume >= 500 && profit_rate >= 0.2", 90);
        SkuTagRule ruleB = createTestRule("RULE_B", tagGroupId, 103L, 
                "sales_volume >= 100", 80);
        
        tagRuleService.registerRule(ruleS);
        tagRuleService.registerRule(ruleA);
        tagRuleService.registerRule(ruleB);
        
        tagRuleService.publishRule(ruleS.getRuleCode(), ruleS.getVersion(), "system");
        tagRuleService.publishRule(ruleA.getRuleCode(), ruleA.getVersion(), "system");
        tagRuleService.publishRule(ruleB.getRuleCode(), ruleB.getVersion(), "system");
        
        // Test SKU that matches highest priority rule (S)
        Map<String, Object> skuDataS = new HashMap<>();
        skuDataS.put("sku_id", "SKU-S");
        skuDataS.put("sales_volume", 1200);
        skuDataS.put("profit_rate", 0.35);
        
        SkuTagResult resultS = tagRuleService.executeRulesForSku("SKU-S", tagGroupId, skuDataS);
        assertEquals("Should match S rule", Long.valueOf(101L), resultS.getTagValueId());
        
        // Test SKU that matches A rule but not S
        Map<String, Object> skuDataA = new HashMap<>();
        skuDataA.put("sku_id", "SKU-A");
        skuDataA.put("sales_volume", 600);
        skuDataA.put("profit_rate", 0.25);
        
        SkuTagResult resultA = tagRuleService.executeRulesForSku("SKU-A", tagGroupId, skuDataA);
        assertEquals("Should match A rule", Long.valueOf(102L), resultA.getTagValueId());
        
        // Test SKU that only matches B rule
        Map<String, Object> skuDataB = new HashMap<>();
        skuDataB.put("sku_id", "SKU-B");
        skuDataB.put("sales_volume", 150);
        skuDataB.put("profit_rate", 0.15);
        
        SkuTagResult resultB = tagRuleService.executeRulesForSku("SKU-B", tagGroupId, skuDataB);
        assertEquals("Should match B rule", Long.valueOf(103L), resultB.getTagValueId());
    }
    
    @Test
    public void testExecuteRulesForSku_NoMatch() {
        Long tagGroupId = 1L;
        
        // Register rule
        SkuTagRule rule = createTestRule("NO_MATCH_RULE", tagGroupId, 101L, 
                "sales_volume >= 1000", 100);
        tagRuleService.registerRule(rule);
        tagRuleService.publishRule(rule.getRuleCode(), rule.getVersion(), "system");
        
        // Execute with SKU data that doesn't match
        Map<String, Object> skuData = new HashMap<>();
        skuData.put("sku_id", "SKU-NO-MATCH");
        skuData.put("sales_volume", 50);
        
        SkuTagResult result = tagRuleService.executeRulesForSku("SKU-NO-MATCH", tagGroupId, skuData);
        
        assertNull("Result should be null when no rule matches", result);
    }
    
    @Test
    public void testBatchExecuteRules() {
        Long tagGroupId = 1L;
        
        // Register and publish rules
        SkuTagRule ruleA = createTestRule("BATCH_RULE_A", tagGroupId, 101L, 
                "sales_volume >= 500", 100);
        SkuTagRule ruleB = createTestRule("BATCH_RULE_B", tagGroupId, 102L, 
                "sales_volume >= 100 && sales_volume < 500", 90);
        
        tagRuleService.registerRule(ruleA);
        tagRuleService.registerRule(ruleB);
        tagRuleService.publishRule(ruleA.getRuleCode(), ruleA.getVersion(), "system");
        tagRuleService.publishRule(ruleB.getRuleCode(), ruleB.getVersion(), "system");
        
        // Prepare batch data
        List<Map<String, Object>> batchData = new ArrayList<>();
        
        Map<String, Object> sku1 = new HashMap<>();
        sku1.put("sku_id", "SKU-BATCH-1");
        sku1.put("sales_volume", 600);
        batchData.add(sku1);
        
        Map<String, Object> sku2 = new HashMap<>();
        sku2.put("sku_id", "SKU-BATCH-2");
        sku2.put("sales_volume", 300);
        batchData.add(sku2);
        
        Map<String, Object> sku3 = new HashMap<>();
        sku3.put("sku_id", "SKU-BATCH-3");
        sku3.put("sales_volume", 50);
        batchData.add(sku3);
        
        // Execute batch
        Map<String, Integer> stats = tagRuleService.batchExecuteRules(tagGroupId, batchData);
        
        assertEquals("Total should be 3", Integer.valueOf(3), stats.get("total"));
        assertEquals("Success should be 2", Integer.valueOf(2), stats.get("success"));
        assertEquals("Failure should be 0", Integer.valueOf(0), stats.get("failure"));
        assertEquals("Skipped should be 1", Integer.valueOf(1), stats.get("skipped"));
    }
    
    @Test
    public void testBatchExecuteRules_SkipManualTags() {
        Long tagGroupId = 1L;
        String skuId = "SKU-MANUAL";
        
        // Create manual tag first
        tagService.tagSku(skuId, tagGroupId, 999L, TagSource.MANUAL,
                null, null, "admin", "Manual tag", null, null);
        
        // Register and publish rule
        SkuTagRule rule = createTestRule("SKIP_MANUAL_RULE", tagGroupId, 101L, 
                "sales_volume >= 100", 100);
        tagRuleService.registerRule(rule);
        tagRuleService.publishRule(rule.getRuleCode(), rule.getVersion(), "system");
        
        // Prepare batch data
        List<Map<String, Object>> batchData = new ArrayList<>();
        Map<String, Object> skuData = new HashMap<>();
        skuData.put("sku_id", skuId);
        skuData.put("sales_volume", 500);
        batchData.add(skuData);
        
        // Execute batch
        Map<String, Integer> stats = tagRuleService.batchExecuteRules(tagGroupId, batchData);
        
        assertEquals("Skipped should be 1 (manual tag)", Integer.valueOf(1), stats.get("skipped"));
        
        // Verify manual tag is still active
        SkuTagResult activeTag = tagService.getActiveTag(skuId, tagGroupId);
        assertEquals("Manual tag should still be active", Long.valueOf(999L), 
                activeTag.getTagValueId());
        assertEquals("Tag should still be manual", TagSource.MANUAL.getCode(), 
                activeTag.getSource());
    }
    
    @Test
    public void testPreviewRuleMatches() {
        Long tagGroupId = 1L;
        
        // Create rule
        SkuTagRule rule = createTestRule("PREVIEW_RULE", tagGroupId, 101L, 
                "sales_volume >= 500", 100);
        
        // Prepare test data
        List<Map<String, Object>> testData = new ArrayList<>();
        
        for (int i = 1; i <= 10; i++) {
            Map<String, Object> sku = new HashMap<>();
            sku.put("sku_id", "SKU-" + i);
            sku.put("sales_volume", i * 100); // 100, 200, 300, ..., 1000
            testData.add(sku);
        }
        
        // Preview matches
        List<String> matches = tagRuleService.previewRuleMatches(rule, testData);
        
        // Should match SKUs with sales_volume >= 500 (SKU-5 through SKU-10)
        assertEquals("Should match 6 SKUs", 6, matches.size());
        assertTrue("Should contain SKU-5", matches.contains("SKU-5"));
        assertTrue("Should contain SKU-10", matches.contains("SKU-10"));
        assertFalse("Should not contain SKU-4", matches.contains("SKU-4"));
    }
    
    private SkuTagRule createTestRule(String ruleCode, Long tagGroupId, Long tagValueId, 
                                      String ruleContent, int priority) {
        SkuTagRule rule = new SkuTagRule();
        rule.setRuleCode(ruleCode);
        rule.setRuleName("Rule: " + ruleCode);
        rule.setTagGroupId(tagGroupId);
        rule.setTagValueId(tagValueId);
        rule.setRuleType("JAVA_EXPR");
        rule.setRuleContent(ruleContent);
        rule.setPriority(priority);
        return rule;
    }
}
