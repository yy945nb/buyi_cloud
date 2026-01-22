package com.buyi.datawarehouse.model.dimension;

import java.io.Serializable;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.WeekFields;
import java.util.Locale;

/**
 * 时间维度模型
 * Time Dimension Model for Data Warehouse
 */
public class DimDate implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /** 日期键 YYYYMMDD */
    private Integer dateKey;
    
    /** 完整日期 */
    private LocalDate fullDate;
    
    /** 年份 */
    private Integer year;
    
    /** 季度 1-4 */
    private Integer quarter;
    
    /** 月份 1-12 */
    private Integer month;
    
    /** 周数 1-53 */
    private Integer week;
    
    /** 月中第几天 */
    private Integer dayOfMonth;
    
    /** 周中第几天 1-7 */
    private Integer dayOfWeek;
    
    /** 年中第几天 */
    private Integer dayOfYear;
    
    /** 是否周末 */
    private Boolean isWeekend;
    
    /** 是否节假日 */
    private Boolean isHoliday;
    
    /** 年月 YYYY-MM */
    private String yearMonth;
    
    /** 年季度 YYYY-Q1 */
    private String yearQuarter;
    
    public DimDate() {
    }
    
    /**
     * 从LocalDate构建时间维度
     * @param date 日期
     * @return 时间维度对象
     */
    public static DimDate fromDate(LocalDate date) {
        DimDate dimDate = new DimDate();
        dimDate.fullDate = date;
        dimDate.dateKey = Integer.parseInt(date.format(DateTimeFormatter.BASIC_ISO_DATE));
        dimDate.year = date.getYear();
        dimDate.month = date.getMonthValue();
        dimDate.quarter = (date.getMonthValue() - 1) / 3 + 1;
        dimDate.week = date.get(WeekFields.of(Locale.getDefault()).weekOfYear());
        dimDate.dayOfMonth = date.getDayOfMonth();
        dimDate.dayOfWeek = date.getDayOfWeek().getValue();
        dimDate.dayOfYear = date.getDayOfYear();
        dimDate.isWeekend = date.getDayOfWeek() == DayOfWeek.SATURDAY 
                        || date.getDayOfWeek() == DayOfWeek.SUNDAY;
        dimDate.isHoliday = false; // 默认非节假日，可通过外部配置
        dimDate.yearMonth = date.format(DateTimeFormatter.ofPattern("yyyy-MM"));
        dimDate.yearQuarter = date.getYear() + "-Q" + dimDate.quarter;
        return dimDate;
    }
    
    /**
     * 生成日期范围内的时间维度
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 时间维度数组
     */
    public static DimDate[] generateDateRange(LocalDate startDate, LocalDate endDate) {
        long days = endDate.toEpochDay() - startDate.toEpochDay() + 1;
        DimDate[] dates = new DimDate[(int) days];
        LocalDate current = startDate;
        for (int i = 0; i < days; i++) {
            dates[i] = fromDate(current);
            current = current.plusDays(1);
        }
        return dates;
    }

    // Getters and Setters
    
    public Integer getDateKey() {
        return dateKey;
    }

    public void setDateKey(Integer dateKey) {
        this.dateKey = dateKey;
    }

    public LocalDate getFullDate() {
        return fullDate;
    }

    public void setFullDate(LocalDate fullDate) {
        this.fullDate = fullDate;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Integer getQuarter() {
        return quarter;
    }

    public void setQuarter(Integer quarter) {
        this.quarter = quarter;
    }

    public Integer getMonth() {
        return month;
    }

    public void setMonth(Integer month) {
        this.month = month;
    }

    public Integer getWeek() {
        return week;
    }

    public void setWeek(Integer week) {
        this.week = week;
    }

    public Integer getDayOfMonth() {
        return dayOfMonth;
    }

    public void setDayOfMonth(Integer dayOfMonth) {
        this.dayOfMonth = dayOfMonth;
    }

    public Integer getDayOfWeek() {
        return dayOfWeek;
    }

    public void setDayOfWeek(Integer dayOfWeek) {
        this.dayOfWeek = dayOfWeek;
    }

    public Integer getDayOfYear() {
        return dayOfYear;
    }

    public void setDayOfYear(Integer dayOfYear) {
        this.dayOfYear = dayOfYear;
    }

    public Boolean getIsWeekend() {
        return isWeekend;
    }

    public void setIsWeekend(Boolean isWeekend) {
        this.isWeekend = isWeekend;
    }

    public Boolean getIsHoliday() {
        return isHoliday;
    }

    public void setIsHoliday(Boolean isHoliday) {
        this.isHoliday = isHoliday;
    }

    public String getYearMonth() {
        return yearMonth;
    }

    public void setYearMonth(String yearMonth) {
        this.yearMonth = yearMonth;
    }

    public String getYearQuarter() {
        return yearQuarter;
    }

    public void setYearQuarter(String yearQuarter) {
        this.yearQuarter = yearQuarter;
    }
    
    @Override
    public String toString() {
        return "DimDate{" +
                "dateKey=" + dateKey +
                ", fullDate=" + fullDate +
                ", year=" + year +
                ", quarter=" + quarter +
                ", month=" + month +
                ", week=" + week +
                ", dayOfWeek=" + dayOfWeek +
                ", isWeekend=" + isWeekend +
                '}';
    }
}
