package com.buyi.ruleengine.service;

import com.buyi.ruleengine.enums.RiskLevel;
import com.buyi.ruleengine.model.CosOosPointDetail;
import com.buyi.ruleengine.model.CosOosPointResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 断货点分析服务
 * Stockout Point Analysis Service
 * <p>
 * 内部按日粒度计算库存曲线，对外按周窗口输出监控点。
 * <p>
 * 风险规则：
 * - 若某周窗口内任意一天 inv(d) <= 0 => OUTAGE（单仓断货）
 * - 若 inv(shippingDays) <= 0（海运路径不可救）=> 第1周 AT_RISK（除非第1周已OUTAGE）
 * - 否则 OK
 */
public class StockoutPointService {

    private static final Logger logger = LoggerFactory.getLogger(StockoutPointService.class);

    /** 默认监控间隔天数 */
    private static final int DEFAULT_INTERVAL_DAYS = 7;

    /** 默认计算精度 */
    private static final int CALCULATION_SCALE = 4;

    /** 触发爆款备货模型的最少风险区域数 */
    private static final int MIN_RISK_REGIONS_FOR_HOT_MODEL = 2;

    /**
     * 评估断货风险监控点（按周窗口输出，内部精确到天）
     *
     * @param currentInventory 当前可用库存（件）
     * @param dailyAvg         当前日均销量（件/天）
     * @param shipmentQtyMap   在途库存：key=发货日期，value=数量；到达日=发货日+shippingDays
     * @param productionDays   生产天数（默认20，用于生产路径 leadTime 计算及文案说明）
     * @param shippingDays     海运时长（天），如美西30、美东50
     * @param safetyStockDays  安全库存天数（保留字段，不再用于 AT_RISK 判定）
     * @param intervalDays     窗口长度（天），通常7
     * @param horizonDays      预测总天数（天），决定输出范围；productionDays 不截断此范围
     * @param baseDate         基准日期，监控点为 baseDate+offset
     * @return 监控点响应（包含所有监控点列表）
     */
    public CosOosPointResponse evaluateWithWeeklyShipments(Integer currentInventory,
                                                           BigDecimal dailyAvg,
                                                           Map<LocalDate, Integer> shipmentQtyMap,
                                                           Integer productionDays,
                                                           Integer shippingDays,
                                                           Integer safetyStockDays,
                                                           Integer intervalDays,
                                                           Integer horizonDays,
                                                           LocalDate baseDate) {

        EvaluationParams params = buildParams(currentInventory, dailyAvg, shipmentQtyMap,
                productionDays, shippingDays, safetyStockDays, intervalDays, horizonDays, baseDate);

        logger.debug("Starting stockout evaluation: baseDate={}, horizon={}, interval={}",
                params.baseDate, params.horizonDays, params.intervalDays);

        Map<LocalDate, BigDecimal> arrivalMap = buildArrivalMap(params.shipmentMap, params.shippingDays);

        return evaluateMonitoringPoints(params, arrivalMap);
    }

    /**
     * 构建评估参数（包含默认值处理）
     */
    private EvaluationParams buildParams(Integer currentInventory,
                                         BigDecimal dailyAvg,
                                         Map<LocalDate, Integer> shipmentQtyMap,
                                         Integer productionDays,
                                         Integer shippingDays,
                                         Integer safetyStockDays,
                                         Integer intervalDays,
                                         Integer horizonDays,
                                         LocalDate baseDate) {

        EvaluationParams params = new EvaluationParams();

        params.baseDate = (baseDate == null) ? LocalDate.now() : baseDate;
        params.productionDays = defaultIfNull(productionDays, 20);
        params.shippingDays = defaultIfNull(shippingDays, 30);
        params.safetyStockDays = defaultIfNull(safetyStockDays, 35);
        params.intervalDays = (intervalDays == null || intervalDays <= 0) ? DEFAULT_INTERVAL_DAYS : intervalDays;

        int defaultHorizon = params.productionDays + params.shippingDays;
        params.horizonDays = (horizonDays == null || horizonDays <= 0) ? defaultHorizon : horizonDays;
        if (params.horizonDays <= 0) {
            params.horizonDays = defaultHorizon > 0 ? defaultHorizon : DEFAULT_INTERVAL_DAYS;
        }

        params.currentInventory = (currentInventory == null) ? BigDecimal.ZERO : BigDecimal.valueOf(currentInventory);
        params.dailyAvg = (dailyAvg == null) ? BigDecimal.ZERO : dailyAvg;
        params.shipmentMap = (shipmentQtyMap == null) ? Collections.emptyMap() : shipmentQtyMap;
        params.safetyLevel = params.dailyAvg.multiply(BigDecimal.valueOf(params.safetyStockDays));

        return params;
    }

