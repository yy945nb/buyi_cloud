package com.buyi.datawarehouse.catalog;

import com.buyi.datawarehouse.model.catalog.CompanyGoods;
import com.buyi.datawarehouse.model.catalog.CompanyGoodsItem;
import com.buyi.datawarehouse.model.catalog.PurchaseGoods;
import com.buyi.datawarehouse.model.catalog.SellGoods;
import com.buyi.datawarehouse.model.catalog.SellGoodsItem;
import com.buyi.datawarehouse.model.catalog.SpuSkuMapping;
import com.buyi.datawarehouse.service.catalog.ProductCatalogService;
import org.junit.Before;
import org.junit.Test;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.*;

/**
 * 商品档案/产品档案服务测试
 * Product Catalog Service Tests
 *
 * 验证商品档案（CompanyGoods）和产品档案（PurchaseGoods/SellGoods）
 * 的注册、查询、SKU链路解析等核心功能。
 */
public class ProductCatalogServiceTest {

    private ProductCatalogService catalogService;

    @Before
    public void setUp() {
        catalogService = new ProductCatalogService();
    }

    // ============ 商品档案（CompanyGoods）测试 ============

    @Test
    public void testRegisterCompanyGoods() {
        CompanyGoods goods = createCompanyGoods("WL-FZ-39-W-TJ", "39寸方桌白色-退件", "1", true);
        catalogService.registerCompanyGoods(goods);

        assertEquals(1, catalogService.getCompanyGoodsCount());
        CompanyGoods retrieved = catalogService.getCompanyGoodsBySku("WL-FZ-39-W-TJ");
        assertNotNull(retrieved);
        assertEquals("WL-FZ-39-W-TJ", retrieved.getCompanySku());
        assertEquals("39寸方桌白色-退件", retrieved.getCompanySkuName());
    }

    @Test
    public void testRegisterCompanyGoodsUpdatesExisting() {
        CompanyGoods v1 = createCompanyGoods("WL-FZ-39-W", "方桌白色v1", "1", true);
        CompanyGoods v2 = createCompanyGoods("WL-FZ-39-W", "方桌白色v2-更新", "1", true);

        catalogService.registerCompanyGoods(v1);
        catalogService.registerCompanyGoods(v2);

        assertEquals("商品档案更新后数量不变", 1, catalogService.getCompanyGoodsCount());
        assertEquals("方桌白色v2-更新", catalogService.getCompanyGoodsBySku("WL-FZ-39-W").getCompanySkuName());
    }

    @Test
    public void testRegisterCompanyGoodsNullSkuThrows() {
        CompanyGoods goods = new CompanyGoods();
        goods.setId(1L);
        // companySku is null

        try {
            catalogService.registerCompanyGoods(goods);
            fail("Expected IllegalArgumentException");
        } catch (IllegalArgumentException e) {
            assertTrue(e.getMessage().contains("companySku"));
        }
    }

    @Test
    public void testCompanyGoodsWithItems() {
        CompanyGoods goods = createCompanyGoods("WL-FZ-BUNDLE-001", "桌椅套装", "1", true);
        CompanyGoodsItem item1 = createGoodsItem(1001L, goods.getId(), "WL-FZ-TABLE-001", 1);
        CompanyGoodsItem item2 = createGoodsItem(1002L, goods.getId(), "WL-FZ-CHAIR-001", 4);
        goods.setItemList(Arrays.asList(item1, item2));

        catalogService.registerCompanyGoods(goods);

        List<String> warehouseSkus = catalogService.resolveWarehouseSkuByCompanySku("WL-FZ-BUNDLE-001");
        assertEquals(2, warehouseSkus.size());
        assertTrue(warehouseSkus.contains("WL-FZ-TABLE-001"));
        assertTrue(warehouseSkus.contains("WL-FZ-CHAIR-001"));
    }

    @Test
    public void testResolveWarehouseSkuByCompanySkuNotFound() {
        List<String> result = catalogService.resolveWarehouseSkuByCompanySku("NON-EXISTENT-SKU");
        assertNotNull(result);
        assertTrue("未找到时应返回空列表", result.isEmpty());
    }

