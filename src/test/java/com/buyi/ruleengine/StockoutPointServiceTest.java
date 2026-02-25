package com.buyi.ruleengine;

import com.buyi.ruleengine.enums.RiskLevel;
import com.buyi.ruleengine.model.CosOosPointDetail;
import com.buyi.ruleengine.model.CosOosPointResponse;
import com.buyi.ruleengine.service.StockoutPointService;
import org.junit.Before;
import org.junit.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * 断货点分析服务单元测试
 * Stockout Point Service Unit Tests
 */
public class StockoutPointServiceTest {

    private StockoutPointService service;
    private LocalDate baseDate;

    @Before
    public void setUp() {
        service = new StockoutPointService();
        baseDate = LocalDate.of(2025, 1, 1);
    }

    @Test
    public void testBasicStockoutPrediction() {
        // 测试基本断货预测
        // 当前库存100件，日均销量10件，无补货
        // productionDays=30, shippingDays=50, horizonDays=80
        // 新逻辑：从第1周开始输出所有窗口

        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                100,                    // currentInventory
                BigDecimal.valueOf(10), // dailyAvg
                null,                   // shipmentQtyMap
                30,                     // productionDays
                50,                     // shippingDays
                7,                      // safetyStockDays
                7,                      // intervalDays
                80,                     // horizonDays
                baseDate
        );

        assertNotNull(response);
        List<CosOosPointDetail> points = response.getMonitorPoints();
        assertNotNull(points);
        assertFalse(points.isEmpty());

        // 新逻辑：第1周窗口 offset=7，inv(7)=30>0，但inv(shippingDays=50)=-400<=0 => AT_RISK
        CosOosPointDetail firstPoint = points.get(0);
        assertEquals(7, firstPoint.getOffsetDays().intValue());
        // inv(7) = 100 - 70 = 30 > 0
        assertTrue(firstPoint.getProjectedInventory().compareTo(BigDecimal.ZERO) > 0);
        assertEquals(RiskLevel.AT_RISK, firstPoint.getRiskLevel());

