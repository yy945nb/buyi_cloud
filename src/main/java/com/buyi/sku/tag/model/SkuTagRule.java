package com.buyi.sku.tag.model;

import java.util.Date;
import java.util.Map;

/**
 * SKU标签规则模型
 * SKU Tag Rule Model
 */
public class SkuTagRule {
    
    private Long id;
    private String ruleCode;
    private String ruleName;
    private Long tagGroupId;
    private Long tagValueId;
    private String ruleType; // JAVA_EXPR, SQL_QUERY, API_CALL
    private String ruleContent;
    private Map<String, Object> ruleParams;
    private Map<String, Object> scopeConfig;
    private Integer priority;
    private Integer version;
    private String status; // DRAFT, ENABLED, DISABLED
    private String description;
    private Date createTime;
    private Date updateTime;
    private String createUser;
    private String updateUser;
    private Date publishedTime;
    private String publishedUser;
    
    // Extended fields for query (not in DB)
    private String tagGroupCode;
    private String tagGroupName;
    private String tagValueCode;
    private String tagValueName;
    
    // Constructors
    public SkuTagRule() {
    }
    
    public SkuTagRule(String ruleCode, String ruleName, Long tagGroupId, Long tagValueId, 
                      String ruleType, String ruleContent) {
        this.ruleCode = ruleCode;
        this.ruleName = ruleName;
        this.tagGroupId = tagGroupId;
        this.tagValueId = tagValueId;
        this.ruleType = ruleType;
        this.ruleContent = ruleContent;
        this.version = 1;
        this.status = "DRAFT";
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
    
    public Long getTagGroupId() {
        return tagGroupId;
    }
    
    public void setTagGroupId(Long tagGroupId) {
        this.tagGroupId = tagGroupId;
    }
    
    public Long getTagValueId() {
        return tagValueId;
    }
    
    public void setTagValueId(Long tagValueId) {
        this.tagValueId = tagValueId;
    }
    
    public String getRuleType() {
        return ruleType;
    }
    
    public void setRuleType(String ruleType) {
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
    
    public Map<String, Object> getScopeConfig() {
        return scopeConfig;
    }
    
    public void setScopeConfig(Map<String, Object> scopeConfig) {
        this.scopeConfig = scopeConfig;
    }
    
    public Integer getPriority() {
        return priority;
    }
    
    public void setPriority(Integer priority) {
        this.priority = priority;
    }
    
    public Integer getVersion() {
        return version;
    }
    
    public void setVersion(Integer version) {
        this.version = version;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
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
    
    public Date getPublishedTime() {
        return publishedTime;
    }
    
    public void setPublishedTime(Date publishedTime) {
        this.publishedTime = publishedTime;
    }
    
    public String getPublishedUser() {
        return publishedUser;
    }
    
    public void setPublishedUser(String publishedUser) {
        this.publishedUser = publishedUser;
    }
    
    public String getTagGroupCode() {
        return tagGroupCode;
    }
    
    public void setTagGroupCode(String tagGroupCode) {
        this.tagGroupCode = tagGroupCode;
    }
    
    public String getTagGroupName() {
        return tagGroupName;
    }
    
    public void setTagGroupName(String tagGroupName) {
        this.tagGroupName = tagGroupName;
    }
    
    public String getTagValueCode() {
        return tagValueCode;
    }
    
    public void setTagValueCode(String tagValueCode) {
        this.tagValueCode = tagValueCode;
    }
    
    public String getTagValueName() {
        return tagValueName;
    }
    
    public void setTagValueName(String tagValueName) {
        this.tagValueName = tagValueName;
    }
    
    @Override
    public String toString() {
        return "SkuTagRule{" +
                "id=" + id +
                ", ruleCode='" + ruleCode + '\'' +
                ", ruleName='" + ruleName + '\'' +
                ", tagGroupId=" + tagGroupId +
                ", tagValueId=" + tagValueId +
                ", ruleType='" + ruleType + '\'' +
                ", priority=" + priority +
                ", version=" + version +
                ", status='" + status + '\'' +
                '}';
    }
}
