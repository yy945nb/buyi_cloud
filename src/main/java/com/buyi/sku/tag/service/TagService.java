package com.buyi.sku.tag.service;

import com.buyi.sku.tag.enums.TagOperationType;
import com.buyi.sku.tag.enums.TagSource;
import com.buyi.sku.tag.model.SkuTagHistory;
import com.buyi.sku.tag.model.SkuTagResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

/**
 * SKU标签服务
 * SKU Tag Service
 * 
 * 提供标签的增删改查功能
 */
public class TagService {
    
    private static final Logger logger = LoggerFactory.getLogger(TagService.class);
    
    // In-memory storage for demonstration purposes only
    // PRODUCTION NOTE: Replace with proper database persistence layer
    // - Use ConcurrentHashMap for thread safety if keeping in-memory cache
    // - Use AtomicLong for thread-safe ID generation
    // - Implement DAO layer with JDBC/MyBatis/JPA for database operations
    // - Consider using database sequences or auto-increment for ID generation
    private Map<String, List<SkuTagResult>> tagResultCache = new HashMap<>();
    private List<SkuTagHistory> tagHistoryList = new ArrayList<>();
    private Long nextResultId = 1L;
    private Long nextHistoryId = 1L;
    
    /**
     * 为SKU打标签（创建或更新）
     * Tag a SKU (create or update)
     * 
     * @param skuId SKU编码
     * @param tagGroupId 标签组ID
     * @param tagValueId 标签值ID
     * @param source 标签来源
     * @param ruleCode 规则编码（可选）
     * @param ruleVersion 规则版本（可选）
     * @param operator 操作人（可选）
     * @param reason 原因（可选）
     * @param validFrom 有效期开始（可选）
     * @param validTo 有效期结束（可选）
     * @return 标签结果
     */
    public SkuTagResult tagSku(String skuId, Long tagGroupId, Long tagValueId, 
                               TagSource source, String ruleCode, Integer ruleVersion,
                               String operator, String reason, Date validFrom, Date validTo) {
        logger.info("Tagging SKU: skuId={}, tagGroupId={}, tagValueId={}, source={}",
                skuId, tagGroupId, tagValueId, source);
        
        // Check if tag already exists for this SKU and tag group
        SkuTagResult existingTag = getActiveTag(skuId, tagGroupId);
        
        SkuTagResult newTag = new SkuTagResult(skuId, tagGroupId, tagValueId, source.getCode());
        newTag.setId(nextResultId++);
        newTag.setRuleCode(ruleCode);
        newTag.setRuleVersion(ruleVersion);
        newTag.setOperator(operator);
        newTag.setReason(reason);
        newTag.setValidFrom(validFrom);
        newTag.setValidTo(validTo);
        newTag.setCreateTime(new Date());
        newTag.setUpdateTime(new Date());
        
        String operationType;
        Long oldTagValueId = null;
        
        if (existingTag != null) {
            // Update existing tag: deactivate old tag
            existingTag.setIsActive(0);
            existingTag.setUpdateTime(new Date());
            oldTagValueId = existingTag.getTagValueId();
            operationType = TagOperationType.UPDATE.getCode();
            logger.info("Updating existing tag: oldTagValueId={}, newTagValueId={}", 
                    oldTagValueId, tagValueId);
        } else {
            // Create new tag
            operationType = TagOperationType.CREATE.getCode();
            logger.info("Creating new tag for SKU: {}", skuId);
        }
        
        // Store new tag
        tagResultCache.computeIfAbsent(skuId, k -> new ArrayList<>()).add(newTag);
        
        // Record history
        recordHistory(skuId, tagGroupId, oldTagValueId, tagValueId, source.getCode(),
                ruleCode, ruleVersion, operator, reason, operationType);
        
        logger.info("Successfully tagged SKU: skuId={}, tagValueId={}", skuId, tagValueId);
        return newTag;
    }
    
    /**
     * 获取SKU的当前生效标签
     * Get active tag for SKU
     * 
     * @param skuId SKU编码
     * @param tagGroupId 标签组ID
     * @return 生效的标签结果，如果没有则返回null
     */
    public SkuTagResult getActiveTag(String skuId, Long tagGroupId) {
        List<SkuTagResult> tags = tagResultCache.get(skuId);
        if (tags == null) {
            return null;
        }
        
        Date now = new Date();
        return tags.stream()
                .filter(tag -> tag.getTagGroupId().equals(tagGroupId))
                .filter(tag -> tag.getIsActive() == 1)
                .filter(tag -> isValidPeriod(tag, now))
                .findFirst()
                .orElse(null);
    }
    
