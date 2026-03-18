package com.buyi.datawarehouse.model.catalog;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 采购商品档案模型
 * Purchase Goods Profile Model
 *
 * 对应数据库表：amf_jh_purchase_goods
 * 仓库采购商品表，以仓库SKU（warehouse_sku）为唯一标识，
 * 包含商品规格、重量尺寸、采购价格、状态等完整产品档案信息。
 */
public class PurchaseGoods implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 商品唯一ID（接口返回的id字段，非自增） */
    private Long id;

    /** 用户标识（用于用户数据隔离） */
    private String userKey;

    /** 仓库商品SKU（唯一编码，如：AC-ZHYJ-CBGFB-WHITE-B） */
    private String warehouseSku;

    /** 商品中文名称 */
    private String nameCn;

    /** 商品英文名称 */
    private String nameEn;

    /** 商品一级分类名称 */
    private String category;

    /** 一级分类ID */
    private Integer categoryId;

    /** 二级分类ID */
    private Integer categoryTwoId;

    /** 采购分类ID */
    private Integer purchaseCategoryId;

    /** 商品毛重（单位：kg） */
    private BigDecimal roughWeight;

    /** 商品净重（单位：kg） */
    private BigDecimal netWeight;

    /** 商品长度（单位：cm） */
    private BigDecimal pLength;

    /** 商品宽度（单位：cm） */
    private BigDecimal pWidth;

    /** 商品高度（单位：cm） */
    private BigDecimal pHeight;

    /** 外箱长度（单位：cm） */
    private BigDecimal pLengthOut;

    /** 外箱宽度（单位：cm） */
    private BigDecimal pWidthOut;

    /** 外箱高度（单位：cm） */
    private BigDecimal pHeightOut;

    /** 外箱数量 */
    private Integer outerboxNumber;

    /** 外箱毛重（单位：kg） */
    private BigDecimal outBoxRoughWeight;

    /** 外箱净重（单位：kg） */
    private BigDecimal outBoxNetWeight;

    /** 采购价值 */
    private BigDecimal purchaseValue;

    /** 采购货币类型（如：USD） */
    private String purchaseCurrency;

    /** 采购负责人ID */
    private Integer purchaseUserId;

    /** 采购负责人姓名 */
    private String purchaseUserName;

    /** 商品状态（如：onlineproduct=在线商品） */
    private String pStatus;

    /** 商品性质 */
    private String pNature;

    /** 商品单位 */
    private String unit;

    /** UPC编码（商品条码） */
    private String upcCode;

    /** HS编码（海关编码） */
    private String hsCode;

    /** 中文申报名称 */
    private String declareNameCn;

    /** 英文申报名称 */
    private String declareNameEn;

    /** 运输周期 */
    private String haulCycle;

    /** 采购周期 */
    private String purchaseCycle;

    /** 是否可拆分（0=否，1=是） */
    private Boolean isSplit;

    /** 是否为配件（0=否，1=是） */
    private Boolean isParts;

    /** 配件数量 */
    private Integer partsNum;

    /** 上线时间 */
    private LocalDateTime launchTime;

    /** 工厂ID */
    private Integer factoryId;

    /** 工厂名称 */
    private String factoryName;

    /** 商品图片URL */
    private String imgUrl;

    /** 记录创建时间 */
    private LocalDateTime createTime;

    /** 记录更新时间 */
    private LocalDateTime updateTime;

    public PurchaseGoods() {
        this.isSplit = false;
        this.isParts = false;
        this.partsNum = 0;
        this.outerboxNumber = 0;
    }

    /**
     * 计算商品体积（长 × 宽 × 高，单位：cm³）
     *
     * @return 体积，任一尺寸为null则返回null
     */
    public BigDecimal calculateVolume() {
        if (pLength != null && pWidth != null && pHeight != null) {
            return pLength.multiply(pWidth).multiply(pHeight);
        }
        return null;
    }

    /**
     * 计算外箱体积（外箱长 × 宽 × 高，单位：cm³）
     *
     * @return 外箱体积，任一尺寸为null则返回null
     */
    public BigDecimal calculateOuterBoxVolume() {
        if (pLengthOut != null && pWidthOut != null && pHeightOut != null) {
            return pLengthOut.multiply(pWidthOut).multiply(pHeightOut);
        }
        return null;
    }

    /**
     * 检查商品是否为在线商品
     */
    public boolean isOnlineProduct() {
        return "onlineproduct".equals(pStatus);
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

    public String getWarehouseSku() {
        return warehouseSku;
    }

    public void setWarehouseSku(String warehouseSku) {
        this.warehouseSku = warehouseSku;
    }

    public String getNameCn() {
        return nameCn;
    }

    public void setNameCn(String nameCn) {
        this.nameCn = nameCn;
    }

    public String getNameEn() {
        return nameEn;
    }

    public void setNameEn(String nameEn) {
        this.nameEn = nameEn;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public Integer getCategoryTwoId() {
        return categoryTwoId;
    }

    public void setCategoryTwoId(Integer categoryTwoId) {
        this.categoryTwoId = categoryTwoId;
    }

    public Integer getPurchaseCategoryId() {
        return purchaseCategoryId;
    }

    public void setPurchaseCategoryId(Integer purchaseCategoryId) {
        this.purchaseCategoryId = purchaseCategoryId;
    }

    public BigDecimal getRoughWeight() {
        return roughWeight;
    }

    public void setRoughWeight(BigDecimal roughWeight) {
        this.roughWeight = roughWeight;
    }

    public BigDecimal getNetWeight() {
        return netWeight;
    }

    public void setNetWeight(BigDecimal netWeight) {
        this.netWeight = netWeight;
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

    public BigDecimal getPLengthOut() {
        return pLengthOut;
    }

    public void setPLengthOut(BigDecimal pLengthOut) {
        this.pLengthOut = pLengthOut;
    }

    public BigDecimal getPWidthOut() {
        return pWidthOut;
    }

    public void setPWidthOut(BigDecimal pWidthOut) {
        this.pWidthOut = pWidthOut;
    }

    public BigDecimal getPHeightOut() {
        return pHeightOut;
    }

    public void setPHeightOut(BigDecimal pHeightOut) {
        this.pHeightOut = pHeightOut;
    }

    public Integer getOuterboxNumber() {
        return outerboxNumber;
    }

    public void setOuterboxNumber(Integer outerboxNumber) {
        this.outerboxNumber = outerboxNumber;
    }

    public BigDecimal getOutBoxRoughWeight() {
        return outBoxRoughWeight;
    }

    public void setOutBoxRoughWeight(BigDecimal outBoxRoughWeight) {
        this.outBoxRoughWeight = outBoxRoughWeight;
    }

    public BigDecimal getOutBoxNetWeight() {
        return outBoxNetWeight;
    }

    public void setOutBoxNetWeight(BigDecimal outBoxNetWeight) {
        this.outBoxNetWeight = outBoxNetWeight;
    }

    public BigDecimal getPurchaseValue() {
        return purchaseValue;
    }

    public void setPurchaseValue(BigDecimal purchaseValue) {
        this.purchaseValue = purchaseValue;
    }

    public String getPurchaseCurrency() {
        return purchaseCurrency;
    }

    public void setPurchaseCurrency(String purchaseCurrency) {
        this.purchaseCurrency = purchaseCurrency;
    }

    public Integer getPurchaseUserId() {
        return purchaseUserId;
    }

    public void setPurchaseUserId(Integer purchaseUserId) {
        this.purchaseUserId = purchaseUserId;
    }

    public String getPurchaseUserName() {
        return purchaseUserName;
    }

    public void setPurchaseUserName(String purchaseUserName) {
        this.purchaseUserName = purchaseUserName;
    }

    public String getPStatus() {
        return pStatus;
    }

    public void setPStatus(String pStatus) {
        this.pStatus = pStatus;
    }

    public String getPNature() {
        return pNature;
    }

    public void setPNature(String pNature) {
        this.pNature = pNature;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getUpcCode() {
        return upcCode;
    }

    public void setUpcCode(String upcCode) {
        this.upcCode = upcCode;
    }

    public String getHsCode() {
        return hsCode;
    }

    public void setHsCode(String hsCode) {
        this.hsCode = hsCode;
    }

    public String getDeclareNameCn() {
        return declareNameCn;
    }

    public void setDeclareNameCn(String declareNameCn) {
        this.declareNameCn = declareNameCn;
    }

    public String getDeclareNameEn() {
        return declareNameEn;
    }

    public void setDeclareNameEn(String declareNameEn) {
        this.declareNameEn = declareNameEn;
    }

    public String getHaulCycle() {
        return haulCycle;
    }

    public void setHaulCycle(String haulCycle) {
        this.haulCycle = haulCycle;
    }

    public String getPurchaseCycle() {
        return purchaseCycle;
    }

    public void setPurchaseCycle(String purchaseCycle) {
        this.purchaseCycle = purchaseCycle;
    }

    public Boolean getIsSplit() {
        return isSplit;
    }

    public void setIsSplit(Boolean isSplit) {
        this.isSplit = isSplit;
    }

    public Boolean getIsParts() {
        return isParts;
    }

    public void setIsParts(Boolean isParts) {
        this.isParts = isParts;
    }

    public Integer getPartsNum() {
        return partsNum;
    }

    public void setPartsNum(Integer partsNum) {
        this.partsNum = partsNum;
    }

    public LocalDateTime getLaunchTime() {
        return launchTime;
    }

    public void setLaunchTime(LocalDateTime launchTime) {
        this.launchTime = launchTime;
    }

    public Integer getFactoryId() {
        return factoryId;
    }

    public void setFactoryId(Integer factoryId) {
        this.factoryId = factoryId;
    }

    public String getFactoryName() {
        return factoryName;
    }

    public void setFactoryName(String factoryName) {
        this.factoryName = factoryName;
    }

    public String getImgUrl() {
        return imgUrl;
    }

    public void setImgUrl(String imgUrl) {
        this.imgUrl = imgUrl;
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
        return "PurchaseGoods{" +
                "id=" + id +
                ", warehouseSku='" + warehouseSku + '\'' +
                ", nameCn='" + nameCn + '\'' +
                ", pStatus='" + pStatus + '\'' +
                ", purchaseValue=" + purchaseValue +
                ", purchaseCurrency='" + purchaseCurrency + '\'' +
                '}';
    }
}