    @Test
    public void testCompanyGoodsIsActiveAndOnShelves() {
        CompanyGoods activeGoods = createCompanyGoods("SKU-ACTIVE", "正常上架商品", "1", true);
        CompanyGoods inactiveGoods = createCompanyGoods("SKU-INACTIVE", "下架商品", "2", false);

        assertTrue(activeGoods.isActive());
        assertTrue(activeGoods.isOnShelves());

        assertFalse(inactiveGoods.isActive());
        assertFalse(inactiveGoods.isOnShelves());
    }

    @Test
    public void testBatchRegisterCompanyGoods() {
        List<CompanyGoods> goodsList = Arrays.asList(
                createCompanyGoods("SKU-001", "商品1", "1", true),
                createCompanyGoods("SKU-002", "商品2", "1", true),
                createCompanyGoods("SKU-003", "商品3", "1", false)
        );

        int count = catalogService.registerCompanyGoodsBatch(goodsList);
        assertEquals(3, count);
        assertEquals(3, catalogService.getCompanyGoodsCount());
    }

    // ============ 产品档案（PurchaseGoods）测试 ============

    @Test
    public void testRegisterPurchaseGoods() {
        PurchaseGoods goods = createPurchaseGoods("AC-ZHYJ-CBGFB-WHITE-B", "组合柜白色B包", "onlineproduct");
        catalogService.registerPurchaseGoods(goods);

        assertEquals(1, catalogService.getPurchaseGoodsCount());
        PurchaseGoods retrieved = catalogService.getPurchaseGoodsBySku("AC-ZHYJ-CBGFB-WHITE-B");
        assertNotNull(retrieved);
        assertEquals("AC-ZHYJ-CBGFB-WHITE-B", retrieved.getWarehouseSku());
        assertEquals("组合柜白色B包", retrieved.getNameCn());
    }

    @Test
    public void testPurchaseGoodsVolumeCalculation() {
        PurchaseGoods goods = new PurchaseGoods();
        goods.setWarehouseSku("TEST-SKU-001");
        goods.setPLength(new BigDecimal("109.0"));
        goods.setPWidth(new BigDecimal("48.5"));
        goods.setPHeight(new BigDecimal("15.0"));

        BigDecimal volume = goods.calculateVolume();
        assertNotNull(volume);
        assertEquals(new BigDecimal("109.0").multiply(new BigDecimal("48.5")).multiply(new BigDecimal("15.0")), volume);
    }

    @Test
    public void testPurchaseGoodsVolumeNullWhenMissingDimension() {
        PurchaseGoods goods = new PurchaseGoods();
        goods.setWarehouseSku("TEST-SKU-002");
        goods.setPLength(new BigDecimal("109.0"));
        // pWidth and pHeight are null

        assertNull("缺少尺寸时体积应为null", goods.calculateVolume());
    }

    @Test
    public void testPurchaseGoodsOuterBoxVolumeCalculation() {
        PurchaseGoods goods = new PurchaseGoods();
        goods.setWarehouseSku("TEST-SKU-003");
        goods.setPLengthOut(new BigDecimal("120.0"));
        goods.setPWidthOut(new BigDecimal("55.0"));
        goods.setPHeightOut(new BigDecimal("20.0"));

        BigDecimal outerVolume = goods.calculateOuterBoxVolume();
        assertNotNull(outerVolume);
        assertEquals(
                new BigDecimal("120.0").multiply(new BigDecimal("55.0")).multiply(new BigDecimal("20.0")),
                outerVolume
        );
    }

    @Test
    public void testPurchaseGoodsIsOnlineProduct() {
        PurchaseGoods onlineGoods = createPurchaseGoods("SKU-ONLINE", "在线商品", "onlineproduct");
        PurchaseGoods offlineGoods = createPurchaseGoods("SKU-OFFLINE", "已下线商品", "offlineproduct");

        assertTrue(onlineGoods.isOnlineProduct());
        assertFalse(offlineGoods.isOnlineProduct());
    }

