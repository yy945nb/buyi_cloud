package com.buyi.ruleengine.processing.model;

import java.util.Map;

/**
 * 处理动作模型 - 对应processing.json中的单个动作定义
 * Processing Action Model - Corresponds to a single action definition in processing.json
 */
public class ProcessingAction {
    
    /**
     * 动作ID
     */
    private String actionId;
    
    /**
     * 动作类型（SCRIPT, API等）
     */
    private ActionType type;
    
    /**
     * 动作配置
     */
    private Map<String, Object> config;
    
    /**
     * 输出变量名
     */
    private String outputVariable;
    
    /**
     * 输出表达式（用于从结果中提取特定值）
     */
    private String outputExpression;
    
    /**
     * 错误时是否继续执行
     */
    private boolean continueOnError;
    
    // Constructors
    public ProcessingAction() {
    }
    
    // Getters and Setters
    public String getActionId() {
        return actionId;
    }
    
    public void setActionId(String actionId) {
        this.actionId = actionId;
    }
    
    public ActionType getType() {
        return type;
    }
    
    public void setType(ActionType type) {
        this.type = type;
    }
    
    public Map<String, Object> getConfig() {
        return config;
    }
    
    public void setConfig(Map<String, Object> config) {
        this.config = config;
    }
    
    public String getOutputVariable() {
        return outputVariable;
    }
    
    public void setOutputVariable(String outputVariable) {
        this.outputVariable = outputVariable;
    }
    
    public String getOutputExpression() {
        return outputExpression;
    }
    
    public void setOutputExpression(String outputExpression) {
        this.outputExpression = outputExpression;
    }
    
    public boolean isContinueOnError() {
        return continueOnError;
    }
    
    public void setContinueOnError(boolean continueOnError) {
        this.continueOnError = continueOnError;
    }
    
    /**
     * 动作类型枚举
     */
    public enum ActionType {
        /**
         * 脚本表达式
         */
        SCRIPT,
        
        /**
         * API调用
         */
        API,
        
        /**
         * SQL查询
         */
        SQL
    }
    
    @Override
    public String toString() {
        return "ProcessingAction{" +
                "actionId='" + actionId + '\'' +
                ", type=" + type +
                ", outputVariable='" + outputVariable + '\'' +
                ", continueOnError=" + continueOnError +
                '}';
    }
}
