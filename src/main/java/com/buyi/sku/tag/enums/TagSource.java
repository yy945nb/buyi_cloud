package com.buyi.sku.tag.enums;

/**
 * 标签来源枚举
 * Tag Source Enum
 */
public enum TagSource {
    
    RULE("RULE", "规则"),
    MANUAL("MANUAL", "人工");
    
    private final String code;
    private final String description;
    
    TagSource(String code, String description) {
        this.code = code;
        this.description = description;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDescription() {
        return description;
    }
    
    public static TagSource fromCode(String code) {
        for (TagSource source : TagSource.values()) {
            if (source.code.equals(code)) {
                return source;
            }
        }
        throw new IllegalArgumentException("Unknown tag source: " + code);
    }
}
