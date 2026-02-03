package com.buyi.datawarehouse;

import com.buyi.datawarehouse.model.IntransitInventory;
import com.buyi.datawarehouse.model.WarehouseMapping;
import com.buyi.datawarehouse.model.fact.FactInventory;
import com.buyi.datawarehouse.service.IntransitInventoryService;
import com.buyi.datawarehouse.service.WarehouseInventoryService;
import com.buyi.ruleengine.model.CosOosPointResponse;
import com.buyi.ruleengine.service.WarehouseStockoutMonitoringService;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

/**
 * 仓库维度断货点监控示例
 * Warehouse-based Stockout Monitoring Example
 * 
 * 本示例展示如何使用新的仓库维度服务进行断货点监控
 * This example demonstrates how to use the new warehouse-dimension services for stockout monitoring
 */
public class WarehouseStockoutMonitoringExample {
    
    public static void main(String[] args) {
        System.out.println("=== 仓库维度断货点监控示例 ===\n");
        
        // 1. 初始化服务
        IntransitInventoryService intransitService = new IntransitInventoryService();
        WarehouseInventoryService inventoryService = new WarehouseInventoryService();
        WarehouseStockoutMonitoringService monitoringService = new WarehouseStockoutMonitoringService();
        
        // 2. 加载仓库映射配置
        Map<Long, WarehouseMapping> warehouseMapping = loadWarehouseMappings();
        System.out.println("已加载 " + warehouseMapping.size() + " 个仓库映射配置\n");
        
        // 3. 示例1：计算特定仓库的在途库存
        demonstrateIntransitCalculation(intransitService, warehouseMapping);
        
        // 4. 示例2：按模式聚合库存
        demonstrateInventoryByMode(inventoryService, intransitService, warehouseMapping);
        
        // 5. 示例3：评估仓库断货风险
        demonstrateStockoutRiskEvaluation(monitoringService, warehouseMapping);
        
        // 6. 示例4：多仓库批量监控
        demonstrateMultiWarehouseMonitoring(monitoringService, warehouseMapping);
    }
    
    /**
     * 示例1：计算在途库存
     */
    private static void demonstrateIntransitCalculation(
            IntransitInventoryService intransitService,
            Map<Long, WarehouseMapping> warehouseMapping) {
        
        System.out.println("--- 示例1：在途库存计算 ---");
        
        LocalDate monitorDate = LocalDate.now();
        Long warehouseId = 1001L;  // CAJW06仓
        String skuCode = "WL-FZ-39-W";
        
        // 获取在途库存数量
        Integer intransitQty = intransitService.getIntransitQuantity(
                warehouseId, skuCode, monitorDate, warehouseMapping);
        
        System.out.println("仓库ID: " + warehouseId);
        System.out.println("SKU: " + skuCode);
        System.out.println("监控日期: " + monitorDate);
        System.out.println("在途库存数量: " + intransitQty);
        System.out.println();
        
        // 获取所有在途库存
        Map<String, IntransitInventory> allIntransit = 
                intransitService.aggregateAllIntransit(monitorDate, warehouseMapping);
        
        System.out.println("全部在途库存项数: " + allIntransit.size());
        
        // 显示前5项
        int count = 0;
        for (IntransitInventory item : allIntransit.values()) {
            if (count++ >= 5) break;
            System.out.println("  - 仓库: " + item.getWarehouseName() + 
                             ", SKU: " + item.getSkuCode() + 
                             ", 数量: " + item.getIntransitQuantity() +
                             ", 模式: " + item.getMode() +
                             ", 来源: " + item.getSource());
        }
        System.out.println();
    }
    
