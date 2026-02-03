package com.buyi.ruleengine.service;

import com.buyi.datawarehouse.model.IntransitInventory;
import com.buyi.datawarehouse.model.WarehouseMapping;
import com.buyi.datawarehouse.service.IntransitInventoryService;
import com.buyi.datawarehouse.service.WarehouseInventoryService;
import com.buyi.ruleengine.model.CosOosPointResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

/**
 * 基于仓库维度的断货点监控服务
 * Warehouse-based Stockout Point Monitoring Service
 * 
 * 扩展原有的StockoutPointService，支持按仓库维度计算在途库存和现有库存
 * Extends the original StockoutPointService to support warehouse-dimension inventory calculation
 */
public class WarehouseStockoutMonitoringService {
    
    private static final Logger logger = LoggerFactory.getLogger(WarehouseStockoutMonitoringService.class);
    
    private final StockoutPointService stockoutPointService;
    private final IntransitInventoryService intransitInventoryService;
    private final WarehouseInventoryService warehouseInventoryService;
    
    public WarehouseStockoutMonitoringService() {
        this.stockoutPointService = new StockoutPointService();
        this.intransitInventoryService = new IntransitInventoryService();
        this.warehouseInventoryService = new WarehouseInventoryService();
    }
    
    public WarehouseStockoutMonitoringService(StockoutPointService stockoutPointService,
                                              IntransitInventoryService intransitInventoryService,
                                              WarehouseInventoryService warehouseInventoryService) {
        this.stockoutPointService = stockoutPointService;
        this.intransitInventoryService = intransitInventoryService;
        this.warehouseInventoryService = warehouseInventoryService;
    }
    
    /**
     * 评估特定仓库和SKU的断货风险（基于仓库维度的在途库存）
     * Evaluate stockout risk for specific warehouse and SKU (warehouse-dimension based)
     * 
     * @param warehouseId 仓库ID
     * @param skuCode SKU编码
     * @param mode 模式：REGIONAL 或 FBA
     * @param currentInventory 当前库存（可选，如果为null则从数据库查询）
     * @param dailyAvg 日均销量
     * @param productionDays 生产天数
     * @param shippingDays 海运天数
     * @param safetyStockDays 安全库存天数
     * @param intervalDays 监控间隔天数
     * @param horizonDays 预测总天数
     * @param baseDate 基准日期
     * @param warehouseMapping 仓库映射表
     * @return 断货风险评估响应
     */
    public CosOosPointResponse evaluateWarehouseStockoutRisk(
            Long warehouseId,
            String skuCode,
            String mode,
            Integer currentInventory,
            BigDecimal dailyAvg,
            Integer productionDays,
            Integer shippingDays,
            Integer safetyStockDays,
            Integer intervalDays,
            Integer horizonDays,
            LocalDate baseDate,
            Map<Long, WarehouseMapping> warehouseMapping) {
        
        logger.info("Evaluating warehouse stockout risk - warehouse: {}, sku: {}, mode: {}", 
                   warehouseId, skuCode, mode);
        
        // 1. 获取当前库存（如果未提供）
        if (currentInventory == null) {
            currentInventory = warehouseInventoryService.getInventoryQuantity(
                    warehouseId, skuCode, mode, warehouseMapping);
            logger.debug("Retrieved current inventory from warehouse: {}", currentInventory);
        }
        
        // 2. 计算在途库存（按仓库维度聚合）
        Integer intransitQty = intransitInventoryService.getIntransitQuantity(
                warehouseId, skuCode, baseDate, warehouseMapping);
        logger.debug("Calculated in-transit quantity: {}", intransitQty);
        
        // 3. 构建发货单映射（从在途库存数据转换）
        Map<LocalDate, Integer> shipmentQtyMap = buildShipmentMapFromIntransit(
                warehouseId, skuCode, baseDate, warehouseMapping);
        
        // 4. 调用原有的断货点评估服务
        CosOosPointResponse response = stockoutPointService.evaluateWithWeeklyShipments(
                currentInventory,
                dailyAvg,
                shipmentQtyMap,
                productionDays,
                shippingDays,
                safetyStockDays,
                intervalDays,
                horizonDays,
                baseDate
        );
        
        // 5. 添加仓库维度信息
        response.setWarehouseId(warehouseId);
        response.setSkuCode(skuCode);
        response.setMode(mode);
        
        logger.info("Warehouse stockout risk evaluation completed - risk level: {}", 
                   response.getFirstRiskPoint() != null ? 
                   response.getFirstRiskPoint().getRiskLevel() : "NONE");
        
        return response;
    }
    
