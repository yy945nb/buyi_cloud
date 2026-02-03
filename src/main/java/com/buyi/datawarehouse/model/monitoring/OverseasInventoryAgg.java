package com.buyi.datawarehouse.model.monitoring;

import com.buyi.datawarehouse.enums.BusinessMode;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * 海外仓库存聚合数据模型
 * Overseas Warehouse Inventory Aggregation Model
 * 
 * 用于按产品、仓库、业务模式维度聚合海外仓库存
 * JH+LX合并统计，FBA单独统计
 */
public class OverseasInventoryAgg implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 产品ID */
    private Long productId;
    
    /** 产品SKU */
    private String productSku;
    
    /** 仓库ID */
    private Long warehouseId;
    
    /** 仓库编码 */
    private String warehouseCode;
    
    /** 业务模式（JH_LX合并或FBA） */
    private BusinessMode businessMode;
    
    /** 现有库存数量 */
    private Integer onHandQuantity;
    
    /** 可用数量 */
    private Integer availableQuantity;
    
    /** 预留数量 */
    private Integer reservedQuantity;
    
    /** 数据日期 */
    private LocalDate dataDate;
    
    public OverseasInventoryAgg() {
        this.onHandQuantity = 0;
        this.availableQuantity = 0;
        this.reservedQuantity = 0;
    }
    
    public OverseasInventoryAgg(Long productId, String productSku, Long warehouseId,
                                String warehouseCode, BusinessMode businessMode,
                                Integer onHandQuantity, Integer availableQuantity) {
        this.productId = productId;
        this.productSku = productSku;
        this.warehouseId = warehouseId;
        this.warehouseCode = warehouseCode;
        this.businessMode = businessMode;
        this.onHandQuantity = onHandQuantity;
        this.availableQuantity = availableQuantity;
        this.reservedQuantity = onHandQuantity - availableQuantity;
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
    
    public Integer getOnHandQuantity() {
        return onHandQuantity;
    }
    
    public void setOnHandQuantity(Integer onHandQuantity) {
        this.onHandQuantity = onHandQuantity;
    }
    
    public Integer getAvailableQuantity() {
        return availableQuantity;
    }
    
    public void setAvailableQuantity(Integer availableQuantity) {
        this.availableQuantity = availableQuantity;
    }
    
    public Integer getReservedQuantity() {
        return reservedQuantity;
    }
    
    public void setReservedQuantity(Integer reservedQuantity) {
        this.reservedQuantity = reservedQuantity;
    }
    
    public LocalDate getDataDate() {
        return dataDate;
    }
    
    public void setDataDate(LocalDate dataDate) {
        this.dataDate = dataDate;
    }
    
    @Override
    public String toString() {
        return "OverseasInventoryAgg{" +
                "productSku='" + productSku + '\'' +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", businessMode=" + businessMode +
                ", onHandQuantity=" + onHandQuantity +
                ", availableQuantity=" + availableQuantity +
                '}';
    }
}
