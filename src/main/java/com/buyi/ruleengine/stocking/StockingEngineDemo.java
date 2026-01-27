package com.buyi.ruleengine.stocking;

import com.buyi.ruleengine.stocking.enums.ProductCategory;
import com.buyi.ruleengine.stocking.enums.ShippingRegion;
import com.buyi.ruleengine.stocking.enums.StockingModelType;
import com.buyi.ruleengine.stocking.model.ProductStockConfig;
import com.buyi.ruleengine.stocking.model.SalesHistoryData;
import com.buyi.ruleengine.stocking.model.StockingResult;
import com.buyi.ruleengine.stocking.service.StockingEngine;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 备货引擎示例
 * Stocking Engine Demo
 * 
 * 演示三种备货模型的使用：
 * 1. 月度备货模型 - 基于SABC分类的月度备货
 * 2. 每周固定备货模型 - 固定7天周期的备货
 * 3. 断货点临时备货模型 - 基于断货风险的紧急备货
 */
public class StockingEngineDemo {
    
    public static void main(String[] args) {
        System.out.println("===========================================");
        System.out.println("      备货引擎演示 / Stocking Engine Demo");
        System.out.println("===========================================\n");
        
        StockingEngine engine = new StockingEngine();
        LocalDate baseDate = LocalDate.now();
        
        // 演示1: 月度备货模型
        demonstrateMonthlyStocking(engine, baseDate);
        
        // 演示2: 每周固定备货模型
        demonstrateWeeklyStocking(engine, baseDate);
        
        // 演示3: 断货点临时备货模型
        demonstrateStockoutStocking(engine, baseDate);
        
        // 演示4: 综合备货建议
        demonstrateRecommendedStocking(engine, baseDate);
        
        // 演示5: 批量计算
        demonstrateBatchCalculation(engine, baseDate);
    }
    
    /**
     * 演示月度备货模型
     */
    private static void demonstrateMonthlyStocking(StockingEngine engine, LocalDate baseDate) {
        System.out.println("【1. 月度备货模型演示】");
        System.out.println("----------------------------------------------");
        
        // 创建S类畅销品配置
        ProductStockConfig config = createSampleConfig(
                1001L, "SKU-001", "畅销产品A",
                ProductCategory.S, ShippingRegion.US_EAST,
                null, null, // 使用默认安全库存和备货系数
                1000, 500, 20);
        
        // 创建销售历史
        SalesHistoryData salesHistory = createSampleSalesHistory(
                1001L, "SKU-001", 3000, 1500, 700);
        
        // 计算月度备货
        StockingResult result = engine.calculateMonthlyStocking(config, salesHistory, baseDate);
        
        printResult("月度备货", result);
        System.out.println();
    }
    
    /**
     * 演示每周固定备货模型
     */
    private static void demonstrateWeeklyStocking(StockingEngine engine, LocalDate baseDate) {
        System.out.println("【2. 每周固定备货模型演示】");
        System.out.println("----------------------------------------------");
        
        // 创建配置
        ProductStockConfig config = createSampleConfig(
                1002L, "SKU-002", "标准产品B",
                ProductCategory.A, ShippingRegion.US_WEST,
                30, BigDecimal.valueOf(1.15),
                800, 200, 15);
        
        // 创建销售历史
        SalesHistoryData salesHistory = createSampleSalesHistory(
                1002L, "SKU-002", 1500, 800, 350);
        
        // 计算每周备货
        StockingResult result = engine.calculateWeeklyStocking(config, salesHistory, baseDate);
        
        printResult("每周固定备货", result);
        System.out.println();
    }
    
