package com.buyi.ruleengine.stocking.service;

import com.buyi.ruleengine.enums.RiskLevel;
import com.buyi.ruleengine.model.CosOosPointResponse;
import com.buyi.ruleengine.model.MultiRegionStockoutAnalysis;
import com.buyi.ruleengine.model.MultiRegionStockoutAnalysis.RegionStockoutDetail;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 新款/爆款备货业务服务
 * New SKU / Hot-Selling Stockup Business Service
 * 
 * 针对短时间销量暴涨导致多区域（美东、美西、美中、美南）全部断货的商品，
 * 设计的爆款备货模型。
 * 
 * 核心特点：
 * 1. 多区域断货点跟踪 - 同时监控四个区域仓库的库存状态
 * 2. 爆款识别触发 - 当多个区域同时存在断货风险时，自动触发爆款备货模型
 * 3. 动态备货系数 - 根据销量增长速度动态调整备货系数
 * 4. 紧急备货优先级 - 优先补充断货最严重的区域
 * 5. 跨区域库存调配建议 - 提供区域间库存调配方案
 * 
 * 使用场景：
 * - 新品上市后销量暴涨
 * - 季节性爆款商品
 * - 营销活动导致的需求激增
 * - 供应链中断导致的多区域断货
 */
public class NewSkuStockupBusiness {
    
    private static final Logger logger = LoggerFactory.getLogger(NewSkuStockupBusiness.class);
    
    /** 计算精度 */
    private static final int CALCULATION_SCALE = 4;
    
    /** 监控间隔（天） */
    private static final int MONITOR_INTERVAL_DAYS = 7;
    
    /** 默认预测天数 */
    private static final int DEFAULT_HORIZON_DAYS = 90;
    
    /** 爆款备货基础系数 */
    private static final BigDecimal HOT_SELLING_BASE_COEFFICIENT = new BigDecimal("1.5");
    
    /** 多区域断货时的加急系数 */
    private static final BigDecimal MULTI_REGION_URGENCY_COEFFICIENT = new BigDecimal("1.3");
    
    /** 销量暴涨判定阈值（7天销量相对于30天平均的倍数） */
    private static final BigDecimal SALES_SURGE_THRESHOLD = new BigDecimal("2.0");
    
    /** 高速增长时的系数调整 */
    private static final BigDecimal HIGH_GROWTH_COEFFICIENT = new BigDecimal("1.3");
    
    /** 中速增长时的系数调整 */
    private static final BigDecimal MEDIUM_GROWTH_COEFFICIENT = new BigDecimal("1.1");
    
    /** 双区域断货时的系数调整 */
    private static final BigDecimal DUAL_REGION_STOCKOUT_COEFFICIENT = new BigDecimal("1.15");
    
    /** 触发爆款模型的最少风险区域数 */
    private static final int MIN_RISK_REGIONS_FOR_HOT_MODEL = 2;
    
    /** 断货点分析服务 */
    private final StockoutPointService stockoutPointService;
    
    public NewSkuStockupBusiness() {
        this.stockoutPointService = new StockoutPointService();
    }
    
    public NewSkuStockupBusiness(StockoutPointService stockoutPointService) {
        this.stockoutPointService = stockoutPointService;
    }
    
    /**
     * 评估商品是否符合爆款备货模型条件
     * 
     * @param salesHistory 销售历史数据
     * @return 是否为爆款商品
     */
    public boolean isHotSellingProduct(SalesHistoryData salesHistory) {
        if (salesHistory == null) {
            return false;
        }
        
        // 计算30天日均销量
        BigDecimal avg30Days = calculateDailyAvg(salesHistory.getTotalSales30Days(), 30);
        // 计算7天日均销量
        BigDecimal avg7Days = calculateDailyAvg(salesHistory.getTotalSales7Days(), 7);
        
        if (avg30Days.compareTo(BigDecimal.ZERO) <= 0) {
            // 如果30天没有销量，但7天有销量，可能是新品
            return avg7Days.compareTo(BigDecimal.ZERO) > 0;
        }
        
        // 如果7天日均销量是30天日均的2倍以上，判定为销量暴涨
        BigDecimal ratio = avg7Days.divide(avg30Days, CALCULATION_SCALE, RoundingMode.HALF_UP);
        return ratio.compareTo(SALES_SURGE_THRESHOLD) >= 0;
    }
    
