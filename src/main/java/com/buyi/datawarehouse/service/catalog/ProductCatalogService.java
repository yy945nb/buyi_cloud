package com.buyi.datawarehouse.service.catalog;

import com.buyi.datawarehouse.model.catalog.CompanyGoods;
import com.buyi.datawarehouse.model.catalog.CompanyGoodsItem;
import com.buyi.datawarehouse.model.catalog.PurchaseGoods;
import com.buyi.datawarehouse.model.catalog.SellGoods;
import com.buyi.datawarehouse.model.catalog.SellGoodsItem;
import com.buyi.datawarehouse.model.catalog.SpuSkuMapping;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 商品档案/产品档案服务
 * Product Catalog Service
 *
 * 负责管理商品档案（CompanyGoods）和产品档案（PurchaseGoods / SellGoods）
 * 的内存索引与 SKU 解析，支持：
 *
 * 1. 商品档案（商品档案 = 公司内部产品目录）：
 *    - company_sku → warehouse_sku 映射（一对多）
 *    - 通过 CompanyGoods + CompanyGoodsItem 组合表示
 *
 * 2. 产品档案（产品档案 = 仓库采购商品目录）：
 *    - warehouse_sku → 规格、重量、采购价格等完整产品属性
 *    - 通过 PurchaseGoods 表示
 *
 * 3. 销售商品档案（sell_sku → company_sku / warehouse_sku 映射）：
 *    - 通过 SellGoods + SellGoodsItem 组合表示
 *
 * 4. SPU-SKU 映射（warehouse_sku → SPU 解析）：
 *    - 通过 SpuSkuMapping 表示
 *
 * 核心业务能力：
 * - 通过 sell_sku 解析到对应的 warehouse_sku 列表
 * - 通过 company_sku 获取商品规格/档案信息
 * - 通过 warehouse_sku 查询 SPU 和采购档案
 */
public class ProductCatalogService {
    private static final Logger logger = LoggerFactory.getLogger(ProductCatalogService.class);

    /** 商品档案索引：companySku → CompanyGoods */
    private final Map<String, CompanyGoods> companyGoodsIndex;

    /** 产品档案索引：warehouseSku → PurchaseGoods */
    private final Map<String, PurchaseGoods> purchaseGoodsIndex;

    /** 销售商品档案索引：sellSku → SellGoods */
    private final Map<String, SellGoods> sellGoodsIndex;

    /** SPU-SKU映射索引：warehouseSku → SpuSkuMapping（仅未删除的记录） */
    private final Map<String, SpuSkuMapping> spuSkuIndex;

    public ProductCatalogService() {
        this.companyGoodsIndex = new HashMap<>();
        this.purchaseGoodsIndex = new HashMap<>();
        this.sellGoodsIndex = new HashMap<>();
        this.spuSkuIndex = new HashMap<>();
    }

    // ─────────────────────────────────────────────────────────
    // 商品档案（CompanyGoods）管理
    // ─────────────────────────────────────────────────────────

    /**
     * 注册/更新商品档案（amf_jh_company_goods）
     *
     * @param goods 商品档案
     */
    public void registerCompanyGoods(CompanyGoods goods) {
        if (goods == null || goods.getCompanySku() == null) {
            throw new IllegalArgumentException("商品档案及其 companySku 不能为空");
        }
        companyGoodsIndex.put(goods.getCompanySku(), goods);
        logger.debug("Registered company goods: companySku={}, itemCount={}",
                goods.getCompanySku(),
                goods.getItemList() != null ? goods.getItemList().size() : 0);
    }

    /**
     * 批量注册商品档案
     *
     * @param goodsList 商品档案列表
     * @return 成功注册数量
     */
    public int registerCompanyGoodsBatch(List<CompanyGoods> goodsList) {
        if (goodsList == null || goodsList.isEmpty()) {
            return 0;
        }
        int count = 0;
        for (CompanyGoods goods : goodsList) {
            try {
                registerCompanyGoods(goods);
                count++;
            } catch (Exception e) {
                logger.warn("Failed to register company goods: {}", e.getMessage());
            }
        }
        logger.info("Registered {} / {} company goods records", count, goodsList.size());
        return count;
    }

    /**
     * 通过公司SKU获取商品档案
     *
     * @param companySku 公司SKU
     * @return 商品档案，不存在则返回null
     */
    public CompanyGoods getCompanyGoodsBySku(String companySku) {
        return companyGoodsIndex.get(companySku);
    }

    /**
     * 通过公司SKU查找对应的仓库SKU列表
     * 支持一个公司SKU对应多个仓库SKU（套装商品）
     *
     * @param companySku 公司SKU
     * @return 仓库SKU列表，不存在则返回空列表
     */
    public List<String> resolveWarehouseSkuByCompanySku(String companySku) {
        CompanyGoods goods = companyGoodsIndex.get(companySku);
        if (goods == null) {
            logger.debug("No company goods found for companySku={}", companySku);
            return Collections.emptyList();
        }
        return goods.getWarehouseSkuList();
    }

