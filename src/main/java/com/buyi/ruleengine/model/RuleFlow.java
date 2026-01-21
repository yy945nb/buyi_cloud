package com.buyi.ruleengine.model;

import java.util.List;
import java.util.Map;

/**
 * 规则流程配置
 * Rule Flow Configuration
 */
public class RuleFlow {
    
    private Long id;
    private String flowCode;
    private String flowName;
    private List<FlowStep> steps;
    private String description;
    private Integer status;
    
    // Constructors
    public RuleFlow() {
    }
    
    public RuleFlow(String flowCode, String flowName, List<FlowStep> steps) {
        this.flowCode = flowCode;
        this.flowName = flowName;
        this.steps = steps;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getFlowCode() {
        return flowCode;
    }
    
    public void setFlowCode(String flowCode) {
        this.flowCode = flowCode;
    }
    
    public String getFlowName() {
        return flowName;
    }
    
    public void setFlowName(String flowName) {
        this.flowName = flowName;
    }
    
    public List<FlowStep> getSteps() {
        return steps;
    }
    
    public void setSteps(List<FlowStep> steps) {
        this.steps = steps;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Integer getStatus() {
        return status;
    }
    
    public void setStatus(Integer status) {
        this.status = status;
    }
    
    /**
     * 流程步骤
     */
    public static class FlowStep {
        private int step;
        private String ruleCode;
        private String condition;
        private String onSuccess;
        private String onFailure;
        
        // Getters and Setters
        public int getStep() {
            return step;
        }
        
        public void setStep(int step) {
            this.step = step;
        }
        
        public String getRuleCode() {
            return ruleCode;
        }
        
        public void setRuleCode(String ruleCode) {
            this.ruleCode = ruleCode;
        }
        
        public String getCondition() {
            return condition;
        }
        
        public void setCondition(String condition) {
            this.condition = condition;
        }
        
        public String getOnSuccess() {
            return onSuccess;
        }
        
        public void setOnSuccess(String onSuccess) {
            this.onSuccess = onSuccess;
        }
        
        public String getOnFailure() {
            return onFailure;
        }
        
        public void setOnFailure(String onFailure) {
            this.onFailure = onFailure;
        }
        
        @Override
        public String toString() {
            return "FlowStep{" +
                    "step=" + step +
                    ", ruleCode='" + ruleCode + '\'' +
                    ", condition='" + condition + '\'' +
                    ", onSuccess='" + onSuccess + '\'' +
                    ", onFailure='" + onFailure + '\'' +
                    '}';
        }
    }
    
    @Override
    public String toString() {
        return "RuleFlow{" +
                "id=" + id +
                ", flowCode='" + flowCode + '\'' +
                ", flowName='" + flowName + '\'' +
                ", steps=" + steps +
                ", description='" + description + '\'' +
                ", status=" + status +
                '}';
    }
}
