package com.buyi.ruleengine.service;

import cn.hutool.core.collection.CollectionUtil;
import cn.hutool.core.util.ObjectUtil;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.lmc.channel.core.constant.Constant;
import com.lmc.channel.core.constant.ExcludeTypeEnum;
import com.lmc.channel.core.constant.StockupTypeEnum;
import com.lmc.channel.core.entity.CosGoodsSku;
import com.lmc.channel.core.enumtype.WarehouseEnum;
import com.lmc.channel.core.model.channel.sheinauth.util.JsonUtil;
import com.lmc.channel.core.model.goods.CosDailyAvgRuleDateExcludeResponse;
import com.lmc.channel.core.model.goods.CosStockupPlanDto;
import com.lmc.channel.core.model.goods.CosStockupPlanItemDto;
import com.lmc.channel.core.model.goods.response.CosGoodsSpuResponse;
import com.lmc.channel.core.model.sys.SysConfigItemResponse;
import com.lmc.channel.core.model.sys.SysConfigResponse;
import com.lmc.channel.core.model.tag.TagUserPermissionResponse;
import com.lmc.channel.core.service.*;
import com.lmc.channel.core.utils.IdUtils;
import com.lmc.channel.core.utils.userinfo.ThreadLocalUserHolder;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;

@Slf4j
@Component
public class NewSkuStockupBusiness {

    @Autowired
    private SysConfigService sysConfigService;

    @Autowired
    private CosGoodsSkuService cosGoodsSkuService;

    @Autowired
    private CosDailyAvgRuleService cosDailyAvgRuleService;
    @Autowired
    private CosGoodsSpuService cosGoodsSpuService;
    @Autowired
    private CosStockupPlanService cosStockupPlanService;

    @Autowired
    private TagUserPermissionService tagUserPermissionService;


    /**
     * 分段常数需求： [startDay, endDay) -> dailyRate。endDay 为 null 表示无穷大
     */
    public static final class DemandSegment {
        public final Long skuId;

        // 起始天（含）
        public final int startDayInclusive;
        // 结束天（不含），null表示无穷大
        public final Integer endDayExclusive;
        // 日需求
        public final BigDecimal dailyRate;

        public DemandSegment(Long skuId, int startDayInclusive, Integer endDayExclusive, BigDecimal dailyRate) {
            this.skuId = skuId;
            if (startDayInclusive < 0) throw new IllegalArgumentException("startDay must be >= 0");
            if (endDayExclusive != null && endDayExclusive <= startDayInclusive) {
                throw new IllegalArgumentException("endDayExclusive must be > startDayInclusive");
            }
            this.startDayInclusive = startDayInclusive;
            this.endDayExclusive = endDayExclusive;
            this.dailyRate = dailyRate;
        }

        public boolean contains(int day) {
            if (day < startDayInclusive) return false;
            if (endDayExclusive == null) return true;
            return day < endDayExclusive;
        }
    }

    /**
     * 分段需求曲线
     */
    public static final class StepDemandCurve {
        private final Map<Long, List<DemandSegment>> bySkuId;

        public StepDemandCurve(List<DemandSegment> segments) {
            if (segments == null || segments.isEmpty()) throw new IllegalArgumentException("segments required");
            this.bySkuId = segments.stream().collect(Collectors.groupingBy(s -> s.skuId));
        }

        public BigDecimal rateAt(Long skuId, int day) {
            List<DemandSegment> currentSegments = bySkuId.get(skuId);
            if (currentSegments == null || currentSegments.isEmpty()) {
                throw new IllegalStateException("No demand segments for skuId=" + skuId);
            }
            for (DemandSegment s : currentSegments) {
                if (s.contains(day)) return s.dailyRate;
            }
            throw new IllegalStateException("skuId=" + skuId + " no demand segment covers day=" + day);
        }
    }

