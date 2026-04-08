package com.buyi.datawarehouse.model.catalog;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 销售商品档案主表模型
 * Sell Goods Profile Main Model
 *
 * 对应数据库表：amf_jh_sell_goods
 * 销售商品主表，以销售SKU（sell_sku）为唯一标识，
 * 关联店铺、公司内部SKU，并通过 SellGoodsItem 子表关联仓库SKU明细。
 */
public class SellGoods implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 商品ID（主键） */
    private Long id;

    /** 用户标识 */
    private String userKey;

    /** 销售SKU（唯一） */
    private String sellSku;

    /** 销售SKU名称 */
    private String sellSkuName;

    /** 销售SKU图片URL（可为空） */
    private String sellSkuImg;

    /** 店铺ID */
    private Integer shopId;

    /** 店铺名称 */
    private String shopName;

    /** 店铺展示名称 */
    private String shopShowName;

    /** 公司内部SKU（关联 CompanyGoods.companySku） */
    private String companySku;

    /** 平台类型（如：Walmart） */
    private String platformType;

    /** 平台名称 */
    private String platformName;

    /** 是否上架（0=未上架，1=已上架） */
    private Integer isShelves;

    /** 亚马逊ASIN码 */
    private String asin;

    /** 是否上传库存（0=否，1=是） */
    private Integer isUploadStock;

    /** 是否可拆分（0=否，1=是） */
    private Integer isSplit;

    /** 最大拆分数量 */
    private Integer maxSplitNum;

    /** 是否按比例上传库存（0=否，1=是） */
    private Integer isScaleUploadStock;

    /** 是否自动计算库存（0=否，1=是） */
    private Integer isAutoCalInventory;

    /** 库存数量 */
    private Integer stockNum;

    /** 可售数量 */
    private Integer sellableQty;

    /** 采购SKU */
    private String purchaseSku;

    /** 备货天数 */
    private Integer stockUpDays;

    /** 平台类目名称 */
    private String platformCategoryName;

    /** 平台类目ID */
    private String platformCategoryId;

    /** 是否有仓库（0=否，1=是） */
    private Integer isHasWarehouse;

    /** 店铺授权状态（0=未授权，1=已授权） */
    private Integer shopAuthStatus;

    /** 店铺状态（0=禁用，1=正常） */
    private Integer shopStatus;

    /** 操作人ID */
    private Integer operateUserId;

    /** 操作人姓名 */
    private String operateUserName;

    /** 操作主管ID */
    private Integer operateDirectorId;

    /** 操作主管姓名 */
    private String operateDirectorName;

    /** 创建人ID */
    private Integer createUserId;

    /** 创建时间 */
    private LocalDateTime createTime;

    /** 更新时间 */
    private LocalDateTime updateTime;

    /** 关联的仓库SKU明细（1:N关系） */
    private List<SellGoodsItem> itemList;

    public SellGoods() {
        this.isShelves = 0;
        this.isUploadStock = 0;
        this.isSplit = 0;
        this.isScaleUploadStock = 0;
        this.itemList = new ArrayList<>();
    }

    /**
     * 检查是否已上架
     */
    public boolean isOnShelves() {
        return Integer.valueOf(1).equals(isShelves);
    }

    /**
     * 检查是否已上传库存
     */
    public boolean isStockUploaded() {
        return Integer.valueOf(1).equals(isUploadStock);
    }

    /**
     * 获取关联的仓库SKU列表
     */
    public List<String> getWarehouseSkuList() {
        List<String> skuList = new ArrayList<>();
        if (itemList != null) {
            for (SellGoodsItem item : itemList) {
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

    public String getSellSku() {
        return sellSku;
    }

    public void setSellSku(String sellSku) {
        this.sellSku = sellSku;
    }

    public String getSellSkuName() {
        return sellSkuName;
    }

    public void setSellSkuName(String sellSkuName) {
        this.sellSkuName = sellSkuName;
    }

    public String getSellSkuImg() {
        return sellSkuImg;
    }

    public void setSellSkuImg(String sellSkuImg) {
        this.sellSkuImg = sellSkuImg;
    }

    public Integer getShopId() {
        return shopId;
    }

    public void setShopId(Integer shopId) {
        this.shopId = shopId;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getShopShowName() {
        return shopShowName;
    }

    public void setShopShowName(String shopShowName) {
        this.shopShowName = shopShowName;
    }

    public String getCompanySku() {
        return companySku;
    }

    public void setCompanySku(String companySku) {
        this.companySku = companySku;
    }

    public String getPlatformType() {
        return platformType;
    }

    public void setPlatformType(String platformType) {
        this.platformType = platformType;
    }

    public String getPlatformName() {
        return platformName;
    }

    public void setPlatformName(String platformName) {
        this.platformName = platformName;
    }

    public Integer getIsShelves() {
        return isShelves;
    }

    public void setIsShelves(Integer isShelves) {
        this.isShelves = isShelves;
    }

    public String getAsin() {
        return asin;
    }

    public void setAsin(String asin) {
        this.asin = asin;
    }

    public Integer getIsUploadStock() {
        return isUploadStock;
    }

    public void setIsUploadStock(Integer isUploadStock) {
        this.isUploadStock = isUploadStock;
    }

    public Integer getIsSplit() {
        return isSplit;
    }

    public void setIsSplit(Integer isSplit) {
        this.isSplit = isSplit;
    }

    public Integer getMaxSplitNum() {
        return maxSplitNum;
    }

    public void setMaxSplitNum(Integer maxSplitNum) {
        this.maxSplitNum = maxSplitNum;
    }

    public Integer getIsScaleUploadStock() {
        return isScaleUploadStock;
    }

    public void setIsScaleUploadStock(Integer isScaleUploadStock) {
        this.isScaleUploadStock = isScaleUploadStock;
    }

    public Integer getIsAutoCalInventory() {
        return isAutoCalInventory;
    }

    public void setIsAutoCalInventory(Integer isAutoCalInventory) {
        this.isAutoCalInventory = isAutoCalInventory;
    }

    public Integer getStockNum() {
        return stockNum;
    }

    public void setStockNum(Integer stockNum) {
        this.stockNum = stockNum;
    }

    public Integer getSellableQty() {
        return sellableQty;
    }

    public void setSellableQty(Integer sellableQty) {
        this.sellableQty = sellableQty;
    }

    public String getPurchaseSku() {
        return purchaseSku;
    }

    public void setPurchaseSku(String purchaseSku) {
        this.purchaseSku = purchaseSku;
    }

    public Integer getStockUpDays() {
        return stockUpDays;
    }

    public void setStockUpDays(Integer stockUpDays) {
        this.stockUpDays = stockUpDays;
    }

    public String getPlatformCategoryName() {
        return platformCategoryName;
    }

    public void setPlatformCategoryName(String platformCategoryName) {
        this.platformCategoryName = platformCategoryName;
    }

    public String getPlatformCategoryId() {
        return platformCategoryId;
    }

    public void setPlatformCategoryId(String platformCategoryId) {
        this.platformCategoryId = platformCategoryId;
    }

    public Integer getIsHasWarehouse() {
        return isHasWarehouse;
    }

    public void setIsHasWarehouse(Integer isHasWarehouse) {
        this.isHasWarehouse = isHasWarehouse;
    }

    public Integer getShopAuthStatus() {
        return shopAuthStatus;
    }

    public void setShopAuthStatus(Integer shopAuthStatus) {
        this.shopAuthStatus = shopAuthStatus;
    }

    public Integer getShopStatus() {
        return shopStatus;
    }

    public void setShopStatus(Integer shopStatus) {
        this.shopStatus = shopStatus;
    }

    public Integer getOperateUserId() {
        return operateUserId;
    }

    public void setOperateUserId(Integer operateUserId) {
        this.operateUserId = operateUserId;
    }

    public String getOperateUserName() {
        return operateUserName;
    }

    public void setOperateUserName(String operateUserName) {
        this.operateUserName = operateUserName;
    }

    public Integer getOperateDirectorId() {
        return operateDirectorId;
    }

    public void setOperateDirectorId(Integer operateDirectorId) {
        this.operateDirectorId = operateDirectorId;
    }

    public String getOperateDirectorName() {
        return operateDirectorName;
    }

    public void setOperateDirectorName(String operateDirectorName) {
        this.operateDirectorName = operateDirectorName;
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

    public List<SellGoodsItem> getItemList() {
        return itemList;
    }

    public void setItemList(List<SellGoodsItem> itemList) {
        this.itemList = itemList;
    }

    @Override
    public String toString() {
        return "SellGoods{" +
                "id=" + id +
                ", sellSku='" + sellSku + '\'' +
                ", sellSkuName='" + sellSkuName + '\'' +
                ", shopId=" + shopId +
                ", companySku='" + companySku + '\'' +
                ", platformName='" + platformName + '\'' +
                ", isShelves=" + isShelves +
                ", itemCount=" + (itemList != null ? itemList.size() : 0) +
                '}';
    }
}
