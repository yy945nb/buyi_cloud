package com.buyi.datawarehouse.monitoring;

import com.buyi.datawarehouse.model.monitoring.DomesticInventoryAgg;
import com.buyi.datawarehouse.service.monitoring.DomesticInventoryService;
import org.junit.Before;
import org.junit.Test;

import java.time.LocalDate;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * 国内仓库存服务测试
 * Domestic Inventory Service Test
 */
public class DomesticInventoryServiceTest {
    
    private DomesticInventoryService service;
    
    @Before
    public void setUp() {
        service = new DomesticInventoryService();
    }
    
    @Test
    public void testQueryDomesticInventory() {
        // 测试查询国内仓库存
        LocalDate monitorDate = LocalDate.of(2024, 1, 15);
        Long companyId = 1L;
        
        Map<String, DomesticInventoryAgg> inventoryMap = 
            service.queryDomesticInventory(monitorDate, companyId);
        
        // 由于是模拟实现，返回空map
        assertNotNull(inventoryMap);
    }
    
    @Test
    public void testQueryDomesticInventoryBySku() {
        // 测试查询单个产品SKU的国内仓库存
        String productSku = "TEST-SKU-001";
        LocalDate monitorDate = LocalDate.of(2024, 1, 15);
        Long companyId = 1L;
        
        DomesticInventoryAgg inventory = 
            service.queryDomesticInventoryBySku(productSku, monitorDate, companyId);
        
        // 由于没有实际数据，应该返回零值对象
        assertNotNull(inventory);
        assertEquals(productSku, inventory.getProductSku());
        assertEquals(monitorDate, inventory.getMonitorDate());
        assertEquals(companyId, inventory.getCompanyId());
        assertEquals(Integer.valueOf(0), inventory.getRemainingQty());
        assertEquals(Integer.valueOf(0), inventory.getActualStockQty());
    }
    
    @Test
    public void testQueryDomesticInventoryWithNullCompanyId() {
        // 测试不指定公司ID的查询
        LocalDate monitorDate = LocalDate.of(2024, 1, 15);
        
        Map<String, DomesticInventoryAgg> inventoryMap = 
            service.queryDomesticInventory(monitorDate, null);
        
        assertNotNull(inventoryMap);
    }
    
    @Test
    public void testValidateDomesticInventory_Valid() {
        // 测试验证有效的库存数据
        DomesticInventoryAgg inventory = new DomesticInventoryAgg();
        inventory.setProductSku("TEST-SKU-001");
        inventory.setRemainingQty(1000);
        inventory.setActualStockQty(800);
        
        boolean isValid = service.validateDomesticInventory(inventory);
        
        assertTrue(isValid);
    }
    
    @Test
    public void testValidateDomesticInventory_NullObject() {
        // 测试验证null对象
        boolean isValid = service.validateDomesticInventory(null);
        
        assertFalse(isValid);
    }
    
    @Test
    public void testValidateDomesticInventory_MissingProductSku() {
        // 测试验证缺少产品SKU的数据
        DomesticInventoryAgg inventory = new DomesticInventoryAgg();
        inventory.setRemainingQty(1000);
        inventory.setActualStockQty(800);
        
        boolean isValid = service.validateDomesticInventory(inventory);
        
        assertFalse(isValid);
    }
    
    @Test
    public void testValidateDomesticInventory_EmptyProductSku() {
        // 测试验证空字符串产品SKU的数据
        DomesticInventoryAgg inventory = new DomesticInventoryAgg();
        inventory.setProductSku("");
        inventory.setRemainingQty(1000);
        inventory.setActualStockQty(800);
        
        boolean isValid = service.validateDomesticInventory(inventory);
        
        assertFalse(isValid);
    }
    
    @Test
    public void testValidateDomesticInventory_NegativeQuantity() {
        // 测试验证负数库存的数据
        DomesticInventoryAgg inventory = new DomesticInventoryAgg();
        inventory.setProductSku("TEST-SKU-001");
        inventory.setRemainingQty(-100);
        inventory.setActualStockQty(800);
        
        boolean isValid = service.validateDomesticInventory(inventory);
        
        assertFalse(isValid);
    }
    
    @Test
    public void testDomesticInventoryAgg_DefaultValues() {
        // 测试DomesticInventoryAgg的默认值
        DomesticInventoryAgg inventory = new DomesticInventoryAgg();
        
        assertEquals(Integer.valueOf(0), inventory.getRemainingQty());
        assertEquals(Integer.valueOf(0), inventory.getActualStockQty());
    }
    
    @Test
    public void testDomesticInventoryAgg_SettersAndGetters() {
        // 测试DomesticInventoryAgg的getter和setter
        DomesticInventoryAgg inventory = new DomesticInventoryAgg();
        
        String productSku = "TEST-SKU-001";
        String localSku = "LOCAL-SKU-001";
        Long companyId = 1L;
        Integer remainingQty = 1000;
        Integer actualStockQty = 800;
        LocalDate syncDate = LocalDate.of(2024, 1, 14);
        LocalDate monitorDate = LocalDate.of(2024, 1, 15);
        
        inventory.setProductSku(productSku);
        inventory.setLocalSku(localSku);
        inventory.setCompanyId(companyId);
        inventory.setRemainingQty(remainingQty);
        inventory.setActualStockQty(actualStockQty);
        inventory.setSyncDate(syncDate);
        inventory.setMonitorDate(monitorDate);
        
        assertEquals(productSku, inventory.getProductSku());
        assertEquals(localSku, inventory.getLocalSku());
        assertEquals(companyId, inventory.getCompanyId());
        assertEquals(remainingQty, inventory.getRemainingQty());
        assertEquals(actualStockQty, inventory.getActualStockQty());
        assertEquals(syncDate, inventory.getSyncDate());
        assertEquals(monitorDate, inventory.getMonitorDate());
    }
    
    @Test
    public void testDomesticInventoryAgg_ToString() {
        // 测试DomesticInventoryAgg的toString方法
        DomesticInventoryAgg inventory = new DomesticInventoryAgg();
        inventory.setProductSku("TEST-SKU-001");
        inventory.setLocalSku("LOCAL-SKU-001");
        inventory.setCompanyId(1L);
        inventory.setRemainingQty(1000);
        inventory.setActualStockQty(800);
        
        String result = inventory.toString();
        
        assertTrue(result.contains("TEST-SKU-001"));
        assertTrue(result.contains("LOCAL-SKU-001"));
        assertTrue(result.contains("1000"));
        assertTrue(result.contains("800"));
    }
}
