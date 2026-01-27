package com.buyi.ruleengine.stocking.service;

import com.buyi.ruleengine.stocking.enums.StockingModelType;
import com.buyi.ruleengine.stocking.model.ProductStockConfig;
import com.buyi.ruleengine.stocking.model.SalesHistoryData;
import com.buyi.ruleengine.stocking.model.StockingResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 备货引擎
 * Stocking Engine
 * 
 * 整合三种备货模型的统一入口：
 * 1. 月度备货模型 - 基于SABC分类的月度备货计划
 * 2. 每周固定备货模型 - 固定7天周期的备货
 * 3. 断货点临时备货模型 - 基于断货风险的紧急备货
 * 
 * 引擎会根据配置和实际情况协调各模型，给出最优备货建议
 */
public class StockingEngine {
    
    private static final Logger logger = LoggerFactory.getLogger(StockingEngine.class);
    
    /** 月度备货服务 */
    private final MonthlyStockingService monthlyStockingService;
    
    /** 每周固定备货服务 */
    private final WeeklyStockingService weeklyStockingService;
    
    /** 断货点临时备货服务 */
    private final StockoutStockingService stockoutStockingService;
    
    public StockingEngine() {
        this.monthlyStockingService = new MonthlyStockingService();
        this.weeklyStockingService = new WeeklyStockingService();
        this.stockoutStockingService = new StockoutStockingService();
    }
    
    public StockingEngine(
            MonthlyStockingService monthlyStockingService,
            WeeklyStockingService weeklyStockingService,
            StockoutStockingService stockoutStockingService) {
        this.monthlyStockingService = monthlyStockingService;
        this.weeklyStockingService = weeklyStockingService;
        this.stockoutStockingService = stockoutStockingService;
    }
    
    /**
     * 计算综合备货建议
     * 首先检查是否有断货风险，如果有则优先使用紧急备货模型
     * 否则根据指定模型类型计算
     * 
     * @param config 商品备货配置
     * @param salesHistory 销售历史数据
     * @param existingShipments 已有发货计划
     * @param modelType 优先使用的备货模型类型
     * @param baseDate 基准日期
     * @return 备货计算结果
     */
    public StockingResult calculateStocking(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            Map<LocalDate, Integer> existingShipments,
            StockingModelType modelType,
            LocalDate baseDate) {
        
        logger.info("Calculating stocking for product: {}, model type: {}", 
                config.getSku(), modelType);
        
        // 1. 首先检查断货风险
        StockingResult emergencyResult = stockoutStockingService.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, existingShipments, baseDate);
        
        // 2. 如果检测到紧急断货风险，优先返回紧急备货建议
        if (emergencyResult != null && Boolean.TRUE.equals(emergencyResult.getIsEmergency())) {
            logger.warn("Emergency stocking detected for product: {}", config.getSku());
            return emergencyResult;
        }
        
        // 3. 根据指定模型类型计算
        StockingResult result;
        switch (modelType) {
            case MONTHLY:
                result = monthlyStockingService.calculateMonthlyStocking(config, salesHistory, baseDate);
                break;
            case WEEKLY_FIXED:
                result = weeklyStockingService.calculateWeeklyStocking(config, salesHistory, baseDate);
                break;
            case STOCKOUT_EMERGENCY:
                // 如果指定紧急备货模型但没有紧急情况，返回风险评估结果或null
                result = emergencyResult;
                break;
            default:
                logger.warn("Unknown stocking model type: {}, using monthly model", modelType);
                result = monthlyStockingService.calculateMonthlyStocking(config, salesHistory, baseDate);
        }
        
        // 4. 如果有非紧急的断货风险，添加警告信息
        if (emergencyResult != null && result != null && !Boolean.TRUE.equals(emergencyResult.getIsEmergency())) {
            result.setStockoutRiskDays(emergencyResult.getStockoutRiskDays());
            result.setExpectedStockoutQuantity(emergencyResult.getExpectedStockoutQuantity());
            String warning = "注意：" + emergencyResult.getUrgencyNote();
            String existingReason = result.getReason() != null ? result.getReason() : "";
            result.setReason(existingReason + " | " + warning);
        }
        
