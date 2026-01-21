package com.buyi.ruleengine.model;

import com.buyi.ruleengine.enums.RuleType;

import java.util.Date;
import java.util.Map;

/**
 * 规则配置模型
 * Rule Configuration Model
 */
public class RuleConfig {

    private Long id;
    private String ruleCode;
    private String ruleName;
    private RuleType ruleType;
    private String ruleContent;
    private Map<String, Object> ruleParams;
    private String description;
    private Integer status;
    private Integer priority;
    private Date createTime;
    private Date updateTime;
    private String createUser;
    private String updateUser;

    // Constructors
    public RuleConfig() {
    }

    public RuleConfig(String ruleCode, String ruleName, RuleType ruleType, String ruleContent) {
        this.ruleCode = ruleCode;
        this.ruleName = ruleName;
        this.ruleType = ruleType;
        this.ruleContent = ruleContent;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

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

    public RuleType getRuleType() {
        return ruleType;
    }

    public void setRuleType(RuleType ruleType) {
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

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Date getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }

    public String getCreateUser() {
        return createUser;
    }

    public void setCreateUser(String createUser) {
        this.createUser = createUser;
    }

    public String getUpdateUser() {
        return updateUser;
    }

    public void setUpdateUser(String updateUser) {
        this.updateUser = updateUser;
    }

    @Override
    public String toString() {
        return "RuleConfig{" +
                "id=" + id +
                ", ruleCode='" + ruleCode + '\'' +
                ", ruleName='" + ruleName + '\'' +
                ", ruleType=" + ruleType +
                ", ruleContent='" + ruleContent + '\'' +
                ", description='" + description + '\'' +
                ", status=" + status +
                ", priority=" + priority +
                '}';
    }
}
