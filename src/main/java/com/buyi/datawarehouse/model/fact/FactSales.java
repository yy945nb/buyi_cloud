package com.buyi.datawarehouse.model.fact;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 销售事实表模型
 * Sales Fact Model for Data Warehouse
 */
public class FactSales implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 销售键（数仓主键） */
    private Long salesKey;
    
    /** 日期键 */
    private Integer dateKey;
    
    /** 商品键 */
    private Long productKey;
    
    /** 店铺键 */
    private Long shopKey;
    
    /** 仓库键 */
    private Long warehouseKey;
    
    /** 地区键 */
    private Long regionKey;
    
    /** 订单号 */
    private String orderId;
    
    /** 订单项ID */
    private String orderItemId;
    
    /** 销售数量 */
    private Integer quantity;
    
    /** 单价 */
    private BigDecimal unitPrice;
    
    /** 销售总额 */
    private BigDecimal grossAmount;
    
    /** 折扣金额 */
    private BigDecimal discountAmount;
    
    /** 净销售额 */
    private BigDecimal netAmount;
    
    /** 成本金额 */
    private BigDecimal costAmount;
    
    /** 利润金额 */
    private BigDecimal profitAmount;
    
    /** 运费 */
    private BigDecimal shippingFee;
    
    /** 平台费用 */
    private BigDecimal platformFee;
    
    /** 订单状态 */
    private String orderStatus;
    
    /** 支付方式 */
    private String paymentMethod;
    
    /** 创建时间 */
    private LocalDateTime createTime;
    
    /** 更新时间 */
    private LocalDateTime updateTime;
    
    public FactSales() {
        this.discountAmount = BigDecimal.ZERO;
        this.shippingFee = BigDecimal.ZERO;
        this.platformFee = BigDecimal.ZERO;
    }
    
    /**
     * 计算利润金额
     */
    public void calculateProfit() {
        if (netAmount != null && costAmount != null) {
            this.profitAmount = netAmount.subtract(costAmount)
                    .subtract(shippingFee != null ? shippingFee : BigDecimal.ZERO)
                    .subtract(platformFee != null ? platformFee : BigDecimal.ZERO);
        }
    }
    
    /**
     * 计算净销售额
     */
    public void calculateNetAmount() {
        if (grossAmount != null) {
            this.netAmount = grossAmount.subtract(
                    discountAmount != null ? discountAmount : BigDecimal.ZERO);
        }
    }

    // Getters and Setters
    
    public Long getSalesKey() {
        return salesKey;
    }

    public void setSalesKey(Long salesKey) {
        this.salesKey = salesKey;
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

    public Long getShopKey() {
        return shopKey;
    }

    public void setShopKey(Long shopKey) {
        this.shopKey = shopKey;
    }

    public Long getWarehouseKey() {
        return warehouseKey;
    }

    public void setWarehouseKey(Long warehouseKey) {
        this.warehouseKey = warehouseKey;
    }

    public Long getRegionKey() {
        return regionKey;
    }

    public void setRegionKey(Long regionKey) {
        this.regionKey = regionKey;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(String orderItemId) {
        this.orderItemId = orderItemId;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public BigDecimal getGrossAmount() {
        return grossAmount;
    }

    public void setGrossAmount(BigDecimal grossAmount) {
        this.grossAmount = grossAmount;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getNetAmount() {
        return netAmount;
    }

    public void setNetAmount(BigDecimal netAmount) {
        this.netAmount = netAmount;
    }

    public BigDecimal getCostAmount() {
        return costAmount;
    }

    public void setCostAmount(BigDecimal costAmount) {
        this.costAmount = costAmount;
    }

    public BigDecimal getProfitAmount() {
        return profitAmount;
    }

    public void setProfitAmount(BigDecimal profitAmount) {
        this.profitAmount = profitAmount;
    }

    public BigDecimal getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(BigDecimal shippingFee) {
        this.shippingFee = shippingFee;
    }

    public BigDecimal getPlatformFee() {
        return platformFee;
    }

    public void setPlatformFee(BigDecimal platformFee) {
        this.platformFee = platformFee;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }
    
    @Override
    public String toString() {
        return "FactSales{" +
                "salesKey=" + salesKey +
                ", dateKey=" + dateKey +
                ", orderId='" + orderId + '\'' +
                ", quantity=" + quantity +
                ", netAmount=" + netAmount +
                ", profitAmount=" + profitAmount +
                ", orderStatus='" + orderStatus + '\'' +
                '}';
    }
}
