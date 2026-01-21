package com.buyi.ruleengine.processing.model;

import java.util.List;

/**
 * 流程配置模型 - 对应processing.json的根结构
 * Processing Configuration Model - Corresponds to the root structure of processing.json
 */
public class ProcessingConfig {
    
    /**
     * 配置版本
     */
    private String version;
    
    /**
     * 入口规则ID
     */
    private String entryPoint;
    
    /**
     * 全局设置
     */
    private GlobalSettings globalSettings;
    
    /**
     * 规则列表
     */
    private List<ProcessingRule> rules;
    
    // Constructors
    public ProcessingConfig() {
    }
    
    // Getters and Setters
    public String getVersion() {
        return version;
    }
    
    public void setVersion(String version) {
        this.version = version;
    }
    
    public String getEntryPoint() {
        return entryPoint;
    }
    
    public void setEntryPoint(String entryPoint) {
        this.entryPoint = entryPoint;
    }
    
    public GlobalSettings getGlobalSettings() {
        return globalSettings;
    }
    
    public void setGlobalSettings(GlobalSettings globalSettings) {
        this.globalSettings = globalSettings;
    }
    
    public List<ProcessingRule> getRules() {
        return rules;
    }
    
    public void setRules(List<ProcessingRule> rules) {
        this.rules = rules;
    }
    
    /**
     * 全局设置
     */
    public static class GlobalSettings {
        /**
         * 最大执行深度（防止无限循环）
         */
        private int maxExecutionDepth = 50;
        
        /**
         * 超时时间（毫秒）
         */
        private long timeout = 30000;
        
        public int getMaxExecutionDepth() {
            return maxExecutionDepth;
        }
        
        public void setMaxExecutionDepth(int maxExecutionDepth) {
            this.maxExecutionDepth = maxExecutionDepth;
        }
        
        public long getTimeout() {
            return timeout;
        }
        
        public void setTimeout(long timeout) {
            this.timeout = timeout;
        }
        
        @Override
        public String toString() {
            return "GlobalSettings{" +
                    "maxExecutionDepth=" + maxExecutionDepth +
                    ", timeout=" + timeout +
                    '}';
        }
    }
    
    @Override
    public String toString() {
        return "ProcessingConfig{" +
                "version='" + version + '\'' +
                ", entryPoint='" + entryPoint + '\'' +
                ", globalSettings=" + globalSettings +
                ", rules=" + (rules != null ? rules.size() + " rules" : "null") +
                '}';
    }
}
