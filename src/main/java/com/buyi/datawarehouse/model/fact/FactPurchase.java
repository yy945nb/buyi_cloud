package com.buyi.datawarehouse.model.fact;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 采购事实表模型
 * Purchase Fact Model for Data Warehouse
 */
public class FactPurchase implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 采购键（数仓主键） */
    private Long purchaseKey;
    
    /** 日期键 */
    private Integer dateKey;
    
    /** 商品键 */
    private Long productKey;
    
    /** 目标仓库键 */
    private Long warehouseKey;
    
    /** 供应商键 */
    private Long supplierKey;
    
    /** 采购单号 */
    private String purchaseOrderId;
    
    /** 采购数量 */
    private Integer quantity;
    
    /** 采购单价 */
    private BigDecimal unitCost;
    
    /** 采购总金额 */
    private BigDecimal totalCost;
    
    /** 运费 */
    private BigDecimal freightCost;
    
    /** 其他费用 */
    private BigDecimal otherCost;
    
    /** 订单状态 */
    private String orderStatus;
    
    /** 预计到货日期 */
    private LocalDate expectedDate;
    
    /** 实际到货日期 */
    private LocalDate actualDate;
    
    /** 采购周期(天) */
    private Integer leadTimeDays;
    
    /** 创建时间 */
    private LocalDateTime createTime;
    
    public FactPurchase() {
        this.freightCost = BigDecimal.ZERO;
        this.otherCost = BigDecimal.ZERO;
    }
    
    /**
     * 计算采购总金额
     */
    public void calculateTotalCost() {
        if (quantity != null && unitCost != null) {
            this.totalCost = unitCost.multiply(BigDecimal.valueOf(quantity))
                    .add(freightCost != null ? freightCost : BigDecimal.ZERO)
                    .add(otherCost != null ? otherCost : BigDecimal.ZERO);
        }
    }
    
    /**
     * 计算采购周期
     */
    public void calculateLeadTime() {
        if (actualDate != null && createTime != null) {
            this.leadTimeDays = (int) (actualDate.toEpochDay() - 
                    createTime.toLocalDate().toEpochDay());
        }
    }

    // Getters and Setters
    
    public Long getPurchaseKey() {
        return purchaseKey;
    }

    public void setPurchaseKey(Long purchaseKey) {
        this.purchaseKey = purchaseKey;
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

    public Long getSupplierKey() {
        return supplierKey;
    }

    public void setSupplierKey(Long supplierKey) {
        this.supplierKey = supplierKey;
    }

    public String getPurchaseOrderId() {
        return purchaseOrderId;
    }

    public void setPurchaseOrderId(String purchaseOrderId) {
        this.purchaseOrderId = purchaseOrderId;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitCost() {
        return unitCost;
    }

    public void setUnitCost(BigDecimal unitCost) {
        this.unitCost = unitCost;
    }

    public BigDecimal getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(BigDecimal totalCost) {
        this.totalCost = totalCost;
    }

    public BigDecimal getFreightCost() {
        return freightCost;
    }

    public void setFreightCost(BigDecimal freightCost) {
        this.freightCost = freightCost;
    }

    public BigDecimal getOtherCost() {
        return otherCost;
    }

    public void setOtherCost(BigDecimal otherCost) {
        this.otherCost = otherCost;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public LocalDate getExpectedDate() {
        return expectedDate;
    }

    public void setExpectedDate(LocalDate expectedDate) {
        this.expectedDate = expectedDate;
    }

    public LocalDate getActualDate() {
        return actualDate;
    }

    public void setActualDate(LocalDate actualDate) {
        this.actualDate = actualDate;
    }

    public Integer getLeadTimeDays() {
        return leadTimeDays;
    }

    public void setLeadTimeDays(Integer leadTimeDays) {
        this.leadTimeDays = leadTimeDays;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
    
    @Override
    public String toString() {
        return "FactPurchase{" +
                "purchaseKey=" + purchaseKey +
                ", dateKey=" + dateKey +
                ", purchaseOrderId='" + purchaseOrderId + '\'' +
                ", quantity=" + quantity +
                ", totalCost=" + totalCost +
                ", orderStatus='" + orderStatus + '\'' +
                ", leadTimeDays=" + leadTimeDays +
                '}';
    }
}
