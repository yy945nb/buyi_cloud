package com.buyi.datawarehouse.model.monitoring;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * 国内仓库存聚合模型
 * Domestic Inventory Aggregation Model
 * 
 * 用于聚合国内仓库存数据（来自amf_jh_company_stock）
 * 国内仓库存在两种业务模式（JH_LX和FBA）下共享使用
 */
public class DomesticInventoryAgg implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 产品SKU */
    private String productSku;
    
    /** 本地SKU（国内仓SKU） */
    private String localSku;
    
    /** 公司ID */
    private Long companyId;
    
    /** 余单数量（remaining_num） */
    private Integer remainingQty;
    
    /** 实物库存数量（stock_num） */
    private Integer actualStockQty;
    
    /** 数据同步日期 */
    private LocalDate syncDate;
    
    /** 监控日期（用于查询 <= monitor_date 的最近数据） */
    private LocalDate monitorDate;
    
    public DomesticInventoryAgg() {
        this.remainingQty = 0;
        this.actualStockQty = 0;
    }
    
    // Getters and Setters
    
    public String getProductSku() {
        return productSku;
    }
    
    public void setProductSku(String productSku) {
        this.productSku = productSku;
    }
    
    public String getLocalSku() {
        return localSku;
    }
    
    public void setLocalSku(String localSku) {
        this.localSku = localSku;
    }
    
    public Long getCompanyId() {
        return companyId;
    }
    
    public void setCompanyId(Long companyId) {
        this.companyId = companyId;
    }
    
    public Integer getRemainingQty() {
        return remainingQty;
    }
    
    public void setRemainingQty(Integer remainingQty) {
        this.remainingQty = remainingQty;
    }
    
    public Integer getActualStockQty() {
        return actualStockQty;
    }
    
    public void setActualStockQty(Integer actualStockQty) {
        this.actualStockQty = actualStockQty;
    }
    
    public LocalDate getSyncDate() {
        return syncDate;
    }
    
    public void setSyncDate(LocalDate syncDate) {
        this.syncDate = syncDate;
    }
    
    public LocalDate getMonitorDate() {
        return monitorDate;
    }
    
    public void setMonitorDate(LocalDate monitorDate) {
        this.monitorDate = monitorDate;
    }
    
    @Override
    public String toString() {
        return "DomesticInventoryAgg{" +
                "productSku='" + productSku + '\'' +
                ", localSku='" + localSku + '\'' +
                ", companyId=" + companyId +
                ", remainingQty=" + remainingQty +
                ", actualStockQty=" + actualStockQty +
                ", syncDate=" + syncDate +
                ", monitorDate=" + monitorDate +
                '}';
    }
}