    @Test
    public void testRegisterPurchaseGoodsNullSkuThrows() {
        PurchaseGoods goods = new PurchaseGoods();
        goods.setId(1L);
        // warehouseSku is null

        try {
            catalogService.registerPurchaseGoods(goods);
            fail("Expected IllegalArgumentException");
        } catch (IllegalArgumentException e) {
            assertTrue(e.getMessage().contains("warehouseSku"));
        }
    }

    // ============ 销售商品档案（SellGoods）测试 ============

    @Test
    public void testRegisterSellGoods() {
        SellGoods sellGoods = createSellGoods("SELL-SKU-001", "Amazon US 方桌", 1001, "WL-FZ-39-W");
        catalogService.registerSellGoods(sellGoods);

        assertEquals(1, catalogService.getSellGoodsCount());
        SellGoods retrieved = catalogService.getSellGoodsBySellSku("SELL-SKU-001");
        assertNotNull(retrieved);
        assertEquals("SELL-SKU-001", retrieved.getSellSku());
        assertEquals("WL-FZ-39-W", retrieved.getCompanySku());
    }

    @Test
    public void testResolveWarehouseSkuBySellSkuViaCompanyGoods() {
        // 设置 CompanyGoods 映射
        CompanyGoods companyGoods = createCompanyGoods("WL-FZ-39-W", "方桌白色", "1", true);
        CompanyGoodsItem item = createGoodsItem(1001L, companyGoods.getId(), "WL-WH-TABLE-001", 1);
        companyGoods.setItemList(Arrays.asList(item));
        catalogService.registerCompanyGoods(companyGoods);

        // 设置 SellGoods（没有直接 item，通过 companySku 解析）
        SellGoods sellGoods = createSellGoods("SELL-SKU-001", "Amazon US 方桌", 1001, "WL-FZ-39-W");
        catalogService.registerSellGoods(sellGoods);

        List<String> warehouseSkus = catalogService.resolveWarehouseSkuBySellSku("SELL-SKU-001");
        assertEquals(1, warehouseSkus.size());
        assertEquals("WL-WH-TABLE-001", warehouseSkus.get(0));
    }

    @Test
    public void testResolveWarehouseSkuBySellSkuDirectItems() {
        // SellGoods 有直接的 SellGoodsItem 关联仓库SKU
        SellGoods sellGoods = createSellGoods("SELL-SKU-002", "Walmart 套装", 1002, "WL-FZ-BUNDLE");
        SellGoodsItem item1 = createSellGoodsItem(sellGoods.getId(), "WH-SKU-PART-A");
        SellGoodsItem item2 = createSellGoodsItem(sellGoods.getId(), "WH-SKU-PART-B");
        sellGoods.setItemList(Arrays.asList(item1, item2));
        catalogService.registerSellGoods(sellGoods);

        List<String> warehouseSkus = catalogService.resolveWarehouseSkuBySellSku("SELL-SKU-002");
        assertEquals(2, warehouseSkus.size());
        assertTrue(warehouseSkus.contains("WH-SKU-PART-A"));
        assertTrue(warehouseSkus.contains("WH-SKU-PART-B"));
    }

    @Test
    public void testResolveWarehouseSkuBySellSkuNotFound() {
        List<String> result = catalogService.resolveWarehouseSkuBySellSku("NON-EXISTENT-SELL-SKU");
        assertNotNull(result);
        assertTrue("未找到时应返回空列表", result.isEmpty());
    }

    @Test
    public void testSellGoodsIsOnShelvesAndStockUploaded() {
        SellGoods onShelves = createSellGoods("SELL-ON", "上架商品", 1001, "COMP-SKU-1");
        onShelves.setIsShelves(1);
        onShelves.setIsUploadStock(1);

        SellGoods offShelves = createSellGoods("SELL-OFF", "下架商品", 1001, "COMP-SKU-2");
        offShelves.setIsShelves(0);
        offShelves.setIsUploadStock(0);

        assertTrue(onShelves.isOnShelves());
        assertTrue(onShelves.isStockUploaded());

        assertFalse(offShelves.isOnShelves());
        assertFalse(offShelves.isStockUploaded());
    }

