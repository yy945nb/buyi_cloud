package com.buyi.ruleengine.enums;

/**
 * 规则类型枚举
 * Rule Type Enumeration
 */
public enum RuleType {
    /**
     * Java表达式
     */
    JAVA_EXPR("JAVA_EXPR", "Java表达式"),
    
    /**
     * SQL查询
     */
    SQL_QUERY("SQL_QUERY", "SQL查询"),
    
    /**
     * API接口调用
     */
    API_CALL("API_CALL", "API接口调用");
    
    private final String code;
    private final String description;
    
    RuleType(String code, String description) {
        this.code = code;
        this.description = description;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDescription() {
        return description;
    }
    
    public static RuleType fromCode(String code) {
        for (RuleType type : values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown rule type: " + code);
    }
}
