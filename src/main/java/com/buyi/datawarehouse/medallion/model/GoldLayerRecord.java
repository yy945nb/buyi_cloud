package com.buyi.datawarehouse.medallion.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Gold层业务就绪记录模型
 * Gold Layer Business-Ready Record Model
 *
 * Gold层职责：业务就绪、聚合、有SLA保障
 * - 构建与业务问题对齐的领域聚合
 * - 针对查询模式优化：分区裁剪、预聚合
 * - 上线前与消费方确认数据契约
 * - 设定新鲜度SLA并通过监控强制执行
 * - 必须附带行级数据质量分数，禁止null隐式传播
 * - 禁止Gold消费者直接读取Bronze或Silver
 */
public class GoldLayerRecord implements Serializable {
    private static final long serialVersionUID = 1L;

    /** Gold层记录唯一标识 */
    private String recordId;

    /** 业务域（如：sales, inventory, purchase） */
    private String domainName;

    /** 聚合粒度（如：daily, weekly, monthly） */
    private String aggregationGranularity;

    /** 聚合维度标识（如：product+region+date的组合键） */
    private String dimensionKey;

    /** 聚合周期开始时间 */
    private LocalDateTime periodStart;

    /** 聚合周期结束时间 */
    private LocalDateTime periodEnd;

    /** 聚合后的业务指标（Key-Value结构） */
    private Map<String, Object> metrics;

    /** 行级数据质量分数（0-100，必填字段，不允许null传播到Gold层） */
    private Integer rowQualityScore;

    /** 数据新鲜度时间戳（最近一次刷新时间，用于SLA监控） */
    private LocalDateTime refreshedAt;

    /** SLA目标刷新间隔（分钟） */
    private Integer slaRefreshIntervalMinutes;

    /** 是否满足SLA（刷新时间在SLA窗口内） */
    private boolean slaMet;

    /** 来源Silver层记录ID列表（数据血缘追踪） */
    private String sourceSilverRecordIds;

    /** 来源系统 */
    private String sourceSystem;

    /** 记录创建时间（审计字段） */
    private LocalDateTime createdAt;

    /** 记录最后更新时间（审计字段） */
    private LocalDateTime updatedAt;

    /** 软删除时间（审计字段） */
    private LocalDateTime deletedAt;

    /** 数据归属方（负责这条数据的团队/系统） */
    private String dataOwner;

    /** 消费方列表（谁在使用这条数据） */
    private String consumers;

    /** 记录行数（聚合来源的明细记录数，用于异常检测） */
    private Long sourceRowCount;

    /** 聚合后总金额（用于异常检测） */
    private BigDecimal totalAmount;

    public GoldLayerRecord() {
        this.metrics = new HashMap<>();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.refreshedAt = LocalDateTime.now();
        this.rowQualityScore = 0;
        this.slaMet = false;
    }

    /**
     * 检查是否满足SLA（基于当前时间和refreshedAt）
     *
     * @return true如果刷新时间在SLA窗口内
     */
    public boolean checkSlaMet() {
        return checkSlaMet(LocalDateTime.now());
    }

    /**
     * 检查是否满足SLA（接受参考时间，便于测试）
     *
     * @param referenceTime 用于SLA判断的参考时间点
     * @return true如果刷新时间在SLA窗口内
     */
    public boolean checkSlaMet(LocalDateTime referenceTime) {
        if (slaRefreshIntervalMinutes == null || refreshedAt == null || referenceTime == null) {
            this.slaMet = false;
            return false;
        }
        LocalDateTime slaDeadline = referenceTime.minusMinutes(slaRefreshIntervalMinutes);
        this.slaMet = refreshedAt.isAfter(slaDeadline);
        return this.slaMet;
    }

    /**
     * 将指标设置到metrics map中
     *
     * @param key   指标名称
     * @param value 指标值
     */
    public void putMetric(String key, Object value) {
        if (this.metrics == null) {
            this.metrics = new HashMap<>();
        }
        this.metrics.put(key, value);
    }

    /**
     * 获取指定指标值
     *
     * @param key 指标名称
     * @return 指标值，不存在则返回null
     */
    public Object getMetric(String key) {
        return this.metrics != null ? this.metrics.get(key) : null;
    }

    public String getRecordId() {
        return recordId;
    }

    public void setRecordId(String recordId) {
        this.recordId = recordId;
    }

    public String getDomainName() {
        return domainName;
    }

    public void setDomainName(String domainName) {
        this.domainName = domainName;
    }

    public String getAggregationGranularity() {
        return aggregationGranularity;
    }

    public void setAggregationGranularity(String aggregationGranularity) {
        this.aggregationGranularity = aggregationGranularity;
    }

    public String getDimensionKey() {
        return dimensionKey;
    }

    public void setDimensionKey(String dimensionKey) {
        this.dimensionKey = dimensionKey;
    }

    public LocalDateTime getPeriodStart() {
        return periodStart;
    }

    public void setPeriodStart(LocalDateTime periodStart) {
        this.periodStart = periodStart;
    }

    public LocalDateTime getPeriodEnd() {
        return periodEnd;
    }

    public void setPeriodEnd(LocalDateTime periodEnd) {
        this.periodEnd = periodEnd;
    }

    public Map<String, Object> getMetrics() {
        return metrics;
    }

    public void setMetrics(Map<String, Object> metrics) {
        this.metrics = metrics;
    }

    public Integer getRowQualityScore() {
        return rowQualityScore;
    }

    public void setRowQualityScore(Integer rowQualityScore) {
        this.rowQualityScore = rowQualityScore;
    }

    public LocalDateTime getRefreshedAt() {
        return refreshedAt;
    }

    public void setRefreshedAt(LocalDateTime refreshedAt) {
        this.refreshedAt = refreshedAt;
    }

    public Integer getSlaRefreshIntervalMinutes() {
        return slaRefreshIntervalMinutes;
    }

    public void setSlaRefreshIntervalMinutes(Integer slaRefreshIntervalMinutes) {
        this.slaRefreshIntervalMinutes = slaRefreshIntervalMinutes;
    }

    public boolean isSlaMet() {
        return slaMet;
    }

    public void setSlaMet(boolean slaMet) {
        this.slaMet = slaMet;
    }

    public String getSourceSilverRecordIds() {
        return sourceSilverRecordIds;
    }

    public void setSourceSilverRecordIds(String sourceSilverRecordIds) {
        this.sourceSilverRecordIds = sourceSilverRecordIds;
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

    public String getDataOwner() {
        return dataOwner;
    }

    public void setDataOwner(String dataOwner) {
        this.dataOwner = dataOwner;
    }

    public String getConsumers() {
        return consumers;
    }

    public void setConsumers(String consumers) {
        this.consumers = consumers;
    }

    public Long getSourceRowCount() {
        return sourceRowCount;
    }

    public void setSourceRowCount(Long sourceRowCount) {
        this.sourceRowCount = sourceRowCount;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    @Override
    public String toString() {
        return "GoldLayerRecord{" +
                "recordId='" + recordId + '\'' +
                ", domainName='" + domainName + '\'' +
                ", aggregationGranularity='" + aggregationGranularity + '\'' +
                ", dimensionKey='" + dimensionKey + '\'' +
                ", rowQualityScore=" + rowQualityScore +
                ", refreshedAt=" + refreshedAt +
                ", slaMet=" + slaMet +
                ", dataOwner='" + dataOwner + '\'' +
                ", sourceRowCount=" + sourceRowCount +
                '}';
    }
}
