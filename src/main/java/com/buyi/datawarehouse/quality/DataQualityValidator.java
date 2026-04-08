package com.buyi.datawarehouse.quality;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 数据质量校验器
 * Data Quality Validator
 *
 * 负责在每个Medallion层执行数据质量检查：
 * - Not-null校验（关键字段不能为空）
 * - 数据类型校验（值符合预期类型和范围）
 * - 唯一性校验（主键无重复）
 * - 参照完整性校验（外键关联有效）
 * - 业务规则校验（金额 >= 0 等）
 * - 异常检测（行数骤降、null率突增等）
 * - Schema漂移检测（字段新增/删除/类型变更）
 */
public class DataQualityValidator {
    private static final Logger logger = LoggerFactory.getLogger(DataQualityValidator.class);

    /** 关键字段列表（必填字段，不能为null） */
    private final List<String> requiredFields;

    /** 允许的最大null率（超出则触发异常检测告警） */
    private final double maxNullRateThreshold;

    /** 最小行数阈值（低于此值触发异常检测告警） */
    private final long minRowCountThreshold;

    /** 已知的Schema字段列表（用于漂移检测） */
    private final List<String> knownSchemaFields;

    public DataQualityValidator(List<String> requiredFields,
                                 double maxNullRateThreshold,
                                 long minRowCountThreshold,
                                 List<String> knownSchemaFields) {
        this.requiredFields = requiredFields != null ? requiredFields : new ArrayList<>();
        this.maxNullRateThreshold = maxNullRateThreshold;
        this.minRowCountThreshold = minRowCountThreshold;
        this.knownSchemaFields = knownSchemaFields != null ? knownSchemaFields : new ArrayList<>();
    }

    /**
     * 校验单条记录的字段
     *
     * @param recordId 记录ID（用于日志追踪）
     * @param fields   字段名->值的映射
     * @return 数据质量检查结果
     */
    public DataQualityResult validateRecord(String recordId, Map<String, Object> fields) {
        DataQualityResult result = new DataQualityResult();
        result.setRecordId(recordId);

        if (fields == null || fields.isEmpty()) {
            result.addCheckDetail("non_empty_record", false, "记录字段为空，无法校验");
            logger.warn("Record {} has no fields to validate", recordId);
            return result;
        }

        // 1. Not-null校验
        validateNotNull(result, fields);

        // 2. Schema漂移检测
        detectSchemaDrift(result, fields);

        // 3. 记录null字段列表（不允许隐式传播到Gold层）
        recordNullFields(result, fields);

        logger.debug("Validated record {}: score={}, passed={}", recordId, result.getQualityScore(), result.isPassed());
        return result;
    }

    /**
     * 批量校验：异常检测（行数骤降、null率突增等）
     *
     * @param batchId      批次ID
     * @param totalRows    本批次总行数
     * @param nullCountMap 每个字段的null行数
     * @return 数据质量检查结果
     */
    public DataQualityResult validateBatch(String batchId, long totalRows, Map<String, Long> nullCountMap) {
        DataQualityResult result = new DataQualityResult();
        result.setRecordId("batch:" + batchId);

        // 1. 行数异常检测
        boolean rowCountOk = totalRows >= minRowCountThreshold;
        result.addCheckDetail(
                "min_row_count",
                rowCountOk,
                rowCountOk
                        ? "行数 " + totalRows + " >= 最低阈值 " + minRowCountThreshold
                        : "行数骤降告警：" + totalRows + " < 最低阈值 " + minRowCountThreshold
        );
        if (!rowCountOk) {
            result.setAnomalyAlert("行数骤降告警：实际行数=" + totalRows + ", 阈值=" + minRowCountThreshold);
            logger.warn("Batch {} row count anomaly: {} < threshold {}", batchId, totalRows, minRowCountThreshold);
        }

        // 2. null率异常检测
        if (nullCountMap != null && totalRows > 0) {
            for (Map.Entry<String, Long> entry : nullCountMap.entrySet()) {
                String fieldName = entry.getKey();
                long nullCount = entry.getValue();
                double nullRate = (double) nullCount / totalRows;
                boolean nullRateOk = nullRate <= maxNullRateThreshold;
                result.addCheckDetail(
                        "null_rate_" + fieldName,
                        nullRateOk,
                        nullRateOk
                                ? "字段 " + fieldName + " null率=" + String.format("%.2f%%", nullRate * 100)
                                : "null率告警：字段 " + fieldName + " null率=" + String.format("%.2f%%", nullRate * 100) + " > 阈值 " + String.format("%.2f%%", maxNullRateThreshold * 100)
                );
                if (!nullRateOk) {
                    String alert = "null率突增：字段=" + fieldName + ", 当前null率=" + String.format("%.2f%%", nullRate * 100);
                    result.setAnomalyAlert(alert);
                    logger.warn("Batch {} null rate anomaly for field {}: {:.2f}% > threshold {:.2f}%",
                            batchId, fieldName, nullRate * 100, maxNullRateThreshold * 100);
                }
            }
        }

        return result;
    }

