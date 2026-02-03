package com.buyi.datawarehouse.monitoring;

import com.buyi.datawarehouse.enums.BusinessMode;
import com.buyi.datawarehouse.model.monitoring.InTransitInventoryAgg;
import com.buyi.datawarehouse.service.monitoring.InTransitInventoryService;
import org.junit.Before;
import org.junit.Test;

import java.time.LocalDate;
import java.util.*;

import static org.junit.Assert.*;

/**
 * 在途库存聚合服务测试
 * In-Transit Inventory Aggregation Service Test
 */
public class InTransitInventoryServiceTest {
    
    private InTransitInventoryService service;
    
    @Before
    public void setUp() {
        service = new InTransitInventoryService();
    }
    
    @Test
    public void testAggregateByRegionalWarehouse() {
        // 准备测试数据
        List<InTransitInventoryAgg> warehouseInventories = new ArrayList<>();
        
        // 仓库101的JH在途库存
        InTransitInventoryAgg inv1 = new InTransitInventoryAgg(
                1001L, "SKU-001", 101L, "WH_US_WEST_JH", BusinessMode.JH, 500);
        warehouseInventories.add(inv1);
        
        // 仓库102的LX在途库存
        InTransitInventoryAgg inv2 = new InTransitInventoryAgg(
                1001L, "SKU-001", 102L, "WH_US_WEST_LX", BusinessMode.LX, 300);
        warehouseInventories.add(inv2);
        
        // 仓库103的FBA在途库存
        InTransitInventoryAgg inv3 = new InTransitInventoryAgg(
                1001L, "SKU-001", 103L, "WH_US_WEST_FBA", BusinessMode.FBA, 200);
        warehouseInventories.add(inv3);
        
        // 区域仓绑定关系：所有仓库都绑定到区域仓1
        Map<Long, Long> bindings = new HashMap<>();
        bindings.put(101L, 1L); // WH_US_WEST_JH -> 区域仓1
        bindings.put(102L, 1L); // WH_US_WEST_LX -> 区域仓1
        bindings.put(103L, 1L); // WH_US_WEST_FBA -> 区域仓1
        
        // 执行聚合
        Map<String, InTransitInventoryAgg> result = service.aggregateByRegionalWarehouse(
                warehouseInventories, bindings);
        
        // 验证结果
        assertNotNull(result);
        assertEquals(3, result.size()); // 应该有3条记录：JH、LX、FBA各一条
        
        // 验证每个业务模式的在途库存
        boolean hasJH = false, hasLX = false, hasFBA = false;
        for (InTransitInventoryAgg agg : result.values()) {
            assertEquals("SKU-001", agg.getProductSku());
            assertEquals(Long.valueOf(1L), agg.getWarehouseId()); // 区域仓ID
            
            if (agg.getBusinessMode() == BusinessMode.JH) {
                assertEquals(Integer.valueOf(500), agg.getInTransitQuantity());
                hasJH = true;
            } else if (agg.getBusinessMode() == BusinessMode.LX) {
                assertEquals(Integer.valueOf(300), agg.getInTransitQuantity());
                hasLX = true;
            } else if (agg.getBusinessMode() == BusinessMode.FBA) {
                assertEquals(Integer.valueOf(200), agg.getInTransitQuantity());
                hasFBA = true;
            }
        }
        
        assertTrue("应该包含JH模式", hasJH);
        assertTrue("应该包含LX模式", hasLX);
        assertTrue("应该包含FBA模式", hasFBA);
    }
    
    @Test
    public void testAggregateByRegionalWarehouse_MultipleWarehouses() {
        // 测试多个仓库聚合到同一个区域仓的情况
        List<InTransitInventoryAgg> warehouseInventories = new ArrayList<>();
        
        // 仓库101的JH在途库存
        InTransitInventoryAgg inv1 = new InTransitInventoryAgg(
                1001L, "SKU-001", 101L, "WH_US_WEST_JH_1", BusinessMode.JH, 500);
        warehouseInventories.add(inv1);
        
        // 仓库104的JH在途库存（另一个JH仓库）
        InTransitInventoryAgg inv2 = new InTransitInventoryAgg(
                1001L, "SKU-001", 104L, "WH_US_WEST_JH_2", BusinessMode.JH, 300);
        warehouseInventories.add(inv2);
        
        // 区域仓绑定关系
        Map<Long, Long> bindings = new HashMap<>();
        bindings.put(101L, 1L);
        bindings.put(104L, 1L);
        
        // 执行聚合
        Map<String, InTransitInventoryAgg> result = service.aggregateByRegionalWarehouse(
                warehouseInventories, bindings);
        
        // 验证结果：两个JH仓库应该合并成一条记录
        assertEquals(1, result.size());
        
        InTransitInventoryAgg agg = result.values().iterator().next();
        assertEquals(BusinessMode.JH, agg.getBusinessMode());
        assertEquals(Integer.valueOf(800), agg.getInTransitQuantity()); // 500 + 300
    }
    
