package com.buyi.sku.tag;

import com.buyi.sku.tag.enums.TagRuleStatus;
import com.buyi.sku.tag.enums.TagSource;
import com.buyi.sku.tag.model.SkuTagHistory;
import com.buyi.sku.tag.model.SkuTagResult;
import com.buyi.sku.tag.model.SkuTagRule;
import com.buyi.sku.tag.service.TagQueryService;
import com.buyi.sku.tag.service.TagRuleService;
import com.buyi.sku.tag.service.TagService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

/**
 * SKU标签系统示例
 * SKU Tagging System Example
 * 
 * 演示如何使用SKU标签系统进行货盘等级自动分类
 * Demonstrates how to use the SKU tagging system for automatic cargo grade classification
 */
public class SkuTaggingExample {
    
    private static final Logger logger = LoggerFactory.getLogger(SkuTaggingExample.class);
    
    // 标签组ID和标签值ID (在实际场景中应从数据库查询)
    // Tag group ID and tag value IDs (should be queried from database in real scenario)
    private static final Long CARGO_GRADE_TAG_GROUP_ID = 1L;
    private static final Long TAG_VALUE_S = 101L;
    private static final Long TAG_VALUE_A = 102L;
    private static final Long TAG_VALUE_B = 103L;
    private static final Long TAG_VALUE_C = 104L;
    
    public static void main(String[] args) {
        logger.info("=== SKU Tagging System Example ===");
        
        // 1. Initialize services
        TagService tagService = new TagService();
        TagRuleService tagRuleService = new TagRuleService(tagService);
        TagQueryService queryService = new TagQueryService(tagService);
        
        // 2. Setup and publish rules
        setupCargoGradeRules(tagRuleService);
        
        // 3. Execute automatic tagging with rules
        executeAutomaticTagging(tagRuleService);
        
        // 4. Demonstrate manual tagging and override
        demonstrateManualTagging(tagService);
        
        // 5. Query and display results
        queryTagResults(tagService, queryService);
        
        // 6. Show tag history
        showTagHistory(tagService);
        
        // 7. Demonstrate batch processing
        demonstrateBatchProcessing(tagRuleService);
        
        logger.info("=== Example completed successfully ===");
    }
    
    /**
     * 设置并发布货盘等级规则
     * Setup and publish cargo grade rules
     */
    private static void setupCargoGradeRules(TagRuleService tagRuleService) {
        logger.info("\n--- Step 1: Setup Cargo Grade Rules ---");
        
        // S级货盘规则：优质货盘
        SkuTagRule ruleS = new SkuTagRule(
            "CARGO_GRADE_S_RULE",
            "货盘S级规则",
            CARGO_GRADE_TAG_GROUP_ID,
            TAG_VALUE_S,
            "JAVA_EXPR",
            "sales_volume >= 1000 && profit_rate >= 0.3 && turnover_days <= 15"
        );
        ruleS.setPriority(100);
        ruleS.setDescription("销量>=1000且利润率>=30%且周转天数<=15天");
        tagRuleService.registerRule(ruleS);
        tagRuleService.publishRule(ruleS.getRuleCode(), ruleS.getVersion(), "system");
        logger.info("Published rule: {} (priority: {})", ruleS.getRuleName(), ruleS.getPriority());
        
        // A级货盘规则：良好货盘
        SkuTagRule ruleA = new SkuTagRule(
            "CARGO_GRADE_A_RULE",
            "货盘A级规则",
            CARGO_GRADE_TAG_GROUP_ID,
            TAG_VALUE_A,
            "JAVA_EXPR",
            "sales_volume >= 500 && profit_rate >= 0.2 && turnover_days <= 30"
        );
        ruleA.setPriority(90);
        ruleA.setDescription("销量>=500且利润率>=20%且周转天数<=30天");
        tagRuleService.registerRule(ruleA);
        tagRuleService.publishRule(ruleA.getRuleCode(), ruleA.getVersion(), "system");
        logger.info("Published rule: {} (priority: {})", ruleA.getRuleName(), ruleA.getPriority());
        
        // B级货盘规则：一般货盘
        SkuTagRule ruleB = new SkuTagRule(
            "CARGO_GRADE_B_RULE",
            "货盘B级规则",
            CARGO_GRADE_TAG_GROUP_ID,
            TAG_VALUE_B,
            "JAVA_EXPR",
            "sales_volume >= 100 && profit_rate >= 0.1 && turnover_days <= 60"
        );
        ruleB.setPriority(80);
        ruleB.setDescription("销量>=100且利润率>=10%且周转天数<=60天");
        tagRuleService.registerRule(ruleB);
        tagRuleService.publishRule(ruleB.getRuleCode(), ruleB.getVersion(), "system");
        logger.info("Published rule: {} (priority: {})", ruleB.getRuleName(), ruleB.getPriority());
        
        // C级货盘规则：较差货盘
        SkuTagRule ruleC = new SkuTagRule(
            "CARGO_GRADE_C_RULE",
            "货盘C级规则",
            CARGO_GRADE_TAG_GROUP_ID,
            TAG_VALUE_C,
            "JAVA_EXPR",
            "sales_volume < 100 || profit_rate < 0.1 || turnover_days > 60"
        );
        ruleC.setPriority(70);
        ruleC.setDescription("销量<100或利润率<10%或周转天数>60天");
        tagRuleService.registerRule(ruleC);
        tagRuleService.publishRule(ruleC.getRuleCode(), ruleC.getVersion(), "system");
        logger.info("Published rule: {} (priority: {})", ruleC.getRuleName(), ruleC.getPriority());
    }
    
