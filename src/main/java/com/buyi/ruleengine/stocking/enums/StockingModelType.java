package com.buyi.ruleengine.stocking.enums;

/**
 * 备货模型类型枚举
 * Stocking Model Type Enumeration
 */
public enum StockingModelType {
    
    /**
     * 月度备货模型
     * 基于SABC分类和自定义参数进行月度备货计划
     */
    MONTHLY("MONTHLY", "月度备货模型"),
    
    /**
     * 每周固定备货模型
     * 固定7天周期，基于加权平均日销计算
     */
    WEEKLY_FIXED("WEEKLY_FIXED", "每周固定备货模型"),
    
    /**
     * 断货点临时备货模型
     * 基于断货点预测进行紧急备货
     */
    STOCKOUT_EMERGENCY("STOCKOUT_EMERGENCY", "断货点临时备货模型"),
    
    /**
     * 新款/爆款备货模型
     * 针对短时间销量暴涨导致多区域断货的商品
     * 适用于新品上市或爆款商品的紧急备货策略
     */
    NEW_SKU("NEW_SKU", "新款爆款备货模型");
    
    private final String code;
    private final String description;
    
    StockingModelType(String code, String description) {
        this.code = code;
        this.description = description;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDescription() {
        return description;
    }
    
    public static StockingModelType fromCode(String code) {
        for (StockingModelType type : values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown stocking model type: " + code);
    }
}
