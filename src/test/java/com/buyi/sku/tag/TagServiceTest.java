package com.buyi.sku.tag;

import com.buyi.sku.tag.enums.TagOperationType;
import com.buyi.sku.tag.enums.TagSource;
import com.buyi.sku.tag.model.SkuTagHistory;
import com.buyi.sku.tag.model.SkuTagResult;
import com.buyi.sku.tag.service.TagService;
import org.junit.Before;
import org.junit.Test;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

import static org.junit.Assert.*;

/**
 * SKU标签服务测试
 * SKU Tag Service Test
 */
public class TagServiceTest {
    
    private TagService tagService;
    
    @Before
    public void setUp() {
        tagService = new TagService();
    }
    
    @Test
    public void testTagSku_Create() {
        // Test creating a new tag
        String skuId = "SKU-001";
        Long tagGroupId = 1L;
        Long tagValueId = 101L;
        
        SkuTagResult result = tagService.tagSku(
                skuId, tagGroupId, tagValueId, TagSource.RULE,
                "TEST_RULE", 1, null, "Test tag creation",
                null, null
        );
        
        assertNotNull("Tag result should not be null", result);
        assertEquals("SKU ID should match", skuId, result.getSkuId());
        assertEquals("Tag group ID should match", tagGroupId, result.getTagGroupId());
        assertEquals("Tag value ID should match", tagValueId, result.getTagValueId());
        assertEquals("Source should be RULE", TagSource.RULE.getCode(), result.getSource());
        assertEquals("Tag should be active", Integer.valueOf(1), result.getIsActive());
        
        // Verify tag can be retrieved
        SkuTagResult retrieved = tagService.getActiveTag(skuId, tagGroupId);
        assertNotNull("Retrieved tag should not be null", retrieved);
        assertEquals("Retrieved tag value ID should match", tagValueId, retrieved.getTagValueId());
    }
    
    @Test
    public void testTagSku_Update() {
        // Create initial tag
        String skuId = "SKU-002";
        Long tagGroupId = 1L;
        Long oldTagValueId = 101L;
        Long newTagValueId = 102L;
        
        tagService.tagSku(skuId, tagGroupId, oldTagValueId, TagSource.RULE,
                "RULE_A", 1, null, "Initial tag", null, null);
        
        // Update tag
        SkuTagResult updated = tagService.tagSku(
                skuId, tagGroupId, newTagValueId, TagSource.RULE,
                "RULE_B", 1, null, "Updated tag", null, null
        );
        
        assertNotNull("Updated tag should not be null", updated);
        assertEquals("New tag value ID should match", newTagValueId, updated.getTagValueId());
        
        // Verify only new tag is active
        SkuTagResult activeTag = tagService.getActiveTag(skuId, tagGroupId);
        assertEquals("Active tag should have new value", newTagValueId, activeTag.getTagValueId());
        
        // Verify history is recorded
        List<SkuTagHistory> history = tagService.getTagHistory(skuId, tagGroupId);
        assertEquals("Should have 2 history records", 2, history.size());
    }
    
    @Test
    public void testTagSku_ManualOverrideRule() {
        // Create rule-based tag
        String skuId = "SKU-003";
        Long tagGroupId = 1L;
        Long ruleTagValueId = 101L;
        Long manualTagValueId = 102L;
        
        tagService.tagSku(skuId, tagGroupId, ruleTagValueId, TagSource.RULE,
                "AUTO_RULE", 1, null, "Automatic tag", null, null);
        
        // Override with manual tag
        SkuTagResult manualTag = tagService.tagSku(
                skuId, tagGroupId, manualTagValueId, TagSource.MANUAL,
                null, null, "admin", "Manual override", null, null
        );
        
        assertEquals("Manual tag should be applied", manualTagValueId, manualTag.getTagValueId());
        assertEquals("Source should be MANUAL", TagSource.MANUAL.getCode(), manualTag.getSource());
        assertEquals("Operator should be set", "admin", manualTag.getOperator());
        
        // Verify manual tag is active
        SkuTagResult activeTag = tagService.getActiveTag(skuId, tagGroupId);
        assertEquals("Active tag should be manual", manualTagValueId, activeTag.getTagValueId());
    }
    
    @Test
    public void testTagSku_WithValidityPeriod() {
        String skuId = "SKU-004";
        Long tagGroupId = 1L;
        Long tagValueId = 101L;
        
        // Create tag with future valid_from date
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, 1);
        Date futureDate = cal.getTime();
        
