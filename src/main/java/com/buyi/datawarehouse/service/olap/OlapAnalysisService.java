package com.buyi.datawarehouse.service.olap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * OLAP分析服务
 * OLAP (Online Analytical Processing) Analysis Service
 * 
 * 提供多维度数据分析能力，支持切片、切块、钻取、旋转等操作
 */
public class OlapAnalysisService {
    private static final Logger logger = LoggerFactory.getLogger(OlapAnalysisService.class);
    
    private final DataSource dataSource;
    
    public OlapAnalysisService(DataSource dataSource) {
        this.dataSource = dataSource;
    }
    
    /**
     * 时间粒度枚举
     */
    public enum TimeGranularity {
        DAILY, WEEKLY, MONTHLY, QUARTERLY, YEARLY
    }
    
    /**
     * 销售趋势分析
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @param granularity 时间粒度
     * @param shopId 店铺ID（可选）
     * @param productId 商品ID（可选）
     * @return 销售趋势结果
     */
    public SalesTrendResult analyzeSalesTrend(LocalDate startDate, LocalDate endDate,
                                               TimeGranularity granularity,
                                               Long shopId, Long productId) {
        logger.info("Analyzing sales trend from {} to {} with granularity {}", 
                startDate, endDate, granularity);
        
        SalesTrendResult result = new SalesTrendResult();
        result.setStartDate(startDate);
        result.setEndDate(endDate);
        result.setGranularity(granularity);
        
        String periodColumn = getPeriodColumn(granularity);
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ").append(periodColumn).append(" as period, ");
        sql.append("SUM(net_amount) as sales_amount, ");
        sql.append("SUM(profit_amount) as profit_amount, ");
        sql.append("SUM(quantity_sold) as quantity, ");
        sql.append("COUNT(DISTINCT CONCAT(date_key, product_key, shop_key)) as record_count ");
        sql.append("FROM dw_agg_sales_daily ");
        sql.append("WHERE date_key >= ? AND date_key <= ? ");
        
        if (shopId != null) {
            sql.append("AND shop_key = ? ");
        }
        if (productId != null) {
            sql.append("AND product_key = ? ");
        }
        
        sql.append("GROUP BY ").append(periodColumn).append(" ");
        sql.append("ORDER BY period");
        
        int startKey = Integer.parseInt(startDate.format(DateTimeFormatter.BASIC_ISO_DATE));
        int endKey = Integer.parseInt(endDate.format(DateTimeFormatter.BASIC_ISO_DATE));
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setInt(paramIndex++, startKey);
            ps.setInt(paramIndex++, endKey);
            
            if (shopId != null) {
                ps.setLong(paramIndex++, shopId);
            }
            if (productId != null) {
                ps.setLong(paramIndex, productId);
            }
            
            ResultSet rs = ps.executeQuery();
            List<SalesTrendDataPoint> dataPoints = new ArrayList<>();
            
            while (rs.next()) {
                SalesTrendDataPoint point = new SalesTrendDataPoint();
                point.setPeriod(rs.getString("period"));
                point.setSalesAmount(rs.getBigDecimal("sales_amount"));
                point.setProfitAmount(rs.getBigDecimal("profit_amount"));
                point.setQuantity(rs.getInt("quantity"));
                dataPoints.add(point);
            }
            
            result.setDataPoints(dataPoints);
            logger.info("Found {} trend data points", dataPoints.size());
        } catch (SQLException e) {
            logger.error("Failed to analyze sales trend", e);
            throw new RuntimeException(e);
        }
        
