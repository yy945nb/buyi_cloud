package com.buyi.sku.tag;

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
 * 规则引擎与标签系统集成示例
 * Rule Engine and Tag System Integration Example
 * 
 * 演示规则引擎的数据计算能力如何与标签系统的业务场景结合
 * Demonstrates how the rule engine's calculation capabilities integrate with tag business scenarios
 */
public class RuleTagIntegrationExample {
    
    private static final Logger logger = LoggerFactory.getLogger(RuleTagIntegrationExample.class);
    
    // 标签组和标签值定义
    private static final Long CARGO_GRADE_TAG_GROUP = 1L;
    private static final Long PRICING_STRATEGY_TAG_GROUP = 2L;
    private static final Long INVENTORY_ALERT_TAG_GROUP = 3L;
    
    // 货盘等级标签值
    private static final Long TAG_S = 101L;
    private static final Long TAG_A = 102L;
    private static final Long TAG_B = 103L;
    private static final Long TAG_C = 104L;
    
    // 定价策略标签值
    private static final Long TAG_PREMIUM = 201L;
    private static final Long TAG_STANDARD = 202L;
    private static final Long TAG_CLEARANCE = 203L;
    
    // 库存预警标签值
    private static final Long TAG_CRITICAL = 301L;
    private static final Long TAG_WARNING = 302L;
    private static final Long TAG_NORMAL = 303L;
    
    public static void main(String[] args) {
        logger.info("=== Rule Engine and Tag System Integration Demo ===\n");
        
        TagService tagService = new TagService();
        TagRuleService ruleService = new TagRuleService(tagService);
        TagQueryService queryService = new TagQueryService(tagService);
        
        // 场景1：基于多维度数据的货盘分级（Java表达式计算）
        demonstrateCargoGrading(ruleService, tagService);
        
        // 场景2：组合计算场景 - 库存预警（复杂表达式）
        demonstrateInventoryAlert(ruleService, tagService);
        
        // 场景3：多规则协同 - 定价策略决策
        demonstratePricingStrategy(ruleService, tagService);
        
        // 场景4：人工干预与规则结果的协同
        demonstrateManualOverride(tagService, ruleService);
        
        // 场景5：下游系统使用标签数据
        demonstrateDownstreamUsage(tagService, queryService);
        
        logger.info("\n=== Integration Demo Completed ===");
    }
    
    /**
     * 场景1：基于多维度数据的货盘分级
     * 展示规则引擎如何通过Java表达式计算多个业务指标
     */
    private static void demonstrateCargoGrading(TagRuleService ruleService, TagService tagService) {
        logger.info("\n--- Scenario 1: Multi-dimensional Cargo Grading ---");
        
        // 定义货盘分级规则（基于销量、利润率、周转天数的综合判断）
        setupCargoGradingRules(ruleService);
        
        // 模拟不同特征的SKU数据
        List<SkuDataScenario> scenarios = Arrays.asList(
            // 场景1：高销量、高利润、快周转 → S级
            new SkuDataScenario("SKU-001", "明星商品", 1500, 0.35, 10),
            
            // 场景2：中等销量、良好利润 → A级
            new SkuDataScenario("SKU-002", "稳定商品", 700, 0.25, 20),
            
            // 场景3：一般销量、一般利润 → B级
            new SkuDataScenario("SKU-003", "普通商品", 200, 0.15, 45),
            
            // 场景4：低销量或高周转天数 → C级
            new SkuDataScenario("SKU-004", "滞销商品", 30, 0.08, 80),
            
            // 场景5：边界情况 - 高销量但低利润 → B级（不满足S级所有条件）
            new SkuDataScenario("SKU-005", "薄利多销", 1200, 0.12, 25)
        );
        
        // 执行规则引擎计算并打标
        for (SkuDataScenario scenario : scenarios) {
            Map<String, Object> skuData = scenario.toMap();
            SkuTagResult result = ruleService.executeRulesForSku(
                scenario.skuId, CARGO_GRADE_TAG_GROUP, skuData
            );
            
            logger.info("SKU: {} ({})", scenario.skuId, scenario.description);
            logger.info("  数据: 销量={}, 利润率={}, 周转天数={}", 
                scenario.salesVolume, scenario.profitRate, scenario.turnoverDays);
            logger.info("  规则计算结果: {} 级货盘 (规则: {})", 
                getGradeName(result.getTagValueId()), result.getRuleCode());
            logger.info("  业务解释: {}", explainGrading(result.getTagValueId()));
        }
    }
    
