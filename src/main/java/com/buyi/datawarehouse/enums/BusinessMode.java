package com.buyi.datawarehouse.enums;

/**
 * 业务模式枚举
 * Business Mode Enum
 * 
 * 用于区分不同的发货和库存管理模式
 */
public enum BusinessMode {
    /**
     * 聚合模式 - 集中发货
     */
    JH("JH", "聚合模式", "集中发货模式"),
    
    /**
     * 零星模式 - 零星发货
     */
    LX("LX", "零星模式", "零星发货模式"),
    
    /**
     * FBA模式 - 亚马逊仓库
     */
    FBA("FBA", "FBA模式", "亚马逊FBA仓库模式"),
    
    /**
     * JH+LX合并模式 - 用于海外仓库存统计
     */
    JH_LX("JH_LX", "JH+LX合并", "聚合和零星模式合并统计");
    
    private final String code;
    private final String name;
    private final String description;
    
    BusinessMode(String code, String name, String description) {
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
     * 判断是否为FBA模式
     */
    public boolean isFBA() {
        return this == FBA;
    }
    
    /**
     * 判断是否为JH或LX模式
     */
    public boolean isJHOrLX() {
        return this == JH || this == LX;
    }
    
    /**
     * 根据代码获取业务模式
     */
    public static BusinessMode fromCode(String code) {
        if (code == null) {
            return null;
        }
        for (BusinessMode mode : values()) {
            if (mode.code.equals(code)) {
                return mode;
            }
        }
        throw new IllegalArgumentException("Unknown business mode code: " + code);
    }
    
    /**
     * 将JH或LX转换为合并模式
     */
    public BusinessMode toMergedMode() {
        if (this == JH || this == LX) {
            return JH_LX;
        }
        return this;
    }
}
