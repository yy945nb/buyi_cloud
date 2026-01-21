package com.buyi.sku.tag.scheduler;

import com.buyi.sku.tag.enums.DataSourceType;
import com.buyi.sku.tag.enums.JobExecutionStatus;
import com.buyi.sku.tag.enums.JobStatus;
import com.buyi.sku.tag.model.ScheduledTagJob;
import com.buyi.sku.tag.model.TagJobExecutionLog;
import com.buyi.sku.tag.service.TagRuleService;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.lang.reflect.Type;
import java.util.*;
import java.util.concurrent.*;

/**
 * 标签计算调度器
 * Tag Calculation Scheduler
 * 
 * 提供标签自动计算的调度功能，支持：
 * - Cron表达式定时调度
 * - 手动触发执行
 * - 批量数据处理
 * - 执行日志记录
 * - 任务生命周期管理
 */
public class TagCalculationScheduler {
    
    private static final Logger logger = LoggerFactory.getLogger(TagCalculationScheduler.class);
    
    private final TagRuleService tagRuleService;
    private final ScheduledExecutorService schedulerExecutor;
    private final ExecutorService taskExecutor;
    private final Gson gson;
    
    // Job configuration cache
    private final Map<String, ScheduledTagJob> jobCache;
    private final Map<String, ScheduledFuture<?>> scheduledTasks;
    private final List<TagJobExecutionLog> executionLogs;
    
    // ID generators
    private Long nextJobId = 1L;
    private Long nextLogId = 1L;
    
    // Configuration
    private boolean isRunning = false;
    
    public TagCalculationScheduler(TagRuleService tagRuleService) {
        this.tagRuleService = tagRuleService;
        this.schedulerExecutor = Executors.newScheduledThreadPool(2);
        this.taskExecutor = Executors.newFixedThreadPool(4);
        this.gson = new Gson();
        this.jobCache = new ConcurrentHashMap<>();
        this.scheduledTasks = new ConcurrentHashMap<>();
        this.executionLogs = Collections.synchronizedList(new ArrayList<>());
        
        logger.info("TagCalculationScheduler initialized");
    }
    
    /**
     * 启动调度器
     * Start the scheduler
     */
    public void start() {
        if (isRunning) {
            logger.warn("Scheduler is already running");
            return;
        }
        
        isRunning = true;
        logger.info("Starting TagCalculationScheduler");
        
        // Schedule enabled jobs
        for (ScheduledTagJob job : jobCache.values()) {
            if (JobStatus.ENABLED.getCode().equals(job.getStatus())) {
                scheduleJob(job);
            }
        }
        
        logger.info("TagCalculationScheduler started with {} enabled jobs", 
                scheduledTasks.size());
    }
    
    /**
     * 停止调度器
     * Stop the scheduler
     */
    public void stop() {
        if (!isRunning) {
            logger.warn("Scheduler is not running");
            return;
        }
        
        logger.info("Stopping TagCalculationScheduler");
        
        // Cancel all scheduled tasks
        for (ScheduledFuture<?> task : scheduledTasks.values()) {
            task.cancel(false);
        }
        scheduledTasks.clear();
        
        isRunning = false;
        logger.info("TagCalculationScheduler stopped");
    }
    
    /**
     * 关闭调度器
     * Shutdown the scheduler
     */
    public void shutdown() {
        stop();
        schedulerExecutor.shutdown();
        taskExecutor.shutdown();
        
        try {
            if (!schedulerExecutor.awaitTermination(30, TimeUnit.SECONDS)) {
                schedulerExecutor.shutdownNow();
            }
            if (!taskExecutor.awaitTermination(30, TimeUnit.SECONDS)) {
                taskExecutor.shutdownNow();
            }
        } catch (InterruptedException e) {
            schedulerExecutor.shutdownNow();
            taskExecutor.shutdownNow();
            Thread.currentThread().interrupt();
        }
        
        logger.info("TagCalculationScheduler shutdown completed");
    }
    
    /**
     * 注册调度任务
     * Register a scheduled job
     * 
     * @param job 调度任务配置
     * @return 任务ID
     */
    public Long registerJob(ScheduledTagJob job) {
        if (job.getId() == null) {
            job.setId(nextJobId++);
        }
        if (job.getCreateTime() == null) {
            job.setCreateTime(new Date());
        }
        job.setUpdateTime(new Date());
        
        jobCache.put(job.getJobCode(), job);
        
        logger.info("Registered job: jobCode={}, cronExpression={}", 
                job.getJobCode(), job.getCronExpression());
        
        // If scheduler is running and job is enabled, schedule it
        if (isRunning && JobStatus.ENABLED.getCode().equals(job.getStatus())) {
            scheduleJob(job);
        }
        
        return job.getId();
    }
    