    /**
     * 新品备货计算
     *
     * @return
     */
    public Boolean computeNewSkuStockup() {
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        Long companyId = ThreadLocalUserHolder.getUser().getCompanyId();

        SysConfigResponse newTagConfigResponse = sysConfigService.getConfigByConfigKey(Constant.NEW_TAG_STAT_DAY);
        if (ObjectUtil.isNull(newTagConfigResponse) || CollectionUtil.isEmpty(newTagConfigResponse.getConfigItemList())) {
            throw new IllegalArgumentException("无法找到新品打标统计天数配置，请先配置，configKey=" + Constant.NEW_TAG_STAT_DAY);
        }
        Map<String, BigDecimal> newTagConfigMap = parseCodeConfig(newTagConfigResponse.getConfigItemList());
        int saleday = newTagConfigMap.getOrDefault("NEW_TAG_STAT_DAY_SALEDAY", BigDecimal.valueOf(90)).intValue();
        int listingday = newTagConfigMap.getOrDefault("NEW_TAG_STAT_DAY_LISTINGDAY", BigDecimal.valueOf(120)).intValue();

        List<CosGoodsSpuResponse> spuResponseList = cosGoodsSpuService.getNewSpuTagList(companyId, saleday, listingday);
        if (CollectionUtil.isEmpty(spuResponseList)) {
            throw new IllegalArgumentException("无法找到对应的SPU信息，companyId=" + companyId);
        }
        List<Long> spuIdList = spuResponseList.stream().map(CosGoodsSpuResponse::getId).collect(Collectors.toList());
        List<CosGoodsSku> skuList = cosGoodsSkuService.getSkuListBySpuIdList(spuIdList);

        Set<Long> allSkuIdSet = new LinkedHashSet<>();
        List<TagUserPermissionResponse> permissionResponses =
                tagUserPermissionService.getNewSkuTagPermissionList(Constant.NEW_TAG_ID, 2);
        if (CollectionUtil.isNotEmpty(permissionResponses)) {
            for (TagUserPermissionResponse p : permissionResponses) {
                if (p == null || p.getDataSourceValue() == null) continue;
                allSkuIdSet.add(Long.valueOf(p.getDataSourceValue()));
            }
        }
        if (CollectionUtil.isNotEmpty(skuList)) {
            for (CosGoodsSku s : skuList) {
                if (s != null && s.getId() != null) allSkuIdSet.add(s.getId());
            }
        }
        if (allSkuIdSet.isEmpty()) return false;

        List<Long> allSkuIds = new ArrayList<>(allSkuIdSet);
        List<CosGoodsSku> allSkuList = cosGoodsSkuService.listByIds(allSkuIds);

        List<CosDailyAvgRuleDateExcludeResponse> dailyAvgRuleSkuList =
                cosDailyAvgRuleService.getDateExcludeByRuleId(allSkuIds, ExcludeTypeEnum.CLIMBING);
        Map<Long, List<CosDailyAvgRuleDateExcludeResponse>> ruleSkuMapGroup = dailyAvgRuleSkuList.stream()
                .filter(r -> r != null && r.getCosDailyAvgRuleSkuResponse() != null)
                .collect(Collectors.groupingBy(CosDailyAvgRuleDateExcludeResponse::getSkuId));

        StockingInput config = initSystemConfig();
        Integer defaultShipmentDay = Constant.DEFAULT_SHIPMENT_DAY;

        // segments 一次性构建 + StepDemandCurve 内部按 skuId 分组
        config.setDemandCurve(new StepDemandCurve(buildSegments(allSkuList, ruleSkuMapGroup, defaultShipmentDay)));
        initBusinessConfig(config);

        for (CosGoodsSku sku : allSkuList) {
            StockingOutput stockingOutput = compute(sku, config);
            if (CollectionUtil.isEmpty(stockingOutput.byWarehouse)) continue;

            CosStockupPlanDto stockupPlanDto = buildStockupPlan(companyId, sku, stockingOutput);
            result.set(cosStockupPlanService.saveIncidentalStockupPlanData(stockupPlanDto));
        }
        return result.get();
    }