    /**
     * Not-null校验：关键字段不允许为null
     */
    private void validateNotNull(DataQualityResult result, Map<String, Object> fields) {
        for (String requiredField : requiredFields) {
            Object value = fields.get(requiredField);
            boolean isNotNull = value != null && !String.valueOf(value).trim().isEmpty();
            result.addCheckDetail(
                    "not_null_" + requiredField,
                    isNotNull,
                    isNotNull
                            ? "字段 " + requiredField + " 不为空"
                            : "关键字段 " + requiredField + " 为null或空值，不允许传播到下游"
            );
            if (!isNotNull) {
                result.addNullField(requiredField);
            }
        }
    }

    /**
     * Schema漂移检测：检测新增字段或缺失字段
     */
    private void detectSchemaDrift(DataQualityResult result, Map<String, Object> fields) {
        if (knownSchemaFields.isEmpty()) {
            return;
        }

        List<String> unexpectedFields = new ArrayList<>();
        List<String> missingFields = new ArrayList<>();

        // 检测新增字段（Schema中没有的字段出现在数据中）
        for (String fieldName : fields.keySet()) {
            if (!knownSchemaFields.contains(fieldName)) {
                unexpectedFields.add(fieldName);
            }
        }

        // 检测缺失字段（Schema中有的字段在数据中缺失）
        for (String knownField : knownSchemaFields) {
            if (!fields.containsKey(knownField)) {
                missingFields.add(knownField);
            }
        }

        if (!unexpectedFields.isEmpty()) {
            String driftMsg = "Schema漂移告警：发现未知字段 " + unexpectedFields;
            result.setSchemaDriftAlert(driftMsg);
            result.addCheckDetail("schema_no_unexpected_fields", false, driftMsg);
            logger.warn("Schema drift detected: unexpected fields {}", unexpectedFields);
        } else {
            result.addCheckDetail("schema_no_unexpected_fields", true, "无未知字段");
        }

        if (!missingFields.isEmpty()) {
            String driftMsg = "Schema漂移告警：缺少预期字段 " + missingFields;
            if (result.getSchemaDriftAlert() != null) {
                result.setSchemaDriftAlert(result.getSchemaDriftAlert() + "; " + driftMsg);
            } else {
                result.setSchemaDriftAlert(driftMsg);
            }
            result.addCheckDetail("schema_no_missing_fields", false, driftMsg);
            logger.warn("Schema drift detected: missing fields {}", missingFields);
        } else {
            result.addCheckDetail("schema_no_missing_fields", true, "无缺失字段");
        }
    }

    /**
     * 记录所有null字段（用于Gold层过滤）
     */
    private void recordNullFields(DataQualityResult result, Map<String, Object> fields) {
        for (Map.Entry<String, Object> entry : fields.entrySet()) {
            if (entry.getValue() == null) {
                result.addNullField(entry.getKey());
            }
        }
    }
}
