package com.buyi.channel.rule.model;

import com.buyi.channel.rule.enums.ChannelRuleType;

import java.util.HashMap;
import java.util.Map;

/**
 * 渠道规则配置模型
 * Channel Rule Configuration Model
 *
 * 合并优化说明：
 * - 继承buyi_cloud RuleConfig的基本字段（ruleCode, ruleType, ruleContent, priority, status）
 * - 融合DslNode的retryCount和timeout特性（buyi_cloud中定义了但未真正使用）
 * - 融合ProcessingAction的continueOnError和outputVariable特性
 * - 新增maxRetries和retryDelayMs，实现真正的重试机制
 * - 新增tags用于规则分组和过滤
 */
public class ChannelRule {

    private String ruleCode;
    private String ruleName;
    private ChannelRuleType ruleType;
    private String ruleContent;
    private Map<String, Object> ruleParams;
    private String description;
    private Integer status;
    private Integer priority;
    private String outputVariable;
    private boolean continueOnError;
    private int maxRetries;
    private long retryDelayMs;
    private long timeoutMs;
    private String[] tags;

    public ChannelRule() {
        this.status = 1;
        this.priority = 0;
        this.continueOnError = false;
        this.maxRetries = 0;
        this.retryDelayMs = 1000;
        this.timeoutMs = 30000;
        this.ruleParams = new HashMap<>();
    }

    public ChannelRule(String ruleCode, String ruleName, ChannelRuleType ruleType, String ruleContent) {
        this();
        this.ruleCode = ruleCode;
        this.ruleName = ruleName;
        this.ruleType = ruleType;
        this.ruleContent = ruleContent;
    }

    // Getters and Setters
    public String getRuleCode() {
        return ruleCode;
    }

    public void setRuleCode(String ruleCode) {
        this.ruleCode = ruleCode;
    }

    public String getRuleName() {
        return ruleName;
    }

    public void setRuleName(String ruleName) {
        this.ruleName = ruleName;
    }

    public ChannelRuleType getRuleType() {
        return ruleType;
    }

    public void setRuleType(ChannelRuleType ruleType) {
        this.ruleType = ruleType;
    }

    public String getRuleContent() {
        return ruleContent;
    }

    public void setRuleContent(String ruleContent) {
        this.ruleContent = ruleContent;
    }

    public Map<String, Object> getRuleParams() {
        return ruleParams;
    }

    public void setRuleParams(Map<String, Object> ruleParams) {
        this.ruleParams = ruleParams;
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

    public Integer getPriority() {
        return priority;
    }

    public void setPriority(Integer priority) {
        this.priority = priority;
    }

    public String getOutputVariable() {
        return outputVariable;
    }

    public void setOutputVariable(String outputVariable) {
        this.outputVariable = outputVariable;
    }

    public boolean isContinueOnError() {
        return continueOnError;
    }

    public void setContinueOnError(boolean continueOnError) {
        this.continueOnError = continueOnError;
    }

    public int getMaxRetries() {
        return maxRetries;
    }

    public void setMaxRetries(int maxRetries) {
        this.maxRetries = maxRetries;
    }

    public long getRetryDelayMs() {
        return retryDelayMs;
    }

    public void setRetryDelayMs(long retryDelayMs) {
        this.retryDelayMs = retryDelayMs;
    }

    public long getTimeoutMs() {
        return timeoutMs;
    }

    public void setTimeoutMs(long timeoutMs) {
        this.timeoutMs = timeoutMs;
    }

    public String[] getTags() {
        return tags;
    }

    public void setTags(String[] tags) {
        this.tags = tags;
    }

    public boolean isEnabled() {
        return status != null && status == 1;
    }

    @Override
    public String toString() {
        return "ChannelRule{" +
                "ruleCode='" + ruleCode + '\'' +
                ", ruleName='" + ruleName + '\'' +
                ", ruleType=" + ruleType +
                ", priority=" + priority +
                ", maxRetries=" + maxRetries +
                ", timeoutMs=" + timeoutMs +
                '}';
    }
}
