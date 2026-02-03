package com.buyi.datawarehouse.model;

import java.io.Serializable;

/**
 * 仓库映射模型
 * Warehouse Mapping Model
 * 
 * 用于建立不同系统（JH/LX）的仓库标识到统一warehouse_id的映射
 * Maps various warehouse identifiers from different systems (JH/LX) to unified warehouse_id
 */
public class WarehouseMapping implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 统一仓库ID */
    private Long warehouseId;
    
    /** 仓库编码 */
    private String warehouseCode;
    
    /** 仓库名称 */
    private String warehouseName;
    
    /** 仓库类型：FBA/REGIONAL */
    private String warehouseType;
    
    /** 来源系统：JH/LX */
    private String sourceSystem;
    
    /** 源系统仓库ID（JH的warehouse_id或LX的wid） */
    private Long sourceWarehouseId;
    
    /** 源系统仓库名称 */
    private String sourceWarehouseName;
    
    /** 区域 */
    private String region;
    
    /** 国家 */
    private String country;
    
    /** 是否启用 */
    private Boolean isActive;
    
    public WarehouseMapping() {
        this.isActive = true;
    }
    
    // Getters and Setters
    
    public Long getWarehouseId() {
        return warehouseId;
    }
    
    public void setWarehouseId(Long warehouseId) {
        this.warehouseId = warehouseId;
    }
    
    public String getWarehouseCode() {
        return warehouseCode;
    }
    
    public void setWarehouseCode(String warehouseCode) {
        this.warehouseCode = warehouseCode;
    }
    
    public String getWarehouseName() {
        return warehouseName;
    }
    
    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }
    
    public String getWarehouseType() {
        return warehouseType;
    }
    
    public void setWarehouseType(String warehouseType) {
        this.warehouseType = warehouseType;
    }
    
    public String getSourceSystem() {
        return sourceSystem;
    }
    
    public void setSourceSystem(String sourceSystem) {
        this.sourceSystem = sourceSystem;
    }
    
    public Long getSourceWarehouseId() {
        return sourceWarehouseId;
    }
    
    public void setSourceWarehouseId(Long sourceWarehouseId) {
        this.sourceWarehouseId = sourceWarehouseId;
    }
    
    public String getSourceWarehouseName() {
        return sourceWarehouseName;
    }
    
    public void setSourceWarehouseName(String sourceWarehouseName) {
        this.sourceWarehouseName = sourceWarehouseName;
    }
    
    public String getRegion() {
        return region;
    }
    
    public void setRegion(String region) {
        this.region = region;
    }
    
    public String getCountry() {
        return country;
    }
    
    public void setCountry(String country) {
        this.country = country;
    }
    
    public Boolean getIsActive() {
        return isActive;
    }
    
    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
    
    @Override
    public String toString() {
        return "WarehouseMapping{" +
                "warehouseId=" + warehouseId +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", warehouseName='" + warehouseName + '\'' +
                ", warehouseType='" + warehouseType + '\'' +
                ", sourceSystem='" + sourceSystem + '\'' +
                ", sourceWarehouseId=" + sourceWarehouseId +
                '}';
    }
}
