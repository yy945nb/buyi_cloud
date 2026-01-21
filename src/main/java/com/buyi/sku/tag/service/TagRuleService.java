package com.buyi.sku.tag.service;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.executor.JavaExpressionExecutor;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import com.buyi.ruleengine.service.RuleEngine;
import com.buyi.sku.tag.enums.TagRuleStatus;
import com.buyi.sku.tag.enums.TagSource;
import com.buyi.sku.tag.model.SkuTagResult;
import com.buyi.sku.tag.model.SkuTagRule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;
import java.util.stream.Collectors;

/**
 * SKU标签规则服务
 * SKU Tag Rule Service
 * 
 * 提供基于规则的自动打标功能
 */
public class TagRuleService {
    
    private static final Logger logger = LoggerFactory.getLogger(TagRuleService.class);
    
    private final TagService tagService;
    private final RuleEngine ruleEngine;
    
    // In-memory storage for demonstration (in production, use database)
    private Map<String, SkuTagRule> ruleCache = new HashMap<>();
    private Long nextRuleId = 1L;
    
    public TagRuleService(TagService tagService) {
        this.tagService = tagService;
        this.ruleEngine = new RuleEngine();
        
        // Register default executors
        this.ruleEngine.registerExecutor(new JavaExpressionExecutor());
        
        logger.info("TagRuleService initialized");
    }
    
    /**
     * 注册标签规则
     * Register tag rule
     * 
     * @param rule 标签规则
     * @return 规则ID
     */
    public Long registerRule(SkuTagRule rule) {
        if (rule.getId() == null) {
            rule.setId(nextRuleId++);
        }
        if (rule.getVersion() == null) {
            rule.setVersion(1);
        }
        if (rule.getStatus() == null) {
            rule.setStatus(TagRuleStatus.DRAFT.getCode());
        }
        
        String cacheKey = rule.getRuleCode() + "_v" + rule.getVersion();
        ruleCache.put(cacheKey, rule);
        
        logger.info("Registered tag rule: ruleCode={}, version={}", 
                rule.getRuleCode(), rule.getVersion());
        return rule.getId();
    }
    
    /**
     * 发布规则（启用规则）
     * Publish rule (enable rule)
     * 
     * @param ruleCode 规则编码
     * @param version 规则版本
     * @param publishedUser 发布人
     * @return 是否成功
     */
    public boolean publishRule(String ruleCode, Integer version, String publishedUser) {
        String cacheKey = ruleCode + "_v" + version;
        SkuTagRule rule = ruleCache.get(cacheKey);
        
        if (rule == null) {
            logger.warn("Rule not found: ruleCode={}, version={}", ruleCode, version);
            return false;
        }
        
        rule.setStatus(TagRuleStatus.ENABLED.getCode());
        rule.setPublishedTime(new Date());
        rule.setPublishedUser(publishedUser);
        
        logger.info("Published tag rule: ruleCode={}, version={}", ruleCode, version);
        return true;
    }
    
    /**
     * 禁用规则
     * Disable rule
     * 
     * @param ruleCode 规则编码
     * @param version 规则版本
     * @return 是否成功
     */
    public boolean disableRule(String ruleCode, Integer version) {
        String cacheKey = ruleCode + "_v" + version;
        SkuTagRule rule = ruleCache.get(cacheKey);
        
        if (rule == null) {
            logger.warn("Rule not found: ruleCode={}, version={}", ruleCode, version);
            return false;
        }
        
        rule.setStatus(TagRuleStatus.DISABLED.getCode());
        logger.info("Disabled tag rule: ruleCode={}, version={}", ruleCode, version);
        return true;
    }
    
    /**
     * 获取标签组的所有启用规则（按优先级排序）
     * Get all enabled rules for tag group (sorted by priority)
     * 
     * @param tagGroupId 标签组ID
     * @return 规则列表
     */
    public List<SkuTagRule> getEnabledRules(Long tagGroupId) {
        return ruleCache.values().stream()
                .filter(rule -> rule.getTagGroupId().equals(tagGroupId))
                .filter(rule -> TagRuleStatus.ENABLED.getCode().equals(rule.getStatus()))
                .sorted(Comparator.comparing(SkuTagRule::getPriority, Comparator.reverseOrder()))
                .collect(Collectors.toList());
    }
    
    /**
     * 执行单个SKU的规则打标
     * Execute rules for a single SKU
     * 
     * @param skuId SKU编码
     * @param tagGroupId 标签组ID
     * @param skuData SKU数据（用于规则计算）
     * @return 打标结果
     */
    public SkuTagResult executeRulesForSku(String skuId, Long tagGroupId, Map<String, Object> skuData) {
        logger.info("Executing tag rules for SKU: skuId={}, tagGroupId={}", skuId, tagGroupId);
        
        List<SkuTagRule> rules = getEnabledRules(tagGroupId);
        if (rules.isEmpty()) {
            logger.warn("No enabled rules found for tag group: {}", tagGroupId);
            return null;
        }
        
        // Try rules in priority order until one matches
        for (SkuTagRule tagRule : rules) {
            logger.debug("Evaluating rule: ruleCode={}, priority={}", 
                    tagRule.getRuleCode(), tagRule.getPriority());
            
            if (evaluateRule(tagRule, skuData)) {
                logger.info("Rule matched: ruleCode={}, applying tag value: {}", 
                        tagRule.getRuleCode(), tagRule.getTagValueId());
                
                // Apply the tag
                SkuTagResult result = tagService.tagSku(
                        skuId, 
                        tagGroupId, 
                        tagRule.getTagValueId(),
                        TagSource.RULE,
                        tagRule.getRuleCode(),
                        tagRule.getVersion(),
                        null, // No operator for rule-based tagging
                        "Rule: " + tagRule.getRuleName(),
                        null, // No validity period by default
                        null
                );
                
                return result;
            }
        }
        
        logger.info("No matching rule found for SKU: skuId={}, tagGroupId={}", skuId, tagGroupId);
        return null;
    }
    
