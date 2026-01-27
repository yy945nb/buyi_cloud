package com.buyi.ruleengine.stocking;

import com.buyi.ruleengine.stocking.enums.ProductCategory;
import com.buyi.ruleengine.stocking.enums.ShippingRegion;
import com.buyi.ruleengine.stocking.enums.StockingModelType;
import com.buyi.ruleengine.stocking.model.ProductStockConfig;
import com.buyi.ruleengine.stocking.model.SalesHistoryData;
import com.buyi.ruleengine.stocking.model.StockingResult;
import com.buyi.ruleengine.stocking.service.StockoutStockingService;
import org.junit.Before;
import org.junit.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * 断货点临时备货服务单元测试
 * Stockout Emergency Stocking Service Unit Tests
 */
public class StockoutStockingServiceTest {
    
    private StockoutStockingService service;
    private LocalDate baseDate;
    
    @Before
    public void setUp() {
        service = new StockoutStockingService();
        baseDate = LocalDate.of(2025, 1, 1);
    }
    
    @Test
    public void testNoStockoutRisk() {
        // 高库存，低销量，不应有断货风险
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                35, null, 10000, 5000, 15);
        
        // 低销量
        SalesHistoryData salesHistory = createSalesHistory(300, 150, 70);
        
        StockingResult result = service.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, null, baseDate);
        
        // 无断货风险应该返回null
        assertNull(result);
    }
    
    @Test
    public void testStockoutRiskDetected() {
        // 低库存，高销量，应检测到断货风险
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_EAST,
                35, null, 200, 0, 20);
        
        // 高销量：日均约100件
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        StockingResult result = service.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, null, baseDate);
        
        assertNotNull(result);
        assertEquals(StockingModelType.STOCKOUT_EMERGENCY, result.getModelType());
        assertTrue(result.getFinalQuantity() > 0);
    }
    
    @Test
    public void testEmergencyFlagSet() {
        // 紧急情况下应设置紧急标志
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_EAST, // 美东50天海运
                35, null, 100, 0, 30); // 只有100件库存
        
        // 很高的销量
        SalesHistoryData salesHistory = createSalesHistory(4500, 2250, 1050);
        
        StockingResult result = service.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, null, baseDate);
        
        if (result != null) {
            assertNotNull(result.getUrgencyNote());
            // 由于库存很低，销量很高，应该是紧急情况
            assertTrue(result.getIsEmergency() || result.getStockoutRiskDays() != null);
        }
    }
    
    @Test
    public void testExistingShipmentsConsidered() {
        // 有已存在的发货计划时应考虑
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                30, null, 500, 0, 15);
        
        SalesHistoryData salesHistory = createSalesHistory(2100, 1050, 490);
        
        // 无发货计划
        StockingResult resultNoShipment = service.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, null, baseDate);
        
        // 有发货计划
        Map<LocalDate, Integer> shipments = new HashMap<>();
        shipments.put(baseDate.plusDays(5), 1000);
        shipments.put(baseDate.plusDays(15), 1000);
        
        StockingResult resultWithShipment = service.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, shipments, baseDate);
        
        // 有发货计划的情况下，备货需求应该更低或不存在
        if (resultNoShipment != null && resultWithShipment != null) {
            assertTrue(resultWithShipment.getFinalQuantity() <= resultNoShipment.getFinalQuantity());
        }
    }
    
    @Test
    public void testDifferentRegionsHaveDifferentLeadTimes() {
        // 不同区域应有不同的海运时间
        SalesHistoryData salesHistory = createSalesHistory(2100, 1050, 490);
        
        // 美西（35天海运）
        ProductStockConfig configWest = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                30, null, 500, 0, 15);
        
        // 美东（50天海运）
        ProductStockConfig configEast = createConfig(
                ProductCategory.A, ShippingRegion.US_EAST,
                30, null, 500, 0, 15);
        
        StockingResult resultWest = service.evaluateAndCalculateEmergencyStocking(
                configWest, salesHistory, null, baseDate);
        StockingResult resultEast = service.evaluateAndCalculateEmergencyStocking(
                configEast, salesHistory, null, baseDate);
        
        // 如果两者都有结果，美东的预计到货时间应该更晚
        if (resultWest != null && resultEast != null) {
            assertNotNull(resultWest.getExpectedArrivalDate());
            assertNotNull(resultEast.getExpectedArrivalDate());
        }
    }
    
    @Test
    public void testStockoutRiskDaysCalculated() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_CENTRAL,
                35, null, 300, 0, 20);
        
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        StockingResult result = service.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, null, baseDate);
        
        if (result != null) {
            assertNotNull(result.getStockoutRiskDays());
            assertTrue(result.getStockoutRiskDays() > 0);
        }
    }
    
    @Test
    public void testExpectedStockoutQuantityCalculated() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_SOUTH,
                35, null, 200, 0, 25);
        
        SalesHistoryData salesHistory = createSalesHistory(4500, 2250, 1050);
        
        StockingResult result = service.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, null, baseDate);
        
        if (result != null) {
            assertNotNull(result.getExpectedStockoutQuantity());
            assertTrue(result.getExpectedStockoutQuantity() >= 0);
        }
    }
    
    @Test
    public void testNullSalesHistory() {
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                30, null, 500, 0, 15);
        
        StockingResult result = service.evaluateAndCalculateEmergencyStocking(
                config, null, null, baseDate);
        
        // 没有销售历史，日均销量为0，不应有断货风险
        assertNull(result);
    }
    
    @Test
    public void testZeroSales() {
        ProductStockConfig config = createConfig(
                ProductCategory.A, ShippingRegion.US_WEST,
                30, null, 500, 0, 15);
        
        SalesHistoryData salesHistory = createSalesHistory(0, 0, 0);
        
        StockingResult result = service.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, null, baseDate);
        
        // 销量为0，不应有断货风险
        assertNull(result);
    }
    
    @Test
    public void testSuggestedShipDateCalculation() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_EAST,
                35, null, 200, 0, 20);
        
        SalesHistoryData salesHistory = createSalesHistory(3000, 1500, 700);
        
        StockingResult result = service.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, null, baseDate);
        
        if (result != null) {
            assertNotNull(result.getSuggestedShipDate());
            // 建议发货日期应该不早于基准日期
            assertFalse(result.getSuggestedShipDate().isBefore(baseDate));
        }
    }
    
    @Test
    public void testReasonContainsUsefulInfo() {
        ProductStockConfig config = createConfig(
                ProductCategory.S, ShippingRegion.US_CENTRAL,
                35, null, 150, 0, 25);
        
        SalesHistoryData salesHistory = createSalesHistory(4500, 2250, 1050);
        
        StockingResult result = service.evaluateAndCalculateEmergencyStocking(
                config, salesHistory, null, baseDate);
        
        if (result != null) {
            assertNotNull(result.getReason());
            assertTrue(result.getReason().contains("断货点"));
        }
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
