package com.buyi.channel.rule.enums;

/**
 * 渠道规则类型枚举
 * Channel Rule Type Enumeration
 *
 * 合并了buyi_cloud中RuleType（JAVA_EXPR, SQL_QUERY, API_CALL）
 * 和ProcessingAction.ActionType（SCRIPT, API, SQL）的优势，
 * 增加了CONDITION和GROOVY类型支持更灵活的规则定义。
 */
public enum ChannelRuleType {

    /**
     * JEXL表达式 - 用于简单计算和条件判断
     */
    EXPRESSION("EXPRESSION", "JEXL表达式"),

    /**
     * 条件判断 - 返回布尔值的表达式
     */
    CONDITION("CONDITION", "条件判断"),

    /**
     * 脚本执行 - 支持多行脚本
     */
    SCRIPT("SCRIPT", "脚本执行"),

    /**
     * Groovy脚本 - 用于复杂业务逻辑
     */
    GROOVY("GROOVY", "Groovy脚本");

    private final String code;
    private final String description;

    ChannelRuleType(String code, String description) {
        this.code = code;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }

    public static ChannelRuleType fromCode(String code) {
        for (ChannelRuleType type : values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown channel rule type: " + code);
    }
}
