package com.buyi.sku.tag.scheduler;

import com.buyi.sku.tag.model.ScheduledTagJob;
import com.buyi.sku.tag.model.SkuTagRule;
import com.buyi.sku.tag.model.TagJobExecutionLog;
import com.buyi.sku.tag.service.TagRuleService;
import com.buyi.sku.tag.service.TagService;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.*;

import static org.junit.Assert.*;

/**
 * 标签计算调度器单元测试
 * Tag Calculation Scheduler Unit Tests
 */
public class TagCalculationSchedulerTest {
    
    private TagService tagService;
    private TagRuleService ruleService;
    private TagCalculationScheduler scheduler;
    
    private static final Long CARGO_GRADE_TAG_GROUP = 1L;
    private static final Long TAG_S = 101L;
    private static final Long TAG_A = 102L;
    private static final Long TAG_B = 103L;
    private static final Long TAG_C = 104L;
    
    @Before
    public void setUp() {
        tagService = new TagService();
        ruleService = new TagRuleService(tagService);
        scheduler = new TagCalculationScheduler(ruleService);
        
        // Setup cargo grading rules
        setupCargoGradingRules();
    }
    
    @After
    public void tearDown() {
        scheduler.shutdown();
        tagService.clearCache();
        ruleService.clearCache();
    }
    