    /**
     * 启用任务
     * Enable a job
     * 
     * @param jobCode 任务编码
     * @return 是否成功
     */
    public boolean enableJob(String jobCode) {
        ScheduledTagJob job = jobCache.get(jobCode);
        if (job == null) {
            logger.warn("Job not found: {}", jobCode);
            return false;
        }
        
        job.setStatus(JobStatus.ENABLED.getCode());
        job.setUpdateTime(new Date());
        
        if (isRunning) {
            scheduleJob(job);
        }
        
        logger.info("Enabled job: {}", jobCode);
        return true;
    }
    
    /**
     * 禁用任务
     * Disable a job
     * 
     * @param jobCode 任务编码
     * @return 是否成功
     */
    public boolean disableJob(String jobCode) {
        ScheduledTagJob job = jobCache.get(jobCode);
        if (job == null) {
            logger.warn("Job not found: {}", jobCode);
            return false;
        }
        
        job.setStatus(JobStatus.DISABLED.getCode());
        job.setUpdateTime(new Date());
        
        // Cancel scheduled task
        ScheduledFuture<?> task = scheduledTasks.remove(jobCode);
        if (task != null) {
            task.cancel(false);
        }
        
        logger.info("Disabled job: {}", jobCode);
        return true;
    }
    
    /**
     * 手动触发任务执行
     * Trigger a job manually
     * 
     * @param jobCode 任务编码
     * @return 执行日志
     */
    public TagJobExecutionLog triggerJob(String jobCode) {
        ScheduledTagJob job = jobCache.get(jobCode);
        if (job == null) {
            logger.warn("Job not found: {}", jobCode);
            return null;
        }
        
        logger.info("Manually triggering job: {}", jobCode);
        return executeJob(job);
    }
    
    /**
     * 手动触发任务执行（带自定义数据）
     * Trigger a job manually with custom data
     * 
     * @param jobCode 任务编码
     * @param skuDataList 自定义SKU数据
     * @return 执行日志
     */
    public TagJobExecutionLog triggerJobWithData(String jobCode, List<Map<String, Object>> skuDataList) {
        ScheduledTagJob job = jobCache.get(jobCode);
        if (job == null) {
            logger.warn("Job not found: {}", jobCode);
            return null;
        }
        
        logger.info("Manually triggering job with custom data: jobCode={}, dataCount={}", 
                jobCode, skuDataList.size());
        return executeJobWithData(job, skuDataList);
    }
    
    /**
     * 获取任务配置
     * Get job configuration
     * 
     * @param jobCode 任务编码
     * @return 任务配置
     */
    public ScheduledTagJob getJob(String jobCode) {
        return jobCache.get(jobCode);
    }
    
    /**
     * 获取所有任务
     * Get all jobs
     * 
     * @return 任务列表
     */
    public List<ScheduledTagJob> getAllJobs() {
        return new ArrayList<>(jobCache.values());
    }
    
    /**
     * 获取启用的任务
     * Get enabled jobs
     * 
     * @return 启用的任务列表
     */
    public List<ScheduledTagJob> getEnabledJobs() {
        List<ScheduledTagJob> enabledJobs = new ArrayList<>();
        for (ScheduledTagJob job : jobCache.values()) {
            if (JobStatus.ENABLED.getCode().equals(job.getStatus())) {
                enabledJobs.add(job);
            }
        }
        return enabledJobs;
    }
    
    /**
     * 获取执行日志
     * Get execution logs
     * 
     * @param jobCode 任务编码（可选）
     * @param limit 数量限制
     * @return 执行日志列表
     */
    public List<TagJobExecutionLog> getExecutionLogs(String jobCode, int limit) {
        List<TagJobExecutionLog> result = new ArrayList<>();
        
        synchronized (executionLogs) {
            for (int i = executionLogs.size() - 1; i >= 0 && result.size() < limit; i--) {
                TagJobExecutionLog log = executionLogs.get(i);
                if (jobCode == null || jobCode.equals(log.getJobCode())) {
                    result.add(log);
                }
            }
        }
        
        return result;
    }
    
