package com.buyi.datawarehouse.model.aggregate;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * 日销售汇总模型
 * Daily Sales Aggregation Model
 */
public class AggSalesDaily implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 主键 */
    private Long id;
    
    /** 日期键 */
    private Integer dateKey;
    
    /** 商品键 */
    private Long productKey;
    
    /** 店铺键 */
    private Long shopKey;
    
    /** 订单数 */
    private Integer orderCount;
    
    /** 销售数量 */
    private Integer quantitySold;
    
    /** 销售总额 */
    private BigDecimal grossAmount;
    
    /** 净销售额 */
    private BigDecimal netAmount;
    
    /** 成本总额 */
    private BigDecimal costAmount;
    
    /** 利润总额 */
    private BigDecimal profitAmount;
    
    /** 利润率% */
    private BigDecimal profitRate;
    
    /** 客单价 */
    private BigDecimal avgOrderValue;
    
    /** 退货数量 */
    private Integer returnQuantity;
    
    /** 退货金额 */
    private BigDecimal returnAmount;
    
    public AggSalesDaily() {
        this.orderCount = 0;
        this.quantitySold = 0;
        this.grossAmount = BigDecimal.ZERO;
        this.netAmount = BigDecimal.ZERO;
        this.costAmount = BigDecimal.ZERO;
        this.profitAmount = BigDecimal.ZERO;
        this.profitRate = BigDecimal.ZERO;
        this.avgOrderValue = BigDecimal.ZERO;
        this.returnQuantity = 0;
        this.returnAmount = BigDecimal.ZERO;
    }
    
    /**
     * 计算利润率
     */
    public void calculateProfitRate() {
        if (netAmount != null && netAmount.compareTo(BigDecimal.ZERO) > 0) {
            this.profitRate = profitAmount
                    .multiply(BigDecimal.valueOf(100))
                    .divide(netAmount, 2, RoundingMode.HALF_UP);
        }
    }
    
    /**
     * 计算客单价
     */
    public void calculateAvgOrderValue() {
        if (orderCount != null && orderCount > 0) {
            this.avgOrderValue = netAmount.divide(
                    BigDecimal.valueOf(orderCount), 2, RoundingMode.HALF_UP);
        }
    }
    
    /**
     * 计算派生指标
     */
    public void calculateDerivedMetrics() {
        calculateProfitRate();
        calculateAvgOrderValue();
    }

    // Getters and Setters
    
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public Integer getOrderCount() {
        return orderCount;
    }

    public void setOrderCount(Integer orderCount) {
        this.orderCount = orderCount;
    }

    public Integer getQuantitySold() {
        return quantitySold;
    }

    public void setQuantitySold(Integer quantitySold) {
        this.quantitySold = quantitySold;
    }

    public BigDecimal getGrossAmount() {
        return grossAmount;
    }

    public void setGrossAmount(BigDecimal grossAmount) {
        this.grossAmount = grossAmount;
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

    public BigDecimal getProfitRate() {
        return profitRate;
    }

    public void setProfitRate(BigDecimal profitRate) {
        this.profitRate = profitRate;
    }

    public BigDecimal getAvgOrderValue() {
        return avgOrderValue;
    }

    public void setAvgOrderValue(BigDecimal avgOrderValue) {
        this.avgOrderValue = avgOrderValue;
    }

    public Integer getReturnQuantity() {
        return returnQuantity;
    }

    public void setReturnQuantity(Integer returnQuantity) {
        this.returnQuantity = returnQuantity;
    }

    public BigDecimal getReturnAmount() {
        return returnAmount;
    }

    public void setReturnAmount(BigDecimal returnAmount) {
        this.returnAmount = returnAmount;
    }
    
    @Override
    public String toString() {
        return "AggSalesDaily{" +
                "dateKey=" + dateKey +
                ", productKey=" + productKey +
                ", shopKey=" + shopKey +
                ", orderCount=" + orderCount +
                ", quantitySold=" + quantitySold +
                ", netAmount=" + netAmount +
                ", profitRate=" + profitRate +
                '}';
    }
}
