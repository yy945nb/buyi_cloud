package com.buyi.sku.tag.model;

import java.util.Date;

/**
 * SKU标签结果模型
 * SKU Tag Result Model
 */
public class SkuTagResult {
    
    private Long id;
    private String skuId;
    private Long tagGroupId;
    private Long tagValueId;
    private String source; // RULE, MANUAL
    private String ruleCode;
    private Integer ruleVersion;
    private String operator;
    private String reason;
    private Integer isActive; // 0-失效，1-生效
    private Date validFrom;
    private Date validTo;
    private Date createTime;
    private Date updateTime;
    
    // Extended fields for query (not in DB)
    private String tagGroupCode;
    private String tagGroupName;
    private String tagValueCode;
    private String tagValueName;
    
    // Constructors
    public SkuTagResult() {
    }
    
    public SkuTagResult(String skuId, Long tagGroupId, Long tagValueId, String source) {
        this.skuId = skuId;
        this.tagGroupId = tagGroupId;
        this.tagValueId = tagValueId;
        this.source = source;
        this.isActive = 1;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getSkuId() {
        return skuId;
    }
    
    public void setSkuId(String skuId) {
        this.skuId = skuId;
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
    
    public String getSource() {
        return source;
    }
    
    public void setSource(String source) {
        this.source = source;
    }
    
    public String getRuleCode() {
        return ruleCode;
    }
    
    public void setRuleCode(String ruleCode) {
        this.ruleCode = ruleCode;
    }
    
    public Integer getRuleVersion() {
        return ruleVersion;
    }
    
    public void setRuleVersion(Integer ruleVersion) {
        this.ruleVersion = ruleVersion;
    }
    
    public String getOperator() {
        return operator;
    }
    
    public void setOperator(String operator) {
        this.operator = operator;
    }
    
    public String getReason() {
        return reason;
    }
    
    public void setReason(String reason) {
        this.reason = reason;
    }
    
    public Integer getIsActive() {
        return isActive;
    }
    
    public void setIsActive(Integer isActive) {
        this.isActive = isActive;
    }
    
    public Date getValidFrom() {
        return validFrom;
    }
    
    public void setValidFrom(Date validFrom) {
        this.validFrom = validFrom;
    }
    
    public Date getValidTo() {
        return validTo;
    }
    
    public void setValidTo(Date validTo) {
        this.validTo = validTo;
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
        return "SkuTagResult{" +
                "id=" + id +
                ", skuId='" + skuId + '\'' +
                ", tagGroupId=" + tagGroupId +
                ", tagValueId=" + tagValueId +
                ", source='" + source + '\'' +
                ", ruleCode='" + ruleCode + '\'' +
                ", ruleVersion=" + ruleVersion +
                ", operator='" + operator + '\'' +
                ", isActive=" + isActive +
                ", updateTime=" + updateTime +
                '}';
    }
}