    /**
     * 演示断货点临时备货模型
     */
    private static void demonstrateStockoutStocking(StockingEngine engine, LocalDate baseDate) {
        System.out.println("【3. 断货点临时备货模型演示】");
        System.out.println("----------------------------------------------");
        
        // 创建低库存配置（模拟断货风险）
        ProductStockConfig config = createSampleConfig(
                1003L, "SKU-003", "即将断货产品C",
                ProductCategory.S, ShippingRegion.US_CENTRAL,
                35, BigDecimal.valueOf(1.2),
                200, 0, 25); // 低库存
        
        // 创建销售历史（高销量）
        SalesHistoryData salesHistory = createSampleSalesHistory(
                1003L, "SKU-003", 4500, 2200, 1050);
        
        // 已有发货计划
        Map<LocalDate, Integer> existingShipments = new HashMap<>();
        existingShipments.put(baseDate.plusDays(10), 500);
        
        // 评估断货风险
        StockingResult result = engine.evaluateStockoutRisk(
                config, salesHistory, existingShipments, baseDate);
        
        if (result != null) {
            printResult("断货点临时备货", result);
        } else {
            System.out.println("未检测到断货风险");
        }
        System.out.println();
    }
    
    /**
     * 演示综合备货建议
     */
    private static void demonstrateRecommendedStocking(StockingEngine engine, LocalDate baseDate) {
        System.out.println("【4. 综合备货建议演示】");
        System.out.println("----------------------------------------------");
        
        // 创建配置
        ProductStockConfig config = createSampleConfig(
                1004L, "SKU-004", "综合测试产品D",
                ProductCategory.A, ShippingRegion.US_SOUTH,
                null, null,
                600, 300, 18);
        
        // 创建销售历史
        SalesHistoryData salesHistory = createSampleSalesHistory(
                1004L, "SKU-004", 2100, 1000, 480);
        
        // 获取推荐备货建议
        StockingResult result = engine.getRecommendedStocking(
                config, salesHistory, null, baseDate);
        
        printResult("推荐备货", result);
        System.out.println();
        
        // 获取所有模型结果进行比较
        System.out.println("各模型计算结果比较：");
        List<StockingResult> allResults = engine.getAllModelResults(
                config, salesHistory, null, baseDate);
        for (StockingResult r : allResults) {
            System.out.println("  - " + r.getModelType().getDescription() + 
                    ": 备货量=" + r.getFinalQuantity());
        }
        System.out.println();
    }
    
    /**
     * 演示批量计算
     */
    private static void demonstrateBatchCalculation(StockingEngine engine, LocalDate baseDate) {
        System.out.println("【5. 批量计算演示】");
        System.out.println("----------------------------------------------");
        
        // 创建多个产品配置
        List<ProductStockConfig> products = new ArrayList<>();
        Map<String, SalesHistoryData> salesHistoryMap = new HashMap<>();
        
        // 产品1 - S类
        ProductStockConfig p1 = createSampleConfig(
                2001L, "BATCH-001", "批量产品1",
                ProductCategory.S, ShippingRegion.US_WEST,
                null, null, 1000, 200, 15);
        products.add(p1);
        salesHistoryMap.put("BATCH-001", createSampleSalesHistory(2001L, "BATCH-001", 3000, 1500, 700));
        
        // 产品2 - A类
        ProductStockConfig p2 = createSampleConfig(
                2002L, "BATCH-002", "批量产品2",
                ProductCategory.A, ShippingRegion.US_EAST,
                null, null, 800, 150, 20);
        products.add(p2);
        salesHistoryMap.put("BATCH-002", createSampleSalesHistory(2002L, "BATCH-002", 2100, 1000, 490));
        
        // 产品3 - B类
        ProductStockConfig p3 = createSampleConfig(
                2003L, "BATCH-003", "批量产品3",
                ProductCategory.B, ShippingRegion.US_CENTRAL,
                null, null, 500, 100, 18);
        products.add(p3);
        salesHistoryMap.put("BATCH-003", createSampleSalesHistory(2003L, "BATCH-003", 900, 450, 210));
        
        // 批量计算（使用月度模型）
        List<StockingResult> results = engine.batchCalculateStocking(
                products, salesHistoryMap, null, StockingModelType.MONTHLY, baseDate);
        
        System.out.println("批量计算结果：");
        for (StockingResult result : results) {
            System.out.println("  SKU: " + result.getSku() + 
                    ", 分类: " + (result.getCategory() != null ? result.getCategory().getDescription() : "N/A") +
                    ", 日均销: " + result.getDailyAvgSales().setScale(2, java.math.RoundingMode.HALF_UP) +
                    ", 建议备货: " + result.getFinalQuantity());
        }
        System.out.println();
    }
    