    /**
     * 计算新品备货
     */
    public static StockingOutput compute(CosGoodsSku sku, StockingInput stockingInput) {
        int minArrivalDay = stockingInput.arrivalDay.values().stream()
                .mapToInt(x -> x)
                .min()
                .orElseThrow(() -> new IllegalArgumentException("arrivalDay must have at least one warehouse"));

        int allArrivedDay = stockingInput.arrivalDay.values().stream()
                .mapToInt(x -> x)
                .max()
                .orElseThrow(() -> new IllegalArgumentException("arrivalDay must have at least one warehouse"));

        BigDecimal allArrivedDaily = stockingInput.demandCurve.rateAt(sku.getId(), allArrivedDay);

        Map<WarehouseEnum, BigDecimal> consumption = new EnumMap<>(WarehouseEnum.class);
        for (WarehouseEnum w : WarehouseEnum.values()) consumption.put(w, BigDecimal.ZERO);

        for (int day = minArrivalDay; day < allArrivedDay; day++) {
            BigDecimal daily = stockingInput.demandCurve.rateAt(sku.getId(), day);
            int finalDay = day;

            List<WarehouseEnum> arrived = Arrays.stream(WarehouseEnum.values())
                    .filter(w -> stockingInput.arrivalDay.get(w) != null && stockingInput.arrivalDay.get(w) <= finalDay)
                    .collect(Collectors.toList());

            if (arrived.isEmpty()) {
                throw new IllegalStateException("No warehouse arrived at day=" + day + ", cannot fulfill demand.");
            }

            List<Long> arrivedIds = arrived.stream().map(WarehouseEnum::getRegionId).collect(Collectors.toList());
            List<Long> allRegionIds = stockingInput.allRegionIds;
            List<Long> notArrivedIds = CollectionUtil.subtractToList(allRegionIds, arrivedIds);

            String key = notArrivedIds.stream().sorted().map(String::valueOf).collect(Collectors.joining(","));
            NewSkuConfig.Rule rule = stockingInput.rules.get(key);

            if (rule != null && rule.getWeights() != null) {
                Map<String, BigDecimal> weights = rule.getWeights();
                for (WarehouseEnum w : arrived) {
                    BigDecimal weight = weights.get(w.getRegionId().toString());
                    if (weight != null && weight.compareTo(BigDecimal.ZERO) > 0) {
                        consumption.put(w, consumption.get(w).add(daily.multiply(weight)));
                    }
                }
            }
        }

        BigDecimal ratioSum = stockingInput.regionRatio.values().stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        if (ratioSum.compareTo(BigDecimal.ONE) != 0) {
            throw new IllegalArgumentException("regionRatio must sum to 1.0, but was " + ratioSum);
        }

        Map<WarehouseEnum, WarehouseResult> result = new EnumMap<>(WarehouseEnum.class);
        for (WarehouseEnum w : WarehouseEnum.values()) {
            BigDecimal regionWeight = stockingInput.regionRatio.getOrDefault(w, BigDecimal.ZERO);
            BigDecimal regionalDaily = allArrivedDaily.multiply(regionWeight).setScale(0, BigDecimal.ROUND_CEILING);

            Integer regionalSafeDays = (stockingInput.regionSafeDays == null)
                    ? stockingInput.defaultSafetyDays
                    : stockingInput.regionSafeDays.getOrDefault(w, stockingInput.defaultSafetyDays);

            BigDecimal safetyStock = BigDecimal.valueOf(regionalSafeDays)
                    .multiply(regionalDaily)
                    .setScale(0, BigDecimal.ROUND_CEILING);

            result.put(w, new WarehouseResult(
                    consumption.get(w),
                    stockingInput.arrivalDay.get(w),
                    safetyStock,
                    regionalSafeDays
            ));
        }

        return new StockingOutput(true, allArrivedDay, allArrivedDaily, result);
    }

    /**
     * 计算输入参数
     */
    @Data
    public static final class StockingInput {

