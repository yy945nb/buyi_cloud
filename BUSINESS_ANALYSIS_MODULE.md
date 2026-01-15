# Business Analysis Module (业务分析模块)

## Overview (概述)

The Business Analysis Module is a comprehensive data analysis system designed for the Buyi Cloud platform. It provides in-depth insights into sales, inventory, customer behavior, and operational performance through various analytical dimensions.

业务分析模块是为不一云平台设计的综合数据分析系统。它通过各种分析维度提供销售、库存、客户行为和运营绩效的深入洞察。

## Module Components (模块组件)

### 1. bms_business_analysis (业务分析主表)

Main business analysis table that captures detailed business metrics across multiple dimensions.

**Key Features:**
- Multi-dimensional analysis (company, shop, warehouse, SKU levels)
- Supports 4 business types: Sales(1), Purchase(2), Inventory(3), Finance(4)
- Comprehensive metrics: orders, sales, refunds, profits, stock, customer data
- Performance indicators: conversion rate, repurchase rate, profit margin, turnover days

**Use Cases:**
- Track daily business performance by SKU
- Compare sales performance across different shops
- Monitor inventory turnover by warehouse
- Analyze profitability at various granularity levels

### 2. bms_business_analysis_daily (业务分析日报表)

Daily aggregated business analysis report providing a snapshot of overall business health.

**Key Features:**
- Daily business summary statistics
- Multi-dimensional analysis support (overall, shop, warehouse, product)
- Customer engagement metrics (new, active, repurchase customers)
- GMV (Gross Merchandise Volume) tracking
- Inventory health indicators (low stock alerts, out of stock count)

**Use Cases:**
- Generate daily business reports for management
- Monitor daily sales trends and compare with historical data
- Track customer acquisition and retention daily
- Alert on inventory issues requiring immediate attention

### 3. bms_business_analysis_monthly (业务分析月报表)

Monthly business analysis with growth comparisons and trend identification.

**Key Features:**
- Monthly aggregated business metrics
- Month-over-month (MoM) and Year-over-year (YoY) growth rates
- Customer retention analysis
- Best/worst performing category identification
- Peak sales day identification

**Use Cases:**
- Generate monthly executive reports
- Analyze seasonal trends and patterns
- Compare performance across different months
- Identify growth opportunities and areas of concern

### 4. bms_business_kpi (业务KPI指标表)

KPI tracking and monitoring system for business objectives.

**Key Features:**
- Flexible KPI type classification (sales, profit, customer, inventory, operation)
- Target vs actual comparison with completion rates
- Status monitoring (normal, warning, critical)
- Trend identification (up, down, stable)
- Department and responsible person assignment

**Use Cases:**
- Set and track business targets
- Monitor team performance against KPIs
- Identify underperforming areas requiring intervention
- Generate KPI dashboards for management

### 5. bms_business_trend (业务趋势分析表)

Advanced trend analysis with forecasting capabilities.

**Key Features:**
- Multiple time-based comparisons (DoD, WoW, MoM, YoY)
- Moving averages (7-day, 30-day) for smoothing trends
- Forecast values with confidence levels
- Trend direction classification
- Multi-dimensional trend tracking

**Use Cases:**
- Predict future business performance
- Identify emerging trends early
- Support data-driven decision making
- Generate trend reports and visualizations

### 6. bms_business_alert (业务预警表)

Business alert and monitoring system for proactive issue detection.

**Key Features:**
- Multi-type alerts (stock, sales, profit, quality)
- 3-level severity system (info, warning, critical)
- Alert lifecycle tracking (unhandled, processing, handled, ignored)
- Threshold-based triggering
- Handler assignment and result tracking

**Use Cases:**
- Monitor critical business metrics in real-time
- Alert relevant personnel when thresholds are breached
- Track alert resolution and response times
- Build alerting dashboards and notification systems

## Database Schema Features (数据库架构特性)

### Indexing Strategy
All tables include optimized indexes for:
- Company and date range queries
- Multi-dimensional filtering
- Status and type-based searches