    /**
     * 执行自动打标
     * Execute automatic tagging
     */
    private static void executeAutomaticTagging(TagRuleService tagRuleService) {
        logger.info("\n--- Step 2: Execute Automatic Tagging ---");
        
        // SKU-001: S级货盘 (高销量、高利润、快周转)
        Map<String, Object> sku001 = new HashMap<>();
        sku001.put("sku_id", "SKU-001");
        sku001.put("sales_volume", 1500);
        sku001.put("profit_rate", 0.35);
        sku001.put("turnover_days", 12);
        
        SkuTagResult result001 = tagRuleService.executeRulesForSku(
            "SKU-001", CARGO_GRADE_TAG_GROUP_ID, sku001
        );
        logger.info("SKU-001 tagged as: {} (rule: {})", 
            getGradeName(result001.getTagValueId()), result001.getRuleCode());
        
        // SKU-002: A级货盘
        Map<String, Object> sku002 = new HashMap<>();
        sku002.put("sku_id", "SKU-002");
        sku002.put("sales_volume", 800);
        sku002.put("profit_rate", 0.25);
        sku002.put("turnover_days", 20);
        
        SkuTagResult result002 = tagRuleService.executeRulesForSku(
            "SKU-002", CARGO_GRADE_TAG_GROUP_ID, sku002
        );
        logger.info("SKU-002 tagged as: {} (rule: {})", 
            getGradeName(result002.getTagValueId()), result002.getRuleCode());
        
        // SKU-003: B级货盘
        Map<String, Object> sku003 = new HashMap<>();
        sku003.put("sku_id", "SKU-003");
        sku003.put("sales_volume", 300);
        sku003.put("profit_rate", 0.15);
        sku003.put("turnover_days", 45);
        
        SkuTagResult result003 = tagRuleService.executeRulesForSku(
            "SKU-003", CARGO_GRADE_TAG_GROUP_ID, sku003
        );
        logger.info("SKU-003 tagged as: {} (rule: {})", 
            getGradeName(result003.getTagValueId()), result003.getRuleCode());
        
        // SKU-004: C级货盘
        Map<String, Object> sku004 = new HashMap<>();
        sku004.put("sku_id", "SKU-004");
        sku004.put("sales_volume", 50);
        sku004.put("profit_rate", 0.08);
        sku004.put("turnover_days", 80);
        
        SkuTagResult result004 = tagRuleService.executeRulesForSku(
            "SKU-004", CARGO_GRADE_TAG_GROUP_ID, sku004
        );
        logger.info("SKU-004 tagged as: {} (rule: {})", 
            getGradeName(result004.getTagValueId()), result004.getRuleCode());
    }
    