    /**
     * 获取SKU的所有生效标签
     * Get all active tags for SKU
     * 
     * @param skuId SKU编码
     * @return 生效的标签列表
     */
    public List<SkuTagResult> getActiveTags(String skuId) {
        List<SkuTagResult> tags = tagResultCache.get(skuId);
        if (tags == null) {
            return new ArrayList<>();
        }
        
        Date now = new Date();
        List<SkuTagResult> activeTags = new ArrayList<>();
        for (SkuTagResult tag : tags) {
            if (tag.getIsActive() == 1 && isValidPeriod(tag, now)) {
                activeTags.add(tag);
            }
        }
        return activeTags;
    }
    
    /**
     * 删除SKU的标签
     * Remove tag from SKU
     * 
     * @param skuId SKU编码
     * @param tagGroupId 标签组ID
     * @param operator 操作人
     * @param reason 原因
     * @return 是否成功删除
     */
    public boolean removeTag(String skuId, Long tagGroupId, String operator, String reason) {
        logger.info("Removing tag: skuId={}, tagGroupId={}", skuId, tagGroupId);
        
        SkuTagResult existingTag = getActiveTag(skuId, tagGroupId);
        if (existingTag == null) {
            logger.warn("No active tag found to remove: skuId={}, tagGroupId={}", skuId, tagGroupId);
            return false;
        }
        
        // Deactivate tag
        existingTag.setIsActive(0);
        existingTag.setUpdateTime(new Date());
        
        // Record history
        recordHistory(skuId, tagGroupId, existingTag.getTagValueId(), null, 
                TagSource.MANUAL.getCode(), null, null, operator, reason, 
                TagOperationType.DELETE.getCode());
        
        logger.info("Successfully removed tag: skuId={}, tagGroupId={}", skuId, tagGroupId);
        return true;
    }
    
    /**
     * 获取标签历史记录
     * Get tag history
     * 
     * @param skuId SKU编码
     * @param tagGroupId 标签组ID（可选）
     * @return 历史记录列表
     */
    public List<SkuTagHistory> getTagHistory(String skuId, Long tagGroupId) {
        List<SkuTagHistory> history = new ArrayList<>();
        for (SkuTagHistory record : tagHistoryList) {
            if (record.getSkuId().equals(skuId)) {
                if (tagGroupId == null || record.getTagGroupId().equals(tagGroupId)) {
                    history.add(record);
                }
            }
        }
        return history;
    }
    
    /**
     * 记录标签历史
     * Record tag history
     */
    private void recordHistory(String skuId, Long tagGroupId, Long oldTagValueId, 
                              Long newTagValueId, String source, String ruleCode, 
                              Integer ruleVersion, String operator, String reason, 
                              String operationType) {
        SkuTagHistory history = new SkuTagHistory(skuId, tagGroupId, oldTagValueId, 
                newTagValueId, source, operationType);
        history.setId(nextHistoryId++);
        history.setRuleCode(ruleCode);
        history.setRuleVersion(ruleVersion);
        history.setOperator(operator);
        history.setReason(reason);
        history.setCreateTime(new Date());
        
        tagHistoryList.add(history);
        logger.debug("Recorded tag history: skuId={}, operationType={}", skuId, operationType);
    }
    
    /**
     * 检查标签是否在有效期内
     * Check if tag is within valid period
     */
    private boolean isValidPeriod(SkuTagResult tag, Date now) {
        if (tag.getValidFrom() != null && now.before(tag.getValidFrom())) {
            return false;
        }
        if (tag.getValidTo() != null && now.after(tag.getValidTo())) {
            return false;
        }
        return true;
    }
    
    /**
     * 清空缓存（用于测试）
     * Clear cache (for testing)
     */
    public void clearCache() {
        tagResultCache.clear();
        tagHistoryList.clear();
        nextResultId = 1L;
        nextHistoryId = 1L;
        logger.info("Tag cache cleared");
    }
}
