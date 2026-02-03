package com.buyi.datawarehouse.service;

import com.buyi.datawarehouse.model.IntransitInventory;
import com.buyi.datawarehouse.model.WarehouseMapping;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 在途库存计算服务
 * In-transit Inventory Calculation Service
 * 
 * 按仓库维度聚合各来源发货单的在途库存
 * Aggregates in-transit inventory from various shipment sources by warehouse dimension
 */
public class IntransitInventoryService {
    
    private static final Logger logger = LoggerFactory.getLogger(IntransitInventoryService.class);
    
    /**
     * 计算JH发货单的在途库存
     * Calculate in-transit inventory from JH shipments
     * 
     * 口径：
     * - 以amf_jh_shipment.warehouse_id为目的仓库
     * - 按shipment_date <= monitor_date
     * - status != 2（2为已完成）
     * - 计算 open_intransit_qty = SUM(ship_qty - receive_qty)
     * - warehouse_sku映射到SKU编码
     * 
     * @param monitorDate 监控日期
     * @param warehouseMapping 仓库映射表
     * @return 按(warehouse_id, sku_code)聚合的在途库存列表
     */
    public List<IntransitInventory> calculateJHIntransit(LocalDate monitorDate, 
                                                         Map<Long, WarehouseMapping> warehouseMapping) {
        logger.info("Calculating JH in-transit inventory for monitor date: {}", monitorDate);
        
        // 聚合结果 key: warehouse_id + sku_code
        Map<String, IntransitInventory> aggregationMap = new HashMap<>();
        
        /*
         * SQL逻辑示例（实际应用中需要从数据库查询）:
         * 
         * SELECT 
         *   s.warehouse_id,
         *   s.warehouse_name,
         *   sku.warehouse_sku as sku_code,
         *   SUM(sku.ship_qty - IFNULL(sku.receive_qty, 0)) as intransit_qty,
         *   COUNT(DISTINCT s.id) as shipment_count,
         *   MIN(s.shipment_date) as earliest_shipment_date
         * FROM amf_jh_shipment s
         * INNER JOIN amf_jh_shipment_sku sku ON s.id = sku.property_shipment_id
         * WHERE s.shipment_date <= ?
         *   AND s.status != 2
         *   AND (sku.ship_qty - IFNULL(sku.receive_qty, 0)) > 0
         * GROUP BY s.warehouse_id, s.warehouse_name, sku.warehouse_sku
         */
        
        // 实际实现需要查询数据库并填充结果
        // 这里提供框架代码供后续集成
        
        return new ArrayList<>(aggregationMap.values());
    }
    
    /**
     * 计算LX OWMS海外仓发货单的在途库存
     * Calculate in-transit inventory from LX OWMS shipments
     * 
     * 口径：
     * - 以r_wid为目的仓库（收货仓库）
     * - 按send_good_handle_time <= monitor_date
     * - status = 50（待收货）
     * - 计算 open_intransit_qty = SUM(stock_num - receive_num)
     * - 使用products.sku作为SKU编码
     * 
     * @param monitorDate 监控日期
     * @param warehouseMapping 仓库映射表
     * @return 按(warehouse_id, sku_code)聚合的在途库存列表
     */
    public List<IntransitInventory> calculateLXOWMSIntransit(LocalDate monitorDate,
                                                              Map<Long, WarehouseMapping> warehouseMapping) {
        logger.info("Calculating LX OWMS in-transit inventory for monitor date: {}", monitorDate);
        
        Map<String, IntransitInventory> aggregationMap = new HashMap<>();
        
        /*
         * SQL逻辑示例（实际应用中需要从数据库查询）:
         * 
         * SELECT 
         *   s.r_wid as source_warehouse_id,
         *   s.r_wname as warehouse_name,
         *   p.sku as sku_code,
         *   SUM(p.stock_num - IFNULL(p.receive_num, 0)) as intransit_qty,
         *   COUNT(DISTINCT s.id) as shipment_count,
         *   MIN(FROM_UNIXTIME(s.real_delivery_time)) as earliest_shipment_date,
         *   MAX(s.estimated_time) as latest_expected_arrival_date
         * FROM amf_lx_shipment s
         * INNER JOIN amf_lx_shipment_products p ON s.id = p.shipment_id
         * WHERE FROM_UNIXTIME(s.real_delivery_time) <= ?
         *   AND s.status = 50
         *   AND (p.stock_num - IFNULL(p.receive_num, 0)) > 0
         * GROUP BY s.r_wid, s.r_wname, p.sku
         */
        
        return new ArrayList<>(aggregationMap.values());
    }
    
