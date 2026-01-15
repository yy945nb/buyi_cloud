# buyi_cloud

## Business Analysis Module

This repository now includes a comprehensive Business Analysis Module (BMS) for data-driven decision making.

### Features
- **Multi-dimensional Analysis**: Track business metrics across company, shop, warehouse, and product levels
- **Daily & Monthly Reports**: Automated aggregation of business data
- **KPI Tracking**: Monitor key performance indicators with target vs actual comparisons
- **Trend Analysis**: Advanced analytics with forecasting capabilities
- **Alert System**: Proactive monitoring with multi-level severity alerts

### Documentation
- [Business Analysis Module Documentation](BUSINESS_ANALYSIS_MODULE.md) - Comprehensive guide with use cases and examples
- [Module Structure](MODULE_STRUCTURE.md) - Visual representation of table relationships and data flow

### Quick Start
The module consists of 6 core tables:
1. `bms_business_analysis` - Main analysis table
2. `bms_business_analysis_daily` - Daily aggregated reports
3. `bms_business_analysis_monthly` - Monthly aggregated reports
4. `bms_business_kpi` - KPI tracking and monitoring
5. `bms_business_trend` - Trend analysis with forecasting
6. `bms_business_alert` - Business alert management

All tables are defined in `buyi_platform_dev.sql` and follow consistent patterns with proper indexing, constraints, and audit trails.