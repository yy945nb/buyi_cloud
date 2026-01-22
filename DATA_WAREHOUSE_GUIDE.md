# 数据仓库私有化部署方案

## 目录
1. [方案概述](#方案概述)
2. [架构设计](#架构设计)
3. [数据模型设计](#数据模型设计)
4. [ETL流程](#etl流程)
5. [OLAP分析服务](#olap分析服务)
6. [部署指南](#部署指南)
7. [使用示例](#使用示例)

## 方案概述

### 背景
Buyi Cloud跨境电商平台积累了大量的业务数据，包括订单、库存、商品、店铺等多维度数据。传统的MySQL OLTP数据库在处理复杂分析查询时存在性能瓶颈。本方案设计一套数据仓库解决方案，将业务数据进行聚合和建模，支持高效的决策分析和业务联机分析处理（OLAP）。

### 目标
- **数据整合**：将分散在多个业务表中的数据进行整合和清洗
- **维度建模**：采用星型模式（Star Schema）构建数据仓库
- **分析能力**：提供多维度的OLAP分析能力
- **私有化部署**：支持在企业内部环境部署，数据安全可控

### 核心功能
1. ✅ 维度表管理（时间、商品、店铺、仓库、地区）
2. ✅ 事实表设计（销售事实、库存事实、采购事实）
3. ✅ ETL数据处理（抽取、转换、加载）
4. ✅ 聚合表支持（日/周/月汇总）
5. ✅ OLAP多维分析（切片、切块、钻取、旋转）
6. ✅ 定时同步调度

## 架构设计

### 整体架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           数据仓库私有化部署架构                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐     │
│  │   数据源层       │    │   ETL层         │    │   数据仓库层     │     │
│  │  (Source Layer) │ => │  (ETL Layer)    │ => │  (DW Layer)     │     │
│  │                 │    │                 │    │                 │     │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │     │
│  │ │ MySQL OLTP  │ │    │ │   Extract   │ │    │ │  ODS层      │ │     │
│  │ │  业务数据库  │ │    │ │   数据抽取   │ │    │ │ 操作数据存储 │ │     │
│  │ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │     │
│  │                 │    │       ↓         │    │       ↓         │     │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │     │
│  │ │ 订单系统    │ │    │ │  Transform  │ │    │ │  DWD层      │ │     │
│  │ │ 库存系统    │ │    │ │   数据转换   │ │    │ │ 明细数据层  │ │     │
│  │ │ 商品系统    │ │    │ └─────────────┘ │    │ └─────────────┘ │     │
│  │ └─────────────┘ │    │       ↓         │    │       ↓         │     │
│  │                 │    │ ┌─────────────┐ │    │ ┌─────────────┐ │     │
│  │                 │    │ │    Load     │ │    │ │  DWS层      │ │     │
│  │                 │    │ │   数据加载   │ │    │ │ 汇总数据层  │ │     │
│  │                 │    │ └─────────────┘ │    │ └─────────────┘ │     │
│  │                 │    │                 │    │       ↓         │     │
│  │                 │    │                 │    │ ┌─────────────┐ │     │
│  │                 │    │                 │    │ │  ADS层      │ │     │
│  │                 │    │                 │    │ │ 应用数据层  │ │     │
│  │                 │    │                 │    │ └─────────────┘ │     │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘     │
│                                                        ↓               │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                         OLAP分析层                               │   │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐    │   │
│  │  │  切片     │  │  切块     │  │  钻取     │  │  旋转     │    │   │
│  │  │  Slice    │  │  Dice     │  │  Drill    │  │  Pivot    │    │   │
│  │  └───────────┘  └───────────┘  └───────────┘  └───────────┘    │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                        ↓               │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                         应用层                                   │   │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐    │   │
│  │  │ 销售分析  │  │ 库存分析  │  │ 商品分析  │  │ 经营决策  │    │   │
│  │  │ Dashboard │  │ Dashboard │  │ Dashboard │  │ Dashboard │    │   │
│  │  └───────────┘  └───────────┘  └───────────┘  └───────────┘    │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 技术选型

| 组件 | 技术方案 | 说明 |
|------|----------|------|
| 数据源 | MySQL 8.0 | 业务OLTP数据库 |
| 数据仓库 | MySQL 8.0 + ClickHouse (可选) | 私有化部署，支持扩展到列式存储 |
| ETL引擎 | Java + JDBC | 自研ETL框架，轻量级部署 |
| 任务调度 | Java ScheduledExecutor | 支持定时同步任务 |
| OLAP引擎 | 自研OLAP服务 | 支持多维分析 |

## 数据模型设计

### 分层架构

#### ODS层（操作数据存储层）
- 原始数据1:1同步
- 保留历史快照
- 数据质量检查

#### DWD层（明细数据层）
- 数据清洗和标准化
- 维度表关联
- 事实表构建

#### DWS层（汇总数据层）
- 按时间粒度聚合
- 业务指标计算
- 预聚合优化查询

#### ADS层（应用数据层）
- 业务报表数据
- KPI指标数据
- 决策支持数据

### 维度表设计

#### 1. 时间维度表 (dim_date)
```sql
CREATE TABLE dw_dim_date (
    date_key INT PRIMARY KEY COMMENT '日期键 YYYYMMDD',
    full_date DATE NOT NULL COMMENT '完整日期',
    year INT NOT NULL COMMENT '年份',
    quarter INT NOT NULL COMMENT '季度 1-4',
    month INT NOT NULL COMMENT '月份 1-12',
    week INT NOT NULL COMMENT '周数 1-53',
    day_of_month INT NOT NULL COMMENT '月中第几天',
    day_of_week INT NOT NULL COMMENT '周中第几天 1-7',
    day_of_year INT NOT NULL COMMENT '年中第几天',
    is_weekend TINYINT NOT NULL COMMENT '是否周末',
    is_holiday TINYINT DEFAULT 0 COMMENT '是否节假日',
    year_month VARCHAR(7) NOT NULL COMMENT '年月 YYYY-MM',
    year_quarter VARCHAR(7) NOT NULL COMMENT '年季度 YYYY-Q1'
);
```

#### 2. 商品维度表 (dim_product)
```sql
CREATE TABLE dw_dim_product (
    product_key BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '商品代理键',
    product_id BIGINT NOT NULL COMMENT '商品业务ID',
    sku_code VARCHAR(64) NOT NULL COMMENT 'SKU编码',
    spu_code VARCHAR(64) COMMENT 'SPU编码',
    product_name VARCHAR(256) NOT NULL COMMENT '商品名称',
    category_id BIGINT COMMENT '分类ID',
    category_name VARCHAR(128) COMMENT '分类名称',
    brand VARCHAR(128) COMMENT '品牌',
    supplier_id BIGINT COMMENT '供应商ID',
    supplier_name VARCHAR(128) COMMENT '供应商名称',
    cost_price DECIMAL(12,2) COMMENT '成本价',
    list_price DECIMAL(12,2) COMMENT '标价',
    weight DECIMAL(10,3) COMMENT '重量(kg)',
    volume DECIMAL(10,3) COMMENT '体积(m³)',
    status VARCHAR(20) COMMENT '状态',
    effective_date DATE NOT NULL COMMENT '生效日期',
    expiry_date DATE DEFAULT '9999-12-31' COMMENT '失效日期',
    is_current TINYINT DEFAULT 1 COMMENT '是否当前版本'
);
```

#### 3. 店铺维度表 (dim_shop)
```sql
CREATE TABLE dw_dim_shop (
    shop_key BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '店铺代理键',
    shop_id BIGINT NOT NULL COMMENT '店铺业务ID',
    shop_code VARCHAR(64) NOT NULL COMMENT '店铺编码',
    shop_name VARCHAR(128) NOT NULL COMMENT '店铺名称',
    platform VARCHAR(64) COMMENT '平台 Amazon/eBay/etc',
    marketplace VARCHAR(64) COMMENT '站点',
    region VARCHAR(64) COMMENT '地区',
    country VARCHAR(64) COMMENT '国家',
    currency VARCHAR(10) COMMENT '币种',
    timezone VARCHAR(64) COMMENT '时区',
    status VARCHAR(20) COMMENT '状态',
    effective_date DATE NOT NULL COMMENT '生效日期',
    expiry_date DATE DEFAULT '9999-12-31' COMMENT '失效日期',
    is_current TINYINT DEFAULT 1 COMMENT '是否当前版本'
);
```

#### 4. 仓库维度表 (dim_warehouse)
```sql
CREATE TABLE dw_dim_warehouse (
    warehouse_key BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '仓库代理键',
    warehouse_id BIGINT NOT NULL COMMENT '仓库业务ID',
    warehouse_code VARCHAR(64) NOT NULL COMMENT '仓库编码',
    warehouse_name VARCHAR(128) NOT NULL COMMENT '仓库名称',
    warehouse_type VARCHAR(32) COMMENT '仓库类型 FBA/FBM/自营',
    country VARCHAR(64) COMMENT '国家',
    region VARCHAR(64) COMMENT '地区',
    city VARCHAR(64) COMMENT '城市',
    address VARCHAR(256) COMMENT '地址',
    status VARCHAR(20) COMMENT '状态',
    effective_date DATE NOT NULL COMMENT '生效日期',
    expiry_date DATE DEFAULT '9999-12-31' COMMENT '失效日期',
    is_current TINYINT DEFAULT 1 COMMENT '是否当前版本'
);
```

#### 5. 地区维度表 (dim_region)
```sql
CREATE TABLE dw_dim_region (
    region_key BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '地区代理键',
    region_id BIGINT NOT NULL COMMENT '地区业务ID',
    country_code VARCHAR(10) NOT NULL COMMENT '国家编码',
    country_name VARCHAR(64) NOT NULL COMMENT '国家名称',
    state_code VARCHAR(32) COMMENT '州/省编码',
    state_name VARCHAR(64) COMMENT '州/省名称',
    city_name VARCHAR(64) COMMENT '城市名称',
    postal_code VARCHAR(20) COMMENT '邮编',
    continent VARCHAR(32) COMMENT '洲',
    is_current TINYINT DEFAULT 1 COMMENT '是否当前版本'
);
```

### 事实表设计

#### 1. 销售事实表 (fact_sales)
```sql
CREATE TABLE dw_fact_sales (
    sales_key BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '销售键',
    date_key INT NOT NULL COMMENT '日期键',
    product_key BIGINT NOT NULL COMMENT '商品键',
    shop_key BIGINT NOT NULL COMMENT '店铺键',
    warehouse_key BIGINT COMMENT '仓库键',
    region_key BIGINT COMMENT '地区键',
    order_id VARCHAR(64) NOT NULL COMMENT '订单号',
    order_item_id VARCHAR(64) COMMENT '订单项ID',
    quantity INT NOT NULL COMMENT '销售数量',
    unit_price DECIMAL(12,2) NOT NULL COMMENT '单价',
    gross_amount DECIMAL(12,2) NOT NULL COMMENT '销售总额',
    discount_amount DECIMAL(12,2) DEFAULT 0 COMMENT '折扣金额',
    net_amount DECIMAL(12,2) NOT NULL COMMENT '净销售额',
    cost_amount DECIMAL(12,2) COMMENT '成本金额',
    profit_amount DECIMAL(12,2) COMMENT '利润金额',
    shipping_fee DECIMAL(12,2) DEFAULT 0 COMMENT '运费',
    platform_fee DECIMAL(12,2) DEFAULT 0 COMMENT '平台费用',
    order_status VARCHAR(32) COMMENT '订单状态',
    payment_method VARCHAR(32) COMMENT '支付方式',
    create_time DATETIME NOT NULL COMMENT '创建时间',
    update_time DATETIME NOT NULL COMMENT '更新时间',
    INDEX idx_date_key (date_key),
    INDEX idx_product_key (product_key),
    INDEX idx_shop_key (shop_key)
);
```

#### 2. 库存事实表 (fact_inventory)
```sql
CREATE TABLE dw_fact_inventory (
    inventory_key BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '库存键',
    date_key INT NOT NULL COMMENT '日期键（快照日期）',
    product_key BIGINT NOT NULL COMMENT '商品键',
    warehouse_key BIGINT NOT NULL COMMENT '仓库键',
    shop_key BIGINT COMMENT '店铺键',
    on_hand_quantity INT NOT NULL DEFAULT 0 COMMENT '在库数量',
    available_quantity INT NOT NULL DEFAULT 0 COMMENT '可用数量',
    reserved_quantity INT DEFAULT 0 COMMENT '预留数量',
    in_transit_quantity INT DEFAULT 0 COMMENT '在途数量',
    pending_quantity INT DEFAULT 0 COMMENT '待入库数量',
    unit_cost DECIMAL(12,2) COMMENT '单位成本',
    inventory_value DECIMAL(14,2) COMMENT '库存价值',
    days_of_supply INT COMMENT '库存可供天数',
    turnover_days INT COMMENT '周转天数',
    last_inbound_date DATE COMMENT '最后入库日期',
    last_outbound_date DATE COMMENT '最后出库日期',
    snapshot_time DATETIME NOT NULL COMMENT '快照时间',
    INDEX idx_date_key (date_key),
    INDEX idx_product_key (product_key),
    INDEX idx_warehouse_key (warehouse_key)
);
```

#### 3. 采购事实表 (fact_purchase)
```sql
CREATE TABLE dw_fact_purchase (
    purchase_key BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '采购键',
    date_key INT NOT NULL COMMENT '日期键',
    product_key BIGINT NOT NULL COMMENT '商品键',
    warehouse_key BIGINT NOT NULL COMMENT '目标仓库键',
    supplier_key BIGINT COMMENT '供应商键',
    purchase_order_id VARCHAR(64) NOT NULL COMMENT '采购单号',
    quantity INT NOT NULL COMMENT '采购数量',
    unit_cost DECIMAL(12,2) NOT NULL COMMENT '采购单价',
    total_cost DECIMAL(14,2) NOT NULL COMMENT '采购总金额',
    freight_cost DECIMAL(12,2) DEFAULT 0 COMMENT '运费',
    other_cost DECIMAL(12,2) DEFAULT 0 COMMENT '其他费用',
    order_status VARCHAR(32) COMMENT '订单状态',
    expected_date DATE COMMENT '预计到货日期',
    actual_date DATE COMMENT '实际到货日期',
    lead_time_days INT COMMENT '采购周期(天)',
    create_time DATETIME NOT NULL COMMENT '创建时间',
    INDEX idx_date_key (date_key),
    INDEX idx_product_key (product_key)
);
```

### 聚合表设计

#### 1. 日销售汇总表 (agg_sales_daily)
```sql
CREATE TABLE dw_agg_sales_daily (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    date_key INT NOT NULL COMMENT '日期键',
    product_key BIGINT NOT NULL COMMENT '商品键',
    shop_key BIGINT NOT NULL COMMENT '店铺键',
    order_count INT NOT NULL DEFAULT 0 COMMENT '订单数',
    quantity_sold INT NOT NULL DEFAULT 0 COMMENT '销售数量',
    gross_amount DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '销售总额',
    net_amount DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '净销售额',
    cost_amount DECIMAL(14,2) DEFAULT 0 COMMENT '成本总额',
    profit_amount DECIMAL(14,2) DEFAULT 0 COMMENT '利润总额',
    profit_rate DECIMAL(5,2) DEFAULT 0 COMMENT '利润率%',
    avg_order_value DECIMAL(12,2) DEFAULT 0 COMMENT '客单价',
    return_quantity INT DEFAULT 0 COMMENT '退货数量',
    return_amount DECIMAL(14,2) DEFAULT 0 COMMENT '退货金额',
    UNIQUE KEY uk_date_product_shop (date_key, product_key, shop_key),
    INDEX idx_date_key (date_key),
    INDEX idx_product_key (product_key)
);
```

#### 2. 周销售汇总表 (agg_sales_weekly)
```sql
CREATE TABLE dw_agg_sales_weekly (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    year INT NOT NULL COMMENT '年份',
    week INT NOT NULL COMMENT '周数',
    product_key BIGINT NOT NULL COMMENT '商品键',
    shop_key BIGINT NOT NULL COMMENT '店铺键',
    order_count INT NOT NULL DEFAULT 0 COMMENT '订单数',
    quantity_sold INT NOT NULL DEFAULT 0 COMMENT '销售数量',
    gross_amount DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '销售总额',
    net_amount DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '净销售额',
    cost_amount DECIMAL(14,2) DEFAULT 0 COMMENT '成本总额',
    profit_amount DECIMAL(14,2) DEFAULT 0 COMMENT '利润总额',
    profit_rate DECIMAL(5,2) DEFAULT 0 COMMENT '利润率%',
    avg_daily_sales DECIMAL(12,2) DEFAULT 0 COMMENT '日均销售额',
    wow_growth_rate DECIMAL(5,2) COMMENT '周环比增长率%',
    UNIQUE KEY uk_year_week_product_shop (year, week, product_key, shop_key)
);
```

#### 3. 月销售汇总表 (agg_sales_monthly)
```sql
CREATE TABLE dw_agg_sales_monthly (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    year INT NOT NULL COMMENT '年份',
    month INT NOT NULL COMMENT '月份',
    product_key BIGINT NOT NULL COMMENT '商品键',
    shop_key BIGINT NOT NULL COMMENT '店铺键',
    order_count INT NOT NULL DEFAULT 0 COMMENT '订单数',
    quantity_sold INT NOT NULL DEFAULT 0 COMMENT '销售数量',
    gross_amount DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '销售总额',
    net_amount DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '净销售额',
    cost_amount DECIMAL(14,2) DEFAULT 0 COMMENT '成本总额',
    profit_amount DECIMAL(14,2) DEFAULT 0 COMMENT '利润总额',
    profit_rate DECIMAL(5,2) DEFAULT 0 COMMENT '利润率%',
    avg_daily_sales DECIMAL(12,2) DEFAULT 0 COMMENT '日均销售额',
    mom_growth_rate DECIMAL(5,2) COMMENT '月环比增长率%',
    yoy_growth_rate DECIMAL(5,2) COMMENT '同比增长率%',
    UNIQUE KEY uk_year_month_product_shop (year, month, product_key, shop_key)
);
```

## ETL流程

### ETL处理流程

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ETL处理流程                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐             │
│  │  1. 抽取    │    │  2. 转换    │    │  3. 加载    │             │
│  │  Extract    │ => │  Transform  │ => │   Load      │             │
│  └─────────────┘    └─────────────┘    └─────────────┘             │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 抽取阶段:                                                    │   │
│  │ - 全量抽取: 首次加载或重建                                    │   │
│  │ - 增量抽取: 基于时间戳或CDC                                   │   │
│  │ - 变更捕获: 监控binlog或轮询变更                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 转换阶段:                                                    │   │
│  │ - 数据清洗: 去重、空值处理、格式化                           │   │
│  │ - 数据标准化: 编码统一、单位换算                             │   │
│  │ - 维度查找: 关联维度表获取代理键                             │   │
│  │ - 指标计算: 派生字段、汇总计算                               │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 加载阶段:                                                    │   │
│  │ - 维度加载: SCD Type 2 缓慢变化维度                         │   │
│  │ - 事实加载: 批量插入或更新                                   │   │
│  │ - 聚合刷新: 计算日/周/月汇总                                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 使用方法

```java
// 创建ETL服务
DataWarehouseETLService etlService = new DataWarehouseETLService(
    sourceDataSource, targetDataSource);

// 执行全量同步
etlService.fullSync();

// 执行增量同步（指定起始时间）
etlService.incrementalSync(startTime, endTime);

// 刷新聚合表
etlService.refreshAggregations(date);
```

## OLAP分析服务

### OLAP操作类型

1. **切片（Slice）**: 选择一个维度的特定值，降低维度
2. **切块（Dice）**: 选择多个维度的特定范围
3. **钻取（Drill）**: 上钻/下钻，改变分析粒度
4. **旋转（Pivot）**: 变换维度的查看角度

### 分析服务使用

```java
// 创建OLAP分析服务
OlapAnalysisService olapService = new OlapAnalysisService(dataSource);

// 1. 销售趋势分析
SalesTrendResult trend = olapService.analyzeSalesTrend(
    startDate, endDate, TimeGranularity.DAILY, shopId, productId);

// 2. 商品销售排名
List<ProductRankResult> ranking = olapService.getProductSalesRanking(
    startDate, endDate, shopId, 10);

// 3. 库存周转分析
InventoryTurnoverResult turnover = olapService.analyzeInventoryTurnover(
    warehouseId, productId);

// 4. 多维度下钻分析
DrillDownResult result = olapService.drillDown(
    DimensionType.SHOP, DimensionType.PRODUCT, filters);
```

### 典型分析场景

#### 场景1: 销售业绩分析
```java
// 按店铺和商品类别分析月度销售
OlapQuery query = new OlapQuery()
    .selectDimension("shop_name")
    .selectDimension("category_name")
    .selectMeasure("SUM(net_amount)", "total_sales")
    .selectMeasure("SUM(profit_amount)", "total_profit")
    .selectMeasure("COUNT(DISTINCT order_id)", "order_count")
    .filterByDateRange(startDate, endDate)
    .groupBy("shop_key", "category_id")
    .orderBy("total_sales", "DESC");
```

#### 场景2: 库存健康度分析
```java
// 分析各仓库库存周转情况
OlapQuery query = new OlapQuery()
    .selectDimension("warehouse_name")
    .selectMeasure("AVG(turnover_days)", "avg_turnover")
    .selectMeasure("SUM(inventory_value)", "total_value")
    .selectMeasure("COUNT(*)", "sku_count")
    .filterByWarehouseType("FBA")
    .groupBy("warehouse_key")
    .having("avg_turnover > 30");
```

#### 场景3: 利润率分析
```java
// 按商品分析利润率和销量
OlapQuery query = new OlapQuery()
    .selectDimension("product_name")
    .selectMeasure("SUM(quantity_sold)", "total_quantity")
    .selectMeasure("SUM(profit_amount)/SUM(net_amount)*100", "profit_rate")
    .filterByDateRange(startDate, endDate)
    .groupBy("product_key")
    .orderBy("profit_rate", "DESC")
    .limit(20);
```

## 部署指南

### 环境要求

- Java 1.8+
- Maven 3.x
- MySQL 8.0+
- 至少 4GB 内存（生产环境建议 16GB+）
- 至少 50GB 存储空间

### 部署步骤

#### 1. 初始化数据仓库表
```bash
mysql -u username -p -h hostname datawarehouse < datawarehouse_schema.sql
```

#### 2. 配置数据源
```java
// 在配置文件中设置
DataWarehouseConfig config = new DataWarehouseConfig();
config.setSourceJdbcUrl("jdbc:mysql://source-host:3306/buyi_platform");
config.setTargetJdbcUrl("jdbc:mysql://dw-host:3306/buyi_dw");
config.setEtlBatchSize(1000);
config.setSyncIntervalMinutes(30);
```

#### 3. 启动ETL服务
```java
// 编程方式启动
DataWarehouseManager manager = new DataWarehouseManager(config);
manager.startScheduledSync();

// 或使用命令行
mvn exec:java -Dexec.mainClass="com.buyi.datawarehouse.DataWarehouseMain"
```

### 监控和运维

#### 数据同步监控
```java
// 获取同步状态
SyncStatus status = manager.getSyncStatus();
System.out.println("Last sync time: " + status.getLastSyncTime());
System.out.println("Records processed: " + status.getRecordsProcessed());
System.out.println("Sync duration: " + status.getDurationSeconds() + "s");
```

#### 数据质量检查
```java
// 执行数据质量检查
DataQualityReport report = manager.checkDataQuality();
report.getIssues().forEach(issue -> {
    System.out.println(issue.getTable() + ": " + issue.getMessage());
});
```

## 使用示例

### 完整示例代码

```java
public class DataWarehouseDemo {
    public static void main(String[] args) {
        // 1. 配置数据仓库
        DataWarehouseConfig config = DataWarehouseConfig.builder()
            .sourceUrl("jdbc:mysql://localhost:3306/buyi_platform")
            .sourceUser("root")
            .sourcePassword("password")
            .targetUrl("jdbc:mysql://localhost:3306/buyi_dw")
            .targetUser("root")
            .targetPassword("password")
            .build();
        
        // 2. 初始化数据仓库管理器
        DataWarehouseManager manager = new DataWarehouseManager(config);
        
        // 3. 执行初始同步
        manager.initialSync();
        
        // 4. 执行OLAP分析
        OlapAnalysisService olap = manager.getOlapService();
        
        // 销售趋势分析
        LocalDate startDate = LocalDate.of(2024, 1, 1);
        LocalDate endDate = LocalDate.of(2024, 12, 31);
        
        SalesTrendResult trend = olap.analyzeSalesTrend(
            startDate, endDate, TimeGranularity.MONTHLY, null, null);
        
        System.out.println("销售趋势:");
        trend.getDataPoints().forEach(point -> {
            System.out.printf("%s: 销售额=%.2f, 利润=%.2f%n",
                point.getPeriod(), point.getSalesAmount(), point.getProfitAmount());
        });
        
        // 商品排名分析
        List<ProductRankResult> topProducts = olap.getProductSalesRanking(
            startDate, endDate, null, 10);
        
        System.out.println("\n销售排名TOP10:");
        topProducts.forEach(p -> {
            System.out.printf("%d. %s: 销售额=%.2f%n",
                p.getRank(), p.getProductName(), p.getSalesAmount());
        });
        
        // 5. 启动定时同步
        manager.startScheduledSync();
    }
}
```

## 附录

### A. 业务指标计算公式

| 指标 | 公式 | 说明 |
|------|------|------|
| 利润率 | (销售额-成本)/销售额×100% | 毛利润率 |
| 库存周转率 | 销售成本/平均库存 | 年周转次数 |
| 周转天数 | 365/库存周转率 | 库存周转天数 |
| 客单价 | 销售总额/订单数 | 平均订单金额 |
| 环比增长率 | (本期-上期)/上期×100% | 与上一期对比 |
| 同比增长率 | (本期-去年同期)/去年同期×100% | 与去年同期对比 |

### B. 缓慢变化维度（SCD）处理

采用Type 2处理方式：
- 保留历史版本
- 使用effective_date和expiry_date标记有效期
- is_current标记当前版本

### C. 扩展建议

1. **ClickHouse集成**: 对于超大数据量场景，可扩展使用ClickHouse作为OLAP存储
2. **实时数仓**: 可集成Flink CDC实现近实时数据同步
3. **数据血缘**: 增加数据血缘追踪，便于数据治理
4. **数据安全**: 增加数据脱敏和访问控制功能