    /**
     * 执行多区域断货分析
     * 分析商品在美东、美西、美中、美南四个区域的断货风险
     * 
     * @param productId 商品ID
     * @param sku 商品SKU
     * @param regionInventories 各区域库存 (区域 -> 库存数量)
     * @param regionInTransit 各区域在途库存 (区域 -> 在途数量)
     * @param salesHistory 销售历史数据
     * @param regionSalesRatios 各区域销量占比 (区域 -> 占比)，如果为空则平均分配
     * @param existingShipments 已有发货计划（发货日期 -> 数量）
     * @param productionDays 生产天数
     * @param safetyStockDays 安全库存天数
     * @param baseDate 基准日期
     * @return 多区域断货分析结果
     */
    public MultiRegionStockoutAnalysis analyzeMultiRegionStockout(
            Long productId,
            String sku,
            Map<ShippingRegion, Integer> regionInventories,
            Map<ShippingRegion, Integer> regionInTransit,
            SalesHistoryData salesHistory,
            Map<ShippingRegion, BigDecimal> regionSalesRatios,
            Map<LocalDate, Integer> existingShipments,
            Integer productionDays,
            Integer safetyStockDays,
            LocalDate baseDate) {
        
        logger.info("开始多区域断货分析：SKU={}", sku);
        
        MultiRegionStockoutAnalysis analysis = new MultiRegionStockoutAnalysis();
        analysis.setProductId(productId);
        analysis.setSku(sku);
        analysis.setAnalysisDate(baseDate != null ? baseDate : LocalDate.now());
        
        // 计算总日均销量
        BigDecimal totalDailyAvg = calculateWeightedDailyAvg(salesHistory);
        
        // 如果没有销量数据，直接返回
        if (totalDailyAvg.compareTo(BigDecimal.ZERO) <= 0) {
            logger.debug("无销量数据，跳过分析：SKU={}", sku);
            analysis.setRecommendedStrategy("无销量数据，暂不需要备货");
            return analysis;
        }
        
        // 获取或计算各区域销量占比
        Map<ShippingRegion, BigDecimal> salesRatios = getSalesRatios(regionSalesRatios);
        
        // 分析每个区域的断货风险
        for (ShippingRegion region : ShippingRegion.values()) {
            RegionStockoutDetail detail = analyzeRegionStockout(
                    region,
                    regionInventories != null ? regionInventories.getOrDefault(region, 0) : 0,
                    regionInTransit != null ? regionInTransit.getOrDefault(region, 0) : 0,
                    totalDailyAvg.multiply(salesRatios.get(region)),
                    existingShipments,
                    productionDays != null ? productionDays : 15,
                    safetyStockDays != null ? safetyStockDays : 35,
                    baseDate
            );
            analysis.addRegionDetail(detail);
        }
        
        // 生成备货策略建议
        analysis.setRecommendedStrategy(generateStrategy(analysis));
        
        logger.info("多区域断货分析完成：SKU={}，风险区域数={}，断货区域数={}，是否触发爆款模型={}",
                sku, analysis.getAtRiskRegionCount(), analysis.getStockoutRegionCount(),
                analysis.isHotSellingModelTriggered());
        
        return analysis;
    }
    
    /**
     * 分析单个区域的断货风险
     */
    private RegionStockoutDetail analyzeRegionStockout(
            ShippingRegion region,
            int currentInventory,
            int inTransitQuantity,
            BigDecimal regionDailyAvg,
            Map<LocalDate, Integer> existingShipments,
            int productionDays,
            int safetyStockDays,
            LocalDate baseDate) {
        
        RegionStockoutDetail detail = new RegionStockoutDetail();
        detail.setRegion(region);
        detail.setCurrentInventory(currentInventory);
        detail.setDailyAvgSales(regionDailyAvg);
        detail.setShippingDays(region.getShippingDays());
        detail.setInTransitQuantity(inTransitQuantity);
        detail.setHasInTransit(inTransitQuantity > 0);
        
        LocalDate actualBaseDate = baseDate != null ? baseDate : LocalDate.now();
        
        // 使用断货点服务评估风险
        int horizonDays = calculateHorizonDays(region, productionDays, region.getShippingDays());
        
        CosOosPointResponse stockoutResponse = stockoutPointService.evaluateWithWeeklyShipments(
                currentInventory + inTransitQuantity,
                regionDailyAvg,
                existingShipments != null ? existingShipments : new HashMap<>(),
                productionDays,
                region.getShippingDays(),
                safetyStockDays,
                MONITOR_INTERVAL_DAYS,
                horizonDays,
                actualBaseDate
        );
        
        // 设置风险等级和详情
        if (stockoutResponse != null && stockoutResponse.getFirstRiskPoint() != null) {
            detail.setRiskLevel(stockoutResponse.getFirstRiskPoint().getRiskLevel());
            detail.setDaysToStockout(stockoutResponse.getOosDays());
            detail.setExpectedShortage(stockoutResponse.getFirstRiskPoint().getOosQuantity());
            
            // 计算建议补货量
            int suggestedQty = calculateRegionReplenishment(
                    regionDailyAvg, safetyStockDays, 
                    stockoutResponse.getFirstRiskPoint().getOosQuantity(),
                    detail.getRiskLevel());
            detail.setSuggestedReplenishment(suggestedQty);
            
            // 计算最早到达日期
            detail.setEarliestArrivalDate(actualBaseDate.plusDays(productionDays + region.getShippingDays()));
            
            // 设置详细说明
            detail.setNote(stockoutResponse.getOosReason());
        } else {
            detail.setRiskLevel(RiskLevel.OK);
            detail.setDaysToStockout(null);
            detail.setExpectedShortage(BigDecimal.ZERO);
            detail.setSuggestedReplenishment(0);
            detail.setNote("库存充足，无断货风险");
        }
        
        return detail;
    }
    
