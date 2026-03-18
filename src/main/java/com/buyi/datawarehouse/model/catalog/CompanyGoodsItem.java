package com.buyi.datawarehouse.model.catalog;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 商品档案仓库SKU子表模型
 * Company Goods Warehouse SKU Item Model
 *
 * 对应数据库表：amf_jh_company_goods_item
 * 公司产品与仓库SKU的关联子表，一条公司产品（company_sku）
 * 可关联多个仓库SKU（warehouse_sku）及其数量比例。
 */
public class CompanyGoodsItem implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 子表主键ID（自增） */
    private Long id;

    /** 用户唯一标识 */
    private String userKey;

    /** 关联主表产品ID（对应 CompanyGoods.id） */
    private Long companyProductId;

    /** 仓库SKU编码（如：WL-HGFZ-BG47-B-TJ） */
    private String warehouseSku;

    /** 仓库SKU数量（公司产品包含多少个该仓库SKU） */
    private Integer warehouseSkuNum;

    /** 仓库SKU名称 */
    private String warehouseSkuName;

    /** 产品中文名称 */
    private String nameCn;

    /** 产品长度（单位：cm） */
    private BigDecimal pLength;

    /** 产品宽度（单位：cm） */
    private BigDecimal pWidth;

    /** 产品高度（单位：cm） */
    private BigDecimal pHeight;

    /** 产品净重（单位：kg） */
    private BigDecimal netWeight;

    /** 创建人ID */
    private Long createUserId;

    /** 子表记录创建时间 */
    private LocalDateTime createTime;

    /** 子表记录更新时间 */
    private LocalDateTime updateTime;

    public CompanyGoodsItem() {
    }

    /**
     * 计算产品体积（长 × 宽 × 高，单位：cm³）
     *
     * @return 体积，任一尺寸为null则返回null
     */
    public BigDecimal calculateVolume() {
        if (pLength != null && pWidth != null && pHeight != null) {
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

    public String getUserKey() {
        return userKey;
    }

    public void setUserKey(String userKey) {
        this.userKey = userKey;
    }

    public Long getCompanyProductId() {
        return companyProductId;
    }

    public void setCompanyProductId(Long companyProductId) {
        this.companyProductId = companyProductId;
    }

    public String getWarehouseSku() {
        return warehouseSku;
    }

    public void setWarehouseSku(String warehouseSku) {
        this.warehouseSku = warehouseSku;
    }

    public Integer getWarehouseSkuNum() {
        return warehouseSkuNum;
    }

    public void setWarehouseSkuNum(Integer warehouseSkuNum) {
        this.warehouseSkuNum = warehouseSkuNum;
    }

    public String getWarehouseSkuName() {
        return warehouseSkuName;
    }

    public void setWarehouseSkuName(String warehouseSkuName) {
        this.warehouseSkuName = warehouseSkuName;
    }

    public String getNameCn() {
        return nameCn;
    }

    public void setNameCn(String nameCn) {
        this.nameCn = nameCn;
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

    public Long getCreateUserId() {
        return createUserId;
    }

    public void setCreateUserId(Long createUserId) {
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
        return "CompanyGoodsItem{" +
                "id=" + id +
                ", companyProductId=" + companyProductId +
                ", warehouseSku='" + warehouseSku + '\'' +
                ", warehouseSkuNum=" + warehouseSkuNum +
                ", nameCn='" + nameCn + '\'' +
                '}';
    }
}
