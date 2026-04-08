package com.buyi.datawarehouse.model.catalog;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 销售商品关联仓库明细模型
 * Sell Goods Warehouse SKU Item Model
 *
 * 对应数据库表：amf_jh_sell_goods_item
 * 销售商品与仓库SKU的关联明细表，
 * 记录每个仓库SKU的数量比例、规格尺寸等信息。
 */
public class SellGoodsItem implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 明细ID（主键） */
    private Long id;

    /** 关联销售商品ID（对应 SellGoods.id） */
    private Long sellGoodsId;

    /** 用户标识 */
    private String userKey;

    /** 仓库SKU */
    private String warehouseSku;

    /** 仓库商品名称 */
    private String warehouseName;

    /** 仓库SKU数量（关联比例，如 1=1个销售SKU对应1个仓库SKU） */
    private Integer warehouseSkuNum;

    /** 店铺ID */
    private Integer shopId;

    /** 公司仓库商品关联ID */
    private Long companyWhProductRelationId;

    /** 比例系数（默认0.00） */
    private BigDecimal scaleNum;

    /** 商品长度（单位：cm） */
    private BigDecimal pLength;

    /** 商品宽度（单位：cm） */
    private BigDecimal pWidth;

    /** 商品高度（单位：cm） */
    private BigDecimal pHeight;

    /** 商品净重（单位：kg） */
    private BigDecimal netWeight;

    /** 创建人ID */
    private Integer createUserId;

    /** 创建时间 */
    private LocalDateTime createTime;

    /** 更新时间 */
    private LocalDateTime updateTime;

    public SellGoodsItem() {
        this.scaleNum = BigDecimal.ZERO;
        this.warehouseSkuNum = 1;
    }

    /**
     * 计算商品体积（长 × 宽 × 高，单位：cm³）
     *
     * @return 体积，任一尺寸为null或零则返回null
     */
    public BigDecimal calculateVolume() {
        if (pLength != null && pWidth != null && pHeight != null
                && pLength.compareTo(BigDecimal.ZERO) > 0
                && pWidth.compareTo(BigDecimal.ZERO) > 0
                && pHeight.compareTo(BigDecimal.ZERO) > 0) {
            return pLength.multiply(pWidth).multiply(pHeight);
        }
        return null;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getSellGoodsId() {
        return sellGoodsId;
    }

    public void setSellGoodsId(Long sellGoodsId) {
        this.sellGoodsId = sellGoodsId;
    }

    public String getUserKey() {
        return userKey;
    }

    public void setUserKey(String userKey) {
        this.userKey = userKey;
    }

    public String getWarehouseSku() {
        return warehouseSku;
    }

    public void setWarehouseSku(String warehouseSku) {
        this.warehouseSku = warehouseSku;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public Integer getWarehouseSkuNum() {
        return warehouseSkuNum;
    }

    public void setWarehouseSkuNum(Integer warehouseSkuNum) {
        this.warehouseSkuNum = warehouseSkuNum;
    }

    public Integer getShopId() {
        return shopId;
    }

    public void setShopId(Integer shopId) {
        this.shopId = shopId;
    }

    public Long getCompanyWhProductRelationId() {
        return companyWhProductRelationId;
    }

    public void setCompanyWhProductRelationId(Long companyWhProductRelationId) {
        this.companyWhProductRelationId = companyWhProductRelationId;
    }

    public BigDecimal getScaleNum() {
        return scaleNum;
    }

    public void setScaleNum(BigDecimal scaleNum) {
        this.scaleNum = scaleNum;
    }

    public BigDecimal getPLength() {
        return pLength;
    }

    public void setPLength(BigDecimal pLength) {
        this.pLength = pLength;
    }

    public BigDecimal getPWidth() {
        return pWidth;
    }

    public void setPWidth(BigDecimal pWidth) {
        this.pWidth = pWidth;
    }

    public BigDecimal getPHeight() {
        return pHeight;
    }

    public void setPHeight(BigDecimal pHeight) {
        this.pHeight = pHeight;
    }

    public BigDecimal getNetWeight() {
        return netWeight;
    }

    public void setNetWeight(BigDecimal netWeight) {
        this.netWeight = netWeight;
    }

    public Integer getCreateUserId() {
        return createUserId;
    }

    public void setCreateUserId(Integer createUserId) {
        this.createUserId = createUserId;
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
        return "SellGoodsItem{" +
                "id=" + id +
                ", sellGoodsId=" + sellGoodsId +
                ", warehouseSku='" + warehouseSku + '\'' +
                ", warehouseSkuNum=" + warehouseSkuNum +
                ", scaleNum=" + scaleNum +
                '}';
    }
}
