package com.buyi.datawarehouse;

import com.buyi.datawarehouse.config.DataWarehouseConfig;
import com.buyi.datawarehouse.model.dimension.*;
import com.buyi.datawarehouse.model.fact.*;
import com.buyi.datawarehouse.model.aggregate.*;
import org.junit.Test;
import org.junit.Before;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.junit.Assert.*;

/**
 * 数据仓库模型测试类
 * Data Warehouse Model Tests
 */
public class DataWarehouseModelTest {
    
    // ============ 维度模型测试 ============
    
    @Test
    public void testDimDateFromDate() {
        LocalDate testDate = LocalDate.of(2024, 6, 17); // Monday
        DimDate dimDate = DimDate.fromDate(testDate);
        
        assertNotNull(dimDate);
        assertEquals(Integer.valueOf(20240617), dimDate.getDateKey());
        assertEquals(testDate, dimDate.getFullDate());
        assertEquals(Integer.valueOf(2024), dimDate.getYear());
        assertEquals(Integer.valueOf(2), dimDate.getQuarter()); // June is Q2
        assertEquals(Integer.valueOf(6), dimDate.getMonth());
        assertEquals(Integer.valueOf(17), dimDate.getDayOfMonth());
        assertFalse(dimDate.getIsWeekend()); // June 17, 2024 is Monday
        assertEquals("2024-06", dimDate.getYearMonth());
        assertEquals("2024-Q2", dimDate.getYearQuarter());
    }
    
    @Test
    public void testDimDateWeekend() {
        // Saturday
        LocalDate saturday = LocalDate.of(2024, 6, 15);
        DimDate saturdayDim = DimDate.fromDate(saturday);
        assertTrue(saturdayDim.getIsWeekend());
        
        // Sunday
        LocalDate sunday = LocalDate.of(2024, 6, 16);
        DimDate sundayDim = DimDate.fromDate(sunday);
        assertTrue(sundayDim.getIsWeekend());
        
        // Monday
        LocalDate monday = LocalDate.of(2024, 6, 17);
        DimDate mondayDim = DimDate.fromDate(monday);
        assertFalse(mondayDim.getIsWeekend());
    }
    
    @Test
    public void testDimDateGenerateRange() {
        LocalDate start = LocalDate.of(2024, 1, 1);
        LocalDate end = LocalDate.of(2024, 1, 10);
        
        DimDate[] dates = DimDate.generateDateRange(start, end);
        
        assertEquals(10, dates.length);
        assertEquals(Integer.valueOf(20240101), dates[0].getDateKey());
        assertEquals(Integer.valueOf(20240110), dates[9].getDateKey());
    }
    
    @Test
    public void testDimDateQuarters() {
        // Q1: January
        assertEquals(Integer.valueOf(1), DimDate.fromDate(LocalDate.of(2024, 1, 15)).getQuarter());
        // Q2: April
        assertEquals(Integer.valueOf(2), DimDate.fromDate(LocalDate.of(2024, 4, 15)).getQuarter());
        // Q3: July
        assertEquals(Integer.valueOf(3), DimDate.fromDate(LocalDate.of(2024, 7, 15)).getQuarter());
        // Q4: October
        assertEquals(Integer.valueOf(4), DimDate.fromDate(LocalDate.of(2024, 10, 15)).getQuarter());
    }
    
    @Test
    public void testDimProductSCDType2() {
        DimProduct product = new DimProduct();
        product.setProductId(1001L);
        product.setSkuCode("SKU-001");
        product.setProductName("Test Product");
        product.setStatus("ACTIVE");
        
        assertTrue(product.getIsCurrent());
        assertEquals(LocalDate.of(9999, 12, 31), product.getExpiryDate());
        
        // Create new version
        DimProduct newVersion = product.createNewVersion();
        newVersion.setProductName("Updated Product");
        
        assertTrue(newVersion.getIsCurrent());
        assertEquals(product.getProductId(), newVersion.getProductId());
        
        // Expire old version
        product.expire();
        assertFalse(product.getIsCurrent());
        assertNotEquals(LocalDate.of(9999, 12, 31), product.getExpiryDate());
    }
    