    /**
     * 内部方法：调度任务
     * Internal method: Schedule a job
     */
    private void scheduleJob(ScheduledTagJob job) {
        // Cancel existing task if any
        ScheduledFuture<?> existingTask = scheduledTasks.remove(job.getJobCode());
        if (existingTask != null) {
            existingTask.cancel(false);
        }
        
        // Calculate initial delay and period from cron expression
        long[] schedule = parseCronExpression(job.getCronExpression());
        long initialDelay = schedule[0];
        long period = schedule[1];
        
        ScheduledFuture<?> task = schedulerExecutor.scheduleAtFixedRate(
                () -> executeJob(job),
                initialDelay,
                period,
                TimeUnit.MILLISECONDS
        );
        
        scheduledTasks.put(job.getJobCode(), task);
        
        // Update next execute time
        job.setNextExecuteTime(new Date(System.currentTimeMillis() + initialDelay));
        
        logger.info("Scheduled job: jobCode={}, initialDelay={}ms, period={}ms", 
                job.getJobCode(), initialDelay, period);
    }
    
    /**
     * 内部方法：执行任务
     * Internal method: Execute a job
     */
    private TagJobExecutionLog executeJob(ScheduledTagJob job) {
        logger.info("Starting job execution: jobCode={}", job.getJobCode());
        
        // Create execution log
        TagJobExecutionLog log = new TagJobExecutionLog(
                job.getId(), job.getJobCode(), job.getTagGroupId());
        log.setId(nextLogId++);
        log.setExecutionParams(job.getJobParams());
        executionLogs.add(log);
        
        // Update job status
        job.setLastExecuteTime(new Date());
        
        try {
            // Get SKU data based on data source type
            List<Map<String, Object>> skuDataList = fetchSkuData(job);
            
            if (skuDataList == null || skuDataList.isEmpty()) {
                logger.warn("No SKU data to process for job: {}", job.getJobCode());
                log.markSuccess(0, 0, 0, 0);
                updateJobStatus(job, log);
                return log;
            }
            
            // Execute with data
            return executeJobWithData(job, skuDataList, log);
            
        } catch (Exception e) {
            logger.error("Job execution failed: jobCode={}", job.getJobCode(), e);
            log.markFailure(e.getMessage());
            updateJobStatus(job, log);
            return log;
        }
    }
    
    /**
     * 内部方法：使用指定数据执行任务
     * Internal method: Execute a job with specified data
     */
    private TagJobExecutionLog executeJobWithData(ScheduledTagJob job, 
                                                   List<Map<String, Object>> skuDataList) {
        // Create execution log
        TagJobExecutionLog log = new TagJobExecutionLog(
                job.getId(), job.getJobCode(), job.getTagGroupId());
        log.setId(nextLogId++);
        log.setExecutionParams(job.getJobParams());
        executionLogs.add(log);
        
        return executeJobWithData(job, skuDataList, log);
    }
    
    /**
     * 内部方法：使用指定数据和日志执行任务
     * Internal method: Execute a job with specified data and log
     */
    private TagJobExecutionLog executeJobWithData(ScheduledTagJob job, 
                                                   List<Map<String, Object>> skuDataList,
                                                   TagJobExecutionLog log) {
        try {
            int batchSize = job.getBatchSize() != null ? job.getBatchSize() : 1000;
            int totalProcessed = 0;
            int totalSuccess = 0;
            int totalFailure = 0;
            int totalSkipped = 0;
            
            // Process in batches
            for (int i = 0; i < skuDataList.size(); i += batchSize) {
                int endIndex = Math.min(i + batchSize, skuDataList.size());
                List<Map<String, Object>> batch = skuDataList.subList(i, endIndex);
                
                logger.debug("Processing batch {}-{} of {}", 
                        i, endIndex, skuDataList.size());
                
                // Execute rules for batch
                Map<String, Integer> stats = tagRuleService.batchExecuteRules(
                        job.getTagGroupId(), batch);
                
                totalProcessed += stats.getOrDefault("total", 0);
                totalSuccess += stats.getOrDefault("success", 0);
                totalFailure += stats.getOrDefault("failure", 0);
                totalSkipped += stats.getOrDefault("skipped", 0);
            }
            
            log.markSuccess(totalProcessed, totalSuccess, totalFailure, totalSkipped);
            logger.info("Job execution completed: jobCode={}, stats={total={}, success={}, failure={}, skipped={}}", 
                    job.getJobCode(), totalProcessed, totalSuccess, totalFailure, totalSkipped);
            
        } catch (Exception e) {
            logger.error("Job execution failed: jobCode={}", job.getJobCode(), e);
            log.markFailure(e.getMessage());
        }
        
        updateJobStatus(job, log);
        return log;
    }
    
