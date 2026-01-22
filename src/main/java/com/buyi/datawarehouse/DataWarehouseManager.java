package com.buyi.datawarehouse;

import com.buyi.datawarehouse.config.DataWarehouseConfig;
import com.buyi.datawarehouse.service.etl.DataWarehouseETLService;
import com.buyi.datawarehouse.service.olap.OlapAnalysisService;
import com.mysql.cj.jdbc.MysqlDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.time.LocalDateTime;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * 数据仓库管理器
 * Data Warehouse Manager
 * 
 * 统一管理数据仓库的ETL同步、OLAP分析等功能
 */
public class DataWarehouseManager {
    private static final Logger logger = LoggerFactory.getLogger(DataWarehouseManager.class);
    
    private final DataWarehouseConfig config;
    private final DataSource sourceDataSource;
    private final DataSource targetDataSource;
    private final DataWarehouseETLService etlService;
    private final OlapAnalysisService olapService;
    private ScheduledExecutorService scheduler;
    
    private LocalDateTime lastSyncTime;
    private volatile boolean syncRunning = false;
    
    public DataWarehouseManager(DataWarehouseConfig config) {
        this.config = config;
        this.sourceDataSource = createDataSource(
                config.getSourceJdbcUrl(),
                config.getSourceUsername(),
                config.getSourcePassword());
        this.targetDataSource = createDataSource(
                config.getTargetJdbcUrl(),
                config.getTargetUsername(),
                config.getTargetPassword());
        
        this.etlService = new DataWarehouseETLService(sourceDataSource, targetDataSource);
        this.etlService.setBatchSize(config.getEtlBatchSize());
        
        this.olapService = new OlapAnalysisService(targetDataSource);
    }
    
    /**
     * 创建数据源
     */
    private DataSource createDataSource(String url, String username, String password) {
        MysqlDataSource dataSource = new MysqlDataSource();
        dataSource.setURL(url);
        dataSource.setUser(username);
        dataSource.setPassword(password);
        return dataSource;
    }
    
    /**
     * 执行初始同步（全量）
     */
    public void initialSync() {
        logger.info("Starting initial sync...");
        try {
            syncRunning = true;
            etlService.fullSync();
            lastSyncTime = LocalDateTime.now();
            logger.info("Initial sync completed at {}", lastSyncTime);
        } catch (Exception e) {
            logger.error("Initial sync failed", e);
            throw e;
        } finally {
            syncRunning = false;
        }
    }
    
    /**
     * 执行增量同步
     */
    public void doIncrementalSync() {
        if (syncRunning) {
            logger.warn("Sync is already running, skipping...");
            return;
        }
        
        logger.info("Starting incremental sync...");
        try {
            syncRunning = true;
            LocalDateTime syncStart = lastSyncTime != null ? 
                    lastSyncTime : LocalDateTime.now().minusHours(1);
            LocalDateTime syncEnd = LocalDateTime.now();
            
            etlService.incrementalSync(syncStart, syncEnd);
            lastSyncTime = syncEnd;
            logger.info("Incremental sync completed at {}", lastSyncTime);
        } catch (Exception e) {
            logger.error("Incremental sync failed", e);
        } finally {
            syncRunning = false;
        }
    }
    
    /**
     * 启动定时同步
     */
    public void startScheduledSync() {
        if (scheduler != null && !scheduler.isShutdown()) {
            logger.warn("Scheduler is already running");
            return;
        }
        
        scheduler = Executors.newScheduledThreadPool(1);
        int intervalMinutes = config.getSyncIntervalMinutes();
        
        scheduler.scheduleAtFixedRate(
                this::doIncrementalSync,
                intervalMinutes,
                intervalMinutes,
                TimeUnit.MINUTES);
        
        logger.info("Scheduled sync started with interval {} minutes", intervalMinutes);
    }
    
    /**
     * 停止定时同步
     */
    public void stopScheduledSync() {
        if (scheduler != null) {
            scheduler.shutdown();
            try {
                if (!scheduler.awaitTermination(60, TimeUnit.SECONDS)) {
                    scheduler.shutdownNow();
                }
            } catch (InterruptedException e) {
                scheduler.shutdownNow();
                Thread.currentThread().interrupt();
            }
            logger.info("Scheduled sync stopped");
        }
    }
    
    /**
     * 获取同步状态
     * @return 同步状态
     */
    public SyncStatus getSyncStatus() {
        SyncStatus status = new SyncStatus();
        status.setLastSyncTime(lastSyncTime);
        status.setSyncRunning(syncRunning);
        status.setSchedulerRunning(scheduler != null && !scheduler.isShutdown());
        status.setSyncIntervalMinutes(config.getSyncIntervalMinutes());
        return status;
    }
    
    /**
     * 获取ETL服务
     * @return ETL服务
     */
    public DataWarehouseETLService getEtlService() {
        return etlService;
    }
    
    /**
     * 获取OLAP服务
     * @return OLAP服务
     */
    public OlapAnalysisService getOlapService() {
        return olapService;
    }
    
    /**
     * 关闭管理器
     */
    public void shutdown() {
        stopScheduledSync();
        logger.info("DataWarehouseManager shutdown completed");
    }
    
    /**
     * 同步状态类
     */
    public static class SyncStatus {
        private LocalDateTime lastSyncTime;
        private boolean syncRunning;
        private boolean schedulerRunning;
        private int syncIntervalMinutes;
        
        public LocalDateTime getLastSyncTime() { return lastSyncTime; }
        public void setLastSyncTime(LocalDateTime lastSyncTime) { this.lastSyncTime = lastSyncTime; }
        public boolean isSyncRunning() { return syncRunning; }
        public void setSyncRunning(boolean syncRunning) { this.syncRunning = syncRunning; }
        public boolean isSchedulerRunning() { return schedulerRunning; }
        public void setSchedulerRunning(boolean schedulerRunning) { this.schedulerRunning = schedulerRunning; }
        public int getSyncIntervalMinutes() { return syncIntervalMinutes; }
        public void setSyncIntervalMinutes(int syncIntervalMinutes) { this.syncIntervalMinutes = syncIntervalMinutes; }
        
        @Override
        public String toString() {
            return "SyncStatus{" +
                    "lastSyncTime=" + lastSyncTime +
                    ", syncRunning=" + syncRunning +
                    ", schedulerRunning=" + schedulerRunning +
                    ", syncIntervalMinutes=" + syncIntervalMinutes +
                    '}';
        }
    }
}
