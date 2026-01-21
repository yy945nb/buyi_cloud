package com.buyi.sku.tag.enums;

/**
 * 标签类型枚举
 * Tag Type Enum
 */
public enum TagType {
    
    SINGLE("SINGLE", "单选"),
    MULTI("MULTI", "多选");
    
    private final String code;
    private final String description;
    
    TagType(String code, String description) {
        this.code = code;
        this.description = description;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDescription() {
        return description;
    }
    
    public static TagType fromCode(String code) {
        for (TagType type : TagType.values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown tag type: " + code);
    }
}
