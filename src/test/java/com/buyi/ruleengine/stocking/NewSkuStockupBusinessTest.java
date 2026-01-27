package com.buyi.ruleengine.stocking;

import com.buyi.ruleengine.enums.RiskLevel;
import com.buyi.ruleengine.model.MultiRegionStockoutAnalysis;
import com.buyi.ruleengine.stocking.enums.ProductCategory;
import com.buyi.ruleengine.stocking.enums.ShippingRegion;
import com.buyi.ruleengine.stocking.enums.StockingModelType;
import com.buyi.ruleengine.stocking.model.ProductStockConfig;
import com.buyi.ruleengine.stocking.model.SalesHistoryData;
import com.buyi.ruleengine.stocking.model.StockingResult;
import com.buyi.ruleengine.stocking.service.NewSkuStockupBusiness;
import org.junit.Before;
import org.junit.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * 新款爆款备货业务服务单元测试
 * New SKU Stockup Business Unit Tests
 */
public class NewSkuStockupBusinessTest {
    
    private NewSkuStockupBusiness service;
    private LocalDate baseDate;
    
    @Before
    public void setUp() {
        service = new NewSkuStockupBusiness();
        baseDate = LocalDate.of(2025, 1, 1);
    }
    
    @Test
    public void testIsHotSellingProduct_SalesSurge() {
        // 销量暴涨场景：7天销量是30天平均的2倍以上
        SalesHistoryData salesHistory = createSalesHistory(3000, 2000, 1500);
        // 30天日均=100, 7天日均=214, 比率>2.0
        
        boolean isHotSelling = service.isHotSellingProduct(salesHistory);
        
        assertTrue("销量暴涨应判定为爆款商品", isHotSelling);
    }
    
    @Test
    public void testIsHotSellingProduct_NormalSales() {
        // 正常销量场景：各时间段销量基本稳定
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        // 30天日均=100, 7天日均=100, 比率=1.0
        
        boolean isHotSelling = service.isHotSellingProduct(salesHistory);
        
        assertFalse("正常销量不应判定为爆款商品", isHotSelling);
    }
    
    @Test
    public void testIsHotSellingProduct_NewProduct() {
        // 新品场景：30天无销量，7天有销量
        SalesHistoryData salesHistory = createSalesHistory(0, 0, 700);
        
        boolean isHotSelling = service.isHotSellingProduct(salesHistory);
        
        assertTrue("新品应判定为爆款商品", isHotSelling);
    }
    
    @Test
    public void testIsHotSellingProduct_NullData() {
        boolean isHotSelling = service.isHotSellingProduct(null);
        
        assertFalse("空数据不应判定为爆款商品", isHotSelling);
    }
    
    @Test
    public void testAnalyzeMultiRegionStockout_AllRegionsAtRisk() {
        // 所有区域都存在风险的场景
        Map<ShippingRegion, Integer> regionInventories = createLowInventoryAllRegions();
        SalesHistoryData salesHistory = createSalesHistory(6000, 3000, 1400);
        
        MultiRegionStockoutAnalysis analysis = service.analyzeMultiRegionStockout(
                1001L, "TEST-SKU",
                regionInventories, null, salesHistory, null, null,
                15, 35, baseDate);
        
        assertNotNull(analysis);
        assertEquals("TEST-SKU", analysis.getSku());
        assertTrue("应触发爆款模型", analysis.isHotSellingModelTriggered());
        assertTrue("风险区域数应>=2", analysis.getAtRiskRegionCount() >= 2);
    }
    
    @Test
    public void testAnalyzeMultiRegionStockout_NoRisk() {
        // 所有区域库存充足的场景
        Map<ShippingRegion, Integer> regionInventories = createHighInventoryAllRegions();
        SalesHistoryData salesHistory = createSalesHistory(300, 150, 70);
        
        MultiRegionStockoutAnalysis analysis = service.analyzeMultiRegionStockout(
                1001L, "TEST-SKU",
                regionInventories, null, salesHistory, null, null,
                15, 35, baseDate);
        
        assertNotNull(analysis);
        assertFalse("不应触发爆款模型", analysis.isHotSellingModelTriggered());
        assertEquals(0, analysis.getAtRiskRegionCount());
        assertEquals(RiskLevel.OK, analysis.getOverallRiskLevel());
    }
    
    @Test
    public void testAnalyzeMultiRegionStockout_PartialRisk() {
        // 部分区域存在风险的场景
        Map<ShippingRegion, Integer> regionInventories = new EnumMap<>(ShippingRegion.class);
        regionInventories.put(ShippingRegion.US_WEST, 100);  // 低库存
        regionInventories.put(ShippingRegion.US_EAST, 100);  // 低库存
        regionInventories.put(ShippingRegion.US_CENTRAL, 5000);  // 高库存
        regionInventories.put(ShippingRegion.US_SOUTH, 5000);  // 高库存
        
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        MultiRegionStockoutAnalysis analysis = service.analyzeMultiRegionStockout(
                1001L, "TEST-SKU",
                regionInventories, null, salesHistory, null, null,
                15, 35, baseDate);
        
        assertNotNull(analysis);
        // 美西和美东各占30%和35%的销量，低库存应有风险
        assertTrue("部分区域应有风险", analysis.getAtRiskRegionCount() >= 1);
    }
    
