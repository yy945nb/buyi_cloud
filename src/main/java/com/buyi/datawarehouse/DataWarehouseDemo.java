package com.buyi.datawarehouse;

import com.buyi.datawarehouse.config.DataWarehouseConfig;
import com.buyi.datawarehouse.service.olap.OlapAnalysisService;
import com.buyi.datawarehouse.service.olap.OlapAnalysisService.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.util.List;

/**
 * 数据仓库示例程序
 * Data Warehouse Demo Application
 * 
 * 展示数据仓库的主要功能和使用方法
 */
public class DataWarehouseDemo {
    private static final Logger logger = LoggerFactory.getLogger(DataWarehouseDemo.class);
    
    public static void main(String[] args) {
        logger.info("========================================");
        logger.info("  Buyi Cloud 数据仓库私有化部署示例");
        logger.info("  Data Warehouse Privatization Demo");
        logger.info("========================================");
        
        // 1. 配置数据仓库
        logger.info("\n[Step 1] 配置数据仓库连接...");
        DataWarehouseConfig config = DataWarehouseConfig.builder()
                .sourceUrl("jdbc:mysql://localhost:3306/buyi_platform")
                .sourceUser("root")
                .sourcePassword("password")
                .targetUrl("jdbc:mysql://localhost:3306/buyi_dw")
                .targetUser("root")
                .targetPassword("password")
                .etlBatchSize(1000)
                .syncIntervalMinutes(30)
                .incrementalSyncEnabled(true)
                .build();
        
        logger.info("配置完成: {}", config);
        
        // 模拟演示（不实际连接数据库）
        demonstrateFeatures();
    }
    
    /**
     * 演示数据仓库功能
     */
    private static void demonstrateFeatures() {
        logger.info("\n[Step 2] 数据仓库功能演示...");
        
        // 演示时间维度
        demonstrateDateDimension();
        
        // 演示OLAP分析
        demonstrateOlapAnalysis();
        
        // 演示聚合计算
        demonstrateAggregation();
        
        logger.info("\n========================================");
        logger.info("  演示完成！");
        logger.info("  更多详情请参考 DATA_WAREHOUSE_GUIDE.md");
        logger.info("========================================");
    }
    
    /**
     * 演示时间维度生成
     */
    private static void demonstrateDateDimension() {
        logger.info("\n--- 时间维度生成示例 ---");
        
        com.buyi.datawarehouse.model.dimension.DimDate dimDate = 
                com.buyi.datawarehouse.model.dimension.DimDate.fromDate(LocalDate.now());
        
        logger.info("当前日期维度:");
        logger.info("  日期键: {}", dimDate.getDateKey());
        logger.info("  年份: {}", dimDate.getYear());
        logger.info("  季度: Q{}", dimDate.getQuarter());
        logger.info("  月份: {}", dimDate.getMonth());
        logger.info("  周数: {}", dimDate.getWeek());
        logger.info("  是否周末: {}", dimDate.getIsWeekend());
        logger.info("  年月: {}", dimDate.getYearMonth());
        logger.info("  年季度: {}", dimDate.getYearQuarter());
    }
    
    /**
     * 演示OLAP分析功能
     */
    private static void demonstrateOlapAnalysis() {
        logger.info("\n--- OLAP分析功能示例 ---");
        
        logger.info("1. 销售趋势分析 (Sales Trend Analysis)");
        logger.info("   - 支持日/周/月/季/年粒度");
        logger.info("   - 可按店铺、商品过滤");
        logger.info("   - 示例SQL:");
        logger.info("     SELECT period, SUM(net_amount), SUM(profit_amount)");
        logger.info("     FROM dw_agg_sales_daily");
        logger.info("     WHERE date_key BETWEEN 20240101 AND 20241231");
        logger.info("     GROUP BY period ORDER BY period");
        
        logger.info("\n2. 商品销售排名 (Product Sales Ranking)");
        logger.info("   - 按销售额/销量排名");
        logger.info("   - 支持TOP N查询");
        logger.info("   - 示例: 获取销售额TOP 10商品");
        
        logger.info("\n3. 店铺业绩分析 (Shop Performance Analysis)");
        logger.info("   - 各店铺销售对比");
        logger.info("   - 利润率分析");
        logger.info("   - 平台维度分析");
        
        logger.info("\n4. 库存周转分析 (Inventory Turnover Analysis)");
        logger.info("   - 平均库存量");
        logger.info("   - 周转天数");
        logger.info("   - 库存价值");
    }
    
    /**
     * 演示聚合计算
     */
    private static void demonstrateAggregation() {
        logger.info("\n--- 聚合计算示例 ---");
        
        logger.info("日聚合指标:");
        logger.info("  - 订单数 (order_count)");
        logger.info("  - 销售数量 (quantity_sold)");
        logger.info("  - 销售总额 (gross_amount)");
        logger.info("  - 净销售额 (net_amount)");
        logger.info("  - 成本总额 (cost_amount)");
        logger.info("  - 利润总额 (profit_amount)");
        logger.info("  - 利润率 (profit_rate)");
        logger.info("  - 客单价 (avg_order_value)");
        
        logger.info("\n月聚合指标（额外）:");
        logger.info("  - 日均销售额 (avg_daily_sales)");
        logger.info("  - 月环比增长率 (mom_growth_rate)");
        logger.info("  - 同比增长率 (yoy_growth_rate)");
        
        // 演示利润率计算
        com.buyi.datawarehouse.model.aggregate.AggSalesDaily agg = 
                new com.buyi.datawarehouse.model.aggregate.AggSalesDaily();
        agg.setNetAmount(new java.math.BigDecimal("10000"));
        agg.setProfitAmount(new java.math.BigDecimal("3000"));
        agg.setOrderCount(50);
        agg.calculateDerivedMetrics();
        
        logger.info("\n计算示例:");
        logger.info("  净销售额: {}", agg.getNetAmount());
        logger.info("  利润金额: {}", agg.getProfitAmount());
        logger.info("  订单数: {}", agg.getOrderCount());
        logger.info("  利润率: {}%", agg.getProfitRate());
        logger.info("  客单价: {}", agg.getAvgOrderValue());
    }
}
