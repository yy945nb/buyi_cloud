package com.buyi.datawarehouse.model.catalog;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 商品档案主表模型
 * Company Goods Profile Main Model
 *
 * 对应数据库表：amf_jh_company_goods
 * 公司产品信息主表，以公司内部SKU（company_sku）为唯一标识，
 * 关联一到多个仓库SKU（通过 CompanyGoodsItem 子表）。
 */
public class CompanyGoods implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 产品主键ID（原始数据唯一标识） */
    private Long id;

    /** 用户唯一标识（用于用户数据隔离） */
    private String userKey;

    /** 公司产品SKU编码（如：WL-FZ-39-W-TJ），唯一 */
    private String companySku;

    /** 产品图片URL（允许为空） */
    private String companySkuImg;

    /** 公司产品名称 */
    private String companySkuName;

    /** 产品状态标识（如：1=正常，2=退件） */
    private String flag;

    /** 是否上架（0=未上架，1=已上架） */
    private Boolean isShelves;

    /** 运营负责人ID */
    private Long operateDirectorId;

    /** 最后操作人ID */
    private Long operateUserId;

    /** 最后操作人姓名 */
    private String updateUserName;

    /** 产品-仓库关联信息（格式：仓库SKU,数量,时间） */
    private String proWhProductInfo;

    /** 产品累计销售数量 */
    private Integer sellCount;

    /** 创建人ID */
    private Long createUserId;

    /** 记录创建时间 */
    private LocalDateTime createTime;

    /** 记录最后更新时间 */
    private LocalDateTime updateTime;

    /** 关联的仓库SKU子表明细（1:N关系） */
    private List<CompanyGoodsItem> itemList;

    public CompanyGoods() {
        this.isShelves = false;
        this.itemList = new ArrayList<>();
    }

    /**
     * 检查商品是否已上架
     */
    public boolean isOnShelves() {
        return Boolean.TRUE.equals(isShelves);
    }

    /**
     * 检查商品是否处于正常状态（flag = "1"）
     */
    public boolean isActive() {
        return "1".equals(flag);
    }

    /**
     * 获取关联的仓库SKU列表
     */
    public List<String> getWarehouseSkuList() {
        List<String> skuList = new ArrayList<>();
        if (itemList != null) {
            for (CompanyGoodsItem item : itemList) {
                if (item.getWarehouseSku() != null) {
                    skuList.add(item.getWarehouseSku());
                }
            }
        }
        return skuList;
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

    public String getCompanySku() {
        return companySku;
    }

    public void setCompanySku(String companySku) {
        this.companySku = companySku;
    }

    public String getCompanySkuImg() {
        return companySkuImg;
    }

    public void setCompanySkuImg(String companySkuImg) {
        this.companySkuImg = companySkuImg;
    }

    public String getCompanySkuName() {
        return companySkuName;
    }

    public void setCompanySkuName(String companySkuName) {
        this.companySkuName = companySkuName;
    }

    public String getFlag() {
        return flag;
    }

    public void setFlag(String flag) {
        this.flag = flag;
    }

    public Boolean getIsShelves() {
        return isShelves;
    }

    public void setIsShelves(Boolean isShelves) {
        this.isShelves = isShelves;
    }

    public Long getOperateDirectorId() {
        return operateDirectorId;
    }

    public void setOperateDirectorId(Long operateDirectorId) {
        this.operateDirectorId = operateDirectorId;
    }

    public Long getOperateUserId() {
        return operateUserId;
    }

    public void setOperateUserId(Long operateUserId) {
        this.operateUserId = operateUserId;
    }

    public String getUpdateUserName() {
        return updateUserName;
    }

    public void setUpdateUserName(String updateUserName) {
        this.updateUserName = updateUserName;
    }

    public String getProWhProductInfo() {
        return proWhProductInfo;
    }

    public void setProWhProductInfo(String proWhProductInfo) {
        this.proWhProductInfo = proWhProductInfo;
    }

    public Integer getSellCount() {
        return sellCount;
    }

    public void setSellCount(Integer sellCount) {
        this.sellCount = sellCount;
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

    public List<CompanyGoodsItem> getItemList() {
        return itemList;
    }

    public void setItemList(List<CompanyGoodsItem> itemList) {
        this.itemList = itemList;
    }

    @Override
    public String toString() {
        return "CompanyGoods{" +
                "id=" + id +
                ", companySku='" + companySku + '\'' +
                ", companySkuName='" + companySkuName + '\'' +
                ", flag='" + flag + '\'' +
                ", isShelves=" + isShelves +
                ", itemCount=" + (itemList != null ? itemList.size() : 0) +
                '}';
    }
}
