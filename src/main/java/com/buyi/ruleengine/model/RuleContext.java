package com.buyi.ruleengine.model;

import java.util.Map;

/**
 * 规则执行上下文
 * Rule Execution Context
 */
public class RuleContext {
    
    /**
     * 输入参数
     */
    private Map<String, Object> inputParams;
    
    /**
     * 输出结果
     */
    private Object result;
    
    /**
     * 执行状态
     */
    private boolean success;
    
    /**
     * 错误信息
     */
    private String errorMessage;
    
    /**
     * 执行时间（毫秒）
     */
    private Long executionTime;
    
    public RuleContext() {
    }
    
    public RuleContext(Map<String, Object> inputParams) {
        this.inputParams = inputParams;
    }
    
    // Getters and Setters
    public Map<String, Object> getInputParams() {
        return inputParams;
    }
    
    public void setInputParams(Map<String, Object> inputParams) {
        this.inputParams = inputParams;
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
    }
    
    public Long getExecutionTime() {
        return executionTime;
    }
    
    public void setExecutionTime(Long executionTime) {
        this.executionTime = executionTime;
    }
    
    /**
     * 获取输入参数值
     */
    public Object getInput(String key) {
        return inputParams != null ? inputParams.get(key) : null;
    }
    
    /**
     * 设置输入参数值
     */
    public void setInput(String key, Object value) {
        if (inputParams != null) {
            inputParams.put(key, value);
        }
    }
    
    @Override
    public String toString() {
        return "RuleContext{" +
                "inputParams=" + inputParams +
                ", result=" + result +
                ", success=" + success +
                ", errorMessage='" + errorMessage + '\'' +
                ", executionTime=" + executionTime +
                '}';
    }
}
