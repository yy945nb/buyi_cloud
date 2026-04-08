package com.buyi.datawarehouse.medallion;

import com.buyi.datawarehouse.lineage.DataLineageTracker;
import com.buyi.datawarehouse.lineage.LineageNode;
import com.buyi.datawarehouse.medallion.model.BronzeLayerRecord;
import com.buyi.datawarehouse.medallion.model.GoldLayerRecord;
import com.buyi.datawarehouse.medallion.model.SilverLayerRecord;
import com.buyi.datawarehouse.medallion.service.MedallionPipelineService;
import com.buyi.datawarehouse.pipeline.PipelineMetrics;
import com.buyi.datawarehouse.pipeline.PipelineStatus;
import com.buyi.datawarehouse.quality.DataQualityResult;
import com.buyi.datawarehouse.quality.DataQualityValidator;
import org.junit.Before;
import org.junit.Test;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * Medallion架构管线服务测试
 * Medallion Pipeline Service Tests
 *
 * 验证Bronze → Silver → Gold的完整数据流转：
 * - 幂等性（重跑不产生重复数据）
 * - 数据质量校验
 * - 去重逻辑
 * - SLA评估
 * - 数据血缘追踪
 */
public class MedallionPipelineTest {

    private MedallionPipelineService pipelineService;
    private DataQualityValidator qualityValidator;
    private DataLineageTracker lineageTracker;

    @Before
    public void setUp() {
        List<String> requiredFields = Arrays.asList("order_id", "customer_id", "revenue");
        List<String> knownSchemaFields = Arrays.asList("order_id", "customer_id", "revenue", "order_date", "region", "product_category", "status");
        qualityValidator = new DataQualityValidator(requiredFields, 0.05, 1, knownSchemaFields);
        lineageTracker = new DataLineageTracker();
        pipelineService = new MedallionPipelineService(qualityValidator, lineageTracker);
    }

    // ============ Bronze层测试 ============

    @Test
    public void testBronzeIngestion() {
        BronzeLayerRecord record = pipelineService.ingestToBronze(
                "erp_system",
                "/data/orders/2024-01-15.json",
                "{\"order_id\":\"ORD-001\",\"revenue\":99.99}",
                LocalDateTime.of(2024, 1, 15, 10, 0),
                "batch_001"
        );

        assertNotNull(record);
        assertNotNull(record.getRecordId());
        assertEquals("erp_system", record.getSourceSystem());
        assertEquals("/data/orders/2024-01-15.json", record.getSourcePath());
        assertNotNull(record.getIngestedAt());
        assertNotNull(record.getPartitionDate());
        assertEquals("batch_001", record.getBatchId());
        assertEquals(1, pipelineService.getBronzeRecordCount());
    }

    @Test
    public void testBronzeIdempotency() {
        // 同一批次+内容重复摄取，不应产生重复记录
        String rawPayload = "{\"order_id\":\"ORD-001\",\"revenue\":99.99}";
        String batchId = "batch_idempotent_001";

        BronzeLayerRecord first = pipelineService.ingestToBronze(
                "erp_system", "/data/orders.json", rawPayload,
                LocalDateTime.of(2024, 1, 15, 10, 0), batchId);

        BronzeLayerRecord second = pipelineService.ingestToBronze(
                "erp_system", "/data/orders.json", rawPayload,
                LocalDateTime.of(2024, 1, 15, 10, 0), batchId);

        assertEquals("Bronze层幂等：相同batchId+内容重跑应返回相同记录ID",
                first.getRecordId(), second.getRecordId());
        assertEquals("Bronze层幂等：重跑不产生重复数据", 1, pipelineService.getBronzeRecordCount());
    }

    @Test
    public void testBronzeDifferentBatchProducesDifferentRecord() {
        String rawPayload = "{\"order_id\":\"ORD-001\",\"revenue\":99.99}";

        pipelineService.ingestToBronze("erp_system", "/data/orders.json", rawPayload,
                LocalDateTime.of(2024, 1, 15, 10, 0), "batch_001");
        pipelineService.ingestToBronze("erp_system", "/data/orders.json", rawPayload,
                LocalDateTime.of(2024, 1, 15, 10, 0), "batch_002");

        assertEquals("不同batchId应产生不同记录", 2, pipelineService.getBronzeRecordCount());
    }