    /**
     * 创建示例商品配置
     */
    private static ProductStockConfig createSampleConfig(
            Long productId, String sku, String productName,
            ProductCategory category, ShippingRegion shippingRegion,
            Integer safetyStockDays, BigDecimal stockingCoefficient,
            Integer currentInventory, Integer inTransitInventory, Integer productionDays) {
        
        ProductStockConfig config = new ProductStockConfig();
        config.setProductId(productId);
        config.setSku(sku);
        config.setProductName(productName);
        config.setCategory(category);
        config.setShippingRegion(shippingRegion);
        config.setSafetyStockDays(safetyStockDays);
        config.setStockingCoefficient(stockingCoefficient);
        config.setCurrentInventory(currentInventory);
        config.setInTransitInventory(inTransitInventory);
        config.setProductionDays(productionDays);
        config.setMinOrderQuantity(100);
        config.setMaxOrderQuantity(10000);
        config.setAutoStockingEnabled(true);
        return config;
    }
    
    /**
     * 创建示例销售历史数据
     */
    private static SalesHistoryData createSampleSalesHistory(
            Long productId, String sku,
            Integer totalSales30Days, Integer totalSales15Days, Integer totalSales7Days) {
        
        SalesHistoryData salesHistory = new SalesHistoryData();
        salesHistory.setProductId(productId);
        salesHistory.setSku(sku);
        salesHistory.setTotalSales30Days(totalSales30Days);
        salesHistory.setTotalSales15Days(totalSales15Days);
        salesHistory.setTotalSales7Days(totalSales7Days);
        salesHistory.setDataEndDate(LocalDate.now().minusDays(1));
        return salesHistory;
    }
    
    /**
     * 打印备货结果
     */
    private static void printResult(String title, StockingResult result) {
        if (result == null) {
            System.out.println(title + ": 无需备货");
            return;
        }
        
        System.out.println(title + "计算结果：");
        System.out.println("  SKU: " + result.getSku());
        System.out.println("  商品名称: " + result.getProductName());
        System.out.println("  模型类型: " + result.getModelType().getDescription());
        System.out.println("  商品分类: " + (result.getCategory() != null ? result.getCategory().getDescription() : "N/A"));
        System.out.println("  发货区域: " + (result.getShippingRegion() != null ? result.getShippingRegion().getDescription() : "N/A"));
        System.out.println("  日均销量: " + result.getDailyAvgSales().setScale(2, java.math.RoundingMode.HALF_UP));
        System.out.println("  当前库存: " + result.getCurrentInventory());
        System.out.println("  在途库存: " + result.getInTransitInventory());
        System.out.println("  建议备货量: " + result.getRecommendedQuantity());
        System.out.println("  调整后备货量: " + result.getAdjustedQuantity());
        System.out.println("  最终备货量: " + result.getFinalQuantity());
        System.out.println("  备货周期: " + result.getStockingCycleDays() + "天");
        System.out.println("  安全库存天数: " + result.getSafetyStockDays());
        System.out.println("  备货浮动系数: " + result.getStockingCoefficient());
        System.out.println("  建议发货日期: " + result.getSuggestedShipDate());
        System.out.println("  预计到货日期: " + result.getExpectedArrivalDate());
        
        if (Boolean.TRUE.equals(result.getIsEmergency())) {
            System.out.println("  ⚠️ 紧急程度: " + result.getUrgencyNote());
        }
        if (result.getStockoutRiskDays() != null) {
            System.out.println("  断货风险天数: " + result.getStockoutRiskDays());
        }
        
        System.out.println("  备货原因: " + result.getReason());
    }
}
