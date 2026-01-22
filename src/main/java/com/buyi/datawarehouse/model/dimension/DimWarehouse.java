package com.buyi.datawarehouse.model.dimension;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * 仓库维度模型
 * Warehouse Dimension Model for Data Warehouse
 * 采用SCD Type 2（缓慢变化维度）
 */
public class DimWarehouse implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 仓库代理键（数仓主键） */
    private Long warehouseKey;
    
    /** 仓库业务ID（源系统主键） */
    private Long warehouseId;
    
    /** 仓库编码 */
    private String warehouseCode;
    
    /** 仓库名称 */
    private String warehouseName;
    
    /** 仓库类型 FBA/FBM/自营 */
    private String warehouseType;
    
    /** 国家 */
    private String country;
    
    /** 地区 */
    private String region;
    
    /** 城市 */
    private String city;
    
    /** 地址 */
    private String address;
    
    /** 状态 */
    private String status;
    
    /** 生效日期（SCD Type 2） */
    private LocalDate effectiveDate;
    
    /** 失效日期（SCD Type 2） */
    private LocalDate expiryDate;
    
    /** 是否当前版本（SCD Type 2） */
    private Boolean isCurrent;
    
    public DimWarehouse() {
        this.effectiveDate = LocalDate.now();
        this.expiryDate = LocalDate.of(9999, 12, 31);
        this.isCurrent = true;
    }
    
    /**
     * 创建新版本（用于SCD Type 2更新）
     * @return 新版本的仓库维度
     */
    public DimWarehouse createNewVersion() {
        DimWarehouse newVersion = new DimWarehouse();
        newVersion.setWarehouseId(this.warehouseId);
        newVersion.setWarehouseCode(this.warehouseCode);
        newVersion.setWarehouseName(this.warehouseName);
        newVersion.setWarehouseType(this.warehouseType);
        newVersion.setCountry(this.country);
        newVersion.setRegion(this.region);
        newVersion.setCity(this.city);
        newVersion.setAddress(this.address);
        newVersion.setStatus(this.status);
        newVersion.setEffectiveDate(LocalDate.now());
        newVersion.setExpiryDate(LocalDate.of(9999, 12, 31));
        newVersion.setIsCurrent(true);
        return newVersion;
    }
    
    /**
     * 使当前版本失效
     */
    public void expire() {
        this.expiryDate = LocalDate.now().minusDays(1);
        this.isCurrent = false;
    }

    // Getters and Setters
    
    public Long getWarehouseKey() {
        return warehouseKey;
    }

    public void setWarehouseKey(Long warehouseKey) {
        this.warehouseKey = warehouseKey;
    }

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

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDate getEffectiveDate() {
        return effectiveDate;
    }

    public void setEffectiveDate(LocalDate effectiveDate) {
        this.effectiveDate = effectiveDate;
    }

    public LocalDate getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(LocalDate expiryDate) {
        this.expiryDate = expiryDate;
    }

    public Boolean getIsCurrent() {
        return isCurrent;
    }

    public void setIsCurrent(Boolean isCurrent) {
        this.isCurrent = isCurrent;
    }
    
    @Override
    public String toString() {
        return "DimWarehouse{" +
                "warehouseKey=" + warehouseKey +
                ", warehouseId=" + warehouseId +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", warehouseName='" + warehouseName + '\'' +
                ", warehouseType='" + warehouseType + '\'' +
                ", country='" + country + '\'' +
                ", status='" + status + '\'' +
                ", isCurrent=" + isCurrent +
                '}';
    }
}