    // ============ Silver层测试 ============

    @Test
    public void testSilverUpsertInsert() {
        BronzeLayerRecord bronzeRecord = createTestBronzeRecord("batch_001");
        Map<String, Object> fields = createValidOrderFields("ORD-001", "CUST-001", "199.99");

        PipelineMetrics metrics = pipelineService.upsertToSilver(
                bronzeRecord, "ORD-001", "order", fields);

        assertEquals(PipelineStatus.SUCCESS, metrics.getStatus());
        assertEquals(1, metrics.getSuccessRows());
        assertEquals(0, metrics.getFailedRows());
        assertEquals(1, pipelineService.getSilverRecordCount());

        SilverLayerRecord silver = pipelineService.getSilverRecord("ORD-001");
        assertNotNull(silver);
        assertEquals("ORD-001", silver.getBusinessKey());
        assertEquals("order", silver.getEntityType());
        assertTrue(silver.isCurrent());
        assertEquals(bronzeRecord.getRecordId(), silver.getSourceBronzeRecordId());
    }

    @Test
    public void testSilverUpsertUpdate() {
        BronzeLayerRecord bronzeRecord1 = createTestBronzeRecordWithTime("batch_001",
                LocalDateTime.of(2024, 1, 15, 9, 0));
        Map<String, Object> fields1 = createValidOrderFields("ORD-001", "CUST-001", "199.99");
        pipelineService.upsertToSilver(bronzeRecord1, "ORD-001", "order", fields1);

        // 更新：更新的事件时间
        BronzeLayerRecord bronzeRecord2 = createTestBronzeRecordWithTime("batch_002",
                LocalDateTime.of(2024, 1, 15, 10, 0));
        Map<String, Object> fields2 = createValidOrderFields("ORD-001", "CUST-001", "299.99");
        pipelineService.upsertToSilver(bronzeRecord2, "ORD-001", "order", fields2);

        // Silver层仍然只有1条记录（去重后保留最新）
        assertEquals(1, pipelineService.getSilverRecordCount());

        SilverLayerRecord silver = pipelineService.getSilverRecord("ORD-001");
        assertNotNull(silver);
        assertEquals("299.99", String.valueOf(silver.getNormalizedFields().get("revenue")));
    }

    @Test
    public void testSilverDeduplicationSkipsOlderRecord() {
        // 先插入较新的记录
        BronzeLayerRecord newerRecord = createTestBronzeRecordWithTime("batch_002",
                LocalDateTime.of(2024, 1, 15, 10, 0));
        Map<String, Object> newerFields = createValidOrderFields("ORD-001", "CUST-001", "299.99");
        pipelineService.upsertToSilver(newerRecord, "ORD-001", "order", newerFields);

        // 再来一条更旧的记录（乱序），不应覆盖新记录
        BronzeLayerRecord olderRecord = createTestBronzeRecordWithTime("batch_001",
                LocalDateTime.of(2024, 1, 15, 9, 0));
        Map<String, Object> olderFields = createValidOrderFields("ORD-001", "CUST-001", "199.99");
        pipelineService.upsertToSilver(olderRecord, "ORD-001", "order", olderFields);

        SilverLayerRecord silver = pipelineService.getSilverRecord("ORD-001");
        assertNotNull(silver);
        // 应保留较新的记录（299.99）
        assertEquals("299.99", String.valueOf(silver.getNormalizedFields().get("revenue")));
    }

