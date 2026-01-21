package com.buyi.sku.tag.model;

import java.util.Date;

/**
 * SKU标签组模型
 * SKU Tag Group Model
 */
public class SkuTagGroup {
    
    private Long id;
    private String tagGroupCode;
    private String tagGroupName;
    private String tagType; // SINGLE, MULTI
    private String description;
    private Integer status; // 0-禁用，1-启用
    private Date createTime;
    private Date updateTime;
    private String createUser;
    private String updateUser;
    
    // Constructors
    public SkuTagGroup() {
    }
    
    public SkuTagGroup(String tagGroupCode, String tagGroupName, String tagType) {
        this.tagGroupCode = tagGroupCode;
        this.tagGroupName = tagGroupName;
        this.tagType = tagType;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
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
    
    public String getTagType() {
        return tagType;
    }
    
    public void setTagType(String tagType) {
        this.tagType = tagType;
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
        return "SkuTagGroup{" +
                "id=" + id +
                ", tagGroupCode='" + tagGroupCode + '\'' +
                ", tagGroupName='" + tagGroupName + '\'' +
                ", tagType='" + tagType + '\'' +
                ", status=" + status +
                '}';
    }
}
