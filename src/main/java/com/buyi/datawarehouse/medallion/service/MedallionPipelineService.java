package com.buyi.datawarehouse.medallion.service;

import com.buyi.datawarehouse.lineage.DataLineageTracker;
import com.buyi.datawarehouse.lineage.LineageNode;
import com.buyi.datawarehouse.medallion.model.BronzeLayerRecord;
import com.buyi.datawarehouse.medallion.model.GoldLayerRecord;
import com.buyi.datawarehouse.medallion.model.SilverLayerRecord;
import com.buyi.datawarehouse.pipeline.PipelineMetrics;
import com.buyi.datawarehouse.pipeline.PipelineStatus;
import com.buyi.datawarehouse.quality.DataQualityResult;
import com.buyi.datawarehouse.quality.DataQualityValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Medallion架构管线服务
 * Medallion Architecture Pipeline Service
 *
 * 负责协调 Bronze → Silver → Gold 的完整数据流转：
 * 1. Bronze层：幂等、只追加的原始摄取
 * 2. Silver层：基于主键+事件时间去重、清洗、统一
 * 3. Gold层：业务聚合、质量分数附加、SLA评估
 *
 * 核心原则：
 * - 所有管线幂等：重跑产生相同结果，绝不产生重复数据
 * - Schema漂移必须告警，绝不静默损坏数据
 * - null不允许隐式传播到Gold/语义层
 * - Gold层数据必须附带行级质量分数
 */
public class MedallionPipelineService {
    private static final Logger logger = LoggerFactory.getLogger(MedallionPipelineService.class);

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private final DataQualityValidator qualityValidator;
    private final DataLineageTracker lineageTracker;

    /** Silver层去重后的记录存储（businessKey -> 最新SilverRecord） */
    private final Map<String, SilverLayerRecord> silverRecordStore;

    /** Gold层聚合记录存储（dimensionKey -> GoldRecord） */
    private final Map<String, GoldLayerRecord> goldRecordStore;

    /** Bronze层记录列表（只追加，不可变） */
    private final List<BronzeLayerRecord> bronzeRecordStore;

    public MedallionPipelineService(DataQualityValidator qualityValidator,
                                     DataLineageTracker lineageTracker) {
        this.qualityValidator = qualityValidator;
        this.lineageTracker = lineageTracker;
        this.silverRecordStore = new HashMap<>();
        this.goldRecordStore = new HashMap<>();
        this.bronzeRecordStore = new ArrayList<>();
        initializeLineageGraph();
    }

    /**
     * 初始化血缘图（Bronze → Silver → Gold）
     */
    private void initializeLineageGraph() {
        LineageNode bronzeNode = new LineageNode(
                "bronze_orders", "bronze.orders", LineageNode.NodeType.BRONZE, "bronze");
        bronzeNode.setTransformationDescription("原始JSON摄取，只追加，捕获_ingested_at和_source_system");
        lineageTracker.registerNode(bronzeNode);

        LineageNode silverNode = new LineageNode(
                "silver_orders", "silver.orders", LineageNode.NodeType.SILVER, "silver");
        silverNode.setTransformationDescription("按order_id去重（取最新），标准化数据类型，SCD Type 2");
        lineageTracker.registerNode(silverNode);

        LineageNode goldNode = new LineageNode(
                "gold_daily_revenue", "gold.daily_revenue", LineageNode.NodeType.GOLD, "gold");
        goldNode.setTransformationDescription("按order_date+region+product_category聚合，计算total_revenue和order_count");
        goldNode.setSlaDescription("SLA：每15分钟刷新，质量通过率 >= 99.9%");
        lineageTracker.registerNode(goldNode);

        lineageTracker.addLineage("bronze_orders", "silver_orders");
        lineageTracker.addLineage("silver_orders", "gold_daily_revenue");
    }

    // ─────────────────────────────────────────────────────────
    // Bronze层：原始摄取（只追加，幂等）
    // ─────────────────────────────────────────────────────────