    @Test
    public void testSilverQualityFailureOnMissingRequiredField() {
        BronzeLayerRecord bronzeRecord = createTestBronzeRecord("batch_001");

        // 缺少必填字段 revenue
        Map<String, Object> incompleteFields = new HashMap<>();
        incompleteFields.put("order_id", "ORD-001");
        incompleteFields.put("customer_id", "CUST-001");
        // revenue 缺失

        PipelineMetrics metrics = pipelineService.upsertToSilver(
                bronzeRecord, "ORD-001", "order", incompleteFields);

        // 管线仍然执行成功（不中断），但质量分数应该更低
        assertEquals(PipelineStatus.SUCCESS, metrics.getStatus());
        assertTrue("质量分数应低于100（缺少必填字段）", metrics.getQualityPassRate() < 100);

        // Silver记录应记录null字段
        SilverLayerRecord silver = pipelineService.getSilverRecord("ORD-001");
        assertNotNull(silver);
        assertFalse("缺少必填字段时质量校验不通过", silver.isQualityPassed());
        assertNotNull("Null字段应被显式记录", silver.getNullFields());
    }

    @Test
    public void testSilverScdType2Fields() {
        SilverLayerRecord record = new SilverLayerRecord();
        record.setBusinessKey("CUST-001");
        record.setEntityType("customer");

        // 默认为当前版本
        assertTrue(record.isCurrent());
        assertNotNull(record.getScdValidFrom());
        assertEquals(LocalDateTime.of(9999, 12, 31, 23, 59, 59), record.getScdValidTo());

        // 关闭版本（SCD Type 2）
        record.expireScdVersion();
        assertFalse(record.isCurrent());
        assertNotEquals(LocalDateTime.of(9999, 12, 31, 23, 59, 59), record.getScdValidTo());
    }

    @Test
    public void testSilverSoftDelete() {
        SilverLayerRecord record = new SilverLayerRecord();
        record.setBusinessKey("PROD-001");
        record.setEntityType("product");

        assertNull(record.getDeletedAt());
        assertTrue(record.isCurrent());

        record.softDelete();

        assertNotNull("软删除后deletedAt应有值", record.getDeletedAt());
        assertFalse("软删除后记录不再是当前版本", record.isCurrent());
    }

    @Test
    public void testSilverNewScdVersion() {
        SilverLayerRecord original = new SilverLayerRecord();
        original.setBusinessKey("PROD-001");
        original.setEntityType("product");
        original.setSourceSystem("erp_system");
        Map<String, Object> fields = new HashMap<>();
        fields.put("name", "Original Product");
        original.setNormalizedFields(fields);

        SilverLayerRecord newVersion = original.createNewScdVersion();

        assertNotNull(newVersion);
        assertEquals(original.getBusinessKey(), newVersion.getBusinessKey());
        assertEquals(original.getEntityType(), newVersion.getEntityType());
        assertEquals(original.getSourceSystem(), newVersion.getSourceSystem());
        assertTrue(newVersion.isCurrent());
        assertEquals("Original Product", newVersion.getNormalizedFields().get("name"));
    }

    // ============ Gold层测试 ============

    @Test
    public void testGoldBuildFromSilver() {
        List<SilverLayerRecord> silverRecords = createTestSilverRecords(5);

        PipelineMetrics metrics = pipelineService.buildGoldRecord(
                "2024-01-15_US_Electronics",
                "sales",
                "daily",
                silverRecords,
                15
        );

        assertEquals(PipelineStatus.SUCCESS, metrics.getStatus());
        assertEquals(5, metrics.getTotalRows());
        assertEquals(1, metrics.getSuccessRows());

        GoldLayerRecord gold = pipelineService.getGoldRecord("2024-01-15_US_Electronics");
        assertNotNull(gold);
        assertEquals("sales", gold.getDomainName());
        assertEquals("daily", gold.getAggregationGranularity());
        assertEquals("2024-01-15_US_Electronics", gold.getDimensionKey());
        assertNotNull("Gold层必须附带行级质量分数", gold.getRowQualityScore());
        assertEquals(Long.valueOf(5), gold.getSourceRowCount());
        assertNotNull(gold.getSourceSilverRecordIds());
        assertNotNull(gold.getRefreshedAt());
        assertEquals(Integer.valueOf(15), gold.getSlaRefreshIntervalMinutes());
    }

