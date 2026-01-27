package com.buyi.ruleengine.stocking.enums;

/**
 * 商品货盘SABC分类枚举
 * Product SABC Category Enumeration
 * 
 * S类: 畅销品，高销量高利润
 * A类: 次畅销品，稳定销量
 * B类: 一般商品，中等销量
 * C类: 滞销品，低销量
 */
public enum ProductCategory {
    
    /**
     * S类 - 畅销品（销量占比前20%，利润贡献高）
     */
    S("S", "畅销品", 45, 1.3),
    
    /**
     * A类 - 次畅销品（销量占比20%-40%）
     */
    A("A", "次畅销品", 35, 1.2),
    
    /**
     * B类 - 一般商品（销量占比40%-70%）
     */
    B("B", "一般商品", 25, 1.1),
    
    /**
     * C类 - 滞销品（销量占比70%-100%）
     */
    C("C", "滞销品", 15, 1.0);
    
    private final String code;
    private final String description;
    /** 默认安全库存天数 */
    private final int defaultSafetyStockDays;
    /** 默认备货浮动系数 */
    private final double defaultStockingCoefficient;
    
    ProductCategory(String code, String description, int defaultSafetyStockDays, double defaultStockingCoefficient) {
        this.code = code;
        this.description = description;
        this.defaultSafetyStockDays = defaultSafetyStockDays;
        this.defaultStockingCoefficient = defaultStockingCoefficient;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDescription() {
        return description;
    }
    
    public int getDefaultSafetyStockDays() {
        return defaultSafetyStockDays;
    }
    
    public double getDefaultStockingCoefficient() {
        return defaultStockingCoefficient;
    }
    
    public static ProductCategory fromCode(String code) {
        for (ProductCategory category : values()) {
            if (category.code.equals(code)) {
                return category;
            }
        }
        throw new IllegalArgumentException("Unknown product category: " + code);
    }
}
