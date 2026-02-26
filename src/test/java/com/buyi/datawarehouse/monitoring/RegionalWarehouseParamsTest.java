package com.buyi.datawarehouse.monitoring;

import com.buyi.datawarehouse.model.monitoring.RegionalWarehouseParams;
import org.junit.Test;

import static org.junit.Assert.*;

/**
 * 区域仓参数模型测试
 * Regional Warehouse Parameters Model Test
 */
public class RegionalWarehouseParamsTest {
    
    @Test
    public void testDefaultValues() {
        // 测试默认值
        RegionalWarehouseParams params = new RegionalWarehouseParams();
        
        assertEquals(Integer.valueOf(30), params.getSafetyStockDays());
        assertEquals(Integer.valueOf(30), params.getStockingCycleDays());
        assertEquals(Integer.valueOf(45), params.getShippingDays());
        assertEquals(Integer.valueOf(0), params.getProductionDays());
        assertEquals(Integer.valueOf(75), params.getLeadTimeDays());
    }
    
    @Test
    public void testCalculateLeadTime() {
        // 测试计算总提前期
        RegionalWarehouseParams params = new RegionalWarehouseParams();
        params.setStockingCycleDays(30);
        params.setShippingDays(45);
        
        params.calculateLeadTime();
        
        assertEquals(Integer.valueOf(75), params.getLeadTimeDays());
    }
    
    @Test
    public void testCalculateLeadTime_DifferentValues() {
        // 测试不同值的总提前期计算
        RegionalWarehouseParams params = new RegionalWarehouseParams();
        params.setStockingCycleDays(25);
        params.setShippingDays(50);
        
        params.calculateLeadTime();
        
        assertEquals(Integer.valueOf(75), params.getLeadTimeDays());
    }
    
    @Test
    public void testCalculateLeadTime_WithNullValues() {
        // 测试null值的总提前期计算
        RegionalWarehouseParams params = new RegionalWarehouseParams();
        params.setStockingCycleDays(null);
        params.setShippingDays(null);
        
        params.calculateLeadTime();
        
        assertEquals(Integer.valueOf(0), params.getLeadTimeDays());
    }
    
    @Test
    public void testSettersAndGetters() {
        // 测试getter和setter
        RegionalWarehouseParams params = new RegionalWarehouseParams();
        
        Long regionalWarehouseId = 1L;
        String regionalWarehouseCode = "RW_US_WEST";
        String regionalWarehouseName = "美西区域仓";
        Integer safetyStockDays = 35;
        Integer stockingCycleDays = 28;
        Integer shippingDays = 40;
        Integer productionDays = 5;
        
        params.setRegionalWarehouseId(regionalWarehouseId);
        params.setRegionalWarehouseCode(regionalWarehouseCode);
        params.setRegionalWarehouseName(regionalWarehouseName);
        params.setSafetyStockDays(safetyStockDays);
        params.setStockingCycleDays(stockingCycleDays);
        params.setShippingDays(shippingDays);
        params.setProductionDays(productionDays);
        
        assertEquals(regionalWarehouseId, params.getRegionalWarehouseId());
        assertEquals(regionalWarehouseCode, params.getRegionalWarehouseCode());
        assertEquals(regionalWarehouseName, params.getRegionalWarehouseName());
        assertEquals(safetyStockDays, params.getSafetyStockDays());
        assertEquals(stockingCycleDays, params.getStockingCycleDays());
        assertEquals(shippingDays, params.getShippingDays());
        assertEquals(productionDays, params.getProductionDays());
    }
    
    @Test
    public void testToString() {
        // 测试toString方法
        RegionalWarehouseParams params = new RegionalWarehouseParams();
        params.setRegionalWarehouseId(1L);
        params.setRegionalWarehouseCode("RW_US_WEST");
        params.setRegionalWarehouseName("美西区域仓");
        params.setSafetyStockDays(35);
        params.setShippingDays(40);
        
        String result = params.toString();
        
        assertTrue(result.contains("RW_US_WEST"));
        assertTrue(result.contains("美西区域仓"));
        assertTrue(result.contains("35"));
        assertTrue(result.contains("40"));
    }
    
    @Test
    public void testUSWestParameters() {
        // 测试美西区域仓参数
        RegionalWarehouseParams params = new RegionalWarehouseParams();
        params.setRegionalWarehouseCode("RW_US_WEST");
        params.setStockingCycleDays(30);
        params.setShippingDays(35);
        params.calculateLeadTime();
        
        assertEquals(Integer.valueOf(65), params.getLeadTimeDays());
    }
    
    @Test
    public void testUSEastParameters() {
        // 测试美东区域仓参数
        RegionalWarehouseParams params = new RegionalWarehouseParams();
        params.setRegionalWarehouseCode("RW_US_EAST");
        params.setStockingCycleDays(30);
        params.setShippingDays(50);
        params.calculateLeadTime();
        
        assertEquals(Integer.valueOf(80), params.getLeadTimeDays());
    }
    
    @Test
    public void testUSCentralParameters() {
        // 测试美中区域仓参数
        RegionalWarehouseParams params = new RegionalWarehouseParams();
        params.setRegionalWarehouseCode("RW_US_CENTRAL");
        params.setStockingCycleDays(30);
        params.setShippingDays(45);
        params.calculateLeadTime();
        
        assertEquals(Integer.valueOf(75), params.getLeadTimeDays());
    }
    
    @Test
    public void testUSSouthParameters() {
        // 测试美南区域仓参数
        RegionalWarehouseParams params = new RegionalWarehouseParams();
        params.setRegionalWarehouseCode("RW_US_SOUTH");
        params.setStockingCycleDays(30);
        params.setShippingDays(48);
        params.calculateLeadTime();
        
        assertEquals(Integer.valueOf(78), params.getLeadTimeDays());
    }
}
