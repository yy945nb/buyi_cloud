package com.buyi.sku.tag.enums;

/**
 * 标签规则状态枚举
 * Tag Rule Status Enum
 */
public enum TagRuleStatus {
    
    DRAFT("DRAFT", "草稿"),
    ENABLED("ENABLED", "启用"),
    DISABLED("DISABLED", "停用");
    
    private final String code;
    private final String description;
    
    TagRuleStatus(String code, String description) {
        this.code = code;
        this.description = description;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDescription() {
        return description;
    }
    
    public static TagRuleStatus fromCode(String code) {
        for (TagRuleStatus status : TagRuleStatus.values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown tag rule status: " + code);
    }
}
