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
import java.util.List;

/**
 * 每周固定备货服务
 * Weekly Fixed Stocking Service
 * 
 * 固定备货周期7天的备货模型：
 * - 固定备货周期7天
 * - 基于历史30天、15天、7天数据
 * - 排除噪点值
 * - 根据20%、30%、50%加权平均销量计算日均销
 * - 日均销 × 7 = 备货量
 */
public class WeeklyStockingService {
    
    private static final Logger logger = LoggerFactory.getLogger(WeeklyStockingService.class);
    
    /** 每周备货周期（天） */
    private static final int WEEKLY_CYCLE_DAYS = 7;
    
    /** 计算精度 */
    private static final int CALCULATION_SCALE = 4;
    
    /** 加权平均权重：30天 20%, 15天 30%, 7天 50% */
    private static final BigDecimal WEIGHT_30_DAYS = new BigDecimal("0.20");
    private static final BigDecimal WEIGHT_15_DAYS = new BigDecimal("0.30");
    private static final BigDecimal WEIGHT_7_DAYS = new BigDecimal("0.50");
    
    /** 噪点排除阈值（标准差倍数） */
    private static final double OUTLIER_THRESHOLD_MULTIPLIER = 3.0;
    
    /**
     * 计算每周固定备货量
     * 
     * @param config 商品备货配置
     * @param salesHistory 销售历史数据
     * @param baseDate 基准日期
     * @return 备货计算结果
     */
    public StockingResult calculateWeeklyStocking(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            LocalDate baseDate) {
        
        logger.debug("Calculating weekly stocking for product: {}", config.getSku());
        
        // 1. 计算加权平均日销量（排除噪点）
        BigDecimal dailyAvgSales = calculateWeightedDailyAvgSales(salesHistory);
        
        // 2. 计算基础备货量 = 日均销 × 7
        BigDecimal baseQuantity = dailyAvgSales.multiply(BigDecimal.valueOf(WEEKLY_CYCLE_DAYS));
        int recommendedQuantity = baseQuantity.setScale(0, RoundingMode.CEILING).intValue();
        
        // 3. 应用备货浮动系数（可选）
        BigDecimal stockingCoefficient = config.getEffectiveStockingCoefficient();
        int adjustedQuantity = baseQuantity.multiply(stockingCoefficient)
                .setScale(0, RoundingMode.CEILING).intValue();
        
        // 4. 考虑当前库存，计算实际需要备货量
        int currentInventory = config.getCurrentInventory() != null ? config.getCurrentInventory() : 0;
        
        // 计算7天后的预计库存
        int expectedInventoryAfter7Days = currentInventory - recommendedQuantity;
        
        // 如果预计库存不足以支撑安全库存天数，则需要备货
        int safetyStockDays = config.getEffectiveSafetyStockDays();
        int safetyStock = dailyAvgSales.multiply(BigDecimal.valueOf(safetyStockDays))
                .setScale(0, RoundingMode.CEILING).intValue();
        
        int netQuantity = 0;
        if (expectedInventoryAfter7Days < safetyStock) {
            netQuantity = adjustedQuantity + (safetyStock - Math.max(0, expectedInventoryAfter7Days));
        }
        
        // 5. 应用最小/最大订货量限制
        int finalQuantity = applyOrderQuantityLimits(netQuantity, config);
        
        // 6. 计算建议发货日期和预计到货日期
        int productionDays = config.getProductionDays() != null ? config.getProductionDays() : 3;
        int shippingDays = config.getEffectiveShippingDays();
        LocalDate suggestedShipDate = baseDate.plusDays(productionDays);
        LocalDate expectedArrivalDate = suggestedShipDate.plusDays(shippingDays);
        
        // 7. 构建结果
        return StockingResult.builder()
                .productId(config.getProductId())
                .sku(config.getSku())
                .productName(config.getProductName())
                .modelType(StockingModelType.WEEKLY_FIXED)
                .category(config.getCategory())
                .shippingRegion(config.getShippingRegion())
                .calculationDate(baseDate)
                .dailyAvgSales(dailyAvgSales)
                .recommendedQuantity(recommendedQuantity)
                .adjustedQuantity(adjustedQuantity)
                .finalQuantity(finalQuantity)
                .currentInventory(config.getCurrentInventory())
                .inTransitInventory(config.getInTransitInventory())
                .suggestedShipDate(suggestedShipDate)
                .expectedArrivalDate(expectedArrivalDate)
                .stockingCycleDays(WEEKLY_CYCLE_DAYS)
                .safetyStockDays(safetyStockDays)
                .stockingCoefficient(stockingCoefficient)
                .isEmergency(false)
                .reason(buildStockingReason(dailyAvgSales, recommendedQuantity, finalQuantity))
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
                salesHistory.getLast30DaysSales(), salesHistory.getTotalSales30Days(), 30);
        BigDecimal avg15Days = calculateDailyAvgWithOutlierRemoval(
                salesHistory.getLast15DaysSales(), salesHistory.getTotalSales15Days(), 15);
        BigDecimal avg7Days = calculateDailyAvgWithOutlierRemoval(
                salesHistory.getLast7DaysSales(), salesHistory.getTotalSales7Days(), 7);
        