    @Test
    public void testGoldIdempotentUpsert() {
        List<SilverLayerRecord> silverRecords = createTestSilverRecords(3);

        // 第一次构建
        pipelineService.buildGoldRecord("2024-01-15_US_Electronics", "sales", "daily", silverRecords, 15);
        // 第二次构建（幂等覆盖写入）
        pipelineService.buildGoldRecord("2024-01-15_US_Electronics", "sales", "daily", silverRecords, 15);

        // Gold层仍然只有1条记录（幂等）
        assertEquals(1, pipelineService.getGoldRecordCount());
    }

    @Test
    public void testGoldSlaCheck() {
        GoldLayerRecord gold = new GoldLayerRecord();
        gold.setSlaRefreshIntervalMinutes(15);

        // 刚刷新，应满足SLA
        gold.setRefreshedAt(LocalDateTime.now().minusMinutes(5));
        assertTrue("5分钟前刷新应满足15分钟SLA", gold.checkSlaMet());

        // 超过SLA窗口
        gold.setRefreshedAt(LocalDateTime.now().minusMinutes(20));
        assertFalse("20分钟前刷新不满足15分钟SLA", gold.checkSlaMet());
    }

    @Test
    public void testGoldMetricsAggregation() {
        List<SilverLayerRecord> silverRecords = new java.util.ArrayList<>();
        for (int i = 1; i <= 3; i++) {
            SilverLayerRecord sr = new SilverLayerRecord();
            sr.setRecordId("silver_" + i);
            sr.setQualityScore(100);
            sr.setSourceSystem("erp_system");
            Map<String, Object> fields = new HashMap<>();
            fields.put("order_id", "ORD-00" + i);
            fields.put("revenue", "100.00");
            sr.setNormalizedFields(fields);
            silverRecords.add(sr);
        }

        pipelineService.buildGoldRecord("2024-01-15_US_Test", "sales", "daily", silverRecords, 15);

        GoldLayerRecord gold = pipelineService.getGoldRecord("2024-01-15_US_Test");
        assertNotNull(gold);

        // 验证聚合指标
        Object orderCount = gold.getMetric("order_count");
        Object totalRevenue = gold.getMetric("total_revenue");

        assertNotNull("order_count 指标不能为null", orderCount);
        assertNotNull("total_revenue 指标不能为null", totalRevenue);
        assertEquals(3L, ((Long) orderCount).longValue());
        assertEquals(new BigDecimal("300.00"), totalRevenue);
    }

    @Test
    public void testGoldEmptySilverList() {
        PipelineMetrics metrics = pipelineService.buildGoldRecord(
                "2024-01-15_EMPTY", "sales", "daily", Collections.emptyList(), 15);

        assertEquals(PipelineStatus.SUCCESS, metrics.getStatus());
        assertEquals(0, metrics.getSuccessRows());
    }

    // ============ 数据质量校验测试 ============

    @Test
    public void testDataQualityAllPass() {
        Map<String, Object> fields = createValidOrderFields("ORD-001", "CUST-001", "199.99");
        DataQualityResult result = qualityValidator.validateRecord("ORD-001", fields);

        assertTrue(result.isPassed());
        assertEquals(0, result.getFailedChecks());
        assertEquals(100, result.getQualityScore());
        assertEquals(0, result.getNullFieldCount());
    }

    @Test
    public void testDataQualityMissingRequiredField() {
        Map<String, Object> fields = new HashMap<>();
        fields.put("order_id", "ORD-001");
        // customer_id 和 revenue 缺失

        DataQualityResult result = qualityValidator.validateRecord("ORD-001", fields);

        assertFalse(result.isPassed());
        assertTrue(result.getFailedChecks() > 0);
        assertTrue(result.getNullFieldCount() > 0);
        assertTrue("质量分数应低于100", result.getQualityScore() < 100);
    }

    @Test
    public void testDataQualitySchemaDriftNewField() {
        Map<String, Object> fields = createValidOrderFields("ORD-001", "CUST-001", "199.99");
        // 添加Schema中不存在的新字段（Schema漂移）
        fields.put("unknown_new_field", "some_value");

        DataQualityResult result = qualityValidator.validateRecord("ORD-001", fields);

        assertNotNull("Schema漂移应触发告警", result.getSchemaDriftAlert());
        assertTrue("Schema漂移告警应包含字段名", result.getSchemaDriftAlert().contains("unknown_new_field"));
    }