### Data Integrity
- Unique constraints to prevent duplicate data
- Soft delete support (`is_delete` flag)
- Audit trails with create/update timestamps and user tracking

### Scalability
- `bigint` primary keys for large-scale data
- Decimal precision for financial calculations
- Flexible dimension support for future expansion

## Integration Points (集成点)

The Business Analysis Module integrates with existing Buyi Cloud modules:

- **Order Management System (OMS)**: Order and sales data
- **Warehouse Management System (WMS)**: Inventory data
- **Customer Management System (UMS)**: Customer behavior data
- **Product Management System (PMS)**: Product and SKU information
- **Shop Management (COS)**: Multi-shop operations data

## Usage Examples (使用示例)

### Example 1: Daily Sales Analysis
```sql
-- Get today's sales summary for a specific company
SELECT 
    analysis_date,
    total_order_count,
    total_sales_amount,
    total_profit_amount,
    conversion_rate
FROM bms_business_analysis_daily
WHERE company_id = 1
  AND analysis_date = CURDATE()
  AND analysis_dimension = 'overall'
  AND is_delete = 0;
```

### Example 2: KPI Performance Monitoring
```sql
-- Check KPI completion status for current month
SELECT 
    kpi_name,
    kpi_value,
    kpi_target,
    completion_rate,
    status,
    trend
FROM bms_business_kpi
WHERE company_id = 1
  AND kpi_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
  AND kpi_type = 'sales'
  AND is_delete = 0
ORDER BY completion_rate DESC;
```

### Example 3: Trend Analysis with Forecast
```sql
-- Get sales trend with forecast for next 7 days
SELECT 
    trend_date,
    metric_value,
    moving_average_7d,
    forecast_value,
    forecast_confidence,
    trend_direction
FROM bms_business_trend
WHERE company_id = 1
  AND trend_type = 'sales'
  AND metric_name = 'daily_sales_amount'
  AND trend_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
  AND is_delete = 0
ORDER BY trend_date DESC;
```

### Example 4: Critical Alerts Monitoring
```sql
-- Get all unhandled critical alerts
SELECT 
    alert_type,
    alert_level,
    alert_title,
    alert_content,
    metric_value,
    threshold_value,
    alert_date
FROM bms_business_alert
WHERE company_id = 1
  AND alert_status = 1  -- unhandled
  AND alert_level = 3   -- critical
  AND is_delete = 0
ORDER BY alert_date DESC;
```

## Performance Considerations (性能考虑)

1. **Partitioning**: Consider date-based partitioning for large datasets
2. **Archiving**: Implement data archiving strategy for historical data
3. **Caching**: Use application-level caching for frequently accessed reports
4. **Batch Processing**: Run heavy analytical queries during off-peak hours
5. **Index Maintenance**: Regularly analyze and optimize indexes

## Best Practices (最佳实践)

1. **Data Freshness**: Update analysis tables through scheduled batch jobs
2. **Dimension Consistency**: Maintain consistent dimension_id usage across tables
3. **Alert Tuning**: Regularly review and adjust alert thresholds
4. **KPI Review**: Quarterly review of KPI targets and metrics
5. **Audit Trail**: Never hard delete data, always use soft delete

## Future Enhancements (未来增强)

Potential areas for module expansion:
- Real-time analytics integration
- Machine learning-based forecasting
- Advanced anomaly detection
- Automated report generation
- Mobile dashboard support
- API endpoints for third-party integrations

## Version History (版本历史)

- **v1.0** (2026-01-15): Initial release with 6 core tables
  - Business analysis main table
  - Daily and monthly analysis reports
  - KPI tracking system
  - Trend analysis with forecasting
  - Alert monitoring system

## Support (支持)

For questions or issues regarding the Business Analysis Module, please contact the Buyi Cloud development team.

---

**Module Prefix**: `bms_` (Business Management System)  
**Database**: buyi_platform_dev  
**Charset**: utf8mb4  
**Collation**: utf8mb4_0900_ai_ci  
**Engine**: InnoDB