    /**
     * 构建到达映射（发货日期 -> 到达日期及数量）
     */
    private Map<LocalDate, BigDecimal> buildArrivalMap(Map<LocalDate, Integer> shipmentMap, int shippingDays) {
        Map<LocalDate, BigDecimal> arrivalMap = new HashMap<>();
        for (Map.Entry<LocalDate, Integer> entry : shipmentMap.entrySet()) {
            LocalDate shipDate = entry.getKey();
            if (shipDate == null) {
                continue;
            }
            BigDecimal qty = (entry.getValue() == null) ? BigDecimal.ZERO : BigDecimal.valueOf(entry.getValue());
            LocalDate arrivalDate = shipDate.plusDays(shippingDays);
            arrivalMap.merge(arrivalDate, qty, BigDecimal::add);
        }
        return arrivalMap;
    }

    /**
     * 评估所有监控点（日粒度曲线 + 周窗口输出）
     */
    private CosOosPointResponse evaluateMonitoringPoints(
            EvaluationParams params,
            Map<LocalDate, BigDecimal> arrivalMap) {

        CosOosPointResponse response = new CosOosPointResponse();

        if (params.horizonDays <= 0) {
            return response;
        }

        int windowCount = (params.horizonDays + params.intervalDays - 1) / params.intervalDays;

        // 按到达日期排序，用于滚动指针累加
        List<LocalDate> sortedArrivals = arrivalMap.keySet().stream()
                .sorted()
                .collect(Collectors.toList());

        // --- Step 1: 日粒度库存曲线 ---
        BigDecimal cumulativeArrived = BigDecimal.ZERO;
        int arrivalIndex = 0;
        LocalDate outageDate = null;
        BigDecimal invAtShipping = null;       // inv(shippingDays)，用于 AT_RISK 判定

        // 每个周窗口的状态（1-indexed）
        boolean[] windowHasOutage = new boolean[windowCount + 1];
        BigDecimal[] windowEndInv = new BigDecimal[windowCount + 1];

        for (int d = 1; d <= params.horizonDays; d++) {
            LocalDate date = params.baseDate.plusDays(d);

            // 滚动累加当天及之前到达的补货（含当天）
            while (arrivalIndex < sortedArrivals.size()
                    && !sortedArrivals.get(arrivalIndex).isAfter(date)) {
                BigDecimal arrQty = arrivalMap.getOrDefault(
                        sortedArrivals.get(arrivalIndex), BigDecimal.ZERO);
                cumulativeArrived = cumulativeArrived.add(arrQty);
                arrivalIndex++;
            }

            BigDecimal demand = params.dailyAvg.multiply(BigDecimal.valueOf(d));
            BigDecimal inv = params.currentInventory
                    .add(cumulativeArrived)
                    .subtract(demand)
                    .setScale(CALCULATION_SCALE, RoundingMode.HALF_UP);

            // 记录最早断货日
            if (outageDate == null && inv.compareTo(BigDecimal.ZERO) <= 0) {
                outageDate = date;
            }

            // 记录海运 leadTime 处的库存，用于 AT_RISK 判定
            if (d == params.shippingDays) {
                invAtShipping = inv;
            }

            // 确定当天所属周窗口（第 w 周包含 d = (w-1)*interval+1 .. min(w*interval, horizonDays)）
            int w = (d - 1) / params.intervalDays + 1;
            if (w <= windowCount) {
                if (inv.compareTo(BigDecimal.ZERO) <= 0) {
                    windowHasOutage[w] = true;
                }
                int wEndDay = Math.min(w * params.intervalDays, params.horizonDays);
                if (d == wEndDay) {
                    windowEndInv[w] = inv;
                }
            }
        }

        // --- Step 2: 设置精确断货日字段 ---
        if (outageDate != null) {
            response.setOosStartDate(outageDate);
            response.setOosDays((int) ChronoUnit.DAYS.between(params.baseDate, outageDate));
        }

        // --- Step 3: 判断"海运路径不可救"AT_RISK ---
        boolean atRiskWeek1 = invAtShipping != null
                && invAtShipping.compareTo(BigDecimal.ZERO) <= 0;
        String atRiskReason = null;
        if (atRiskWeek1) {
            atRiskReason = "海运路径不可救：即使今天立即发货，" + params.shippingDays
                    + "天后(leadTime)到达时inv=" + invAtShipping.setScale(2, RoundingMode.HALF_UP)
                    + (outageDate != null ? "，精确断货日：" + outageDate : "");
        } else {
            // 生产路径信息仅用于 note 说明，不独立触发 AT_RISK
        }

        // --- Step 4: 生成周窗口监控点 ---
        for (int windowNum = 1; windowNum <= windowCount; windowNum++) {
            int wEndOffset = Math.min(windowNum * params.intervalDays, params.horizonDays);
            int wStartOffset = (windowNum - 1) * params.intervalDays + 1;

            LocalDate winStart = params.baseDate.plusDays(wStartOffset);
            LocalDate winEnd = params.baseDate.plusDays(wEndOffset);

            BigDecimal invAtEnd = windowEndInv[windowNum] != null
                    ? windowEndInv[windowNum] : BigDecimal.ZERO;

            // 确定风险等级：OUTAGE 优先，其次仅第1周判断 AT_RISK，否则 OK
            RiskLevel riskLevel;
            BigDecimal oosQuantity = BigDecimal.ZERO;
            String note;

            if (windowHasOutage[windowNum]) {
                riskLevel = RiskLevel.OUTAGE;
                oosQuantity = invAtEnd.abs();
                note = "第" + windowNum + "周[" + winStart + "~" + winEnd + "] 断货"
                        + (outageDate != null ? "，精确断货日：" + outageDate : "")
                        + "，窗口末预测库存：" + invAtEnd.setScale(2, RoundingMode.HALF_UP);
            } else if (atRiskWeek1 && windowNum == 1) {
                riskLevel = RiskLevel.AT_RISK;
                note = "第1周[" + winStart + "~" + winEnd + "] 存在断货风险（不可救预警），"
                        + atRiskReason
                        + "，窗口末预测库存：" + invAtEnd.setScale(2, RoundingMode.HALF_UP);
            } else {
                riskLevel = RiskLevel.OK;
                note = "第" + windowNum + "周[" + winStart + "~" + winEnd + "] 安全"
                        + "，窗口末预测库存：" + invAtEnd.setScale(2, RoundingMode.HALF_UP);
            }

            BigDecimal projectedDays = calculateProjectedDays(invAtEnd, params.dailyAvg);

            CosOosPointDetail detail = new CosOosPointDetail();
            detail.setWindowStart(winStart);
            detail.setWindowEnd(winEnd);
            detail.setOffsetDays(wEndOffset);
            detail.setProjectedInventory(invAtEnd);
            detail.setProjectedDays(projectedDays);
            detail.setSafetyLevel(params.safetyLevel);
            detail.setOosQuantity(oosQuantity.setScale(0, RoundingMode.CEILING));
            detail.setRiskLevel(riskLevel);
            detail.setNote(note);

            response.addMonitorPoint(detail);

            // 记录首个风险点
            if (riskLevel != RiskLevel.OK && response.getFirstRiskPoint() == null) {
                response.setFirstRiskPoint(detail);
                response.setOosEndDate(winEnd);
                response.setOosReason(note);
                response.setOosNum(oosQuantity.setScale(0, RoundingMode.CEILING).intValue());
                response.setMonitorDate(winEnd);
                response.setOosType(1);
            }
        }

        return response;
    }

