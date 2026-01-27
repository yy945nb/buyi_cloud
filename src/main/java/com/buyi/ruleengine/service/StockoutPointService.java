package com.buyi.ruleengine.service;

import com.buyi.ruleengine.enums.RiskLevel;
import com.buyi.ruleengine.model.CosOosPointDetail;
import com.buyi.ruleengine.model.CosOosPointResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 断货点分析服务
 * Stockout Point Analysis Service
 * <p>
 * 将未来若干天按固定间隔为监控点，逐点预测库存并判断风险。
 * <p>
 * 风险规则：
 * - 若 projectedInventory <= 0 => OUTAGE（断货）
 * - 若 projectedInventory < safetyStock（= dailyAvg * safetyStockDays）=> AT_RISK（风险）
 * - 否则 OK
 */
public class StockoutPointService {

    private static final Logger logger = LoggerFactory.getLogger(StockoutPointService.class);

    /**
     * 默认监控间隔天数
     */
    private static final int DEFAULT_INTERVAL_DAYS = 7;

    /**
     * 默认计算精度
     */
    private static final int CALCULATION_SCALE = 4;

    /**
     * 连续未发货触发风险的周数阈值
     */
    private static final int CONSECUTIVE_MISSED_THRESHOLD = 5;
    
    /** 触发爆款备货模型的最少风险区域数 */
    private static final int MIN_RISK_REGIONS_FOR_HOT_MODEL = 2;

