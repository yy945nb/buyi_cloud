package com.buyi.sku.tag.model;

import java.util.Date;

/**
 * SKU标签值模型
 * SKU Tag Value Model
 */
public class SkuTagValue {
    
    private Long id;
    private Long tagGroupId;
    private String tagValueCode;
    private String tagValueName;
    private Integer sortOrder;
    private String description;
    private Integer status; // 0-禁用，1-启用
    private Date createTime;
    private Date updateTime;
    
    // Constructors
    public SkuTagValue() {
    }
    
    public SkuTagValue(Long tagGroupId, String tagValueCode, String tagValueName) {
        this.tagGroupId = tagGroupId;
        this.tagValueCode = tagValueCode;
        this.tagValueName = tagValueName;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Long getTagGroupId() {
        return tagGroupId;
    }
    
    public void setTagGroupId(Long tagGroupId) {
        this.tagGroupId = tagGroupId;
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
    
    public Integer getSortOrder() {
        return sortOrder;
    }
    
    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
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
    
    @Override
    public String toString() {
        return "SkuTagValue{" +
                "id=" + id +
                ", tagGroupId=" + tagGroupId +
                ", tagValueCode='" + tagValueCode + '\'' +
                ", tagValueName='" + tagValueName + '\'' +
                ", sortOrder=" + sortOrder +
                ", status=" + status +
                '}';
    }
}
