package com.buyi.ruleengine.stocking;

import com.buyi.ruleengine.stocking.enums.ProductCategory;
import com.buyi.ruleengine.stocking.enums.ShippingRegion;
import com.buyi.ruleengine.stocking.enums.StockingModelType;
import com.buyi.ruleengine.stocking.model.ProductStockConfig;
import com.buyi.ruleengine.stocking.model.SalesHistoryData;
import com.buyi.ruleengine.stocking.model.StockingResult;
import com.buyi.ruleengine.stocking.service.MonthlyStockingService;
import org.junit.Before;
import org.junit.Test;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

import static org.junit.Assert.*;

/**
 * 月度备货服务单元测试
 * Monthly Stocking Service Unit Tests
 */
public class MonthlyStockingServiceTest {
    
    private MonthlyStockingService service;
    private LocalDate baseDate;
    
    @Before
    public void setUp() {
        service = new MonthlyStockingService();
        baseDate = LocalDate.of(2025, 1, 1);
    }
    
    @Test
    public void testBasicMonthlyStocking() {
        // 创建S类商品配置
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_EAST,
                null, null, 1000, 500, 20);
        
        // 创建销售历史：30天3000，15天1500，7天700
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        // 计算月度备货
        StockingResult result = service.calculateMonthlyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        assertEquals(StockingModelType.MONTHLY, result.getModelType());
        assertEquals(ProductCategory.S, result.getCategory());
        assertTrue(result.getDailyAvgSales().compareTo(BigDecimal.ZERO) > 0);
        assertTrue(result.getRecommendedQuantity() >= 0);
        assertTrue(result.getFinalQuantity() >= 0);
    }
    
    @Test
    public void testWeightedDailyAvgCalculation() {
        // 测试加权平均日销计算
        // 30天100件，15天60件，7天28件
        // 日均：30天=100/30=3.33, 15天=60/15=4, 7天=28/7=4
        // 加权：3.33*0.2 + 4*0.3 + 4*0.5 = 0.666 + 1.2 + 2 = 3.866
        
        SalesHistoryData salesHistory = createSalesHistory(100, 60, 28);
        
        BigDecimal weightedAvg = service.calculateWeightedDailyAvgSales(salesHistory);
        
        assertNotNull(weightedAvg);
        // 允许一定误差
        assertTrue(weightedAvg.compareTo(BigDecimal.valueOf(3.5)) > 0);
        assertTrue(weightedAvg.compareTo(BigDecimal.valueOf(4.2)) < 0);
    }
    
    @Test
    public void testSafetyStockDaysFromCategory() {
        // S类默认安全库存天数为45天
        ProductStockConfig configS = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                null, null, 500, 0, 15);
        assertEquals(45, configS.getEffectiveSafetyStockDays());
        
        // A类默认安全库存天数为35天
        ProductStockConfig configA = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 500, 0, 15);
        assertEquals(35, configA.getEffectiveSafetyStockDays());
        
        // 自定义值覆盖默认值
        ProductStockConfig configCustom = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                60, null, 500, 0, 15);
        assertEquals(60, configCustom.getEffectiveSafetyStockDays());
    }
    
    @Test
    public void testStockingCoefficientFromCategory() {
        // S类默认备货系数为1.3
        ProductStockConfig configS = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                null, null, 500, 0, 15);
        assertEquals(0, BigDecimal.valueOf(1.3).compareTo(configS.getEffectiveStockingCoefficient()));
        
        // 自定义值覆盖默认值
        ProductStockConfig configCustom = createConfig(
                ProductCategory.S, ShippingRegion.US_WEST,
                null, BigDecimal.valueOf(1.5), 500, 0, 15);
        assertEquals(0, BigDecimal.valueOf(1.5).compareTo(configCustom.getEffectiveStockingCoefficient()));
    }
    
    @Test
    public void testMinMaxOrderQuantityLimits() {
        // 测试最小/最大订货量限制
        ProductStockConfig config = createConfig(
                ProductCategory.B, ShippingRegion.US_CENTRAL,
                null, null, 5000, 0, 15); // 高库存，可能计算出负数
        config.setMinOrderQuantity(100);
        config.setMaxOrderQuantity(1000);
        
        // 低销量
        SalesHistoryData salesHistory = createSalesHistory(30, 15, 7);
        
        StockingResult result = service.calculateMonthlyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        // 由于库存充足，最终备货量应该为0
        assertEquals(0, result.getFinalQuantity().intValue());
    }
    
    @Test
    public void testShippingRegionEffect() {
        // 美东海运时间50天
        ProductStockConfig configEast = createConfig(
                ProductCategory.A, ShippingRegion.US_EAST,
                null, null, 500, 0, 15);
        assertEquals(50, configEast.getEffectiveShippingDays());
        
        // 美西海运时间35天
        ProductStockConfig configWest = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 500, 0, 15);
        assertEquals(35, configWest.getEffectiveShippingDays());
        
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        StockingResult resultEast = service.calculateMonthlyStocking(configEast, salesHistory, baseDate);
        StockingResult resultWest = service.calculateMonthlyStocking(configWest, salesHistory, baseDate);
        
        // 两者的备货量应该相同（区域只影响发货时间，不影响备货量）
        assertNotNull(resultEast);
        assertNotNull(resultWest);
        
        // 美东到货时间应该比美西晚
        assertTrue(resultEast.getExpectedArrivalDate().isAfter(resultWest.getExpectedArrivalDate()));
    }
    
    @Test
    public void testNullSalesHistory() {
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 500, 0, 15);
        
        StockingResult result = service.calculateMonthlyStocking(config, null, baseDate);
        
        assertNotNull(result);
        assertEquals(0, BigDecimal.ZERO.compareTo(result.getDailyAvgSales()));
        assertEquals(0, result.getFinalQuantity().intValue());
    }
    
    @Test
    public void testZeroSales() {
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 500, 0, 15);
        
        SalesHistoryData salesHistory = createSalesHistory(0, 0, 0);
        
        StockingResult result = service.calculateMonthlyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        assertEquals(0, BigDecimal.ZERO.compareTo(result.getDailyAvgSales()));
        assertEquals(0, result.getFinalQuantity().intValue());
    }
    
    @Test
    public void testResultDates() {
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST, // 35天海运
                null, null, 500, 0, 20); // 20天生产
        
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        StockingResult result = service.calculateMonthlyStocking(config, salesHistory, baseDate);
        
        assertNotNull(result);
        assertNotNull(result.getSuggestedShipDate());
        assertNotNull(result.getExpectedArrivalDate());
        
        // 发货日期 = 基准日期 + 生产周期
        assertEquals(baseDate.plusDays(20), result.getSuggestedShipDate());
        
        // 到货日期 = 发货日期 + 海运时间
        assertEquals(baseDate.plusDays(20 + 35), result.getExpectedArrivalDate());
    }
    
    @Test
    public void testInTransitInventoryConsidered() {
        // 测试在途库存被纳入计算
        ProductStockConfig configNoTransit = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 500, 0, 15);
        
        ProductStockConfig configWithTransit = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                null, null, 500, 1000, 15); // 增加1000在途
        
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        StockingResult resultNoTransit = service.calculateMonthlyStocking(configNoTransit, salesHistory, baseDate);
        StockingResult resultWithTransit = service.calculateMonthlyStocking(configWithTransit, salesHistory, baseDate);
        
        assertNotNull(resultNoTransit);
        assertNotNull(resultWithTransit);
        
        // 有在途库存的情况下，备货量应该更少
        assertTrue(resultWithTransit.getFinalQuantity() < resultNoTransit.getFinalQuantity());
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
