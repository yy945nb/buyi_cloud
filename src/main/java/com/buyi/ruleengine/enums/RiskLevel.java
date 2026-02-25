package com.buyi.ruleengine.enums;

/**
 * 库存风险等级枚举
 * Inventory Risk Level Enumeration
 */
public enum RiskLevel {
    /**
     * 单仓断货 - 预计库存 <= 0
     */
    OUTAGE("OUTAGE", "单仓断货"),

    /**
     * 全仓断货 - 由上层聚合逻辑判定，本类不实现
     */
    ALLOUTAGE("ALLOUTAGE", "全仓断货"),

    /**
     * 存在断货风险 - 海运路径不可救（即使今天立即发货也无法避免断货）
     */
    AT_RISK("AT_RISK", "存在断货风险"),

    /**
     * 安全 - 库存充足
     */
    OK("OK", "库存安全");

    private final String code;
    private final String description;

    RiskLevel(String code, String description) {
        this.code = code;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }

    public static RiskLevel fromCode(String code) {
        for (RiskLevel level : values()) {
            if (level.code.equals(code)) {
                return level;
            }
        }
        throw new IllegalArgumentException("Unknown risk level: " + code);
    }
}
