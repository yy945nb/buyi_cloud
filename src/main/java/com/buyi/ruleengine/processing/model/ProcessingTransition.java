package com.buyi.ruleengine.processing.model;

/**
 * 处理转换模型 - 对应processing.json中的规则转换定义
 * Processing Transition Model - Corresponds to a rule transition definition in processing.json
 */
public class ProcessingTransition {
    
    /**
     * 转换条件表达式
     */
    private String condition;
    
    /**
     * 目标规则ID
     */
    private String targetRule;
    
    /**
     * 优先级（数字越小优先级越高）
     */
    private int priority;
    
    // Constructors
    public ProcessingTransition() {
    }
    
    public ProcessingTransition(String condition, String targetRule, int priority) {
        this.condition = condition;
        this.targetRule = targetRule;
        this.priority = priority;
    }
    
    // Getters and Setters
    public String getCondition() {
        return condition;
    }
    
    public void setCondition(String condition) {
        this.condition = condition;
    }
    
    public String getTargetRule() {
        return targetRule;
    }
    
    public void setTargetRule(String targetRule) {
        this.targetRule = targetRule;
    }
    
    public int getPriority() {
        return priority;
    }
    
    public void setPriority(int priority) {
        this.priority = priority;
    }
    
    @Override
    public String toString() {
        return "ProcessingTransition{" +
                "condition='" + condition + '\'' +
                ", targetRule='" + targetRule + '\'' +
                ", priority=" + priority +
                '}';
    }
}