    /**
     * 计算可支撑天数
     */
    private BigDecimal calculateProjectedDays(BigDecimal projectedInventory, BigDecimal dailyAvg) {
        if (dailyAvg.compareTo(BigDecimal.ZERO) > 0) {
            return projectedInventory.divide(dailyAvg, CALCULATION_SCALE, RoundingMode.HALF_UP);
        }
        return null;
    }

    /**
     * 辅助方法：空值转默认值
     */
    private int defaultIfNull(Integer value, int defaultValue) {
        return (value == null) ? defaultValue : value;
    }

    /**
     * 评估参数内部类
     */
    private static class EvaluationParams {
        LocalDate baseDate;
        int productionDays;
        int shippingDays;
        int safetyStockDays;
        int intervalDays;
        int horizonDays;
        BigDecimal currentInventory;
        BigDecimal dailyAvg;
        Map<LocalDate, Integer> shipmentMap;
        BigDecimal safetyLevel;
    }
    
    // ==================== 多区域断货分析扩展 ====================
    
    /**
     * 多区域断货点分析
     * Multi-Region Stockout Point Analysis
     * 
     * 同时分析多个区域的断货风险，用于爆款商品的全面风险评估。
     * 
     * @param regionInventories 各区域库存 (区域 -> 库存数量)
     * @param dailyAvg 总日均销量
     * @param regionSalesRatios 各区域销量占比 (区域 -> 占比，总和应为1.0)
     * @param shipmentQtyMap 发货计划
     * @param productionDays 生产天数
     * @param regionShippingDays 各区域海运时间 (区域 -> 海运天数)
     * @param safetyStockDays 安全库存天数
     * @param intervalDays 监控间隔
     * @param horizonDays 预测总天数
     * @param baseDate 基准日期
     * @return 各区域的断货分析结果
     */
    public Map<String, CosOosPointResponse> evaluateMultiRegionStockout(
            Map<String, Integer> regionInventories,
            BigDecimal dailyAvg,
            Map<String, BigDecimal> regionSalesRatios,
            Map<LocalDate, Integer> shipmentQtyMap,
            Integer productionDays,
            Map<String, Integer> regionShippingDays,
            Integer safetyStockDays,
            Integer intervalDays,
            Integer horizonDays,
            LocalDate baseDate) {
        
        Map<String, CosOosPointResponse> results = new java.util.HashMap<>();
        
        if (regionInventories == null || regionInventories.isEmpty()) {
            return results;
        }
        
        // 默认的销量占比（平均分配）
        Map<String, BigDecimal> salesRatios = regionSalesRatios;
        if (salesRatios == null || salesRatios.isEmpty()) {
            int regionCount = regionInventories.size();
            BigDecimal avgRatio = BigDecimal.ONE.divide(BigDecimal.valueOf(regionCount), 
                    CALCULATION_SCALE, java.math.RoundingMode.HALF_UP);
            salesRatios = new java.util.HashMap<>();
            for (String region : regionInventories.keySet()) {
                salesRatios.put(region, avgRatio);
            }
        }
        
        // 为每个区域执行断货分析
        for (Map.Entry<String, Integer> entry : regionInventories.entrySet()) {
            String region = entry.getKey();
            Integer inventory = entry.getValue();
            
            // 计算区域日均销量
            BigDecimal regionDailyAvg = dailyAvg.multiply(
                    salesRatios.getOrDefault(region, BigDecimal.ZERO));
            
            // 获取区域海运时间
            Integer shippingDays = regionShippingDays != null ? 
                    regionShippingDays.get(region) : 45;
            
            // 执行断货分析
            CosOosPointResponse response = evaluateWithWeeklyShipments(
                    inventory,
                    regionDailyAvg,
                    shipmentQtyMap,
                    productionDays,
                    shippingDays,
                    safetyStockDays,
                    intervalDays,
                    horizonDays,
                    baseDate
            );
            
            results.put(region, response);
        }
        
        return results;
    }
    
