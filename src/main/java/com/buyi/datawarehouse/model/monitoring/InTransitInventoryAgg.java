package com.buyi.datawarehouse.model.monitoring;

import com.buyi.datawarehouse.enums.BusinessMode;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * 在途库存聚合数据模型
 * In-Transit Inventory Aggregation Model
 * 
 * 用于按产品、仓库、业务模式维度聚合在途库存
 */
public class InTransitInventoryAgg implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 产品ID */
    private Long productId;
    
    /** 产品SKU */
    private String productSku;
    
    /** 仓库ID */
    private Long warehouseId;
    
    /** 仓库编码 */
    private String warehouseCode;
    
    /** 业务模式 */
    private BusinessMode businessMode;
    
    /** 在途数量 */
    private Integer inTransitQuantity;
    
    /** 统计日期 */
    private LocalDate statisticsDate;
    
    public InTransitInventoryAgg() {
        this.inTransitQuantity = 0;
    }
    
    public InTransitInventoryAgg(Long productId, String productSku, Long warehouseId, 
                                  String warehouseCode, BusinessMode businessMode, Integer inTransitQuantity) {
        this.productId = productId;
        this.productSku = productSku;
        this.warehouseId = warehouseId;
        this.warehouseCode = warehouseCode;
        this.businessMode = businessMode;
        this.inTransitQuantity = inTransitQuantity;
    }
    
    // Getters and Setters
    
    public Long getProductId() {
        return productId;
    }
    
    public void setProductId(Long productId) {
        this.productId = productId;
    }
    
    public String getProductSku() {
        return productSku;
    }
    
    public void setProductSku(String productSku) {
        this.productSku = productSku;
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
    
    public BusinessMode getBusinessMode() {
        return businessMode;
    }
    
    public void setBusinessMode(BusinessMode businessMode) {
        this.businessMode = businessMode;
    }
    
    public Integer getInTransitQuantity() {
        return inTransitQuantity;
    }
    
    public void setInTransitQuantity(Integer inTransitQuantity) {
        this.inTransitQuantity = inTransitQuantity;
    }
    
    public LocalDate getStatisticsDate() {
        return statisticsDate;
    }
    
    public void setStatisticsDate(LocalDate statisticsDate) {
        this.statisticsDate = statisticsDate;
    }
    
    @Override
    public String toString() {
        return "InTransitInventoryAgg{" +
                "productSku='" + productSku + '\'' +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", businessMode=" + businessMode +
                ", inTransitQuantity=" + inTransitQuantity +
                '}';
    }
}