    /**
     * 计算区域补货量
     */
    private int calculateRegionReplenishment(
            BigDecimal dailyAvg, int safetyStockDays,
            BigDecimal expectedShortage, RiskLevel riskLevel) {
        
        BigDecimal shortage = expectedShortage != null ? expectedShortage : BigDecimal.ZERO;
        BigDecimal safetyStock = dailyAvg.multiply(BigDecimal.valueOf(safetyStockDays));
        
        // 基础补货量 = 缺货量 + 安全库存
        BigDecimal baseQty = shortage.add(safetyStock);
        
        // 根据风险等级应用系数
        BigDecimal coefficient;
        if (riskLevel == RiskLevel.OUTAGE) {
            coefficient = HOT_SELLING_BASE_COEFFICIENT.multiply(MULTI_REGION_URGENCY_COEFFICIENT);
        } else if (riskLevel == RiskLevel.AT_RISK) {
            coefficient = HOT_SELLING_BASE_COEFFICIENT;
        } else {
            coefficient = BigDecimal.ONE;
        }
        
        return baseQty.multiply(coefficient).setScale(0, RoundingMode.CEILING).intValue();
    }
    
    /**
     * 根据多区域分析结果计算爆款备货建议
     * 
     * @param config 商品备货配置
     * @param salesHistory 销售历史数据
     * @param multiRegionAnalysis 多区域断货分析结果
     * @param baseDate 基准日期
     * @return 备货计算结果
     */
    public StockingResult calculateHotSellingStocking(
            ProductStockConfig config,
            SalesHistoryData salesHistory,
            MultiRegionStockoutAnalysis multiRegionAnalysis,
            LocalDate baseDate) {
        
        logger.debug("计算爆款备货建议：SKU={}", config.getSku());
        
        // 1. 计算加权日均销量
        BigDecimal dailyAvgSales = calculateWeightedDailyAvg(salesHistory);
        
        // 2. 判断是否触发爆款模型
        if (!multiRegionAnalysis.isHotSellingModelTriggered()) {
            logger.debug("未触发爆款模型，使用常规备货：SKU={}", config.getSku());
            return null;
        }
        
        // 3. 计算总补货量（汇总所有风险区域）
        int totalReplenishment = multiRegionAnalysis.getTotalSuggestedReplenishment();
        
        // 4. 应用爆款备货系数
        BigDecimal hotSellingCoefficient = calculateDynamicCoefficient(salesHistory, multiRegionAnalysis);
        int adjustedQuantity = BigDecimal.valueOf(totalReplenishment)
                .multiply(hotSellingCoefficient)
                .setScale(0, RoundingMode.CEILING).intValue();
        
        // 5. 应用最小/最大订货量限制
        int finalQuantity = applyOrderQuantityLimits(adjustedQuantity, config);
        
        // 6. 计算建议发货日期
        int productionDays = config.getProductionDays() != null ? config.getProductionDays() : 15;
        int shippingDays = config.getEffectiveShippingDays();
        
        LocalDate actualBaseDate = baseDate != null ? baseDate : LocalDate.now();
        LocalDate suggestedShipDate;
        String urgencyNote;
        boolean isUrgent;
        
        if (multiRegionAnalysis.getStockoutRegionCount() >= 2) {
            // 多区域已断货，立即发货
            suggestedShipDate = actualBaseDate;
            urgencyNote = "紧急！" + multiRegionAnalysis.getStockoutRegionCount() + "个区域已断货，需立即备货";
            isUrgent = true;
        } else if (multiRegionAnalysis.getAtRiskRegionCount() >= 3) {
            // 3个及以上区域存在风险
            suggestedShipDate = actualBaseDate.plusDays(Math.min(productionDays / 2, 7));
            urgencyNote = "高度紧急！" + multiRegionAnalysis.getAtRiskRegionCount() + "个区域存在断货风险";
            isUrgent = true;
        } else {
            // 2个区域存在风险
            suggestedShipDate = actualBaseDate.plusDays(productionDays);
            urgencyNote = "注意！" + multiRegionAnalysis.getAtRiskRegionCount() + "个区域存在断货风险";
            isUrgent = false;
        }
        
        LocalDate expectedArrivalDate = suggestedShipDate.plusDays(shippingDays);
        
        // 7. 构建结果
        return StockingResult.builder()
                .productId(config.getProductId())
                .sku(config.getSku())
                .productName(config.getProductName())
                .modelType(StockingModelType.NEW_SKU)
                .category(config.getCategory())
                .shippingRegion(config.getShippingRegion())
                .calculationDate(actualBaseDate)
                .dailyAvgSales(dailyAvgSales)
                .recommendedQuantity(totalReplenishment)
                .adjustedQuantity(adjustedQuantity)
                .finalQuantity(finalQuantity)
                .currentInventory(config.getCurrentInventory())
                .inTransitInventory(config.getInTransitInventory())
                .suggestedShipDate(suggestedShipDate)
                .expectedArrivalDate(expectedArrivalDate)
                .stockingCycleDays(productionDays + shippingDays)
                .safetyStockDays(config.getEffectiveSafetyStockDays())
                .stockingCoefficient(hotSellingCoefficient)
                .isEmergency(isUrgent)
                .urgencyNote(urgencyNote)
                .stockoutRiskDays(getMinDaysToStockout(multiRegionAnalysis))
                .expectedStockoutQuantity(multiRegionAnalysis.getTotalSuggestedReplenishment())
                .reason(buildHotSellingReason(multiRegionAnalysis, finalQuantity))
                .build();
    }
    