    /**
     * 通过公司SKU查找对应的仓库SKU子表明细
     *
     * @param companySku 公司SKU
     * @return 仓库SKU明细列表
     */
    public List<CompanyGoodsItem> getCompanyGoodsItems(String companySku) {
        CompanyGoods goods = companyGoodsIndex.get(companySku);
        if (goods == null || goods.getItemList() == null) {
            return Collections.emptyList();
        }
        return goods.getItemList();
    }

    // ─────────────────────────────────────────────────────────
    // 产品档案（PurchaseGoods）管理
    // ─────────────────────────────────────────────────────────

    /**
     * 注册/更新产品档案（amf_jh_purchase_goods）
     *
     * @param goods 采购商品档案
     */
    public void registerPurchaseGoods(PurchaseGoods goods) {
        if (goods == null || goods.getWarehouseSku() == null) {
            throw new IllegalArgumentException("产品档案及其 warehouseSku 不能为空");
        }
        purchaseGoodsIndex.put(goods.getWarehouseSku(), goods);
        logger.debug("Registered purchase goods: warehouseSku={}", goods.getWarehouseSku());
    }

    /**
     * 批量注册产品档案
     *
     * @param goodsList 产品档案列表
     * @return 成功注册数量
     */
    public int registerPurchaseGoodsBatch(List<PurchaseGoods> goodsList) {
        if (goodsList == null || goodsList.isEmpty()) {
            return 0;
        }
        int count = 0;
        for (PurchaseGoods goods : goodsList) {
            try {
                registerPurchaseGoods(goods);
                count++;
            } catch (Exception e) {
                logger.warn("Failed to register purchase goods: {}", e.getMessage());
            }
        }
        logger.info("Registered {} / {} purchase goods records", count, goodsList.size());
        return count;
    }

    /**
     * 通过仓库SKU获取产品档案
     *
     * @param warehouseSku 仓库SKU
     * @return 产品档案，不存在则返回null
     */
    public PurchaseGoods getPurchaseGoodsBySku(String warehouseSku) {
        return purchaseGoodsIndex.get(warehouseSku);
    }

    // ─────────────────────────────────────────────────────────
    // 销售商品档案（SellGoods）管理
    // ─────────────────────────────────────────────────────────

    /**
     * 注册/更新销售商品档案（amf_jh_sell_goods）
     *
     * @param sellGoods 销售商品档案
     */
    public void registerSellGoods(SellGoods sellGoods) {
        if (sellGoods == null || sellGoods.getSellSku() == null) {
            throw new IllegalArgumentException("销售商品档案及其 sellSku 不能为空");
        }
        sellGoodsIndex.put(sellGoods.getSellSku(), sellGoods);
        logger.debug("Registered sell goods: sellSku={}, companySku={}",
                sellGoods.getSellSku(), sellGoods.getCompanySku());
    }

    /**
     * 通过销售SKU获取销售商品档案
     *
     * @param sellSku 销售SKU
     * @return 销售商品档案，不存在则返回null
     */
    public SellGoods getSellGoodsBySellSku(String sellSku) {
        return sellGoodsIndex.get(sellSku);
    }

    /**
     * 通过销售SKU解析对应的仓库SKU列表
     * 链路：sell_sku → company_sku → warehouse_sku（via CompanyGoods）
     * 或直接：sell_sku → warehouse_sku（via SellGoodsItem）
     *
     * @param sellSku 销售SKU
     * @return 仓库SKU列表（优先使用 SellGoodsItem 中的明细，其次通过 CompanyGoods 解析）
     */
    public List<String> resolveWarehouseSkuBySellSku(String sellSku) {
        SellGoods sellGoods = sellGoodsIndex.get(sellSku);
        if (sellGoods == null) {
            logger.debug("No sell goods found for sellSku={}", sellSku);
            return Collections.emptyList();
        }

        // 优先使用 SellGoodsItem 中直接关联的仓库SKU
        List<String> directWarehouseSkus = sellGoods.getWarehouseSkuList();
        if (!directWarehouseSkus.isEmpty()) {
            return directWarehouseSkus;
        }

        // 其次通过 company_sku → CompanyGoods → warehouse_sku 链路解析
        if (sellGoods.getCompanySku() != null) {
            return resolveWarehouseSkuByCompanySku(sellGoods.getCompanySku());
        }

        return Collections.emptyList();
    }

    /**
     * 通过销售SKU解析对应的仓库SKU明细列表
     *
     * @param sellSku 销售SKU
     * @return 仓库SKU明细列表
     */
    public List<SellGoodsItem> getSellGoodsItems(String sellSku) {
        SellGoods sellGoods = sellGoodsIndex.get(sellSku);
        if (sellGoods == null || sellGoods.getItemList() == null) {
            return Collections.emptyList();
        }
        return sellGoods.getItemList();
    }