    /**
     * 评估断货风险监控点
     * Evaluate stockout risk at monitoring points
     *
     * @param currentInventory 当前可用库存（件）
     * @param dailyAvg         当前日均销量（件/天）
     * @param shipmentQtyMap   实际发货单的发货日期和数量列表，可为空
     * @param productionDays   生产天数（若发货日已为出运日，可传0；若发货日为下单日需加 productionDays）
     * @param shippingDays     海运时长（天），比如 50
     * @param safetyStockDays  安全库存天数（天），比如 35
     * @param intervalDays     窗口长度（天），通常 7
     * @param horizonDays      预测总天数（天），例如 80
     * @param baseDate         基准日期（通常 LocalDate.now()），监控点为 baseDate + offset
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

        // 初始化参数
        EvaluationParams params = buildParams(currentInventory, dailyAvg, shipmentQtyMap,
                productionDays, shippingDays, safetyStockDays, intervalDays, horizonDays, baseDate);

        logger.debug("Starting stockout evaluation: baseDate={}, horizon={}, interval={}",
                params.baseDate, params.horizonDays, params.intervalDays);

        // 计算到达映射
        Map<LocalDate, BigDecimal> arrivalMap = buildArrivalMap(params.shipmentMap, params.shippingDays);

        // 执行评估
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

        // 基准日期
        params.baseDate = (baseDate == null) ? LocalDate.now() : baseDate;

        // 时间参数
        params.productionDays = defaultIfNull(productionDays, 25);
        params.shippingDays = defaultIfNull(shippingDays, 30);
        params.safetyStockDays = defaultIfNull(safetyStockDays, 35);
        params.intervalDays = (intervalDays == null || intervalDays <= 0) ? DEFAULT_INTERVAL_DAYS : intervalDays;

        // 预测总天数
        int defaultHorizon = params.productionDays + params.shippingDays;
        params.horizonDays = (horizonDays == null || horizonDays <= 0) ? defaultHorizon : horizonDays;
        if (params.horizonDays <= 0) {
            params.horizonDays = defaultHorizon > 0 ? defaultHorizon : DEFAULT_INTERVAL_DAYS;
        }

        // 库存和销量
        params.currentInventory = (currentInventory == null) ? BigDecimal.ZERO : BigDecimal.valueOf(currentInventory);
        params.dailyAvg = (dailyAvg == null) ? BigDecimal.ZERO : dailyAvg;

        // 发货映射
        params.shipmentMap = (shipmentQtyMap == null) ? Collections.emptyMap() : shipmentQtyMap;

        // 计算监控范围
        params.minOffsetExclusive = params.shippingDays;
        params.maxOffsetInclusive = params.productionDays + params.shippingDays;

        // 计算安全库存水平
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
     * 评估所有监控点
     */
    private CosOosPointResponse evaluateMonitoringPoints(
            EvaluationParams params,
            Map<LocalDate, BigDecimal> arrivalMap) {

        CosOosPointResponse response = new CosOosPointResponse();

        int windowCount = (params.horizonDays + params.intervalDays - 1) / params.intervalDays;
        int consecutiveMissed = 0;

        // 排序到达日期以便高效累加
        List<LocalDate> sortedArrivals = arrivalMap.keySet().stream()
                .sorted()
                .collect(Collectors.toList());
        List<LocalDate> sortedShipmentDates = params.shipmentMap.keySet().stream()
                .sorted()
                .collect(Collectors.toList());

        BigDecimal cumulativeArrived = BigDecimal.ZERO;
        int arrivalIndex = 0;

        for (int windowNum = 1; windowNum <= windowCount; windowNum++) {
            int offset = Math.min(windowNum * params.intervalDays, params.horizonDays);

            LocalDate windowEnd = params.baseDate.plusDays(offset);
            LocalDate windowStart = params.baseDate.plusDays((windowNum - 1) * params.intervalDays + 1);

            // 累加在此窗口内到达的补货
            while (arrivalIndex < sortedArrivals.size() &&
                    !sortedArrivals.get(arrivalIndex).isAfter(windowEnd)) {
                LocalDate arrivalDate = sortedArrivals.get(arrivalIndex);
                cumulativeArrived = cumulativeArrived.add(arrivalMap.getOrDefault(arrivalDate, BigDecimal.ZERO));
                arrivalIndex++;
            }

            // 超出生产+发货时间，停止生成监控点
            if (offset > params.maxOffsetInclusive) {
                break;
            }

            // 跳过当前+发货时间内的监控点（这段时间设置监控点无意义）
            if (offset <= params.minOffsetExclusive) {
                continue;
            }

            // 检测窗口内是否有发货
            ShipmentWindowInfo shipmentInfo = analyzeShipmentInWindow(
                    sortedShipmentDates, params.shipmentMap, windowStart, windowEnd, params.shippingDays);

            // 更新连续未发货计数
            if (!shipmentInfo.hasShipment) {
                consecutiveMissed++;
            } else {
                consecutiveMissed = 0;
            }

            // 计算预测库存
            BigDecimal cumulativeDemand = params.dailyAvg.multiply(BigDecimal.valueOf(offset));
            BigDecimal projectedInventory = params.currentInventory
                    .add(cumulativeArrived)
                    .subtract(cumulativeDemand)
                    .setScale(CALCULATION_SCALE, RoundingMode.HALF_UP);

            // 计算可支撑天数
            BigDecimal projectedDays = calculateProjectedDays(projectedInventory, params.dailyAvg);

            // 评估风险等级
            RiskAssessment assessment = assessRisk(
                    projectedInventory, params.safetyLevel, params.safetyStockDays, consecutiveMissed, params.intervalDays);

            // 构建监控点详情
            CosOosPointDetail detail = buildMonitorPointDetail(
                    windowStart, windowEnd, offset, projectedInventory, projectedDays,
                    params.safetyLevel, assessment, shipmentInfo, consecutiveMissed,
                    params.shipmentMap, params.shippingDays);

            // 添加到响应
            response.addMonitorPoint(detail);

            // 记录首个风险点
            if (assessment.riskLevel != RiskLevel.OK && response.getFirstRiskPoint() == null) {
                response.setFirstRiskPoint(detail);
                response.setOosStartDate(windowStart);
                response.setOosEndDate(windowEnd);
                response.setOosDays(offset);
                response.setOosNum(assessment.oosQuantity.setScale(0, RoundingMode.CEILING).intValue());
                response.setMonitorDate(params.baseDate.plusDays(offset));
                response.setOosReason(assessment.note);
                response.setOosType(1);
            }
        }

        return response;
    }

