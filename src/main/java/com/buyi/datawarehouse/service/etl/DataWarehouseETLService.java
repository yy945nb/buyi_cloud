package com.buyi.datawarehouse.service.etl;

import com.buyi.datawarehouse.model.dimension.*;
import com.buyi.datawarehouse.model.fact.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 数据仓库ETL服务
 * Data Warehouse ETL (Extract, Transform, Load) Service
 * 
 * 负责从源系统抽取数据，进行转换处理，加载到数据仓库
 */
public class DataWarehouseETLService {
    private static final Logger logger = LoggerFactory.getLogger(DataWarehouseETLService.class);
    
    /** 默认维度键，用于处理无法关联到有效维度的情况 */
    private static final Long DEFAULT_DIMENSION_KEY = 1L;
    
    private final DataSource sourceDataSource;
    private final DataSource targetDataSource;
    private int batchSize = 1000;
    
    // 维度缓存
    private Map<Long, Long> productKeyCache = new HashMap<>();
    private Map<String, Long> productSkuKeyCache = new HashMap<>();
    private Map<Long, Long> shopKeyCache = new HashMap<>();
    private Map<String, Long> shopNameKeyCache = new HashMap<>();
    private Map<Long, Long> warehouseKeyCache = new HashMap<>();
    
    public DataWarehouseETLService(DataSource sourceDataSource, DataSource targetDataSource) {
        this.sourceDataSource = sourceDataSource;
        this.targetDataSource = targetDataSource;
    }
    
    public void setBatchSize(int batchSize) {
        this.batchSize = batchSize;
    }
    
    /**
     * 执行全量同步
     */
    public void fullSync() {
        logger.info("Starting full sync...");
        long startTime = System.currentTimeMillis();
        
        try {
            // 1. 同步时间维度
            syncDateDimension();
            
            // 2. 同步商品维度
            syncProductDimension();
            
            // 3. 同步店铺维度
            syncShopDimension();
            
            // 4. 同步仓库维度
            syncWarehouseDimension();
            
            // 5. 同步销售事实
            syncSalesFact(null, null);
            
            // 6. 同步库存快照
            syncInventorySnapshot();
            
            // 7. 刷新聚合表
            refreshDailyAggregation(LocalDate.now().minusDays(30), LocalDate.now());
            
            long duration = System.currentTimeMillis() - startTime;
            logger.info("Full sync completed in {} ms", duration);
        } catch (Exception e) {
            logger.error("Full sync failed", e);
            throw new RuntimeException("Full sync failed", e);
        }
    }
    
    /**
     * 执行增量同步
     * @param startTime 开始时间
     * @param endTime 结束时间
     */
    public void incrementalSync(LocalDateTime startTime, LocalDateTime endTime) {
        logger.info("Starting incremental sync from {} to {}", startTime, endTime);
        long start = System.currentTimeMillis();
        
        try {
            // 1. 增量同步维度（只同步变更）
            incrementalSyncProductDimension(startTime);
            incrementalSyncShopDimension(startTime);
            
            // 2. 增量同步销售事实
            syncSalesFact(startTime, endTime);
            
            // 3. 刷新当天聚合
            refreshDailyAggregation(startTime.toLocalDate(), endTime.toLocalDate());
            
            long duration = System.currentTimeMillis() - start;
            logger.info("Incremental sync completed in {} ms", duration);
        } catch (Exception e) {
            logger.error("Incremental sync failed", e);
            throw new RuntimeException("Incremental sync failed", e);
        }
    }
    