    /**
     * 计算FBA发货单的在途库存
     * Calculate in-transit inventory from FBA shipments
     * 
     * 口径：
     * - 使用amf_lx_fbashipment_item
     * - 按shipment_time <= monitor_date
     * - shipment_status = 'WORKING'（未完成）
     * - 计算 open_intransit_qty = SUM(num)
     * - 使用wid或destination_fulfillment_center_id映射到逻辑仓
     * 
     * @param monitorDate 监控日期
     * @param warehouseMapping 仓库映射表
     * @return 按(warehouse_id, sku_code)聚合的在途库存列表
     */
    public List<IntransitInventory> calculateFBAIntransit(LocalDate monitorDate,
                                                           Map<Long, WarehouseMapping> warehouseMapping) {
        logger.info("Calculating FBA in-transit inventory for monitor date: {}", monitorDate);
        
        Map<String, IntransitInventory> aggregationMap = new HashMap<>();
        
        /*
         * SQL逻辑示例（实际应用中需要从数据库查询）:
         * 
         * SELECT 
         *   item.wid as source_warehouse_id,
         *   item.destination_fulfillment_center_id,
         *   item.sku as sku_code,
         *   SUM(item.num) as intransit_qty,
         *   COUNT(DISTINCT s.id) as shipment_count,
         *   MIN(s.shipment_time) as earliest_shipment_date,
         *   MAX(s.expected_arrival_date) as latest_expected_arrival_date
         * FROM amf_lx_fbashipment s
         * INNER JOIN amf_lx_fbashipment_item item ON s.id = item.shipment_id
         * WHERE s.shipment_time <= ?
         *   AND item.shipment_status = 'WORKING'
         *   AND s.is_delete = 0
         *   AND item.num > 0
         * GROUP BY item.wid, item.destination_fulfillment_center_id, item.sku
         */
        
        return new ArrayList<>(aggregationMap.values());
    }
    
    /**
     * 聚合所有来源的在途库存
     * Aggregate in-transit inventory from all sources
     * 
     * @param monitorDate 监控日期
     * @param warehouseMapping 仓库映射表
     * @return 按(warehouse_id, sku_code)聚合的总在途库存
     */
    public Map<String, IntransitInventory> aggregateAllIntransit(LocalDate monitorDate,
                                                                  Map<Long, WarehouseMapping> warehouseMapping) {
        logger.info("Aggregating all in-transit inventory for monitor date: {}", monitorDate);
        
        Map<String, IntransitInventory> totalAggregation = new HashMap<>();
        
        // 计算各来源在途库存
        List<IntransitInventory> jhIntransit = calculateJHIntransit(monitorDate, warehouseMapping);
        List<IntransitInventory> lxIntransit = calculateLXOWMSIntransit(monitorDate, warehouseMapping);
        List<IntransitInventory> fbaIntransit = calculateFBAIntransit(monitorDate, warehouseMapping);
        
        // 合并所有结果
        mergeIntransitResults(totalAggregation, jhIntransit);
        mergeIntransitResults(totalAggregation, lxIntransit);
        mergeIntransitResults(totalAggregation, fbaIntransit);
        
        logger.info("Total aggregated in-transit items: {}", totalAggregation.size());
        
        return totalAggregation;
    }
    
    /**
     * 按仓库和SKU聚合在途库存
     * Aggregate in-transit inventory by warehouse and SKU
     * 
     * @param warehouseId 仓库ID
     * @param skuCode SKU编码
     * @param monitorDate 监控日期
     * @param warehouseMapping 仓库映射表
     * @return 指定仓库和SKU的在途库存数量
     */
    public Integer getIntransitQuantity(Long warehouseId, String skuCode, 
                                        LocalDate monitorDate,
                                        Map<Long, WarehouseMapping> warehouseMapping) {
        Map<String, IntransitInventory> allIntransit = aggregateAllIntransit(monitorDate, warehouseMapping);
        String key = generateKey(warehouseId, skuCode);
        
        IntransitInventory result = allIntransit.get(key);
        return result != null ? result.getIntransitQuantity() : 0;
    }
    
    /**
     * 按模式（区域仓/FBA）聚合在途库存
     * Aggregate in-transit inventory by mode (REGIONAL/FBA)
     * 
     * @param mode 模式：REGIONAL 或 FBA
     * @param monitorDate 监控日期
     * @param warehouseMapping 仓库映射表
     * @return 指定模式的在途库存列表
     */
    public List<IntransitInventory> getIntransitByMode(String mode, 
                                                       LocalDate monitorDate,
                                                       Map<Long, WarehouseMapping> warehouseMapping) {
        Map<String, IntransitInventory> allIntransit = aggregateAllIntransit(monitorDate, warehouseMapping);
        
        return allIntransit.values().stream()
                .filter(inv -> mode.equals(inv.getMode()))
                .collect(Collectors.toList());
    }
    
    /**
     * 合并在途库存结果
     */
    private void mergeIntransitResults(Map<String, IntransitInventory> targetMap, 
                                       List<IntransitInventory> sourceList) {
        for (IntransitInventory item : sourceList) {
            String key = generateKey(item.getWarehouseId(), item.getSkuCode());
            
            IntransitInventory existing = targetMap.get(key);
            if (existing == null) {
                targetMap.put(key, item);
            } else {
                // 合并数量和其他信息
                existing.addIntransitQuantity(item.getIntransitQuantity());
                existing.setShipmentCount(existing.getShipmentCount() + item.getShipmentCount());
                existing.updateEarliestShipmentDate(item.getEarliestShipmentDate());
                existing.updateLatestExpectedArrivalDate(item.getLatestExpectedArrivalDate());
                
                // 来源标记为多来源
                if (!existing.getSource().contains(item.getSource())) {
                    existing.setSource(existing.getSource() + "," + item.getSource());
                }
            }
        }
    }
    
    /**
     * 生成聚合键
     */
    private String generateKey(Long warehouseId, String skuCode) {
        return warehouseId + ":" + (skuCode != null ? skuCode : "");
    }
}
