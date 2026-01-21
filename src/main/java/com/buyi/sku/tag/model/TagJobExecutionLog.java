package com.buyi.sku.tag.model;

import java.util.Date;
import java.util.Map;

/**
 * 调度任务执行日志
 * Scheduled Job Execution Log
 */
public class TagJobExecutionLog {
    
    private Long id;
    private Long jobId;
    private String jobCode;
    private Long tagGroupId;
    private Date startTime;
    private Date endTime;
    private Long duration; // milliseconds
    private String status; // RUNNING, SUCCESS, FAILURE, TIMEOUT
    private Integer totalCount;
    private Integer successCount;
    private Integer failureCount;
    private Integer skippedCount;
    private String errorMessage;
    private Map<String, Object> executionParams;
    private Date createTime;
    
    // Constructors
    public TagJobExecutionLog() {
        this.createTime = new Date();
    }
    
    public TagJobExecutionLog(Long jobId, String jobCode, Long tagGroupId) {
        this();
        this.jobId = jobId;
        this.jobCode = jobCode;
        this.tagGroupId = tagGroupId;
        this.startTime = new Date();
        this.status = "RUNNING";
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Long getJobId() {
        return jobId;
    }
    
    public void setJobId(Long jobId) {
        this.jobId = jobId;
    }
    
    public String getJobCode() {
        return jobCode;
    }
    
    public void setJobCode(String jobCode) {
        this.jobCode = jobCode;
    }
    
    public Long getTagGroupId() {
        return tagGroupId;
    }
    
    public void setTagGroupId(Long tagGroupId) {
        this.tagGroupId = tagGroupId;
    }
    
    public Date getStartTime() {
        return startTime;
    }
    
    public void setStartTime(Date startTime) {
        this.startTime = startTime;
    }
    
    public Date getEndTime() {
        return endTime;
    }
    
    public void setEndTime(Date endTime) {
        this.endTime = endTime;
    }
    
    public Long getDuration() {
        return duration;
    }
    
    public void setDuration(Long duration) {
        this.duration = duration;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Integer getTotalCount() {
        return totalCount;
    }
    
    public void setTotalCount(Integer totalCount) {
        this.totalCount = totalCount;
    }
    
    public Integer getSuccessCount() {
        return successCount;
    }
    
    public void setSuccessCount(Integer successCount) {
        this.successCount = successCount;
    }
    
    public Integer getFailureCount() {
        return failureCount;
    }
    
    public void setFailureCount(Integer failureCount) {
        this.failureCount = failureCount;
    }
    
    public Integer getSkippedCount() {
        return skippedCount;
    }
    
    public void setSkippedCount(Integer skippedCount) {
        this.skippedCount = skippedCount;
    }
    
    public String getErrorMessage() {
        return errorMessage;
    }
    
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
    
    public Map<String, Object> getExecutionParams() {
        return executionParams;
    }
    
    public void setExecutionParams(Map<String, Object> executionParams) {
        this.executionParams = executionParams;
    }
    
    public Date getCreateTime() {
        return createTime;
    }
    
    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
    
    /**
     * Mark execution as completed successfully
     */
    public void markSuccess(int total, int success, int failure, int skipped) {
        this.endTime = new Date();
        this.duration = this.endTime.getTime() - this.startTime.getTime();
        this.status = "SUCCESS";
        this.totalCount = total;
        this.successCount = success;
        this.failureCount = failure;
        this.skippedCount = skipped;
    }
    
    /**
     * Mark execution as failed
     */
    public void markFailure(String errorMessage) {
        this.endTime = new Date();
        this.duration = this.endTime.getTime() - this.startTime.getTime();
        this.status = "FAILURE";
        this.errorMessage = errorMessage;
    }
    
    /**
     * Mark execution as timeout
     */
    public void markTimeout() {
        this.endTime = new Date();
        this.duration = this.endTime.getTime() - this.startTime.getTime();
        this.status = "TIMEOUT";
        this.errorMessage = "Job execution timed out";
    }
    
    @Override
    public String toString() {
        return "TagJobExecutionLog{" +
                "id=" + id +
                ", jobCode='" + jobCode + '\'' +
                ", status='" + status + '\'' +
                ", totalCount=" + totalCount +
                ", successCount=" + successCount +
                ", failureCount=" + failureCount +
                ", duration=" + duration +
                '}';
    }
}