        public LocalDate today;
        public LocalDate launchDate;          // SKU上架时间
        public LocalDate listingCreateDate;   // Listing创建时间

        public Map<WarehouseEnum, Integer> arrivalDay;          // 到货日(从发货起算)
        public Map<WarehouseEnum, BigDecimal> regionRatio;      // 到齐后区域订单比例 p_i，和=1
        public Map<WarehouseEnum, Integer> regionSafeDays;      // 各区域安全库存天数，默认35天

        public int defaultSafetyDays = 35;                      // 默认安全库存天数
        public int newByLaunchDays = 90;
        public int newByListingDays = 120;
        public int defaultShipmentDay = 30;                     // 默认物流时效

        public Boolean useRegionRatioConfig = true; // 是否使用配置的区域比例

        // 全国需求曲线
        public StepDemandCurve demandCurve;

        // 新品配置（可选）
        public NewSkuConfig skuConfig;

        // 所有区域id（可选）
        public List<Long> allRegionIds;

        // 新品规则映射（可选）
        private Map<String, NewSkuConfig.Rule> rules;

        // 区域安全库存天数配置（可选）
        private Map<Long, BigDecimal> regionSafeMap;

    }

    /**
     * 单仓计算结果
     */
    @Data
    public static final class WarehouseResult {

        public final BigDecimal preAllArriveConsumption; // 到齐前消耗(按到齐前均分规则)
        public final Integer shippingDays;               // 物流时效(从发货起算)
        public final BigDecimal safetyStock;             // 到齐后安全库存(35天,按区域日销)
        public final Integer safetyDays;                 // 安全库存天数
        public final BigDecimal shipQty;                 // 发货量 = 消耗 + 安全库存

        public WarehouseResult(BigDecimal preAllArriveConsumption, Integer shippingDays, BigDecimal safetyStock, Integer safetyDays) {
            this.preAllArriveConsumption = preAllArriveConsumption;
            this.shippingDays = shippingDays;
            this.safetyStock = safetyStock;
            this.safetyDays = safetyDays;
            this.shipQty = preAllArriveConsumption.add(safetyStock);
        }

        @Override
        public String toString() {
            return "consumption=" + preAllArriveConsumption + ", safetyStock=" + safetyStock + ", shipQty=" + shipQty;
        }
    }

    /**
     * 计算输出结果
     */
    public static final class StockingOutput {

        // 是否是新款
        public final boolean isNew;

        // 到齐日
        public final int allArrivedDay;
        // 到齐后全国日销
        public final BigDecimal allArrivedDaily;
        // 各仓结果
        public final Map<WarehouseEnum, WarehouseResult> byWarehouse;
        // 总备货量
        public final BigDecimal totalShipQty;

        public StockingOutput(boolean isNew, int allArrivedDay,
                              BigDecimal allArrivedDaily,
                              Map<WarehouseEnum, WarehouseResult> byWarehouse) {
            this.isNew = isNew;
            this.allArrivedDay = allArrivedDay;
            this.allArrivedDaily = allArrivedDaily;
            this.byWarehouse = Collections.unmodifiableMap(new EnumMap<>(byWarehouse));
            this.totalShipQty = byWarehouse.values().stream().map(WarehouseResult::getShipQty)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
        }
    }


    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class NewSkuConfig {

        private Map<String, String> warehouseIdMap;

        private Map<String, Rule> rules;

        @Data
        @NoArgsConstructor
        @AllArgsConstructor
        @JsonIgnoreProperties(ignoreUnknown = true)
        public static class Rule {
            /**
             * weights 映射，key 为仓库 id 字符串，value 为权重（可能是负数或小数）
             */
            private Map<String, BigDecimal> weights;
        }
    }


