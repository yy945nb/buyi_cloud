package com.buyi.ruleengine.enums;

/**
 * 执行状态枚举
 * Execution Status Enumeration
 */
public enum ExecutionStatus {
    /**
     * 成功
     */
    SUCCESS(1, "成功"),
    
    /**
     * 失败
     */
    FAILURE(0, "失败");
    
    private final int code;
    private final String description;
    
    ExecutionStatus(int code, String description) {
        this.code = code;
        this.description = description;
    }
    
    public int getCode() {
        return code;
    }
    
    public String getDescription() {
        return description;
    }
}