    /**
     * 批量评估多个仓库的断货风险
     * Batch evaluate stockout risk for multiple warehouses
     * 
     * @param warehouseIds 仓库ID列表
     * @param skuCode SKU编码
     * @param mode 模式
     * @param dailyAvg 日均销量
     * @param productionDays 生产天数
     * @param shippingDays 海运天数
     * @param safetyStockDays 安全库存天数
     * @param intervalDays 监控间隔天数
     * @param horizonDays 预测总天数
     * @param baseDate 基准日期
     * @param warehouseMapping 仓库映射表
     * @return 各仓库的断货风险评估结果
     */
    public Map<Long, CosOosPointResponse> evaluateMultiWarehouseStockoutRisk(
            List<Long> warehouseIds,
            String skuCode,
            String mode,
            BigDecimal dailyAvg,
            Integer productionDays,
            Integer shippingDays,
            Integer safetyStockDays,
            Integer intervalDays,
            Integer horizonDays,
            LocalDate baseDate,
            Map<Long, WarehouseMapping> warehouseMapping) {
        
        logger.info("Evaluating multi-warehouse stockout risk for {} warehouses", warehouseIds.size());
        
        Map<Long, CosOosPointResponse> results = new HashMap<>();
        
        for (Long warehouseId : warehouseIds) {
            try {
                CosOosPointResponse response = evaluateWarehouseStockoutRisk(
                        warehouseId,
                        skuCode,
                        mode,
                        null,  // 从数据库查询
                        dailyAvg,
                        productionDays,
                        shippingDays,
                        safetyStockDays,
                        intervalDays,
                        horizonDays,
                        baseDate,
                        warehouseMapping
                );
                results.put(warehouseId, response);
            } catch (Exception e) {
                logger.error("Failed to evaluate stockout risk for warehouse: {}", warehouseId, e);
                // 继续处理其他仓库
            }
        }
        
        logger.info("Multi-warehouse stockout risk evaluation completed: {}/{} succeeded", 
                   results.size(), warehouseIds.size());
        
        return results;
    }
    
    /**
     * 按模式评估所有仓库的断货风险
     * Evaluate stockout risk for all warehouses by mode
     * 
     * @param skuCode SKU编码
     * @param mode 模式：REGIONAL 或 FBA
     * @param dailyAvg 日均销量
     * @param productionDays 生产天数
     * @param shippingDays 海运天数
     * @param safetyStockDays 安全库存天数
     * @param baseDate 基准日期
     * @param warehouseMapping 仓库映射表
     * @return 存在风险的仓库列表及其风险评估
     */
    public Map<Long, CosOosPointResponse> evaluateByMode(
            String skuCode,
            String mode,
            BigDecimal dailyAvg,
            Integer productionDays,
            Integer shippingDays,
            Integer safetyStockDays,
            LocalDate baseDate,
            Map<Long, WarehouseMapping> warehouseMapping) {
        
        logger.info("Evaluating stockout risk by mode: {} for SKU: {}", mode, skuCode);
        
        // 获取指定模式的所有仓库
        List<Long> warehouseIds = warehouseMapping.values().stream()
                .filter(wm -> mode.equals(wm.getWarehouseType()))
                .map(WarehouseMapping::getWarehouseId)
                .distinct()
                .toList();
        
        logger.debug("Found {} warehouses for mode: {}", warehouseIds.size(), mode);
        
        // 评估所有仓库
        return evaluateMultiWarehouseStockoutRisk(
                warehouseIds,
                skuCode,
                mode,
                dailyAvg,
                productionDays,
                shippingDays,
                safetyStockDays,
                7,  // 默认监控间隔7天
                productionDays + shippingDays,  // 默认预测天数
                baseDate,
                warehouseMapping
        );
    }
    
    /**
     * 从在途库存数据构建发货单映射
     * Build shipment map from in-transit inventory data
     * 
     * 注意：这是一个简化实现，实际应用中需要从在途库存明细表获取更准确的发货日期和数量分布
     */
    private Map<LocalDate, Integer> buildShipmentMapFromIntransit(
            Long warehouseId,
            String skuCode,
            LocalDate monitorDate,
            Map<Long, WarehouseMapping> warehouseMapping) {
        
        Map<LocalDate, Integer> shipmentMap = new HashMap<>();
        
        // 获取在途库存聚合数据
        Map<String, IntransitInventory> allIntransit = 
                intransitInventoryService.aggregateAllIntransit(monitorDate, warehouseMapping);
        
        String key = warehouseId + ":" + skuCode;
        IntransitInventory intransit = allIntransit.get(key);
        
        if (intransit != null && intransit.getIntransitQuantity() != null && 
            intransit.getIntransitQuantity() > 0) {
            
            // 使用最早发货日期作为发货日期
            LocalDate shipmentDate = intransit.getEarliestShipmentDate();
            if (shipmentDate != null) {
                shipmentMap.put(shipmentDate, intransit.getIntransitQuantity());
            }
        }
        
        return shipmentMap;
    }
}
