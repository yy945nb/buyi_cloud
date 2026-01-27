package com.buyi.ruleengine.stocking.service;

import com.buyi.ruleengine.enums.RiskLevel;
import com.buyi.ruleengine.model.CosOosPointDetail;
import com.buyi.ruleengine.model.CosOosPointResponse;
import com.buyi.ruleengine.service.StockoutPointService;
import com.buyi.ruleengine.stocking.enums.ShippingRegion;
import com.buyi.ruleengine.stocking.enums.StockingModelType;
import com.buyi.ruleengine.stocking.model.ProductStockConfig;
import com.buyi.ruleengine.stocking.model.SalesHistoryData;
import com.buyi.ruleengine.stocking.model.StockingResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

/**
 * 断货点临时备货服务
 * Stockout Point Emergency Stocking Service
 * 
 * 基于断货点模型的紧急备货：
 * - 算出未来一段时间内可能存在的断货点
 * - 提前进行生产或备货
 * - 考虑不同区域（美东、美西、美中、美南）的海运时间差异
 * - 不同区域有不同的断货监控点
 */
public class StockoutStockingService {
    
    private static final Logger logger = LoggerFactory.getLogger(StockoutStockingService.class);
    
    /** 计算精度 */
    private static final int CALCULATION_SCALE = 4;
    
    /** 监控间隔（天） */
    private static final int MONITOR_INTERVAL_DAYS = 7;
    
    /** 默认预测天数 */
    private static final int DEFAULT_HORIZON_DAYS = 90;
    
    /** 紧急备货系数 */
    private static final BigDecimal EMERGENCY_COEFFICIENT = new BigDecimal("1.2");
    
    /** 断货点分析服务 */
    private final StockoutPointService stockoutPointService;
    
    public StockoutStockingService() {
        this.stockoutPointService = new StockoutPointService();
    }
    
    public StockoutStockingService(StockoutPointService stockoutPointService) {
        this.stockoutPointService = stockoutPointService;
    }
    
    /**
     * 评估断货风险并计算紧急备货量
     * 
     * @param config 商品备货配置
     * @param salesHistory 销售历史数据
     * @param existingShipments 已有发货计划（发货日期 -> 数量）
     * @param baseDate 基准日期
     * @return 备货计算结果，如果无需紧急备货则返回null
     */
    public StockingResult evaluateAndCalculateEmergencyStocking(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            Map<LocalDate, Integer> existingShipments,
            LocalDate baseDate) {
        
        logger.debug("Evaluating stockout risk for product: {}", config.getSku());
        
        // 1. 计算日均销量
        BigDecimal dailyAvgSales = calculateDailyAvgSales(salesHistory);
        
        // 2. 获取区域相关参数
        ShippingRegion region = config.getShippingRegion();
        int shippingDays = config.getEffectiveShippingDays();
        int productionDays = config.getProductionDays() != null ? config.getProductionDays() : 15;
        int safetyStockDays = config.getEffectiveSafetyStockDays();
        
        // 3. 计算预测天数（根据区域调整）
        int horizonDays = calculateHorizonDays(region, productionDays, shippingDays);
        
        // 4. 调用断货点分析服务
        CosOosPointResponse stockoutAnalysis = stockoutPointService.evaluateWithWeeklyShipments(
                config.getCurrentInventory(),
                dailyAvgSales,
                existingShipments != null ? existingShipments : new HashMap<>(),
                productionDays,
                shippingDays,
                safetyStockDays,
                MONITOR_INTERVAL_DAYS,
                horizonDays,
                baseDate
        );
        
        // 5. 分析结果，判断是否需要紧急备货
        if (stockoutAnalysis == null || stockoutAnalysis.getFirstRiskPoint() == null) {
            logger.debug("No stockout risk detected for product: {}", config.getSku());
            return null; // 无风险，不需要紧急备货
        }
        
        CosOosPointDetail riskPoint = stockoutAnalysis.getFirstRiskPoint();
        
        // 6. 根据风险等级决定是否触发紧急备货
        if (riskPoint.getRiskLevel() == RiskLevel.OK) {
            return null; // 安全，不需要紧急备货
        }
        
        // 7. 计算紧急备货量
        return calculateEmergencyStocking(config, salesHistory, stockoutAnalysis, riskPoint, baseDate);
    }
    
