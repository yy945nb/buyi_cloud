package com.buyi.ruleengine.stocking.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * 历史销售数据模型
 * Sales History Data Model
 * 
 * 用于存储和计算加权平均日销量
 */
public class SalesHistoryData implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 商品ID */
    private Long productId;
    
    /** 商品SKU */
    private String sku;
    
    /** 最近30天销售数据 */
    private List<DailySales> last30DaysSales;
    
    /** 最近15天销售数据 */
    private List<DailySales> last15DaysSales;
    
    /** 最近7天销售数据 */
    private List<DailySales> last7DaysSales;
    
    /** 30天总销量 */
    private Integer totalSales30Days;
    
    /** 15天总销量 */
    private Integer totalSales15Days;
    
    /** 7天总销量 */
    private Integer totalSales7Days;
    
    /** 数据统计截止日期 */
    private LocalDate dataEndDate;
    
    public SalesHistoryData() {
        this.last30DaysSales = new ArrayList<>();
        this.last15DaysSales = new ArrayList<>();
        this.last7DaysSales = new ArrayList<>();
    }
    
    /**
     * 日销售数据内部类
     */
    public static class DailySales implements Serializable {
        private static final long serialVersionUID = 1L;
        
        private LocalDate date;
        private Integer quantity;
        private BigDecimal amount;
        
        public DailySales() {
        }
        
        public DailySales(LocalDate date, Integer quantity) {
            this.date = date;
            this.quantity = quantity;
        }
        
        public DailySales(LocalDate date, Integer quantity, BigDecimal amount) {
            this.date = date;
            this.quantity = quantity;
            this.amount = amount;
        }
        
        public LocalDate getDate() {
            return date;
        }
        
        public void setDate(LocalDate date) {
            this.date = date;
        }
        
        public Integer getQuantity() {
            return quantity;
        }
        
        public void setQuantity(Integer quantity) {
            this.quantity = quantity;
        }
        
        public BigDecimal getAmount() {
            return amount;
        }
        
        public void setAmount(BigDecimal amount) {
            this.amount = amount;
        }
        
        @Override
        public String toString() {
            return "DailySales{date=" + date + ", quantity=" + quantity + '}';
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
    
    public List<DailySales> getLast30DaysSales() {
        return last30DaysSales;
    }
    
    public void setLast30DaysSales(List<DailySales> last30DaysSales) {
        this.last30DaysSales = last30DaysSales;
    }
    
    public List<DailySales> getLast15DaysSales() {
        return last15DaysSales;
    }
    
    public void setLast15DaysSales(List<DailySales> last15DaysSales) {
        this.last15DaysSales = last15DaysSales;
    }
    
    public List<DailySales> getLast7DaysSales() {
        return last7DaysSales;
    }
    
    public void setLast7DaysSales(List<DailySales> last7DaysSales) {
        this.last7DaysSales = last7DaysSales;
    }
    
    public Integer getTotalSales30Days() {
        return totalSales30Days;
    }
    
    public void setTotalSales30Days(Integer totalSales30Days) {
        this.totalSales30Days = totalSales30Days;
    }
    
    public Integer getTotalSales15Days() {
        return totalSales15Days;
    }
    
    public void setTotalSales15Days(Integer totalSales15Days) {
        this.totalSales15Days = totalSales15Days;
    }
    
    public Integer getTotalSales7Days() {
        return totalSales7Days;
    }
    
    public void setTotalSales7Days(Integer totalSales7Days) {
        this.totalSales7Days = totalSales7Days;
    }
    
    public LocalDate getDataEndDate() {
        return dataEndDate;
    }
    
    public void setDataEndDate(LocalDate dataEndDate) {
        this.dataEndDate = dataEndDate;
    }
    
    @Override
    public String toString() {
        return "SalesHistoryData{" +
                "productId=" + productId +
                ", sku='" + sku + '\'' +
                ", totalSales30Days=" + totalSales30Days +
                ", totalSales15Days=" + totalSales15Days +
                ", totalSales7Days=" + totalSales7Days +
                ", dataEndDate=" + dataEndDate +
                '}';
    }
}