        tagService.tagSku(skuId, tagGroupId, tagValueId, TagSource.MANUAL,
                null, null, "admin", "Future tag", futureDate, null);
        
        // Should not be active yet
        SkuTagResult activeTag = tagService.getActiveTag(skuId, tagGroupId);
        assertNull("Tag should not be active yet", activeTag);
        
        // Create tag with past valid_to date
        cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, -1);
        Date pastDate = cal.getTime();
        
        tagService.tagSku(skuId, tagGroupId, tagValueId, TagSource.MANUAL,
                null, null, "admin", "Expired tag", null, pastDate);
        
        // Should not be active (expired)
        activeTag = tagService.getActiveTag(skuId, tagGroupId);
        assertNull("Expired tag should not be active", activeTag);
    }
    
    @Test
    public void testRemoveTag() {
        // Create tag
        String skuId = "SKU-005";
        Long tagGroupId = 1L;
        Long tagValueId = 101L;
        
        tagService.tagSku(skuId, tagGroupId, tagValueId, TagSource.MANUAL,
                null, null, "admin", "Test tag", null, null);
        
        // Remove tag
        boolean removed = tagService.removeTag(skuId, tagGroupId, "admin", "No longer needed");
        
        assertTrue("Tag should be removed successfully", removed);
        
        // Verify tag is no longer active
        SkuTagResult activeTag = tagService.getActiveTag(skuId, tagGroupId);
        assertNull("Tag should not be active after removal", activeTag);
        
        // Verify history is recorded
        List<SkuTagHistory> history = tagService.getTagHistory(skuId, tagGroupId);
        boolean hasDeleteRecord = history.stream()
                .anyMatch(h -> TagOperationType.DELETE.getCode().equals(h.getOperationType()));
        assertTrue("Should have delete history record", hasDeleteRecord);
    }
    
    @Test
    public void testGetActiveTags_MultipleTags() {
        String skuId = "SKU-006";
        Long tagGroup1 = 1L;
        Long tagGroup2 = 2L;
        Long tagValue1 = 101L;
        Long tagValue2 = 201L;
        
        // Add tags for different tag groups
        tagService.tagSku(skuId, tagGroup1, tagValue1, TagSource.RULE,
                "RULE_1", 1, null, "Tag 1", null, null);
        tagService.tagSku(skuId, tagGroup2, tagValue2, TagSource.RULE,
                "RULE_2", 1, null, "Tag 2", null, null);
        
        // Get all active tags
        List<SkuTagResult> activeTags = tagService.getActiveTags(skuId);
        
        assertEquals("Should have 2 active tags", 2, activeTags.size());
    }
    
    @Test
    public void testGetTagHistory() {
        String skuId = "SKU-007";
        Long tagGroupId = 1L;
        
        // Create multiple tag changes
        tagService.tagSku(skuId, tagGroupId, 101L, TagSource.RULE,
                "RULE_1", 1, null, "Initial", null, null);
        tagService.tagSku(skuId, tagGroupId, 102L, TagSource.RULE,
                "RULE_2", 1, null, "Update 1", null, null);
        tagService.tagSku(skuId, tagGroupId, 103L, TagSource.MANUAL,
                null, null, "admin", "Manual override", null, null);
        
        // Get history
        List<SkuTagHistory> history = tagService.getTagHistory(skuId, tagGroupId);
        
        assertEquals("Should have 3 history records", 3, history.size());
        
        // Verify history order and content
        SkuTagHistory firstRecord = history.get(0);
        assertEquals("First record should be CREATE", TagOperationType.CREATE.getCode(), 
                firstRecord.getOperationType());
        assertNull("First record should have null old value", firstRecord.getOldTagValueId());
        assertEquals("First record should have correct new value", Long.valueOf(101L), 
                firstRecord.getNewTagValueId());
        
        // Last record should be manual override
        SkuTagHistory lastRecord = history.get(history.size() - 1);
        assertEquals("Last record should be UPDATE", TagOperationType.UPDATE.getCode(), 
                lastRecord.getOperationType());
        assertEquals("Last record should be manual", TagSource.MANUAL.getCode(), 
                lastRecord.getSource());
        assertEquals("Last record should have operator", "admin", lastRecord.getOperator());
    }
}
