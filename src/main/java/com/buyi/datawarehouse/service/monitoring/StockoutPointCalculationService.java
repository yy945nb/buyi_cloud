package com.buyi.datawarehouse.service.monitoring;

import com.buyi.datawarehouse.enums.BusinessMode;
import com.buyi.datawarehouse.model.monitoring.InTransitInventoryAgg;
import com.buyi.datawarehouse.model.monitoring.OverseasInventoryAgg;
import com.buyi.datawarehouse.model.monitoring.ProductStockoutMonitoring;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

/**
 * 断货点计算服务
 * Stockout Point Calculation Service
 * 
 * 核心计算逻辑：
 * 1. 汇总在途库存和海外仓库存
 * 2. 计算区域销量占比和日均销量
 * 3. 计算断货点、可售天数、风险等级
 */
public class StockoutPointCalculationService {
    private static final Logger logger = LoggerFactory.getLogger(StockoutPointCalculationService.class);
    
    private final InTransitInventoryService inTransitInventoryService;
    private final OverseasInventoryService overseasInventoryService;
    
    public StockoutPointCalculationService() {
        this.inTransitInventoryService = new InTransitInventoryService();
        this.overseasInventoryService = new OverseasInventoryService();
    }
    
    public StockoutPointCalculationService(InTransitInventoryService inTransitInventoryService,
                                           OverseasInventoryService overseasInventoryService) {
        this.inTransitInventoryService = inTransitInventoryService;
        this.overseasInventoryService = overseasInventoryService;
    }
    
    /**
     * 计算产品断货点监控指标
     * 
     * @param productSku 产品SKU
     * @param productId 产品ID
     * @param productName 产品名称
     * @param regionalWarehouseId 区域仓ID
     * @param regionalWarehouseCode 区域仓编码
     * @param businessMode 业务模式
     * @param snapshotDate 快照日期
     * @return 断货点监控数据
     */
    public ProductStockoutMonitoring calculateStockoutPoint(
            String productSku,
            Long productId,
            String productName,
            Long regionalWarehouseId,
            String regionalWarehouseCode,
            BusinessMode businessMode,
            LocalDate snapshotDate) {
        
        logger.info("计算产品断货点: SKU={}, 区域仓={}, 模式={}, 日期={}",
                productSku, regionalWarehouseCode, businessMode, snapshotDate);
        
        ProductStockoutMonitoring monitoring = new ProductStockoutMonitoring();
        monitoring.setProductId(productId);
        monitoring.setProductSku(productSku);
        monitoring.setProductName(productName);
        monitoring.setRegionalWarehouseId(regionalWarehouseId);
        monitoring.setRegionalWarehouseCode(regionalWarehouseCode);
        monitoring.setBusinessMode(businessMode);
        monitoring.setSnapshotDate(snapshotDate);
        
        // 1. 查询在途库存
        Integer inTransit = inTransitInventoryService.queryInTransitInventory(
                productSku, regionalWarehouseId, businessMode, snapshotDate);
        monitoring.setInTransitInventory(inTransit);
        
        // 2. 查询海外仓库存
        OverseasInventoryAgg overseasInv = overseasInventoryService.queryOverseasInventory(
                productSku, regionalWarehouseId, businessMode, snapshotDate);
        monitoring.setOverseasInventory(overseasInv.getOnHandQuantity());
        monitoring.setAvailableInventory(overseasInv.getAvailableQuantity());
        
        // 3. 计算总库存
        monitoring.calculateTotalInventory();
        
        // 4. 查询并计算销量数据
        calculateSalesMetrics(monitoring, snapshotDate);
        
        // 5. 设置周期参数
        setTimeParameters(monitoring, regionalWarehouseCode);
        
        // 6. 计算断货点和风险指标
        monitoring.calculateStockoutMetrics();
        
        logger.info("断货点计算完成: 总库存={}, 日均销量={}, 可售天数={}, 风险等级={}",
                monitoring.getTotalInventory(), monitoring.getRegionalDailySales(),
                monitoring.getAvailableDays(), monitoring.getRiskLevel());
        
        return monitoring;
    }
    