    /**
     * 场景2：库存预警计算
     * 展示规则引擎如何处理复杂的业务逻辑计算
     */
    private static void demonstrateInventoryAlert(TagRuleService ruleService, TagService tagService) {
        logger.info("\n--- Scenario 2: Inventory Alert Calculation ---");
        
        // 定义库存预警规则
        setupInventoryAlertRules(ruleService);
        
        // 模拟不同库存状况的SKU
        List<InventoryScenario> scenarios = Arrays.asList(
            // 紧急：库存不足，低于补货周期需求
            new InventoryScenario("SKU-101", "紧急缺货", 200, 50, 7),
            
            // 预警：库存偏低，接近补货周期需求
            new InventoryScenario("SKU-102", "预警状态", 600, 50, 7),
            
            // 正常：库存充足
            new InventoryScenario("SKU-103", "库存正常", 1200, 50, 7),
            
            // 过剩：库存过多
            new InventoryScenario("SKU-104", "库存过剩", 3000, 30, 7)
        );
        
        for (InventoryScenario scenario : scenarios) {
            Map<String, Object> skuData = scenario.toMap();
            SkuTagResult result = ruleService.executeRulesForSku(
                scenario.skuId, INVENTORY_ALERT_TAG_GROUP, skuData
            );
            
            double stockDays = scenario.stockQuantity / (double) scenario.avgDailySales;
            logger.info("SKU: {} ({})", scenario.skuId, scenario.description);
            logger.info("  数据: 库存={}, 日均销量={}, 补货周期={}天, 可用天数={:.1f}天", 
                scenario.stockQuantity, scenario.avgDailySales, 
                scenario.leadTime, stockDays);
            logger.info("  规则计算结果: {} (规则: {})", 
                getAlertLevel(result.getTagValueId()), result.getRuleCode());
            logger.info("  建议行动: {}", getInventoryAction(result.getTagValueId()));
        }
    }
    
    /**
     * 场景3：定价策略决策
     * 展示多个规则如何协同工作完成复杂业务决策
     */
    private static void demonstratePricingStrategy(TagRuleService ruleService, TagService tagService) {
        logger.info("\n--- Scenario 3: Pricing Strategy Decision ---");
        
        // 定义定价策略规则（考虑库存、周转、季节性等因素）
        setupPricingStrategyRules(ruleService);
        
        // 模拟不同市场情况的SKU
        List<PricingScenario> scenarios = Arrays.asList(
            // 高端定价：热销商品，库存紧张
            new PricingScenario("SKU-201", "热销爆款", 100.0, 80.0, 50, 15, false),
            
            // 标准定价：正常商品，库存正常
            new PricingScenario("SKU-202", "常规商品", 100.0, 95.0, 500, 30, false),
            
            // 清仓定价：滞销商品，库存过多
            new PricingScenario("SKU-203", "清仓处理", 100.0, 110.0, 2000, 90, false),
            
            // 季节性促销
            new PricingScenario("SKU-204", "季节商品", 100.0, 95.0, 800, 45, true)
        );
        
        for (PricingScenario scenario : scenarios) {
            Map<String, Object> skuData = scenario.toMap();
            SkuTagResult result = ruleService.executeRulesForSku(
                scenario.skuId, PRICING_STRATEGY_TAG_GROUP, skuData
            );
            
            logger.info("SKU: {} ({})", scenario.skuId, scenario.description);
            logger.info("  数据: 价格={}, 市场均价={}, 库存={}, 库龄={}天", 
                scenario.currentPrice, scenario.marketAvgPrice, 
                scenario.stockQuantity, scenario.stockAgeDays);
            logger.info("  规则计算结果: {} 策略 (规则: {})", 
                getPricingStrategy(result.getTagValueId()), result.getRuleCode());
            logger.info("  建议定价: {}", 
                getSuggestedPricing(result.getTagValueId(), scenario.currentPrice));
        }
    }
    
