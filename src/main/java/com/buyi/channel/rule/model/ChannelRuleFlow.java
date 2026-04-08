package com.buyi.channel.rule.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * 渠道规则流程配置
 * Channel Rule Flow Configuration
 *
 * 合并优化说明：
 * - 继承RuleFlow的flowCode/steps基本结构
 * - 融合DslRuleChain的maxExecutionDepth/executionTimeout安全限制
 * - 融合ProcessingConfig的entryPoint概念
 * - FlowStep增加了priority字段，支持独立于规则的步骤优先级
 */
public class ChannelRuleFlow {

    private String flowCode;
    private String flowName;
    private List<FlowStep> steps;
    private String description;
    private Integer status;
    private int maxExecutionDepth;
    private long executionTimeoutMs;

    public ChannelRuleFlow() {
        this.steps = new ArrayList<>();
        this.status = 1;
        this.maxExecutionDepth = 100;
        this.executionTimeoutMs = 60000;
    }

    public ChannelRuleFlow(String flowCode, String flowName) {
        this();
        this.flowCode = flowCode;
        this.flowName = flowName;
    }

    public void addStep(FlowStep step) {
        if (step != null) {
            this.steps.add(step);
        }
    }

    // Getters and Setters
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
        this.steps = steps != null ? steps : new ArrayList<>();
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

    public int getMaxExecutionDepth() {
        return maxExecutionDepth;
    }

    public void setMaxExecutionDepth(int maxExecutionDepth) {
        this.maxExecutionDepth = maxExecutionDepth;
    }

    public long getExecutionTimeoutMs() {
        return executionTimeoutMs;
    }

    public void setExecutionTimeoutMs(long executionTimeoutMs) {
        this.executionTimeoutMs = executionTimeoutMs;
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
        private int priority;

        public FlowStep() {
            this.onSuccess = "next";
            this.onFailure = "abort";
            this.priority = 0;
        }

        public FlowStep(int step, String ruleCode) {
            this();
            this.step = step;
            this.ruleCode = ruleCode;
        }

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

        public int getPriority() {
            return priority;
        }

        public void setPriority(int priority) {
            this.priority = priority;
        }

        @Override
        public String toString() {
            return "FlowStep{step=" + step + ", ruleCode='" + ruleCode + "', priority=" + priority + '}';
        }
    }

    @Override
    public String toString() {
        return "ChannelRuleFlow{flowCode='" + flowCode + "', flowName='" + flowName +
                "', steps=" + (steps != null ? steps.size() : 0) + '}';
    }
}