    /**
     * 根据区域计算预测天数
     * 不同区域海运时间不同，监控窗口也不同
     */
    private int calculateHorizonDays(ShippingRegion region, int productionDays, int shippingDays) {
        int baseHorizon = productionDays + shippingDays;
        
        if (region == null) {
            return Math.max(baseHorizon, DEFAULT_HORIZON_DAYS);
        }
        
        // 根据区域特性调整预测天数
        switch (region) {
            case US_WEST:
                // 美西海运时间最短，监控窗口可以短一些
                return Math.max(baseHorizon, 60);
            case US_EAST:
                // 美东海运时间最长，需要更长的监控窗口
                return Math.max(baseHorizon, 90);
            case US_CENTRAL:
            case US_SOUTH:
            default:
                return Math.max(baseHorizon, 80);
        }
    }
    
    /**
     * 计算紧急备货量
     */
    private StockingResult calculateEmergencyStocking(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            CosOosPointResponse stockoutAnalysis,
            CosOosPointDetail riskPoint,
            LocalDate baseDate) {
        
        BigDecimal dailyAvgSales = calculateDailyAvgSales(salesHistory);
        int safetyStockDays = config.getEffectiveSafetyStockDays();
        BigDecimal stockingCoefficient = config.getEffectiveStockingCoefficient();
        int shippingDays = config.getEffectiveShippingDays();
        int productionDays = config.getProductionDays() != null ? config.getProductionDays() : 15;
        
        // 1. 计算到风险点的天数
        int daysToRisk = riskPoint.getOffsetDays();
        
        // 2. 计算需要补充的库存量
        // 缺货量 + 安全库存
        BigDecimal oosQuantity = riskPoint.getOosQuantity() != null ? 
                riskPoint.getOosQuantity() : BigDecimal.ZERO;
        BigDecimal safetyStock = dailyAvgSales.multiply(BigDecimal.valueOf(safetyStockDays));
        
        // 3. 计算基础紧急备货量
        BigDecimal baseEmergencyQuantity = oosQuantity.add(safetyStock);
        
        // 4. 应用紧急备货系数
        BigDecimal emergencyQuantity = baseEmergencyQuantity
                .multiply(EMERGENCY_COEFFICIENT)
                .multiply(stockingCoefficient);
        
        int recommendedQuantity = emergencyQuantity.setScale(0, RoundingMode.CEILING).intValue();
        
        // 5. 应用最小/最大订货量限制
        int finalQuantity = applyOrderQuantityLimits(recommendedQuantity, config);
        
        // 6. 计算建议发货日期
        // 需要在风险点之前到货，倒推发货日期
        int leadTime = productionDays + shippingDays;
        int daysBeforeRisk = daysToRisk - leadTime;
        
        LocalDate suggestedShipDate;
        String urgencyNote;
        boolean isUrgent;
        
        if (daysBeforeRisk <= 0) {
            // 紧急情况：已经来不及正常备货
            suggestedShipDate = baseDate; // 立即发货
            urgencyNote = "紧急！需立即备货，正常流程已来不及";
            isUrgent = true;
        } else if (daysBeforeRisk <= 7) {
            // 高度紧急
            suggestedShipDate = baseDate.plusDays(Math.min(daysBeforeRisk, 3));
            urgencyNote = "高度紧急！需在" + daysBeforeRisk + "天内发货";
            isUrgent = true;
        } else {
            // 需要关注
            suggestedShipDate = baseDate.plusDays(productionDays);
            urgencyNote = "注意：预计" + daysToRisk + "天后可能断货";
            isUrgent = false;
        }
        
        LocalDate expectedArrivalDate = suggestedShipDate.plusDays(shippingDays);
        
        // 7. 构建结果
        return StockingResult.builder()
                .productId(config.getProductId())
                .sku(config.getSku())
                .productName(config.getProductName())
                .modelType(StockingModelType.STOCKOUT_EMERGENCY)
                .category(config.getCategory())
                .shippingRegion(config.getShippingRegion())
                .calculationDate(baseDate)
                .dailyAvgSales(dailyAvgSales)
                .recommendedQuantity(recommendedQuantity)
                .adjustedQuantity(emergencyQuantity.setScale(0, RoundingMode.CEILING).intValue())
                .finalQuantity(finalQuantity)
                .currentInventory(config.getCurrentInventory())
                .inTransitInventory(config.getInTransitInventory())
                .suggestedShipDate(suggestedShipDate)
                .expectedArrivalDate(expectedArrivalDate)
                .stockingCycleDays(daysToRisk)
                .safetyStockDays(safetyStockDays)
                .stockingCoefficient(stockingCoefficient)
                .isEmergency(isUrgent)
                .urgencyNote(urgencyNote)
                .stockoutRiskDays(daysToRisk)
                .expectedStockoutQuantity(oosQuantity.setScale(0, RoundingMode.CEILING).intValue())
                .reason(buildEmergencyReason(riskPoint, daysToRisk, finalQuantity))
                .build();
    }
    
