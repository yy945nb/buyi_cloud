package com.buyi.ruleengine.stocking.model;

import com.buyi.ruleengine.stocking.enums.ProductCategory;
import com.buyi.ruleengine.stocking.enums.ShippingRegion;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 商品备货配置模型
 * Product Stock Configuration Model
 * <p>
 * 定义商品的备货参数，包括SABC分类、安全库存天数、备货浮动系数等
 */
public class ProductStockConfig implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 商品ID
     */
    private Long productId;

    /**
     * 商品SKU
     */
    private String sku;

    /**
     * 商品名称
     */
    private String productName;

    /**
     * 商品货盘SABC分类
     */
    private ProductCategory category;

    /**
     * 发货区域
     */
    private ShippingRegion shippingRegion;

    /**
     * 安全库存天数（可自定义覆盖默认值）
     */
    private Integer safetyStockDays;

    /**
     * 备货浮动系数（可自定义覆盖默认值）
     */
    private BigDecimal stockingCoefficient;

    /**
     * 生产周期（天）
     */
    private Integer productionDays;

    /**
     * 当前库存数量
     */
    private Integer currentInventory;

    /**
     * 在途库存数量
     */
    private Integer inTransitInventory;

    /**
     * 最小订货量
     */
    private Integer minOrderQuantity;

    /**
     * 最大订货量
     */
    private Integer maxOrderQuantity;

    /**
     * 是否启用自动备货
     */
    private Boolean autoStockingEnabled;

    public ProductStockConfig() {
        this.autoStockingEnabled = true;
    }

    /**
     * 获取有效的安全库存天数
     * 如果自定义值存在则使用自定义值，否则使用分类默认值
     */
    public int getEffectiveSafetyStockDays() {
        if (safetyStockDays != null && safetyStockDays > 0) {
            return safetyStockDays;
        }
        return category != null ? category.getDefaultSafetyStockDays() : 30;
    }

    /**
     * 获取有效的备货浮动系数
     * 如果自定义值存在则使用自定义值，否则使用分类默认值
     */
    public BigDecimal getEffectiveStockingCoefficient() {
        if (stockingCoefficient != null && stockingCoefficient.compareTo(BigDecimal.ZERO) > 0) {
            return stockingCoefficient;
        }
        return category != null ? BigDecimal.valueOf(category.getDefaultStockingCoefficient()) : BigDecimal.ONE;
    }

    /**
     * 获取有效的海运时间
     */
    public int getEffectiveShippingDays() {
        return shippingRegion != null ? shippingRegion.getShippingDays() : 45;
    }

    /**
     * 获取总库存（当前库存 + 在途库存）
     */
    public int getTotalInventory() {
        int current = currentInventory != null ? currentInventory : 0;
        int inTransit = inTransitInventory != null ? inTransitInventory : 0;
        return current + inTransit;
    }

    // Getters and Setters
    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public ProductCategory getCategory() {
        return category;
    }

    public void setCategory(ProductCategory category) {
        this.category = category;
    }

    public ShippingRegion getShippingRegion() {
        return shippingRegion;
    }

    public void setShippingRegion(ShippingRegion shippingRegion) {
        this.shippingRegion = shippingRegion;
    }

    public Integer getSafetyStockDays() {
        return safetyStockDays;
    }

    public void setSafetyStockDays(Integer safetyStockDays) {
        this.safetyStockDays = safetyStockDays;
    }

    public BigDecimal getStockingCoefficient() {
        return stockingCoefficient;
    }

    public void setStockingCoefficient(BigDecimal stockingCoefficient) {
        this.stockingCoefficient = stockingCoefficient;
    }

    public Integer getProductionDays() {
        return productionDays;
    }

    public void setProductionDays(Integer productionDays) {
        this.productionDays = productionDays;
    }

    public Integer getCurrentInventory() {
        return currentInventory;
    }

    public void setCurrentInventory(Integer currentInventory) {
        this.currentInventory = currentInventory;
    }

    public Integer getInTransitInventory() {
        return inTransitInventory;
    }

    public void setInTransitInventory(Integer inTransitInventory) {
        this.inTransitInventory = inTransitInventory;
    }

    public Integer getMinOrderQuantity() {
        return minOrderQuantity;
    }

    public void setMinOrderQuantity(Integer minOrderQuantity) {
        this.minOrderQuantity = minOrderQuantity;
    }

    public Integer getMaxOrderQuantity() {
        return maxOrderQuantity;
    }

    public void setMaxOrderQuantity(Integer maxOrderQuantity) {
        this.maxOrderQuantity = maxOrderQuantity;
    }

    public Boolean getAutoStockingEnabled() {
        return autoStockingEnabled;
    }

    public void setAutoStockingEnabled(Boolean autoStockingEnabled) {
        this.autoStockingEnabled = autoStockingEnabled;
    }

    @Override
    public String toString() {
        return "ProductStockConfig{" +
                "productId=" + productId +
                ", sku='" + sku + '\'' +
                ", category=" + category +
                ", shippingRegion=" + shippingRegion +
                ", safetyStockDays=" + getEffectiveSafetyStockDays() +
                ", stockingCoefficient=" + getEffectiveStockingCoefficient() +
                ", currentInventory=" + currentInventory +
                ", inTransitInventory=" + inTransitInventory +
                '}';
    }
}