    /**
     * 摄取原始记录到Bronze层
     * 幂等实现：基于 batchId + recordId 去重，重跑不产生重复数据
     *
     * @param sourceSystem  源系统名称
     * @param sourcePath    源文件/主题路径
     * @param rawPayload    原始JSON内容
     * @param eventTime     源系统事件时间
     * @param batchId       批次ID（幂等重跑依据）
     * @return Bronze层记录
     */
    public BronzeLayerRecord ingestToBronze(String sourceSystem, String sourcePath,
                                             String rawPayload, LocalDateTime eventTime,
                                             String batchId) {
        String recordId = generateRecordId(batchId, sourcePath, rawPayload);

        // 幂等检查：同一批次+内容的记录已存在则跳过
        for (BronzeLayerRecord existing : bronzeRecordStore) {
            if (recordId.equals(existing.getRecordId())) {
                logger.debug("Bronze record {} already exists (idempotent skip), batchId={}", recordId, batchId);
                return existing;
            }
        }

        BronzeLayerRecord record = new BronzeLayerRecord();
        record.setRecordId(recordId);
        record.setSourceSystem(sourceSystem);
        record.setSourcePath(sourcePath);
        record.setRawPayload(rawPayload);
        record.setEventTime(eventTime);
        record.setIngestedAt(LocalDateTime.now());
        record.setPartitionDate(LocalDate.now().format(DATE_FORMATTER));
        record.setBatchId(batchId);
        record.setSchemaVersion("1.0");

        // 只追加，不可变
        bronzeRecordStore.add(record);
        lineageTracker.markRefreshed("bronze_orders");
        logger.info("Ingested to Bronze: recordId={}, sourceSystem={}, batchId={}", recordId, sourceSystem, batchId);
        return record;
    }

    // ─────────────────────────────────────────────────────────
    // Silver层：清洗、去重、统一
    // ─────────────────────────────────────────────────────────

    /**
     * 将Bronze记录转换并Upsert到Silver层
     * - 按业务主键去重（保留最新记录，基于eventTime）
     * - 执行数据质量校验
     * - 记录null字段，不允许隐式传播到Gold层
     *
     * @param bronzeRecord  Bronze层记录
     * @param businessKey   业务主键（去重依据）
     * @param entityType    业务实体类型
     * @param normalizedFields 标准化后的字段Map
     * @return 管线执行指标
     */
    public PipelineMetrics upsertToSilver(BronzeLayerRecord bronzeRecord,
                                           String businessKey,
                                           String entityType,
                                           Map<String, Object> normalizedFields) {
        PipelineMetrics metrics = new PipelineMetrics();
        metrics.setPipelineId(UUID.randomUUID().toString());
        metrics.setPipelineName("silver_upsert_" + entityType);
        metrics.setLayer("silver");
        metrics.setRunId(bronzeRecord.getBatchId());
        metrics.setTotalRows(1);

        try {
            // 1. 数据质量校验
            DataQualityResult qualityResult = qualityValidator.validateRecord(bronzeRecord.getRecordId(), normalizedFields);
            double qualityPassRate = qualityResult.getQualityScore();
            metrics.setQualityPassRate(qualityPassRate);

            // 2. 构建Silver记录
            SilverLayerRecord silverRecord = buildSilverRecord(
                    bronzeRecord, businessKey, entityType, normalizedFields, qualityResult);

            // 3. Upsert：按业务主键去重（SCD Type 2）
            SilverLayerRecord existing = silverRecordStore.get(businessKey);
            if (existing != null) {
                // 事件时间晚于现有记录才更新（防止乱序数据覆盖新数据）
                if (bronzeRecord.getEventTime() != null && existing.getEventTime() != null
                        && bronzeRecord.getEventTime().isBefore(existing.getEventTime())) {
                    logger.debug("Silver dedup: skipping older record for businessKey={}, eventTime={}",
                            businessKey, bronzeRecord.getEventTime());
                    silverRecord.setDeduplicated(false);
                } else {
                    // 关闭旧版本（SCD Type 2）
                    existing.expireScdVersion();
                    silverRecordStore.put(businessKey, silverRecord);
                    logger.info("Silver upsert: updated record for businessKey={}", businessKey);
                }
            } else {
                silverRecordStore.put(businessKey, silverRecord);
                logger.info("Silver upsert: inserted new record for businessKey={}", businessKey);
            }

            metrics.setSuccessRows(1);
            metrics.setDataFreshnessTimestamp(LocalDateTime.now());
            metrics.setSlaFreshnessMinutes(15);
            metrics.markSuccess();
            lineageTracker.markRefreshed("silver_orders");

        } catch (Exception e) {
            metrics.setFailedRows(1);
            metrics.markFailed(e.getMessage());
            logger.error("Silver upsert failed for businessKey={}: {}", businessKey, e.getMessage(), e);
        }

        return metrics;
    }

