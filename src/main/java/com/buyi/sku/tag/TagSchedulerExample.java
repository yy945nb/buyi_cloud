package com.buyi.sku.tag;

import com.buyi.sku.tag.model.ScheduledTagJob;
import com.buyi.sku.tag.model.SkuTagRule;
import com.buyi.sku.tag.model.TagJobExecutionLog;
import com.buyi.sku.tag.scheduler.ScheduledJobConfigLoader;
import com.buyi.sku.tag.scheduler.TagCalculationScheduler;
import com.buyi.sku.tag.service.TagRuleConfigLoader;
import com.buyi.sku.tag.service.TagRuleService;
import com.buyi.sku.tag.service.TagService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

/**
 * 规则解析引擎和调度任务完整示例
 * Rule Parsing Engine and Scheduling Task Complete Example
 * 
 * 演示如何使用规则引擎配置JSON、调度任务和标签业务体系
 * 实现标签的自定义和自动计算
 */
public class TagSchedulerExample {
    
    private static final Logger logger = LoggerFactory.getLogger(TagSchedulerExample.class);
    
    // 标签组定义
    private static final Long CARGO_GRADE_TAG_GROUP = 1L;
    private static final Long PRICING_STRATEGY_TAG_GROUP = 2L;
    private static final Long INVENTORY_ALERT_TAG_GROUP = 3L;
    
    // 货盘等级标签值
    private static final Long TAG_S = 101L;
    private static final Long TAG_A = 102L;
    private static final Long TAG_B = 103L;
    private static final Long TAG_C = 104L;
    
    // 库存预警标签值
    private static final Long TAG_CRITICAL = 301L;
    private static final Long TAG_WARNING = 302L;
    private static final Long TAG_NORMAL = 303L;
    
    public static void main(String[] args) {
        logger.info("=== 规则解析引擎和调度任务示例 ===\n");
        
        // 1. 初始化服务
        TagService tagService = new TagService();
        TagRuleService ruleService = new TagRuleService(tagService);
        TagCalculationScheduler scheduler = new TagCalculationScheduler(ruleService);
        
        try {
            // 2. 演示从JSON配置加载规则
            demonstrateRuleConfigLoading(ruleService);
            
            // 3. 演示从JSON配置加载调度任务
            demonstrateJobConfigLoading(scheduler);
            
            // 4. 演示手动触发任务执行
            demonstrateManualExecution(scheduler);
            
            // 5. 演示调度器生命周期管理
            demonstrateSchedulerLifecycle(scheduler);
            
            // 6. 演示执行日志查询
            demonstrateExecutionLogs(scheduler);
            
        } finally {
            // 清理资源
            scheduler.shutdown();
        }
        
        logger.info("\n=== 示例完成 ===");
    }
    
    /**
     * 演示从JSON配置加载规则
     */
    private static void demonstrateRuleConfigLoading(TagRuleService ruleService) {
        logger.info("\n--- 1. 从JSON配置加载标签规则 ---");
        
        // 示例：从JSON字符串加载规则
        TagRuleConfigLoader ruleLoader = new TagRuleConfigLoader();
        
        String cargoGradeRulesJson = "["
            + "{\"ruleCode\":\"CARGO_S\",\"ruleName\":\"S级货盘\",\"tagGroupId\":1,\"tagValueId\":101,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"sales_volume >= 1000 && profit_rate >= 0.3 && turnover_days <= 15\",\"priority\":100,\"status\":\"ENABLED\"},"
            + "{\"ruleCode\":\"CARGO_A\",\"ruleName\":\"A级货盘\",\"tagGroupId\":1,\"tagValueId\":102,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"sales_volume >= 500 && profit_rate >= 0.2 && turnover_days <= 30\",\"priority\":90,\"status\":\"ENABLED\"},"
            + "{\"ruleCode\":\"CARGO_B\",\"ruleName\":\"B级货盘\",\"tagGroupId\":1,\"tagValueId\":103,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"sales_volume >= 100 && profit_rate >= 0.1 && turnover_days <= 60\",\"priority\":80,\"status\":\"ENABLED\"},"
            + "{\"ruleCode\":\"CARGO_C\",\"ruleName\":\"C级货盘\",\"tagGroupId\":1,\"tagValueId\":104,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"sales_volume < 100 || profit_rate < 0.1 || turnover_days > 60\",\"priority\":70,\"status\":\"ENABLED\"}"
            + "]";
        
        List<SkuTagRule> rules = ruleLoader.loadRuleConfigsFromString(cargoGradeRulesJson);
        logger.info("从JSON字符串加载了 {} 条规则", rules.size());
        
        // 注册并发布规则
        for (SkuTagRule rule : rules) {
            ruleService.registerRule(rule);
            ruleService.publishRule(rule.getRuleCode(), rule.getVersion(), "system");
            logger.info("  已注册规则: {} (优先级: {})", rule.getRuleCode(), rule.getPriority());
        }
        
        // 加载库存预警规则
        String inventoryRulesJson = "["
            + "{\"ruleCode\":\"INV_CRITICAL\",\"ruleName\":\"紧急库存预警\",\"tagGroupId\":3,\"tagValueId\":301,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"stock_quantity / avg_daily_sales < lead_time\",\"priority\":100,\"status\":\"ENABLED\"},"
            + "{\"ruleCode\":\"INV_WARNING\",\"ruleName\":\"库存预警\",\"tagGroupId\":3,\"tagValueId\":302,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"stock_quantity / avg_daily_sales < lead_time * 2\",\"priority\":90,\"status\":\"ENABLED\"},"
            + "{\"ruleCode\":\"INV_NORMAL\",\"ruleName\":\"库存正常\",\"tagGroupId\":3,\"tagValueId\":303,"
            + "\"ruleType\":\"JAVA_EXPR\",\"ruleContent\":\"stock_quantity / avg_daily_sales >= lead_time * 2\",\"priority\":80,\"status\":\"ENABLED\"}"
            + "]";
        
        rules = ruleLoader.loadRuleConfigsFromString(inventoryRulesJson);
        for (SkuTagRule rule : rules) {
            ruleService.registerRule(rule);
            ruleService.publishRule(rule.getRuleCode(), rule.getVersion(), "system");
        }
        logger.info("从JSON字符串加载并注册了库存预警规则");
    }
    