    @Test
    public void testDataQualityNullFieldRecording() {
        Map<String, Object> fields = new HashMap<>();
        fields.put("order_id", "ORD-001");
        fields.put("customer_id", null);  // 显式null
        fields.put("revenue", "99.99");

        DataQualityResult result = qualityValidator.validateRecord("ORD-001", fields);

        assertTrue("Null字段应被显式记录", result.getNullFields().contains("customer_id"));
    }

    @Test
    public void testDataQualityBatchAnomalyDetection() {
        Map<String, Long> nullCountMap = new HashMap<>();
        nullCountMap.put("customer_id", 50L);  // 50% null率（超过5%阈值）

        DataQualityResult result = qualityValidator.validateBatch("batch_001", 100L, nullCountMap);

        assertFalse("null率超阈值应导致批量校验失败", result.isPassed());
        assertNotNull("应触发异常告警", result.getAnomalyAlert());
    }

    @Test
    public void testDataQualityBatchRowCountAnomaly() {
        // 行数低于最小阈值（0行，阈值为1）
        DataQualityResult result = qualityValidator.validateBatch("batch_empty", 0L, new HashMap<>());

        assertFalse("行数骤降应触发告警", result.isPassed());
        assertNotNull("应触发行数异常告警", result.getAnomalyAlert());
    }

    @Test
    public void testDataQualityResultDetailTracking() {
        DataQualityResult result = new DataQualityResult();
        result.setRecordId("test-record");

        result.addCheckDetail("not_null_order_id", true, "order_id 不为空");
        result.addCheckDetail("not_null_customer_id", false, "customer_id 为null");
        result.addCheckDetail("schema_check", true, "Schema正常");

        assertEquals(3, result.getTotalChecks());
        assertEquals(2, result.getPassedChecks());
        assertEquals(1, result.getFailedChecks());
        assertFalse(result.isPassed());
        assertEquals(66, result.getQualityScore()); // 2/3 * 100 = 66
        assertEquals(3, result.getCheckDetails().size());
    }

    // ============ 数据血缘追踪测试 ============

    @Test
    public void testLineageGraphInitialization() {
        DataLineageTracker tracker = pipelineService.getLineageTracker();

        // MedallionPipelineService初始化时自动注册Bronze/Silver/Gold节点
        assertNotNull(tracker.getNode("bronze_orders"));
        assertNotNull(tracker.getNode("silver_orders"));
        assertNotNull(tracker.getNode("gold_daily_revenue"));

        // 验证血缘关系
        LineageNode bronzeNode = tracker.getNode("bronze_orders");
        assertTrue("Bronze应有Silver作为下游", bronzeNode.getDownstreamNodeIds().contains("silver_orders"));

        LineageNode silverNode = tracker.getNode("silver_orders");
        assertTrue("Silver应有Bronze作为上游", silverNode.getUpstreamNodeIds().contains("bronze_orders"));
        assertTrue("Silver应有Gold作为下游", silverNode.getDownstreamNodeIds().contains("gold_daily_revenue"));
    }

    @Test
    public void testLineageAllUpstream() {
        DataLineageTracker tracker = new DataLineageTracker();

        LineageNode source = new LineageNode("source_erp", "source.erp", LineageNode.NodeType.SOURCE, "source");
        LineageNode bronze = new LineageNode("bronze_orders", "bronze.orders", LineageNode.NodeType.BRONZE, "bronze");
        LineageNode silver = new LineageNode("silver_orders", "silver.orders", LineageNode.NodeType.SILVER, "silver");
        LineageNode gold = new LineageNode("gold_revenue", "gold.revenue", LineageNode.NodeType.GOLD, "gold");

        tracker.registerNode(source);
        tracker.registerNode(bronze);
        tracker.registerNode(silver);
        tracker.registerNode(gold);

        tracker.addLineage("source_erp", "bronze_orders");
        tracker.addLineage("bronze_orders", "silver_orders");
        tracker.addLineage("silver_orders", "gold_revenue");

        List<LineageNode> upstreamOfGold = tracker.getAllUpstream("gold_revenue");
        assertEquals("Gold层应有3个上游节点（Silver、Bronze、Source）", 3, upstreamOfGold.size());

        List<LineageNode> downstreamOfSource = tracker.getAllDownstream("source_erp");
        assertEquals("Source应有3个下游节点（Bronze、Silver、Gold）", 3, downstreamOfSource.size());
    }