    /**
     * 示例2：按模式聚合库存
     */
    private static void demonstrateInventoryByMode(
            WarehouseInventoryService inventoryService,
            IntransitInventoryService intransitService,
            Map<Long, WarehouseMapping> warehouseMapping) {
        
        System.out.println("--- 示例2：按模式聚合库存 ---");
        
        LocalDate monitorDate = LocalDate.now();
        
        // 区域仓模式
        System.out.println("区域仓模式 (REGIONAL):");
        List<FactInventory> regionalInventory = 
                inventoryService.aggregateInventoryByMode("REGIONAL", warehouseMapping);
        System.out.println("  现有库存项数: " + regionalInventory.size());
        
        List<IntransitInventory> regionalIntransit = 
                intransitService.getIntransitByMode("REGIONAL", monitorDate, warehouseMapping);
        System.out.println("  在途库存项数: " + regionalIntransit.size());
        
        // FBA模式
        System.out.println("\nFBA模式:");
        List<FactInventory> fbaInventory = 
                inventoryService.aggregateInventoryByMode("FBA", warehouseMapping);
        System.out.println("  现有库存项数: " + fbaInventory.size());
        
        List<IntransitInventory> fbaIntransit = 
                intransitService.getIntransitByMode("FBA", monitorDate, warehouseMapping);
        System.out.println("  在途库存项数: " + fbaIntransit.size());
        System.out.println();
    }
    
    /**
     * 示例3：评估仓库断货风险
     */
    private static void demonstrateStockoutRiskEvaluation(
            WarehouseStockoutMonitoringService monitoringService,
            Map<Long, WarehouseMapping> warehouseMapping) {
        
        System.out.println("--- 示例3：评估仓库断货风险 ---");
        
        Long warehouseId = 1001L;  // CAJW06仓
        String skuCode = "WL-FZ-39-W";
        String mode = "REGIONAL";
        Integer currentInventory = 500;
        BigDecimal dailyAvg = BigDecimal.valueOf(15.5);
        Integer productionDays = 25;
        Integer shippingDays = 35;
        Integer safetyStockDays = 30;
        LocalDate baseDate = LocalDate.now();
        
        System.out.println("评估参数:");
        System.out.println("  仓库ID: " + warehouseId);
        System.out.println("  SKU: " + skuCode);
        System.out.println("  当前库存: " + currentInventory);
        System.out.println("  日均销量: " + dailyAvg);
        System.out.println("  生产天数: " + productionDays);
        System.out.println("  海运天数: " + shippingDays);
        System.out.println("  安全库存天数: " + safetyStockDays);
        System.out.println();
        
        // 执行评估
        CosOosPointResponse response = monitoringService.evaluateWarehouseStockoutRisk(
                warehouseId,
                skuCode,
                mode,
                currentInventory,
                dailyAvg,
                productionDays,
                shippingDays,
                safetyStockDays,
                7,   // 监控间隔7天
                80,  // 预测80天
                baseDate,
                warehouseMapping
        );
        
        // 输出结果
        System.out.println("评估结果:");
        if (response.getFirstRiskPoint() != null) {
            System.out.println("  ⚠ 发现风险!");
            System.out.println("  风险等级: " + response.getFirstRiskPoint().getRiskLevel());
            System.out.println("  断货开始日期: " + response.getOosStartDate());
            System.out.println("  距离断货天数: " + response.getOosDays());
            System.out.println("  预计缺货量: " + response.getOosNum());
            System.out.println("  原因: " + response.getOosReason());
        } else {
            System.out.println("  ✓ 库存安全，未发现风险");
        }
        
        System.out.println("  总监控点数: " + 
                (response.getMonitorPoints() != null ? response.getMonitorPoints().size() : 0));
        System.out.println();
    }
    
