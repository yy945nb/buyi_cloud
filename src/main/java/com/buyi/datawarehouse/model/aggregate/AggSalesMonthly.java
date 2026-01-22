package com.buyi.datawarehouse.model.aggregate;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * 月销售汇总模型
 * Monthly Sales Aggregation Model
 */
public class AggSalesMonthly implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 主键 */
    private Long id;
    
    /** 年份 */
    private Integer year;
    
    /** 月份 */
    private Integer month;
    
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
    
    /** 日均销售额 */
    private BigDecimal avgDailySales;
    
    /** 月环比增长率% */
    private BigDecimal momGrowthRate;
    
    /** 同比增长率% */
    private BigDecimal yoyGrowthRate;
    
    public AggSalesMonthly() {
        this.orderCount = 0;
        this.quantitySold = 0;
        this.grossAmount = BigDecimal.ZERO;
        this.netAmount = BigDecimal.ZERO;
        this.costAmount = BigDecimal.ZERO;
        this.profitAmount = BigDecimal.ZERO;
        this.profitRate = BigDecimal.ZERO;
        this.avgDailySales = BigDecimal.ZERO;
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
     * 计算日均销售额
     * @param daysInMonth 月份天数
     */
    public void calculateAvgDailySales(int daysInMonth) {
        if (netAmount != null && daysInMonth > 0) {
            this.avgDailySales = netAmount.divide(
                    BigDecimal.valueOf(daysInMonth), 2, RoundingMode.HALF_UP);
        }
    }
    
    /**
     * 计算环比增长率
     * @param previousMonthAmount 上月销售额
     */
    public void calculateMomGrowthRate(BigDecimal previousMonthAmount) {
        if (previousMonthAmount != null && previousMonthAmount.compareTo(BigDecimal.ZERO) > 0) {
            this.momGrowthRate = netAmount.subtract(previousMonthAmount)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(previousMonthAmount, 2, RoundingMode.HALF_UP);
        }
    }
    
    /**
     * 计算同比增长率
     * @param lastYearAmount 去年同期销售额
     */
    public void calculateYoyGrowthRate(BigDecimal lastYearAmount) {
        if (lastYearAmount != null && lastYearAmount.compareTo(BigDecimal.ZERO) > 0) {
            this.yoyGrowthRate = netAmount.subtract(lastYearAmount)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(lastYearAmount, 2, RoundingMode.HALF_UP);
        }
    }

    // Getters and Setters
    
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Integer getMonth() {
        return month;
    }

    public void setMonth(Integer month) {
        this.month = month;
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

    public BigDecimal getAvgDailySales() {
        return avgDailySales;
    }

    public void setAvgDailySales(BigDecimal avgDailySales) {
        this.avgDailySales = avgDailySales;
    }

    public BigDecimal getMomGrowthRate() {
        return momGrowthRate;
    }

    public void setMomGrowthRate(BigDecimal momGrowthRate) {
        this.momGrowthRate = momGrowthRate;
    }

    public BigDecimal getYoyGrowthRate() {
        return yoyGrowthRate;
    }

    public void setYoyGrowthRate(BigDecimal yoyGrowthRate) {
        this.yoyGrowthRate = yoyGrowthRate;
    }
    
    @Override
    public String toString() {
        return "AggSalesMonthly{" +
                "year=" + year +
                ", month=" + month +
                ", productKey=" + productKey +
                ", shopKey=" + shopKey +
                ", orderCount=" + orderCount +
                ", netAmount=" + netAmount +
                ", profitRate=" + profitRate +
                ", momGrowthRate=" + momGrowthRate +
                ", yoyGrowthRate=" + yoyGrowthRate +
                '}';
    }
}