    /**
     * 计算日均销量（使用加权平均）
     */
    private BigDecimal calculateDailyAvgSales(SalesHistoryData salesHistory) {
        if (salesHistory == null) {
            return BigDecimal.ZERO;
        }
        
        // 简单使用总量计算平均值
        Integer total30 = salesHistory.getTotalSales30Days();
        Integer total15 = salesHistory.getTotalSales15Days();
        Integer total7 = salesHistory.getTotalSales7Days();
        
        BigDecimal avg30 = total30 != null && total30 > 0 ? 
                BigDecimal.valueOf(total30).divide(BigDecimal.valueOf(30), CALCULATION_SCALE, RoundingMode.HALF_UP) : BigDecimal.ZERO;
        BigDecimal avg15 = total15 != null && total15 > 0 ? 
                BigDecimal.valueOf(total15).divide(BigDecimal.valueOf(15), CALCULATION_SCALE, RoundingMode.HALF_UP) : BigDecimal.ZERO;
        BigDecimal avg7 = total7 != null && total7 > 0 ? 
                BigDecimal.valueOf(total7).divide(BigDecimal.valueOf(7), CALCULATION_SCALE, RoundingMode.HALF_UP) : BigDecimal.ZERO;
        
        // 加权平均：20% * 30天 + 30% * 15天 + 50% * 7天
        return avg30.multiply(new BigDecimal("0.20"))
                .add(avg15.multiply(new BigDecimal("0.30")))
                .add(avg7.multiply(new BigDecimal("0.50")))
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
     * 构建紧急备货原因说明
     */
    private String buildEmergencyReason(CosOosPointDetail riskPoint, int daysToRisk, int finalQuantity) {
        StringBuilder reason = new StringBuilder();
        reason.append("断货点临时备货模型：");
        reason.append("预计").append(daysToRisk).append("天后");
        
        if (riskPoint.getRiskLevel() == RiskLevel.OUTAGE) {
            reason.append("断货");
        } else {
            reason.append("库存风险");
        }
        
        reason.append("，预计缺货量=").append(riskPoint.getOosQuantity() != null ? 
                riskPoint.getOosQuantity().setScale(0, RoundingMode.CEILING) : 0);
        reason.append("，建议紧急备货量=").append(finalQuantity);
        
        return reason.toString();
    }
}
