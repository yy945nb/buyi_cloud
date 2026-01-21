package com.buyi.ruleengine.processing.util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.UUID;

/**
 * 处理引擎工具类 - 提供表达式中可用的工具函数
 * Processing Engine Utility Class - Provides utility functions available in expressions
 * 
 * 所有方法都是静态的，以便在JEXL命名空间中正常工作
 * All methods are static to work properly in JEXL namespaces
 */
public class ProcessingUtils {
    
    /**
     * 四舍五入到指定小数位数
     * Round to specified decimal places
     * 
     * @param value 数值
     * @param decimalPlaces 小数位数
     * @return 四舍五入后的值
     */
    public static double roundTo(Object value, int decimalPlaces) {
        double doubleValue = toDouble(value);
        BigDecimal bd = BigDecimal.valueOf(doubleValue);
        bd = bd.setScale(decimalPlaces, RoundingMode.HALF_UP);
        return bd.doubleValue();
    }
    
    /**
     * 生成UUID
     * Generate UUID
     * 
     * @return UUID字符串
     */
    public static String uuid() {
        return UUID.randomUUID().toString();
    }
    
    /**
     * 获取当前时间戳（毫秒）
     * Get current timestamp in milliseconds
     * 
     * @return 当前时间戳
     */
    public static long timestamp() {
        return System.currentTimeMillis();
    }
    
    /**
     * 判断字符串是否为空
     * Check if string is empty or null
     * 
     * @param value 字符串
     * @return 是否为空
     */
    public static boolean isEmpty(Object value) {
        if (value == null) {
            return true;
        }
        if (value instanceof String) {
            return ((String) value).trim().isEmpty();
        }
        return false;
    }
    
    /**
     * 判断字符串是否不为空
     * Check if string is not empty
     * 
     * @param value 字符串
     * @return 是否不为空
     */
    public static boolean isNotEmpty(Object value) {
        return !isEmpty(value);
    }
    
    /**
     * 返回两个值中的最大值
     * Return the maximum of two values
     * 
     * @param a 第一个值
     * @param b 第二个值
     * @return 最大值
     */
    public static double max(Object a, Object b) {
        return Math.max(toDouble(a), toDouble(b));
    }
    
    /**
     * 返回两个值中的最小值
     * Return the minimum of two values
     * 
     * @param a 第一个值
     * @param b 第二个值
     * @return 最小值
     */
    public static double min(Object a, Object b) {
        return Math.min(toDouble(a), toDouble(b));
    }
    
    /**
     * 取绝对值
     * Return absolute value
     * 
     * @param value 数值
     * @return 绝对值
     */
    public static double abs(Object value) {
        return Math.abs(toDouble(value));
    }
    
    /**
     * 向上取整
     * Round up to the nearest integer
     * 
     * @param value 数值
     * @return 向上取整后的值
     */
    public static double ceil(Object value) {
        return Math.ceil(toDouble(value));
    }
    
    /**
     * 向下取整
     * Round down to the nearest integer
     * 
     * @param value 数值
     * @return 向下取整后的值
     */
    public static double floor(Object value) {
        return Math.floor(toDouble(value));
    }
    
    /**
     * 字符串连接
     * Concatenate strings
     * 
     * @param values 要连接的值
     * @return 连接后的字符串
     */
    public static String concat(Object... values) {
        StringBuilder sb = new StringBuilder();
        for (Object value : values) {
            sb.append(value != null ? value.toString() : "");
        }
        return sb.toString();
    }
    
    /**
     * 字符串子串
     * Get substring
     * 
     * @param str 字符串
     * @param start 开始位置
     * @param end 结束位置
     * @return 子串
     */
    public static String substring(String str, int start, int end) {
        if (str == null) {
            return "";
        }
        int length = str.length();
        if (start < 0) {
            start = 0;
        }
        if (end > length) {
            end = length;
        }
        if (start > end) {
            return "";
        }
        return str.substring(start, end);
    }
    
    /**
     * 转换为大写
     * Convert to uppercase
     * 
     * @param str 字符串
     * @return 大写字符串
     */
    public static String toUpperCase(String str) {
        return str != null ? str.toUpperCase() : "";
    }
    
    /**
     * 转换为小写
     * Convert to lowercase
     * 
     * @param str 字符串
     * @return 小写字符串
     */
    public static String toLowerCase(String str) {
        return str != null ? str.toLowerCase() : "";
    }
    
    /**
     * 去除首尾空格
     * Trim whitespace
     * 
     * @param str 字符串
     * @return 去除首尾空格后的字符串
     */
    public static String trim(String str) {
        return str != null ? str.trim() : "";
    }
    
    /**
     * 将对象转换为double
     * Convert object to double
     */
    private static double toDouble(Object value) {
        if (value == null) {
            return 0.0;
        }
        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }
        try {
            return Double.parseDouble(value.toString());
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }
    
    /**
     * 条件表达式
     * Conditional expression (if-then-else)
     * 
     * @param condition 条件
     * @param trueValue 条件为真时的值
     * @param falseValue 条件为假时的值
     * @return 根据条件返回的值
     */
    public static Object iif(boolean condition, Object trueValue, Object falseValue) {
        return condition ? trueValue : falseValue;
    }
    
    /**
     * 检查值是否为null
     * Check if value is null
     * 
     * @param value 值
     * @return 是否为null
     */
    public static boolean isNull(Object value) {
        return value == null;
    }
    
    /**
     * 检查值是否不为null
     * Check if value is not null
     * 
     * @param value 值
     * @return 是否不为null
     */
    public static boolean isNotNull(Object value) {
        return value != null;
    }
    
    /**
     * 返回默认值（如果原值为null）
     * Return default value if original value is null
     * 
     * @param value 原值
     * @param defaultValue 默认值
     * @return 原值或默认值
     */
    public static Object nvl(Object value, Object defaultValue) {
        return value != null ? value : defaultValue;
    }
}