    /**
     * 演示从JSON配置加载调度任务
     */
    private static void demonstrateJobConfigLoading(TagCalculationScheduler scheduler) {
        logger.info("\n--- 2. 从JSON配置加载调度任务 ---");
        
        ScheduledJobConfigLoader jobLoader = new ScheduledJobConfigLoader();
        
        // 从JSON字符串加载货盘分级任务
        String cargoJobJson = "{"
            + "\"jobCode\":\"CARGO_GRADE_DAILY\","
            + "\"jobName\":\"货盘等级每日计算\","
            + "\"tagGroupId\":1,"
            + "\"cronExpression\":\"@daily\","
            + "\"dataSourceType\":\"LOCAL\","
            + "\"dataSourceConfig\":\"[{\\\"sku_id\\\":\\\"SKU-001\\\",\\\"sales_volume\\\":1500,\\\"profit_rate\\\":0.35,\\\"turnover_days\\\":10},"
            + "{\\\"sku_id\\\":\\\"SKU-002\\\",\\\"sales_volume\\\":700,\\\"profit_rate\\\":0.25,\\\"turnover_days\\\":20},"
            + "{\\\"sku_id\\\":\\\"SKU-003\\\",\\\"sales_volume\\\":200,\\\"profit_rate\\\":0.15,\\\"turnover_days\\\":45},"
            + "{\\\"sku_id\\\":\\\"SKU-004\\\",\\\"sales_volume\\\":30,\\\"profit_rate\\\":0.08,\\\"turnover_days\\\":80}]\","
            + "\"batchSize\":1000,"
            + "\"status\":\"DISABLED\","
            + "\"description\":\"每天凌晨执行货盘等级计算\""
            + "}";
        
        ScheduledTagJob cargoJob = jobLoader.loadJobConfigFromString(cargoJobJson);
        scheduler.registerJob(cargoJob);
        logger.info("已注册调度任务: {} (Cron: {})", cargoJob.getJobCode(), cargoJob.getCronExpression());
        
        // 从JSON字符串加载库存预警任务
        String inventoryJobJson = "{"
            + "\"jobCode\":\"INVENTORY_ALERT_HOURLY\","
            + "\"jobName\":\"库存预警每小时计算\","
            + "\"tagGroupId\":3,"
            + "\"cronExpression\":\"@hourly\","
            + "\"dataSourceType\":\"LOCAL\","
            + "\"dataSourceConfig\":\"[{\\\"sku_id\\\":\\\"SKU-101\\\",\\\"stock_quantity\\\":200,\\\"avg_daily_sales\\\":50,\\\"lead_time\\\":7},"
            + "{\\\"sku_id\\\":\\\"SKU-102\\\",\\\"stock_quantity\\\":600,\\\"avg_daily_sales\\\":50,\\\"lead_time\\\":7},"
            + "{\\\"sku_id\\\":\\\"SKU-103\\\",\\\"stock_quantity\\\":1200,\\\"avg_daily_sales\\\":50,\\\"lead_time\\\":7}]\","
            + "\"batchSize\":500,"
            + "\"status\":\"DISABLED\","
            + "\"description\":\"每小时执行库存预警计算\""
            + "}";
        
        ScheduledTagJob inventoryJob = jobLoader.loadJobConfigFromString(inventoryJobJson);
        scheduler.registerJob(inventoryJob);
        logger.info("已注册调度任务: {} (Cron: {})", inventoryJob.getJobCode(), inventoryJob.getCronExpression());
        
        // 显示所有注册的任务
        logger.info("当前已注册 {} 个调度任务", scheduler.getAllJobs().size());
    }
    
