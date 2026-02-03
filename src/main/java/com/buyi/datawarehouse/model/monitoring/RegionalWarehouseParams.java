package com.buyi.datawarehouse.model.monitoring;

import java.io.Serializable;

/**
 * 区域仓参数模型
 * Regional Warehouse Parameters Model
 * 
 * 用于存储区域仓特定的配置参数，如安全库存天数、海运时间等
 * 支持按区域仓维度配置不同的参数
 */
public class RegionalWarehouseParams implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 区域仓ID */
    private Long regionalWarehouseId;
    
    /** 区域仓编码 */
    private String regionalWarehouseCode;
    
    /** 区域仓名称 */
    private String regionalWarehouseName;
    
    /** 安全库存天数（默认30天） */
    private Integer safetyStockDays;
    
    /** 备货周期天数（默认30天） */
    private Integer stockingCycleDays;
    
    /** 发货天数/海运时间（不同区域仓不同） */
    private Integer shippingDays;
    
    /** 生产天数（可选） */
    private Integer productionDays;
    
    /** 总提前期天数（备货周期 + 发货天数） */
    private Integer leadTimeDays;
    
    public RegionalWarehouseParams() {
        // 默认值
        this.safetyStockDays = 30;
        this.stockingCycleDays = 30;
        this.shippingDays = 45;
        this.productionDays = 0;
        this.leadTimeDays = 75;
    }
    
    /**
     * 计算总提前期
     */
    public void calculateLeadTime() {
        this.leadTimeDays = (this.stockingCycleDays != null ? this.stockingCycleDays : 0)
                + (this.shippingDays != null ? this.shippingDays : 0);
    }
    
    // Getters and Setters
    
    public Long getRegionalWarehouseId() {
        return regionalWarehouseId;
    }
    
    public void setRegionalWarehouseId(Long regionalWarehouseId) {
        this.regionalWarehouseId = regionalWarehouseId;
    }
    
    public String getRegionalWarehouseCode() {
        return regionalWarehouseCode;
    }
    
    public void setRegionalWarehouseCode(String regionalWarehouseCode) {
        this.regionalWarehouseCode = regionalWarehouseCode;
    }
    
    public String getRegionalWarehouseName() {
        return regionalWarehouseName;
    }
    
    public void setRegionalWarehouseName(String regionalWarehouseName) {
        this.regionalWarehouseName = regionalWarehouseName;
    }
    
    public Integer getSafetyStockDays() {
        return safetyStockDays;
    }
    
    public void setSafetyStockDays(Integer safetyStockDays) {
        this.safetyStockDays = safetyStockDays;
    }
    
    public Integer getStockingCycleDays() {
        return stockingCycleDays;
    }
    
    public void setStockingCycleDays(Integer stockingCycleDays) {
        this.stockingCycleDays = stockingCycleDays;
    }
    
    public Integer getShippingDays() {
        return shippingDays;
    }
    
    public void setShippingDays(Integer shippingDays) {
        this.shippingDays = shippingDays;
    }
    
    public Integer getProductionDays() {
        return productionDays;
    }
    
    public void setProductionDays(Integer productionDays) {
        this.productionDays = productionDays;
    }
    
    public Integer getLeadTimeDays() {
        return leadTimeDays;
    }
    
    public void setLeadTimeDays(Integer leadTimeDays) {
        this.leadTimeDays = leadTimeDays;
    }
    
    @Override
    public String toString() {
        return "RegionalWarehouseParams{" +
                "regionalWarehouseId=" + regionalWarehouseId +
                ", regionalWarehouseCode='" + regionalWarehouseCode + '\'' +
                ", regionalWarehouseName='" + regionalWarehouseName + '\'' +
                ", safetyStockDays=" + safetyStockDays +
                ", stockingCycleDays=" + stockingCycleDays +
                ", shippingDays=" + shippingDays +
                ", productionDays=" + productionDays +
                ", leadTimeDays=" + leadTimeDays +
                '}';
    }
}