    // ─────────────────────────────────────────────────────────
    // SPU-SKU 映射（SpuSkuMapping）管理
    // ─────────────────────────────────────────────────────────

    /**
     * 注册SPU-SKU映射（amf_spu_sku）
     *
     * @param mapping SPU-SKU映射
     */
    public void registerSpuSku(SpuSkuMapping mapping) {
        if (mapping == null || mapping.getWarehouseSku() == null) {
            throw new IllegalArgumentException("SPU-SKU映射及其 warehouseSku 不能为空");
        }
        if (!mapping.isDeleted()) {
            spuSkuIndex.put(mapping.getWarehouseSku(), mapping);
        }
    }

    /**
     * 批量注册SPU-SKU映射
     *
     * @param mappings SPU-SKU映射列表
     * @return 成功注册数量
     */
    public int registerSpuSkuBatch(List<SpuSkuMapping> mappings) {
        if (mappings == null || mappings.isEmpty()) {
            return 0;
        }
        int count = 0;
        for (SpuSkuMapping mapping : mappings) {
            try {
                registerSpuSku(mapping);
                count++;
            } catch (Exception e) {
                logger.warn("Failed to register SPU-SKU mapping: {}", e.getMessage());
            }
        }
        logger.info("Registered {} / {} SPU-SKU mappings", count, mappings.size());
        return count;
    }

    /**
     * 通过仓库SKU解析SPU编码
     *
     * @param warehouseSku 仓库SKU
     * @return SPU编码，不存在则返回null
     */
    public String resolveSpuByWarehouseSku(String warehouseSku) {
        SpuSkuMapping mapping = spuSkuIndex.get(warehouseSku);
        return mapping != null ? mapping.getSpu() : null;
    }

    /**
     * 通过仓库SKU获取SPU-SKU映射
     *
     * @param warehouseSku 仓库SKU
     * @return SPU-SKU映射，不存在则返回null
     */
    public SpuSkuMapping getSpuSkuMapping(String warehouseSku) {
        return spuSkuIndex.get(warehouseSku);
    }

    /**
     * 通过 SPU 获取所有关联的仓库SKU列表
     *
     * @param spu SPU编码
     * @return 仓库SKU列表
     */
    public List<String> resolveWarehouseSkuBySpu(String spu) {
        List<String> result = new ArrayList<>();
        for (SpuSkuMapping mapping : spuSkuIndex.values()) {
            if (spu.equals(mapping.getSpu()) && !mapping.isDeleted()) {
                result.add(mapping.getWarehouseSku());
            }
        }
        return result;
    }

    // ─────────────────────────────────────────────────────────
    // 综合解析（SKU链路打通）
    // ─────────────────────────────────────────────────────────

    /**
     * 通过销售SKU获取完整产品档案信息
     * 链路：sell_sku → warehouse_sku → PurchaseGoods
     *
     * @param sellSku 销售SKU
     * @return 对应的产品档案列表（可能有多个，如套装商品）
     */
    public List<PurchaseGoods> getPurchaseGoodsBySellSku(String sellSku) {
        List<String> warehouseSkus = resolveWarehouseSkuBySellSku(sellSku);
        List<PurchaseGoods> result = new ArrayList<>();
        for (String warehouseSku : warehouseSkus) {
            PurchaseGoods goods = purchaseGoodsIndex.get(warehouseSku);
            if (goods != null) {
                result.add(goods);
            }
        }
        return result;
    }

    /**
     * 通过销售SKU解析 SPU 编码
     * 链路：sell_sku → warehouse_sku → SPU
     *
     * @param sellSku 销售SKU
     * @return SPU编码列表（一个销售SKU可能对应多个warehouse_sku，每个对应一个SPU）
     */
    public List<String> resolveSpuBySellSku(String sellSku) {
        List<String> warehouseSkus = resolveWarehouseSkuBySellSku(sellSku);
        List<String> result = new ArrayList<>();
        for (String warehouseSku : warehouseSkus) {
            String spu = resolveSpuByWarehouseSku(warehouseSku);
            if (spu != null && !result.contains(spu)) {
                result.add(spu);
            }
        }
        return result;
    }

    // ─────────────────────────────────────────────────────────
    // 统计查询
    // ─────────────────────────────────────────────────────────

    /** 获取商品档案总数 */
    public int getCompanyGoodsCount() {
        return companyGoodsIndex.size();
    }

    /** 获取产品档案总数 */
    public int getPurchaseGoodsCount() {
        return purchaseGoodsIndex.size();
    }

    /** 获取销售商品档案总数 */
    public int getSellGoodsCount() {
        return sellGoodsIndex.size();
    }

    /** 获取SPU-SKU映射总数（仅有效记录） */
    public int getSpuSkuMappingCount() {
        return spuSkuIndex.size();
    }
}
