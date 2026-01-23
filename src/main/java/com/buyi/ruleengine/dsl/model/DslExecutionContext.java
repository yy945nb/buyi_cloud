package com.buyi.ruleengine.dsl.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DSL执行上下文 - 在规则链执行过程中保持状态
 * DSL Execution Context - Maintains state during rule chain execution
 */
public class DslExecutionContext {
    
    /**
     * 输入参数
     */
    private Map<String, Object> inputParams;
    
    /**
     * 变量存储（规则执行过程中产生的变量）
     */
    private Map<String, Object> variables;
    
    /**
     * 最终结果
     */
    private Object result;
    
    /**
     * 执行是否成功
     */
    private boolean success;
    
    /**
     * 错误信息
     */
    private String errorMessage;
    
    /**
     * 当前节点ID
     */
    private String currentNodeId;
    
    /**
     * 执行深度
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
    
    /**
     * 执行追踪列表
     */
    private List<ExecutionTrace> executionTraces;
    
    /**
     * 分支执行结果（用于FORK/JOIN）
     */
    private Map<String, Object> branchResults;
    
    /**
     * 是否已终止
     */
    private boolean terminated;
    
    // Constructors
    public DslExecutionContext() {
        this.inputParams = new HashMap<>();
        this.variables = new HashMap<>();
        this.executionTraces = new ArrayList<>();
        this.branchResults = new HashMap<>();
        this.success = true;
        this.executionDepth = 0;
        this.startTime = System.currentTimeMillis();
    }
    
    public DslExecutionContext(Map<String, Object> inputParams) {
        this();
        if (inputParams != null) {
            this.inputParams.putAll(inputParams);
            this.variables.putAll(inputParams);
        }
    }
    
    /**
     * 设置变量
     */
    public void setVariable(String key, Object value) {
        variables.put(key, value);
    }
    
    /**
     * 获取变量
     */
    public Object getVariable(String key) {
        return variables.get(key);
    }
    
    /**
     * 检查变量是否存在
     */
    public boolean hasVariable(String key) {
        return variables.containsKey(key);
    }
    
    /**
     * 添加执行追踪
     */
    public void addTrace(String nodeId, String message, boolean success) {
        ExecutionTrace trace = new ExecutionTrace();
        trace.setNodeId(nodeId);
        trace.setMessage(message);
        trace.setSuccess(success);
        trace.setTimestamp(System.currentTimeMillis());
        executionTraces.add(trace);
    }
    
    /**
     * 设置分支结果
     */
    public void setBranchResult(String branchId, Object result) {
        branchResults.put(branchId, result);
    }
    
    /**
     * 获取分支结果
     */
    public Object getBranchResult(String branchId) {
        return branchResults.get(branchId);
    }
    
    /**
     * 完成执行
     */
    public void finishExecution() {
        this.totalExecutionTime = System.currentTimeMillis() - startTime;
    }
    
    /**
     * 增加执行深度
     */
    public void incrementDepth() {
        this.executionDepth++;
    }
    
    // Getters and Setters
    public Map<String, Object> getInputParams() {
        return inputParams;
    }
    
    public void setInputParams(Map<String, Object> inputParams) {
        this.inputParams = inputParams;
        if (inputParams != null) {
            this.variables.putAll(inputParams);
        }
    }
    
    public Map<String, Object> getVariables() {
        return variables;
    }
    
    public void setVariables(Map<String, Object> variables) {
        this.variables = variables;
    }
    
    public Object getResult() {
        return result;
    }
    
    public void setResult(Object result) {
        this.result = result;
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
        if (errorMessage != null) {
            this.success = false;
        }
    }
    
    public String getCurrentNodeId() {
        return currentNodeId;
    }
    
    public void setCurrentNodeId(String currentNodeId) {
        this.currentNodeId = currentNodeId;
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
    
    public List<ExecutionTrace> getExecutionTraces() {
        return executionTraces;
    }
    
    public void setExecutionTraces(List<ExecutionTrace> executionTraces) {
        this.executionTraces = executionTraces;
    }
    
    public Map<String, Object> getBranchResults() {
        return branchResults;
    }
    
    public void setBranchResults(Map<String, Object> branchResults) {
        this.branchResults = branchResults;
    }
    
    public boolean isTerminated() {
        return terminated;
    }
    
    public void setTerminated(boolean terminated) {
        this.terminated = terminated;
    }
    
    /**
     * 执行追踪
     */
    public static class ExecutionTrace {
        private String nodeId;
        private String message;
        private boolean success;
        private long timestamp;
        
        public String getNodeId() {
            return nodeId;
        }
        
        public void setNodeId(String nodeId) {
            this.nodeId = nodeId;
        }
        
        public String getMessage() {
            return message;
        }
        
        public void setMessage(String message) {
            this.message = message;
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
                    "nodeId='" + nodeId + '\'' +
                    ", message='" + message + '\'' +
                    ", success=" + success +
                    ", timestamp=" + timestamp +
                    '}';
        }
    }
    
    @Override
    public String toString() {
        return "DslExecutionContext{" +
                "currentNodeId='" + currentNodeId + '\'' +
                ", success=" + success +
                ", executionDepth=" + executionDepth +
                ", totalExecutionTime=" + totalExecutionTime +
                ", result=" + result +
                ", errorMessage='" + errorMessage + '\'' +
                '}';
    }
}