    /**
     * 批量执行规则打标
     * Batch execute rules for multiple SKUs
     * 
     * @param tagGroupId 标签组ID
     * @param skuDataList SKU数据列表
     * @return 打标结果统计
     */
    public Map<String, Integer> batchExecuteRules(Long tagGroupId, List<Map<String, Object>> skuDataList) {
        logger.info("Starting batch rule execution: tagGroupId={}, skuCount={}", 
                tagGroupId, skuDataList.size());
        
        int successCount = 0;
        int failureCount = 0;
        int skippedCount = 0;
        
        for (Map<String, Object> skuData : skuDataList) {
            String skuId = (String) skuData.get("sku_id");
            if (skuId == null) {
                logger.warn("SKU data missing sku_id field, skipping");
                skippedCount++;
                continue;
            }
            
            try {
                // Check if manual tag exists (manual overrides rule)
                SkuTagResult existingTag = tagService.getActiveTag(skuId, tagGroupId);
                if (existingTag != null && TagSource.MANUAL.getCode().equals(existingTag.getSource())) {
                    logger.debug("SKU has manual tag, skipping rule execution: skuId={}", skuId);
                    skippedCount++;
                    continue;
                }
                
                SkuTagResult result = executeRulesForSku(skuId, tagGroupId, skuData);
                if (result != null) {
                    successCount++;
                } else {
                    skippedCount++;
                }
            } catch (Exception e) {
                logger.error("Failed to execute rules for SKU: skuId={}", skuId, e);
                failureCount++;
            }
        }
        
        Map<String, Integer> stats = new HashMap<>();
        stats.put("total", skuDataList.size());
        stats.put("success", successCount);
        stats.put("failure", failureCount);
        stats.put("skipped", skippedCount);
        
        logger.info("Batch rule execution completed: stats={}", stats);
        return stats;
    }
    
    /**
     * 预览规则命中的SKU
     * Preview SKUs that match the rule
     * 
     * @param tagRule 标签规则
     * @param skuDataList SKU数据列表
     * @return 命中的SKU列表
     */
    public List<String> previewRuleMatches(SkuTagRule tagRule, List<Map<String, Object>> skuDataList) {
        logger.info("Previewing rule matches: ruleCode={}", tagRule.getRuleCode());
        
        List<String> matchedSkus = new ArrayList<>();
        for (Map<String, Object> skuData : skuDataList) {
            String skuId = (String) skuData.get("sku_id");
            if (skuId != null && evaluateRule(tagRule, skuData)) {
                matchedSkus.add(skuId);
            }
        }
        
        logger.info("Rule preview completed: ruleCode={}, matchedCount={}", 
                tagRule.getRuleCode(), matchedSkus.size());
        return matchedSkus;
    }
    
    /**
     * 评估规则是否匹配
     * Evaluate if rule matches
     * 
     * @param tagRule 标签规则
     * @param skuData SKU数据
     * @return 是否匹配
     */
    private boolean evaluateRule(SkuTagRule tagRule, Map<String, Object> skuData) {
        try {
            // Convert tag rule to rule config
            RuleConfig ruleConfig = new RuleConfig();
            ruleConfig.setRuleCode(tagRule.getRuleCode());
            ruleConfig.setRuleName(tagRule.getRuleName());
            ruleConfig.setRuleType(RuleType.valueOf(tagRule.getRuleType()));
            ruleConfig.setRuleContent(tagRule.getRuleContent());
            ruleConfig.setRuleParams(tagRule.getRuleParams());
            
            // Execute rule
            RuleContext context = new RuleContext(skuData);
            context = ruleEngine.executeRule(ruleConfig, context);
            
            // Check result
            if (context.isSuccess() && context.getResult() != null) {
                Object result = context.getResult();
                // If result is boolean, return it; otherwise consider it matched if not null
                if (result instanceof Boolean) {
                    return (Boolean) result;
                }
                return true;
            }
            
            return false;
        } catch (Exception e) {
            logger.error("Failed to evaluate rule: ruleCode={}", tagRule.getRuleCode(), e);
            return false;
        }
    }
    
    /**
     * 获取规则
     * Get rule
     * 
     * @param ruleCode 规则编码
     * @param version 规则版本
     * @return 规则
     */
    public SkuTagRule getRule(String ruleCode, Integer version) {
        String cacheKey = ruleCode + "_v" + version;
        return ruleCache.get(cacheKey);
    }
    
    /**
     * 清空缓存（用于测试）
     * Clear cache (for testing)
     */
    public void clearCache() {
        ruleCache.clear();
        nextRuleId = 1L;
        logger.info("Tag rule cache cleared");
    }
}
