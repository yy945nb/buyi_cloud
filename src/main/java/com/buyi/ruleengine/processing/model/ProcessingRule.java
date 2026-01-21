package com.buyi.ruleengine.processing.model;

import java.util.List;

/**
 * 处理规则模型 - 对应processing.json中的单个规则定义
 * Processing Rule Model - Corresponds to a single rule definition in processing.json
 */
public class ProcessingRule {
    
    /**
     * 规则ID（唯一标识）
     */
    private String ruleId;
    
    /**
     * 规则描述
     */
    private String description;
    
    /**
     * 是否为终止节点（不再进行转换）
     */
    private boolean terminal;
    
    /**
     * 规则中的动作列表
     */
    private List<ProcessingAction> actions;
    
    /**
     * 规则转换列表（条件跳转）
     */
    private List<ProcessingTransition> transitions;
    
    // Constructors
    public ProcessingRule() {
    }
    
    // Getters and Setters
    public String getRuleId() {
        return ruleId;
    }
    
    public void setRuleId(String ruleId) {
        this.ruleId = ruleId;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public boolean isTerminal() {
        return terminal;
    }
    
    public void setTerminal(boolean terminal) {
        this.terminal = terminal;
    }
    
    public List<ProcessingAction> getActions() {
        return actions;
    }
    
    public void setActions(List<ProcessingAction> actions) {
        this.actions = actions;
    }
    
    public List<ProcessingTransition> getTransitions() {
        return transitions;
    }
    
    public void setTransitions(List<ProcessingTransition> transitions) {
        this.transitions = transitions;
    }
    
    @Override
    public String toString() {
        return "ProcessingRule{" +
                "ruleId='" + ruleId + '\'' +
                ", description='" + description + '\'' +
                ", terminal=" + terminal +
                ", actions=" + (actions != null ? actions.size() : 0) +
                ", transitions=" + (transitions != null ? transitions.size() : 0) +
                '}';
    }
}
