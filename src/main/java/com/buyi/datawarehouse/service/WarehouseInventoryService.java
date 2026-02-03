package com.buyi.datawarehouse.service;

import com.buyi.datawarehouse.model.WarehouseMapping;
import com.buyi.datawarehouse.model.fact.FactInventory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 仓库库存聚合服务
 * Warehouse Inventory Aggregation Service
 * 
 * 按仓库维度聚合现有库存，支持区域仓模式和FBA模式
 * Aggregates current inventory by warehouse dimension, supporting REGIONAL and FBA modes
 */
public class WarehouseInventoryService {
    
    private static final Logger logger = LoggerFactory.getLogger(WarehouseInventoryService.class);
    
    /**
     * 聚合JH海外仓库存
     * Aggregate JH overseas warehouse inventory
     * 
     * 数据源：amf_jh_warehouse_stock
     * 聚合维度：(warehouse_id, sku_code)
     * 
     * @param warehouseMapping 仓库映射表
     * @return 按仓库和SKU聚合的库存列表
     */
    public List<FactInventory> aggregateJHWarehouseStock(Map<Long, WarehouseMapping> warehouseMapping) {
        logger.info("Aggregating JH warehouse stock");
        
        List<FactInventory> inventoryList = new ArrayList<>();
        
        /*
         * SQL逻辑示例：
         * 
         * SELECT 
         *   wm.warehouse_id,
         *   wm.warehouse_code,
         *   wm.warehouse_name,
         *   'REGIONAL' as mode,
         *   jws.warehouse_sku as sku_code,
         *   SUM(jws.out_available_qty) as available_quantity,
         *   SUM(jws.out_available_qty) as on_hand_quantity
         * FROM amf_jh_warehouse_stock jws
         * INNER JOIN dw_warehouse_mapping wm 
         *   ON wm.source_system = 'JH' 
         *   AND wm.source_warehouse_name = jws.warehouse_name
         * WHERE jws.out_available_qty > 0
         * GROUP BY wm.warehouse_id, wm.warehouse_code, wm.warehouse_name, jws.warehouse_sku
         */
        
        return inventoryList;
    }
    
    /**
     * 聚合LX海外仓库存
     * Aggregate LX overseas warehouse inventory
     * 
     * 数据源：amf_lx_warehouse_stock
     * 聚合维度：(warehouse_id, sku_code)
     * 
     * @param warehouseMapping 仓库映射表
     * @return 按仓库和SKU聚合的库存列表
     */
    public List<FactInventory> aggregateLXWarehouseStock(Map<Long, WarehouseMapping> warehouseMapping) {
        logger.info("Aggregating LX warehouse stock");
        
        List<FactInventory> inventoryList = new ArrayList<>();
        
        /*
         * SQL逻辑示例：
         * 
         * SELECT 
         *   wm.warehouse_id,
         *   wm.warehouse_code,
         *   wm.warehouse_name,
         *   'REGIONAL' as mode,
         *   lws.sku as sku_code,
         *   SUM(lws.product_valid_num) as available_quantity,
         *   SUM(lws.product_valid_num) as on_hand_quantity
         * FROM amf_lx_warehouse_stock lws
         * INNER JOIN dw_warehouse_mapping wm 
         *   ON wm.source_system = 'LX' 
         *   AND wm.warehouse_type = 'REGIONAL'
         *   AND wm.source_warehouse_id = lws.wid
         * WHERE lws.product_valid_num > 0
         * GROUP BY wm.warehouse_id, wm.warehouse_code, wm.warehouse_name, lws.sku
         */
        
        return inventoryList;
    }
    
    /**
     * 聚合FBA平台库存
     * Aggregate FBA platform inventory
     * 
     * 数据源：amf_lx_fbadetail
     * 聚合维度：(warehouse_id, sku_code)
     * 
     * @param warehouseMapping 仓库映射表
     * @return 按仓库和SKU聚合的库存列表
     */
    public List<FactInventory> aggregateFBAStock(Map<Long, WarehouseMapping> warehouseMapping) {
        logger.info("Aggregating FBA stock");
        
        List<FactInventory> inventoryList = new ArrayList<>();
        
        /*
         * SQL逻辑示例：
         * 
         * SELECT 
         *   wm.warehouse_id,
         *   wm.warehouse_code,
         *   wm.warehouse_name,
         *   'FBA' as mode,
         *   fba.seller_sku as sku_code,
         *   SUM(fba.available_total) as available_quantity,
         *   SUM(fba.available_total) as on_hand_quantity
         * FROM amf_lx_fbadetail fba
         * INNER JOIN dw_warehouse_mapping wm 
         *   ON wm.warehouse_type = 'FBA'
         * WHERE fba.available_total > 0
         * GROUP BY wm.warehouse_id, wm.warehouse_code, wm.warehouse_name, fba.seller_sku
         */
        
        return inventoryList;
    }
    
