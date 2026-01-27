package com.buyi.ruleengine.model;

import com.buyi.ruleengine.enums.RiskLevel;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 断货监控点详情
 * Stockout Monitoring Point Detail
 */
public class CosOosPointDetail {

    /** 监控窗口开始日期 */
    private LocalDate windowStart;

    /** 监控窗口结束日期 */
    private LocalDate windowEnd;

    /** 距离基准日期的天数 */
    private Integer offsetDays;

    /** 预测库存数量 */
    private BigDecimal projectedInventory;

    /** 预测可支撑天数 */
    private BigDecimal projectedDays;

    /** 安全库存水平 */
    private BigDecimal safetyLevel;

    /** 预计缺货量 */
    private BigDecimal oosQuantity;

    /** 风险等级 */
    private RiskLevel riskLevel;

    /** 风险说明 */
    private String note;

    /** 窗口内是否有发货 */
    private boolean hasShipmentInWindow;

    /** 连续未发货周数 */
    private Integer consecutiveMissedWeeks;

    public CosOosPointDetail() {
    }

    // Getters and Setters
    public LocalDate getWindowStart() {
        return windowStart;
    }

    public void setWindowStart(LocalDate windowStart) {
        this.windowStart = windowStart;
    }

    public LocalDate getWindowEnd() {
        return windowEnd;
    }

    public void setWindowEnd(LocalDate windowEnd) {
        this.windowEnd = windowEnd;
    }

    public Integer getOffsetDays() {
        return offsetDays;
    }

    public void setOffsetDays(Integer offsetDays) {
        this.offsetDays = offsetDays;
    }

    public BigDecimal getProjectedInventory() {
        return projectedInventory;
    }

    public void setProjectedInventory(BigDecimal projectedInventory) {
        this.projectedInventory = projectedInventory;
    }

    public BigDecimal getProjectedDays() {
        return projectedDays;
    }

    public void setProjectedDays(BigDecimal projectedDays) {
        this.projectedDays = projectedDays;
    }

    public BigDecimal getSafetyLevel() {
        return safetyLevel;
    }

    public void setSafetyLevel(BigDecimal safetyLevel) {
        this.safetyLevel = safetyLevel;
    }

    public BigDecimal getOosQuantity() {
        return oosQuantity;
    }

    public void setOosQuantity(BigDecimal oosQuantity) {
        this.oosQuantity = oosQuantity;
    }

    public RiskLevel getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(RiskLevel riskLevel) {
        this.riskLevel = riskLevel;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public boolean isHasShipmentInWindow() {
        return hasShipmentInWindow;
    }

    public void setHasShipmentInWindow(boolean hasShipmentInWindow) {
        this.hasShipmentInWindow = hasShipmentInWindow;
    }

    public Integer getConsecutiveMissedWeeks() {
        return consecutiveMissedWeeks;
    }

    public void setConsecutiveMissedWeeks(Integer consecutiveMissedWeeks) {
        this.consecutiveMissedWeeks = consecutiveMissedWeeks;
    }

    @Override
    public String toString() {
        return "CosOosPointDetail{" +
                "windowStart=" + windowStart +
                ", windowEnd=" + windowEnd +
                ", offsetDays=" + offsetDays +
                ", projectedInventory=" + projectedInventory +
                ", projectedDays=" + projectedDays +
                ", riskLevel=" + riskLevel +
                ", note='" + note + '\'' +
                '}';
    }
}