    @Test
    public void testDimShopSCDType2() {
        DimShop shop = new DimShop();
        shop.setShopId(2001L);
        shop.setShopCode("SHOP-001");
        shop.setShopName("Test Shop");
        shop.setPlatform("Amazon");
        shop.setMarketplace("US");
        
        assertTrue(shop.getIsCurrent());
        
        // Create new version
        DimShop newVersion = shop.createNewVersion();
        newVersion.setShopName("Updated Shop");
        
        assertTrue(newVersion.getIsCurrent());
        assertEquals(shop.getShopId(), newVersion.getShopId());
        assertEquals("Amazon", newVersion.getPlatform());
    }
    
    @Test
    public void testDimWarehouseSCDType2() {
        DimWarehouse warehouse = new DimWarehouse();
        warehouse.setWarehouseId(3001L);
        warehouse.setWarehouseCode("WH-001");
        warehouse.setWarehouseName("FBA Warehouse");
        warehouse.setWarehouseType("FBA");
        warehouse.setCountry("US");
        
        assertTrue(warehouse.getIsCurrent());
        
        warehouse.expire();
        assertFalse(warehouse.getIsCurrent());
    }
    
    // ============ 事实表模型测试 ============
    
    @Test
    public void testFactSalesCalculations() {
        FactSales sales = new FactSales();
        sales.setQuantity(10);
        sales.setUnitPrice(new BigDecimal("99.99"));
        sales.setGrossAmount(new BigDecimal("999.90"));
        sales.setDiscountAmount(new BigDecimal("99.90"));
        sales.setCostAmount(new BigDecimal("600.00"));
        sales.setShippingFee(new BigDecimal("50.00"));
        sales.setPlatformFee(new BigDecimal("100.00"));
        
        // Calculate net amount
        sales.calculateNetAmount();
        assertEquals(new BigDecimal("900.00"), sales.getNetAmount());
        
        // Calculate profit
        sales.calculateProfit();
        // Profit = NetAmount - Cost - Shipping - Platform = 900 - 600 - 50 - 100 = 150
        assertEquals(new BigDecimal("150.00"), sales.getProfitAmount());
    }
    
    @Test
    public void testFactSalesDefaultValues() {
        FactSales sales = new FactSales();
        
        assertEquals(BigDecimal.ZERO, sales.getDiscountAmount());
        assertEquals(BigDecimal.ZERO, sales.getShippingFee());
        assertEquals(BigDecimal.ZERO, sales.getPlatformFee());
    }
    
    @Test
    public void testFactInventoryCalculations() {
        FactInventory inventory = new FactInventory();
        inventory.setOnHandQuantity(100);
        inventory.setReservedQuantity(20);
        inventory.setUnitCost(new BigDecimal("50.00"));
        
        // Calculate available quantity
        inventory.calculateAvailableQuantity();
        assertEquals(Integer.valueOf(80), inventory.getAvailableQuantity());
        
        // Calculate inventory value
        inventory.calculateInventoryValue();
        assertEquals(new BigDecimal("5000.00"), inventory.getInventoryValue());
        
        // Calculate days of supply
        inventory.calculateDaysOfSupply(10.0); // 10 units per day
        assertEquals(Integer.valueOf(8), inventory.getDaysOfSupply()); // 80 / 10 = 8
    }
    
    @Test
    public void testFactInventoryDefaultValues() {
        FactInventory inventory = new FactInventory();
        
        assertEquals(Integer.valueOf(0), inventory.getOnHandQuantity());
        assertEquals(Integer.valueOf(0), inventory.getAvailableQuantity());
        assertEquals(Integer.valueOf(0), inventory.getReservedQuantity());
    }
    
    @Test
    public void testFactPurchaseCalculations() {
        FactPurchase purchase = new FactPurchase();
        purchase.setQuantity(50);
        purchase.setUnitCost(new BigDecimal("30.00"));
        purchase.setFreightCost(new BigDecimal("100.00"));
        purchase.setOtherCost(new BigDecimal("50.00"));
        
        // Calculate total cost
        purchase.calculateTotalCost();
        // Total = (50 * 30) + 100 + 50 = 1500 + 150 = 1650
        assertEquals(new BigDecimal("1650.00"), purchase.getTotalCost());
    }
    
    // ============ 聚合表模型测试 ============
    
    @Test
    public void testAggSalesDailyCalculations() {
        AggSalesDaily agg = new AggSalesDaily();
        agg.setOrderCount(50);
        agg.setQuantitySold(200);
        agg.setNetAmount(new BigDecimal("10000.00"));
        agg.setProfitAmount(new BigDecimal("3000.00"));
        
        agg.calculateDerivedMetrics();
        
        // Profit rate = 3000 / 10000 * 100 = 30%
        assertEquals(new BigDecimal("30.00"), agg.getProfitRate());
        
        // Avg order value = 10000 / 50 = 200
        assertEquals(new BigDecimal("200.00"), agg.getAvgOrderValue());
    }
    
