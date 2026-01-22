package com.buyi.datawarehouse.model.dimension;

import java.io.Serializable;

/**
 * 地区维度模型
 * Region Dimension Model for Data Warehouse
 */
public class DimRegion implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 地区代理键（数仓主键） */
    private Long regionKey;
    
    /** 地区业务ID（源系统主键） */
    private Long regionId;
    
    /** 国家编码 */
    private String countryCode;
    
    /** 国家名称 */
    private String countryName;
    
    /** 州/省编码 */
    private String stateCode;
    
    /** 州/省名称 */
    private String stateName;
    
    /** 城市名称 */
    private String cityName;
    
    /** 邮编 */
    private String postalCode;
    
    /** 洲 */
    private String continent;
    
    /** 是否当前版本 */
    private Boolean isCurrent;
    
    public DimRegion() {
        this.isCurrent = true;
    }

    // Getters and Setters
    
    public Long getRegionKey() {
        return regionKey;
    }

    public void setRegionKey(Long regionKey) {
        this.regionKey = regionKey;
    }

    public Long getRegionId() {
        return regionId;
    }

    public void setRegionId(Long regionId) {
        this.regionId = regionId;
    }

    public String getCountryCode() {
        return countryCode;
    }

    public void setCountryCode(String countryCode) {
        this.countryCode = countryCode;
    }

    public String getCountryName() {
        return countryName;
    }

    public void setCountryName(String countryName) {
        this.countryName = countryName;
    }

    public String getStateCode() {
        return stateCode;
    }

    public void setStateCode(String stateCode) {
        this.stateCode = stateCode;
    }

    public String getStateName() {
        return stateName;
    }

    public void setStateName(String stateName) {
        this.stateName = stateName;
    }

    public String getCityName() {
        return cityName;
    }

    public void setCityName(String cityName) {
        this.cityName = cityName;
    }

    public String getPostalCode() {
        return postalCode;
    }

    public void setPostalCode(String postalCode) {
        this.postalCode = postalCode;
    }

    public String getContinent() {
        return continent;
    }

    public void setContinent(String continent) {
        this.continent = continent;
    }

    public Boolean getIsCurrent() {
        return isCurrent;
    }

    public void setIsCurrent(Boolean isCurrent) {
        this.isCurrent = isCurrent;
    }
    
    @Override
    public String toString() {
        return "DimRegion{" +
                "regionKey=" + regionKey +
                ", countryCode='" + countryCode + '\'' +
                ", countryName='" + countryName + '\'' +
                ", stateName='" + stateName + '\'' +
                ", cityName='" + cityName + '\'' +
                '}';
    }
}