    private List<DemandSegment> buildSegments(List<CosGoodsSku> allSkuList,
                                              Map<Long, List<CosDailyAvgRuleDateExcludeResponse>> ruleSkuMapGroup,
                                              Integer defaultShipmentDay) {
        List<DemandSegment> segments = new ArrayList<>();
        for (CosGoodsSku sku : allSkuList) {
            List<CosDailyAvgRuleDateExcludeResponse> rules = ruleSkuMapGroup.get(sku.getId());
            if (CollectionUtil.isNotEmpty(rules)) {
                for (CosDailyAvgRuleDateExcludeResponse r : rules) {
                    segments.add(new DemandSegment(
                            sku.getId(),
                            defaultShipmentDay,
                            defaultShipmentDay + r.getExcludeDays(),
                            r.getActualValue()));
                }
            } else {
                segments.add(new DemandSegment(sku.getId(), 0, 45, BigDecimal.valueOf(6)));
                segments.add(new DemandSegment(sku.getId(), 45, 55, BigDecimal.valueOf(8)));
                segments.add(new DemandSegment(sku.getId(), 55, null, BigDecimal.valueOf(10)));
            }
        }
        return segments;
    }

    private CosStockupPlanDto buildStockupPlan(Long companyId, CosGoodsSku sku, StockingOutput stockingOutput) {
        CosStockupPlanDto stockupPlanDto = new CosStockupPlanDto();
        List<CosStockupPlanItemDto> itemDtoList = new ArrayList<>();
        for (Map.Entry<WarehouseEnum, WarehouseResult> entry : stockingOutput.byWarehouse.entrySet()) {
            WarehouseEnum warehouseEnum = entry.getKey();
            WarehouseResult warehouseResult = entry.getValue();

            CosStockupPlanItemDto itemDto = new CosStockupPlanItemDto();
            itemDto.setId(IdUtils.getId());
            itemDto.setStockupId(stockupPlanDto.getId());
            itemDto.setGoodsLevel("N");
            itemDto.setCompanyId(companyId);
            itemDto.setLogicShopId(warehouseEnum.getRegionId());
            itemDto.setStockupDate(LocalDate.now());
            itemDto.setSkuId(sku.getId());
            itemDto.setSkuCode(sku.getSkuCode());
            itemDto.setSpuId(sku.getSpuId());
            itemDto.setSpuCode(sku.getSpuCode());
            itemDto.setNeedStockup(warehouseResult.getShipQty().compareTo(BigDecimal.ZERO) > 0 ? 1 : 0);
            itemDto.setSuggestStockupNum(warehouseResult.getShipQty().setScale(0, BigDecimal.ROUND_CEILING).intValue());
            itemDto.setShippingDays(warehouseResult.getShippingDays());
            itemDtoList.add(itemDto);
        }

        stockupPlanDto.setCompanyId(companyId);
        stockupPlanDto.setStockupStatus(0);
        stockupPlanDto.setStockupNum(stockingOutput.totalShipQty.setScale(0, BigDecimal.ROUND_CEILING).intValue());
        stockupPlanDto.setStockupDate(LocalDate.now());
        stockupPlanDto.setStockupType(StockupTypeEnum.NEW_PRODUCT_STOCKUP.getCode());
        stockupPlanDto.setItemList(itemDtoList);
        return stockupPlanDto;
    }