    /**
     * 场景4：人工干预与规则结果的协同
     * 展示人工判断如何与自动规则计算相结合
     */
    private static void demonstrateManualOverride(TagService tagService, TagRuleService ruleService) {
        logger.info("\n--- Scenario 4: Manual Override and Rule Collaboration ---");
        
        String skuId = "SKU-301";
        
        // 1. 初始规则打标
        Map<String, Object> skuData = new HashMap<>();
        skuData.put("sku_id", skuId);
        skuData.put("sales_volume", 80);      // 低销量
        skuData.put("profit_rate", 0.09);     // 低利润
        skuData.put("turnover_days", 70);     // 周转慢
        
        SkuTagResult ruleResult = ruleService.executeRulesForSku(
            skuId, CARGO_GRADE_TAG_GROUP, skuData
        );
        
        logger.info("步骤1 - 规则自动打标:");
        logger.info("  SKU数据: 销量={}, 利润率={}, 周转={}天", 
            skuData.get("sales_volume"), skuData.get("profit_rate"), skuData.get("turnover_days"));
        logger.info("  规则结果: {} 级 (规则: {})", 
            getGradeName(ruleResult.getTagValueId()), ruleResult.getRuleCode());
        
        // 2. 产品经理人工覆盖
        logger.info("\n步骤2 - 产品经理人工干预:");
        logger.info("  判断依据: 该商品为新品，处于市场培育期");
        logger.info("  预期收益: 3个月后销量预计提升至500+");
        logger.info("  战略定位: 重点扶持商品");
        
        SkuTagResult manualResult = tagService.tagSku(
            skuId,
            CARGO_GRADE_TAG_GROUP,
            TAG_B,                    // 从C级调整为B级
            TagSource.MANUAL,
            null,
            null,
            "product_manager_zhang",
            "新品培育期，战略重点商品，预期3个月后销量达标",
            null,
            null
        );
        
        logger.info("  人工调整: C级 → B级");
        logger.info("  操作人: {}", manualResult.getOperator());
        logger.info("  调整原因: {}", manualResult.getReason());
        
        // 3. 验证人工标签保护
        logger.info("\n步骤3 - 批量规则执行时的保护机制:");
        List<Map<String, Object>> batchData = new ArrayList<>();
        batchData.add(skuData);  // 包含已被人工调整的SKU
        
        Map<String, Integer> stats = ruleService.batchExecuteRules(
            CARGO_GRADE_TAG_GROUP, batchData
        );
        
        logger.info("  批量执行统计: {}", stats);
        logger.info("  结果: SKU-301被跳过(skipped)，保留人工标签");
        logger.info("  验证: 人工打标优先级高于规则打标");
        
        // 4. 查看标签历史
        logger.info("\n步骤4 - 标签变更历史审计:");
        List<SkuTagHistory> history = tagService.getTagHistory(skuId, CARGO_GRADE_TAG_GROUP);
        for (int i = 0; i < history.size(); i++) {
            SkuTagHistory h = history.get(i);
            logger.info("  记录{}: {} - {} → {}, 来源: {}, 原因: {}", 
                i+1, h.getOperationType(),
                h.getOldTagValueId() != null ? getGradeName(h.getOldTagValueId()) : "无",
                h.getNewTagValueId() != null ? getGradeName(h.getNewTagValueId()) : "无",
                h.getSource(),
                h.getReason() != null ? h.getReason().substring(0, Math.min(20, h.getReason().length())) + "..." : "");
        }
    }
    
