package com.buyi.datawarehouse.model.fact;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 库存事实表模型（快照事实表）
 * Inventory Fact Model for Data Warehouse (Snapshot Fact)
 */
public class FactInventory implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 库存键（数仓主键） */
    private Long inventoryKey;
    
    /** 日期键（快照日期） */
    private Integer dateKey;
    
    /** 商品键 */
    private Long productKey;
    
    /** 仓库键 */
    private Long warehouseKey;
    
    /** 店铺键 */
    private Long shopKey;
    
    /** 模式：REGIONAL（区域仓）或 FBA */
    private String mode;
    
    /** 在库数量 */
    private Integer onHandQuantity;
    
    /** 可用数量 */
    private Integer availableQuantity;
    
    /** 预留数量 */
    private Integer reservedQuantity;
    
    /** 在途数量 */
    private Integer inTransitQuantity;
    
    /** 待入库数量 */
    private Integer pendingQuantity;
    
    /** 单位成本 */
    private BigDecimal unitCost;
    
    /** 库存价值 */
    private BigDecimal inventoryValue;
    
    /** 库存可供天数 */
    private Integer daysOfSupply;
    
    /** 周转天数 */
    private Integer turnoverDays;
    
    /** 最后入库日期 */
    private LocalDate lastInboundDate;
    
    /** 最后出库日期 */
    private LocalDate lastOutboundDate;
    
    /** 快照时间 */
    private LocalDateTime snapshotTime;
    
    public FactInventory() {
        this.onHandQuantity = 0;
        this.availableQuantity = 0;
        this.reservedQuantity = 0;
        this.inTransitQuantity = 0;
        this.pendingQuantity = 0;
    }
    
    /**
     * 计算库存价值
     */
    public void calculateInventoryValue() {
        if (onHandQuantity != null && unitCost != null) {
            this.inventoryValue = unitCost.multiply(BigDecimal.valueOf(onHandQuantity));
        }
    }
    
    /**
     * 计算可用数量
     */
    public void calculateAvailableQuantity() {
        if (onHandQuantity != null) {
            int reserved = reservedQuantity != null ? reservedQuantity : 0;
            this.availableQuantity = onHandQuantity - reserved;
        }
    }
    
    /**
     * 计算库存可供天数
     * @param dailyAverageSales 日均销量
     */
    public void calculateDaysOfSupply(double dailyAverageSales) {
        if (availableQuantity != null && dailyAverageSales > 0) {
            this.daysOfSupply = (int) Math.round(availableQuantity / dailyAverageSales);
        }
    }

    // Getters and Setters
    
    public Long getInventoryKey() {
        return inventoryKey;
    }

    public void setInventoryKey(Long inventoryKey) {
        this.inventoryKey = inventoryKey;
    }

    public Integer getDateKey() {
        return dateKey;
    }

    public void setDateKey(Integer dateKey) {
        this.dateKey = dateKey;
    }

    public Long getProductKey() {
        return productKey;
    }

    public void setProductKey(Long productKey) {
        this.productKey = productKey;
    }

    public Long getWarehouseKey() {
        return warehouseKey;
    }

    public void setWarehouseKey(Long warehouseKey) {
        this.warehouseKey = warehouseKey;
    }

    public Long getShopKey() {
        return shopKey;
    }

    public void setShopKey(Long shopKey) {
        this.shopKey = shopKey;
    }

    public String getMode() {
        return mode;
    }

    public void setMode(String mode) {
        this.mode = mode;
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

    public Integer getInTransitQuantity() {
        return inTransitQuantity;
    }

    public void setInTransitQuantity(Integer inTransitQuantity) {
        this.inTransitQuantity = inTransitQuantity;
    }

    public Integer getPendingQuantity() {
        return pendingQuantity;
    }

    public void setPendingQuantity(Integer pendingQuantity) {
        this.pendingQuantity = pendingQuantity;
    }

    public BigDecimal getUnitCost() {
        return unitCost;
    }

    public void setUnitCost(BigDecimal unitCost) {
        this.unitCost = unitCost;
    }

    public BigDecimal getInventoryValue() {
        return inventoryValue;
    }

    public void setInventoryValue(BigDecimal inventoryValue) {
        this.inventoryValue = inventoryValue;
    }

    public Integer getDaysOfSupply() {
        return daysOfSupply;
    }

    public void setDaysOfSupply(Integer daysOfSupply) {
        this.daysOfSupply = daysOfSupply;
    }

    public Integer getTurnoverDays() {
        return turnoverDays;
    }

    public void setTurnoverDays(Integer turnoverDays) {
        this.turnoverDays = turnoverDays;
    }

    public LocalDate getLastInboundDate() {
        return lastInboundDate;
    }

    public void setLastInboundDate(LocalDate lastInboundDate) {
        this.lastInboundDate = lastInboundDate;
    }

    public LocalDate getLastOutboundDate() {
        return lastOutboundDate;
    }

    public void setLastOutboundDate(LocalDate lastOutboundDate) {
        this.lastOutboundDate = lastOutboundDate;
    }

    public LocalDateTime getSnapshotTime() {
        return snapshotTime;
    }

    public void setSnapshotTime(LocalDateTime snapshotTime) {
        this.snapshotTime = snapshotTime;
    }
    
    @Override
    public String toString() {
        return "FactInventory{" +
                "inventoryKey=" + inventoryKey +
                ", dateKey=" + dateKey +
                ", productKey=" + productKey +
                ", warehouseKey=" + warehouseKey +
                ", onHandQuantity=" + onHandQuantity +
                ", availableQuantity=" + availableQuantity +
                ", inventoryValue=" + inventoryValue +
                ", daysOfSupply=" + daysOfSupply +
                '}';
    }
}