    /**
     * 初始化业务配置
     */
    private void initBusinessConfig(StockingInput config) {
        // 各区域安全库存天数
        SysConfigResponse regionSafeResponse = sysConfigService.getConfigByConfigKey(Constant.REGION_SAFE_STOCK_DAY);
        if (ObjectUtil.isNotNull(regionSafeResponse) && CollectionUtil.isNotEmpty(regionSafeResponse.getConfigItemList())) {
            Map<Long, BigDecimal> regionSafeMap = parseConfig(regionSafeResponse.getConfigItemList());
            regionSafeMap.forEach((regionId, safeDays) -> {
                WarehouseEnum warehouseEnum = WarehouseEnum.fromRegionId(regionId);
                if (warehouseEnum != null) {
                    config.regionSafeDays.put(warehouseEnum, safeDays.intValue());
                }
            });
            config.regionSafeMap = regionSafeMap;
        }

        // 各区域物流天数
        SysConfigResponse regionShipDayResponse = sysConfigService.getConfigByConfigKey(Constant.REGION_SHIPMENT_DAY);
        if (ObjectUtil.isNotNull(regionShipDayResponse) && CollectionUtil.isNotEmpty(regionShipDayResponse.getConfigItemList())) {
            Map<Long, BigDecimal> regionShipDayMap = parseConfig(regionShipDayResponse.getConfigItemList());
            regionShipDayMap.forEach((regionId, shipDays) -> {
                WarehouseEnum warehouseEnum = WarehouseEnum.fromRegionId(regionId);
                if (warehouseEnum != null) {
                    config.arrivalDay.put(warehouseEnum, shipDays.intValue());
                }
            });
        }

        // 使用默认值
        if (config.getUseRegionRatioConfig() == false) {
            SysConfigResponse regionOrderResponse = sysConfigService.getConfigByConfigKey(Constant.REGION_ORDER_RATIO);
            if (ObjectUtil.isNotNull(regionOrderResponse) && CollectionUtil.isNotEmpty(regionOrderResponse.getConfigItemList())) {
                Map<Long, BigDecimal> regionOrderMap = parseConfig(regionOrderResponse.getConfigItemList());
                regionOrderMap.forEach((regionId, weight) -> {
                    WarehouseEnum warehouseEnum = WarehouseEnum.fromRegionId(regionId);
                    if (warehouseEnum != null) {
                        config.regionRatio.put(warehouseEnum, weight);
                    }
                });
            }
        }

    }


    /**
     * 解析系统配置项
     */
    private static StockingInput initSystemConfig() {
        String jsonConfig = getJsonConfig();
        NewSkuConfig skuConfig = null;
        if (ObjectUtil.isNotNull(jsonConfig)) {
            skuConfig = JsonUtil.transferToObj(jsonConfig, NewSkuConfig.class);
        }
        StockingInput stockingInput = new StockingInput();

        if (ObjectUtil.isNotNull(skuConfig)) {
            stockingInput.skuConfig = skuConfig;
            stockingInput.allRegionIds = skuConfig.getWarehouseIdMap().values().stream().map(x -> Long.valueOf(x)).collect(Collectors.toList());
            stockingInput.rules = skuConfig.getRules();
        }
        stockingInput.launchDate = LocalDate.now().minusDays(90);
        stockingInput.listingCreateDate = LocalDate.now().minusDays(120); // <=120天(示例)

        // 到货日(从发货起算)：这里仍然使用示例固定值；如需从配置/接口注入，可在此处替换
        stockingInput.arrivalDay = new EnumMap<>(WarehouseEnum.class);
        for (WarehouseEnum w : WarehouseEnum.values()) {
            stockingInput.arrivalDay.put(w, 30);
        }

        // 区域比例：优先从 jsonConfig.rules[""] 的 weights 按 warehouseIdMap 映射到 WarehouseEnum
        stockingInput.regionRatio = new EnumMap<>(WarehouseEnum.class);
        for (WarehouseEnum w : WarehouseEnum.values()) {
            stockingInput.regionRatio.put(w, BigDecimal.ZERO);
        }
        // 安全库存天数：默认35天
        stockingInput.regionSafeDays = new EnumMap<>(WarehouseEnum.class);
        for (WarehouseEnum w : WarehouseEnum.values()) {
            stockingInput.regionSafeDays.put(w, 35);
        }

        if (skuConfig != null && skuConfig.getWarehouseIdMap() != null) {
            Map<String, BigDecimal> weights = skuConfig.getRules().get("all").getWeights();
            // 将 json 中的 key(如 "west") 映射为 WarehouseEnum；并用其 warehouseId 找到权重
            Map<WarehouseEnum, BigDecimal> raw = new EnumMap<>(WarehouseEnum.class);
            for (Map.Entry<String, String> e : skuConfig.getWarehouseIdMap().entrySet()) {
                String k = e.getKey();
                String id = e.getValue();
                if (id == null) continue;

                WarehouseEnum wh = parseWarehouseEnum(k);
                if (wh == null) continue;

                BigDecimal w = weights.get(id);
                if (w == null) continue;

                // 仅接受正权重作为“发货比例”的候选；<=0 视为不参与
                if (w.compareTo(BigDecimal.ZERO) > 0) {
                    raw.put(wh, w);
                }
            }

            BigDecimal sum = raw.values().stream().reduce(BigDecimal.ZERO, BigDecimal::add);
            if (sum.compareTo(BigDecimal.ZERO) < 0) {
                throw new IllegalArgumentException("json 配置的 rules未提供任何>0的权重，无法计算区域发货比例");
            }
            for (Map.Entry<WarehouseEnum, BigDecimal> e : raw.entrySet()) {
                stockingInput.regionRatio.put(e.getKey(), e.getValue().divide(sum));
            }
        } else {
            stockingInput.useRegionRatioConfig = false;
        }

        return stockingInput;
    }


