package com.buyi.datawarehouse.service.monitoring;

import com.buyi.datawarehouse.enums.BusinessMode;
import com.buyi.datawarehouse.model.monitoring.InTransitInventoryAgg;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 在途库存聚合服务
 * In-Transit Inventory Aggregation Service
 * 
 * 负责从JH、LX、FBA发货单统计在途库存
 * 按照(产品SKU/产品, 仓库, 模式)维度聚合
 */
public class InTransitInventoryService {
    private static final Logger logger = LoggerFactory.getLogger(InTransitInventoryService.class);
    
    /**
     * 聚合在途库存
     * 
     * SQL逻辑示例:
     * SELECT 
     *   product_id,
     *   product_sku,
     *   warehouse_id,
     *   warehouse_code,
     *   business_mode,
     *   SUM(quantity - COALESCE(received_quantity, 0)) as in_transit_quantity
     * FROM shipment_order
     * WHERE status IN ('SHIPPED', 'IN_TRANSIT')
     *   AND ship_date <= ?
     * GROUP BY product_id, product_sku, warehouse_id, warehouse_code, business_mode
     * 
     * @param asOfDate 截止日期
     * @return 在途库存聚合结果列表
     */
    public List<InTransitInventoryAgg> aggregateInTransitInventory(LocalDate asOfDate) {
        logger.info("开始聚合在途库存，截止日期: {}", asOfDate);
        
        // TODO: 实际实现中需要从数据库查询发货单数据
        // 这里提供逻辑框架和示例
        
        List<InTransitInventoryAgg> results = new ArrayList<>();
        
        // 示例：查询所有在途的发货单
        // SELECT * FROM shipment_order 
        // WHERE status IN ('SHIPPED', 'IN_TRANSIT')
        //   AND ship_date <= ?
        //   AND (actual_arrival_date IS NULL OR actual_arrival_date > ?)
        
        // 按照 (product_sku, warehouse_code, business_mode) 分组聚合
        // Map<String, InTransitInventoryAgg> aggregationMap = new HashMap<>();
        
        logger.info("在途库存聚合完成，共{}条记录", results.size());
        return results;
    }
    
    /**
     * 按区域仓聚合在途库存
     * 通过区域仓-仓库绑定关系，将仓库维度的在途库存聚合到区域仓维度
     * 
     * @param warehouseInventories 仓库维度的在途库存列表
     * @param regionalWarehouseBindings 区域仓-仓库绑定关系 Map<仓库ID, 区域仓ID>
     * @return 区域仓维度的在途库存聚合结果
     */
    public Map<String, InTransitInventoryAgg> aggregateByRegionalWarehouse(
            List<InTransitInventoryAgg> warehouseInventories,
            Map<Long, Long> regionalWarehouseBindings) {
        
        logger.info("开始按区域仓聚合在途库存，仓库库存数: {}", warehouseInventories.size());
        
        Map<String, InTransitInventoryAgg> regionalAggMap = new HashMap<>();
        
        for (InTransitInventoryAgg warehouseInv : warehouseInventories) {
            Long regionalWarehouseId = regionalWarehouseBindings.get(warehouseInv.getWarehouseId());
            if (regionalWarehouseId == null) {
                logger.warn("仓库{}未绑定区域仓", warehouseInv.getWarehouseCode());
                continue;
            }
            
            // 按照 (product_sku, regional_warehouse_id, business_mode) 分组聚合
            String key = buildKey(warehouseInv.getProductSku(), regionalWarehouseId, 
                    warehouseInv.getBusinessMode());
            
            InTransitInventoryAgg regionalInv = regionalAggMap.get(key);
            if (regionalInv == null) {
                regionalInv = new InTransitInventoryAgg();
                regionalInv.setProductId(warehouseInv.getProductId());
                regionalInv.setProductSku(warehouseInv.getProductSku());
                regionalInv.setWarehouseId(regionalWarehouseId);
                regionalInv.setBusinessMode(warehouseInv.getBusinessMode());
                regionalInv.setInTransitQuantity(0);
                regionalAggMap.put(key, regionalInv);
            }
            
            // 累加在途数量
            regionalInv.setInTransitQuantity(
                    regionalInv.getInTransitQuantity() + warehouseInv.getInTransitQuantity());
        }
        
        logger.info("区域仓聚合完成，共{}条记录", regionalAggMap.size());
        return regionalAggMap;
    }
    
    /**
     * 按业务模式合并在途库存
     * JH和LX合并为JH_LX，FBA保持独立
     * 
     * @param inventories 原始在途库存列表
     * @return 按合并模式分组的在途库存
     */
    public Map<String, InTransitInventoryAgg> mergeByBusinessMode(
            List<InTransitInventoryAgg> inventories) {
        
        logger.info("开始按业务模式合并在途库存");
        
        Map<String, InTransitInventoryAgg> mergedMap = new HashMap<>();
        
        for (InTransitInventoryAgg inv : inventories) {
            BusinessMode mergedMode = inv.getBusinessMode().toMergedMode();
            
            String key = buildKey(inv.getProductSku(), inv.getWarehouseId(), mergedMode);
            
            InTransitInventoryAgg merged = mergedMap.get(key);
            if (merged == null) {
                merged = new InTransitInventoryAgg();
                merged.setProductId(inv.getProductId());
                merged.setProductSku(inv.getProductSku());
                merged.setWarehouseId(inv.getWarehouseId());
                merged.setWarehouseCode(inv.getWarehouseCode());
                merged.setBusinessMode(mergedMode);
                merged.setInTransitQuantity(0);
                mergedMap.put(key, merged);
            }
            
            merged.setInTransitQuantity(
                    merged.getInTransitQuantity() + inv.getInTransitQuantity());
        }
        
        logger.info("业务模式合并完成，JH+LX合并统计");
        return mergedMap;
    }
    
    /**
     * 构建聚合键
     */
    private String buildKey(String productSku, Long warehouseId, BusinessMode mode) {
        return productSku + "|" + warehouseId + "|" + mode.getCode();
    }
    
    /**
     * 查询指定产品的在途库存
     * 
     * @param productSku 产品SKU
     * @param regionalWarehouseId 区域仓ID
     * @param businessMode 业务模式
     * @param asOfDate 截止日期
     * @return 在途库存数量
     */
    public Integer queryInTransitInventory(String productSku, Long regionalWarehouseId,
                                           BusinessMode businessMode, LocalDate asOfDate) {
        // TODO: 实际实现中从数据库查询
        return 0;
    }
}
