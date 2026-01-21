package com.buyi.sku.tag.enums;

/**
 * 数据源类型枚举
 * Data Source Type Enum
 */
public enum DataSourceType {
    
    SQL("SQL", "SQL查询"),
    API("API", "外部API"),
    LOCAL("LOCAL", "本地数据");
    
    private final String code;
    private final String desc;
    
    DataSourceType(String code, String desc) {
        this.code = code;
        this.desc = desc;
    }
    
    public String getCode() {
        return code;
    }
    
    public String getDesc() {
        return desc;
    }
    
    public static DataSourceType fromCode(String code) {
        for (DataSourceType type : values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        return null;
    }
}