    private void setupCargoGradingRules() {
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
    
    @Test
    public void testRegisterJob() {
        ScheduledTagJob job = new ScheduledTagJob("TEST_JOB", "测试任务", CARGO_GRADE_TAG_GROUP, "@daily");
        
        Long jobId = scheduler.registerJob(job);
        
        assertNotNull(jobId);
        assertEquals(Long.valueOf(1L), jobId);
        
        ScheduledTagJob retrieved = scheduler.getJob("TEST_JOB");
        assertNotNull(retrieved);
        assertEquals("TEST_JOB", retrieved.getJobCode());
        assertEquals("测试任务", retrieved.getJobName());
        assertEquals("@daily", retrieved.getCronExpression());
    }
    
    @Test
    public void testEnableDisableJob() {
        ScheduledTagJob job = new ScheduledTagJob("TEST_JOB", "测试任务", CARGO_GRADE_TAG_GROUP, "@hourly");
        scheduler.registerJob(job);
        
        // Initially disabled
        assertEquals("DISABLED", scheduler.getJob("TEST_JOB").getStatus());
        
        // Enable job
        assertTrue(scheduler.enableJob("TEST_JOB"));
        assertEquals("ENABLED", scheduler.getJob("TEST_JOB").getStatus());
        
        // Disable job
        assertTrue(scheduler.disableJob("TEST_JOB"));
        assertEquals("DISABLED", scheduler.getJob("TEST_JOB").getStatus());
    }
    
    @Test
    public void testTriggerJobWithLocalData() {
        // Create job with local data
        String localData = "[{\"sku_id\":\"SKU-001\",\"sales_volume\":1500,\"profit_rate\":0.35,\"turnover_days\":10},"
            + "{\"sku_id\":\"SKU-002\",\"sales_volume\":30,\"profit_rate\":0.05,\"turnover_days\":90}]";
        
        ScheduledTagJob job = new ScheduledTagJob("CARGO_JOB", "货盘分级任务", CARGO_GRADE_TAG_GROUP, "@daily");
        job.setDataSourceType("LOCAL");
        job.setDataSourceConfig(localData);
        scheduler.registerJob(job);
        
        // Trigger job
        TagJobExecutionLog log = scheduler.triggerJob("CARGO_JOB");
        
        assertNotNull(log);
        assertEquals("SUCCESS", log.getStatus());
        assertEquals(Integer.valueOf(2), log.getTotalCount());
        assertEquals(Integer.valueOf(2), log.getSuccessCount());
        assertEquals(Integer.valueOf(0), log.getFailureCount());
        assertNotNull(log.getDuration());
        assertTrue(log.getDuration() >= 0);
    }
    
    @Test
    public void testTriggerJobWithCustomData() {
        ScheduledTagJob job = new ScheduledTagJob("CUSTOM_JOB", "自定义数据任务", CARGO_GRADE_TAG_GROUP, "@daily");
        scheduler.registerJob(job);
        
        // Prepare custom data
        List<Map<String, Object>> customData = new ArrayList<>();
        
        Map<String, Object> sku1 = new HashMap<>();
        sku1.put("sku_id", "CUSTOM-001");
        sku1.put("sales_volume", 2000);
        sku1.put("profit_rate", 0.4);
        sku1.put("turnover_days", 8);
        customData.add(sku1);
        
        Map<String, Object> sku2 = new HashMap<>();
        sku2.put("sku_id", "CUSTOM-002");
        sku2.put("sales_volume", 600);
        sku2.put("profit_rate", 0.22);
        sku2.put("turnover_days", 25);
        customData.add(sku2);
        
        Map<String, Object> sku3 = new HashMap<>();
        sku3.put("sku_id", "CUSTOM-003");
        sku3.put("sales_volume", 20);
        sku3.put("profit_rate", 0.05);
        sku3.put("turnover_days", 100);
        customData.add(sku3);
        
        // Trigger job with custom data
        TagJobExecutionLog log = scheduler.triggerJobWithData("CUSTOM_JOB", customData);
        
        assertNotNull(log);
        assertEquals("SUCCESS", log.getStatus());
        assertEquals(Integer.valueOf(3), log.getTotalCount());
        assertEquals(Integer.valueOf(3), log.getSuccessCount());
    }
    
    @Test
    public void testSchedulerStartStop() {
        ScheduledTagJob job = new ScheduledTagJob("SCHEDULED_JOB", "定时任务", CARGO_GRADE_TAG_GROUP, "@hourly");
        job.setStatus("ENABLED");
        scheduler.registerJob(job);
        
        // Scheduler not running initially
        assertFalse(scheduler.isRunning());
        
        // Start scheduler
        scheduler.start();
        assertTrue(scheduler.isRunning());
        
        // Job should be scheduled
        List<ScheduledTagJob> enabledJobs = scheduler.getEnabledJobs();
        assertEquals(1, enabledJobs.size());
        
        // Stop scheduler
        scheduler.stop();
        assertFalse(scheduler.isRunning());
    }
    
    @Test
    public void testGetExecutionLogs() {
        String localData = "[{\"sku_id\":\"SKU-001\",\"sales_volume\":1000,\"profit_rate\":0.3,\"turnover_days\":15}]";
        
        ScheduledTagJob job = new ScheduledTagJob("LOG_JOB", "日志测试任务", CARGO_GRADE_TAG_GROUP, "@daily");
        job.setDataSourceType("LOCAL");
        job.setDataSourceConfig(localData);
        scheduler.registerJob(job);
        
        // Execute job multiple times
        scheduler.triggerJob("LOG_JOB");
        scheduler.triggerJob("LOG_JOB");
        scheduler.triggerJob("LOG_JOB");
        
        // Get all logs
        List<TagJobExecutionLog> allLogs = scheduler.getExecutionLogs(null, 10);
        assertEquals(3, allLogs.size());
        
        // Get job-specific logs
        List<TagJobExecutionLog> jobLogs = scheduler.getExecutionLogs("LOG_JOB", 2);
        assertEquals(2, jobLogs.size());
        for (TagJobExecutionLog log : jobLogs) {
            assertEquals("LOG_JOB", log.getJobCode());
        }
    }
    
    @Test
    public void testBatchProcessing() {
        // Create job with batch size
        StringBuilder dataBuilder = new StringBuilder("[");
        for (int i = 0; i < 50; i++) {
            if (i > 0) dataBuilder.append(",");
            dataBuilder.append("{\"sku_id\":\"BATCH-").append(i)
                .append("\",\"sales_volume\":").append(100 + i * 50)
                .append(",\"profit_rate\":").append(0.1 + i * 0.01)
                .append(",\"turnover_days\":").append(60 - i)
                .append("}");
        }
        dataBuilder.append("]");
        
        ScheduledTagJob job = new ScheduledTagJob("BATCH_JOB", "批量任务", CARGO_GRADE_TAG_GROUP, "@daily");
        job.setDataSourceType("LOCAL");
        job.setDataSourceConfig(dataBuilder.toString());
        job.setBatchSize(10); // Process in batches of 10
        scheduler.registerJob(job);
        
        // Trigger job
        TagJobExecutionLog log = scheduler.triggerJob("BATCH_JOB");
        
        assertNotNull(log);
        assertEquals("SUCCESS", log.getStatus());
        assertEquals(Integer.valueOf(50), log.getTotalCount());
    }
    
    @Test
    public void testJobNotFound() {
        // Try to trigger non-existent job
        TagJobExecutionLog log = scheduler.triggerJob("NON_EXISTENT_JOB");
        assertNull(log);
        
        // Try to enable non-existent job
        assertFalse(scheduler.enableJob("NON_EXISTENT_JOB"));
        
        // Try to disable non-existent job
        assertFalse(scheduler.disableJob("NON_EXISTENT_JOB"));
    }
    
    @Test
    public void testClearCache() {
        ScheduledTagJob job = new ScheduledTagJob("CLEAR_JOB", "清理测试任务", CARGO_GRADE_TAG_GROUP, "@daily");
        scheduler.registerJob(job);
        
        assertEquals(1, scheduler.getAllJobs().size());
        
        scheduler.clearCache();
        
        assertEquals(0, scheduler.getAllJobs().size());
        assertEquals(0, scheduler.getExecutionLogs(null, 10).size());
    }
}
