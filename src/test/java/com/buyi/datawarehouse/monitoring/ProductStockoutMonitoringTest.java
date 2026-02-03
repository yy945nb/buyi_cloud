package com.buyi.datawarehouse.monitoring;

import com.buyi.datawarehouse.enums.BusinessMode;
import com.buyi.datawarehouse.enums.RiskLevel;
import com.buyi.datawarehouse.model.monitoring.ProductStockoutMonitoring;
import org.junit.Before;
import org.junit.Test;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.Assert.*;

/**
 * 产品断货点监控模型测试
 * Product Stockout Monitoring Model Test
 */
public class ProductStockoutMonitoringTest {
    
    private ProductStockoutMonitoring monitoring;
    
    @Before
    public void setUp() {
        monitoring = new ProductStockoutMonitoring();
        monitoring.setProductId(1001L);
        monitoring.setProductSku("TEST-SKU-001");
        monitoring.setProductName("测试产品");
        monitoring.setRegionalWarehouseId(1L);
        monitoring.setRegionalWarehouseCode("RW_US_WEST");
        monitoring.setBusinessMode(BusinessMode.JH_LX);
        monitoring.setSnapshotDate(LocalDate.of(2024, 1, 15));
    }
    
    @Test
    public void testCalculateTotalInventory() {
        // 测试总库存计算
        monitoring.setOverseasInventory(1000);
        monitoring.setInTransitInventory(500);
        
        monitoring.calculateTotalInventory();
        
        assertEquals(Integer.valueOf(1500), monitoring.getTotalInventory());
    }
    
    @Test
    public void testCalculateTotalInventoryWithNulls() {
        // 测试null值处理
        monitoring.setOverseasInventory(null);
        monitoring.setInTransitInventory(null);
        
        monitoring.calculateTotalInventory();
        
        assertEquals(Integer.valueOf(0), monitoring.getTotalInventory());
    }
    
    @Test
    public void testCalculateRegionalDailySales() {
        // 测试区域日均销量计算
        monitoring.setDailyAvgSales(new BigDecimal("100.0000"));
        monitoring.setRegionalProportion(new BigDecimal("0.3000"));
        
        monitoring.calculateRegionalDailySales();
        
        assertEquals(new BigDecimal("30.0000"), monitoring.getRegionalDailySales());
    }
    
    @Test
    public void testCalculateStockoutMetrics_NormalCase() {
        // 测试正常情况下的断货点计算
        monitoring.setAvailableInventory(3000);
        monitoring.setDailyAvgSales(new BigDecimal("100.0000"));
        monitoring.setRegionalProportion(new BigDecimal("0.2000"));
        monitoring.setSafetyStockDays(30);
        monitoring.setStockingCycleDays(30);
        monitoring.setShippingDays(45);
        monitoring.setLeadTimeDays(75);
        
        monitoring.calculateRegionalDailySales();
        monitoring.calculateStockoutMetrics();
        
        // 区域日均销量 = 100 * 0.2 = 20
        assertEquals(new BigDecimal("20.0000"), monitoring.getRegionalDailySales());
        
        // 断货点 = 20 * 75 = 1500
        assertEquals(Integer.valueOf(1500), monitoring.getStockoutPoint());
        
        // 安全库存数量 = 20 * 30 = 600
        assertEquals(Integer.valueOf(600), monitoring.getSafetyStockQuantity());
        
        // 可售天数 = 3000 / 20 = 150
        assertEquals(new BigDecimal("150.00"), monitoring.getAvailableDays());
        
        // 断货风险天数 = 150 - (75 + 30) = 45
        assertEquals(Integer.valueOf(45), monitoring.getStockoutRiskDays());
        
        // 无断货风险
        assertFalse(monitoring.getIsStockoutRisk());
        
        // 风险等级为SAFE
        assertEquals(RiskLevel.SAFE, monitoring.getRiskLevel());
    }
    
    @Test
    public void testCalculateStockoutMetrics_WarningCase() {
        // 测试预警情况
        monitoring.setAvailableInventory(400);
        monitoring.setDailyAvgSales(new BigDecimal("100.0000"));
        monitoring.setRegionalProportion(new BigDecimal("0.2000"));
        monitoring.setSafetyStockDays(30);
        monitoring.setStockingCycleDays(30);
        monitoring.setShippingDays(45);
        monitoring.setLeadTimeDays(75);
        
        monitoring.calculateRegionalDailySales();
        monitoring.calculateStockoutMetrics();
        
        // 可售天数 = 400 / 20 = 20
        assertEquals(new BigDecimal("20.00"), monitoring.getAvailableDays());
        
        // 断货风险天数 = 20 - 105 = -85
        assertEquals(Integer.valueOf(-85), monitoring.getStockoutRiskDays());
        
        // 有断货风险
        assertTrue(monitoring.getIsStockoutRisk());
        
        // 风险等级为WARNING (20天 < 30天安全库存)
        assertEquals(RiskLevel.WARNING, monitoring.getRiskLevel());
    }
    
