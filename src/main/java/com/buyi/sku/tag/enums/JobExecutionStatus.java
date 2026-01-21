package com.buyi.sku.tag.enums;

/**
 * 任务执行状态枚举
 * Job Execution Status Enum
 */
public enum JobExecutionStatus {
    
    RUNNING("RUNNING", "执行中"),
    SUCCESS("SUCCESS", "成功"),
    FAILURE("FAILURE", "失败"),
    TIMEOUT("TIMEOUT", "超时");
    
    private final String code;
    private final String desc;
    
    JobExecutionStatus(String code, String desc) {
        this.code = code;
        this.desc = desc;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDesc() {
        return desc;
    }
    
    public static JobExecutionStatus fromCode(String code) {
        for (JobExecutionStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        return null;
    }
}
