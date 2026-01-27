package com.buyi.ruleengine.enums;

/**
 * 库存风险等级枚举
 * Inventory Risk Level Enumeration
 */
public enum RiskLevel {
    /**
     * 断货 - 预计库存 <= 0
     */
    OUTAGE("OUTAGE", "断货"),

    /**
     * 风险 - 库存低于安全库存或长期未发货
     */
    AT_RISK("AT_RISK", "风险"),

    /**
     * 安全 - 库存充足
     */
    OK("OK", "安全");

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
