package com.buyi.sku.tag.enums;

/**
 * 调度任务状态枚举
 * Scheduled Job Status Enum
 */
public enum JobStatus {
    
    ENABLED("ENABLED", "已启用"),
    DISABLED("DISABLED", "已禁用"),
    PAUSED("PAUSED", "已暂停");
    
    private final String code;
    private final String desc;
    
    JobStatus(String code, String desc) {
        this.code = code;
        this.desc = desc;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDesc() {
        return desc;
    }
    
    public static JobStatus fromCode(String code) {
        for (JobStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        return null;
    }
}
