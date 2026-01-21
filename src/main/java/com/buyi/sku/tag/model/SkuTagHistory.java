package com.buyi.sku.tag.model;

import java.util.Date;

/**
 * SKU标签历史记录模型
 * SKU Tag History Model
 */
public class SkuTagHistory {
    
    private Long id;
    private String skuId;
    private Long tagGroupId;
    private Long oldTagValueId;
    private Long newTagValueId;
    private String source; // RULE, MANUAL
    private String ruleCode;
    private Integer ruleVersion;
    private String operator;
    private String reason;
    private String operationType; // CREATE, UPDATE, DELETE
    private Date createTime;
    
    // Extended fields for query (not in DB)
    private String tagGroupCode;
    private String tagGroupName;
    private String oldTagValueCode;
    private String oldTagValueName;
    private String newTagValueCode;
    private String newTagValueName;
    
    // Constructors
    public SkuTagHistory() {
    }
    
    public SkuTagHistory(String skuId, Long tagGroupId, Long oldTagValueId, Long newTagValueId, 
                         String source, String operationType) {
        this.skuId = skuId;
        this.tagGroupId = tagGroupId;
        this.oldTagValueId = oldTagValueId;
        this.newTagValueId = newTagValueId;
        this.source = source;
        this.operationType = operationType;
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
    
    public Long getOldTagValueId() {
        return oldTagValueId;
    }
    
    public void setOldTagValueId(Long oldTagValueId) {
        this.oldTagValueId = oldTagValueId;
    }
    
    public Long getNewTagValueId() {
        return newTagValueId;
    }
    
    public void setNewTagValueId(Long newTagValueId) {
        this.newTagValueId = newTagValueId;
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
    
    public String getOperationType() {
        return operationType;
    }
    
    public void setOperationType(String operationType) {
        this.operationType = operationType;
    }
    
    public Date getCreateTime() {
        return createTime;
    }
    
    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
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
    
    public String getOldTagValueCode() {
        return oldTagValueCode;
    }
    
    public void setOldTagValueCode(String oldTagValueCode) {
        this.oldTagValueCode = oldTagValueCode;
    }
    
    public String getOldTagValueName() {
        return oldTagValueName;
    }
    
    public void setOldTagValueName(String oldTagValueName) {
        this.oldTagValueName = oldTagValueName;
    }
    
    public String getNewTagValueCode() {
        return newTagValueCode;
    }
    
    public void setNewTagValueCode(String newTagValueCode) {
        this.newTagValueCode = newTagValueCode;
    }
    
    public String getNewTagValueName() {
        return newTagValueName;
    }
    
    public void setNewTagValueName(String newTagValueName) {
        this.newTagValueName = newTagValueName;
    }
    
    @Override
    public String toString() {
        return "SkuTagHistory{" +
                "id=" + id +
                ", skuId='" + skuId + '\'' +
                ", tagGroupId=" + tagGroupId +
                ", oldTagValueId=" + oldTagValueId +
                ", newTagValueId=" + newTagValueId +
                ", source='" + source + '\'' +
                ", operationType='" + operationType + '\'' +
                ", createTime=" + createTime +
                '}';
    }
}