    /**
     * 分析窗口内的发货情况
     */
    private ShipmentWindowInfo analyzeShipmentInWindow(
            List<LocalDate> sortedShipmentDates,
            Map<LocalDate, Integer> shipmentMap,
            LocalDate windowStart,
            LocalDate windowEnd,
            int shippingDays) {

        ShipmentWindowInfo info = new ShipmentWindowInfo();

        for (LocalDate shipDate : sortedShipmentDates) {
            LocalDate arrivalDate = shipDate.plusDays(shippingDays);

            // 情况1：到达日在窗口内
            boolean arrivalInWindow = !arrivalDate.isBefore(windowStart) && !arrivalDate.isAfter(windowEnd);

            // 情况2：已发出但尚未到达（在途）
            boolean inTransit = !shipDate.isAfter(windowEnd) && arrivalDate.isAfter(windowEnd);

            if (arrivalInWindow || inTransit) {
                info.hasShipment = true;
                info.shipmentDate = shipDate;
                info.arrivalDate = arrivalDate;
                info.shipmentQty = shipmentMap.getOrDefault(shipDate, 0);
                info.isInTransit = inTransit;
                break;
            }
        }

        return info;
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
     * 评估风险等级
     */
    private RiskAssessment assessRisk(
            BigDecimal projectedInventory,
            BigDecimal safetyLevel,
            int safetyStockDays,
            int consecutiveMissed,
            int intervalDays) {

        RiskAssessment assessment = new RiskAssessment();
        boolean longMiss = consecutiveMissed >= CONSECUTIVE_MISSED_THRESHOLD;

        if (projectedInventory.compareTo(BigDecimal.ZERO) <= 0) {
            // 断货
            assessment.riskLevel = RiskLevel.OUTAGE;
            assessment.oosQuantity = projectedInventory.abs();
            assessment.note = "预计在此时点或之前发生断货";
        } else if (projectedInventory.compareTo(safetyLevel) < 0 || longMiss) {
            // 风险
            assessment.riskLevel = RiskLevel.AT_RISK;
            assessment.oosQuantity = safetyLevel.subtract(projectedInventory).max(BigDecimal.ZERO);

            StringBuilder sb = new StringBuilder();
            if (longMiss) {
                sb.append("已连续 ").append(consecutiveMissed).append(" 周未发货（累计 ")
                        .append(consecutiveMissed * intervalDays).append(" 天），存在断货风险；");
            }
            sb.append("库存低于安全库存(").append(safetyStockDays).append(" 天)或将接近风险点");
            assessment.note = sb.toString();
        } else {
            // 安全
            assessment.riskLevel = RiskLevel.OK;
            assessment.oosQuantity = BigDecimal.ZERO;
            assessment.note = "安全";
        }

        return assessment;
    }

    /**
     * 构建监控点详情
     */
    private CosOosPointDetail buildMonitorPointDetail(
            LocalDate windowStart,
            LocalDate windowEnd,
            int offsetDays,
            BigDecimal projectedInventory,
            BigDecimal projectedDays,
            BigDecimal safetyLevel,
            RiskAssessment assessment,
            ShipmentWindowInfo shipmentInfo,
            int consecutiveMissed,
            Map<LocalDate, Integer> shipmentMap,
            int shippingDays) {

        CosOosPointDetail detail = new CosOosPointDetail();
        detail.setWindowStart(windowStart);
        detail.setWindowEnd(windowEnd);
        detail.setOffsetDays(offsetDays);
        detail.setProjectedInventory(projectedInventory);
        detail.setProjectedDays(projectedDays);
        detail.setSafetyLevel(safetyLevel);
        detail.setOosQuantity(assessment.oosQuantity.setScale(0, RoundingMode.CEILING));
        detail.setRiskLevel(assessment.riskLevel);
        detail.setHasShipmentInWindow(shipmentInfo.hasShipment);
        detail.setConsecutiveMissedWeeks(consecutiveMissed);

        // 构建详细说明
        String detailNote = buildDetailNote(
                shipmentInfo, assessment, windowStart, windowEnd,
                projectedInventory, shippingDays);
        detail.setNote(detailNote);

        return detail;
    }

    /**
     * 构建详细说明文本
     */
    private String buildDetailNote(
            ShipmentWindowInfo shipmentInfo,
            RiskAssessment assessment,
            LocalDate windowStart,
            LocalDate windowEnd,
            BigDecimal projectedInventory,
            int shippingDays) {

        StringBuilder note = new StringBuilder();

        // 发货状态说明
        if (!shipmentInfo.hasShipment) {
            note.append("窗口[").append(windowStart).append(" ~ ").append(windowEnd).append("] 无发货单；");
        } else {
            if (shipmentInfo.isInTransit) {
                // 预计到达日期 = 发货日期 + 海运时长
                LocalDate expectedArrival = shipmentInfo.shipmentDate.plusDays(shippingDays);
                note.append("窗口内存在在途/未到达发货单，预计到达：").append(expectedArrival).append("；");
            } else {
                note.append("窗口内存在将要到达或已到达的发货单；");
            }
            note.append("本次发货量：").append(shipmentInfo.shipmentQty).append("；");
        }

        // 库存预测说明
        note.append("预计库存：").append(projectedInventory).append("；");
        note.append("预计缺货量：").append(assessment.oosQuantity.setScale(0, RoundingMode.CEILING)).append("；");
        note.append(assessment.note);

        return note.toString();
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
        int minOffsetExclusive;
        int maxOffsetInclusive;
        BigDecimal safetyLevel;
    }

    /**
     * 发货窗口信息内部类
     */
    private static class ShipmentWindowInfo {
        boolean hasShipment = false;
        LocalDate shipmentDate;
        LocalDate arrivalDate;
        int shipmentQty = 0;
        boolean isInTransit = false;
    }

    /**
     * 风险评估结果内部类
     */
    private static class RiskAssessment {
        RiskLevel riskLevel;
        BigDecimal oosQuantity = BigDecimal.ZERO;
        String note;
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
