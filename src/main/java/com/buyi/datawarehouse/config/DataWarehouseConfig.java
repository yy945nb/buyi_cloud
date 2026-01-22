package com.buyi.datawarehouse.config;

/**
 * 数据仓库配置类
 * Data Warehouse Configuration
 */
public class DataWarehouseConfig {
    
    /** 源数据库JDBC URL */
    private String sourceJdbcUrl;
    
    /** 源数据库用户名 */
    private String sourceUsername;
    
    /** 源数据库密码 */
    private String sourcePassword;
    
    /** 目标数据库JDBC URL */
    private String targetJdbcUrl;
    
    /** 目标数据库用户名 */
    private String targetUsername;
    
    /** 目标数据库密码 */
    private String targetPassword;
    
    /** ETL批次大小 */
    private int etlBatchSize = 1000;
    
    /** 同步间隔（分钟） */
    private int syncIntervalMinutes = 30;
    
    /** 是否启用增量同步 */
    private boolean incrementalSyncEnabled = true;
    
    /** 并行线程数 */
    private int parallelThreads = 4;
    
    /** 数据保留天数 */
    private int dataRetentionDays = 365;
    
    public DataWarehouseConfig() {
    }
    
    /**
     * 创建Builder
     * @return Builder实例
     */
    public static Builder builder() {
        return new Builder();
    }
    
    /**
     * Builder模式
     */
    public static class Builder {
        private final DataWarehouseConfig config = new DataWarehouseConfig();
        
        public Builder sourceUrl(String url) {
            config.sourceJdbcUrl = url;
            return this;
        }
        
        public Builder sourceUser(String user) {
            config.sourceUsername = user;
            return this;
        }
        
        public Builder sourcePassword(String password) {
            config.sourcePassword = password;
            return this;
        }
        
        public Builder targetUrl(String url) {
            config.targetJdbcUrl = url;
            return this;
        }
        
        public Builder targetUser(String user) {
            config.targetUsername = user;
            return this;
        }
        
        public Builder targetPassword(String password) {
            config.targetPassword = password;
            return this;
        }
        
        public Builder etlBatchSize(int size) {
            config.etlBatchSize = size;
            return this;
        }
        
        public Builder syncIntervalMinutes(int minutes) {
            config.syncIntervalMinutes = minutes;
            return this;
        }
        
        public Builder incrementalSyncEnabled(boolean enabled) {
            config.incrementalSyncEnabled = enabled;
            return this;
        }
        
        public Builder parallelThreads(int threads) {
            config.parallelThreads = threads;
            return this;
        }
        
        public Builder dataRetentionDays(int days) {
            config.dataRetentionDays = days;
            return this;
        }
        
        public DataWarehouseConfig build() {
            return config;
        }
    }

    // Getters and Setters
    
    public String getSourceJdbcUrl() {
        return sourceJdbcUrl;
    }

    public void setSourceJdbcUrl(String sourceJdbcUrl) {
        this.sourceJdbcUrl = sourceJdbcUrl;
    }

    public String getSourceUsername() {
        return sourceUsername;
    }

    public void setSourceUsername(String sourceUsername) {
        this.sourceUsername = sourceUsername;
    }

    public String getSourcePassword() {
        return sourcePassword;
    }

    public void setSourcePassword(String sourcePassword) {
        this.sourcePassword = sourcePassword;
    }

    public String getTargetJdbcUrl() {
        return targetJdbcUrl;
    }

    public void setTargetJdbcUrl(String targetJdbcUrl) {
        this.targetJdbcUrl = targetJdbcUrl;
    }

    public String getTargetUsername() {
        return targetUsername;
    }

    public void setTargetUsername(String targetUsername) {
        this.targetUsername = targetUsername;
    }

    public String getTargetPassword() {
        return targetPassword;
    }

    public void setTargetPassword(String targetPassword) {
        this.targetPassword = targetPassword;
    }

    public int getEtlBatchSize() {
        return etlBatchSize;
    }

    public void setEtlBatchSize(int etlBatchSize) {
        this.etlBatchSize = etlBatchSize;
    }

    public int getSyncIntervalMinutes() {
        return syncIntervalMinutes;
    }

    public void setSyncIntervalMinutes(int syncIntervalMinutes) {
        this.syncIntervalMinutes = syncIntervalMinutes;
    }

    public boolean isIncrementalSyncEnabled() {
        return incrementalSyncEnabled;
    }

    public void setIncrementalSyncEnabled(boolean incrementalSyncEnabled) {
        this.incrementalSyncEnabled = incrementalSyncEnabled;
    }

    public int getParallelThreads() {
        return parallelThreads;
    }

    public void setParallelThreads(int parallelThreads) {
        this.parallelThreads = parallelThreads;
    }

    public int getDataRetentionDays() {
        return dataRetentionDays;
    }

    public void setDataRetentionDays(int dataRetentionDays) {
        this.dataRetentionDays = dataRetentionDays;
    }
    
    @Override
    public String toString() {
        return "DataWarehouseConfig{" +
                "sourceJdbcUrl='" + sourceJdbcUrl + '\'' +
                ", targetJdbcUrl='" + targetJdbcUrl + '\'' +
                ", etlBatchSize=" + etlBatchSize +
                ", syncIntervalMinutes=" + syncIntervalMinutes +
                ", incrementalSyncEnabled=" + incrementalSyncEnabled +
                ", parallelThreads=" + parallelThreads +
                '}';
    }
}
