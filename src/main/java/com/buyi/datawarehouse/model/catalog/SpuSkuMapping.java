package com.buyi.datawarehouse.model.catalog;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * SPU-SKU映射模型
 * SPU-SKU Mapping Model
 *
 * 对应数据库表：amf_spu_sku
 * 鲸汇系统备货发货SKU明细子表，建立仓库SKU与SPU的映射关系，
 * 用于订单中通过仓库SKU查找对应的SPU（产品款式分组）。
 */
public class SpuSkuMapping implements Serializable {
    private static final long serialVersionUID = 1L;

    /** SKU明细主键ID（自增） */
    private Long id;

    /** 仓库SKU编码（如：AP-XZSJ-5C-R），唯一性由业务层保证 */
    private String warehouseSku;

    /** SPU编码（如：XZSJ-5C红色），一个SPU对应多个SKU */
    private String spu;

    /** 在仓数量（当前仓库实际库存） */
    private Integer stockQty;

    /** 在制数量（工厂在生产中的数量） */
    private Integer factoryQty;

    /** 是否已删除（0=正常，1=已删除，软删除标记） */
    private Integer isdel;

    /** 明细创建时间 */
    private LocalDateTime createTime;

    /** 明细更新时间 */
    private LocalDateTime updateTime;

    public SpuSkuMapping() {
        this.isdel = 0;
        this.stockQty = 0;
        this.factoryQty = 0;
    }

    /**
     * 检查是否已被删除
     */
    public boolean isDeleted() {
        return Integer.valueOf(1).equals(isdel);
    }

    /**
     * 获取总可用数量（在仓 + 在制）
     */
    public int getTotalAvailableQty() {
        int stock = stockQty != null ? stockQty : 0;
        int factory = factoryQty != null ? factoryQty : 0;
        return stock + factory;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getWarehouseSku() {
        return warehouseSku;
    }

    public void setWarehouseSku(String warehouseSku) {
        this.warehouseSku = warehouseSku;
    }

    public String getSpu() {
        return spu;
    }

    public void setSpu(String spu) {
        this.spu = spu;
    }

    public Integer getStockQty() {
        return stockQty;
    }

    public void setStockQty(Integer stockQty) {
        this.stockQty = stockQty;
    }

    public Integer getFactoryQty() {
        return factoryQty;
    }

    public void setFactoryQty(Integer factoryQty) {
        this.factoryQty = factoryQty;
    }

    public Integer getIsdel() {
        return isdel;
    }

    public void setIsdel(Integer isdel) {
        this.isdel = isdel;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    @Override
    public String toString() {
        return "SpuSkuMapping{" +
                "id=" + id +
                ", warehouseSku='" + warehouseSku + '\'' +
                ", spu='" + spu + '\'' +
                ", stockQty=" + stockQty +
                ", factoryQty=" + factoryQty +
                ", isdel=" + isdel +
                '}';
    }
}