    // ─────────────────────────────────────────────────────────
    // Gold层：业务聚合，附带质量分数和SLA评估
    // ─────────────────────────────────────────────────────────

    /**
     * 从Silver层聚合构建Gold层记录
     * - 计算业务指标（total_revenue, order_count等）
     * - 附带行级质量分数（不允许null传播）
     * - 评估SLA达标情况
     *
     * @param dimensionKey           聚合维度键（如：2024-01-15_US_Electronics）
     * @param domainName             业务域名称
     * @param aggregationGranularity 聚合粒度（如：daily）
     * @param silverRecords          参与聚合的Silver层记录列表
     * @param slaRefreshMinutes      SLA目标刷新间隔（分钟）
     * @return 管线执行指标
     */
    public PipelineMetrics buildGoldRecord(String dimensionKey,
                                            String domainName,
                                            String aggregationGranularity,
                                            List<SilverLayerRecord> silverRecords,
                                            int slaRefreshMinutes) {
        PipelineMetrics metrics = new PipelineMetrics();
        metrics.setPipelineId(UUID.randomUUID().toString());
        metrics.setPipelineName("gold_build_" + domainName);
        metrics.setLayer("gold");
        metrics.setTotalRows(silverRecords != null ? silverRecords.size() : 0);

        try {
            if (silverRecords == null || silverRecords.isEmpty()) {
                metrics.setSuccessRows(0);
                metrics.markSuccess();
                return metrics;
            }

            // 1. 从Silver层记录聚合计算指标
            Map<String, Object> aggregatedMetrics = aggregateSilverRecords(silverRecords);

            // 2. 计算聚合结果的整体质量分数（不允许null传播）
            int overallQualityScore = computeGoldQualityScore(silverRecords);

            // 3. 构建Gold层记录
            GoldLayerRecord goldRecord = new GoldLayerRecord();
            goldRecord.setRecordId(UUID.randomUUID().toString());
            goldRecord.setDomainName(domainName);
            goldRecord.setAggregationGranularity(aggregationGranularity);
            goldRecord.setDimensionKey(dimensionKey);
            goldRecord.setMetrics(aggregatedMetrics);
            goldRecord.setRowQualityScore(overallQualityScore);
            goldRecord.setSourceRowCount((long) silverRecords.size());
            goldRecord.setRefreshedAt(LocalDateTime.now());
            goldRecord.setSlaRefreshIntervalMinutes(slaRefreshMinutes);
            goldRecord.setSourceSystem(silverRecords.get(0).getSourceSystem());

            // 4. 收集来源Silver记录ID列表（数据血缘）
            StringBuilder silverIds = new StringBuilder();
            for (SilverLayerRecord sr : silverRecords) {
                if (silverIds.length() > 0) {
                    silverIds.append(",");
                }
                silverIds.append(sr.getRecordId());
            }
            goldRecord.setSourceSilverRecordIds(silverIds.toString());

            // 5. 评估SLA
            goldRecord.checkSlaMet();

            // 6. 幂等Upsert（相同dimensionKey覆盖写入）
            goldRecordStore.put(dimensionKey, goldRecord);

            metrics.setSuccessRows(1);
            metrics.setQualityPassRate(overallQualityScore);
            metrics.setDataFreshnessTimestamp(LocalDateTime.now());
            metrics.setSlaFreshnessMinutes(slaRefreshMinutes);
            metrics.markSuccess();
            lineageTracker.markRefreshed("gold_daily_revenue");

            logger.info("Built Gold record: dimensionKey={}, qualityScore={}, slaRefreshMinutes={}",
                    dimensionKey, overallQualityScore, slaRefreshMinutes);

        } catch (Exception e) {
            metrics.setFailedRows(1);
            metrics.markFailed(e.getMessage());
            logger.error("Gold build failed for dimensionKey={}: {}", dimensionKey, e.getMessage(), e);
        }

        return metrics;
    }

    // ─────────────────────────────────────────────────────────
    // 内部辅助方法
    // ─────────────────────────────────────────────────────────

