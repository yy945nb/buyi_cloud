package com.buyi.datawarehouse.monitoring;

import com.buyi.datawarehouse.enums.BusinessMode;
import com.buyi.datawarehouse.enums.RiskLevel;
import com.buyi.datawarehouse.model.monitoring.ProductStockoutMonitoring;
import com.buyi.datawarehouse.service.monitoring.MonitoringSnapshotService;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Product Stockout Monitoring Model Demo
 */
public class StockoutMonitoringDemo {
    
    public static void main(String[] args) {
        System.out.println("=== Product Stockout Monitoring Model Demo ===\n");
        
        demonstrateEnums();
        demonstrateStockoutCalculation();
        demonstrateSnapshotService();
        
        System.out.println("\n=== Demo Completed ===");
    }
    
    private static void demonstrateEnums() {
        System.out.println("### Example 1: Enum Usage ###\n");
        
        System.out.println("Business Modes:");
        for (BusinessMode mode : BusinessMode.values()) {
            System.out.println(String.format("  %s - %s: %s", 
                mode.getCode(), mode.getName(), mode.getDescription()));
        }
        
        System.out.println("\nMode Conversion:");
        System.out.println("  JH merged: " + BusinessMode.JH.toMergedMode());
        System.out.println("  LX merged: " + BusinessMode.LX.toMergedMode());
        System.out.println("  FBA merged: " + BusinessMode.FBA.toMergedMode());
        
        System.out.println("\nRisk Levels:");
        for (RiskLevel level : RiskLevel.values()) {
            System.out.println(String.format("  %s - %s",
                level.getCode(), level.getName()));
        }
        System.out.println();
    }
    
    private static void demonstrateStockoutCalculation() {
        System.out.println("### Example 2: Stockout Calculation ###\n");
        
        ProductStockoutMonitoring monitoring = new ProductStockoutMonitoring();
        monitoring.setProductSku("DEMO-SKU-001");
        monitoring.setRegionalWarehouseCode("RW_US_WEST");
        monitoring.setBusinessMode(BusinessMode.JH_LX);
        monitoring.setOverseasInventory(1000);
        monitoring.setInTransitInventory(500);
        monitoring.setAvailableInventory(900);
        monitoring.calculateTotalInventory();
        
        monitoring.setDailyAvgSales(new BigDecimal("100.0000"));
        monitoring.setRegionalProportion(new BigDecimal("0.2500"));
        monitoring.calculateRegionalDailySales();
        
        monitoring.setSafetyStockDays(30);
        monitoring.setLeadTimeDays(65);
        monitoring.calculateStockoutMetrics();
        
        System.out.println("Inventory: " + monitoring.getTotalInventory());
        System.out.println("Regional Daily Sales: " + monitoring.getRegionalDailySales());
        System.out.println("Available Days: " + monitoring.getAvailableDays());
        System.out.println("Risk Level: " + monitoring.getRiskLevel().getName());
        System.out.println();
    }
    
    private static void demonstrateSnapshotService() {
        System.out.println("### Example 3: Snapshot Service ###\n");
        System.out.println("Available Functions:");
        System.out.println("1. generateDailySnapshot(date) - Generate daily monitoring snapshot");
        System.out.println("2. backfillHistoricalSnapshots(start, end) - Backfill historical data");
        System.out.println("\nNote: Actual execution requires database configuration");
        System.out.println();
    }
}