    @Test
    public void testCalculateStockoutMetrics_DangerCase() {
        // 测试危险情况
        monitoring.setAvailableInventory(200);
        monitoring.setDailyAvgSales(new BigDecimal("100.0000"));
        monitoring.setRegionalProportion(new BigDecimal("0.2000"));
        monitoring.setSafetyStockDays(30);
        
        monitoring.calculateRegionalDailySales();
        monitoring.calculateStockoutMetrics();
        
        // 可售天数 = 200 / 20 = 10
        assertEquals(new BigDecimal("10.00"), monitoring.getAvailableDays());
        
        // 风险等级为DANGER (10天 < 15天，即安全库存的一半)
        assertEquals(RiskLevel.DANGER, monitoring.getRiskLevel());
    }
    
    @Test
    public void testCalculateStockoutMetrics_StockoutCase() {
        // 测试已断货情况
        monitoring.setAvailableInventory(0);
        monitoring.setDailyAvgSales(new BigDecimal("100.0000"));
        monitoring.setRegionalProportion(new BigDecimal("0.2000"));
        monitoring.setSafetyStockDays(30);
        
        monitoring.calculateRegionalDailySales();
        monitoring.calculateStockoutMetrics();
        
        // 可售天数 = 0
        assertEquals(new BigDecimal("0.00"), monitoring.getAvailableDays());
        
        // 风险等级为STOCKOUT
        assertEquals(RiskLevel.STOCKOUT, monitoring.getRiskLevel());
    }
    
    @Test
    public void testCalculateStockoutMetrics_ZeroSales() {
        // 测试零销量情况
        monitoring.setAvailableInventory(1000);
        monitoring.setDailyAvgSales(BigDecimal.ZERO);
        monitoring.setRegionalProportion(new BigDecimal("0.2000"));
        monitoring.setSafetyStockDays(30);
        
        monitoring.calculateRegionalDailySales();
        monitoring.calculateStockoutMetrics();
        
        // 零销量时，可售天数应该为999
        assertEquals(new BigDecimal("999"), monitoring.getAvailableDays());
        
        // 无断货风险
        assertFalse(monitoring.getIsStockoutRisk());
        
        // 风险等级为SAFE
        assertEquals(RiskLevel.SAFE, monitoring.getRiskLevel());
    }
    
    @Test
    public void testDefaultValues() {
        // 测试默认值
        ProductStockoutMonitoring newMonitoring = new ProductStockoutMonitoring();
        
        assertEquals(Integer.valueOf(0), newMonitoring.getOverseasInventory());
        assertEquals(Integer.valueOf(0), newMonitoring.getInTransitInventory());
        assertEquals(Integer.valueOf(0), newMonitoring.getTotalInventory());
        assertEquals(Integer.valueOf(0), newMonitoring.getAvailableInventory());
        assertEquals(BigDecimal.ZERO, newMonitoring.getDailyAvgSales());
        assertEquals(BigDecimal.ZERO, newMonitoring.getRegionalProportion());
        assertEquals(BigDecimal.ZERO, newMonitoring.getRegionalDailySales());
        assertFalse(newMonitoring.getIsStockoutRisk());
        assertEquals(RiskLevel.SAFE, newMonitoring.getRiskLevel());
        assertEquals(Integer.valueOf(0), newMonitoring.getPendingOrderQuantity());
    }
    
    @Test
    public void testToString() {
        // 测试toString方法
        monitoring.setTotalInventory(1500);
        monitoring.setDailyAvgSales(new BigDecimal("50.0000"));
        monitoring.setRegionalProportion(new BigDecimal("0.3000"));
        monitoring.calculateRegionalDailySales();
        monitoring.setAvailableDays(new BigDecimal("100.00"));
        monitoring.setRiskLevel(RiskLevel.SAFE);
        
        String result = monitoring.toString();
        
        assertTrue(result.contains("TEST-SKU-001"));
        assertTrue(result.contains("RW_US_WEST"));
        assertTrue(result.contains("JH_LX"));
        assertTrue(result.contains("SAFE"));
    }
}