    private SilverLayerRecord buildSilverRecord(BronzeLayerRecord bronzeRecord,
                                                  String businessKey,
                                                  String entityType,
                                                  Map<String, Object> normalizedFields,
                                                  DataQualityResult qualityResult) {
        SilverLayerRecord silver = new SilverLayerRecord();
        silver.setRecordId(UUID.randomUUID().toString());
        silver.setEntityType(entityType);
        silver.setBusinessKey(businessKey);
        silver.setNormalizedFields(normalizedFields);
        silver.setSourceBronzeRecordId(bronzeRecord.getRecordId());
        silver.setSourceSystem(bronzeRecord.getSourceSystem());
        silver.setEventTime(bronzeRecord.getEventTime());
        silver.setQualityScore(qualityResult.getQualityScore());
        silver.setQualityPassed(qualityResult.isPassed());

        // 记录null字段（不允许隐式传播到Gold层）
        if (qualityResult.getNullFields() != null && !qualityResult.getNullFields().isEmpty()) {
            silver.setNullFields(String.join(",", qualityResult.getNullFields()));
            silver.setQualityIssues("Null字段: " + silver.getNullFields());
        }

        return silver;
    }

    /**
     * 聚合Silver层记录计算业务指标
     */
    private Map<String, Object> aggregateSilverRecords(List<SilverLayerRecord> silverRecords) {
        Map<String, Object> metrics = new HashMap<>();
        long orderCount = 0;
        BigDecimal totalRevenue = BigDecimal.ZERO;

        for (SilverLayerRecord record : silverRecords) {
            if (record == null || record.getNormalizedFields() == null) {
                continue;
            }
            Map<String, Object> fields = record.getNormalizedFields();
            orderCount++;

            // 聚合revenue字段
            Object revenueObj = fields.get("revenue");
            if (revenueObj != null) {
                try {
                    BigDecimal revenue = new BigDecimal(String.valueOf(revenueObj));
                    totalRevenue = totalRevenue.add(revenue);
                } catch (NumberFormatException e) {
                    logger.warn("Invalid revenue value: {}", revenueObj);
                }
            }
        }

        metrics.put("order_count", orderCount);
        metrics.put("total_revenue", totalRevenue);
        return metrics;
    }

    /**
     * 计算Gold层整体质量分数（来自Silver层质量分数的平均值）
     * null不允许传播到Gold层：质量分数为0的记录会拉低整体分数
     */
    private int computeGoldQualityScore(List<SilverLayerRecord> silverRecords) {
        if (silverRecords == null || silverRecords.isEmpty()) {
            return 0;
        }
        int totalScore = 0;
        for (SilverLayerRecord record : silverRecords) {
            totalScore += (record.getQualityScore() != null ? record.getQualityScore() : 0);
        }
        return totalScore / silverRecords.size();
    }

    /**
     * 生成幂等记录ID（基于batchId + sourcePath + 内容hash）
     */
    private String generateRecordId(String batchId, String sourcePath, String rawPayload) {
        String combined = batchId + "|" + sourcePath + "|" + (rawPayload != null ? rawPayload : "");
        return "rec_" + Math.abs(combined.hashCode());
    }

    // ─────────────────────────────────────────────────────────
    // 查询方法
    // ─────────────────────────────────────────────────────────

    /**
     * 获取指定业务主键的Silver层记录（当前有效版本）
     */
    public SilverLayerRecord getSilverRecord(String businessKey) {
        return silverRecordStore.get(businessKey);
    }

    /**
     * 获取指定维度键的Gold层记录
     */
    public GoldLayerRecord getGoldRecord(String dimensionKey) {
        return goldRecordStore.get(dimensionKey);
    }

    /**
     * 获取Bronze层记录总数
     */
    public int getBronzeRecordCount() {
        return bronzeRecordStore.size();
    }

    /**
     * 获取Silver层记录总数（当前有效版本）
     */
    public int getSilverRecordCount() {
        return silverRecordStore.size();
    }

    /**
     * 获取Gold层记录总数
     */
    public int getGoldRecordCount() {
        return goldRecordStore.size();
    }

    /**
     * 获取所有Silver层记录（用于Gold层聚合）
     */
    public List<SilverLayerRecord> getAllSilverRecords() {
        return new ArrayList<>(silverRecordStore.values());
    }

    /**
     * 获取血缘追踪器
     */
    public DataLineageTracker getLineageTracker() {
        return lineageTracker;
    }
}