    /**
     * 聚合区域仓模式的库存（JH + LX）
     * Aggregate REGIONAL mode inventory (JH + LX)
     * 
     * @param warehouseMapping 仓库映射表
     * @return 区域仓库存列表
     */
    public List<FactInventory> aggregateRegionalInventory(Map<Long, WarehouseMapping> warehouseMapping) {
        logger.info("Aggregating REGIONAL mode inventory");
        
        // 聚合JH和LX的库存
        List<FactInventory> jhInventory = aggregateJHWarehouseStock(warehouseMapping);
        List<FactInventory> lxInventory = aggregateLXWarehouseStock(warehouseMapping);
        
        // 合并结果
        Map<String, FactInventory> aggregationMap = new HashMap<>();
        
        mergeInventoryList(aggregationMap, jhInventory);
        mergeInventoryList(aggregationMap, lxInventory);
        
        logger.info("Total REGIONAL inventory items: {}", aggregationMap.size());
        
        return new ArrayList<>(aggregationMap.values());
    }
    
    /**
     * 按模式聚合所有库存
     * Aggregate all inventory by mode
     * 
     * @param mode 模式：REGIONAL 或 FBA
     * @param warehouseMapping 仓库映射表
     * @return 指定模式的库存列表
     */
    public List<FactInventory> aggregateInventoryByMode(String mode, 
                                                        Map<Long, WarehouseMapping> warehouseMapping) {
        logger.info("Aggregating inventory for mode: {}", mode);
        
        if ("REGIONAL".equals(mode)) {
            return aggregateRegionalInventory(warehouseMapping);
        } else if ("FBA".equals(mode)) {
            return aggregateFBAStock(warehouseMapping);
        } else {
            logger.warn("Unknown mode: {}, returning empty list", mode);
            return new ArrayList<>();
        }
    }
    
    /**
     * 获取指定仓库和SKU的库存数量
     * Get inventory quantity for specific warehouse and SKU
     * 
     * @param warehouseId 仓库ID
     * @param skuCode SKU编码
     * @param mode 模式
     * @param warehouseMapping 仓库映射表
     * @return 库存数量
     */
    public Integer getInventoryQuantity(Long warehouseId, String skuCode, String mode,
                                        Map<Long, WarehouseMapping> warehouseMapping) {
        List<FactInventory> inventoryList = aggregateInventoryByMode(mode, warehouseMapping);
        
        return inventoryList.stream()
                .filter(inv -> warehouseId.equals(inv.getWarehouseKey()))
                .filter(inv -> skuCode.equals(inv.getProductKey()))  // Note: 需要通过product_key关联SKU
                .mapToInt(inv -> inv.getAvailableQuantity() != null ? inv.getAvailableQuantity() : 0)
                .sum();
    }
    
    /**
     * 按仓库聚合库存汇总
     * Aggregate inventory summary by warehouse
     * 
     * @param mode 模式
     * @param warehouseMapping 仓库映射表
     * @return 仓库库存汇总Map (warehouse_id -> total_quantity)
     */
    public Map<Long, Integer> getInventorySummaryByWarehouse(String mode,
                                                             Map<Long, WarehouseMapping> warehouseMapping) {
        List<FactInventory> inventoryList = aggregateInventoryByMode(mode, warehouseMapping);
        
        return inventoryList.stream()
                .collect(Collectors.groupingBy(
                        FactInventory::getWarehouseKey,
                        Collectors.summingInt(inv -> inv.getAvailableQuantity() != null ? 
                                inv.getAvailableQuantity() : 0)
                ));
    }
    
    /**
     * 合并库存列表到聚合Map
     */
    private void mergeInventoryList(Map<String, FactInventory> targetMap, 
                                    List<FactInventory> sourceList) {
        for (FactInventory item : sourceList) {
            String key = generateKey(item.getWarehouseKey(), item.getProductKey());
            
            FactInventory existing = targetMap.get(key);
            if (existing == null) {
                targetMap.put(key, item);
            } else {
                // 合并数量
                int onHandQty = (existing.getOnHandQuantity() != null ? existing.getOnHandQuantity() : 0) +
                               (item.getOnHandQuantity() != null ? item.getOnHandQuantity() : 0);
                existing.setOnHandQuantity(onHandQty);
                
                int availableQty = (existing.getAvailableQuantity() != null ? existing.getAvailableQuantity() : 0) +
                                  (item.getAvailableQuantity() != null ? item.getAvailableQuantity() : 0);
                existing.setAvailableQuantity(availableQty);
                
                // 更新最后出库日期（取最新的）
                if (item.getLastOutboundDate() != null) {
                    if (existing.getLastOutboundDate() == null || 
                        item.getLastOutboundDate().isAfter(existing.getLastOutboundDate())) {
                        existing.setLastOutboundDate(item.getLastOutboundDate());
                    }
                }
            }
        }
    }
    
    /**
     * 生成聚合键
     */
    private String generateKey(Long warehouseKey, Long productKey) {
        return warehouseKey + ":" + (productKey != null ? productKey : "");
    }
}
