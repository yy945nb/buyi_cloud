package com.buyi.datawarehouse.enums;

/**
 * 断货风险等级枚举
 * Stockout Risk Level Enum
 */
public enum RiskLevel {
    /**
     * 安全 - 库存充足
     */
    SAFE("SAFE", "安全", "库存充足，无断货风险"),
    
    /**
     * 预警 - 库存偏低，需要关注
     */
    WARNING("WARNING", "预警", "库存偏低，需要关注"),
    
    /**
     * 危险 - 库存严重不足，需要紧急补货
     */
    DANGER("DANGER", "危险", "库存严重不足，需要紧急补货"),
    
    /**
     * 已断货 - 库存为零或已断货
     */
    STOCKOUT("STOCKOUT", "已断货", "库存为零或已断货");
    
    private final String code;
    private final String name;
    private final String description;
    
    RiskLevel(String code, String name, String description) {
        this.code = code;
        this.name = name;
        this.description = description;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getName() {
        return name;
    }
    
    public String getDescription() {
        return description;
    }
    
    /**
     * 根据可售天数和风险天数计算风险等级
     * 
     * @param availableDays 可售天数
     * @param safetyStockDays 安全库存天数
     * @return 风险等级
     */
    public static RiskLevel calculateRiskLevel(double availableDays, int safetyStockDays) {
        if (availableDays <= 0) {
            return STOCKOUT;
        } else if (availableDays < safetyStockDays * 0.5) {
            return DANGER;
        } else if (availableDays < safetyStockDays) {
            return WARNING;
        } else {
            return SAFE;
        }
    }
    
    /**
     * 根据代码获取风险等级
     */
    public static RiskLevel fromCode(String code) {
        if (code == null) {
            return null;
        }
        for (RiskLevel level : values()) {
            if (level.code.equals(code)) {
                return level;
            }
        }
        throw new IllegalArgumentException("Unknown risk level code: " + code);
    }
}