    /**
     * 计算销量指标
     * 
     * @param monitoring 监控数据对象
     * @param snapshotDate 快照日期
     */
    private void calculateSalesMetrics(ProductStockoutMonitoring monitoring, LocalDate snapshotDate) {
        String productSku = monitoring.getProductSku();
        Long regionalWarehouseId = monitoring.getRegionalWarehouseId();
        
        // TODO: 从数据库查询销量数据
        // 1. 查询产品整体销量（7天、30天）
        // SELECT SUM(quantity) FROM daily_sales_detail 
        // WHERE product_sku = ? AND sales_date BETWEEN ? AND ?
        
        // 示例数据
        int sales7Days = 0;  // TODO: 从数据库查询
        int sales30Days = 0; // TODO: 从数据库查询
        
        BigDecimal dailyAvg7Days = BigDecimal.valueOf(sales7Days).divide(
                BigDecimal.valueOf(7), 4, BigDecimal.ROUND_HALF_UP);
        BigDecimal dailyAvg30Days = BigDecimal.valueOf(sales30Days).divide(
                BigDecimal.valueOf(30), 4, BigDecimal.ROUND_HALF_UP);
        
        monitoring.setDailyAvgSales7Days(dailyAvg7Days);
        monitoring.setDailyAvgSales30Days(dailyAvg30Days);
        
        // 2. 计算加权日均销量 (7天50% + 30天50%)
        BigDecimal weightedAvg = dailyAvg7Days.multiply(BigDecimal.valueOf(0.5))
                .add(dailyAvg30Days.multiply(BigDecimal.valueOf(0.5)));
        monitoring.setDailyAvgSales(weightedAvg);
        
        // 3. 查询区域销量占比
        // SELECT weighted_proportion FROM order_regional_proportion
        // WHERE product_sku = ? AND regional_warehouse_id = ? 
        //   AND calculation_date = ?
        
        BigDecimal regionalProportion = BigDecimal.ZERO; // TODO: 从数据库查询
        monitoring.setRegionalProportion(regionalProportion);
        
        // 4. 计算区域日均销量
        monitoring.calculateRegionalDailySales();
    }
    
    /**
     * 设置时间参数（安全库存天数、备货周期、发货天数等）
     * 
     * @param monitoring 监控数据对象
     * @param regionalWarehouseCode 区域仓编码
     */
    private void setTimeParameters(ProductStockoutMonitoring monitoring, String regionalWarehouseCode) {
        // TODO: 从配置表或产品配置中获取
        
        // 默认值
        int safetyStockDays = 30;     // 安全库存天数
        int stockingCycleDays = 30;   // 备货周期天数
        int shippingDays = 45;        // 发货天数（根据区域调整）
        
        // 根据区域仓调整发货天数
        if (regionalWarehouseCode.contains("WEST")) {
            shippingDays = 35;
        } else if (regionalWarehouseCode.contains("EAST")) {
            shippingDays = 50;
        } else if (regionalWarehouseCode.contains("CENTRAL")) {
            shippingDays = 45;
        } else if (regionalWarehouseCode.contains("SOUTH")) {
            shippingDays = 48;
        }
        
        monitoring.setSafetyStockDays(safetyStockDays);
        monitoring.setStockingCycleDays(stockingCycleDays);
        monitoring.setShippingDays(shippingDays);
        monitoring.setLeadTimeDays(stockingCycleDays + shippingDays);
    }
    
    /**
     * 批量计算断货点监控指标
     * 
     * @param products 产品列表
     * @param regionalWarehouses 区域仓列表
     * @param businessModes 业务模式列表
     * @param snapshotDate 快照日期
     * @return 监控数据列表
     */
    public List<ProductStockoutMonitoring> batchCalculateStockoutPoints(
            List<Map<String, Object>> products,
            List<Map<String, Object>> regionalWarehouses,
            List<BusinessMode> businessModes,
            LocalDate snapshotDate) {
        
        logger.info("开始批量计算断货点，产品数={}, 区域仓数={}, 业务模式数={}, 日期={}",
                products.size(), regionalWarehouses.size(), businessModes.size(), snapshotDate);
        
        List<ProductStockoutMonitoring> results = new ArrayList<>();
        
        for (Map<String, Object> product : products) {
            String productSku = (String) product.get("sku");
            Long productId = (Long) product.get("id");
            String productName = (String) product.get("name");
            
            for (Map<String, Object> warehouse : regionalWarehouses) {
                Long warehouseId = (Long) warehouse.get("id");
                String warehouseCode = (String) warehouse.get("code");
                
                for (BusinessMode mode : businessModes) {
                    try {
                        ProductStockoutMonitoring monitoring = calculateStockoutPoint(
                                productSku, productId, productName,
                                warehouseId, warehouseCode,
                                mode, snapshotDate);
                        results.add(monitoring);
                    } catch (Exception e) {
                        logger.error("计算失败: SKU={}, 区域仓={}, 模式={}",
                                productSku, warehouseCode, mode, e);
                    }
                }
            }
        }
        
        logger.info("批量计算完成，共生成{}条监控记录", results.size());
        return results;
    }
}
