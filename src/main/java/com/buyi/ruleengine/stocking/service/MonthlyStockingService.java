package com.buyi.ruleengine.stocking.service;

import com.buyi.ruleengine.stocking.enums.StockingModelType;
import com.buyi.ruleengine.stocking.model.ProductStockConfig;
import com.buyi.ruleengine.stocking.model.SalesHistoryData;
import com.buyi.ruleengine.stocking.model.StockingResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

/**
 * 月度备货服务
 * Monthly Stocking Service
 * 
 * 基于SABC分类的月度备货模型：
 * - 分析商品货盘SABC分类
 * - 根据分类定义安全库存天数和备货浮动系数
 * - 考虑生产周期和海运时间
 * - 计算月度备货量
 */
public class MonthlyStockingService {
    
    private static final Logger logger = LoggerFactory.getLogger(MonthlyStockingService.class);
    
    /** 月度备货周期（天） */
    private static final int MONTHLY_CYCLE_DAYS = 30;
    
    /** 计算精度 */
    private static final int CALCULATION_SCALE = 4;
    
    /** 加权平均权重：30天 20%, 15天 30%, 7天 50% */
    private static final BigDecimal WEIGHT_30_DAYS = new BigDecimal("0.20");
    private static final BigDecimal WEIGHT_15_DAYS = new BigDecimal("0.30");
    private static final BigDecimal WEIGHT_7_DAYS = new BigDecimal("0.50");
    
    /**
     * 计算月度备货量
     * 
     * @param config 商品备货配置
     * @param salesHistory 销售历史数据
     * @param baseDate 基准日期
     * @return 备货计算结果
     */
    public StockingResult calculateMonthlyStocking(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            LocalDate baseDate) {
        
        logger.debug("Calculating monthly stocking for product: {}", config.getSku());
        
        // 1. 计算加权平均日销量
        BigDecimal dailyAvgSales = calculateWeightedDailyAvgSales(salesHistory);
        
        // 2. 获取有效参数
        int safetyStockDays = config.getEffectiveSafetyStockDays();
        BigDecimal stockingCoefficient = config.getEffectiveStockingCoefficient();
        int shippingDays = config.getEffectiveShippingDays();
        int productionDays = config.getProductionDays() != null ? config.getProductionDays() : 15;
        
        // 3. 计算基础备货量 = 日均销 × (月度周期 + 安全库存天数)
        int totalCoverDays = MONTHLY_CYCLE_DAYS + safetyStockDays;
        BigDecimal baseQuantity = dailyAvgSales.multiply(BigDecimal.valueOf(totalCoverDays));
        
        // 4. 应用备货浮动系数
        BigDecimal adjustedQuantity = baseQuantity.multiply(stockingCoefficient)
                .setScale(0, RoundingMode.CEILING);
        
        // 5. 考虑当前库存和在途库存
        int totalInventory = config.getTotalInventory();
        BigDecimal netQuantity = adjustedQuantity.subtract(BigDecimal.valueOf(totalInventory));
        int recommendedQuantity = Math.max(0, netQuantity.intValue());
        
        // 6. 应用最小/最大订货量限制
        int finalQuantity = applyOrderQuantityLimits(recommendedQuantity, config);
        
        // 7. 计算建议发货日期和预计到货日期
        LocalDate suggestedShipDate = baseDate.plusDays(productionDays);
        LocalDate expectedArrivalDate = suggestedShipDate.plusDays(shippingDays);
        
        // 8. 构建结果
        return StockingResult.builder()
                .productId(config.getProductId())
                .sku(config.getSku())
                .productName(config.getProductName())
                .modelType(StockingModelType.MONTHLY)
                .category(config.getCategory())
                .shippingRegion(config.getShippingRegion())
                .calculationDate(baseDate)
                .dailyAvgSales(dailyAvgSales)
                .recommendedQuantity(recommendedQuantity)
                .adjustedQuantity(adjustedQuantity.intValue())
                .finalQuantity(finalQuantity)
                .currentInventory(config.getCurrentInventory())
                .inTransitInventory(config.getInTransitInventory())
                .suggestedShipDate(suggestedShipDate)
                .expectedArrivalDate(expectedArrivalDate)
                .stockingCycleDays(MONTHLY_CYCLE_DAYS)
                .safetyStockDays(safetyStockDays)
                .stockingCoefficient(stockingCoefficient)
                .isEmergency(false)
                .reason(buildStockingReason(config, dailyAvgSales, totalCoverDays, finalQuantity))
                .build();
    }
    