    @Test
    public void testLineageNodeTypes() {
        LineageNode bronzeNode = new LineageNode("bronze_1", "bronze.orders", LineageNode.NodeType.BRONZE, "bronze");
        assertEquals(LineageNode.NodeType.BRONZE, bronzeNode.getNodeType());
        assertEquals("bronze", bronzeNode.getLayer());

        LineageNode goldNode = new LineageNode("gold_1", "gold.revenue", LineageNode.NodeType.GOLD, "gold");
        assertEquals(LineageNode.NodeType.GOLD, goldNode.getNodeType());
    }

    @Test
    public void testLineageMarkRefreshed() {
        DataLineageTracker tracker = new DataLineageTracker();
        LineageNode node = new LineageNode("test_node", "test.table", LineageNode.NodeType.SILVER, "silver");
        tracker.registerNode(node);

        assertNull(node.getLastRefreshedAt());

        tracker.markRefreshed("test_node");

        assertNotNull("标记刷新后lastRefreshedAt应有值", node.getLastRefreshedAt());
    }

    // ============ 管线指标测试 ============

    @Test
    public void testPipelineMetricsSuccess() {
        PipelineMetrics metrics = new PipelineMetrics();
        metrics.setPipelineName("test_pipeline");
        metrics.setLayer("silver");
        metrics.setTotalRows(100);
        metrics.setSuccessRows(100);
        metrics.setFailedRows(0);
        metrics.setQualityPassRate(100.0);
        metrics.setDataFreshnessTimestamp(LocalDateTime.now().minusMinutes(5));
        metrics.setSlaFreshnessMinutes(15);

        metrics.markSuccess();

        assertEquals(PipelineStatus.SUCCESS, metrics.getStatus());
        assertNotNull(metrics.getEndTime());
        assertTrue(metrics.getDurationMs() >= 0);
        assertTrue("质量通过率100%应满足质量SLA", metrics.isQualitySlaMet());
        assertTrue("5分钟前刷新应满足15分钟新鲜度SLA", metrics.isFreshnessSlaMet());
        assertFalse("正常执行不应触发告警", metrics.isAlertTriggered());
    }

    @Test
    public void testPipelineMetricsFailure() {
        PipelineMetrics metrics = new PipelineMetrics();
        metrics.setPipelineName("test_pipeline_fail");

        metrics.markFailed("数据库连接超时");

        assertEquals(PipelineStatus.FAILED, metrics.getStatus());
        assertEquals("数据库连接超时", metrics.getErrorMessage());
        assertTrue("管线失败应触发告警", metrics.isAlertTriggered());
        assertNotNull("告警消息不能为null", metrics.getAlertMessage());
    }

    @Test
    public void testPipelineMetricsQualitySlaViolation() {
        PipelineMetrics metrics = new PipelineMetrics();
        metrics.setPipelineName("test_quality_sla");
        metrics.setQualityPassRate(98.5);  // 低于99.9%
        metrics.setTotalRows(1000);
        metrics.setSuccessRows(985);
        metrics.setFailedRows(15);

        metrics.markSuccess();  // 管线执行成功但质量SLA不达标

        assertFalse("质量通过率98.5%不满足99.9%的SLA", metrics.isQualitySlaMet());
        assertTrue("质量SLA违反应触发告警", metrics.isAlertTriggered());
    }

    @Test
    public void testPipelineMetricsFreshnessViolation() {
        PipelineMetrics metrics = new PipelineMetrics();
        metrics.setPipelineName("test_freshness_sla");
        metrics.setQualityPassRate(100.0);
        metrics.setDataFreshnessTimestamp(LocalDateTime.now().minusMinutes(30));  // 30分钟前
        metrics.setSlaFreshnessMinutes(15);

        metrics.markSuccess();

        assertFalse("30分钟前的数据不满足15分钟新鲜度SLA", metrics.isFreshnessSlaMet());
        assertTrue("新鲜度SLA违反应触发告警", metrics.isAlertTriggered());
    }