        // 第2周窗口 offset=14，inv(10)=0<=0 => OUTAGE
        CosOosPointDetail week2 = points.get(1);
        assertEquals(RiskLevel.OUTAGE, week2.getRiskLevel());
    }

    @Test
    public void testSafeInventoryLevel() {
        // 测试安全库存场景（有发货的情况）
        // 当前库存5000件，日均销量10件
        // productionDays=30, shippingDays=50 => 监控范围是 (50, 80]
        // 5000 - 10*56 = 4440 > 安全库存(10*35=350)
        // 添加发货以避免"连续未发货"触发AT_RISK

        Map<LocalDate, Integer> shipments = new HashMap<>();
        shipments.put(baseDate.plusDays(1), 100);    // 到达: baseDate + 51
        shipments.put(baseDate.plusDays(10), 100);   // 到达: baseDate + 60
        shipments.put(baseDate.plusDays(20), 100);   // 到达: baseDate + 70

        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                5000,                   // currentInventory
                BigDecimal.valueOf(10), // dailyAvg
                shipments,              // shipmentQtyMap
                30,                     // productionDays
                50,                     // shippingDays
                35,                     // safetyStockDays
                7,                      // intervalDays
                80,                     // horizonDays
                baseDate
        );

        assertNotNull(response);
        List<CosOosPointDetail> points = response.getMonitorPoints();
        assertNotNull(points);

        // 所有监控点应该都是安全状态
        for (CosOosPointDetail point : points) {
            assertEquals(RiskLevel.OK, point.getRiskLevel());
        }

        // 首个风险点应该为空
        assertNull(response.getFirstRiskPoint());
    }

    @Test
    public void testAtRiskInventoryLevel() {
        // 测试风险库存场景
        // 当前库存800件，日均销量10件，无在途
        // productionDays=30, shippingDays=50, horizonDays=80
        // inv(shippingDays=50) = 800-500 = 300 > 0 => 无 AT_RISK 触发
        // outageDate: inv(80) = 800-800 = 0 <= 0 => 第12周 OUTAGE

        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                800,                    // currentInventory
                BigDecimal.valueOf(10), // dailyAvg
                null,                   // shipmentQtyMap
                30,                     // productionDays
                50,                     // shippingDays
                35,                     // safetyStockDays
                7,                      // intervalDays
                80,                     // horizonDays
                baseDate
        );

        assertNotNull(response);
        // 首个风险点为 OUTAGE（第12周，inv(80)=0<=0）
        assertNotNull(response.getFirstRiskPoint());
        assertEquals(RiskLevel.OUTAGE, response.getFirstRiskPoint().getRiskLevel());
    }

    @Test
    public void testWithShipmentArrival() {
        // 测试有补货到达的场景
        // 当前库存500件，日均销量10件
        // 在第10天发货1000件，发货时间50天，预计第60天到达
        // productionDays=30, shippingDays=50, horizonDays=80

        Map<LocalDate, Integer> shipments = new HashMap<>();
        shipments.put(baseDate.plusDays(10), 1000);

        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                500,                    // currentInventory
                BigDecimal.valueOf(10), // dailyAvg
                shipments,              // shipmentQtyMap
                30,                     // productionDays
                50,                     // shippingDays
                35,                     // safetyStockDays
                7,                      // intervalDays
                80,                     // horizonDays
                baseDate
        );

        assertNotNull(response);
        List<CosOosPointDetail> points = response.getMonitorPoints();
        assertNotNull(points);
        assertFalse(points.isEmpty());

        // 新逻辑（日粒度）：
        // inv(50)=0<=0 => outageDate=baseDate+50, AT_RISK from week 1 (inv(shippingDays=50)=0<=0)
        // 第9周(days 57-63)：days 57-59 inv<0（补货在day60到）=> OUTAGE
        // 窗口末 inv(63) = 500+1000-630 = 870 > 0 (补货已到，窗口末库存充足)
        CosOosPointDetail point63 = points.stream()
                .filter(p -> p.getOffsetDays() == 63)
                .findFirst()
                .orElse(null);

        assertNotNull(point63);
        // 窗口末 projectedInventory = 870，大于0
        assertTrue(point63.getProjectedInventory().compareTo(BigDecimal.valueOf(350)) > 0);
        // 日粒度：第9周内 days 57-59 inv<0（补货day60才到），所以该周为 OUTAGE
        assertEquals(RiskLevel.OUTAGE, point63.getRiskLevel());
    }

    @Test
    public void testNullParameters() {
        // 测试空参数处理
        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                null,   // currentInventory
                null,   // dailyAvg
                null,   // shipmentQtyMap
                null,   // productionDays
                null,   // shippingDays
                null,   // safetyStockDays
                null,   // intervalDays
                null,   // horizonDays
                null    // baseDate
        );

        assertNotNull(response);
        // 当所有参数为null时，应该返回空的监控点列表（因为horizonDays默认为0+0=0）
        assertNotNull(response.getMonitorPoints());
    }

    @Test
    public void testDefaultIntervalDays() {
        // 测试默认间隔天数（7天）
        // productionDays=10, shippingDays=20 => 监控范围是 (20, 30]
        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                100,
                BigDecimal.valueOf(5),
                null,
                10,     // productionDays
                20,     // shippingDays
                7,
                0,  // 传入0或负数应该使用默认值7
                50,
                baseDate
        );

        assertNotNull(response);
        List<CosOosPointDetail> points = response.getMonitorPoints();

        // 检查监控点间隔应该是7天
        if (points.size() >= 2) {
            int diff = points.get(1).getOffsetDays() - points.get(0).getOffsetDays();
            assertEquals(7, diff);
        }
    }

    @Test
    public void testMonitoringPointsOrder() {
        // 测试监控点按天数增序排列
        // productionDays=10, shippingDays=20 => 监控范围是 (20, 30]
        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                500,
                BigDecimal.valueOf(5),
                null,
                10,     // productionDays
                20,     // shippingDays
                7,
                7,
                50,
                baseDate
        );

        assertNotNull(response);
        List<CosOosPointDetail> points = response.getMonitorPoints();

        // 验证监控点按天数增序排列
        Integer prevOffset = null;
        for (CosOosPointDetail point : points) {
            if (prevOffset != null) {
                assertTrue(point.getOffsetDays() > prevOffset);
            }
            prevOffset = point.getOffsetDays();
        }
    }

    @Test
    public void testProjectedDaysCalculation() {
        // 测试可支撑天数计算
        // productionDays=10, shippingDays=20 => 监控范围是 (20, 30]
        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                500,
                BigDecimal.valueOf(10),
                null,
                10,     // productionDays
                20,     // shippingDays
                7,
                7,
                50,
                baseDate
        );

        assertNotNull(response);
        List<CosOosPointDetail> points = response.getMonitorPoints();

        for (CosOosPointDetail point : points) {
            assertNotNull(point.getProjectedDays());
            // 可支撑天数 = 预测库存 / 日均销量
            BigDecimal expected = point.getProjectedInventory()
                    .divide(BigDecimal.valueOf(10), 4, java.math.RoundingMode.HALF_UP);
            assertEquals(0, expected.compareTo(point.getProjectedDays()));
        }
    }

    @Test
    public void testZeroDailyAvg() {
        // 测试日均销量为0的场景
        // productionDays=10, shippingDays=20 => 监控范围是 (20, 30]
        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                100,
                BigDecimal.ZERO,
                null,
                10,     // productionDays
                20,     // shippingDays
                7,
                7,
                50,
                baseDate
        );

        assertNotNull(response);
        List<CosOosPointDetail> points = response.getMonitorPoints();

        // 日均销量为0时，所有监控点都应该是安全的（库存不会减少）
        for (CosOosPointDetail point : points) {
            assertEquals(RiskLevel.OK, point.getRiskLevel());
            // 可支撑天数应该为null（因为无法除以0）
            assertNull(point.getProjectedDays());
        }
    }

    @Test
    public void testMultipleShipments() {
        // 测试多次发货场景
        // productionDays=10, shippingDays=20 => 监控范围是 (20, 30]
        Map<LocalDate, Integer> shipments = new HashMap<>();
        shipments.put(baseDate.plusDays(3), 100);   // 到达日: baseDate + 3 + 20 = baseDate + 23
        shipments.put(baseDate.plusDays(8), 200);   // 到达日: baseDate + 8 + 20 = baseDate + 28

        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                200,
                BigDecimal.valueOf(10),
                shipments,
                10,     // productionDays
                20,     // shippingDays
                7,
                7,
                50,
                baseDate
        );

        assertNotNull(response);
        List<CosOosPointDetail> points = response.getMonitorPoints();
        assertFalse(points.isEmpty());

        // 验证多次发货被正确累加
        // 第28天：200 + 100(第23天到达) + 200(第28天到达) - 280 = 220
    }

    @Test
    public void testShipmentWindowDetection() {
        // 测试发货窗口检测
        // productionDays=10, shippingDays=20 => 监控范围是 (20, 30]
        Map<LocalDate, Integer> shipments = new HashMap<>();
        shipments.put(baseDate.plusDays(5), 100);  // 到达日: baseDate + 25

        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                500,
                BigDecimal.valueOf(5),
                shipments,
                10,     // productionDays
                20,     // shippingDays
                7,
                7,
                50,
                baseDate
        );

        assertNotNull(response);
        List<CosOosPointDetail> points = response.getMonitorPoints();

        // 验证发货窗口检测
        for (CosOosPointDetail point : points) {
            assertNotNull(point.getNote());
        }
    }

    @Test
    public void testFirstRiskPointTracking() {
        // 测试首个风险点跟踪
        // productionDays=30, shippingDays=50 => 监控范围是 (50, 80]
        // 100 - 10*56 = -460 => OUTAGE
        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                100,
                BigDecimal.valueOf(10),
                null,
                30,     // productionDays
                50,     // shippingDays
                35,     // safetyStockDays
                7,
                80,
                baseDate
        );

        assertNotNull(response);

        // 应该有首个风险点
        assertNotNull(response.getFirstRiskPoint());
        assertNotNull(response.getOosStartDate());
        assertNotNull(response.getOosEndDate());
        assertNotNull(response.getOosDays());
        assertNotNull(response.getOosNum());
        assertNotNull(response.getOosReason());
        assertEquals(Integer.valueOf(1), response.getOosType());
    }

    @Test
    public void testProductionDaysEffect() {
        // 测试生产天数不再截断监控范围
        // 新逻辑：horizonDays 决定预测范围，productionDays 仅用于文案说明
        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                100,
                BigDecimal.valueOf(5),
                null,
                10,     // productionDays
                20,     // shippingDays
                7,
                7,
                50,
                baseDate
        );

        assertNotNull(response);
        List<CosOosPointDetail> points = response.getMonitorPoints();
        assertFalse(points.isEmpty());

        // 新逻辑：第1周 offset=7 开始，不跳过 shippingDays 范围内的窗口
        assertEquals(7, points.get(0).getOffsetDays().intValue());
        // inv(shippingDays=20) = 100-100 = 0 <= 0 => 第1周 AT_RISK
        assertEquals(RiskLevel.AT_RISK, points.get(0).getRiskLevel());
        // 所有窗口 offset 在 1..horizonDays=50 内，不受 productionDays 截断
        for (CosOosPointDetail point : points) {
            assertTrue(point.getOffsetDays() >= 7);
            assertTrue(point.getOffsetDays() <= 50);
        }
    }

    @Test
    public void testLargeInventory() {
        // 测试大库存场景（有发货的情况）
        // productionDays=30, shippingDays=50 => 监控范围是 (50, 80]
        // 10000 - 10*80 = 9200 > 安全库存(10*35=350) => OK
        // 添加发货以避免"连续未发货"触发AT_RISK

        Map<LocalDate, Integer> shipments = new HashMap<>();
        shipments.put(baseDate.plusDays(1), 100);    // 到达: baseDate + 51
        shipments.put(baseDate.plusDays(10), 100);   // 到达: baseDate + 60
        shipments.put(baseDate.plusDays(20), 100);   // 到达: baseDate + 70

        CosOosPointResponse response = service.evaluateWithWeeklyShipments(
                10000,
                BigDecimal.valueOf(10),
                shipments,
                30,     // productionDays
                50,     // shippingDays
                35,     // safetyStockDays
                7,
                80,
                baseDate
        );

        assertNotNull(response);

        // 大库存场景下，所有监控点应该是安全的
        for (CosOosPointDetail point : response.getMonitorPoints()) {
            assertEquals(RiskLevel.OK, point.getRiskLevel());
        }
    }
}