    @Test
    public void testCalculateHotSellingStocking_MultiRegionStockout() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                35, null, 100, 0, 15);
        
        // 创建多区域低库存情况
        Map<ShippingRegion, Integer> regionInventories = createLowInventoryAllRegions();
        SalesHistoryData salesHistory = createSalesHistory(6000, 3000, 1400);
        
        // 首先执行多区域分析
        MultiRegionStockoutAnalysis analysis = service.analyzeMultiRegionStockout(
                1001L, "TEST-SKU",
                regionInventories, null, salesHistory, null, null,
                15, 35, baseDate);
        
        // 如果触发了爆款模型，计算备货
        if (analysis.isHotSellingModelTriggered()) {
            StockingResult result = service.calculateHotSellingStocking(
                    config, salesHistory, analysis, baseDate);
            
            assertNotNull(result);
            assertEquals(StockingModelType.NEW_SKU, result.getModelType());
            assertTrue(result.getFinalQuantity() > 0);
            assertNotNull(result.getUrgencyNote());
        }
    }
    
    @Test
    public void testEvaluateAndCalculateNewSkuStocking_HotSelling() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                35, null, 100, 0, 15);
        
        Map<ShippingRegion, Integer> regionInventories = createLowInventoryAllRegions();
        // 销量暴涨的数据
        SalesHistoryData salesHistory = createSalesHistory(3000, 2000, 1400);
        
        StockingResult result = service.evaluateAndCalculateNewSkuStocking(
                config, regionInventories, null, salesHistory, null, null, baseDate);
        
        // 如果检测到爆款且有风险，应返回结果
        if (result != null) {
            assertEquals(StockingModelType.NEW_SKU, result.getModelType());
            assertTrue(result.getFinalQuantity() > 0);
            assertNotNull(result.getReason());
            assertTrue(result.getReason().contains("爆款"));
        }
    }
    
    @Test
    public void testEvaluateAndCalculateNewSkuStocking_NotHotSelling() {
        ProductStockConfig config = createConfig(
                ProductCategory.B, ShippingRegion.US_CENTRAL,
                30, null, 5000, 2000, 15);
        
        Map<ShippingRegion, Integer> regionInventories = createHighInventoryAllRegions();
        // 正常销量数据
        SalesHistoryData salesHistory = createSalesHistory(300, 150, 70);
        
        StockingResult result = service.evaluateAndCalculateNewSkuStocking(
                config, regionInventories, null, salesHistory, null, null, baseDate);
        
        // 不是爆款且无风险，应返回null
        assertNull("非爆款商品且无风险应返回null", result);
    }
    
    @Test
    public void testMultiRegionAnalysis_RegionDetails() {
        Map<ShippingRegion, Integer> regionInventories = createLowInventoryAllRegions();
        SalesHistoryData salesHistory = createSalesHistory(6000, 3000, 1400);
        
        MultiRegionStockoutAnalysis analysis = service.analyzeMultiRegionStockout(
                1001L, "TEST-SKU",
                regionInventories, null, salesHistory, null, null,
                15, 35, baseDate);
        
        // 验证每个区域都有分析结果
        assertEquals(4, analysis.getRegionDetails().size());
        
        for (ShippingRegion region : ShippingRegion.values()) {
            MultiRegionStockoutAnalysis.RegionStockoutDetail detail = 
                    analysis.getRegionDetails().get(region);
            assertNotNull("区域" + region + "应有分析结果", detail);
            assertEquals(region, detail.getRegion());
            assertNotNull(detail.getRiskLevel());
            assertEquals(region.getShippingDays(), detail.getShippingDays().intValue());
        }
    }
    
    @Test
    public void testMultiRegionAnalysis_TotalReplenishment() {
        Map<ShippingRegion, Integer> regionInventories = createLowInventoryAllRegions();
        SalesHistoryData salesHistory = createSalesHistory(6000, 3000, 1400);
        
        MultiRegionStockoutAnalysis analysis = service.analyzeMultiRegionStockout(
                1001L, "TEST-SKU",
                regionInventories, null, salesHistory, null, null,
                15, 35, baseDate);
        
        if (analysis.isHotSellingModelTriggered()) {
            int totalReplenishment = analysis.getTotalSuggestedReplenishment();
            assertTrue("总补货量应大于0", totalReplenishment > 0);
        }
    }
    
    @Test
    public void testMultiRegionAnalysis_RecommendedStrategy() {
        Map<ShippingRegion, Integer> regionInventories = createLowInventoryAllRegions();
        SalesHistoryData salesHistory = createSalesHistory(6000, 3000, 1400);
        
        MultiRegionStockoutAnalysis analysis = service.analyzeMultiRegionStockout(
                1001L, "TEST-SKU",
                regionInventories, null, salesHistory, null, null,
                15, 35, baseDate);
        
        assertNotNull(analysis.getRecommendedStrategy());
        assertTrue(analysis.getRecommendedStrategy().length() > 0);
    }
    
    @Test
    public void testCustomSalesRatios() {
        Map<ShippingRegion, Integer> regionInventories = createLowInventoryAllRegions();
        SalesHistoryData salesHistory = createSalesHistory(6000, 3000, 1400);
        
        // 自定义销量占比
        Map<ShippingRegion, BigDecimal> customRatios = new HashMap<>();
        customRatios.put(ShippingRegion.US_WEST, new BigDecimal("0.50"));
        customRatios.put(ShippingRegion.US_EAST, new BigDecimal("0.25"));
        customRatios.put(ShippingRegion.US_CENTRAL, new BigDecimal("0.15"));
        customRatios.put(ShippingRegion.US_SOUTH, new BigDecimal("0.10"));
        
        MultiRegionStockoutAnalysis analysis = service.analyzeMultiRegionStockout(
                1001L, "TEST-SKU",
                regionInventories, null, salesHistory, customRatios, null,
                15, 35, baseDate);
        
        assertNotNull(analysis);
        // 美西占比最高，库存又低，应该风险最高
        MultiRegionStockoutAnalysis.RegionStockoutDetail westDetail = 
                analysis.getRegionDetails().get(ShippingRegion.US_WEST);
        assertNotNull(westDetail);
    }
    
    @Test
    public void testInTransitInventory() {
        Map<ShippingRegion, Integer> regionInventories = createLowInventoryAllRegions();
        Map<ShippingRegion, Integer> regionInTransit = new EnumMap<>(ShippingRegion.class);
        regionInTransit.put(ShippingRegion.US_WEST, 5000);
        regionInTransit.put(ShippingRegion.US_EAST, 5000);
        regionInTransit.put(ShippingRegion.US_CENTRAL, 5000);
        regionInTransit.put(ShippingRegion.US_SOUTH, 5000);
        
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        MultiRegionStockoutAnalysis analysis = service.analyzeMultiRegionStockout(
                1001L, "TEST-SKU",
                regionInventories, regionInTransit, salesHistory, null, null,
                15, 35, baseDate);
        
        // 有大量在途库存，风险应该降低
        assertNotNull(analysis);
    }
    
    @Test
    public void testNullInputs() {
        MultiRegionStockoutAnalysis analysis = service.analyzeMultiRegionStockout(
                null, null, null, null, null, null, null,
                null, null, null);
        
        assertNotNull(analysis);
        assertFalse(analysis.isHotSellingModelTriggered());
    }
    
    // ==================== 辅助方法 ====================
    
    private ProductStockConfig createConfig(
            ProductCategory category, ShippingRegion region,
            Integer safetyStockDays, BigDecimal stockingCoefficient,
            Integer currentInventory, Integer inTransitInventory, Integer productionDays) {
        
        ProductStockConfig config = new ProductStockConfig();
        config.setProductId(1001L);
        config.setSku("TEST-SKU");
        config.setProductName("测试爆款商品");
        config.setCategory(category);
        config.setShippingRegion(region);
        config.setSafetyStockDays(safetyStockDays);
        config.setStockingCoefficient(stockingCoefficient);
        config.setCurrentInventory(currentInventory);
        config.setInTransitInventory(inTransitInventory);
        config.setProductionDays(productionDays);
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
    
    private Map<ShippingRegion, Integer> createLowInventoryAllRegions() {
        Map<ShippingRegion, Integer> inventories = new EnumMap<>(ShippingRegion.class);
        inventories.put(ShippingRegion.US_WEST, 100);
        inventories.put(ShippingRegion.US_EAST, 100);
        inventories.put(ShippingRegion.US_CENTRAL, 100);
        inventories.put(ShippingRegion.US_SOUTH, 100);
        return inventories;
    }
    
    private Map<ShippingRegion, Integer> createHighInventoryAllRegions() {
        Map<ShippingRegion, Integer> inventories = new EnumMap<>(ShippingRegion.class);
        inventories.put(ShippingRegion.US_WEST, 10000);
        inventories.put(ShippingRegion.US_EAST, 10000);
        inventories.put(ShippingRegion.US_CENTRAL, 10000);
        inventories.put(ShippingRegion.US_SOUTH, 10000);
        return inventories;
    }
}