    // ============ SPU-SKU 映射测试 ============

    @Test
    public void testRegisterSpuSkuMapping() {
        SpuSkuMapping mapping = createSpuSkuMapping("AP-XZSJ-5C-R", "XZSJ-5C红色", 50, 20);
        catalogService.registerSpuSku(mapping);

        assertEquals(1, catalogService.getSpuSkuMappingCount());
        assertEquals("XZSJ-5C红色", catalogService.resolveSpuByWarehouseSku("AP-XZSJ-5C-R"));
    }

    @Test
    public void testDeletedSpuSkuNotRegistered() {
        SpuSkuMapping deleted = createSpuSkuMapping("WH-SKU-DELETED", "SPU-DELETED", 0, 0);
        deleted.setIsdel(1);  // 标记为已删除
        catalogService.registerSpuSku(deleted);

        assertEquals("已删除的SPU-SKU映射不应被注册", 0, catalogService.getSpuSkuMappingCount());
        assertNull(catalogService.resolveSpuByWarehouseSku("WH-SKU-DELETED"));
    }

    @Test
    public void testResolveSpuByWarehouseSkuNotFound() {
        assertNull("不存在的SKU应返回null SPU", catalogService.resolveSpuByWarehouseSku("NON-EXISTENT-SKU"));
    }

    @Test
    public void testResolveWarehouseSkuBySpu() {
        catalogService.registerSpuSku(createSpuSkuMapping("SKU-RED", "TABLE-SPU-001", 10, 5));
        catalogService.registerSpuSku(createSpuSkuMapping("SKU-BLUE", "TABLE-SPU-001", 8, 3));
        catalogService.registerSpuSku(createSpuSkuMapping("SKU-GREEN", "CHAIR-SPU-001", 6, 2));

        List<String> tableSkus = catalogService.resolveWarehouseSkuBySpu("TABLE-SPU-001");
        assertEquals(2, tableSkus.size());
        assertTrue(tableSkus.contains("SKU-RED"));
        assertTrue(tableSkus.contains("SKU-BLUE"));
    }

    @Test
    public void testSpuSkuMappingGetTotalAvailableQty() {
        SpuSkuMapping mapping = createSpuSkuMapping("SKU-001", "SPU-001", 50, 20);
        assertEquals(70, mapping.getTotalAvailableQty());
    }

    @Test
    public void testSpuSkuMappingNullQtySafe() {
        SpuSkuMapping mapping = new SpuSkuMapping();
        mapping.setWarehouseSku("SKU-NULL-QTY");
        mapping.setSpu("SPU-001");
        // stockQty and factoryQty are null (default 0)
        assertEquals(0, mapping.getTotalAvailableQty());
    }

    @Test
    public void testBatchRegisterSpuSku() {
        List<SpuSkuMapping> mappings = Arrays.asList(
                createSpuSkuMapping("WH-SKU-001", "SPU-A", 10, 5),
                createSpuSkuMapping("WH-SKU-002", "SPU-A", 8, 3),
                createSpuSkuMapping("WH-SKU-003", "SPU-B", 15, 0)
        );
        int count = catalogService.registerSpuSkuBatch(mappings);
        assertEquals(3, count);
        assertEquals(3, catalogService.getSpuSkuMappingCount());
    }

    // ============ 综合 SKU 链路解析测试 ============