    /**
     * 计算加权平均日销量
     * 权重：30天数据 20%，15天数据 30%，7天数据 50%
     * 排除噪点值后计算
     */
    public BigDecimal calculateWeightedDailyAvgSales(SalesHistoryData salesHistory) {
        if (salesHistory == null) {
            return BigDecimal.ZERO;
        }
        
        // 计算各时间段日均销量（已排除噪点）
        BigDecimal avg30Days = calculateDailyAvgWithOutlierRemoval(
                salesHistory.getTotalSales30Days(), 30, salesHistory.getLast30DaysSales());
        BigDecimal avg15Days = calculateDailyAvgWithOutlierRemoval(
                salesHistory.getTotalSales15Days(), 15, salesHistory.getLast15DaysSales());
        BigDecimal avg7Days = calculateDailyAvgWithOutlierRemoval(
                salesHistory.getTotalSales7Days(), 7, salesHistory.getLast7DaysSales());
        
        // 加权平均
        BigDecimal weightedAvg = avg30Days.multiply(WEIGHT_30_DAYS)
                .add(avg15Days.multiply(WEIGHT_15_DAYS))
                .add(avg7Days.multiply(WEIGHT_7_DAYS))
                .setScale(CALCULATION_SCALE, RoundingMode.HALF_UP);
        
        logger.debug("Weighted daily average sales: 30d={}, 15d={}, 7d={}, weighted={}",
                avg30Days, avg15Days, avg7Days, weightedAvg);
        
        return weightedAvg;
    }
    
    /**
     * 计算日均销量，排除噪点值
     * 噪点定义：超过平均值3倍标准差的数据点
     */
    private BigDecimal calculateDailyAvgWithOutlierRemoval(
            Integer totalSales, 
            int days,
            java.util.List<SalesHistoryData.DailySales> dailySalesList) {
        
        if (dailySalesList == null || dailySalesList.isEmpty()) {
            if (totalSales != null && days > 0) {
                return BigDecimal.valueOf(totalSales)
                        .divide(BigDecimal.valueOf(days), CALCULATION_SCALE, RoundingMode.HALF_UP);
            }
            return BigDecimal.ZERO;
        }
        
        // 计算平均值
        double mean = dailySalesList.stream()
                .mapToInt(d -> d.getQuantity() != null ? d.getQuantity() : 0)
                .average()
                .orElse(0.0);
        
        if (mean == 0) {
            return BigDecimal.ZERO;
        }
        
        // 计算标准差
        double sumSquaredDiff = dailySalesList.stream()
                .mapToDouble(d -> {
                    int qty = d.getQuantity() != null ? d.getQuantity() : 0;
                    return Math.pow(qty - mean, 2);
                })
                .sum();
        double stdDev = Math.sqrt(sumSquaredDiff / dailySalesList.size());
        
        // 排除噪点（超过3倍标准差的数据）
        double threshold = 3.0 * stdDev;
        double filteredSum = dailySalesList.stream()
                .mapToInt(d -> d.getQuantity() != null ? d.getQuantity() : 0)
                .filter(qty -> Math.abs(qty - mean) <= threshold)
                .sum();
        
        long filteredCount = dailySalesList.stream()
                .mapToInt(d -> d.getQuantity() != null ? d.getQuantity() : 0)
                .filter(qty -> Math.abs(qty - mean) <= threshold)
                .count();
        
        if (filteredCount == 0) {
            return BigDecimal.valueOf(mean).setScale(CALCULATION_SCALE, RoundingMode.HALF_UP);
        }
        
        return BigDecimal.valueOf(filteredSum / filteredCount)
                .setScale(CALCULATION_SCALE, RoundingMode.HALF_UP);
    }
    
    /**
     * 应用最小/最大订货量限制
     */
    private int applyOrderQuantityLimits(int quantity, ProductStockConfig config) {
        if (quantity <= 0) {
            return 0;
        }
        
        int minQty = config.getMinOrderQuantity() != null ? config.getMinOrderQuantity() : 0;
        int maxQty = config.getMaxOrderQuantity() != null ? config.getMaxOrderQuantity() : Integer.MAX_VALUE;
        
        if (quantity < minQty) {
            return minQty;
        }
        if (quantity > maxQty) {
            return maxQty;
        }
        return quantity;
    }
    
    /**
     * 构建备货原因说明
     */
    private String buildStockingReason(ProductStockConfig config, BigDecimal dailyAvgSales,
                                       int coverDays, int finalQuantity) {
        StringBuilder reason = new StringBuilder();
        reason.append("月度备货模型计算：");
        reason.append("分类=").append(config.getCategory() != null ? config.getCategory().getDescription() : "未分类");
        reason.append("，日均销=").append(dailyAvgSales.setScale(2, RoundingMode.HALF_UP));
        reason.append("，覆盖天数=").append(coverDays);
        reason.append("，建议备货量=").append(finalQuantity);
        return reason.toString();
    }
}