    /**
     * 内部方法：获取SKU数据
     * Internal method: Fetch SKU data
     */
    private List<Map<String, Object>> fetchSkuData(ScheduledTagJob job) {
        String dataSourceType = job.getDataSourceType();
        String dataSourceConfig = job.getDataSourceConfig();
        
        if (dataSourceType == null || dataSourceConfig == null) {
            logger.warn("No data source configured for job: {}", job.getJobCode());
            return null;
        }
        
        DataSourceType type = DataSourceType.fromCode(dataSourceType);
        if (type == null) {
            logger.warn("Unknown data source type: {}", dataSourceType);
            return null;
        }
        
        switch (type) {
            case LOCAL:
                return parseLocalData(dataSourceConfig);
            case SQL:
                // TODO: Implement SQL data source
                logger.warn("SQL data source not yet implemented");
                return null;
            case API:
                // TODO: Implement API data source
                logger.warn("API data source not yet implemented");
                return null;
            default:
                return null;
        }
    }
    
    /**
     * 内部方法：解析本地数据配置
     * Internal method: Parse local data configuration
     */
    private List<Map<String, Object>> parseLocalData(String dataSourceConfig) {
        try {
            Type listType = new TypeToken<List<Map<String, Object>>>(){}.getType();
            return gson.fromJson(dataSourceConfig, listType);
        } catch (Exception e) {
            logger.error("Failed to parse local data: {}", e.getMessage());
            return null;
        }
    }
    
    /**
     * 内部方法：更新任务状态
     * Internal method: Update job status
     */
    private void updateJobStatus(ScheduledTagJob job, TagJobExecutionLog log) {
        job.setLastExecuteTime(log.getStartTime());
        job.setLastExecuteStatus(log.getStatus());
        job.setLastExecuteDuration(log.getDuration());
        job.setLastSuccessCount(log.getSuccessCount());
        job.setLastFailureCount(log.getFailureCount());
        job.setUpdateTime(new Date());
    }
    
    /**
     * 内部方法：解析Cron表达式
     * Internal method: Parse cron expression
     * 
     * 简化实现，支持以下格式：
     * - @hourly: 每小时执行
     * - @daily: 每天执行
     * - @weekly: 每周执行
     * - 数字（毫秒）: 固定间隔执行
     */
    private long[] parseCronExpression(String cronExpression) {
        if (cronExpression == null || cronExpression.isEmpty()) {
            // Default: execute hourly
            return new long[]{60000, 3600000};
        }
        
        switch (cronExpression.toLowerCase()) {
            case "@hourly":
                return new long[]{calculateDelayToNextHour(), 3600000};
            case "@daily":
                return new long[]{calculateDelayToNextDay(), 86400000};
            case "@weekly":
                return new long[]{calculateDelayToNextWeek(), 604800000};
            case "@minutely":
                return new long[]{60000, 60000};
            default:
                try {
                    long interval = Long.parseLong(cronExpression);
                    return new long[]{interval, interval};
                } catch (NumberFormatException e) {
                    // Default to hourly
                    return new long[]{60000, 3600000};
                }
        }
    }
    
    private long calculateDelayToNextHour() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.HOUR_OF_DAY, 1);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return Math.max(1000, cal.getTimeInMillis() - System.currentTimeMillis());
    }
    
    private long calculateDelayToNextDay() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, 1);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return Math.max(1000, cal.getTimeInMillis() - System.currentTimeMillis());
    }
    
    private long calculateDelayToNextWeek() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.WEEK_OF_YEAR, 1);
        cal.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return Math.max(1000, cal.getTimeInMillis() - System.currentTimeMillis());
    }
    
    /**
     * 检查调度器是否运行中
     * Check if scheduler is running
     */
    public boolean isRunning() {
        return isRunning;
    }
    
    /**
     * 清空缓存（用于测试）
     * Clear cache (for testing)
     */
    public void clearCache() {
        stop();
        jobCache.clear();
        executionLogs.clear();
        nextJobId = 1L;
        nextLogId = 1L;
        logger.info("Scheduler cache cleared");
    }
}