    /**
     * 同步时间维度
     */
    public void syncDateDimension() {
        logger.info("Syncing date dimension...");
        
        // 生成未来一年的时间维度
        LocalDate startDate = LocalDate.now().minusYears(2);
        LocalDate endDate = LocalDate.now().plusYears(1);
        
        DimDate[] dates = DimDate.generateDateRange(startDate, endDate);
        
        String sql = "INSERT IGNORE INTO dw_dim_date (date_key, full_date, year, quarter, month, " +
                "week, day_of_month, day_of_week, day_of_year, is_weekend, is_holiday, " +
                "year_month, year_quarter) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = targetDataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            conn.setAutoCommit(false);
            int count = 0;
            
            for (DimDate date : dates) {
                ps.setInt(1, date.getDateKey());
                ps.setDate(2, Date.valueOf(date.getFullDate()));
                ps.setInt(3, date.getYear());
                ps.setInt(4, date.getQuarter());
                ps.setInt(5, date.getMonth());
                ps.setInt(6, date.getWeek());
                ps.setInt(7, date.getDayOfMonth());
                ps.setInt(8, date.getDayOfWeek());
                ps.setInt(9, date.getDayOfYear());
                ps.setInt(10, date.getIsWeekend() ? 1 : 0);
                ps.setInt(11, date.getIsHoliday() ? 1 : 0);
                ps.setString(12, date.getYearMonth());
                ps.setString(13, date.getYearQuarter());
                ps.addBatch();
                
                if (++count % batchSize == 0) {
                    ps.executeBatch();
                }
            }
            
            ps.executeBatch();
            conn.commit();
            logger.info("Synced {} date records", dates.length);
        } catch (SQLException e) {
            logger.error("Failed to sync date dimension", e);
            throw new RuntimeException(e);
        }
    }
    
    /**
     * 同步商品维度
     */
    public void syncProductDimension() {
        logger.info("Syncing product dimension...");
        
        String selectSql = "SELECT id, company_sku, company_sku_name, flag " +
                "FROM amf_jh_company_goods WHERE company_sku IS NOT NULL";
        
        String insertSql = "INSERT INTO dw_dim_product (product_id, sku_code, product_name, " +
                "status, effective_date, expiry_date, is_current) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE product_name = VALUES(product_name), status = VALUES(status)";
        
        try (Connection sourceConn = sourceDataSource.getConnection();
             Connection targetConn = targetDataSource.getConnection();
             Statement stmt = sourceConn.createStatement();
             ResultSet rs = stmt.executeQuery(selectSql);
             PreparedStatement ps = targetConn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            
            targetConn.setAutoCommit(false);
            int count = 0;
            
            while (rs.next()) {
                Long productId = rs.getLong("id");
                String skuCode = rs.getString("company_sku");
                String productName = rs.getString("company_sku_name");
                String status = rs.getString("flag");
                
                ps.setLong(1, productId);
                ps.setString(2, skuCode);
                ps.setString(3, productName);
                ps.setString(4, status);
                ps.setDate(5, Date.valueOf(LocalDate.now()));
                ps.setDate(6, Date.valueOf(LocalDate.of(9999, 12, 31)));
                ps.setInt(7, 1);
                ps.addBatch();
                
                if (++count % batchSize == 0) {
                    ps.executeBatch();
                    targetConn.commit();
                }
            }
            
            ps.executeBatch();
            targetConn.commit();
            
            // 更新缓存
            loadProductKeyCache();
            logger.info("Synced {} product records", count);
        } catch (SQLException e) {
            logger.error("Failed to sync product dimension", e);
            throw new RuntimeException(e);
        }
    }
    
    /**
     * 增量同步商品维度
     * @param since 起始时间
     */
    public void incrementalSyncProductDimension(LocalDateTime since) {
        logger.info("Incremental syncing product dimension since {}", since);
        
        String selectSql = "SELECT id, company_sku, company_sku_name, flag " +
                "FROM amf_jh_company_goods " +
                "WHERE update_time >= ? OR create_time >= ?";
        
        String insertSql = "INSERT INTO dw_dim_product (product_id, sku_code, product_name, " +
                "status, effective_date, expiry_date, is_current) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE product_name = VALUES(product_name), status = VALUES(status)";
        
        try (Connection sourceConn = sourceDataSource.getConnection();
             Connection targetConn = targetDataSource.getConnection();
             PreparedStatement selectPs = sourceConn.prepareStatement(selectSql);
             PreparedStatement insertPs = targetConn.prepareStatement(insertSql)) {
            
            Timestamp sinceTs = Timestamp.valueOf(since);
            selectPs.setTimestamp(1, sinceTs);
            selectPs.setTimestamp(2, sinceTs);
            
            ResultSet rs = selectPs.executeQuery();
            targetConn.setAutoCommit(false);
            int count = 0;
            
            while (rs.next()) {
                Long productId = rs.getLong("id");
                String skuCode = rs.getString("company_sku");
                String productName = rs.getString("company_sku_name");
                String status = rs.getString("flag");
                
                insertPs.setLong(1, productId);
                insertPs.setString(2, skuCode);
                insertPs.setString(3, productName);
                insertPs.setString(4, status);
                insertPs.setDate(5, Date.valueOf(LocalDate.now()));
                insertPs.setDate(6, Date.valueOf(LocalDate.of(9999, 12, 31)));
                insertPs.setInt(7, 1);
                insertPs.addBatch();
                
                if (++count % batchSize == 0) {
                    insertPs.executeBatch();
                    targetConn.commit();
                }
            }
            
            insertPs.executeBatch();
            targetConn.commit();
            
            // 更新缓存
            loadProductKeyCache();
            logger.info("Incremental synced {} product records", count);
        } catch (SQLException e) {
            logger.error("Failed to incremental sync product dimension", e);
            throw new RuntimeException(e);
        }
    }
    
    /**
     * 同步店铺维度
     */
    public void syncShopDimension() {
        logger.info("Syncing shop dimension...");
        
        String selectSql = "SELECT id, shop_name, platform, region " +
                "FROM amf_lx_shop WHERE shop_name IS NOT NULL";
        
        String insertSql = "INSERT INTO dw_dim_shop (shop_id, shop_code, shop_name, platform, " +
                "region, effective_date, expiry_date, is_current) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE shop_name = VALUES(shop_name), platform = VALUES(platform)";
        
        try (Connection sourceConn = sourceDataSource.getConnection();
             Connection targetConn = targetDataSource.getConnection();
             Statement stmt = sourceConn.createStatement();
             ResultSet rs = stmt.executeQuery(selectSql);
             PreparedStatement ps = targetConn.prepareStatement(insertSql)) {
            
            targetConn.setAutoCommit(false);
            int count = 0;
            
            while (rs.next()) {
                Long shopId = rs.getLong("id");
                String shopName = rs.getString("shop_name");
                String platform = rs.getString("platform");
                String region = rs.getString("region");
                
                ps.setLong(1, shopId);
                ps.setString(2, "SHOP_" + shopId);
                ps.setString(3, shopName);
                ps.setString(4, platform);
                ps.setString(5, region);
                ps.setDate(6, Date.valueOf(LocalDate.now()));
                ps.setDate(7, Date.valueOf(LocalDate.of(9999, 12, 31)));
                ps.setInt(8, 1);
                ps.addBatch();
                
                if (++count % batchSize == 0) {
                    ps.executeBatch();
                    targetConn.commit();
                }
            }
            
            ps.executeBatch();
            targetConn.commit();
            
            loadShopKeyCache();
            logger.info("Synced {} shop records", count);
        } catch (SQLException e) {
            logger.error("Failed to sync shop dimension", e);
            throw new RuntimeException(e);
        }
    }
    
    /**
     * 增量同步店铺维度
     * @param since 起始时间
     */
    public void incrementalSyncShopDimension(LocalDateTime since) {
        logger.info("Incremental syncing shop dimension since {}", since);
        // 实现类似 incrementalSyncProductDimension
        syncShopDimension(); // 简化处理，全量同步
    }
    
    /**
     * 同步仓库维度
     */
    public void syncWarehouseDimension() {
        logger.info("Syncing warehouse dimension...");
        
        String selectSql = "SELECT id, warehouse_name, warehouse_type, country, region " +
                "FROM wms_warehouse WHERE warehouse_name IS NOT NULL";
        
        String insertSql = "INSERT INTO dw_dim_warehouse (warehouse_id, warehouse_code, warehouse_name, " +
                "warehouse_type, country, region, effective_date, expiry_date, is_current) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE warehouse_name = VALUES(warehouse_name)";
        
        try (Connection sourceConn = sourceDataSource.getConnection();
             Connection targetConn = targetDataSource.getConnection();
             Statement stmt = sourceConn.createStatement();
             ResultSet rs = stmt.executeQuery(selectSql);
             PreparedStatement ps = targetConn.prepareStatement(insertSql)) {
            
            targetConn.setAutoCommit(false);
            int count = 0;
            
            while (rs.next()) {
                Long warehouseId = rs.getLong("id");
                String warehouseName = rs.getString("warehouse_name");
                String warehouseType = rs.getString("warehouse_type");
                String country = rs.getString("country");
                String region = rs.getString("region");
                
                ps.setLong(1, warehouseId);
                ps.setString(2, "WH_" + warehouseId);
                ps.setString(3, warehouseName);
                ps.setString(4, warehouseType);
                ps.setString(5, country);
                ps.setString(6, region);
                ps.setDate(7, Date.valueOf(LocalDate.now()));
                ps.setDate(8, Date.valueOf(LocalDate.of(9999, 12, 31)));
                ps.setInt(9, 1);
                ps.addBatch();
                
                if (++count % batchSize == 0) {
                    ps.executeBatch();
                    targetConn.commit();
                }
            }
            
            ps.executeBatch();
            targetConn.commit();
            
            loadWarehouseKeyCache();
            logger.info("Synced {} warehouse records", count);
        } catch (SQLException e) {
            logger.error("Failed to sync warehouse dimension", e);
            throw new RuntimeException(e);
        }
    }
    
    /**
     * 同步销售事实
     * @param startTime 开始时间（null表示全量）
     * @param endTime 结束时间（null表示当前）
     */
    public void syncSalesFact(LocalDateTime startTime, LocalDateTime endTime) {
        logger.info("Syncing sales fact...");
        
        StringBuilder selectSql = new StringBuilder();
        selectSql.append("SELECT o.id, o.order_id, o.shop, o.order_date, o.quantity, ");
        selectSql.append("o.price, o.total_amount, o.sku, o.create_time ");
        selectSql.append("FROM amf_jh_orders o ");
        selectSql.append("WHERE o.order_id IS NOT NULL ");
        
        if (startTime != null) {
            selectSql.append("AND o.create_time >= ? ");
        }
        if (endTime != null) {
            selectSql.append("AND o.create_time <= ? ");
        }
        
        String insertSql = "INSERT INTO dw_fact_sales (date_key, product_key, shop_key, " +
                "order_id, quantity, unit_price, gross_amount, net_amount, create_time, update_time) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE quantity = VALUES(quantity), gross_amount = VALUES(gross_amount)";
        
        try (Connection sourceConn = sourceDataSource.getConnection();
             Connection targetConn = targetDataSource.getConnection();
             PreparedStatement selectPs = sourceConn.prepareStatement(selectSql.toString());
             PreparedStatement insertPs = targetConn.prepareStatement(insertSql)) {
            
            int paramIndex = 1;
            if (startTime != null) {
                selectPs.setTimestamp(paramIndex++, Timestamp.valueOf(startTime));
            }
            if (endTime != null) {
                selectPs.setTimestamp(paramIndex, Timestamp.valueOf(endTime));
            }
            
            ResultSet rs = selectPs.executeQuery();
            targetConn.setAutoCommit(false);
            int count = 0;
            
            while (rs.next()) {
                String orderId = rs.getString("order_id");
                Timestamp orderDate = rs.getTimestamp("order_date");
                int quantity = rs.getInt("quantity");
                BigDecimal price = rs.getBigDecimal("price");
                BigDecimal totalAmount = rs.getBigDecimal("total_amount");
                String sku = rs.getString("sku");
                Timestamp createTime = rs.getTimestamp("create_time");
                
                // 获取日期键
                int dateKey = orderDate != null ? 
                        Integer.parseInt(orderDate.toLocalDateTime().toLocalDate()
                                .format(DateTimeFormatter.BASIC_ISO_DATE)) :
                        Integer.parseInt(LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE));
                
                // 获取维度键（通过SKU和店铺名称查找缓存）
                Long productKey = productSkuKeyCache.getOrDefault(sku, DEFAULT_DIMENSION_KEY);
                Long shopKey = DEFAULT_DIMENSION_KEY;
                
                insertPs.setInt(1, dateKey);
                insertPs.setLong(2, productKey);
                insertPs.setLong(3, shopKey);
                insertPs.setString(4, orderId);
                insertPs.setInt(5, quantity);
                insertPs.setBigDecimal(6, price != null ? price : BigDecimal.ZERO);
                insertPs.setBigDecimal(7, totalAmount != null ? totalAmount : BigDecimal.ZERO);
                insertPs.setBigDecimal(8, totalAmount != null ? totalAmount : BigDecimal.ZERO);
                insertPs.setTimestamp(9, createTime);
                insertPs.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));
                insertPs.addBatch();
                
                if (++count % batchSize == 0) {
                    insertPs.executeBatch();
                    targetConn.commit();
                }
            }
            
            insertPs.executeBatch();
            targetConn.commit();
            logger.info("Synced {} sales records", count);
        } catch (SQLException e) {
            logger.error("Failed to sync sales fact", e);
            throw new RuntimeException(e);
        }
    }
    
    /**
     * 同步库存快照
     */
    public void syncInventorySnapshot() {
        logger.info("Syncing inventory snapshot...");
        
        String selectSql = "SELECT id, warehouse_id, sku, on_hand_qty, available_qty, " +
                "reserved_qty, unit_cost FROM wms_sku_stock WHERE sku IS NOT NULL";
        
        String insertSql = "INSERT INTO dw_fact_inventory (date_key, product_key, warehouse_key, " +
                "on_hand_quantity, available_quantity, reserved_quantity, unit_cost, " +
                "inventory_value, snapshot_time) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        int dateKey = Integer.parseInt(LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE));
        
        try (Connection sourceConn = sourceDataSource.getConnection();
             Connection targetConn = targetDataSource.getConnection();
             Statement stmt = sourceConn.createStatement();
             ResultSet rs = stmt.executeQuery(selectSql);
             PreparedStatement ps = targetConn.prepareStatement(insertSql)) {
            
            targetConn.setAutoCommit(false);
            int count = 0;
            
            while (rs.next()) {
                Long warehouseId = rs.getLong("warehouse_id");
                int onHandQty = rs.getInt("on_hand_qty");
                int availableQty = rs.getInt("available_qty");
                int reservedQty = rs.getInt("reserved_qty");
                BigDecimal unitCost = rs.getBigDecimal("unit_cost");
                String sku = rs.getString("sku");
                
                Long productKey = productSkuKeyCache.getOrDefault(sku, DEFAULT_DIMENSION_KEY);
                Long warehouseKey = warehouseKeyCache.getOrDefault(warehouseId, DEFAULT_DIMENSION_KEY);
                
                BigDecimal inventoryValue = unitCost != null ? 
                        unitCost.multiply(BigDecimal.valueOf(onHandQty)) : BigDecimal.ZERO;
                
                ps.setInt(1, dateKey);
                ps.setLong(2, productKey);
                ps.setLong(3, warehouseKey);
                ps.setInt(4, onHandQty);
                ps.setInt(5, availableQty);
                ps.setInt(6, reservedQty);
                ps.setBigDecimal(7, unitCost);
                ps.setBigDecimal(8, inventoryValue);
                ps.setTimestamp(9, Timestamp.valueOf(LocalDateTime.now()));
                ps.addBatch();
                
                if (++count % batchSize == 0) {
                    ps.executeBatch();
                    targetConn.commit();
                }
            }
            
            ps.executeBatch();
            targetConn.commit();
            logger.info("Synced {} inventory records", count);
        } catch (SQLException e) {
            logger.error("Failed to sync inventory snapshot", e);
            throw new RuntimeException(e);
        }
    }
    
    /**
     * 刷新日聚合表
     * @param startDate 开始日期
     * @param endDate 结束日期
     */
    public void refreshDailyAggregation(LocalDate startDate, LocalDate endDate) {
        logger.info("Refreshing daily aggregation from {} to {}", startDate, endDate);
        
        String sql = "INSERT INTO dw_agg_sales_daily " +
                "(date_key, product_key, shop_key, order_count, quantity_sold, " +
                "gross_amount, net_amount, cost_amount, profit_amount) " +
                "SELECT date_key, product_key, shop_key, " +
                "COUNT(DISTINCT order_id), SUM(quantity), " +
                "SUM(gross_amount), SUM(net_amount), SUM(cost_amount), " +
                "SUM(profit_amount) " +
                "FROM dw_fact_sales " +
                "WHERE date_key >= ? AND date_key <= ? " +
                "GROUP BY date_key, product_key, shop_key " +
                "ON DUPLICATE KEY UPDATE " +
                "order_count = VALUES(order_count), quantity_sold = VALUES(quantity_sold), " +
                "gross_amount = VALUES(gross_amount), net_amount = VALUES(net_amount)";
        
        int startKey = Integer.parseInt(startDate.format(DateTimeFormatter.BASIC_ISO_DATE));
        int endKey = Integer.parseInt(endDate.format(DateTimeFormatter.BASIC_ISO_DATE));
        
        try (Connection conn = targetDataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, startKey);
            ps.setInt(2, endKey);
            
            int affected = ps.executeUpdate();
            logger.info("Refreshed {} daily aggregation records", affected);
        } catch (SQLException e) {
            logger.error("Failed to refresh daily aggregation", e);
            throw new RuntimeException(e);
        }
    }
    
    /**
     * 加载商品键缓存
     */
    private void loadProductKeyCache() {
        productKeyCache.clear();
        productSkuKeyCache.clear();
        String sql = "SELECT product_key, product_id, sku_code FROM dw_dim_product WHERE is_current = 1";
        
        try (Connection conn = targetDataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Long productKey = rs.getLong("product_key");
                productKeyCache.put(rs.getLong("product_id"), productKey);
                String skuCode = rs.getString("sku_code");
                if (skuCode != null) {
                    productSkuKeyCache.put(skuCode, productKey);
                }
            }
            logger.info("Loaded {} product keys to cache", productKeyCache.size());
        } catch (SQLException e) {
            logger.error("Failed to load product key cache", e);
        }
    }
    
    /**
     * 加载店铺键缓存
     */
    private void loadShopKeyCache() {
        shopKeyCache.clear();
        String sql = "SELECT shop_key, shop_id FROM dw_dim_shop WHERE is_current = 1";
        
        try (Connection conn = targetDataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                shopKeyCache.put(rs.getLong("shop_id"), rs.getLong("shop_key"));
            }
            logger.info("Loaded {} shop keys to cache", shopKeyCache.size());
        } catch (SQLException e) {
            logger.error("Failed to load shop key cache", e);
        }
    }
    
    /**
     * 加载仓库键缓存
     */
    private void loadWarehouseKeyCache() {
        warehouseKeyCache.clear();
        String sql = "SELECT warehouse_key, warehouse_id FROM dw_dim_warehouse WHERE is_current = 1";
        
        try (Connection conn = targetDataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                warehouseKeyCache.put(rs.getLong("warehouse_id"), rs.getLong("warehouse_key"));
            }
            logger.info("Loaded {} warehouse keys to cache", warehouseKeyCache.size());
        } catch (SQLException e) {
            logger.error("Failed to load warehouse key cache", e);
        }
    }
}
