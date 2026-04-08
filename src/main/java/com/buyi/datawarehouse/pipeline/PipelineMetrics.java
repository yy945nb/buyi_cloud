package com.buyi.datawarehouse.pipeline;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 管线执行指标
 * Pipeline Execution Metrics
 *
 * 记录每次管线执行的SLA监控指标，支持：
 * - 延迟监控（数据新鲜度）
 * - 完整性监控（行数、空值率）
 * - SLA达标状态告警
 * - 管线执行时长统计
 */
public class PipelineMetrics implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 管线唯一标识 */
    private String pipelineId;

    /** 管线名称（如：bronze_orders, silver_orders, gold_daily_revenue） */
    private String pipelineName;

    /** 管线所属层级（bronze / silver / gold） */
    private String layer;

    /** 执行批次ID */
    private String runId;

    /** 执行开始时间 */
    private LocalDateTime startTime;

    /** 执行结束时间 */
    private LocalDateTime endTime;

    /** 执行状态（RUNNING / SUCCESS / FAILED / PARTIAL） */
    private PipelineStatus status;

    /** 处理总行数 */
    private long totalRows;

    /** 成功处理行数 */
    private long successRows;

    /** 失败行数 */
    private long failedRows;

    /** 数据新鲜度时间戳（最新数据的事件时间） */
    private LocalDateTime dataFreshnessTimestamp;

    /** SLA目标新鲜度延迟（分钟） */
    private int slaFreshnessMinutes;

    /** 是否满足新鲜度SLA */
    private boolean freshnessSlaMet;

    /** 数据质量通过率（0-100） */
    private double qualityPassRate;

    /** 是否满足质量SLA（>= 99.9%） */
    private boolean qualitySlaMet;

    /** 执行时长（毫秒） */
    private long durationMs;

    /** 错误信息（失败时填充） */
    private String errorMessage;

    /** 错误堆栈（失败时填充，用于Runbook排查） */
    private String errorStack;

    /** 是否已触发告警 */
    private boolean alertTriggered;

    /** 告警描述 */
    private String alertMessage;

    /** 源数据时间范围开始（增量同步） */
    private LocalDateTime sourceWindowStart;

    /** 源数据时间范围结束（增量同步） */
    private LocalDateTime sourceWindowEnd;

    public PipelineMetrics() {
        this.startTime = LocalDateTime.now();
        this.status = PipelineStatus.RUNNING;
        this.alertTriggered = false;
        this.freshnessSlaMet = false;
        this.qualitySlaMet = false;
    }

    /**
     * 标记管线执行成功并计算执行时长
     */
    public void markSuccess() {
        markSuccess(LocalDateTime.now());
    }

    /**
     * 标记管线执行成功并计算执行时长（接受参考时间，便于测试）
     *
     * @param now 结束时间（用于SLA评估的参考时间点）
     */
    public void markSuccess(LocalDateTime now) {
        this.endTime = now;
        this.status = PipelineStatus.SUCCESS;
        this.durationMs = java.time.Duration.between(startTime, endTime).toMillis();
        evaluateSla(now);
    }

    /**
     * 标记管线执行失败
     *
     * @param errorMessage 错误信息
     */
    public void markFailed(String errorMessage) {
        this.endTime = LocalDateTime.now();
        this.status = PipelineStatus.FAILED;
        this.durationMs = java.time.Duration.between(startTime, endTime).toMillis();
        this.errorMessage = errorMessage;
        this.alertTriggered = true;
        this.alertMessage = "管线执行失败：" + pipelineName + " - " + errorMessage;
    }

    /**
     * 标记部分成功（有失败行但管线未中断）
     */
    public void markPartial() {
        markPartial(LocalDateTime.now());
    }

    /**
     * 标记部分成功（接受参考时间，便于测试）
     *
     * @param now 结束时间（用于SLA评估的参考时间点）
     */
    public void markPartial(LocalDateTime now) {
        this.endTime = now;
        this.status = PipelineStatus.PARTIAL;
        this.durationMs = java.time.Duration.between(startTime, endTime).toMillis();
        evaluateSla(now);
    }

    /**
     * 评估SLA达标情况
     */
    private void evaluateSla() {
        evaluateSla(LocalDateTime.now());
    }

    /**
     * 评估SLA达标情况（接受参考时间，便于测试）
     *
     * @param now 参考时间点
     */
    private void evaluateSla(LocalDateTime now) {
        // 评估新鲜度SLA
        if (dataFreshnessTimestamp != null && slaFreshnessMinutes > 0) {
            LocalDateTime slaDeadline = now.minusMinutes(slaFreshnessMinutes);
            this.freshnessSlaMet = dataFreshnessTimestamp.isAfter(slaDeadline);
            if (!freshnessSlaMet) {
                this.alertTriggered = true;
                this.alertMessage = "新鲜度SLA告警：" + pipelineName + " 数据延迟超过 " + slaFreshnessMinutes + " 分钟";
            }
        }

        // 评估质量SLA（>= 99.9%）
        this.qualitySlaMet = qualityPassRate >= 99.9;
        if (!qualitySlaMet) {
            this.alertTriggered = true;
            String qualityAlert = "质量SLA告警：" + pipelineName + " 质量通过率=" +
                    String.format("%.2f%%", qualityPassRate) + " < 99.9%";
            this.alertMessage = (this.alertMessage != null)
                    ? this.alertMessage + "; " + qualityAlert
                    : qualityAlert;
        }
    }

    /**
     * 获取执行时长（秒）
     */
    public double getDurationSeconds() {
        return durationMs / 1000.0;
    }

    /**
     * 获取失败率
     */
    public double getFailureRate() {
        return totalRows > 0 ? (double) failedRows / totalRows * 100 : 0.0;
    }

    public String getPipelineId() {
        return pipelineId;
    }

    public void setPipelineId(String pipelineId) {
        this.pipelineId = pipelineId;
    }

    public String getPipelineName() {
        return pipelineName;
    }

    public void setPipelineName(String pipelineName) {
        this.pipelineName = pipelineName;
    }

    public String getLayer() {
        return layer;
    }

    public void setLayer(String layer) {
        this.layer = layer;
    }

    public String getRunId() {
        return runId;
    }

    public void setRunId(String runId) {
        this.runId = runId;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public PipelineStatus getStatus() {
        return status;
    }

    public void setStatus(PipelineStatus status) {
        this.status = status;
    }

    public long getTotalRows() {
        return totalRows;
    }

    public void setTotalRows(long totalRows) {
        this.totalRows = totalRows;
    }

    public long getSuccessRows() {
        return successRows;
    }

    public void setSuccessRows(long successRows) {
        this.successRows = successRows;
    }

    public long getFailedRows() {
        return failedRows;
    }

    public void setFailedRows(long failedRows) {
        this.failedRows = failedRows;
    }

    public LocalDateTime getDataFreshnessTimestamp() {
        return dataFreshnessTimestamp;
    }

    public void setDataFreshnessTimestamp(LocalDateTime dataFreshnessTimestamp) {
        this.dataFreshnessTimestamp = dataFreshnessTimestamp;
    }

    public int getSlaFreshnessMinutes() {
        return slaFreshnessMinutes;
    }

    public void setSlaFreshnessMinutes(int slaFreshnessMinutes) {
        this.slaFreshnessMinutes = slaFreshnessMinutes;
    }

    public boolean isFreshnessSlaMet() {
        return freshnessSlaMet;
    }

    public void setFreshnessSlaMet(boolean freshnessSlaMet) {
        this.freshnessSlaMet = freshnessSlaMet;
    }

    public double getQualityPassRate() {
        return qualityPassRate;
    }

    public void setQualityPassRate(double qualityPassRate) {
        this.qualityPassRate = qualityPassRate;
    }

    public boolean isQualitySlaMet() {
        return qualitySlaMet;
    }

    public void setQualitySlaMet(boolean qualitySlaMet) {
        this.qualitySlaMet = qualitySlaMet;
    }

    public long getDurationMs() {
        return durationMs;
    }

    public void setDurationMs(long durationMs) {
        this.durationMs = durationMs;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public String getErrorStack() {
        return errorStack;
    }

    public void setErrorStack(String errorStack) {
        this.errorStack = errorStack;
    }

    public boolean isAlertTriggered() {
        return alertTriggered;
    }

    public void setAlertTriggered(boolean alertTriggered) {
        this.alertTriggered = alertTriggered;
    }

    public String getAlertMessage() {
        return alertMessage;
    }

    public void setAlertMessage(String alertMessage) {
        this.alertMessage = alertMessage;
    }

    public LocalDateTime getSourceWindowStart() {
        return sourceWindowStart;
    }

    public void setSourceWindowStart(LocalDateTime sourceWindowStart) {
        this.sourceWindowStart = sourceWindowStart;
    }

    public LocalDateTime getSourceWindowEnd() {
        return sourceWindowEnd;
    }

    public void setSourceWindowEnd(LocalDateTime sourceWindowEnd) {
        this.sourceWindowEnd = sourceWindowEnd;
    }

    @Override
    public String toString() {
        return "PipelineMetrics{" +
                "pipelineId='" + pipelineId + '\'' +
                ", pipelineName='" + pipelineName + '\'' +
                ", layer='" + layer + '\'' +
                ", status=" + status +
                ", totalRows=" + totalRows +
                ", successRows=" + successRows +
                ", failedRows=" + failedRows +
                ", durationMs=" + durationMs +
                ", freshnessSlaMet=" + freshnessSlaMet +
                ", qualitySlaMet=" + qualitySlaMet +
                ", alertTriggered=" + alertTriggered +
                '}';
    }
}