    /**
     * 一站式爆款备货评估入口
     * 整合多区域分析和备货计算
     * 
     * @param config 商品备货配置
     * @param regionInventories 各区域库存
     * @param regionInTransit 各区域在途库存
     * @param salesHistory 销售历史数据
     * @param regionSalesRatios 各区域销量占比
     * @param existingShipments 已有发货计划
     * @param baseDate 基准日期
     * @return 备货计算结果，如果不符合爆款条件则返回null
     */
    public StockingResult evaluateAndCalculateNewSkuStocking(
            ProductStockConfig config,
            Map<ShippingRegion, Integer> regionInventories,
            Map<ShippingRegion, Integer> regionInTransit,
            SalesHistoryData salesHistory,
            Map<ShippingRegion, BigDecimal> regionSalesRatios,
            Map<LocalDate, Integer> existingShipments,
            LocalDate baseDate) {
        
        logger.info("开始爆款备货评估：SKU={}", config.getSku());
        
        // 1. 先判断是否为爆款商品
        boolean isHotSelling = isHotSellingProduct(salesHistory);
        
        // 2. 执行多区域断货分析
        MultiRegionStockoutAnalysis analysis = analyzeMultiRegionStockout(
                config.getProductId(),
                config.getSku(),
                regionInventories,
                regionInTransit,
                salesHistory,
                regionSalesRatios,
                existingShipments,
                config.getProductionDays(),
                config.getEffectiveSafetyStockDays(),
                baseDate
        );
        
        // 3. 如果不是爆款商品且没有触发多区域风险，返回null
        if (!isHotSelling && !analysis.isHotSellingModelTriggered()) {
            logger.debug("不符合爆款备货条件：SKU={}", config.getSku());
            return null;
        }
        
        // 4. 如果是爆款商品但没有风险，返回提示信息
        if (analysis.getAtRiskRegionCount() == 0) {
            logger.debug("爆款商品暂无断货风险：SKU={}", config.getSku());
            return null;
        }
        
        // 5. 计算爆款备货
        return calculateHotSellingStocking(config, salesHistory, analysis, baseDate);
    }
    
