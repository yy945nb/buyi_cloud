# Business Analysis Module - Table Relationships

```
┌─────────────────────────────────────────────────────────────────┐
│               BUSINESS ANALYSIS MODULE (BMS)                     │
│                      6 Core Tables                               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    DATA COLLECTION LAYER                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────┐      │
│  │  bms_business_analysis (Main Analysis Table)          │      │
│  │  ------------------------------------------------      │      │
│  │  • Granular business metrics                          │      │
│  │  • Multi-dimensional: company/shop/warehouse/SKU      │      │
│  │  • Business types: Sales/Purchase/Inventory/Finance   │      │
│  │  • Tracks: orders, sales, refunds, profits, stock     │      │
│  └───────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   AGGREGATION LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────┐  ┌──────────────────────────────┐  │
│  │ bms_business_analysis_ │  │ bms_business_analysis_       │  │
│  │ daily                  │  │ monthly                      │  │
│  │ ---------------------- │  │ ---------------------------- │  │
│  │ • Daily summaries      │  │ • Monthly summaries          │  │
│  │ • Multiple dimensions  │  │ • Growth rates (MoM/YoY)     │  │
│  │ • GMV tracking         │  │ • Retention rates            │  │
│  │ • Inventory alerts     │  │ • Peak sales identification  │  │
│  │ • Customer metrics     │  │ • Category performance       │  │
│  └────────────────────────┘  └──────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   INTELLIGENCE LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │ bms_business_kpi │  │ bms_business_    │  │ bms_business_│  │
│  │                  │  │ trend            │  │ alert        │  │
│  │ ---------------- │  │ ---------------- │  │ ------------ │  │
│  │ • KPI tracking   │  │ • Trend analysis │  │ • Alert mgmt │  │
│  │ • Target vs      │  │ • DoD/WoW/MoM/   │  │ • Multi-level│  │
│  │   actual         │  │   YoY changes    │  │   severity   │  │
│  │ • Completion     │  │ • Moving averages│  │ • Threshold  │  │
│  │   rates          │  │ • Forecasting    │  │   monitoring │  │
│  │ • Status         │  │ • Confidence     │  │ • Handler    │  │
│  │   monitoring     │  │   levels         │  │   tracking   │  │
│  └──────────────────┘  └──────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   INTEGRATION POINTS                             │
├─────────────────────────────────────────────────────────────────┤
│  External Systems:                                               │
│  • OMS (Order Management System) ──► Orders, Sales Data         │
│  • WMS (Warehouse Management)    ──► Inventory Data             │
│  • UMS (User Management)         ──► Customer Data              │
│  • PMS (Product Management)      ──► Product/SKU Info           │
│  • COS (Shop Management)         ──► Multi-shop Operations      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   KEY FEATURES                                   │
├─────────────────────────────────────────────────────────────────┤
│  ✓ Multi-dimensional analysis (company/shop/warehouse/product)  │
│  ✓ Time-series data with trend analysis                         │
│  ✓ KPI tracking and monitoring                                  │
│  ✓ Automated alert system                                       │
│  ✓ Forecasting capabilities                                     │
│  ✓ Soft delete support                                          │
│  ✓ Comprehensive indexing strategy                              │
│  ✓ Audit trail (create/update tracking)                         │
│  ✓ UTF-8MB4 full Unicode support                                │
│  ✓ InnoDB engine with ACID compliance                           │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   COMMON FIELDS                                  │
├─────────────────────────────────────────────────────────────────┤
│  All tables include:                                             │
│  • id (bigint, AUTO_INCREMENT, PRIMARY KEY)                     │
│  • company_id (bigint, NOT NULL)                                │
│  • is_delete (tinyint, DEFAULT 0)                               │
│  • create_time (datetime, DEFAULT CURRENT_TIMESTAMP)            │
│  • update_time (datetime, ON UPDATE CURRENT_TIMESTAMP)          │
│                                                                  │
│  Indexed fields:                                                 │
│  • company_id + date columns (composite indexes)                │
│  • Type/dimension fields (for filtering)                        │
│  • Status fields (for monitoring)                               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   USE CASE FLOW                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Daily ETL Process                                           │
│     └─► Collect raw data from source systems                    │
│         └─► Populate bms_business_analysis                      │
│             └─► Aggregate to bms_business_analysis_daily        │
│                                                                  │
│  2. Monthly Aggregation                                         │
│     └─► Process month-end data                                  │
│         └─► Calculate growth rates                              │
│             └─► Populate bms_business_analysis_monthly          │
│                                                                  │
│  3. KPI Evaluation                                              │
│     └─► Compare actual vs target                                │
│         └─► Update bms_business_kpi                             │
│             └─► Trigger alerts if threshold breached            │
│                                                                  │
│  4. Trend Analysis                                              │
│     └─► Calculate moving averages                               │
│         └─► Generate forecasts                                  │
│             └─► Update bms_business_trend                       │
│                                                                  │
│  5. Alert Management                                            │
│     └─► Monitor critical metrics                                │
│         └─► Create alerts in bms_business_alert                 │
│             └─► Notify responsible personnel                    │
│                 └─► Track resolution                            │
└─────────────────────────────────────────────────────────────────┘
```

## Data Volume Estimates

| Table                            | Expected Daily Rows | Retention Period |
|----------------------------------|---------------------|------------------|
| bms_business_analysis            | 10,000 - 100,000   | 2 years          |
| bms_business_analysis_daily      | 100 - 1,000        | 5 years          |
| bms_business_analysis_monthly    | 10 - 100           | Permanent        |
| bms_business_kpi                 | 50 - 500           | 3 years          |
| bms_business_trend               | 100 - 1,000        | 2 years          |
| bms_business_alert               | 10 - 100           | 1 year           |

## Performance Optimization Tips

1. **Partitioning**: Consider date-based partitioning for large tables
2. **Archiving**: Move old data to archive tables after retention period
3. **Indexing**: Monitor and optimize indexes based on query patterns
4. **Caching**: Cache frequently accessed aggregations
5. **Batch Processing**: Run heavy analytics during off-peak hours
