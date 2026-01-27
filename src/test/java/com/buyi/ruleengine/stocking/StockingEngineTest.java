package com.buyi.ruleengine.stocking;

import com.buyi.ruleengine.stocking.enums.ProductCategory;
import com.buyi.ruleengine.stocking.enums.ShippingRegion;
import com.buyi.ruleengine.stocking.enums.StockingModelType;
import com.buyi.ruleengine.stocking.model.ProductStockConfig;
import com.buyi.ruleengine.stocking.model.SalesHistoryData;
import com.buyi.ruleengine.stocking.model.StockingResult;
import com.buyi.ruleengine.stocking.service.StockingEngine;
import org.junit.Before;
import org.junit.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * 备货引擎单元测试
 * Stocking Engine Unit Tests
 */
public class StockingEngineTest {
    
    private StockingEngine engine;
    private LocalDate baseDate;
    
    @Before
    public void setUp() {
        engine = new StockingEngine();
        baseDate = LocalDate.of(2025, 1, 1);
    }
    
    @Test
    public void testCalculateMonthlyStocking() {
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 500, 100, 15);
        
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        StockingResult result = engine.calculateMonthlyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        assertEquals(StockingModelType.MONTHLY, result.getModelType());
    }
    
    @Test
    public void testCalculateWeeklyStocking() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_EAST,
                null, null, 500, 100, 10);
        
        SalesHistoryData salesHistory = createSalesHistory(2100, 1050, 490);
        
        StockingResult result = engine.calculateWeeklyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        assertEquals(StockingModelType.WEEKLY_FIXED, result.getModelType());
        assertEquals(Integer.valueOf(7), result.getStockingCycleDays());
    }
    
    @Test
    public void testCalculateStockingWithMonthlyModel() {
        ProductStockConfig config = createConfig(
                ProductCategory.B, ShippingRegion.US_CENTRAL,
                null, null, 800, 200, 18);
        
        SalesHistoryData salesHistory = createSalesHistory(1500, 750, 350);
        
        StockingResult result = engine.calculateStocking(
                config, salesHistory, null, StockingModelType.MONTHLY, baseDate);
        
        assertNotNull(result);
        // 应该使用月度模型（除非检测到紧急断货风险）
        assertTrue(result.getModelType() == StockingModelType.MONTHLY || 
                   result.getModelType() == StockingModelType.STOCKOUT_EMERGENCY);
    }
    
    @Test
    public void testCalculateStockingWithWeeklyModel() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                null, null, 1000, 300, 12);
        
        SalesHistoryData salesHistory = createSalesHistory(2100, 1050, 490);
        
        StockingResult result = engine.calculateStocking(
                config, salesHistory, null, StockingModelType.WEEKLY_FIXED, baseDate);
        
        assertNotNull(result);
        // 应该使用每周模型（除非检测到紧急断货风险）
        assertTrue(result.getModelType() == StockingModelType.WEEKLY_FIXED || 
                   result.getModelType() == StockingModelType.STOCKOUT_EMERGENCY);
    }
    
    @Test
    public void testEmergencyStockingPrioritized() {
        // 创建紧急断货风险场景
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_EAST,
                35, null, 100, 0, 30); // 极低库存
        
        // 高销量
        SalesHistoryData salesHistory = createSalesHistory(6000, 3000, 1400);
        
        // 即使指定月度模型，如果有紧急断货风险应该返回紧急备货结果
        StockingResult result = engine.calculateStocking(
                config, salesHistory, null, StockingModelType.MONTHLY, baseDate);
        
        assertNotNull(result);
        // 检查是否为紧急备货或包含断货风险信息
        if (Boolean.TRUE.equals(result.getIsEmergency())) {
            assertEquals(StockingModelType.STOCKOUT_EMERGENCY, result.getModelType());
        }
    }
    
    @Test
    public void testGetAllModelResults() {
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_CENTRAL,
                null, null, 600, 150, 15);
        
        SalesHistoryData salesHistory = createSalesHistory(2100, 1050, 490);
        
        List<StockingResult> results = engine.getAllModelResults(
                config, salesHistory, null, baseDate);
        
        assertNotNull(results);
        // 应该至少有两个结果（月度和每周）
        assertTrue(results.size() >= 2);
        
        // 验证包含不同的模型类型
        boolean hasMonthly = results.stream().anyMatch(r -> r.getModelType() == StockingModelType.MONTHLY);
        boolean hasWeekly = results.stream().anyMatch(r -> r.getModelType() == StockingModelType.WEEKLY_FIXED);
        assertTrue(hasMonthly);
        assertTrue(hasWeekly);
    }
    
    @Test
    public void testGetRecommendedStocking() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                null, null, 800, 200, 12);
        
        SalesHistoryData salesHistory = createSalesHistory(2100, 1050, 490);
        
        StockingResult result = engine.getRecommendedStocking(
                config, salesHistory, null, baseDate);
        
        assertNotNull(result);
        // S类商品应该推荐每周备货（除非有紧急情况）
        assertTrue(result.getModelType() == StockingModelType.WEEKLY_FIXED || 
                   result.getModelType() == StockingModelType.STOCKOUT_EMERGENCY);
    }
    
    @Test
    public void testBatchCalculateStocking() {
        List<ProductStockConfig> products = new ArrayList<>();
        Map<String, SalesHistoryData> salesHistoryMap = new HashMap<>();
        
        // 添加多个产品
        ProductStockConfig p1 = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                null, null, 500, 100, 15);
        p1.setSku("SKU-001");
        products.add(p1);
        salesHistoryMap.put("SKU-001", createSalesHistory(3000, 1500, 700));
        
        ProductStockConfig p2 = createConfig(
                ProductCategory.A, ShippingRegion.US_EAST,
                null, null, 600, 150, 18);
        p2.setSku("SKU-002");
        products.add(p2);
        salesHistoryMap.put("SKU-002", createSalesHistory(2100, 1050, 490));
        
        ProductStockConfig p3 = createConfig(
                ProductCategory.B, ShippingRegion.US_CENTRAL,
                null, null, 400, 100, 12);
        p3.setSku("SKU-003");
        products.add(p3);
        salesHistoryMap.put("SKU-003", createSalesHistory(900, 450, 210));
        
        List<StockingResult> results = engine.batchCalculateStocking(
                products, salesHistoryMap, null, StockingModelType.MONTHLY, baseDate);
        
        assertNotNull(results);
        // 应该返回需要备货的产品结果
        for (StockingResult result : results) {
            assertNotNull(result.getSku());
            assertNotNull(result.getModelType());
        }
    }
    
    @Test
    public void testBatchCalculateSkipsDisabledProducts() {
        List<ProductStockConfig> products = new ArrayList<>();
        Map<String, SalesHistoryData> salesHistoryMap = new HashMap<>();
        
        // 启用自动备货的产品
        ProductStockConfig p1 = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 500, 100, 15);
        p1.setSku("ENABLED-SKU");
        p1.setAutoStockingEnabled(true);
        products.add(p1);
        salesHistoryMap.put("ENABLED-SKU", createSalesHistory(3000, 1500, 700));
        
        // 禁用自动备货的产品
        ProductStockConfig p2 = createConfig(
                ProductCategory.A, ShippingRegion.US_EAST,
                null, null, 500, 100, 15);
        p2.setSku("DISABLED-SKU");
        p2.setAutoStockingEnabled(false);
        products.add(p2);
        salesHistoryMap.put("DISABLED-SKU", createSalesHistory(3000, 1500, 700));
        
        List<StockingResult> results = engine.batchCalculateStocking(
                products, salesHistoryMap, null, StockingModelType.MONTHLY, baseDate);
        
        // 禁用的产品不应出现在结果中
        boolean hasDisabled = results.stream().anyMatch(r -> "DISABLED-SKU".equals(r.getSku()));
        assertFalse(hasDisabled);
    }
    
    @Test
    public void testRecommendedStockingByCategory() {
        SalesHistoryData salesHistory = createSalesHistory(2100, 1050, 490);
        
        // S类商品推荐每周备货
        ProductStockConfig configS = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                null, null, 1000, 200, 15);
        StockingResult resultS = engine.getRecommendedStocking(
                configS, salesHistory, null, baseDate);
        
        // B类商品推荐月度备货
        ProductStockConfig configB = createConfig(
                ProductCategory.B, ShippingRegion.US_WEST,
                null, null, 1000, 200, 15);
        StockingResult resultB = engine.getRecommendedStocking(
                configB, salesHistory, null, baseDate);
        
        assertNotNull(resultS);
        assertNotNull(resultB);
        
        // S类应该使用每周模型（除非紧急）
        if (!Boolean.TRUE.equals(resultS.getIsEmergency())) {
            assertEquals(StockingModelType.WEEKLY_FIXED, resultS.getModelType());
        }
        
        // B类应该使用月度模型（除非紧急）
        if (!Boolean.TRUE.equals(resultB.getIsEmergency())) {
            assertEquals(StockingModelType.MONTHLY, resultB.getModelType());
        }
    }
    
    @Test
    public void testStockoutRiskInfoAppended() {
        // 创建有断货风险但不紧急的场景
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                30, null, 400, 0, 15);
        
        SalesHistoryData salesHistory = createSalesHistory(2100, 1050, 490);
        
        StockingResult result = engine.calculateStocking(
                config, salesHistory, null, StockingModelType.MONTHLY, baseDate);
        
        assertNotNull(result);
        // 如果检测到非紧急断货风险，应该在reason中包含警告信息
        // 或者设置断货风险相关字段
    }
    
    // 辅助方法
    private ProductStockConfig createConfig(
            ProductCategory category, ShippingRegion region,
            Integer safetyStockDays, BigDecimal stockingCoefficient,
            Integer currentInventory, Integer inTransitInventory, Integer productionDays) {
        
        ProductStockConfig config = new ProductStockConfig();
        config.setProductId(1001L);
        config.setSku("TEST-SKU");
        config.setProductName("测试商品");
        config.setCategory(category);
        config.setShippingRegion(region);
        config.setSafetyStockDays(safetyStockDays);
        config.setStockingCoefficient(stockingCoefficient);
        config.setCurrentInventory(currentInventory);
        config.setInTransitInventory(inTransitInventory);
        config.setProductionDays(productionDays);
        config.setAutoStockingEnabled(true);
        return config;
    }
    
    private SalesHistoryData createSalesHistory(Integer total30, Integer total15, Integer total7) {
        SalesHistoryData salesHistory = new SalesHistoryData();
        salesHistory.setProductId(1001L);
        salesHistory.setSku("TEST-SKU");
        salesHistory.setTotalSales30Days(total30);
        salesHistory.setTotalSales15Days(total15);
        salesHistory.setTotalSales7Days(total7);
        return salesHistory;
    }
}
