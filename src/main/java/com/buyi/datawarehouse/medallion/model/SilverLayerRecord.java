package com.buyi.datawarehouse.medallion.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Silver层清洗记录模型
 * Silver Layer Cleansed Record Model
 *
 * Silver层职责：清洗、去重、统一
 * - 使用窗口函数按主键+事件时间戳去重
 * - 标准化数据类型、日期格式、货币代码、国家代码
 * - 显式处理null：根据字段级规则选择填充、标记或拒绝
 * - 必须可跨域Join，支持SCD Type 2
 */
public class SilverLayerRecord implements Serializable {
    private static final long serialVersionUID = 1L;

    /** Silver层记录唯一标识（业务主键） */
    private String recordId;

    /** 业务实体类型（如：order, customer, product） */
    private String entityType;

    /** 业务主键（去重依据） */
    private String businessKey;

    /** 标准化后的业务数据（Key-Value结构） */
    private Map<String, Object> normalizedFields;

    /** 来源Bronze层记录ID（数据血缘） */
    private String sourceBronzeRecordId;

    /** 来源系统 */
    private String sourceSystem;

    /** 记录创建时间 */
    private LocalDateTime createdAt;

    /** 记录最后更新时间 */
    private LocalDateTime updatedAt;

    /** 软删除时间（软删除标记，不做物理删除） */
    private LocalDateTime deletedAt;

    /** 事件时间（源系统业务时间，用于去重排序） */
    private LocalDateTime eventTime;

    /** 数据质量评分（0-100，Silver层字段级校验结果） */
    private Integer qualityScore;

    /** 是否通过质量校验 */
    private boolean qualityPassed;

    /** 质量问题描述（如有） */
    private String qualityIssues;

    /** Null字段列表（显式记录，不允许隐式传播到Gold层） */
    private String nullFields;

    /** 去重处理标记：保留的记录为true，被去重淘汰的为false */
    private boolean deduplicated;

    /** SCD Type 2标记：是否为当前有效版本 */
    private boolean isCurrent;

    /** SCD有效起始时间 */
    private LocalDateTime scdValidFrom;

    /** SCD有效结束时间（9999-12-31表示当前有效） */
    private LocalDateTime scdValidTo;

    public SilverLayerRecord() {
        this.normalizedFields = new HashMap<>();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.deduplicated = true;
        this.isCurrent = true;
        this.qualityScore = 0;
        this.qualityPassed = false;
        this.scdValidFrom = LocalDateTime.now();
        this.scdValidTo = LocalDateTime.of(9999, 12, 31, 23, 59, 59);
    }

    /**
     * 将记录标记为软删除
     */
    public void softDelete() {
        this.deletedAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.isCurrent = false;
        this.scdValidTo = LocalDateTime.now();
    }

    /**
     * SCD Type 2：关闭当前版本
     */
    public void expireScdVersion() {
        this.isCurrent = false;
        this.scdValidTo = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * 创建新的SCD Type 2版本
     */
    public SilverLayerRecord createNewScdVersion() {
        SilverLayerRecord newVersion = new SilverLayerRecord();
        newVersion.setEntityType(this.entityType);
        newVersion.setBusinessKey(this.businessKey);
        newVersion.setSourceSystem(this.sourceSystem);
        newVersion.setNormalizedFields(new HashMap<>(this.normalizedFields));
        newVersion.setIsCurrent(true);
        newVersion.setScdValidFrom(LocalDateTime.now());
        newVersion.setScdValidTo(LocalDateTime.of(9999, 12, 31, 23, 59, 59));
        return newVersion;
    }

    public String getRecordId() {
        return recordId;
    }

    public void setRecordId(String recordId) {
        this.recordId = recordId;
    }

    public String getEntityType() {
        return entityType;
    }

    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    public String getBusinessKey() {
        return businessKey;
    }

    public void setBusinessKey(String businessKey) {
        this.businessKey = businessKey;
    }

    public Map<String, Object> getNormalizedFields() {
        return normalizedFields;
    }

    public void setNormalizedFields(Map<String, Object> normalizedFields) {
        this.normalizedFields = normalizedFields;
    }

    public String getSourceBronzeRecordId() {
        return sourceBronzeRecordId;
    }

    public void setSourceBronzeRecordId(String sourceBronzeRecordId) {
        this.sourceBronzeRecordId = sourceBronzeRecordId;
    }

    public String getSourceSystem() {
        return sourceSystem;
    }

    public void setSourceSystem(String sourceSystem) {
        this.sourceSystem = sourceSystem;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    public LocalDateTime getEventTime() {
        return eventTime;
    }

    public void setEventTime(LocalDateTime eventTime) {
        this.eventTime = eventTime;
    }

    public Integer getQualityScore() {
        return qualityScore;
    }

    public void setQualityScore(Integer qualityScore) {
        this.qualityScore = qualityScore;
    }

    public boolean isQualityPassed() {
        return qualityPassed;
    }

    public void setQualityPassed(boolean qualityPassed) {
        this.qualityPassed = qualityPassed;
    }

    public String getQualityIssues() {
        return qualityIssues;
    }

    public void setQualityIssues(String qualityIssues) {
        this.qualityIssues = qualityIssues;
    }

    public String getNullFields() {
        return nullFields;
    }

    public void setNullFields(String nullFields) {
        this.nullFields = nullFields;
    }

    public boolean isDeduplicated() {
        return deduplicated;
    }

    public void setDeduplicated(boolean deduplicated) {
        this.deduplicated = deduplicated;
    }

    public boolean isCurrent() {
        return isCurrent;
    }

    public void setIsCurrent(boolean isCurrent) {
        this.isCurrent = isCurrent;
    }

    public LocalDateTime getScdValidFrom() {
        return scdValidFrom;
    }

    public void setScdValidFrom(LocalDateTime scdValidFrom) {
        this.scdValidFrom = scdValidFrom;
    }

    public LocalDateTime getScdValidTo() {
        return scdValidTo;
    }

    public void setScdValidTo(LocalDateTime scdValidTo) {
        this.scdValidTo = scdValidTo;
    }

    @Override
    public String toString() {
        return "SilverLayerRecord{" +
                "recordId='" + recordId + '\'' +
                ", entityType='" + entityType + '\'' +
                ", businessKey='" + businessKey + '\'' +
                ", sourceSystem='" + sourceSystem + '\'' +
                ", qualityScore=" + qualityScore +
                ", qualityPassed=" + qualityPassed +
                ", isCurrent=" + isCurrent +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
