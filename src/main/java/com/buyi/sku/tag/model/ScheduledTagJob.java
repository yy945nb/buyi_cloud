package com.buyi.sku.tag.model;

import java.util.Date;
import java.util.Map;

/**
 * 标签计算调度任务配置
 * Scheduled Tag Job Configuration
 * 
 * 定义定时执行的标签计算任务
 */
public class ScheduledTagJob {
    
    // Default configuration constants
    public static final int DEFAULT_BATCH_SIZE = 1000;
    public static final int DEFAULT_MAX_RETRIES = 3;
    public static final int DEFAULT_TIMEOUT_SECONDS = 3600;
    public static final String DEFAULT_STATUS = "DISABLED";
    
    private Long id;
    private String jobCode;
    private String jobName;
    private Long tagGroupId;
    private String cronExpression;
    private String dataSourceType; // SQL, API, LOCAL
    private String dataSourceConfig; // SQL查询/API地址/数据配置
    private Map<String, Object> jobParams;
    private Integer batchSize;
    private Integer maxRetries;
    private Integer timeoutSeconds;
    private String status; // ENABLED, DISABLED, PAUSED
    private String description;
    private Date lastExecuteTime;
    private String lastExecuteStatus;
    private Long lastExecuteDuration;
    private Integer lastSuccessCount;
    private Integer lastFailureCount;
    private Date nextExecuteTime;
    private Date createTime;
    private Date updateTime;
    private String createUser;
    private String updateUser;
    
    // Constructors
    public ScheduledTagJob() {
        this.batchSize = DEFAULT_BATCH_SIZE;
        this.maxRetries = DEFAULT_MAX_RETRIES;
        this.timeoutSeconds = DEFAULT_TIMEOUT_SECONDS;
        this.status = DEFAULT_STATUS;
    }
    
    public ScheduledTagJob(String jobCode, String jobName, Long tagGroupId, String cronExpression) {
        this();
        this.jobCode = jobCode;
        this.jobName = jobName;
        this.tagGroupId = tagGroupId;
        this.cronExpression = cronExpression;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getJobCode() {
        return jobCode;
    }
    
    public void setJobCode(String jobCode) {
        this.jobCode = jobCode;
    }
    
    public String getJobName() {
        return jobName;
    }
    
    public void setJobName(String jobName) {
        this.jobName = jobName;
    }
    
    public Long getTagGroupId() {
        return tagGroupId;
    }
    
    public void setTagGroupId(Long tagGroupId) {
        this.tagGroupId = tagGroupId;
    }
    
    public String getCronExpression() {
        return cronExpression;
    }
    
    public void setCronExpression(String cronExpression) {
        this.cronExpression = cronExpression;
    }
    
    public String getDataSourceType() {
        return dataSourceType;
    }
    
    public void setDataSourceType(String dataSourceType) {
        this.dataSourceType = dataSourceType;
    }
    
    public String getDataSourceConfig() {
        return dataSourceConfig;
    }
    
    public void setDataSourceConfig(String dataSourceConfig) {
        this.dataSourceConfig = dataSourceConfig;
    }
    
    public Map<String, Object> getJobParams() {
        return jobParams;
    }
    
    public void setJobParams(Map<String, Object> jobParams) {
        this.jobParams = jobParams;
    }
    
    public Integer getBatchSize() {
        return batchSize;
    }
    
    public void setBatchSize(Integer batchSize) {
        this.batchSize = batchSize;
    }
    
    public Integer getMaxRetries() {
        return maxRetries;
    }
    
    public void setMaxRetries(Integer maxRetries) {
        this.maxRetries = maxRetries;
    }
    
    public Integer getTimeoutSeconds() {
        return timeoutSeconds;
    }
    
    public void setTimeoutSeconds(Integer timeoutSeconds) {
        this.timeoutSeconds = timeoutSeconds;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Date getLastExecuteTime() {
        return lastExecuteTime;
    }
    
    public void setLastExecuteTime(Date lastExecuteTime) {
        this.lastExecuteTime = lastExecuteTime;
    }
    
    public String getLastExecuteStatus() {
        return lastExecuteStatus;
    }
    
    public void setLastExecuteStatus(String lastExecuteStatus) {
        this.lastExecuteStatus = lastExecuteStatus;
    }
    
    public Long getLastExecuteDuration() {
        return lastExecuteDuration;
    }
    
    public void setLastExecuteDuration(Long lastExecuteDuration) {
        this.lastExecuteDuration = lastExecuteDuration;
    }
    
    public Integer getLastSuccessCount() {
        return lastSuccessCount;
    }
    
    public void setLastSuccessCount(Integer lastSuccessCount) {
        this.lastSuccessCount = lastSuccessCount;
    }
    
    public Integer getLastFailureCount() {
        return lastFailureCount;
    }
    
    public void setLastFailureCount(Integer lastFailureCount) {
        this.lastFailureCount = lastFailureCount;
    }
    
    public Date getNextExecuteTime() {
        return nextExecuteTime;
    }
    
    public void setNextExecuteTime(Date nextExecuteTime) {
        this.nextExecuteTime = nextExecuteTime;
    }
    
    public Date getCreateTime() {
        return createTime;
    }
    
    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
    
    public Date getUpdateTime() {
        return updateTime;
    }
    
    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }
    
    public String getCreateUser() {
        return createUser;
    }
    
    public void setCreateUser(String createUser) {
        this.createUser = createUser;
    }
    
    public String getUpdateUser() {
        return updateUser;
    }
    
    public void setUpdateUser(String updateUser) {
        this.updateUser = updateUser;
    }
    
    @Override
    public String toString() {
        return "ScheduledTagJob{" +
                "id=" + id +
                ", jobCode='" + jobCode + '\'' +
                ", jobName='" + jobName + '\'' +
                ", tagGroupId=" + tagGroupId +
                ", cronExpression='" + cronExpression + '\'' +
                ", status='" + status + '\'' +
                ", lastExecuteTime=" + lastExecuteTime +
                ", lastExecuteStatus='" + lastExecuteStatus + '\'' +
                '}';
    }
}
