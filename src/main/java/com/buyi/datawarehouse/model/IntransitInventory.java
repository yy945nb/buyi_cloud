package com.buyi.datawarehouse.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 在途库存聚合模型
 * In-transit Inventory Aggregation Model
 * 
 * 用于按仓库维度聚合各种发货单的在途库存
 * Used to aggregate in-transit inventory from various shipment sources by warehouse dimension
 */
public class IntransitInventory implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 仓库ID（目的仓库） */
    private Long warehouseId;
    
    /** 仓库编码 */
    private String warehouseCode;
    
    /** 仓库名称 */
    private String warehouseName;
    
    /** SKU编码 */
    private String skuCode;
    
    /** 模式：REGIONAL（区域仓）或 FBA */
    private String mode;
    
    /** 在途数量 */
    private Integer intransitQuantity;
    
    /** 监控日期 */
    private LocalDate monitorDate;
    
    /** 来源：JH、LX_OWMS、FBA */
    private String source;
    
    /** 发货单数量 */
    private Integer shipmentCount;
    
    /** 最早发货日期 */
    private LocalDate earliestShipmentDate;
    
    /** 最晚预计到达日期 */
    private LocalDate latestExpectedArrivalDate;
    
    public IntransitInventory() {
        this.intransitQuantity = 0;
        this.shipmentCount = 0;
    }
    
    /**
     * 累加在途数量
     */
    public void addIntransitQuantity(Integer quantity) {
        if (quantity != null && quantity > 0) {
            this.intransitQuantity = (this.intransitQuantity == null ? 0 : this.intransitQuantity) + quantity;
        }
    }
    
    /**
     * 增加发货单计数
     */
    public void incrementShipmentCount() {
        this.shipmentCount = (this.shipmentCount == null ? 0 : this.shipmentCount) + 1;
    }
    
    /**
     * 更新最早发货日期
     */
    public void updateEarliestShipmentDate(LocalDate date) {
        if (date != null) {
            if (this.earliestShipmentDate == null || date.isBefore(this.earliestShipmentDate)) {
                this.earliestShipmentDate = date;
            }
        }
    }
    
    /**
     * 更新最晚预计到达日期
     */
    public void updateLatestExpectedArrivalDate(LocalDate date) {
        if (date != null) {
            if (this.latestExpectedArrivalDate == null || date.isAfter(this.latestExpectedArrivalDate)) {
                this.latestExpectedArrivalDate = date;
            }
        }
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
    
    public String getSkuCode() {
        return skuCode;
    }
    
    public void setSkuCode(String skuCode) {
        this.skuCode = skuCode;
    }
    
    public String getMode() {
        return mode;
    }
    
    public void setMode(String mode) {
        this.mode = mode;
    }
    
    public Integer getIntransitQuantity() {
        return intransitQuantity;
    }
    
    public void setIntransitQuantity(Integer intransitQuantity) {
        this.intransitQuantity = intransitQuantity;
    }
    
    public LocalDate getMonitorDate() {
        return monitorDate;
    }
    
    public void setMonitorDate(LocalDate monitorDate) {
        this.monitorDate = monitorDate;
    }
    
    public String getSource() {
        return source;
    }
    
    public void setSource(String source) {
        this.source = source;
    }
    
    public Integer getShipmentCount() {
        return shipmentCount;
    }
    
    public void setShipmentCount(Integer shipmentCount) {
        this.shipmentCount = shipmentCount;
    }
    
    public LocalDate getEarliestShipmentDate() {
        return earliestShipmentDate;
    }
    
    public void setEarliestShipmentDate(LocalDate earliestShipmentDate) {
        this.earliestShipmentDate = earliestShipmentDate;
    }
    
    public LocalDate getLatestExpectedArrivalDate() {
        return latestExpectedArrivalDate;
    }
    
    public void setLatestExpectedArrivalDate(LocalDate latestExpectedArrivalDate) {
        this.latestExpectedArrivalDate = latestExpectedArrivalDate;
    }
    
    @Override
    public String toString() {
        return "IntransitInventory{" +
                "warehouseId=" + warehouseId +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", skuCode='" + skuCode + '\'' +
                ", mode='" + mode + '\'' +
                ", intransitQuantity=" + intransitQuantity +
                ", source='" + source + '\'' +
                ", shipmentCount=" + shipmentCount +
                '}';
    }
}
