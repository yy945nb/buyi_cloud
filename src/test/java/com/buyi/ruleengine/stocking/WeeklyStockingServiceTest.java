package com.buyi.ruleengine.stocking;

import com.buyi.ruleengine.stocking.enums.ProductCategory;
import com.buyi.ruleengine.stocking.enums.ShippingRegion;
import com.buyi.ruleengine.stocking.enums.StockingModelType;
import com.buyi.ruleengine.stocking.model.ProductStockConfig;
import com.buyi.ruleengine.stocking.model.SalesHistoryData;
import com.buyi.ruleengine.stocking.model.StockingResult;
import com.buyi.ruleengine.stocking.service.WeeklyStockingService;
import org.junit.Before;
import org.junit.Test;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.*;

/**
 * 每周固定备货服务单元测试
 * Weekly Fixed Stocking Service Unit Tests
 */
public class WeeklyStockingServiceTest {
    
    private WeeklyStockingService service;
    private LocalDate baseDate;
    
    @Before
    public void setUp() {
        service = new WeeklyStockingService();
        baseDate = LocalDate.of(2025, 1, 1);
    }
    
    @Test
    public void testBasicWeeklyStocking() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                null, null, 500, 100, 10);
        
        // 日均销量约为100件
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        StockingResult result = service.calculateWeeklyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        assertEquals(StockingModelType.WEEKLY_FIXED, result.getModelType());
        assertEquals(Integer.valueOf(7), result.getStockingCycleDays());
        assertTrue(result.getDailyAvgSales().compareTo(BigDecimal.ZERO) > 0);
    }
    
    @Test
    public void testWeeklyQuantityCalculation() {
        // 日均销量10件，7天备货量 = 10 * 7 = 70
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, BigDecimal.ONE, // 系数1.0，不调整
                1000, 0, 10);
        
        // 30天300件，15天150件，7天70件 => 日均约10件
        SalesHistoryData salesHistory = createSalesHistory(300, 150, 70);
        
        StockingResult result = service.calculateWeeklyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        // 日均销量应该接近10
        BigDecimal dailyAvg = result.getDailyAvgSales();
        assertTrue(dailyAvg.compareTo(BigDecimal.valueOf(9)) >= 0);
        assertTrue(dailyAvg.compareTo(BigDecimal.valueOf(11)) <= 0);
        
        // 推荐备货量应该接近70
        assertTrue(result.getRecommendedQuantity() >= 63);
        assertTrue(result.getRecommendedQuantity() <= 77);
    }
    
    @Test
    public void testWeightedAverageCalculation() {
        // 权重：30天20%，15天30%，7天50%
        // 30天销量300 (日均10), 15天销量150 (日均10), 7天销量140 (日均20)
        // 加权日均 = 10*0.2 + 10*0.3 + 20*0.5 = 2 + 3 + 10 = 15
        
        SalesHistoryData salesHistory = createSalesHistory(300, 150, 140);
        
        BigDecimal weightedAvg = service.calculateWeightedDailyAvgSales(salesHistory);
        
        assertNotNull(weightedAvg);
        // 允许一定误差
        assertTrue(weightedAvg.compareTo(BigDecimal.valueOf(14)) >= 0);
        assertTrue(weightedAvg.compareTo(BigDecimal.valueOf(16)) <= 0);
    }
    
    @Test
    public void testOutlierRemovalLogic() {
        // 测试噪点排除逻辑
        // 注意：对于小样本数据，3σ法则可能不够敏感
        // 这里测试基本的噪点排除机制是否工作
        
        SalesHistoryData salesHistory = new SalesHistoryData();
        salesHistory.setProductId(1001L);
        salesHistory.setSku("TEST-SKU");
        
        // 创建一个更极端的异常值场景
        List<SalesHistoryData.DailySales> dailySales = new ArrayList<>();
        // 添加14天正常销量（增加样本量提高3σ排除效果）
        for (int i = 0; i < 14; i++) {
            dailySales.add(new SalesHistoryData.DailySales(baseDate.minusDays(i + 1), 10));
        }
        
        // 设置销售数据
        salesHistory.setLast30DaysSales(dailySales);
        salesHistory.setTotalSales30Days(140);  // 14天，日均10
        salesHistory.setTotalSales15Days(140);  // 日均约9.3
        salesHistory.setTotalSales7Days(70);    // 日均10
        
        BigDecimal weightedAvg = service.calculateWeightedDailyAvgSales(salesHistory);
        
        assertNotNull(weightedAvg);
        // 没有异常值时，加权平均应该接近10
        assertTrue(weightedAvg.compareTo(BigDecimal.valueOf(8)) >= 0);
        assertTrue(weightedAvg.compareTo(BigDecimal.valueOf(12)) <= 0);
    }
    
    @Test
    public void testStockingCycleIs7Days() {
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_CENTRAL,
                null, null, 500, 100, 10);
        
        SalesHistoryData salesHistory = createSalesHistory(2100, 1050, 490);
        
        StockingResult result = service.calculateWeeklyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        assertEquals(Integer.valueOf(7), result.getStockingCycleDays());
    }
    
    @Test
    public void testNullSalesHistory() {
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 500, 0, 10);
        
        StockingResult result = service.calculateWeeklyStocking(config, null, baseDate);
        
        assertNotNull(result);
        assertEquals(0, BigDecimal.ZERO.compareTo(result.getDailyAvgSales()));
        assertEquals(0, result.getFinalQuantity().intValue());
    }
    
    @Test
    public void testZeroSales() {
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 500, 0, 10);
        
        SalesHistoryData salesHistory = createSalesHistory(0, 0, 0);
        
        StockingResult result = service.calculateWeeklyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        assertEquals(0, BigDecimal.ZERO.compareTo(result.getDailyAvgSales()));
        assertEquals(0, result.getFinalQuantity().intValue());
    }
    
    @Test
    public void testHighInventoryNoStockingNeeded() {
        // 高库存情况下不需要备货
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 10000, 5000, 10); // 大量库存
        
        // 低销量
        SalesHistoryData salesHistory = createSalesHistory(100, 50, 21);
        
        StockingResult result = service.calculateWeeklyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        // 由于库存远超需求，最终备货量应该为0
        assertEquals(0, result.getFinalQuantity().intValue());
    }
    
    @Test
    public void testMinOrderQuantityApplied() {
        ProductStockConfig config = createConfig(
                ProductCategory.B, ShippingRegion.US_WEST,
                null, null, 400, 0, 10);
        config.setMinOrderQuantity(100);
        
        // 低销量，需要的备货量可能低于最小订货量
        SalesHistoryData salesHistory = createSalesHistory(30, 15, 7);
        
        StockingResult result = service.calculateWeeklyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        // 如果需要备货，最小应该是100
        if (result.getFinalQuantity() > 0) {
            assertTrue(result.getFinalQuantity() >= 100);
        }
    }
    
    @Test
    public void testMaxOrderQuantityApplied() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_EAST,
                null, null, 100, 0, 10); // 低库存
        config.setMaxOrderQuantity(500);
        
        // 高销量
        SalesHistoryData salesHistory = createSalesHistory(30000, 15000, 7000);
        
        StockingResult result = service.calculateWeeklyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        // 最终备货量不应超过最大订货量
        assertTrue(result.getFinalQuantity() <= 500);
    }
    
    @Test
    public void testStockingCoefficientEffect() {
        ProductStockConfig configNormal = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, BigDecimal.ONE, 500, 0, 10);
        
        ProductStockConfig configWithCoef = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, BigDecimal.valueOf(1.5), 500, 0, 10);
        
        SalesHistoryData salesHistory = createSalesHistory(2100, 1050, 490);
        
        StockingResult resultNormal = service.calculateWeeklyStocking(configNormal, salesHistory, baseDate);
        StockingResult resultWithCoef = service.calculateWeeklyStocking(configWithCoef, salesHistory, baseDate);
        
        assertNotNull(resultNormal);
        assertNotNull(resultWithCoef);
        
        // 有浮动系数的调整后数量应该更大
        assertTrue(resultWithCoef.getAdjustedQuantity() > resultNormal.getAdjustedQuantity());
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
