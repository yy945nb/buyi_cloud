package com.buyi.datawarehouse.service.monitoring;

import com.buyi.datawarehouse.model.monitoring.DomesticInventoryAgg;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 国内仓库存服务
 * Domestic Inventory Service
 * 
 * 负责：
 * 1. 从 amf_jh_company_stock 查询国内仓库存数据
 * 2. 按 monitor_date 取 <= monitor_date 的最近一次 sync_date
 * 3. 按 local_sku 聚合得到 remaining_qty 和 actual_stock_qty
 * 4. 映射到产品SKU
 * 5. 在 JH_LX 和 FBA 两种模式下共享使用
 */
public class DomesticInventoryService {
    private static final Logger logger = LoggerFactory.getLogger(DomesticInventoryService.class);
    
    /**
     * 查询国内仓库存数据（按产品SKU聚合）
     * 
     * @param monitorDate 监控日期
     * @param companyId 公司ID（可选，为null时查询所有公司）
     * @return 产品SKU -> 库存聚合数据的映射
     */
    public Map<String, DomesticInventoryAgg> queryDomesticInventory(LocalDate monitorDate, Long companyId) {
        logger.info("查询国内仓库存数据，监控日期={}, 公司ID={}", monitorDate, companyId);
        
        Map<String, DomesticInventoryAgg> inventoryMap = new HashMap<>();
        
        try {
            // TODO: 实际实现需要从数据库查询
            /*
             * SQL查询逻辑：
             * 
             * WITH latest_sync AS (
             *     SELECT 
             *         local_sku,
             *         company_id,
             *         MAX(sync_date) as latest_sync_date
             *     FROM amf_jh_company_stock
             *     WHERE sync_date <= ?  -- monitor_date
             *       AND (? IS NULL OR company_id = ?)  -- company_id filter
             *     GROUP BY local_sku, company_id
             * )
             * SELECT 
             *     s.local_sku,
             *     s.company_id,
             *     SUM(s.remaining_num) as remaining_qty,
             *     SUM(s.stock_num) as actual_stock_qty,
             *     ls.latest_sync_date as sync_date,
             *     -- TODO: 需要映射表将 local_sku 映射到 product_sku
             *     m.product_sku
             * FROM amf_jh_company_stock s
             * INNER JOIN latest_sync ls 
             *     ON s.local_sku = ls.local_sku 
             *     AND s.company_id = ls.company_id
             *     AND s.sync_date = ls.latest_sync_date
             * LEFT JOIN sku_mapping m ON s.local_sku = m.local_sku
             * GROUP BY s.local_sku, s.company_id, ls.latest_sync_date, m.product_sku
             */
            
            // 模拟返回示例数据
            List<Map<String, Object>> queryResults = queryFromDatabase(monitorDate, companyId);
            
            for (Map<String, Object> row : queryResults) {
                DomesticInventoryAgg agg = new DomesticInventoryAgg();
                agg.setProductSku((String) row.get("product_sku"));
                agg.setLocalSku((String) row.get("local_sku"));
                agg.setCompanyId((Long) row.get("company_id"));
                agg.setRemainingQty((Integer) row.get("remaining_qty"));
                agg.setActualStockQty((Integer) row.get("actual_stock_qty"));
                agg.setSyncDate((LocalDate) row.get("sync_date"));
                agg.setMonitorDate(monitorDate);
                
                String productSku = agg.getProductSku();
                if (productSku != null) {
                    // 如果同一个 product_sku 有多个 local_sku，需要合并
                    if (inventoryMap.containsKey(productSku)) {
                        DomesticInventoryAgg existing = inventoryMap.get(productSku);
                        existing.setRemainingQty(
                            existing.getRemainingQty() + agg.getRemainingQty()
                        );
                        existing.setActualStockQty(
                            existing.getActualStockQty() + agg.getActualStockQty()
                        );
                    } else {
                        inventoryMap.put(productSku, agg);
                    }
                }
            }
            
            logger.info("查询到{}个产品SKU的国内仓库存数据", inventoryMap.size());
            
        } catch (Exception e) {
            logger.error("查询国内仓库存数据失败", e);
        }
        
        return inventoryMap;
    }
    
    /**
     * 查询单个产品SKU的国内仓库存
     * 
     * @param productSku 产品SKU
     * @param monitorDate 监控日期
     * @param companyId 公司ID（可选）
     * @return 库存聚合数据，如果不存在则返回零值对象
     */
    public DomesticInventoryAgg queryDomesticInventoryBySku(
            String productSku, LocalDate monitorDate, Long companyId) {
        
        logger.debug("查询单个产品SKU的国内仓库存，SKU={}, 监控日期={}, 公司ID={}", 
                productSku, monitorDate, companyId);
        
        Map<String, DomesticInventoryAgg> inventoryMap = queryDomesticInventory(monitorDate, companyId);
        
        DomesticInventoryAgg result = inventoryMap.get(productSku);
        if (result == null) {
            // 返回零值对象
            result = new DomesticInventoryAgg();
            result.setProductSku(productSku);
            result.setMonitorDate(monitorDate);
            result.setCompanyId(companyId);
            result.setRemainingQty(0);
            result.setActualStockQty(0);
        }
        
        return result;
    }
    
    /**
     * 从数据库查询
     * TODO: 实际实现需要使用JDBC或ORM框架
     */
    private List<Map<String, Object>> queryFromDatabase(LocalDate monitorDate, Long companyId) {
        // 这里返回空列表，实际实现需要连接数据库查询
        List<Map<String, Object>> results = new ArrayList<>();
        
        // 示例数据结构：
        // {
        //   "product_sku": "TEST-SKU-001",
        //   "local_sku": "LOCAL-SKU-001",
        //   "company_id": 1L,
        //   "remaining_qty": 1000,
        //   "actual_stock_qty": 800,
        //   "sync_date": LocalDate.of(2024, 1, 14)
        // }
        
        return results;
    }
    
    /**
     * 验证国内仓库存数据的完整性
     */
    public boolean validateDomesticInventory(DomesticInventoryAgg inventory) {
        if (inventory == null) {
            return false;
        }
        
        if (inventory.getProductSku() == null || inventory.getProductSku().isEmpty()) {
            logger.warn("国内仓库存数据缺少产品SKU");
            return false;
        }
        
        if (inventory.getRemainingQty() < 0 || inventory.getActualStockQty() < 0) {
            logger.warn("国内仓库存数据存在负数，SKU={}", inventory.getProductSku());
            return false;
        }
        
        return true;
    }
}
