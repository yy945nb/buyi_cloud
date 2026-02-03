package com.buyi.datawarehouse.model.monitoring;

import com.buyi.datawarehouse.enums.BusinessMode;
import com.buyi.datawarehouse.enums.RiskLevel;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 产品断货点监控模型
 * Product Stockout Point Monitoring Model
 * 
 * 用于存储产品在区域仓维度的断货点监控指标
 */
public class ProductStockoutMonitoring implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 主键ID */
    private Long id;
    
    /** 产品ID */
    private Long productId;
    
    /** 产品SKU */
    private String productSku;
    
    /** 产品名称 */
    private String productName;
    
    /** 公司ID */
    private Long companyId;
    
    /** 仓库ID（可选，用于仓库级别监控） */
    private Long warehouseId;
    
    /** 区域仓ID */
    private Long regionalWarehouseId;
    
    /** 区域仓编码 */
    private String regionalWarehouseCode;
    
    /** 业务模式 */
    private BusinessMode businessMode;
    
    /** 快照日期 */
    private LocalDate snapshotDate;
    
    // 库存指标
    /** 海外仓现有库存 */
    private Integer overseasInventory;
    
    /** 在途库存 */
    private Integer inTransitInventory;
    
    /** 国内仓余单数量 */
    private Integer domesticRemainingQty;
    
    /** 国内仓实物库存数量 */
    private Integer domesticActualStockQty;
    
    /** 总库存（海外+在途） */
    private Integer totalInventory;
    
    /** 可用库存 */
    private Integer availableInventory;
    
    // 销量指标
    /** 日均销量 */
    private BigDecimal dailyAvgSales;
    
    /** 7天日均销量 */
    private BigDecimal dailyAvgSales7Days;
    
    /** 30天日均销量 */
    private BigDecimal dailyAvgSales30Days;
    
    /** 区域销量占比 */
    private BigDecimal regionalProportion;
    
    /** 区域日均销量 */
    private BigDecimal regionalDailySales;
    
    // 周期参数
    /** 安全库存天数 */
    private Integer safetyStockDays;
    
    /** 备货周期天数 */
    private Integer stockingCycleDays;
    
    /** 发货天数（海运时间） */
    private Integer shippingDays;
    
    /** 总提前期（备货+发货） */
    private Integer leadTimeDays;
    
    // 断货点指标
    /** 断货点数量 */
    private Integer stockoutPoint;
    
    /** 安全库存数量 */
    private Integer safetyStockQuantity;
    
    /** 可售天数 */
    private BigDecimal availableDays;
    
    /** 断货风险天数 */
    private Integer stockoutRiskDays;
    
    /** 是否有断货风险 */
    private Boolean isStockoutRisk;
    
    /** 风险等级 */
    private RiskLevel riskLevel;
    
    /** 余单数量 */
    private Integer pendingOrderQuantity;
    
    public ProductStockoutMonitoring() {
        this.overseasInventory = 0;
        this.inTransitInventory = 0;
        this.domesticRemainingQty = 0;
        this.domesticActualStockQty = 0;
        this.totalInventory = 0;
        this.availableInventory = 0;
        this.dailyAvgSales = BigDecimal.ZERO;
        this.regionalProportion = BigDecimal.ZERO;
        this.regionalDailySales = BigDecimal.ZERO;
        this.isStockoutRisk = false;
        this.riskLevel = RiskLevel.SAFE;
        this.pendingOrderQuantity = 0;
    }
    
    /**
     * 计算总库存
     */
    public void calculateTotalInventory() {
        this.totalInventory = (this.overseasInventory != null ? this.overseasInventory : 0)
                + (this.inTransitInventory != null ? this.inTransitInventory : 0);
    }
    
    /**
     * 计算区域日均销量
     */
    public void calculateRegionalDailySales() {
        if (this.dailyAvgSales != null && this.regionalProportion != null) {
            this.regionalDailySales = this.dailyAvgSales.multiply(this.regionalProportion);
        }
    }
    
    /**
     * 计算断货点和相关指标
     */
    public void calculateStockoutMetrics() {
        if (this.regionalDailySales == null || this.regionalDailySales.compareTo(BigDecimal.ZERO) <= 0) {
            this.availableDays = BigDecimal.valueOf(999);
            this.stockoutRiskDays = 999;
            this.isStockoutRisk = false;
            this.riskLevel = RiskLevel.SAFE;
            return;
        }
        
        // 计算断货点 = 日均销量 * 提前期
        if (this.leadTimeDays != null) {
            this.stockoutPoint = this.regionalDailySales
                    .multiply(BigDecimal.valueOf(this.leadTimeDays))
                    .intValue();
        }
        
        // 计算安全库存数量
        if (this.safetyStockDays != null) {
            this.safetyStockQuantity = this.regionalDailySales
                    .multiply(BigDecimal.valueOf(this.safetyStockDays))
                    .intValue();
        }
        
        // 计算可售天数
        int inventory = this.availableInventory != null ? this.availableInventory : 0;
        this.availableDays = BigDecimal.valueOf(inventory)
                .divide(this.regionalDailySales, 2, BigDecimal.ROUND_HALF_UP);
        
        // 计算断货风险天数
        int targetDays = (this.leadTimeDays != null ? this.leadTimeDays : 0)
                + (this.safetyStockDays != null ? this.safetyStockDays : 0);
        this.stockoutRiskDays = this.availableDays.intValue() - targetDays;
        
        // 判断是否有断货风险
        this.isStockoutRisk = this.stockoutRiskDays < 0;
        
        // 计算风险等级
        int safetyDays = this.safetyStockDays != null ? this.safetyStockDays : 30;
        this.riskLevel = RiskLevel.calculateRiskLevel(this.availableDays.doubleValue(), safetyDays);
    }
    
    // Getters and Setters
    
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Long getProductId() {
        return productId;
    }
    
    public void setProductId(Long productId) {
        this.productId = productId;
    }
    
    public String getProductSku() {
        return productSku;
    }
    
    public void setProductSku(String productSku) {
        this.productSku = productSku;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public Long getCompanyId() {
        return companyId;
    }
    
    public void setCompanyId(Long companyId) {
        this.companyId = companyId;
    }
    
    public Long getWarehouseId() {
        return warehouseId;
    }
    
    public void setWarehouseId(Long warehouseId) {
        this.warehouseId = warehouseId;
    }
    
    public Long getRegionalWarehouseId() {
        return regionalWarehouseId;
    }
    
    public void setRegionalWarehouseId(Long regionalWarehouseId) {
        this.regionalWarehouseId = regionalWarehouseId;
    }
    
    public String getRegionalWarehouseCode() {
        return regionalWarehouseCode;
    }
    
    public void setRegionalWarehouseCode(String regionalWarehouseCode) {
        this.regionalWarehouseCode = regionalWarehouseCode;
    }
    
    public BusinessMode getBusinessMode() {
        return businessMode;
    }
    
    public void setBusinessMode(BusinessMode businessMode) {
        this.businessMode = businessMode;
    }
    
    public LocalDate getSnapshotDate() {
        return snapshotDate;
    }
    
    public void setSnapshotDate(LocalDate snapshotDate) {
        this.snapshotDate = snapshotDate;
    }
    
    public Integer getOverseasInventory() {
        return overseasInventory;
    }
    
    public void setOverseasInventory(Integer overseasInventory) {
        this.overseasInventory = overseasInventory;
    }
    
    public Integer getInTransitInventory() {
        return inTransitInventory;
    }
    
    public void setInTransitInventory(Integer inTransitInventory) {
        this.inTransitInventory = inTransitInventory;
    }
    
    public Integer getDomesticRemainingQty() {
        return domesticRemainingQty;
    }
    
    public void setDomesticRemainingQty(Integer domesticRemainingQty) {
        this.domesticRemainingQty = domesticRemainingQty;
    }
    
    public Integer getDomesticActualStockQty() {
        return domesticActualStockQty;
    }
    
    public void setDomesticActualStockQty(Integer domesticActualStockQty) {
        this.domesticActualStockQty = domesticActualStockQty;
    }
    
    public Integer getTotalInventory() {
        return totalInventory;
    }
    
    public void setTotalInventory(Integer totalInventory) {
        this.totalInventory = totalInventory;
    }
    
    public Integer getAvailableInventory() {
        return availableInventory;
    }
    
    public void setAvailableInventory(Integer availableInventory) {
        this.availableInventory = availableInventory;
    }
    
    public BigDecimal getDailyAvgSales() {
        return dailyAvgSales;
    }
    
    public void setDailyAvgSales(BigDecimal dailyAvgSales) {
        this.dailyAvgSales = dailyAvgSales;
    }
    
    public BigDecimal getDailyAvgSales7Days() {
        return dailyAvgSales7Days;
    }
    
    public void setDailyAvgSales7Days(BigDecimal dailyAvgSales7Days) {
        this.dailyAvgSales7Days = dailyAvgSales7Days;
    }
    
    public BigDecimal getDailyAvgSales30Days() {
        return dailyAvgSales30Days;
    }
    
    public void setDailyAvgSales30Days(BigDecimal dailyAvgSales30Days) {
        this.dailyAvgSales30Days = dailyAvgSales30Days;
    }
    
    public BigDecimal getRegionalProportion() {
        return regionalProportion;
    }
    
    public void setRegionalProportion(BigDecimal regionalProportion) {
        this.regionalProportion = regionalProportion;
    }
    
    public BigDecimal getRegionalDailySales() {
        return regionalDailySales;
    }
    
    public void setRegionalDailySales(BigDecimal regionalDailySales) {
        this.regionalDailySales = regionalDailySales;
    }
    
    public Integer getSafetyStockDays() {
        return safetyStockDays;
    }
    
    public void setSafetyStockDays(Integer safetyStockDays) {
        this.safetyStockDays = safetyStockDays;
    }
    
    public Integer getStockingCycleDays() {
        return stockingCycleDays;
    }
    
    public void setStockingCycleDays(Integer stockingCycleDays) {
        this.stockingCycleDays = stockingCycleDays;
    }
    
    public Integer getShippingDays() {
        return shippingDays;
    }
    
    public void setShippingDays(Integer shippingDays) {
        this.shippingDays = shippingDays;
    }
    
    public Integer getLeadTimeDays() {
        return leadTimeDays;
    }
    
    public void setLeadTimeDays(Integer leadTimeDays) {
        this.leadTimeDays = leadTimeDays;
    }
    
    public Integer getStockoutPoint() {
        return stockoutPoint;
    }
    
    public void setStockoutPoint(Integer stockoutPoint) {
        this.stockoutPoint = stockoutPoint;
    }
    
    public Integer getSafetyStockQuantity() {
        return safetyStockQuantity;
    }
    
    public void setSafetyStockQuantity(Integer safetyStockQuantity) {
        this.safetyStockQuantity = safetyStockQuantity;
    }
    
    public BigDecimal getAvailableDays() {
        return availableDays;
    }
    
    public void setAvailableDays(BigDecimal availableDays) {
        this.availableDays = availableDays;
    }
    
    public Integer getStockoutRiskDays() {
        return stockoutRiskDays;
    }
    
    public void setStockoutRiskDays(Integer stockoutRiskDays) {
        this.stockoutRiskDays = stockoutRiskDays;
    }
    
    public Boolean getIsStockoutRisk() {
        return isStockoutRisk;
    }
    
    public void setIsStockoutRisk(Boolean isStockoutRisk) {
        this.isStockoutRisk = isStockoutRisk;
    }
    
    public RiskLevel getRiskLevel() {
        return riskLevel;
    }
    
    public void setRiskLevel(RiskLevel riskLevel) {
        this.riskLevel = riskLevel;
    }
    
    public Integer getPendingOrderQuantity() {
        return pendingOrderQuantity;
    }
    
    public void setPendingOrderQuantity(Integer pendingOrderQuantity) {
        this.pendingOrderQuantity = pendingOrderQuantity;
    }
    
    @Override
    public String toString() {
        return "ProductStockoutMonitoring{" +
                "productSku='" + productSku + '\'' +
                ", regionalWarehouseCode='" + regionalWarehouseCode + '\'' +
                ", businessMode=" + businessMode +
                ", snapshotDate=" + snapshotDate +
                ", totalInventory=" + totalInventory +
                ", regionalDailySales=" + regionalDailySales +
                ", availableDays=" + availableDays +
                ", riskLevel=" + riskLevel +
                '}';
    }
}