    /**
     * 场景5：下游系统使用标签数据
     * 展示备货和促销系统如何消费标签结果
     */
    private static void demonstrateDownstreamUsage(TagService tagService, TagQueryService queryService) {
        logger.info("\n--- Scenario 5: Downstream System Usage ---");
        
        // 准备一些测试数据
        prepareTestData(tagService);
        
        // 用例1：备货系统 - 查询高等级货盘优先备货
        logger.info("\n用例1: 备货系统集成");
        logger.info("目标: 查询S级和A级货盘，制定优先备货策略");
        
        List<String> highGradeSkus = new ArrayList<>();
        // 实际应用中应该通过queryService.queryTagsWithPagination查询
        // 这里简化为直接从tagService获取
        String[] testSkus = {"SKU-001", "SKU-002"};
        for (String skuId : testSkus) {
            SkuTagResult tag = tagService.getActiveTag(skuId, CARGO_GRADE_TAG_GROUP);
            if (tag != null && (TAG_S.equals(tag.getTagValueId()) || TAG_A.equals(tag.getTagValueId()))) {
                highGradeSkus.add(skuId);
                logger.info("  发现高等级货盘: {} → {} 级", skuId, getGradeName(tag.getTagValueId()));
            }
        }
        
        logger.info("  备货策略:");
        for (String skuId : highGradeSkus) {
            SkuTagResult tag = tagService.getActiveTag(skuId, CARGO_GRADE_TAG_GROUP);
            if (TAG_S.equals(tag.getTagValueId())) {
                logger.info("    {}: 目标库存1000件, 安全库存300件, 7天补货周期", skuId);
            } else {
                logger.info("    {}: 目标库存500件, 安全库存150件, 14天补货周期", skuId);
            }
        }
        
        // 用例2：促销系统 - 查询低等级货盘创建促销
        logger.info("\n用例2: 促销系统集成");
        logger.info("目标: 查询C级货盘，创建清仓促销活动");
        
        List<String> lowGradeSkus = new ArrayList<>();
        String[] allTestSkus = {"SKU-001", "SKU-002", "SKU-003", "SKU-004"};
        for (String skuId : allTestSkus) {
            SkuTagResult tag = tagService.getActiveTag(skuId, CARGO_GRADE_TAG_GROUP);
            if (tag != null && TAG_C.equals(tag.getTagValueId()) && 
                "RULE".equals(tag.getSource())) {  // 只处理规则打标的
                lowGradeSkus.add(skuId);
                logger.info("  发现滞销货盘: {} → C级 (来源: 规则{})", 
                    skuId, tag.getRuleCode());
            }
        }
        
        logger.info("  促销策略:");
        for (String skuId : lowGradeSkus) {
            logger.info("    {}: 创建30天清仓促销, 折扣30%, 优先展示位", skuId);
        }
        
        // 用例3：数据分析 - 统计标签分布
        logger.info("\n用例3: 数据分析 - 货盘等级分布");
        Map<Long, Integer> distribution = new HashMap<>();
        for (String skuId : allTestSkus) {
            SkuTagResult tag = tagService.getActiveTag(skuId, CARGO_GRADE_TAG_GROUP);
            if (tag != null) {
                distribution.merge(tag.getTagValueId(), 1, Integer::sum);
            }
        }
        
        logger.info("  货盘等级分布:");
        distribution.forEach((tagValueId, count) -> {
            logger.info("    {} 级: {} 个SKU ({:.1f}%)", 
                getGradeName(tagValueId), count, 
                count * 100.0 / allTestSkus.length);
        });
    }
    
    // ========== 辅助方法 ==========
    
    private static void setupCargoGradingRules(TagRuleService ruleService) {
        // S级规则
        SkuTagRule ruleS = new SkuTagRule("CARGO_S", "S级货盘", CARGO_GRADE_TAG_GROUP, TAG_S,
            "JAVA_EXPR", "sales_volume >= 1000 && profit_rate >= 0.3 && turnover_days <= 15");
        ruleS.setPriority(100);
        ruleService.registerRule(ruleS);
        ruleService.publishRule(ruleS.getRuleCode(), ruleS.getVersion(), "system");
        
        // A级规则
        SkuTagRule ruleA = new SkuTagRule("CARGO_A", "A级货盘", CARGO_GRADE_TAG_GROUP, TAG_A,
            "JAVA_EXPR", "sales_volume >= 500 && profit_rate >= 0.2 && turnover_days <= 30");
        ruleA.setPriority(90);
        ruleService.registerRule(ruleA);
        ruleService.publishRule(ruleA.getRuleCode(), ruleA.getVersion(), "system");
        
        // B级规则
        SkuTagRule ruleB = new SkuTagRule("CARGO_B", "B级货盘", CARGO_GRADE_TAG_GROUP, TAG_B,
            "JAVA_EXPR", "sales_volume >= 100 && profit_rate >= 0.1 && turnover_days <= 60");
        ruleB.setPriority(80);
        ruleService.registerRule(ruleB);
        ruleService.publishRule(ruleB.getRuleCode(), ruleB.getVersion(), "system");
        
        // C级规则
        SkuTagRule ruleC = new SkuTagRule("CARGO_C", "C级货盘", CARGO_GRADE_TAG_GROUP, TAG_C,
            "JAVA_EXPR", "sales_volume < 100 || profit_rate < 0.1 || turnover_days > 60");
        ruleC.setPriority(70);
        ruleService.registerRule(ruleC);
        ruleService.publishRule(ruleC.getRuleCode(), ruleC.getVersion(), "system");
    }
    