    /**
     * 演示手动触发任务执行
     */
    private static void demonstrateManualExecution(TagCalculationScheduler scheduler) {
        logger.info("\n--- 3. 手动触发任务执行 ---");
        
        // 手动触发货盘分级任务
        logger.info("手动触发 CARGO_GRADE_DAILY 任务...");
        TagJobExecutionLog log1 = scheduler.triggerJob("CARGO_GRADE_DAILY");
        
        if (log1 != null) {
            logger.info("执行完成:");
            logger.info("  状态: {}", log1.getStatus());
            logger.info("  总数: {}", log1.getTotalCount());
            logger.info("  成功: {}", log1.getSuccessCount());
            logger.info("  失败: {}", log1.getFailureCount());
            logger.info("  跳过: {}", log1.getSkippedCount());
            logger.info("  耗时: {}ms", log1.getDuration());
        }
        
        // 手动触发库存预警任务
        logger.info("\n手动触发 INVENTORY_ALERT_HOURLY 任务...");
        TagJobExecutionLog log2 = scheduler.triggerJob("INVENTORY_ALERT_HOURLY");
        
        if (log2 != null) {
            logger.info("执行完成:");
            logger.info("  状态: {}", log2.getStatus());
            logger.info("  总数: {}", log2.getTotalCount());
            logger.info("  成功: {}", log2.getSuccessCount());
            logger.info("  耗时: {}ms", log2.getDuration());
        }
        
        // 使用自定义数据触发任务
        logger.info("\n使用自定义数据触发任务...");
        List<Map<String, Object>> customData = new ArrayList<>();
        
        Map<String, Object> sku1 = new HashMap<>();
        sku1.put("sku_id", "CUSTOM-001");
        sku1.put("sales_volume", 2000);
        sku1.put("profit_rate", 0.4);
        sku1.put("turnover_days", 8);
        customData.add(sku1);
        
        Map<String, Object> sku2 = new HashMap<>();
        sku2.put("sku_id", "CUSTOM-002");
        sku2.put("sales_volume", 50);
        sku2.put("profit_rate", 0.05);
        sku2.put("turnover_days", 90);
        customData.add(sku2);
        
        TagJobExecutionLog log3 = scheduler.triggerJobWithData("CARGO_GRADE_DAILY", customData);
        if (log3 != null) {
            logger.info("自定义数据执行完成: 成功 {}, 失败 {}", 
                    log3.getSuccessCount(), log3.getFailureCount());
        }
    }
    
    /**
     * 演示调度器生命周期管理
     */
    private static void demonstrateSchedulerLifecycle(TagCalculationScheduler scheduler) {
        logger.info("\n--- 4. 调度器生命周期管理 ---");
        
        // 启用任务
        logger.info("启用 CARGO_GRADE_DAILY 任务...");
        scheduler.enableJob("CARGO_GRADE_DAILY");
        
        // 启动调度器
        logger.info("启动调度器...");
        scheduler.start();
        logger.info("调度器运行状态: {}", scheduler.isRunning());
        
        // 检查启用的任务
        List<ScheduledTagJob> enabledJobs = scheduler.getEnabledJobs();
        logger.info("当前启用的任务数: {}", enabledJobs.size());
        for (ScheduledTagJob job : enabledJobs) {
            logger.info("  - {} (下次执行: {})", job.getJobCode(), job.getNextExecuteTime());
        }
        
        // 禁用任务
        logger.info("\n禁用 CARGO_GRADE_DAILY 任务...");
        scheduler.disableJob("CARGO_GRADE_DAILY");
        
        // 停止调度器
        logger.info("停止调度器...");
        scheduler.stop();
        logger.info("调度器运行状态: {}", scheduler.isRunning());
    }
    
    /**
     * 演示执行日志查询
     */
    private static void demonstrateExecutionLogs(TagCalculationScheduler scheduler) {
        logger.info("\n--- 5. 执行日志查询 ---");
        
        // 查询所有执行日志
        List<TagJobExecutionLog> allLogs = scheduler.getExecutionLogs(null, 10);
        logger.info("最近 {} 条执行日志:", allLogs.size());
        
        for (TagJobExecutionLog log : allLogs) {
            logger.info("  [{}] {} - 状态: {}, 成功/失败: {}/{}, 耗时: {}ms",
                    log.getJobCode(),
                    log.getStartTime(),
                    log.getStatus(),
                    log.getSuccessCount(),
                    log.getFailureCount(),
                    log.getDuration());
        }
        
        // 查询特定任务的执行日志
        logger.info("\nCARGO_GRADE_DAILY 任务的执行日志:");
        List<TagJobExecutionLog> cargoLogs = scheduler.getExecutionLogs("CARGO_GRADE_DAILY", 5);
        for (TagJobExecutionLog log : cargoLogs) {
            logger.info("  执行时间: {}, 状态: {}, 处理数: {}", 
                    log.getStartTime(), log.getStatus(), log.getTotalCount());
        }
    }
}