    /**
     * 批量评估多个SKU的爆款备货需求
     * 
     * @param configs 商品配置列表
     * @param regionInventoriesMap SKU -> 各区域库存映射
     * @param regionInTransitMap SKU -> 各区域在途库存映射
     * @param salesHistoryMap SKU -> 销售历史映射
     * @param baseDate 基准日期
     * @return 需要爆款备货的结果列表
     */
    public List<StockingResult> batchEvaluateNewSkuStocking(
            List<ProductStockConfig> configs,
            Map<String, Map<ShippingRegion, Integer>> regionInventoriesMap,
            Map<String, Map<ShippingRegion, Integer>> regionInTransitMap,
            Map<String, SalesHistoryData> salesHistoryMap,
            LocalDate baseDate) {
        
        logger.info("批量爆款备货评估，商品数量：{}", configs.size());
        
        List<StockingResult> results = new ArrayList<>();
        
        for (ProductStockConfig config : configs) {
            if (!Boolean.TRUE.equals(config.getAutoStockingEnabled())) {
                continue;
            }
            
            try {
                String sku = config.getSku();
                
                StockingResult result = evaluateAndCalculateNewSkuStocking(
                        config,
                        regionInventoriesMap != null ? regionInventoriesMap.get(sku) : null,
                        regionInTransitMap != null ? regionInTransitMap.get(sku) : null,
                        salesHistoryMap != null ? salesHistoryMap.get(sku) : null,
                        null, // 使用默认的区域销量占比
                        null, // 无已有发货计划
                        baseDate
                );
                
                if (result != null && result.getFinalQuantity() != null && result.getFinalQuantity() > 0) {
                    results.add(result);
                }
            } catch (Exception e) {
                logger.error("爆款备货评估失败：SKU={}", config.getSku(), e);
            }
        }
        
        logger.info("批量爆款备货评估完成，需要备货商品数量：{}", results.size());
        return results;
    }
    
    // ==================== 辅助方法 ====================
    
    /**
     * 计算日均销量
     */
    private BigDecimal calculateDailyAvg(Integer totalSales, int days) {
        if (totalSales == null || totalSales <= 0 || days <= 0) {
            return BigDecimal.ZERO;
        }
        return BigDecimal.valueOf(totalSales)
                .divide(BigDecimal.valueOf(days), CALCULATION_SCALE, RoundingMode.HALF_UP);
    }
    
    /**
     * 计算加权日均销量
     */
    private BigDecimal calculateWeightedDailyAvg(SalesHistoryData salesHistory) {
        if (salesHistory == null) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal avg30 = calculateDailyAvg(salesHistory.getTotalSales30Days(), 30);
        BigDecimal avg15 = calculateDailyAvg(salesHistory.getTotalSales15Days(), 15);
        BigDecimal avg7 = calculateDailyAvg(salesHistory.getTotalSales7Days(), 7);
        
        // 加权平均：20% * 30天 + 30% * 15天 + 50% * 7天
        return avg30.multiply(new BigDecimal("0.20"))
                .add(avg15.multiply(new BigDecimal("0.30")))
                .add(avg7.multiply(new BigDecimal("0.50")))
                .setScale(CALCULATION_SCALE, RoundingMode.HALF_UP);
    }
    
    /**
     * 获取或计算各区域销量占比
     */
    private Map<ShippingRegion, BigDecimal> getSalesRatios(Map<ShippingRegion, BigDecimal> providedRatios) {
        if (providedRatios != null && !providedRatios.isEmpty()) {
            return providedRatios;
        }
        
        // 默认按区域人口/市场规模分配
        Map<ShippingRegion, BigDecimal> defaultRatios = new HashMap<>();
        defaultRatios.put(ShippingRegion.US_WEST, new BigDecimal("0.30"));
        defaultRatios.put(ShippingRegion.US_EAST, new BigDecimal("0.35"));
        defaultRatios.put(ShippingRegion.US_CENTRAL, new BigDecimal("0.20"));
        defaultRatios.put(ShippingRegion.US_SOUTH, new BigDecimal("0.15"));
        return defaultRatios;
    }
    
    /**
     * 计算预测天数
     */
    private int calculateHorizonDays(ShippingRegion region, int productionDays, int shippingDays) {
        int baseHorizon = productionDays + shippingDays;
        
        switch (region) {
            case US_WEST:
                return Math.max(baseHorizon, 60);
            case US_EAST:
                return Math.max(baseHorizon, 90);
            case US_CENTRAL:
            case US_SOUTH:
            default:
                return Math.max(baseHorizon, DEFAULT_HORIZON_DAYS);
        }
    }
    
