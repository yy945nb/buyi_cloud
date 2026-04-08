package com.buyi.datawarehouse.quality;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 数据质量检查结果
 * Data Quality Check Result
 *
 * 包含行级质量分数和每项校验的详细结果，
 * 支持Gold层质量达标率 >= 99.9% 的SLA目标。
 */
public class DataQualityResult implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 被检查的记录ID */
    private String recordId;

    /** 检查执行时间 */
    private LocalDateTime checkedAt;

    /** 是否整体通过（所有关键检查均通过） */
    private boolean passed;

    /** 总检查项数 */
    private int totalChecks;

    /** 通过的检查项数 */
    private int passedChecks;

    /** 失败的检查项数 */
    private int failedChecks;

    /** 行级质量分数（0-100，passed/total * 100） */
    private int qualityScore;

    /** 各项检查详细结果 */
    private List<CheckDetail> checkDetails;

    /** Null字段列表（显式记录，不允许隐式传播到Gold层） */
    private List<String> nullFields;

    /** Schema漂移告警描述（如有） */
    private String schemaDriftAlert;

    /** 异常检测告警描述（如有） */
    private String anomalyAlert;

    public DataQualityResult() {
        this.checkedAt = LocalDateTime.now();
        this.checkDetails = new ArrayList<>();
        this.nullFields = new ArrayList<>();
        this.passed = false;
    }

    /**
     * 添加单项检查结果
     *
     * @param checkName   检查名称
     * @param checkPassed 是否通过
     * @param message     检查描述或失败原因
     */
    public void addCheckDetail(String checkName, boolean checkPassed, String message) {
        CheckDetail detail = new CheckDetail(checkName, checkPassed, message);
        this.checkDetails.add(detail);
        this.totalChecks++;
        if (checkPassed) {
            this.passedChecks++;
        } else {
            this.failedChecks++;
        }
        // 重新计算质量分数
        this.qualityScore = totalChecks > 0 ? (passedChecks * 100 / totalChecks) : 0;
        // 所有检查通过才算整体通过
        this.passed = (failedChecks == 0) && (totalChecks > 0);
    }

    /**
     * 记录Null字段
     *
     * @param fieldName 字段名
     */
    public void addNullField(String fieldName) {
        if (this.nullFields == null) {
            this.nullFields = new ArrayList<>();
        }
        this.nullFields.add(fieldName);
    }

    /**
     * 获取Null字段数量
     */
    public int getNullFieldCount() {
        return nullFields != null ? nullFields.size() : 0;
    }

    /**
     * 内部类：单项检查详情
     */
    public static class CheckDetail implements Serializable {
        private static final long serialVersionUID = 1L;

        private final String checkName;
        private final boolean passed;
        private final String message;
        private final LocalDateTime checkedAt;

        public CheckDetail(String checkName, boolean passed, String message) {
            this.checkName = checkName;
            this.passed = passed;
            this.message = message;
            this.checkedAt = LocalDateTime.now();
        }

        public String getCheckName() {
            return checkName;
        }

        public boolean isPassed() {
            return passed;
        }

        public String getMessage() {
            return message;
        }

        public LocalDateTime getCheckedAt() {
            return checkedAt;
        }

        @Override
        public String toString() {
            return "CheckDetail{checkName='" + checkName + "', passed=" + passed + ", message='" + message + "'}";
        }
    }

    public String getRecordId() {
        return recordId;
    }

    public void setRecordId(String recordId) {
        this.recordId = recordId;
    }

    public LocalDateTime getCheckedAt() {
        return checkedAt;
    }

    public void setCheckedAt(LocalDateTime checkedAt) {
        this.checkedAt = checkedAt;
    }

    public boolean isPassed() {
        return passed;
    }

    public void setPassed(boolean passed) {
        this.passed = passed;
    }

    public int getTotalChecks() {
        return totalChecks;
    }

    public void setTotalChecks(int totalChecks) {
        this.totalChecks = totalChecks;
    }

    public int getPassedChecks() {
        return passedChecks;
    }

    public void setPassedChecks(int passedChecks) {
        this.passedChecks = passedChecks;
    }

    public int getFailedChecks() {
        return failedChecks;
    }

    public void setFailedChecks(int failedChecks) {
        this.failedChecks = failedChecks;
    }

    public int getQualityScore() {
        return qualityScore;
    }

    public void setQualityScore(int qualityScore) {
        this.qualityScore = qualityScore;
    }

    public List<CheckDetail> getCheckDetails() {
        return checkDetails;
    }

    public void setCheckDetails(List<CheckDetail> checkDetails) {
        this.checkDetails = checkDetails;
    }

    public List<String> getNullFields() {
        return nullFields;
    }

    public void setNullFields(List<String> nullFields) {
        this.nullFields = nullFields;
    }

    public String getSchemaDriftAlert() {
        return schemaDriftAlert;
    }

    public void setSchemaDriftAlert(String schemaDriftAlert) {
        this.schemaDriftAlert = schemaDriftAlert;
    }

    public String getAnomalyAlert() {
        return anomalyAlert;
    }

    public void setAnomalyAlert(String anomalyAlert) {
        this.anomalyAlert = anomalyAlert;
    }

    @Override
    public String toString() {
        return "DataQualityResult{" +
                "recordId='" + recordId + '\'' +
                ", passed=" + passed +
                ", totalChecks=" + totalChecks +
                ", passedChecks=" + passedChecks +
                ", failedChecks=" + failedChecks +
                ", qualityScore=" + qualityScore +
                ", nullFieldCount=" + getNullFieldCount() +
                '}';
    }
}