        return result;
    }
    
    /**
     * 商品销售排名分析
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @param shopId 店铺ID（可选）
     * @param topN 前N名
     * @return 商品排名列表
     */
    public List<ProductRankResult> getProductSalesRanking(LocalDate startDate, LocalDate endDate,
                                                           Long shopId, int topN) {
        logger.info("Getting product sales ranking from {} to {}, top {}", startDate, endDate, topN);
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.product_key, p.sku_code, p.product_name, ");
        sql.append("SUM(a.net_amount) as total_sales, ");
        sql.append("SUM(a.quantity_sold) as total_quantity, ");
        sql.append("SUM(a.profit_amount) as total_profit, ");
        sql.append("SUM(a.order_count) as total_orders ");
        sql.append("FROM dw_agg_sales_daily a ");
        sql.append("JOIN dw_dim_product p ON a.product_key = p.product_key ");
        sql.append("WHERE a.date_key >= ? AND a.date_key <= ? ");
        sql.append("AND p.is_current = 1 ");
        
        if (shopId != null) {
            sql.append("AND a.shop_key = ? ");
        }
        
        sql.append("GROUP BY p.product_key, p.sku_code, p.product_name ");
        sql.append("ORDER BY total_sales DESC ");
        sql.append("LIMIT ?");
        
        int startKey = Integer.parseInt(startDate.format(DateTimeFormatter.BASIC_ISO_DATE));
        int endKey = Integer.parseInt(endDate.format(DateTimeFormatter.BASIC_ISO_DATE));
        
        List<ProductRankResult> results = new ArrayList<>();
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setInt(paramIndex++, startKey);
            ps.setInt(paramIndex++, endKey);
            
            if (shopId != null) {
                ps.setLong(paramIndex++, shopId);
            }
            
            ps.setInt(paramIndex, topN);
            
            ResultSet rs = ps.executeQuery();
            int rank = 1;
            
            while (rs.next()) {
                ProductRankResult result = new ProductRankResult();
                result.setRank(rank++);
                result.setProductKey(rs.getLong("product_key"));
                result.setSkuCode(rs.getString("sku_code"));
                result.setProductName(rs.getString("product_name"));
                result.setSalesAmount(rs.getBigDecimal("total_sales"));
                result.setQuantity(rs.getInt("total_quantity"));
                result.setProfitAmount(rs.getBigDecimal("total_profit"));
                result.setOrderCount(rs.getInt("total_orders"));
                results.add(result);
            }
            
            logger.info("Found {} product ranking results", results.size());
        } catch (SQLException e) {
            logger.error("Failed to get product sales ranking", e);
            throw new RuntimeException(e);
        }
        
        return results;
    }
    
    /**
     * 店铺业绩分析
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 店铺业绩列表
     */
    public List<ShopPerformanceResult> analyzeShopPerformance(LocalDate startDate, LocalDate endDate) {
        logger.info("Analyzing shop performance from {} to {}", startDate, endDate);
        
        String sql = "SELECT s.shop_key, s.shop_code, s.shop_name, s.platform, " +
                "SUM(a.net_amount) as total_sales, " +
                "SUM(a.quantity_sold) as total_quantity, " +
                "SUM(a.profit_amount) as total_profit, " +
                "SUM(a.order_count) as total_orders, " +
                "CASE WHEN SUM(a.net_amount) > 0 THEN " +
                "  SUM(a.profit_amount) / SUM(a.net_amount) * 100 " +
                "ELSE 0 END as profit_rate " +
                "FROM dw_agg_sales_daily a " +
                "JOIN dw_dim_shop s ON a.shop_key = s.shop_key " +
                "WHERE a.date_key >= ? AND a.date_key <= ? " +
                "AND s.is_current = 1 " +
                "GROUP BY s.shop_key, s.shop_code, s.shop_name, s.platform " +
                "ORDER BY total_sales DESC";
        
        int startKey = Integer.parseInt(startDate.format(DateTimeFormatter.BASIC_ISO_DATE));
        int endKey = Integer.parseInt(endDate.format(DateTimeFormatter.BASIC_ISO_DATE));
        
        List<ShopPerformanceResult> results = new ArrayList<>();
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, startKey);
            ps.setInt(2, endKey);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                ShopPerformanceResult result = new ShopPerformanceResult();
                result.setShopKey(rs.getLong("shop_key"));
                result.setShopCode(rs.getString("shop_code"));
                result.setShopName(rs.getString("shop_name"));
                result.setPlatform(rs.getString("platform"));
                result.setTotalSales(rs.getBigDecimal("total_sales"));
                result.setTotalQuantity(rs.getInt("total_quantity"));
                result.setTotalProfit(rs.getBigDecimal("total_profit"));
                result.setTotalOrders(rs.getInt("total_orders"));
                result.setProfitRate(rs.getBigDecimal("profit_rate"));
                results.add(result);
            }
            
            logger.info("Found {} shop performance results", results.size());
        } catch (SQLException e) {
            logger.error("Failed to analyze shop performance", e);
            throw new RuntimeException(e);
        }
        
        return results;
    }
    
    /**
     * 库存周转分析
     * @param warehouseId 仓库ID（可选）
     * @param productId 商品ID（可选）
     * @return 库存周转分析结果
     */
    public InventoryTurnoverResult analyzeInventoryTurnover(Long warehouseId, Long productId) {
        logger.info("Analyzing inventory turnover for warehouse={}, product={}", warehouseId, productId);
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ");
        sql.append("AVG(i.on_hand_quantity) as avg_inventory, ");
        sql.append("AVG(i.turnover_days) as avg_turnover_days, ");
        sql.append("SUM(i.inventory_value) as total_inventory_value, ");
        sql.append("COUNT(DISTINCT i.product_key) as sku_count ");
        sql.append("FROM dw_fact_inventory i ");
        sql.append("WHERE i.date_key = ? ");
        
        if (warehouseId != null) {
            sql.append("AND i.warehouse_key = ? ");
        }
        if (productId != null) {
            sql.append("AND i.product_key = ? ");
        }
        
        int todayKey = Integer.parseInt(LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE));
        
        InventoryTurnoverResult result = new InventoryTurnoverResult();
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setInt(paramIndex++, todayKey);
            
            if (warehouseId != null) {
                ps.setLong(paramIndex++, warehouseId);
            }
            if (productId != null) {
                ps.setLong(paramIndex, productId);
            }
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                result.setAvgInventory(rs.getBigDecimal("avg_inventory"));
                result.setAvgTurnoverDays(rs.getBigDecimal("avg_turnover_days"));
                result.setTotalInventoryValue(rs.getBigDecimal("total_inventory_value"));
                result.setSkuCount(rs.getInt("sku_count"));
            }
            
            logger.info("Inventory turnover analysis completed");
        } catch (SQLException e) {
            logger.error("Failed to analyze inventory turnover", e);
            throw new RuntimeException(e);
        }
        
        return result;
    }
    
    /**
     * 多维分析查询
     * @param dimensions 维度列表
     * @param measures 度量列表
     * @param filters 过滤条件
     * @return 查询结果
     */
    public List<Map<String, Object>> multiDimensionalQuery(
            List<String> dimensions, 
            List<String> measures,
            Map<String, Object> filters) {
        
        logger.info("Executing multi-dimensional query with dimensions={}, measures={}", 
                dimensions, measures);
        
        StringBuilder sql = new StringBuilder("SELECT ");
        
        // 添加维度
        for (int i = 0; i < dimensions.size(); i++) {
            if (i > 0) sql.append(", ");
            sql.append(dimensions.get(i));
        }
        
        // 添加度量
        for (String measure : measures) {
            sql.append(", ").append(measure);
        }
        
        sql.append(" FROM dw_agg_sales_daily a ");
        sql.append(" LEFT JOIN dw_dim_product p ON a.product_key = p.product_key ");
        sql.append(" LEFT JOIN dw_dim_shop s ON a.shop_key = s.shop_key ");
        sql.append(" WHERE 1=1 ");
        
        // 添加过滤条件
        List<Object> params = new ArrayList<>();
        if (filters != null) {
            for (Map.Entry<String, Object> entry : filters.entrySet()) {
                sql.append(" AND ").append(entry.getKey()).append(" = ?");
                params.add(entry.getValue());
            }
        }
        
        // 分组
        if (!dimensions.isEmpty()) {
            sql.append(" GROUP BY ");
            for (int i = 0; i < dimensions.size(); i++) {
                if (i > 0) sql.append(", ");
                sql.append(dimensions.get(i));
            }
        }
        
        List<Map<String, Object>> results = new ArrayList<>();
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = ps.executeQuery();
            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                for (int i = 1; i <= columnCount; i++) {
                    row.put(metaData.getColumnLabel(i), rs.getObject(i));
                }
                results.add(row);
            }
            
            logger.info("Multi-dimensional query returned {} rows", results.size());
        } catch (SQLException e) {
            logger.error("Failed to execute multi-dimensional query", e);
            throw new RuntimeException(e);
        }
        
        return results;
    }
    
    /**
     * 获取周期列表达式
     */
    private String getPeriodColumn(TimeGranularity granularity) {
        switch (granularity) {
            case DAILY:
                return "date_key";
            case WEEKLY:
                return "CONCAT(YEAR(STR_TO_DATE(date_key, '%Y%m%d')), '-W', " +
                       "LPAD(WEEK(STR_TO_DATE(date_key, '%Y%m%d')), 2, '0'))";
            case MONTHLY:
                return "CONCAT(LEFT(date_key, 6))";
            case QUARTERLY:
                return "CONCAT(LEFT(date_key, 4), '-Q', QUARTER(STR_TO_DATE(date_key, '%Y%m%d')))";
            case YEARLY:
                return "LEFT(date_key, 4)";
            default:
                return "date_key";
        }
    }
    
    // ============ 结果类 ============
    
    /**
     * 销售趋势结果
     */
    public static class SalesTrendResult {
        private LocalDate startDate;
        private LocalDate endDate;
        private TimeGranularity granularity;
        private List<SalesTrendDataPoint> dataPoints;
        
        public LocalDate getStartDate() { return startDate; }
        public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
        public LocalDate getEndDate() { return endDate; }
        public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
        public TimeGranularity getGranularity() { return granularity; }
        public void setGranularity(TimeGranularity granularity) { this.granularity = granularity; }
        public List<SalesTrendDataPoint> getDataPoints() { return dataPoints; }
        public void setDataPoints(List<SalesTrendDataPoint> dataPoints) { this.dataPoints = dataPoints; }
    }
    
    /**
     * 销售趋势数据点
     */
    public static class SalesTrendDataPoint {
        private String period;
        private BigDecimal salesAmount;
        private BigDecimal profitAmount;
        private Integer quantity;
        
        public String getPeriod() { return period; }
        public void setPeriod(String period) { this.period = period; }
        public BigDecimal getSalesAmount() { return salesAmount; }
        public void setSalesAmount(BigDecimal salesAmount) { this.salesAmount = salesAmount; }
        public BigDecimal getProfitAmount() { return profitAmount; }
        public void setProfitAmount(BigDecimal profitAmount) { this.profitAmount = profitAmount; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
    }
    
    /**
     * 商品排名结果
     */
    public static class ProductRankResult {
        private int rank;
        private Long productKey;
        private String skuCode;
        private String productName;
        private BigDecimal salesAmount;
        private Integer quantity;
        private BigDecimal profitAmount;
        private Integer orderCount;
        
        public int getRank() { return rank; }
        public void setRank(int rank) { this.rank = rank; }
        public Long getProductKey() { return productKey; }
        public void setProductKey(Long productKey) { this.productKey = productKey; }
        public String getSkuCode() { return skuCode; }
        public void setSkuCode(String skuCode) { this.skuCode = skuCode; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public BigDecimal getSalesAmount() { return salesAmount; }
        public void setSalesAmount(BigDecimal salesAmount) { this.salesAmount = salesAmount; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public BigDecimal getProfitAmount() { return profitAmount; }
        public void setProfitAmount(BigDecimal profitAmount) { this.profitAmount = profitAmount; }
        public Integer getOrderCount() { return orderCount; }
        public void setOrderCount(Integer orderCount) { this.orderCount = orderCount; }
    }
    
    /**
     * 店铺业绩结果
     */
    public static class ShopPerformanceResult {
        private Long shopKey;
        private String shopCode;
        private String shopName;
        private String platform;
        private BigDecimal totalSales;
        private Integer totalQuantity;
        private BigDecimal totalProfit;
        private Integer totalOrders;
        private BigDecimal profitRate;
        
        public Long getShopKey() { return shopKey; }
        public void setShopKey(Long shopKey) { this.shopKey = shopKey; }
        public String getShopCode() { return shopCode; }
        public void setShopCode(String shopCode) { this.shopCode = shopCode; }
        public String getShopName() { return shopName; }
        public void setShopName(String shopName) { this.shopName = shopName; }
        public String getPlatform() { return platform; }
        public void setPlatform(String platform) { this.platform = platform; }
        public BigDecimal getTotalSales() { return totalSales; }
        public void setTotalSales(BigDecimal totalSales) { this.totalSales = totalSales; }
        public Integer getTotalQuantity() { return totalQuantity; }
        public void setTotalQuantity(Integer totalQuantity) { this.totalQuantity = totalQuantity; }
        public BigDecimal getTotalProfit() { return totalProfit; }
        public void setTotalProfit(BigDecimal totalProfit) { this.totalProfit = totalProfit; }
        public Integer getTotalOrders() { return totalOrders; }
        public void setTotalOrders(Integer totalOrders) { this.totalOrders = totalOrders; }
        public BigDecimal getProfitRate() { return profitRate; }
        public void setProfitRate(BigDecimal profitRate) { this.profitRate = profitRate; }
    }
    
    /**
     * 库存周转结果
     */
    public static class InventoryTurnoverResult {
        private BigDecimal avgInventory;
        private BigDecimal avgTurnoverDays;
        private BigDecimal totalInventoryValue;
        private Integer skuCount;
        
        public BigDecimal getAvgInventory() { return avgInventory; }
        public void setAvgInventory(BigDecimal avgInventory) { this.avgInventory = avgInventory; }
        public BigDecimal getAvgTurnoverDays() { return avgTurnoverDays; }
        public void setAvgTurnoverDays(BigDecimal avgTurnoverDays) { this.avgTurnoverDays = avgTurnoverDays; }
        public BigDecimal getTotalInventoryValue() { return totalInventoryValue; }
        public void setTotalInventoryValue(BigDecimal totalInventoryValue) { this.totalInventoryValue = totalInventoryValue; }
        public Integer getSkuCount() { return skuCount; }
        public void setSkuCount(Integer skuCount) { this.skuCount = skuCount; }
    }
}
