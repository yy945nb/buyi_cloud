package com.buyi.datawarehouse.model.dimension;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 商品维度模型
 * Product Dimension Model for Data Warehouse
 * 采用SCD Type 2（缓慢变化维度）
 */
public class DimProduct implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 商品代理键（数仓主键） */
    private Long productKey;
    
    /** 商品业务ID（源系统主键） */
    private Long productId;
    
    /** SKU编码 */
    private String skuCode;
    
    /** SPU编码 */
    private String spuCode;
    
    /** 商品名称 */
    private String productName;
    
    /** 分类ID */
    private Long categoryId;
    
    /** 分类名称 */
    private String categoryName;
    
    /** 品牌 */
    private String brand;
    
    /** 供应商ID */
    private Long supplierId;
    
    /** 供应商名称 */
    private String supplierName;
    
    /** 成本价 */
    private BigDecimal costPrice;
    
    /** 标价 */
    private BigDecimal listPrice;
    
    /** 重量(kg) */
    private BigDecimal weight;
    
    /** 体积(m³) */
    private BigDecimal volume;
    
    /** 状态 */
    private String status;
    
    /** 生效日期（SCD Type 2） */
    private LocalDate effectiveDate;
    
    /** 失效日期（SCD Type 2） */
    private LocalDate expiryDate;
    
    /** 是否当前版本（SCD Type 2） */
    private Boolean isCurrent;
    
    public DimProduct() {
        this.effectiveDate = LocalDate.now();
        this.expiryDate = LocalDate.of(9999, 12, 31);
        this.isCurrent = true;
    }
    
    /**
     * 创建新版本（用于SCD Type 2更新）
     * @return 新版本的商品维度
     */
    public DimProduct createNewVersion() {
        DimProduct newVersion = new DimProduct();
        newVersion.setProductId(this.productId);
        newVersion.setSkuCode(this.skuCode);
        newVersion.setSpuCode(this.spuCode);
        newVersion.setProductName(this.productName);
        newVersion.setCategoryId(this.categoryId);
        newVersion.setCategoryName(this.categoryName);
        newVersion.setBrand(this.brand);
        newVersion.setSupplierId(this.supplierId);
        newVersion.setSupplierName(this.supplierName);
        newVersion.setCostPrice(this.costPrice);
        newVersion.setListPrice(this.listPrice);
        newVersion.setWeight(this.weight);
        newVersion.setVolume(this.volume);
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
    
    public Long getProductKey() {
        return productKey;
    }

    public void setProductKey(Long productKey) {
        this.productKey = productKey;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public String getSkuCode() {
        return skuCode;
    }

    public void setSkuCode(String skuCode) {
        this.skuCode = skuCode;
    }

    public String getSpuCode() {
        return spuCode;
    }

    public void setSpuCode(String spuCode) {
        this.spuCode = spuCode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public Long getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Long supplierId) {
        this.supplierId = supplierId;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public BigDecimal getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(BigDecimal costPrice) {
        this.costPrice = costPrice;
    }

    public BigDecimal getListPrice() {
        return listPrice;
    }

    public void setListPrice(BigDecimal listPrice) {
        this.listPrice = listPrice;
    }

    public BigDecimal getWeight() {
        return weight;
    }

    public void setWeight(BigDecimal weight) {
        this.weight = weight;
    }

    public BigDecimal getVolume() {
        return volume;
    }

    public void setVolume(BigDecimal volume) {
        this.volume = volume;
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
        return "DimProduct{" +
                "productKey=" + productKey +
                ", productId=" + productId +
                ", skuCode='" + skuCode + '\'' +
                ", productName='" + productName + '\'' +
                ", categoryName='" + categoryName + '\'' +
                ", status='" + status + '\'' +
                ", isCurrent=" + isCurrent +
                '}';
    }
}