    /**
     * 计算动态备货系数
     * 根据销量增长速度和风险程度动态调整
     */
    private BigDecimal calculateDynamicCoefficient(
            SalesHistoryData salesHistory, MultiRegionStockoutAnalysis analysis) {
        
        BigDecimal coefficient = HOT_SELLING_BASE_COEFFICIENT;
        
        // 根据销量增长调整
        if (salesHistory != null) {
            BigDecimal avg30 = calculateDailyAvg(salesHistory.getTotalSales30Days(), 30);
            BigDecimal avg7 = calculateDailyAvg(salesHistory.getTotalSales7Days(), 7);
            
            if (avg30.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal growthRatio = avg7.divide(avg30, CALCULATION_SCALE, RoundingMode.HALF_UP);
                // 销量增长越快，系数越高
                if (growthRatio.compareTo(new BigDecimal("3.0")) >= 0) {
                    coefficient = coefficient.multiply(HIGH_GROWTH_COEFFICIENT);
                } else if (growthRatio.compareTo(SALES_SURGE_THRESHOLD) >= 0) {
                    coefficient = coefficient.multiply(MEDIUM_GROWTH_COEFFICIENT);
                }
            }
        }
        
        // 根据断货区域数调整
        if (analysis.getStockoutRegionCount() >= 3) {
            coefficient = coefficient.multiply(MULTI_REGION_URGENCY_COEFFICIENT);
        } else if (analysis.getStockoutRegionCount() >= 2) {
            coefficient = coefficient.multiply(DUAL_REGION_STOCKOUT_COEFFICIENT);
        }
        
        return coefficient.setScale(2, RoundingMode.HALF_UP);
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
     * 获取最短断货天数
     */
    private Integer getMinDaysToStockout(MultiRegionStockoutAnalysis analysis) {
        Integer minDays = null;
        for (RegionStockoutDetail detail : analysis.getRegionDetails().values()) {
            if (detail.getDaysToStockout() != null) {
                if (minDays == null || detail.getDaysToStockout() < minDays) {
                    minDays = detail.getDaysToStockout();
                }
            }
        }
        return minDays;
    }
    
    /**
     * 构建爆款备货原因说明
     */
    private String buildHotSellingReason(MultiRegionStockoutAnalysis analysis, int finalQuantity) {
        StringBuilder reason = new StringBuilder();
        reason.append("新款爆款备货模型：");
        reason.append("检测到").append(analysis.getAtRiskRegionCount()).append("个区域存在断货风险");
        
        if (analysis.getStockoutRegionCount() > 0) {
            reason.append("（其中").append(analysis.getStockoutRegionCount()).append("个已断货）");
        }
        
        reason.append("；风险区域：");
        analysis.getAtRiskRegions().keySet().forEach(region -> 
                reason.append(region.getDescription()).append("、"));
        
        if (reason.toString().endsWith("、")) {
            reason.setLength(reason.length() - 1);
        }
        
        reason.append("；建议紧急备货量=").append(finalQuantity);
        
        return reason.toString();
    }
    
    /**
     * 生成备货策略建议
     */
    private String generateStrategy(MultiRegionStockoutAnalysis analysis) {
        StringBuilder strategy = new StringBuilder();
        
        if (analysis.getStockoutRegionCount() >= 3) {
            strategy.append("【严重警告】多区域全面断货，建议：\n");
            strategy.append("1. 立即启动紧急空运补货\n");
            strategy.append("2. 协调现有在途货物优先配送\n");
            strategy.append("3. 考虑临时采购替代品");
        } else if (analysis.getStockoutRegionCount() >= 1) {
            strategy.append("【警告】部分区域已断货，建议：\n");
            strategy.append("1. 优先补充断货区域\n");
            strategy.append("2. 从库存充足区域调配\n");
            strategy.append("3. 加快在途货物清关");
        } else if (analysis.getAtRiskRegionCount() >= 2) {
            strategy.append("【注意】多区域存在断货风险，建议：\n");
            strategy.append("1. 启动爆款备货模型\n");
            strategy.append("2. 增加备货量30%-50%\n");
            strategy.append("3. 监控销量变化");
        } else if (analysis.getAtRiskRegionCount() == 1) {
            strategy.append("【提示】单区域存在断货风险，建议：\n");
            strategy.append("1. 针对性补货\n");
            strategy.append("2. 关注销量趋势");
        } else {
            strategy.append("各区域库存充足，暂无备货需求");
        }
        
        return strategy.toString();
    }
}