    /**
     * 示例4：多仓库批量监控
     */
    private static void demonstrateMultiWarehouseMonitoring(
            WarehouseStockoutMonitoringService monitoringService,
            Map<Long, WarehouseMapping> warehouseMapping) {
        
        System.out.println("--- 示例4：多仓库批量监控 ---");
        
        String skuCode = "WL-FZ-39-W";
        String mode = "REGIONAL";
        BigDecimal dailyAvg = BigDecimal.valueOf(15.5);
        Integer productionDays = 25;
        Integer shippingDays = 35;
        Integer safetyStockDays = 30;
        LocalDate baseDate = LocalDate.now();
        
        System.out.println("监控SKU: " + skuCode);
        System.out.println("监控模式: " + mode);
        System.out.println();
        
        // 按模式评估所有仓库
        Map<Long, CosOosPointResponse> results = monitoringService.evaluateByMode(
                skuCode,
                mode,
                dailyAvg,
                productionDays,
                shippingDays,
                safetyStockDays,
                baseDate,
                warehouseMapping
        );
        
        System.out.println("监控结果汇总:");
        System.out.println("  监控仓库总数: " + results.size());
        
        int riskCount = 0;
        for (Map.Entry<Long, CosOosPointResponse> entry : results.entrySet()) {
            Long warehouseId = entry.getKey();
            CosOosPointResponse response = entry.getValue();
            
            if (response.getFirstRiskPoint() != null) {
                riskCount++;
                WarehouseMapping wm = warehouseMapping.get(warehouseId);
                System.out.println("\n  ⚠ 仓库: " + (wm != null ? wm.getWarehouseName() : warehouseId));
                System.out.println("     风险等级: " + response.getFirstRiskPoint().getRiskLevel());
                System.out.println("     距离断货天数: " + response.getOosDays());
                System.out.println("     预计缺货量: " + response.getOosNum());
            }
        }
        
        if (riskCount == 0) {
            System.out.println("  ✓ 所有仓库库存安全");
        } else {
            System.out.println("\n  存在风险的仓库数: " + riskCount + " / " + results.size());
        }
        System.out.println();
    }
    
    /**
     * 加载仓库映射配置
     */
    private static Map<Long, WarehouseMapping> loadWarehouseMappings() {
        Map<Long, WarehouseMapping> mapping = new HashMap<>();
        
        // JH系统仓库
        WarehouseMapping wm1 = new WarehouseMapping();
        wm1.setWarehouseId(1001L);
        wm1.setWarehouseCode("CAJW06");
        wm1.setWarehouseName("CAJW06仓");
        wm1.setWarehouseType("REGIONAL");
        wm1.setSourceSystem("JH");
        wm1.setSourceWarehouseId(11129L);
        wm1.setSourceWarehouseName("CAJW06");
        wm1.setRegion("US_WEST");
        wm1.setCountry("US");
        mapping.put(1001L, wm1);
        
        // JH系统另一个仓库
        WarehouseMapping wm2 = new WarehouseMapping();
        wm2.setWarehouseId(1002L);
        wm2.setWarehouseCode("CG-MJJ");
        wm2.setWarehouseName("CG仓-Meijiajia");
        wm2.setWarehouseType("REGIONAL");
        wm2.setSourceSystem("JH");
        wm2.setSourceWarehouseId(10568L);
        wm2.setSourceWarehouseName("CG仓-Meijiajia");
        wm2.setRegion("US_EAST");
        wm2.setCountry("US");
        mapping.put(1002L, wm2);
        
        // LX系统欧洲仓
        WarehouseMapping wm3 = new WarehouseMapping();
        wm3.setWarehouseId(2001L);
        wm3.setWarehouseCode("EUWE");
        wm3.setWarehouseName("欧洲DE EUWE");
        wm3.setWarehouseType("REGIONAL");
        wm3.setSourceSystem("LX");
        wm3.setSourceWarehouseId(9488L);
        wm3.setSourceWarehouseName("欧洲DE EUWE");
        wm3.setRegion("EU");
        wm3.setCountry("DE");
        mapping.put(2001L, wm3);
        
        // LX系统英国仓
        WarehouseMapping wm4 = new WarehouseMapping();
        wm4.setWarehouseId(2002L);
        wm4.setWarehouseCode("UKNH02");
        wm4.setWarehouseName("欧洲UK UKNH02");
        wm4.setWarehouseType("REGIONAL");
        wm4.setSourceSystem("LX");
        wm4.setSourceWarehouseId(9487L);
        wm4.setSourceWarehouseName("欧洲UK UKNH02");
        wm4.setRegion("EU");
        wm4.setCountry("UK");
        mapping.put(2002L, wm4);
        
        // FBA仓
        WarehouseMapping wm5 = new WarehouseMapping();
        wm5.setWarehouseId(3001L);
        wm5.setWarehouseCode("FBA_US");
        wm5.setWarehouseName("FBA美国仓");
        wm5.setWarehouseType("FBA");
        wm5.setSourceSystem("LX");
        wm5.setSourceWarehouseId(4000L);
        wm5.setSourceWarehouseName("FBA");
        wm5.setRegion("US");
        wm5.setCountry("US");
        mapping.put(3001L, wm5);
        
        return mapping;
    }
}
