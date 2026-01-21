package com.buyi.sku.tag.enums;

/**
 * 标签操作类型枚举
 * Tag Operation Type Enum
 */
public enum TagOperationType {
    
    CREATE("CREATE", "新增"),
    UPDATE("UPDATE", "更新"),
    DELETE("DELETE", "删除");
    
    private final String code;
    private final String description;
    
    TagOperationType(String code, String description) {
        this.code = code;
        this.description = description;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDescription() {
        return description;
    }
    
    public static TagOperationType fromCode(String code) {
        for (TagOperationType type : TagOperationType.values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown tag operation type: " + code);
    }
}
