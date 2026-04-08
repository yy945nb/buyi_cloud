package com.buyi.datawarehouse.medallion.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Bronze层原始记录模型
 * Bronze Layer Raw Record Model
 *
 * Bronze层职责：原始、不可变、只追加（Append-Only）
 * - 零转换的原始摄取，保留源系统原始数据
 * - 捕获元数据：源文件、摄取时间戳、源系统名称
 * - Schema演化通过 mergeSchema 处理——告警但不阻塞
 * - 按摄取日期分区，支持低成本历史回放
 */
public class BronzeLayerRecord implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 原始记录唯一标识（基于内容hash生成） */
    private String recordId;

    /** 源系统名称（如：erp_system, pos_terminal, api_gateway） */
    private String sourceSystem;

    /** 源文件或主题路径 */
    private String sourcePath;

    /** 业务数据（JSON格式原始内容） */
    private String rawPayload;

    /** 摄取时间戳（Ingest Timestamp） */
    private LocalDateTime ingestedAt;

    /** 分区日期（按摄取日期分区） */
    private String partitionDate;

    /** Schema版本（用于追踪Schema演化） */
    private String schemaVersion;

    /** 是否存在Schema漂移告警 */
    private boolean schemaDriftDetected;

    /** Schema漂移描述（如有） */
    private String schemaDriftDescription;

    /** 数据批次ID（同一批次摄取的记录共享同一ID，支持幂等重放） */
    private String batchId;

    /** Kafka/事件流偏移量（流处理时使用） */
    private Long streamOffset;

    /** 事件发生时间（源系统的业务时间） */
    private LocalDateTime eventTime;

    public BronzeLayerRecord() {
        this.ingestedAt = LocalDateTime.now();
        this.schemaDriftDetected = false;
    }

    public String getRecordId() {
        return recordId;
    }

    public void setRecordId(String recordId) {
        this.recordId = recordId;
    }

    public String getSourceSystem() {
        return sourceSystem;
    }

    public void setSourceSystem(String sourceSystem) {
        this.sourceSystem = sourceSystem;
    }

    public String getSourcePath() {
        return sourcePath;
    }

    public void setSourcePath(String sourcePath) {
        this.sourcePath = sourcePath;
    }

    public String getRawPayload() {
        return rawPayload;
    }

    public void setRawPayload(String rawPayload) {
        this.rawPayload = rawPayload;
    }

    public LocalDateTime getIngestedAt() {
        return ingestedAt;
    }

    public void setIngestedAt(LocalDateTime ingestedAt) {
        this.ingestedAt = ingestedAt;
    }

    public String getPartitionDate() {
        return partitionDate;
    }

    public void setPartitionDate(String partitionDate) {
        this.partitionDate = partitionDate;
    }

    public String getSchemaVersion() {
        return schemaVersion;
    }

    public void setSchemaVersion(String schemaVersion) {
        this.schemaVersion = schemaVersion;
    }

    public boolean isSchemaDriftDetected() {
        return schemaDriftDetected;
    }

    public void setSchemaDriftDetected(boolean schemaDriftDetected) {
        this.schemaDriftDetected = schemaDriftDetected;
    }

    public String getSchemaDriftDescription() {
        return schemaDriftDescription;
    }

    public void setSchemaDriftDescription(String schemaDriftDescription) {
        this.schemaDriftDescription = schemaDriftDescription;
    }

    public String getBatchId() {
        return batchId;
    }

    public void setBatchId(String batchId) {
        this.batchId = batchId;
    }

    public Long getStreamOffset() {
        return streamOffset;
    }

    public void setStreamOffset(Long streamOffset) {
        this.streamOffset = streamOffset;
    }

    public LocalDateTime getEventTime() {
        return eventTime;
    }

    public void setEventTime(LocalDateTime eventTime) {
        this.eventTime = eventTime;
    }

    @Override
    public String toString() {
        return "BronzeLayerRecord{" +
                "recordId='" + recordId + '\'' +
                ", sourceSystem='" + sourceSystem + '\'' +
                ", sourcePath='" + sourcePath + '\'' +
                ", ingestedAt=" + ingestedAt +
                ", partitionDate='" + partitionDate + '\'' +
                ", schemaVersion='" + schemaVersion + '\'' +
                ", schemaDriftDetected=" + schemaDriftDetected +
                ", batchId='" + batchId + '\'' +
                '}';
    }
}