    /**
     * 演示人工打标和覆盖
     * Demonstrate manual tagging and override
     */
    private static void demonstrateManualTagging(TagService tagService) {
        logger.info("\n--- Step 3: Demonstrate Manual Tagging ---");
        
        // 人工将SKU-004从C级调整为B级（考虑到其他因素）
        SkuTagResult manualTag = tagService.tagSku(
            "SKU-004",
            CARGO_GRADE_TAG_GROUP_ID,
            TAG_VALUE_B,
            TagSource.MANUAL,
            null,
            null,
            "product_manager",
            "虽然销量低，但是新品有潜力，人工调整为B级",
            null,
            null
        );
        logger.info("SKU-004 manually adjusted from C to B by: {}", manualTag.getOperator());
        logger.info("Reason: {}", manualTag.getReason());
    }
    
    /**
     * 查询标签结果
     * Query tag results
     */
    private static void queryTagResults(TagService tagService, TagQueryService queryService) {
        logger.info("\n--- Step 4: Query Tag Results ---");
        
        String[] skus = {"SKU-001", "SKU-002", "SKU-003", "SKU-004"};
        for (String skuId : skus) {
            SkuTagResult tag = queryService.querySkuTag(skuId, CARGO_GRADE_TAG_GROUP_ID);
            if (tag != null) {
                logger.info("{}: Grade={}, Source={}, UpdateTime={}", 
                    skuId, 
                    getGradeName(tag.getTagValueId()),
                    tag.getSource(),
                    tag.getUpdateTime()
                );
            }
        }
    }
    
    /**
     * 显示标签历史
     * Show tag history
     */
    private static void showTagHistory(TagService tagService) {
        logger.info("\n--- Step 5: Tag History for SKU-004 ---");
        
        List<SkuTagHistory> history = tagService.getTagHistory("SKU-004", CARGO_GRADE_TAG_GROUP_ID);
        logger.info("Total history records: {}", history.size());
        
        for (int i = 0; i < history.size(); i++) {
            SkuTagHistory h = history.get(i);
            logger.info("Record {}: {} - {} -> {}, Source: {}, Operator: {}, Reason: {}", 
                i + 1,
                h.getOperationType(),
                h.getOldTagValueId() != null ? getGradeName(h.getOldTagValueId()) : "NULL",
                h.getNewTagValueId() != null ? getGradeName(h.getNewTagValueId()) : "NULL",
                h.getSource(),
                h.getOperator(),
                h.getReason()
            );
        }
    }
    
    /**
     * 演示批量处理
     * Demonstrate batch processing
     */
    private static void demonstrateBatchProcessing(TagRuleService tagRuleService) {
        logger.info("\n--- Step 6: Batch Processing Demo ---");
        
        // 准备100个SKU的测试数据
        List<Map<String, Object>> batchData = new ArrayList<>();
        Random random = new Random(42);  // 使用固定种子以获得可重复的结果
        
        for (int i = 5; i <= 104; i++) {
            Map<String, Object> sku = new HashMap<>();
            sku.put("sku_id", "SKU-" + String.format("%03d", i));
            sku.put("sales_volume", random.nextInt(2000));
            sku.put("profit_rate", random.nextDouble() * 0.5);
            sku.put("turnover_days", random.nextInt(100));
            batchData.add(sku);
        }
        
        logger.info("Processing {} SKUs in batch...", batchData.size());
        
        // 执行批量打标
        Map<String, Integer> stats = tagRuleService.batchExecuteRules(
            CARGO_GRADE_TAG_GROUP_ID, 
            batchData
        );
        
        logger.info("Batch processing completed:");
        logger.info("  Total: {}", stats.get("total"));
        logger.info("  Success: {}", stats.get("success"));
        logger.info("  Failure: {}", stats.get("failure"));
        logger.info("  Skipped: {} (manual tags)", stats.get("skipped"));
    }
    
    /**
     * 获取等级名称
     * Get grade name
     */
    private static String getGradeName(Long tagValueId) {
        if (tagValueId.equals(TAG_VALUE_S)) return "S";
        if (tagValueId.equals(TAG_VALUE_A)) return "A";
        if (tagValueId.equals(TAG_VALUE_B)) return "B";
        if (tagValueId.equals(TAG_VALUE_C)) return "C";
        return "Unknown";
    }
}
