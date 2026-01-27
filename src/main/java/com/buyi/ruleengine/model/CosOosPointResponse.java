package com.buyi.ruleengine.model;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * 断货点分析响应模型
 * Stockout Point Analysis Response Model
 */
public class CosOosPointResponse {

    /** 断货开始日期 */
    private LocalDate oosStartDate;

    /** 断货结束日期 */
    private LocalDate oosEndDate;

    /** 距离断货天数 */
    private Integer oosDays;

    /** 缺货数量 */
    private Integer oosNum;

    /** 监控日期 */
    private LocalDate monitorDate;

    /** 断货原因 */
    private String oosReason;

    /** 断货类型 (1: 库存不足) */
    private Integer oosType;

    /** 所有监控点详情列表 */
    private List<CosOosPointDetail> monitorPoints;

    /** 首个风险点（断货或风险） */
    private CosOosPointDetail firstRiskPoint;

    public CosOosPointResponse() {
        this.monitorPoints = new ArrayList<>();
    }

    // Getters and Setters
    public LocalDate getOosStartDate() {
        return oosStartDate;
    }

    public void setOosStartDate(LocalDate oosStartDate) {
        this.oosStartDate = oosStartDate;
    }

    public LocalDate getOosEndDate() {
        return oosEndDate;
    }

    public void setOosEndDate(LocalDate oosEndDate) {
        this.oosEndDate = oosEndDate;
    }

    public Integer getOosDays() {
        return oosDays;
    }

    public void setOosDays(Integer oosDays) {
        this.oosDays = oosDays;
    }

    public Integer getOosNum() {
        return oosNum;
    }

    public void setOosNum(Integer oosNum) {
        this.oosNum = oosNum;
    }

    public LocalDate getMonitorDate() {
        return monitorDate;
    }

    public void setMonitorDate(LocalDate monitorDate) {
        this.monitorDate = monitorDate;
    }

    public String getOosReason() {
        return oosReason;
    }

    public void setOosReason(String oosReason) {
        this.oosReason = oosReason;
    }

    public Integer getOosType() {
        return oosType;
    }

    public void setOosType(Integer oosType) {
        this.oosType = oosType;
    }

    public List<CosOosPointDetail> getMonitorPoints() {
        return monitorPoints;
    }

    public void setMonitorPoints(List<CosOosPointDetail> monitorPoints) {
        this.monitorPoints = monitorPoints;
    }

    public CosOosPointDetail getFirstRiskPoint() {
        return firstRiskPoint;
    }

    public void setFirstRiskPoint(CosOosPointDetail firstRiskPoint) {
        this.firstRiskPoint = firstRiskPoint;
    }

    /**
     * 添加监控点
     * @param detail 监控点详情
     */
    public void addMonitorPoint(CosOosPointDetail detail) {
        if (this.monitorPoints == null) {
            this.monitorPoints = new ArrayList<>();
        }
        this.monitorPoints.add(detail);
    }

    @Override
    public String toString() {
        return "CosOosPointResponse{" +
                "oosStartDate=" + oosStartDate +
                ", oosEndDate=" + oosEndDate +
                ", oosDays=" + oosDays +
                ", oosNum=" + oosNum +
                ", oosReason='" + oosReason + '\'' +
                ", monitorPointsCount=" + (monitorPoints != null ? monitorPoints.size() : 0) +
                '}';
    }
}