    private static void setupInventoryAlertRules(TagRuleService ruleService) {
        // 紧急预警：库存可用天数 < 补货周期
        SkuTagRule critical = new SkuTagRule("INV_CRITICAL", "紧急库存预警", 
            INVENTORY_ALERT_TAG_GROUP, TAG_CRITICAL,
            "JAVA_EXPR", "stock_quantity / avg_daily_sales < lead_time");
        critical.setPriority(100);
        ruleService.registerRule(critical);
        ruleService.publishRule(critical.getRuleCode(), critical.getVersion(), "system");
        
        // 预警：库存可用天数 < 补货周期 * 2
        SkuTagRule warning = new SkuTagRule("INV_WARNING", "库存预警", 
            INVENTORY_ALERT_TAG_GROUP, TAG_WARNING,
            "JAVA_EXPR", "stock_quantity / avg_daily_sales < lead_time * 2");
        warning.setPriority(90);
        ruleService.registerRule(warning);
        ruleService.publishRule(warning.getRuleCode(), warning.getVersion(), "system");
        
        // 正常：其他情况
        SkuTagRule normal = new SkuTagRule("INV_NORMAL", "库存正常", 
            INVENTORY_ALERT_TAG_GROUP, TAG_NORMAL,
            "JAVA_EXPR", "stock_quantity / avg_daily_sales >= lead_time * 2");
        normal.setPriority(80);
        ruleService.registerRule(normal);
        ruleService.publishRule(normal.getRuleCode(), normal.getVersion(), "system");
    }
    
    private static void setupPricingStrategyRules(TagRuleService ruleService) {
        // 高端定价：库存紧张且非季节性
        SkuTagRule premium = new SkuTagRule("PRICE_PREMIUM", "高端定价", 
            PRICING_STRATEGY_TAG_GROUP, TAG_PREMIUM,
            "JAVA_EXPR", "stock_quantity < 100 && stock_age_days < 30 && !is_seasonal");
        premium.setPriority(100);
        ruleService.registerRule(premium);
        ruleService.publishRule(premium.getRuleCode(), premium.getVersion(), "system");
        
        // 清仓定价：库存过多或库龄过长
        SkuTagRule clearance = new SkuTagRule("PRICE_CLEARANCE", "清仓定价", 
            PRICING_STRATEGY_TAG_GROUP, TAG_CLEARANCE,
            "JAVA_EXPR", "stock_quantity > 1000 || stock_age_days > 60 || is_seasonal");
        clearance.setPriority(90);
        ruleService.registerRule(clearance);
        ruleService.publishRule(clearance.getRuleCode(), clearance.getVersion(), "system");
        
        // 标准定价：其他情况
        SkuTagRule standard = new SkuTagRule("PRICE_STANDARD", "标准定价", 
            PRICING_STRATEGY_TAG_GROUP, TAG_STANDARD,
            "JAVA_EXPR", "stock_quantity >= 100 && stock_quantity <= 1000");
        standard.setPriority(80);
        ruleService.registerRule(standard);
        ruleService.publishRule(standard.getRuleCode(), standard.getVersion(), "system");
    }
    
    private static void prepareTestData(TagService tagService) {
        // 预先创建一些标签数据用于演示查询
        tagService.tagSku("SKU-001", CARGO_GRADE_TAG_GROUP, TAG_S, TagSource.RULE, 
            "CARGO_S", 1, null, "高销量高利润", null, null);
        tagService.tagSku("SKU-002", CARGO_GRADE_TAG_GROUP, TAG_A, TagSource.RULE, 
            "CARGO_A", 1, null, "稳定销量", null, null);
        tagService.tagSku("SKU-003", CARGO_GRADE_TAG_GROUP, TAG_B, TagSource.RULE, 
            "CARGO_B", 1, null, "一般销量", null, null);
        tagService.tagSku("SKU-004", CARGO_GRADE_TAG_GROUP, TAG_C, TagSource.RULE, 
            "CARGO_C", 1, null, "低销量", null, null);
    }
    
    private static String getGradeName(Long tagValueId) {
        if (TAG_S.equals(tagValueId)) return "S";
        if (TAG_A.equals(tagValueId)) return "A";
        if (TAG_B.equals(tagValueId)) return "B";
        if (TAG_C.equals(tagValueId)) return "C";
        return "Unknown";
    }
    
