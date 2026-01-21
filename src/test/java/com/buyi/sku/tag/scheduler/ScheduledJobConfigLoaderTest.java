package com.buyi.sku.tag.scheduler;

import com.buyi.sku.tag.model.ScheduledTagJob;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

/**
 * 调度任务JSON配置加载器单元测试
 * Scheduled Job Config Loader Unit Tests
 */
public class ScheduledJobConfigLoaderTest {
    
    private ScheduledJobConfigLoader loader;
    
    @Before
    public void setUp() {
        loader = new ScheduledJobConfigLoader();
    }
    
    @Test
    public void testLoadJobConfigFromString() {
        String jsonString = "{"
            + "\"jobCode\":\"TEST_JOB\","
            + "\"jobName\":\"测试任务\","
            + "\"tagGroupId\":1,"
            + "\"cronExpression\":\"@daily\","
            + "\"dataSourceType\":\"LOCAL\","
            + "\"batchSize\":500,"
            + "\"maxRetries\":5,"
            + "\"timeoutSeconds\":1800,"
            + "\"status\":\"ENABLED\","
            + "\"description\":\"这是一个测试任务\""
            + "}";
        
        ScheduledTagJob job = loader.loadJobConfigFromString(jsonString);
        
        assertNotNull(job);
        assertEquals("TEST_JOB", job.getJobCode());
        assertEquals("测试任务", job.getJobName());
        assertEquals(Long.valueOf(1L), job.getTagGroupId());
        assertEquals("@daily", job.getCronExpression());
        assertEquals("LOCAL", job.getDataSourceType());
        assertEquals(Integer.valueOf(500), job.getBatchSize());
        assertEquals(Integer.valueOf(5), job.getMaxRetries());
        assertEquals(Integer.valueOf(1800), job.getTimeoutSeconds());
        assertEquals("ENABLED", job.getStatus());
        assertEquals("这是一个测试任务", job.getDescription());
    }
    
    @Test
    public void testLoadJobConfigsFromString() {
        String jsonString = "["
            + "{\"jobCode\":\"JOB_1\",\"jobName\":\"任务1\",\"tagGroupId\":1,\"cronExpression\":\"@hourly\"},"
            + "{\"jobCode\":\"JOB_2\",\"jobName\":\"任务2\",\"tagGroupId\":2,\"cronExpression\":\"@daily\"},"
            + "{\"jobCode\":\"JOB_3\",\"jobName\":\"任务3\",\"tagGroupId\":3,\"cronExpression\":\"@weekly\"}"
            + "]";
        
        List<ScheduledTagJob> jobs = loader.loadJobConfigsFromString(jsonString);
        
        assertNotNull(jobs);
        assertEquals(3, jobs.size());
        
        assertEquals("JOB_1", jobs.get(0).getJobCode());
        assertEquals("@hourly", jobs.get(0).getCronExpression());
        
        assertEquals("JOB_2", jobs.get(1).getJobCode());
        assertEquals("@daily", jobs.get(1).getCronExpression());
        
        assertEquals("JOB_3", jobs.get(2).getJobCode());
        assertEquals("@weekly", jobs.get(2).getCronExpression());
    }
    
    @Test
    public void testLoadJobConfigWithDataSourceConfig() {
        String jsonString = "{"
            + "\"jobCode\":\"DATA_JOB\","
            + "\"jobName\":\"数据源任务\","
            + "\"tagGroupId\":1,"
            + "\"cronExpression\":\"@daily\","
            + "\"dataSourceType\":\"LOCAL\","
            + "\"dataSourceConfig\":\"[{\\\"sku_id\\\":\\\"SKU-001\\\",\\\"value\\\":100}]\""
            + "}";
        
        ScheduledTagJob job = loader.loadJobConfigFromString(jsonString);
        
        assertNotNull(job);
        assertEquals("DATA_JOB", job.getJobCode());
        assertEquals("LOCAL", job.getDataSourceType());
        assertNotNull(job.getDataSourceConfig());
        assertTrue(job.getDataSourceConfig().contains("SKU-001"));
    }
    
    @Test
    public void testLoadJobConfigWithDefaults() {
        // Minimal config - only required fields
        String jsonString = "{"
            + "\"jobCode\":\"MINIMAL_JOB\","
            + "\"jobName\":\"最小配置任务\","
            + "\"tagGroupId\":1"
            + "}";
        
        ScheduledTagJob job = loader.loadJobConfigFromString(jsonString);
        
        assertNotNull(job);
        assertEquals("MINIMAL_JOB", job.getJobCode());
        assertEquals("最小配置任务", job.getJobName());
        assertEquals(Long.valueOf(1L), job.getTagGroupId());
        
        // Defaults should be set
        assertEquals(Integer.valueOf(1000), job.getBatchSize());
        assertEquals(Integer.valueOf(3), job.getMaxRetries());
        assertEquals(Integer.valueOf(3600), job.getTimeoutSeconds());
        assertEquals("DISABLED", job.getStatus());
    }
    
    @Test
    public void testExportJobConfig() {
        ScheduledTagJob job = new ScheduledTagJob("EXPORT_JOB", "导出测试任务", 1L, "@daily");
        job.setDataSourceType("LOCAL");
        job.setBatchSize(500);
        job.setStatus("ENABLED");
        
        String json = loader.exportJobConfig(job);
        
        assertNotNull(json);
        assertTrue(json.contains("EXPORT_JOB"));
        assertTrue(json.contains("导出测试任务"));
        assertTrue(json.contains("@daily"));
        assertTrue(json.contains("LOCAL"));
        assertTrue(json.contains("500"));
    }
}