    @Test
    public void testGetPurchaseGoodsBySellSku() {
        // 注册 SPU-SKU 映射
        catalogService.registerSpuSku(createSpuSkuMapping("WH-TABLE-001", "TABLE-SPU", 50, 10));

        // 注册产品档案（以 warehouseSku 为键）
        PurchaseGoods purchaseGoods = createPurchaseGoods("WH-TABLE-001", "方桌", "onlineproduct");
        purchaseGoods.setRoughWeight(new BigDecimal("27.45"));
        catalogService.registerPurchaseGoods(purchaseGoods);

        // 注册商品档案（company_sku → warehouse_sku）
        CompanyGoods companyGoods = createCompanyGoods("COMP-TABLE-001", "方桌公司档案", "1", true);
        companyGoods.setItemList(Arrays.asList(createGoodsItem(1L, companyGoods.getId(), "WH-TABLE-001", 1)));
        catalogService.registerCompanyGoods(companyGoods);

        // 注册销售商品档案
        SellGoods sellGoods = createSellGoods("AMAZON-TABLE-001", "Amazon 方桌", 1001, "COMP-TABLE-001");
        catalogService.registerSellGoods(sellGoods);

        // 通过 sellSku 解析完整产品档案
        List<PurchaseGoods> result = catalogService.getPurchaseGoodsBySellSku("AMAZON-TABLE-001");
        assertEquals(1, result.size());
        assertEquals("WH-TABLE-001", result.get(0).getWarehouseSku());
        assertEquals("方桌", result.get(0).getNameCn());
        assertEquals(new BigDecimal("27.45"), result.get(0).getRoughWeight());
    }

    @Test
    public void testResolveSpuBySellSku() {
        // 注册 SPU-SKU
        catalogService.registerSpuSku(createSpuSkuMapping("WH-CHAIR-001", "CHAIR-SPU-2024", 20, 5));

        // 注册商品档案（company_sku → warehouse_sku）
        CompanyGoods companyGoods = createCompanyGoods("COMP-CHAIR", "椅子公司档案", "1", true);
        companyGoods.setItemList(Arrays.asList(createGoodsItem(2L, companyGoods.getId(), "WH-CHAIR-001", 1)));
        catalogService.registerCompanyGoods(companyGoods);

        // 注册销售商品档案
        SellGoods sellGoods = createSellGoods("WALMART-CHAIR-001", "Walmart 椅子", 2001, "COMP-CHAIR");
        catalogService.registerSellGoods(sellGoods);

        // 通过 sellSku 解析 SPU
        List<String> spus = catalogService.resolveSpuBySellSku("WALMART-CHAIR-001");
        assertEquals(1, spus.size());
        assertEquals("CHAIR-SPU-2024", spus.get(0));
    }

    // ============ 子模型测试 ============

    @Test
    public void testCompanyGoodsItemVolumeCalculation() {
        CompanyGoodsItem item = new CompanyGoodsItem();
        item.setPLength(new BigDecimal("100.0"));
        item.setPWidth(new BigDecimal("50.0"));
        item.setPHeight(new BigDecimal("30.0"));

        BigDecimal volume = item.calculateVolume();
        assertNotNull(volume);
        assertEquals(
                new BigDecimal("100.0").multiply(new BigDecimal("50.0")).multiply(new BigDecimal("30.0")),
                volume
        );
    }

    @Test
    public void testSellGoodsItemVolumeCalculation() {
        SellGoodsItem item = new SellGoodsItem();
        item.setPLength(new BigDecimal("120.0"));
        item.setPWidth(new BigDecimal("60.0"));
        item.setPHeight(new BigDecimal("40.0"));

        BigDecimal volume = item.calculateVolume();
        assertNotNull(volume);
        assertEquals(
                new BigDecimal("120.0").multiply(new BigDecimal("60.0")).multiply(new BigDecimal("40.0")),
                volume
        );
    }

    @Test
    public void testSellGoodsItemVolumeNullWhenZeroDimension() {
        SellGoodsItem item = new SellGoodsItem();
        item.setPLength(BigDecimal.ZERO);
        item.setPWidth(new BigDecimal("60.0"));
        item.setPHeight(new BigDecimal("40.0"));

        assertNull("包含零值尺寸时体积应为null", item.calculateVolume());
    }

    @Test
    public void testCompanyGoodsDefaultValues() {
        CompanyGoods goods = new CompanyGoods();
        assertFalse("默认未上架", goods.getIsShelves());
        assertNotNull("itemList不应为null", goods.getItemList());
        assertTrue("默认itemList为空", goods.getItemList().isEmpty());
    }