    @Test
    public void testMergeByBusinessMode() {
        // 准备测试数据
        List<InTransitInventoryAgg> inventories = new ArrayList<>();
        
        // JH模式
        InTransitInventoryAgg inv1 = new InTransitInventoryAgg(
                1001L, "SKU-001", 1L, "RW_US_WEST", BusinessMode.JH, 500);
        inventories.add(inv1);
        
        // LX模式
        InTransitInventoryAgg inv2 = new InTransitInventoryAgg(
                1001L, "SKU-001", 1L, "RW_US_WEST", BusinessMode.LX, 300);
        inventories.add(inv2);
        
        // FBA模式
        InTransitInventoryAgg inv3 = new InTransitInventoryAgg(
                1001L, "SKU-001", 1L, "RW_US_WEST", BusinessMode.FBA, 200);
        inventories.add(inv3);
        
        // 执行合并
        Map<String, InTransitInventoryAgg> result = service.mergeByBusinessMode(inventories);
        
        // 验证结果
        assertNotNull(result);
        assertEquals(2, result.size()); // JH+LX合并为1条，FBA单独1条
        
        // 验证合并结果
        boolean hasJHLX = false, hasFBA = false;
        for (InTransitInventoryAgg agg : result.values()) {
            if (agg.getBusinessMode() == BusinessMode.JH_LX) {
                assertEquals(Integer.valueOf(800), agg.getInTransitQuantity()); // 500 + 300
                hasJHLX = true;
            } else if (agg.getBusinessMode() == BusinessMode.FBA) {
                assertEquals(Integer.valueOf(200), agg.getInTransitQuantity());
                hasFBA = true;
            }
        }
        
        assertTrue("应该包含JH_LX合并模式", hasJHLX);
        assertTrue("应该包含FBA模式", hasFBA);
    }
    
    @Test
    public void testMergeByBusinessMode_OnlyJH() {
        // 测试仅有JH模式的情况
        List<InTransitInventoryAgg> inventories = new ArrayList<>();
        
        InTransitInventoryAgg inv1 = new InTransitInventoryAgg(
                1001L, "SKU-001", 1L, "RW_US_WEST", BusinessMode.JH, 500);
        inventories.add(inv1);
        
        Map<String, InTransitInventoryAgg> result = service.mergeByBusinessMode(inventories);
        
        assertEquals(1, result.size());
        InTransitInventoryAgg agg = result.values().iterator().next();
        assertEquals(BusinessMode.JH_LX, agg.getBusinessMode());
        assertEquals(Integer.valueOf(500), agg.getInTransitQuantity());
    }
    
    @Test
    public void testMergeByBusinessMode_OnlyFBA() {
        // 测试仅有FBA模式的情况
        List<InTransitInventoryAgg> inventories = new ArrayList<>();
        
        InTransitInventoryAgg inv1 = new InTransitInventoryAgg(
                1001L, "SKU-001", 1L, "RW_US_WEST", BusinessMode.FBA, 200);
        inventories.add(inv1);
        
        Map<String, InTransitInventoryAgg> result = service.mergeByBusinessMode(inventories);
        
        assertEquals(1, result.size());
        InTransitInventoryAgg agg = result.values().iterator().next();
        assertEquals(BusinessMode.FBA, agg.getBusinessMode());
        assertEquals(Integer.valueOf(200), agg.getInTransitQuantity());
    }
    
    @Test
    public void testAggregateByRegionalWarehouse_UnboundWarehouse() {
        // 测试未绑定区域仓的情况
        List<InTransitInventoryAgg> warehouseInventories = new ArrayList<>();
        
        InTransitInventoryAgg inv1 = new InTransitInventoryAgg(
                1001L, "SKU-001", 999L, "WH_UNBOUND", BusinessMode.JH, 500);
        warehouseInventories.add(inv1);
        
        // 空的绑定关系
        Map<Long, Long> bindings = new HashMap<>();
        
        // 执行聚合
        Map<String, InTransitInventoryAgg> result = service.aggregateByRegionalWarehouse(
                warehouseInventories, bindings);
        
        // 未绑定的仓库应该被跳过
        assertEquals(0, result.size());
    }
}
