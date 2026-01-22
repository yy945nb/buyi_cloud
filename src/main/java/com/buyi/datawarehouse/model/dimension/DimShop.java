package com.buyi.datawarehouse.model.dimension;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * 店铺维度模型
 * Shop Dimension Model for Data Warehouse
 * 采用SCD Type 2（缓慢变化维度）
 */
public class DimShop implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 店铺代理键（数仓主键） */
    private Long shopKey;
    
    /** 店铺业务ID（源系统主键） */
    private Long shopId;
    
    /** 店铺编码 */
    private String shopCode;
    
    /** 店铺名称 */
    private String shopName;
    
    /** 平台 Amazon/eBay/etc */
    private String platform;
    
    /** 站点 */
    private String marketplace;
    
    /** 地区 */
    private String region;
    
    /** 国家 */
    private String country;
    
    /** 币种 */
    private String currency;
    
    /** 时区 */
    private String timezone;
    
    /** 状态 */
    private String status;
    
    /** 生效日期（SCD Type 2） */
    private LocalDate effectiveDate;
    
    /** 失效日期（SCD Type 2） */
    private LocalDate expiryDate;
    
    /** 是否当前版本（SCD Type 2） */
    private Boolean isCurrent;
    
    public DimShop() {
        this.effectiveDate = LocalDate.now();
        this.expiryDate = LocalDate.of(9999, 12, 31);
        this.isCurrent = true;
    }
    
    /**
     * 创建新版本（用于SCD Type 2更新）
     * @return 新版本的店铺维度
     */
    public DimShop createNewVersion() {
        DimShop newVersion = new DimShop();
        newVersion.setShopId(this.shopId);
        newVersion.setShopCode(this.shopCode);
        newVersion.setShopName(this.shopName);
        newVersion.setPlatform(this.platform);
        newVersion.setMarketplace(this.marketplace);
        newVersion.setRegion(this.region);
        newVersion.setCountry(this.country);
        newVersion.setCurrency(this.currency);
        newVersion.setTimezone(this.timezone);
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
    
    public Long getShopKey() {
        return shopKey;
    }

    public void setShopKey(Long shopKey) {
        this.shopKey = shopKey;
    }

    public Long getShopId() {
        return shopId;
    }

    public void setShopId(Long shopId) {
        this.shopId = shopId;
    }

    public String getShopCode() {
        return shopCode;
    }

    public void setShopCode(String shopCode) {
        this.shopCode = shopCode;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getPlatform() {
        return platform;
    }

    public void setPlatform(String platform) {
        this.platform = platform;
    }

    public String getMarketplace() {
        return marketplace;
    }

    public void setMarketplace(String marketplace) {
        this.marketplace = marketplace;
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

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getTimezone() {
        return timezone;
    }

    public void setTimezone(String timezone) {
        this.timezone = timezone;
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
        return "DimShop{" +
                "shopKey=" + shopKey +
                ", shopId=" + shopId +
                ", shopCode='" + shopCode + '\'' +
                ", shopName='" + shopName + '\'' +
                ", platform='" + platform + '\'' +
                ", marketplace='" + marketplace + '\'' +
                ", status='" + status + '\'' +
                ", isCurrent=" + isCurrent +
                '}';
    }
}