    @Test
    public void testSellGoodsDefaultValues() {
        SellGoods goods = new SellGoods();
        assertEquals(Integer.valueOf(0), goods.getIsShelves());
        assertEquals(Integer.valueOf(0), goods.getIsUploadStock());
        assertEquals(Integer.valueOf(0), goods.getIsSplit());
        assertNotNull("itemList不应为null", goods.getItemList());
    }

    @Test
    public void testSpuSkuMappingIsDeleted() {
        SpuSkuMapping normal = new SpuSkuMapping();
        normal.setIsdel(0);
        assertFalse(normal.isDeleted());

        SpuSkuMapping deleted = new SpuSkuMapping();
        deleted.setIsdel(1);
        assertTrue(deleted.isDeleted());
    }

    // ============ 辅助方法 ============

    private CompanyGoods createCompanyGoods(String companySku, String name, String flag, boolean isShelves) {
        CompanyGoods goods = new CompanyGoods();
        goods.setId((long) companySku.hashCode());
        goods.setUserKey("USER-001");
        goods.setCompanySku(companySku);
        goods.setCompanySkuName(name);
        goods.setFlag(flag);
        goods.setIsShelves(isShelves);
        goods.setCreateTime(LocalDateTime.of(2024, 1, 1, 0, 0));
        goods.setUpdateTime(LocalDateTime.of(2024, 1, 1, 0, 0));
        return goods;
    }

    private CompanyGoodsItem createGoodsItem(Long id, Long companyProductId, String warehouseSku, int qty) {
        CompanyGoodsItem item = new CompanyGoodsItem();
        item.setId(id);
        item.setCompanyProductId(companyProductId);
        item.setWarehouseSku(warehouseSku);
        item.setWarehouseSkuNum(qty);
        item.setUserKey("USER-001");
        return item;
    }

    private PurchaseGoods createPurchaseGoods(String warehouseSku, String nameCn, String pStatus) {
        PurchaseGoods goods = new PurchaseGoods();
        goods.setId((long) warehouseSku.hashCode());
        goods.setUserKey("USER-001");
        goods.setWarehouseSku(warehouseSku);
        goods.setNameCn(nameCn);
        goods.setNameEn(warehouseSku);
        goods.setPStatus(pStatus);
        goods.setCreateTime(LocalDateTime.of(2024, 1, 1, 0, 0));
        goods.setUpdateTime(LocalDateTime.of(2024, 1, 1, 0, 0));
        return goods;
    }

    private SellGoods createSellGoods(String sellSku, String name, int shopId, String companySku) {
        SellGoods goods = new SellGoods();
        goods.setId((long) sellSku.hashCode());
        goods.setUserKey("USER-001");
        goods.setSellSku(sellSku);
        goods.setSellSkuName(name);
        goods.setShopId(shopId);
        goods.setCompanySku(companySku);
        goods.setCreateTime(LocalDateTime.of(2024, 1, 1, 0, 0));
        goods.setUpdateTime(LocalDateTime.of(2024, 1, 1, 0, 0));
        return goods;
    }

    private SellGoodsItem createSellGoodsItem(Long sellGoodsId, String warehouseSku) {
        SellGoodsItem item = new SellGoodsItem();
        item.setSellGoodsId(sellGoodsId);
        item.setWarehouseSku(warehouseSku);
        item.setWarehouseSkuNum(1);
        item.setUserKey("USER-001");
        return item;
    }

    private SpuSkuMapping createSpuSkuMapping(String warehouseSku, String spu, int stockQty, int factoryQty) {
        SpuSkuMapping mapping = new SpuSkuMapping();
        mapping.setWarehouseSku(warehouseSku);
        mapping.setSpu(spu);
        mapping.setStockQty(stockQty);
        mapping.setFactoryQty(factoryQty);
        mapping.setIsdel(0);
        mapping.setCreateTime(LocalDateTime.of(2024, 1, 1, 0, 0));
        return mapping;
    }
}