    /**
     * 快速多区域风险检测
     * Quick Multi-Region Risk Detection
     * 
     * 快速检测是否存在多区域断货风险，用于触发爆款备货模型。
     * 
     * @param regionInventories 各区域库存
     * @param dailyAvg 总日均销量
     * @param regionSalesRatios 各区域销量占比
     * @param regionShippingDays 各区域海运时间
     * @param safetyStockDays 安全库存天数
     * @param baseDate 基准日期
     * @return 存在风险的区域数量
     */
    public int detectMultiRegionRiskCount(
            Map<String, Integer> regionInventories,
            BigDecimal dailyAvg,
            Map<String, BigDecimal> regionSalesRatios,
            Map<String, Integer> regionShippingDays,
            Integer safetyStockDays,
            LocalDate baseDate) {
        
        int riskCount = 0;
        
        if (regionInventories == null || dailyAvg == null || 
                dailyAvg.compareTo(BigDecimal.ZERO) <= 0) {
            return riskCount;
        }
        
        int safeDays = safetyStockDays != null ? safetyStockDays : 35;
        BigDecimal safetyLevel = dailyAvg.multiply(BigDecimal.valueOf(safeDays));
        
        // 计算平均占比（如果没有提供）
        Map<String, BigDecimal> salesRatios = regionSalesRatios;
        if (salesRatios == null || salesRatios.isEmpty()) {
            int regionCount = regionInventories.size();
            BigDecimal avgRatio = BigDecimal.ONE.divide(BigDecimal.valueOf(regionCount), 
                    CALCULATION_SCALE, java.math.RoundingMode.HALF_UP);
            salesRatios = new java.util.HashMap<>();
            for (String region : regionInventories.keySet()) {
                salesRatios.put(region, avgRatio);
            }
        }
        
        for (Map.Entry<String, Integer> entry : regionInventories.entrySet()) {
            String region = entry.getKey();
            Integer inventory = entry.getValue() != null ? entry.getValue() : 0;
            
            // 计算区域日均销量
            BigDecimal regionDailyAvg = dailyAvg.multiply(
                    salesRatios.getOrDefault(region, BigDecimal.ZERO));
            
            // 获取区域海运时间
            int shippingDays = regionShippingDays != null ? 
                    regionShippingDays.getOrDefault(region, 45) : 45;
            
            // 计算区域安全库存
            BigDecimal regionSafetyLevel = regionDailyAvg.multiply(BigDecimal.valueOf(safeDays));
            
            // 计算海运到达时的预期库存
            BigDecimal expectedDemand = regionDailyAvg.multiply(BigDecimal.valueOf(shippingDays));
            BigDecimal expectedInventory = BigDecimal.valueOf(inventory).subtract(expectedDemand);
            
            // 判断风险
            if (expectedInventory.compareTo(BigDecimal.ZERO) <= 0) {
                // 断货风险
                riskCount++;
            } else if (expectedInventory.compareTo(regionSafetyLevel) < 0) {
                // 低于安全库存风险
                riskCount++;
            }
        }
        
        return riskCount;
    }
    
    /**
     * 判断是否应触发爆款备货模型
     * 
     * @param regionInventories 各区域库存
     * @param dailyAvg 总日均销量
     * @param regionSalesRatios 各区域销量占比
     * @param regionShippingDays 各区域海运时间
     * @param safetyStockDays 安全库存天数
     * @param baseDate 基准日期
     * @return 是否应触发爆款备货模型
     */
    public boolean shouldTriggerHotSellingModel(
            Map<String, Integer> regionInventories,
            BigDecimal dailyAvg,
            Map<String, BigDecimal> regionSalesRatios,
            Map<String, Integer> regionShippingDays,
            Integer safetyStockDays,
            LocalDate baseDate) {
        
        int riskCount = detectMultiRegionRiskCount(
                regionInventories, dailyAvg, regionSalesRatios,
                regionShippingDays, safetyStockDays, baseDate);
        
        // 当达到最少风险区域数时，触发爆款备货模型
        return riskCount >= MIN_RISK_REGIONS_FOR_HOT_MODEL;
    }
}