    private static WarehouseEnum parseWarehouseEnum(String k) {
        for (WarehouseEnum w : WarehouseEnum.values()) {
            if (w.getRegionCode().equals(k)) {
                return w;
            }
        }
        return null;
    }


    private static String getJsonConfig() {
        String jsonConfig = "{\n" +
                "  \"warehouseIdMap\": {\n" +
                "    \"west\": \"1764655782335020001\",\n" +
                "    \"south\": \"1764655782335020002\",\n" +
                "    \"east\": \"1764655782335020003\",\n" +
                "    \"central\": \"1764655782335020004\",\n" +
                "    \"north\": \"1764655782335020006\"\n" +
                "  },\n" +

                "  \"rules\": {\n" +
                "    \"all\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.25,\n" +
                "        \"1764655782335020003\": 0.30,\n" +
                "        \"1764655782335020002\": 0.35,\n" +
                "        \"1764655782335020004\": 0.10,\n" +
                "        \"1764655782335020006\": 0.00\n" +
                "      }\n" +
                "    },\n" +
                "\n" +
                "    \"1764655782335020001\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": 0,\n" +
                "        \"1764655782335020002\": 0.6,\n" +
                "        \"1764655782335020004\": 0.4,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020002\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0,\n" +
                "        \"1764655782335020003\": 0.6,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": 0.4,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020003\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": 0.8,\n" +
                "        \"1764655782335020004\": 0.2,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020004\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.5,\n" +
                "        \"1764655782335020003\": 0,\n" +
                "        \"1764655782335020002\": 0.5,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0,\n" +
                "        \"1764655782335020003\": 0.4,\n" +
                "        \"1764655782335020002\": 0.4,\n" +
                "        \"1764655782335020004\": 0.2,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "\n" +
                "    \"1764655782335020001,1764655782335020003\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": 0.7,\n" +
                "        \"1764655782335020004\": 0.3,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020002\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": 0.6,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": 0.4,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020004\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": 0.3,\n" +
                "        \"1764655782335020002\": 0.7,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": 0.3,\n" +
                "        \"1764655782335020002\": 0.4,\n" +
                "        \"1764655782335020004\": 0.3,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020002,1764655782335020003\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.6,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": 0.4,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020003,1764655782335020004\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.4,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": 0.6,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020003,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.2,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": 0.6,\n" +
                "        \"1764655782335020004\": 0.2,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020002,1764655782335020004\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.5,\n" +
                "        \"1764655782335020003\": 0.5,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020002,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.2,\n" +
                "        \"1764655782335020003\": 0.6,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": 0.2,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020004,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.4,\n" +
                "        \"1764655782335020003\": 0.4,\n" +
                "        \"1764655782335020002\": 0.2,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "\n" +
                "    \"1764655782335020001,1764655782335020002,1764655782335020003\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": 1,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020003,1764655782335020004\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": 1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020003,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": 0.7,\n" +
                "        \"1764655782335020004\": 0.3,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020002,1764655782335020004\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": 1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020002,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": 0.6,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": 0.4,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020004,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": 0.4,\n" +
                "        \"1764655782335020002\": 0.6,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020002,1764655782335020003,1764655782335020004\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": 0\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020002,1764655782335020003,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.7,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": 0.3,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020003,1764655782335020004,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.4,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": 0.6,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020002,1764655782335020004,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 0.5,\n" +
                "        \"1764655782335020003\": 0.5,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020002,1764655782335020004,1764655782335020006,1764655782335020001\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": 1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020002,1764655782335020003,1764655782335020004,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020002,1764655782335020004,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": 1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020003,1764655782335020004,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": 1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020002,1764655782335020003,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": 1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "    \"1764655782335020001,1764655782335020002,1764655782335020003,1764655782335020004\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": 1\n" +
                "      }\n" +
                "    },\n" +
                "\n" +
                "    \"1764655782335020003,1764655782335020002,1764655782335020004,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": 1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    },\n" +
                "\n" +
                "    \"1764655782335020001,1764655782335020002,1764655782335020003,1764655782335020004,1764655782335020006\": {\n" +
                "      \"weights\": {\n" +
                "        \"1764655782335020001\": -1,\n" +
                "        \"1764655782335020003\": -1,\n" +
                "        \"1764655782335020002\": -1,\n" +
                "        \"1764655782335020004\": -1,\n" +
                "        \"1764655782335020006\": -1\n" +
                "      }\n" +
                "    }\n" +
                "}\n" +
                "}";