        // 加权平均：20% × 30天日均 + 30% × 15天日均 + 50% × 7天日均
        BigDecimal weightedAvg = avg30Days.multiply(WEIGHT_30_DAYS)
                .add(avg15Days.multiply(WEIGHT_15_DAYS))
                .add(avg7Days.multiply(WEIGHT_7_DAYS))
                .setScale(CALCULATION_SCALE, RoundingMode.HALF_UP);
        
        logger.debug("Weekly weighted daily average: 30d={}, 15d={}, 7d={}, weighted={}",
                avg30Days.setScale(2, RoundingMode.HALF_UP),
                avg15Days.setScale(2, RoundingMode.HALF_UP),
                avg7Days.setScale(2, RoundingMode.HALF_UP),
                weightedAvg.setScale(2, RoundingMode.HALF_UP));
        
        return weightedAvg;
    }
    
    /**
     * 计算日均销量，排除噪点值
     * 噪点定义：超过平均值3倍标准差的数据点
     * 
     * @param dailySalesList 每日销售数据列表
     * @param totalSales 总销量（备用）
     * @param days 天数
     * @return 日均销量
     */
    private BigDecimal calculateDailyAvgWithOutlierRemoval(
            List<SalesHistoryData.DailySales> dailySalesList,
            Integer totalSales,
            int days) {
        
        // 如果没有详细数据，使用总量计算
        if (dailySalesList == null || dailySalesList.isEmpty()) {
            if (totalSales != null && days > 0) {
                return BigDecimal.valueOf(totalSales)
                        .divide(BigDecimal.valueOf(days), CALCULATION_SCALE, RoundingMode.HALF_UP);
            }
            return BigDecimal.ZERO;
        }
        
        // 提取销量数据
        int[] quantities = dailySalesList.stream()
                .mapToInt(d -> d.getQuantity() != null ? d.getQuantity() : 0)
                .toArray();
        
        if (quantities.length == 0) {
            return BigDecimal.ZERO;
        }
        
        // 计算平均值
        double mean = 0;
        for (int qty : quantities) {
            mean += qty;
        }
        mean /= quantities.length;
        
        if (mean == 0) {
            return BigDecimal.ZERO;
        }
        
        // 计算标准差
        double sumSquaredDiff = 0;
        for (int qty : quantities) {
            sumSquaredDiff += Math.pow(qty - mean, 2);
        }
        double stdDev = Math.sqrt(sumSquaredDiff / quantities.length);
        
        // 排除噪点（超过3倍标准差的数据）
        double threshold = OUTLIER_THRESHOLD_MULTIPLIER * stdDev;
        double filteredSum = 0;
        int filteredCount = 0;
        
        for (int qty : quantities) {
            if (Math.abs(qty - mean) <= threshold) {
                filteredSum += qty;
                filteredCount++;
            }
        }
        
        // 如果所有数据都被排除，使用原始平均值
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
    private String buildStockingReason(BigDecimal dailyAvgSales, int baseQuantity, int finalQuantity) {
        StringBuilder reason = new StringBuilder();
        reason.append("每周固定备货模型：");
        reason.append("日均销=").append(dailyAvgSales.setScale(2, RoundingMode.HALF_UP));
        reason.append("，周期7天");
        reason.append("，基础备货量=").append(baseQuantity);
        reason.append("，最终备货量=").append(finalQuantity);
        return reason.toString();
    }
}
