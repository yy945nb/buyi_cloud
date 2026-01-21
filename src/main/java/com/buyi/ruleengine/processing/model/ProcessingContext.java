package com.buyi.ruleengine.processing.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 处理执行上下文 - 存储执行过程中的变量和状态
 * Processing Execution Context - Stores variables and state during execution
 */
public class ProcessingContext {
    
    /**
     * 执行变量存储
     */
    private Map<String, Object> variables;
    
    /**
     * 执行跟踪信息
     */
    private List<ExecutionTrace> executionTraces;
    
    /**
     * 执行是否成功
     */
    private boolean success = true;
    
    /**
     * 错误信息
     */
    private String errorMessage;
    
    /**
     * 当前规则ID
     */
    private String currentRuleId;
    
    /**
     * 执行深度（用于防止无限循环）
     */
    private int executionDepth;
    
    /**
     * 执行开始时间
     */
    private long startTime;
    
    /**
     * 总执行时间（毫秒）
     */
    private long totalExecutionTime;
    
    // Constructors
    public ProcessingContext() {
        this.variables = new HashMap<>();
        this.executionTraces = new ArrayList<>();
        this.executionDepth = 0;
        this.startTime = System.currentTimeMillis();
    }
    
    public ProcessingContext(Map<String, Object> initialVariables) {
        this();
        if (initialVariables != null) {
            this.variables.putAll(initialVariables);
        }
    }
    
    // Variable operations
    public void setVariable(String name, Object value) {
        this.variables.put(name, value);
    }
    
    public Object getVariable(String name) {
        return this.variables.get(name);
    }
    
    public boolean hasVariable(String name) {
        return this.variables.containsKey(name);
    }
    
    public Map<String, Object> getAllVariables() {
        return new HashMap<>(this.variables);
    }
    
    // Execution trace operations
    public void addTrace(String ruleId, String actionId, String description, boolean success) {
        ExecutionTrace trace = new ExecutionTrace();
        trace.setRuleId(ruleId);
        trace.setActionId(actionId);
        trace.setDescription(description);
        trace.setSuccess(success);
        trace.setTimestamp(System.currentTimeMillis());
        this.executionTraces.add(trace);
    }
    
    public void incrementDepth() {
        this.executionDepth++;
    }
    
    public void decrementDepth() {
        this.executionDepth--;
    }
    
    // Getters and Setters
    public Map<String, Object> getVariables() {
        return variables;
    }
    
    public void setVariables(Map<String, Object> variables) {
        this.variables = variables;
    }
    
    public List<ExecutionTrace> getExecutionTraces() {
        return executionTraces;
    }
    
    public void setExecutionTraces(List<ExecutionTrace> executionTraces) {
        this.executionTraces = executionTraces;
    }
    
    public boolean isSuccess() {
        return success;
    }
    
    public void setSuccess(boolean success) {
        this.success = success;
    }
    
    public String getErrorMessage() {
        return errorMessage;
    }
    
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
    
    public String getCurrentRuleId() {
        return currentRuleId;
    }
    
    public void setCurrentRuleId(String currentRuleId) {
        this.currentRuleId = currentRuleId;
    }
    
    public int getExecutionDepth() {
        return executionDepth;
    }
    
    public void setExecutionDepth(int executionDepth) {
        this.executionDepth = executionDepth;
    }
    
    public long getStartTime() {
        return startTime;
    }
    
    public void setStartTime(long startTime) {
        this.startTime = startTime;
    }
    
    public long getTotalExecutionTime() {
        return totalExecutionTime;
    }
    
    public void setTotalExecutionTime(long totalExecutionTime) {
        this.totalExecutionTime = totalExecutionTime;
    }
    
    /**
     * 计算并设置总执行时间
     */
    public void finishExecution() {
        this.totalExecutionTime = System.currentTimeMillis() - this.startTime;
    }
    
    /**
     * 执行跟踪信息
     */
    public static class ExecutionTrace {
        private String ruleId;
        private String actionId;
        private String description;
        private boolean success;
        private long timestamp;
        
        public String getRuleId() {
            return ruleId;
        }
        
        public void setRuleId(String ruleId) {
            this.ruleId = ruleId;
        }
        
        public String getActionId() {
            return actionId;
        }
        
        public void setActionId(String actionId) {
            this.actionId = actionId;
        }
        
        public String getDescription() {
            return description;
        }
        
        public void setDescription(String description) {
            this.description = description;
        }
        
        public boolean isSuccess() {
            return success;
        }
        
        public void setSuccess(boolean success) {
            this.success = success;
        }
        
        public long getTimestamp() {
            return timestamp;
        }
        
        public void setTimestamp(long timestamp) {
            this.timestamp = timestamp;
        }
        
        @Override
        public String toString() {
            return "ExecutionTrace{" +
                    "ruleId='" + ruleId + '\'' +
                    ", actionId='" + actionId + '\'' +
                    ", success=" + success +
                    '}';
        }
    }
    
    @Override
    public String toString() {
        return "ProcessingContext{" +
                "variables=" + variables.keySet() +
                ", success=" + success +
                ", currentRuleId='" + currentRuleId + '\'' +
                ", executionDepth=" + executionDepth +
                ", totalExecutionTime=" + totalExecutionTime +
                '}';
    }
}
