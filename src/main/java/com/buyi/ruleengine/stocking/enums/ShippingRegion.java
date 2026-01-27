package com.buyi.ruleengine.stocking.enums;

/**
 * 发货区域枚举
 * Shipping Region Enumeration
 * <p>
 * 定义美国不同区域的海运时间
 */
public enum ShippingRegion {

    /**
     * 美西 - US West Coast (Los Angeles, Seattle)
     */
    US_WEST("US_WEST", "美西", 30, 25),

    /**
     * 美东 - US East Coast (New York, Miami)
     */
    US_EAST("US_EAST", "美东", 50, 35),

    /**
     * 美中 - US Central (Chicago, Dallas)
     */
    US_CENTRAL("US_CENTRAL", "美中", 45, 30),

    /**
     * 美南 - US South (Houston, Atlanta)
     */
    US_SOUTH("US_SOUTH", "美南", 55, 35);

    private final String code;
    private final String description;
    /**
     * 海运时间（天）
     */
    private final int shippingDays;
    /**
     * 断货监控提前天数
     */
    private final int stockoutMonitorDays;

    ShippingRegion(String code, String description, int shippingDays, int stockoutMonitorDays) {
        this.code = code;
        this.description = description;
        this.shippingDays = shippingDays;
        this.stockoutMonitorDays = stockoutMonitorDays;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }

    public int getShippingDays() {
        return shippingDays;
    }

    public int getStockoutMonitorDays() {
        return stockoutMonitorDays;
    }

    public static ShippingRegion fromCode(String code) {
        for (ShippingRegion region : values()) {
            if (region.code.equals(code)) {
                return region;
            }
        }
        throw new IllegalArgumentException("Unknown shipping region: " + code);
    }
}
