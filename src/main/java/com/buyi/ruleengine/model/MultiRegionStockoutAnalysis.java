package com.buyi.ruleengine.model;

import com.buyi.ruleengine.enums.RiskLevel;
import com.buyi.ruleengine.stocking.enums.ShippingRegion;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.EnumMap;
import java.util.Map;

/**
 * 多区域断货分析结果
 * Multi-Region Stockout Analysis Result
 * 
 * 用于分析商品在美东、美西、美中、美南四个区域仓库的断货风险情况
 * 特别适用于爆款商品的多区域断货追踪
 */
public class MultiRegionStockoutAnalysis implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 商品ID */
    private Long productId;
    
    /** 商品SKU */
    private String sku;
    
    /** 分析基准日期 */
    private LocalDate analysisDate;
    
    /** 各区域断货分析结果 */
    private Map<ShippingRegion, RegionStockoutDetail> regionDetails;
    
    /** 存在断货风险的区域数量 */
    private int atRiskRegionCount;
    
    /** 已断货的区域数量 */
    private int stockoutRegionCount;
    
    /** 是否触发爆款模型（当多个区域同时断货时触发） */
    private boolean hotSellingModelTriggered;
    
    /** 综合风险等级 */
    private RiskLevel overallRiskLevel;
    
    /** 建议的备货策略说明 */
    private String recommendedStrategy;
    
    public MultiRegionStockoutAnalysis() {
        this.regionDetails = new EnumMap<>(ShippingRegion.class);
        this.atRiskRegionCount = 0;
        this.stockoutRegionCount = 0;
        this.hotSellingModelTriggered = false;
        this.overallRiskLevel = RiskLevel.OK;
    }
    
    /**
     * 单个区域的断货详情
     */
    public static class RegionStockoutDetail implements Serializable {
        private static final long serialVersionUID = 1L;
        
        /** 区域 */
        private ShippingRegion region;
        
        /** 风险等级 */
        private RiskLevel riskLevel;
        
        /** 当前区域库存 */
        private Integer currentInventory;
        
        /** 区域日均销量 */
        private BigDecimal dailyAvgSales;
        
        /** 预计断货天数 */
        private Integer daysToStockout;
        
        /** 预计缺货量 */
        private BigDecimal expectedShortage;
        
        /** 建议补货量 */
        private Integer suggestedReplenishment;
        
        /** 海运时间（天） */
        private Integer shippingDays;
        
        /** 预计最早补货到达日期 */
        private LocalDate earliestArrivalDate;
        
        /** 是否有在途库存 */
        private boolean hasInTransit;
        
        /** 在途库存数量 */
        private Integer inTransitQuantity;
        
        /** 详细说明 */
        private String note;
        
        public RegionStockoutDetail() {
            this.riskLevel = RiskLevel.OK;
            this.hasInTransit = false;
        }
        
        // Getters and Setters
        public ShippingRegion getRegion() {
            return region;
        }
        
        public void setRegion(ShippingRegion region) {
            this.region = region;
        }
        
        public RiskLevel getRiskLevel() {
            return riskLevel;
        }
        
        public void setRiskLevel(RiskLevel riskLevel) {
            this.riskLevel = riskLevel;
        }
        
        public Integer getCurrentInventory() {
            return currentInventory;
        }
        
        public void setCurrentInventory(Integer currentInventory) {
            this.currentInventory = currentInventory;
        }
        
        public BigDecimal getDailyAvgSales() {
            return dailyAvgSales;
        }
        
        public void setDailyAvgSales(BigDecimal dailyAvgSales) {
            this.dailyAvgSales = dailyAvgSales;
        }
        
        public Integer getDaysToStockout() {
            return daysToStockout;
        }
        
        public void setDaysToStockout(Integer daysToStockout) {
            this.daysToStockout = daysToStockout;
        }
        
        public BigDecimal getExpectedShortage() {
            return expectedShortage;
        }
        
        public void setExpectedShortage(BigDecimal expectedShortage) {
            this.expectedShortage = expectedShortage;
        }
        
        public Integer getSuggestedReplenishment() {
            return suggestedReplenishment;
        }
        
        public void setSuggestedReplenishment(Integer suggestedReplenishment) {
            this.suggestedReplenishment = suggestedReplenishment;
        }
        
        public Integer getShippingDays() {
            return shippingDays;
        }
        
        public void setShippingDays(Integer shippingDays) {
            this.shippingDays = shippingDays;
        }
        
        public LocalDate getEarliestArrivalDate() {
            return earliestArrivalDate;
        }
        
        public void setEarliestArrivalDate(LocalDate earliestArrivalDate) {
            this.earliestArrivalDate = earliestArrivalDate;
        }
        
        public boolean isHasInTransit() {
            return hasInTransit;
        }
        
        public void setHasInTransit(boolean hasInTransit) {
            this.hasInTransit = hasInTransit;
        }
        
        public Integer getInTransitQuantity() {
            return inTransitQuantity;
        }
        
        public void setInTransitQuantity(Integer inTransitQuantity) {
            this.inTransitQuantity = inTransitQuantity;
        }
        
        public String getNote() {
            return note;
        }
        
        public void setNote(String note) {
            this.note = note;
        }
        
        @Override
        public String toString() {
            return "RegionStockoutDetail{" +
                    "region=" + region +
                    ", riskLevel=" + riskLevel +
                    ", currentInventory=" + currentInventory +
                    ", daysToStockout=" + daysToStockout +
                    ", suggestedReplenishment=" + suggestedReplenishment +
                    '}';
        }
    }
    
    /**
     * 添加区域分析结果
     */
    public void addRegionDetail(RegionStockoutDetail detail) {
        if (detail != null && detail.getRegion() != null) {
            regionDetails.put(detail.getRegion(), detail);
            updateCounters(detail);
        }
    }
    
    /**
     * 更新计数器和整体风险等级
     */
    private void updateCounters(RegionStockoutDetail detail) {
        if (detail.getRiskLevel() == RiskLevel.OUTAGE) {
            stockoutRegionCount++;
            atRiskRegionCount++;
        } else if (detail.getRiskLevel() == RiskLevel.AT_RISK) {
            atRiskRegionCount++;
        }
        
        // 当2个及以上区域存在风险时，触发爆款模型
        if (atRiskRegionCount >= 2) {
            hotSellingModelTriggered = true;
        }
        
        // 更新整体风险等级
        updateOverallRiskLevel();
    }
    
    /**
     * 根据各区域风险情况更新整体风险等级
     */
    private void updateOverallRiskLevel() {
        if (stockoutRegionCount >= 2) {
            // 2个及以上区域已断货 - 严重风险
            overallRiskLevel = RiskLevel.OUTAGE;
        } else if (stockoutRegionCount == 1 || atRiskRegionCount >= 2) {
            // 1个区域已断货 或 2个及以上区域存在风险
            overallRiskLevel = RiskLevel.AT_RISK;
        } else if (atRiskRegionCount == 1) {
            // 1个区域存在风险
            overallRiskLevel = RiskLevel.AT_RISK;
        } else {
            overallRiskLevel = RiskLevel.OK;
        }
    }
    
    /**
     * 获取所有存在风险的区域
     */
    public Map<ShippingRegion, RegionStockoutDetail> getAtRiskRegions() {
        Map<ShippingRegion, RegionStockoutDetail> atRiskRegions = new EnumMap<>(ShippingRegion.class);
        for (Map.Entry<ShippingRegion, RegionStockoutDetail> entry : regionDetails.entrySet()) {
            if (entry.getValue().getRiskLevel() != RiskLevel.OK) {
                atRiskRegions.put(entry.getKey(), entry.getValue());
            }
        }
        return atRiskRegions;
    }
    
    /**
     * 获取已断货的区域
     */
    public Map<ShippingRegion, RegionStockoutDetail> getStockoutRegions() {
        Map<ShippingRegion, RegionStockoutDetail> stockoutRegions = new EnumMap<>(ShippingRegion.class);
        for (Map.Entry<ShippingRegion, RegionStockoutDetail> entry : regionDetails.entrySet()) {
            if (entry.getValue().getRiskLevel() == RiskLevel.OUTAGE) {
                stockoutRegions.put(entry.getKey(), entry.getValue());
            }
        }
        return stockoutRegions;
    }
    
    /**
     * 计算总的建议补货量（所有区域汇总）
     */
    public int getTotalSuggestedReplenishment() {
        int total = 0;
        for (RegionStockoutDetail detail : regionDetails.values()) {
            if (detail.getSuggestedReplenishment() != null) {
                total += detail.getSuggestedReplenishment();
            }
        }
        return total;
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
    
    public LocalDate getAnalysisDate() {
        return analysisDate;
    }
    
    public void setAnalysisDate(LocalDate analysisDate) {
        this.analysisDate = analysisDate;
    }
    
    public Map<ShippingRegion, RegionStockoutDetail> getRegionDetails() {
        return regionDetails;
    }
    
    public void setRegionDetails(Map<ShippingRegion, RegionStockoutDetail> regionDetails) {
        this.regionDetails = regionDetails;
    }
    
    public int getAtRiskRegionCount() {
        return atRiskRegionCount;
    }
    
    public void setAtRiskRegionCount(int atRiskRegionCount) {
        this.atRiskRegionCount = atRiskRegionCount;
    }
    
    public int getStockoutRegionCount() {
        return stockoutRegionCount;
    }
    
    public void setStockoutRegionCount(int stockoutRegionCount) {
        this.stockoutRegionCount = stockoutRegionCount;
    }
    
    public boolean isHotSellingModelTriggered() {
        return hotSellingModelTriggered;
    }
    
    public void setHotSellingModelTriggered(boolean hotSellingModelTriggered) {
        this.hotSellingModelTriggered = hotSellingModelTriggered;
    }
    
    public RiskLevel getOverallRiskLevel() {
        return overallRiskLevel;
    }
    
    public void setOverallRiskLevel(RiskLevel overallRiskLevel) {
        this.overallRiskLevel = overallRiskLevel;
    }
    
    public String getRecommendedStrategy() {
        return recommendedStrategy;
    }
    
    public void setRecommendedStrategy(String recommendedStrategy) {
        this.recommendedStrategy = recommendedStrategy;
    }
    
    @Override
    public String toString() {
        return "MultiRegionStockoutAnalysis{" +
                "sku='" + sku + '\'' +
                ", analysisDate=" + analysisDate +
                ", atRiskRegionCount=" + atRiskRegionCount +
                ", stockoutRegionCount=" + stockoutRegionCount +
                ", hotSellingModelTriggered=" + hotSellingModelTriggered +
                ", overallRiskLevel=" + overallRiskLevel +
                '}';
    }
}