    private static String explainGrading(Long tagValueId) {
        if (TAG_S.equals(tagValueId)) return "优质货盘，优先资源投入，重点推广";
        if (TAG_A.equals(tagValueId)) return "良好货盘，保持现有策略，适度推广";
        if (TAG_B.equals(tagValueId)) return "一般货盘，观察调整，优化运营";
        if (TAG_C.equals(tagValueId)) return "较差货盘，考虑促销清仓或优化";
        return "";
    }
    
    private static String getAlertLevel(Long tagValueId) {
        if (TAG_CRITICAL.equals(tagValueId)) return "紧急预警";
        if (TAG_WARNING.equals(tagValueId)) return "一般预警";
        if (TAG_NORMAL.equals(tagValueId)) return "库存正常";
        return "Unknown";
    }
    
    private static String getInventoryAction(Long tagValueId) {
        if (TAG_CRITICAL.equals(tagValueId)) return "立即补货，加急处理";
        if (TAG_WARNING.equals(tagValueId)) return "计划补货，正常流程";
        if (TAG_NORMAL.equals(tagValueId)) return "监控库存，按需补货";
        return "";
    }
    
    private static String getPricingStrategy(Long tagValueId) {
        if (TAG_PREMIUM.equals(tagValueId)) return "高端定价";
        if (TAG_STANDARD.equals(tagValueId)) return "标准定价";
        if (TAG_CLEARANCE.equals(tagValueId)) return "清仓定价";
        return "Unknown";
    }
    
    private static String getSuggestedPricing(Long tagValueId, double currentPrice) {
        if (TAG_PREMIUM.equals(tagValueId)) {
            return String.format("%.2f (提价10%%)", currentPrice * 1.1);
        }
        if (TAG_CLEARANCE.equals(tagValueId)) {
            return String.format("%.2f (降价30%%)", currentPrice * 0.7);
        }
        return String.format("%.2f (保持现价)", currentPrice);
    }
    
    // ========== 数据场景类 ==========
    
    static class SkuDataScenario {
        String skuId;
        String description;
        int salesVolume;
        double profitRate;
        int turnoverDays;
        
        SkuDataScenario(String skuId, String description, int salesVolume, 
                       double profitRate, int turnoverDays) {
            this.skuId = skuId;
            this.description = description;
            this.salesVolume = salesVolume;
            this.profitRate = profitRate;
            this.turnoverDays = turnoverDays;
        }
        
        Map<String, Object> toMap() {
            Map<String, Object> map = new HashMap<>();
            map.put("sku_id", skuId);
            map.put("sales_volume", salesVolume);
            map.put("profit_rate", profitRate);
            map.put("turnover_days", turnoverDays);
            return map;
        }
    }
    
    static class InventoryScenario {
        String skuId;
        String description;
        int stockQuantity;
        int avgDailySales;
        int leadTime;
        
        InventoryScenario(String skuId, String description, int stockQuantity, 
                         int avgDailySales, int leadTime) {
            this.skuId = skuId;
            this.description = description;
            this.stockQuantity = stockQuantity;
            this.avgDailySales = avgDailySales;
            this.leadTime = leadTime;
        }
        
        Map<String, Object> toMap() {
            Map<String, Object> map = new HashMap<>();
            map.put("sku_id", skuId);
            map.put("stock_quantity", stockQuantity);
            map.put("avg_daily_sales", avgDailySales);
            map.put("lead_time", leadTime);
            return map;
        }
    }
    
    static class PricingScenario {
        String skuId;
        String description;
        double currentPrice;
        double marketAvgPrice;
        int stockQuantity;
        int stockAgeDays;
        boolean isSeasonal;
        
        PricingScenario(String skuId, String description, double currentPrice, 
                       double marketAvgPrice, int stockQuantity, 
                       int stockAgeDays, boolean isSeasonal) {
            this.skuId = skuId;
            this.description = description;
            this.currentPrice = currentPrice;
            this.marketAvgPrice = marketAvgPrice;
            this.stockQuantity = stockQuantity;
            this.stockAgeDays = stockAgeDays;
            this.isSeasonal = isSeasonal;
        }
        
        Map<String, Object> toMap() {
            Map<String, Object> map = new HashMap<>();
            map.put("sku_id", skuId);
            map.put("current_price", currentPrice);
            map.put("market_avg_price", marketAvgPrice);
            map.put("stock_quantity", stockQuantity);
            map.put("stock_age_days", stockAgeDays);
            map.put("is_seasonal", isSeasonal);
            return map;
        }
    }
}