        return result;
    }
    
    /**
     * 计算月度备货
     */
    public StockingResult calculateMonthlyStocking(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            LocalDate baseDate) {
        return monthlyStockingService.calculateMonthlyStocking(config, salesHistory, baseDate);
    }
    
    /**
     * 计算每周固定备货
     */
    public StockingResult calculateWeeklyStocking(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            LocalDate baseDate) {
        return weeklyStockingService.calculateWeeklyStocking(config, salesHistory, baseDate);
    }
    
    /**
     * 评估断货风险并计算紧急备货
     */
    public StockingResult evaluateStockoutRisk(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            Map<LocalDate, Integer> existingShipments,
            LocalDate baseDate) {
        return stockoutStockingService.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, existingShipments, baseDate);
    }
    
    /**
     * 批量计算备货建议
     * 
     * @param products 商品配置列表
     * @param salesHistoryMap SKU -> 销售历史数据映射
     * @param shipmentsMap SKU -> 已有发货计划映射
     * @param modelType 备货模型类型
     * @param baseDate 基准日期
     * @return 备货建议列表
     */
    public List<StockingResult> batchCalculateStocking(
            List<ProductStockConfig> products,
            Map<String, SalesHistoryData> salesHistoryMap,
            Map<String, Map<LocalDate, Integer>> shipmentsMap,
            StockingModelType modelType,
            LocalDate baseDate) {
        
        logger.info("Batch calculating stocking for {} products", products.size());
        
        List<StockingResult> results = new ArrayList<>();
        
        for (ProductStockConfig config : products) {
            if (!Boolean.TRUE.equals(config.getAutoStockingEnabled())) {
                logger.debug("Auto stocking disabled for product: {}", config.getSku());
                continue;
            }
            
            try {
                String sku = config.getSku();
                SalesHistoryData salesHistory = salesHistoryMap.get(sku);
                Map<LocalDate, Integer> existingShipments = shipmentsMap != null ? 
                        shipmentsMap.get(sku) : null;
                
                StockingResult result = calculateStocking(
                        config, salesHistory, existingShipments, modelType, baseDate);
                
                if (result != null && result.getFinalQuantity() != null && result.getFinalQuantity() > 0) {
                    results.add(result);
                }
            } catch (Exception e) {
                logger.error("Error calculating stocking for product: {}", config.getSku(), e);
            }
        }
        
        logger.info("Batch calculation completed, {} products need stocking", results.size());
        return results;
    }
    
    /**
     * 获取所有模型的备货建议（用于比较）
     * 
     * @param config 商品备货配置
     * @param salesHistory 销售历史数据
     * @param existingShipments 已有发货计划
     * @param baseDate 基准日期
     * @return 各模型的备货建议列表
     */
    public List<StockingResult> getAllModelResults(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            Map<LocalDate, Integer> existingShipments,
            LocalDate baseDate) {
        
        List<StockingResult> results = new ArrayList<>();
        
        // 月度备货
        StockingResult monthlyResult = monthlyStockingService.calculateMonthlyStocking(
                config, salesHistory, baseDate);
        if (monthlyResult != null) {
            results.add(monthlyResult);
        }
        
        // 每周固定备货
        StockingResult weeklyResult = weeklyStockingService.calculateWeeklyStocking(
                config, salesHistory, baseDate);
        if (weeklyResult != null) {
            results.add(weeklyResult);
        }
        
        // 断货点临时备货
        StockingResult stockoutResult = stockoutStockingService.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, existingShipments, baseDate);
        if (stockoutResult != null) {
            results.add(stockoutResult);
        }
        
        return results;
    }
    
    /**
     * 获取推荐的备货建议
     * 根据风险等级和库存状况自动选择最合适的备货模型
     * 
     * @param config 商品备货配置
     * @param salesHistory 销售历史数据
     * @param existingShipments 已有发货计划
     * @param baseDate 基准日期
     * @return 推荐的备货建议
     */
    public StockingResult getRecommendedStocking(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            Map<LocalDate, Integer> existingShipments,
            LocalDate baseDate) {
        
        // 1. 首先检查断货风险
        StockingResult emergencyResult = stockoutStockingService.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, existingShipments, baseDate);
        
        // 2. 如果有紧急断货风险，必须优先处理
        if (emergencyResult != null && Boolean.TRUE.equals(emergencyResult.getIsEmergency())) {
            return emergencyResult;
        }
        
        // 3. 根据商品分类选择合适的模型
        switch (config.getCategory()) {
            case S:
                // S类畅销品：建议使用每周固定备货，保持高周转
                return weeklyStockingService.calculateWeeklyStocking(config, salesHistory, baseDate);
            case A:
                // A类次畅销品：可以使用月度备货
                return monthlyStockingService.calculateMonthlyStocking(config, salesHistory, baseDate);
            case B:
            case C:
            default:
                // B/C类一般商品：使用月度备货，减少备货频次
                return monthlyStockingService.calculateMonthlyStocking(config, salesHistory, baseDate);
        }
    }
}