    @Test
    public void testAggSalesDailyZeroOrderCount() {
        AggSalesDaily agg = new AggSalesDaily();
        agg.setOrderCount(0);
        agg.setNetAmount(new BigDecimal("0.00"));
        agg.setProfitAmount(new BigDecimal("0.00"));
        
        agg.calculateDerivedMetrics();
        
        // Should not throw exception, profit rate remains 0
        assertEquals(BigDecimal.ZERO, agg.getProfitRate());
        assertEquals(BigDecimal.ZERO, agg.getAvgOrderValue());
    }
    
    @Test
    public void testAggSalesMonthlyCalculations() {
        AggSalesMonthly agg = new AggSalesMonthly();
        agg.setYear(2024);
        agg.setMonth(6);
        agg.setNetAmount(new BigDecimal("30000.00"));
        agg.setProfitAmount(new BigDecimal("9000.00"));
        
        agg.calculateProfitRate();
        assertEquals(new BigDecimal("30.00"), agg.getProfitRate());
        
        // Calculate avg daily sales for June (30 days)
        agg.calculateAvgDailySales(30);
        assertEquals(new BigDecimal("1000.00"), agg.getAvgDailySales());
        
        // Calculate MoM growth rate
        BigDecimal previousMonth = new BigDecimal("25000.00");
        agg.calculateMomGrowthRate(previousMonth);
        // Growth = (30000 - 25000) / 25000 * 100 = 20%
        assertEquals(new BigDecimal("20.00"), agg.getMomGrowthRate());
        
        // Calculate YoY growth rate
        BigDecimal lastYear = new BigDecimal("24000.00");
        agg.calculateYoyGrowthRate(lastYear);
        // Growth = (30000 - 24000) / 24000 * 100 = 25%
        assertEquals(new BigDecimal("25.00"), agg.getYoyGrowthRate());
    }
    
    @Test
    public void testAggSalesMonthlyNegativeGrowth() {
        AggSalesMonthly agg = new AggSalesMonthly();
        agg.setNetAmount(new BigDecimal("20000.00"));
        
        // Calculate MoM with decrease
        BigDecimal previousMonth = new BigDecimal("25000.00");
        agg.calculateMomGrowthRate(previousMonth);
        // Growth = (20000 - 25000) / 25000 * 100 = -20%
        assertEquals(new BigDecimal("-20.00"), agg.getMomGrowthRate());
    }
    
    // ============ 配置测试 ============
    
    @Test
    public void testDataWarehouseConfigBuilder() {
        DataWarehouseConfig config = DataWarehouseConfig.builder()
                .sourceUrl("jdbc:mysql://localhost:3306/source")
                .sourceUser("sourceUser")
                .sourcePassword("sourcePass")
                .targetUrl("jdbc:mysql://localhost:3306/target")
                .targetUser("targetUser")
                .targetPassword("targetPass")
                .etlBatchSize(500)
                .syncIntervalMinutes(15)
                .incrementalSyncEnabled(false)
                .parallelThreads(8)
                .dataRetentionDays(180)
                .build();
        
        assertEquals("jdbc:mysql://localhost:3306/source", config.getSourceJdbcUrl());
        assertEquals("sourceUser", config.getSourceUsername());
        assertEquals("jdbc:mysql://localhost:3306/target", config.getTargetJdbcUrl());
        assertEquals("targetUser", config.getTargetUsername());
        assertEquals(500, config.getEtlBatchSize());
        assertEquals(15, config.getSyncIntervalMinutes());
        assertFalse(config.isIncrementalSyncEnabled());
        assertEquals(8, config.getParallelThreads());
        assertEquals(180, config.getDataRetentionDays());
    }
    
    @Test
    public void testDataWarehouseConfigDefaults() {
        DataWarehouseConfig config = new DataWarehouseConfig();
        
        assertEquals(1000, config.getEtlBatchSize());
        assertEquals(30, config.getSyncIntervalMinutes());
        assertTrue(config.isIncrementalSyncEnabled());
        assertEquals(4, config.getParallelThreads());
        assertEquals(365, config.getDataRetentionDays());
    }
}