        return jsonConfig;
    }

    /**
     * 解析配置项，返回以refObjId为key，配置值为BigDecimal的Map
     *
     * @param configItemList 配置项列表
     * @return 解析后的配置Map
     */
    private Map<Long, BigDecimal> parseConfig(List<SysConfigItemResponse> configItemList) {
        Map<Long, BigDecimal> configMap = new HashMap<>();
        if (CollectionUtil.isNotEmpty(configItemList)) {
            for (SysConfigItemResponse item : configItemList) {
                try {
                    Long key = item.getRefObjId();
                    if (Integer.valueOf(1).equals(item.getDataType())) {
                        BigDecimal value = new BigDecimal(item.getConfigItemValue());
                        configMap.put(key, value);
                    }
                    if (Integer.valueOf(4).equals(item.getDataType())) {
                        BigDecimal value = new BigDecimal(item.getConfigItemValue().replace("%", "")).divide(new BigDecimal(100));
                        configMap.put(key, value);
                    }
                } catch (Exception e) {
                    log.error("解析配置项失败，itemKey={}, itemValue={}", item.getRefObjId(), item.getConfigItemValue(), e);
                }
            }
        }
        return configMap;
    }

    /**
     * 解析配置项，返回以configItemCode为key，配置值为BigDecimal的Map
     *
     * @param configItemList
     * @return
     */
    private Map<String, BigDecimal> parseCodeConfig(List<SysConfigItemResponse> configItemList) {
        Map<String, BigDecimal> configMap = new HashMap<>();
        if (CollectionUtil.isNotEmpty(configItemList)) {
            for (SysConfigItemResponse item : configItemList) {
                try {
                    String key = item.getConfigItemCode();
                    if (Integer.valueOf(1).equals(item.getDataType())) {
                        BigDecimal value = new BigDecimal(item.getConfigItemValue());
                        configMap.put(key, value);
                    }
                    if (Integer.valueOf(4).equals(item.getDataType())) {
                        BigDecimal value = new BigDecimal(item.getConfigItemValue().replace("%", "")).divide(new BigDecimal(100));
                        configMap.put(key, value);
                    }
                } catch (Exception e) {
                    log.error("解析配置项失败，itemKey={}, itemValue={}", item.getRefObjId(), item.getConfigItemValue(), e);
                }
            }
        }
        return configMap;
    }

}
