package com.buyi.ruleengine.stocking.model;

import com.buyi.ruleengine.stocking.enums.ProductCategory;
import com.buyi.ruleengine.stocking.enums.ShippingRegion;
import com.buyi.ruleengine.stocking.enums.StockingModelType;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 备货计算结果模型
 * Stocking Calculation Result Model
 */
public class StockingResult implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 商品ID */
    private Long productId;
    
    /** 商品SKU */
    private String sku;
    
    /** 商品名称 */
    private String productName;
    
    /** 备货模型类型 */
    private StockingModelType modelType;
    
    /** 商品SABC分类 */
    private ProductCategory category;
    
    /** 发货区域 */
    private ShippingRegion shippingRegion;
    
    /** 计算日期 */
    private LocalDate calculationDate;
    
    /** 日均销量 */
    private BigDecimal dailyAvgSales;
    
    /** 建议备货量 */
    private Integer recommendedQuantity;
    
    /** 调整后备货量（考虑浮动系数和安全库存） */
    private Integer adjustedQuantity;
    
    /** 最终备货量（考虑最小/最大订货量限制） */
    private Integer finalQuantity;
    
    /** 当前库存 */
    private Integer currentInventory;
    
    /** 在途库存 */
    private Integer inTransitInventory;
    
    /** 预计到货日期 */
    private LocalDate expectedArrivalDate;
    
    /** 建议发货日期 */
    private LocalDate suggestedShipDate;
    
    /** 备货周期（天） */
    private Integer stockingCycleDays;
    
    /** 安全库存天数 */
    private Integer safetyStockDays;
    
    /** 备货浮动系数 */
    private BigDecimal stockingCoefficient;
    
    /** 是否紧急备货 */
    private Boolean isEmergency;
    
    /** 紧急程度说明 */
    private String urgencyNote;
    
    /** 备货原因/说明 */
    private String reason;
    
    /** 断货风险天数（如适用） */
    private Integer stockoutRiskDays;
    
    /** 预计断货量（如适用） */
    private Integer expectedStockoutQuantity;
    
    public StockingResult() {
        this.isEmergency = false;
    }
    
    // Builder pattern for convenience
    public static Builder builder() {
        return new Builder();
    }
    
    public static class Builder {
        private StockingResult result = new StockingResult();
        
        public Builder productId(Long productId) {
            result.productId = productId;
            return this;
        }
        
        public Builder sku(String sku) {
            result.sku = sku;
            return this;
        }
        
        public Builder productName(String productName) {
            result.productName = productName;
            return this;
        }
        
        public Builder modelType(StockingModelType modelType) {
            result.modelType = modelType;
            return this;
        }
        
        public Builder category(ProductCategory category) {
            result.category = category;
            return this;
        }
        
        public Builder shippingRegion(ShippingRegion shippingRegion) {
            result.shippingRegion = shippingRegion;
            return this;
        }
        
        public Builder calculationDate(LocalDate calculationDate) {
            result.calculationDate = calculationDate;
            return this;
        }
        
        public Builder dailyAvgSales(BigDecimal dailyAvgSales) {
            result.dailyAvgSales = dailyAvgSales;
            return this;
        }
        
        public Builder recommendedQuantity(Integer recommendedQuantity) {
            result.recommendedQuantity = recommendedQuantity;
            return this;
        }
        
        public Builder adjustedQuantity(Integer adjustedQuantity) {
            result.adjustedQuantity = adjustedQuantity;
            return this;
        }
        
        public Builder finalQuantity(Integer finalQuantity) {
            result.finalQuantity = finalQuantity;
            return this;
        }
        
        public Builder currentInventory(Integer currentInventory) {
            result.currentInventory = currentInventory;
            return this;
        }
        
        public Builder inTransitInventory(Integer inTransitInventory) {
            result.inTransitInventory = inTransitInventory;
            return this;
        }
        
        public Builder expectedArrivalDate(LocalDate expectedArrivalDate) {
            result.expectedArrivalDate = expectedArrivalDate;
            return this;
        }
        
        public Builder suggestedShipDate(LocalDate suggestedShipDate) {
            result.suggestedShipDate = suggestedShipDate;
            return this;
        }
        
        public Builder stockingCycleDays(Integer stockingCycleDays) {
            result.stockingCycleDays = stockingCycleDays;
            return this;
        }
        
        public Builder safetyStockDays(Integer safetyStockDays) {
            result.safetyStockDays = safetyStockDays;
            return this;
        }
        
        public Builder stockingCoefficient(BigDecimal stockingCoefficient) {
            result.stockingCoefficient = stockingCoefficient;
            return this;
        }
        
        public Builder isEmergency(Boolean isEmergency) {
            result.isEmergency = isEmergency;
            return this;
        }
        
        public Builder urgencyNote(String urgencyNote) {
            result.urgencyNote = urgencyNote;
            return this;
        }
        
        public Builder reason(String reason) {
            result.reason = reason;
            return this;
        }
        
        public Builder stockoutRiskDays(Integer stockoutRiskDays) {
            result.stockoutRiskDays = stockoutRiskDays;
            return this;
        }
        
        public Builder expectedStockoutQuantity(Integer expectedStockoutQuantity) {
            result.expectedStockoutQuantity = expectedStockoutQuantity;
            return this;
        }
        
        public StockingResult build() {
            return result;
        }
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
    
    public StockingModelType getModelType() {
        return modelType;
    }
    
    public void setModelType(StockingModelType modelType) {
        this.modelType = modelType;
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
    
    public LocalDate getCalculationDate() {
        return calculationDate;
    }
    
    public void setCalculationDate(LocalDate calculationDate) {
        this.calculationDate = calculationDate;
    }
    
    public BigDecimal getDailyAvgSales() {
        return dailyAvgSales;
    }
    
    public void setDailyAvgSales(BigDecimal dailyAvgSales) {
        this.dailyAvgSales = dailyAvgSales;
    }
    
    public Integer getRecommendedQuantity() {
        return recommendedQuantity;
    }
    
    public void setRecommendedQuantity(Integer recommendedQuantity) {
        this.recommendedQuantity = recommendedQuantity;
    }
    
    public Integer getAdjustedQuantity() {
        return adjustedQuantity;
    }
    
    public void setAdjustedQuantity(Integer adjustedQuantity) {
        this.adjustedQuantity = adjustedQuantity;
    }
    
    public Integer getFinalQuantity() {
        return finalQuantity;
    }
    
    public void setFinalQuantity(Integer finalQuantity) {
        this.finalQuantity = finalQuantity;
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
    
    public LocalDate getExpectedArrivalDate() {
        return expectedArrivalDate;
    }
    
    public void setExpectedArrivalDate(LocalDate expectedArrivalDate) {
        this.expectedArrivalDate = expectedArrivalDate;
    }
    
    public LocalDate getSuggestedShipDate() {
        return suggestedShipDate;
    }
    
    public void setSuggestedShipDate(LocalDate suggestedShipDate) {
        this.suggestedShipDate = suggestedShipDate;
    }
    
    public Integer getStockingCycleDays() {
        return stockingCycleDays;
    }
    
    public void setStockingCycleDays(Integer stockingCycleDays) {
        this.stockingCycleDays = stockingCycleDays;
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
    
    public Boolean getIsEmergency() {
        return isEmergency;
    }
    
    public void setIsEmergency(Boolean isEmergency) {
        this.isEmergency = isEmergency;
    }
    
    public String getUrgencyNote() {
        return urgencyNote;
    }
    
    public void setUrgencyNote(String urgencyNote) {
        this.urgencyNote = urgencyNote;
    }
    
    public String getReason() {
        return reason;
    }
    
    public void setReason(String reason) {
        this.reason = reason;
    }
    
    public Integer getStockoutRiskDays() {
        return stockoutRiskDays;
    }
    
    public void setStockoutRiskDays(Integer stockoutRiskDays) {
        this.stockoutRiskDays = stockoutRiskDays;
    }
    
    public Integer getExpectedStockoutQuantity() {
        return expectedStockoutQuantity;
    }
    
    public void setExpectedStockoutQuantity(Integer expectedStockoutQuantity) {
        this.expectedStockoutQuantity = expectedStockoutQuantity;
    }
    
    @Override
    public String toString() {
        return "StockingResult{" +
                "productId=" + productId +
                ", sku='" + sku + '\'' +
                ", modelType=" + modelType +
                ", category=" + category +
                ", dailyAvgSales=" + dailyAvgSales +
                ", recommendedQuantity=" + recommendedQuantity +
                ", finalQuantity=" + finalQuantity +
                ", isEmergency=" + isEmergency +
                ", reason='" + reason + '\'' +
                '}';
    }
}