    @Test
    public void testPipelineMetricsFailureRate() {
        PipelineMetrics metrics = new PipelineMetrics();
        metrics.setTotalRows(1000);
        metrics.setFailedRows(100);

        assertEquals(10.0, metrics.getFailureRate(), 0.001);
    }

    // ============ 端到端管线测试 ============

    @Test
    public void testEndToEndPipeline() {
        // Step 1: Bronze层摄取
        BronzeLayerRecord bronze = pipelineService.ingestToBronze(
                "erp_system",
                "/data/orders/2024-01-15.json",
                "{\"order_id\":\"ORD-E2E-001\",\"revenue\":500.00}",
                LocalDateTime.of(2024, 1, 15, 9, 0),
                "batch_e2e_001"
        );
        assertNotNull(bronze);
        assertEquals(1, pipelineService.getBronzeRecordCount());

        // Step 2: Silver层Upsert
        Map<String, Object> fields = createValidOrderFields("ORD-E2E-001", "CUST-001", "500.00");
        PipelineMetrics silverMetrics = pipelineService.upsertToSilver(
                bronze, "ORD-E2E-001", "order", fields);
        assertEquals(PipelineStatus.SUCCESS, silverMetrics.getStatus());
        assertEquals(1, pipelineService.getSilverRecordCount());

        // Step 3: Gold层构建
        List<SilverLayerRecord> allSilver = pipelineService.getAllSilverRecords();
        PipelineMetrics goldMetrics = pipelineService.buildGoldRecord(
                "2024-01-15_GLOBAL_ALL", "sales", "daily", allSilver, 15);
        assertEquals(PipelineStatus.SUCCESS, goldMetrics.getStatus());
        assertEquals(1, pipelineService.getGoldRecordCount());

        // 验证完整血缘链路
        GoldLayerRecord gold = pipelineService.getGoldRecord("2024-01-15_GLOBAL_ALL");
        assertNotNull(gold);
        assertNotNull("Gold层必须有来源Silver记录ID（数据血缘）", gold.getSourceSilverRecordIds());
        assertNotNull("Gold层必须附带行级质量分数", gold.getRowQualityScore());
    }

    // ============ 辅助方法 ============

    private BronzeLayerRecord createTestBronzeRecord(String batchId) {
        return createTestBronzeRecordWithTime(batchId, LocalDateTime.of(2024, 1, 15, 10, 0));
    }

    private BronzeLayerRecord createTestBronzeRecordWithTime(String batchId, LocalDateTime eventTime) {
        return pipelineService.ingestToBronze(
                "erp_system",
                "/data/orders.json",
                "{\"order_id\":\"ORD-001\",\"revenue\":100.00,\"batch\":\"" + batchId + "\"}",
                eventTime,
                batchId
        );
    }

    private Map<String, Object> createValidOrderFields(String orderId, String customerId, String revenue) {
        Map<String, Object> fields = new HashMap<>();
        fields.put("order_id", orderId);
        fields.put("customer_id", customerId);
        fields.put("revenue", revenue);
        fields.put("order_date", "2024-01-15");
        fields.put("region", "US");
        fields.put("product_category", "Electronics");
        fields.put("status", "completed");
        return fields;
    }

    private List<SilverLayerRecord> createTestSilverRecords(int count) {
        List<SilverLayerRecord> records = new java.util.ArrayList<>();
        for (int i = 1; i <= count; i++) {
            SilverLayerRecord sr = new SilverLayerRecord();
            sr.setRecordId("silver_test_" + i);
            sr.setBusinessKey("ORD-TEST-" + i);
            sr.setEntityType("order");
            sr.setQualityScore(100);
            sr.setQualityPassed(true);
            sr.setSourceSystem("erp_system");
            Map<String, Object> fields = createValidOrderFields("ORD-TEST-" + i, "CUST-" + i, "100.00");
            sr.setNormalizedFields(fields);
            records.add(sr);
        }
        return records;
    }
}
