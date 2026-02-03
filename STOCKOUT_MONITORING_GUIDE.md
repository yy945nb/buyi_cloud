# 产品断货点监控模型使用指南
# Stock-Out Point Monitoring Model User Guide

## 概述 / Overview

本断货点监控模型基于现有产品基础数据，引入区域仓-仓库绑定与仓库维度库存/在途聚合，实现FBA与区域仓模式的业务隔离，为跨境电商提供精准的断货预警和补货决策支持。

This stock-out monitoring model is built upon existing product data, introducing regional warehouse-warehouse binding and warehouse-level inventory/in-transit aggregation. It implements business isolation between FBA and regional warehouse modes, providing precise stock-out alerts and replenishment decision support for cross-border e-commerce.

## 核心功能 / Core Features

### 1. 双模式业务隔离 (Dual-Mode Business Isolation)

**FBA模式 (FBA Mode)**
- 使用FBA平台库存作为海外仓库存
- FBA shipment作为在途库存
- 按FBA仓库（逻辑仓）聚合
- 适用于亚马逊FBA全托管等场景

**区域仓模式 (Regional Warehouse Mode)**
- JH（鲸汇）+ LX（领星）海外仓库存合并
- JH shipment + LX发货单合并作为在途
- 按区域仓聚合，支持多仓库绑定
- 适用于自建海外仓、第三方仓储场景

### 2. 仓库维度监控 (Warehouse-Level Monitoring)

每个快照记录包含完整的维度信息：
- **时间维度**: monitor_date（监控日期）
- **企业维度**: company_id
- **模式维度**: business_mode（FBA/REGIONAL）
- **区域仓维度**: region_warehouse_id, region_warehouse_code, region_code
- **仓库维度**: warehouse_id, warehouse_code, warehouse_name
- **产品维度**: commodity_id/code（SPU）, commodity_sku_id/code（SKU）

### 3. 断货点计算模型 (Stock-Out Point Calculation)

#### 核心指标计算公式

```
区域日均销量 = daily_sale_qty × region_order_ratio

安全库存数量 = 区域日均销量 × safety_days

再订货点(ROP) = 区域日均销量 × (shipping_days + producte_days + safety_days)

缺口数量 = ROP - (onhand_qty + in_transit_qty)

可售天数 = (onhand_qty + in_transit_qty) / 区域日均销量

预计断货日期 = monitor_date + 可售天数
```

#### 风险等级划分

| 风险等级 | 可售天数 | 说明 |
|---------|---------|------|
| CRITICAL | ≤ 7天 | 极高风险，需立即补货 |
| HIGH | 8-15天 | 高风险，紧急安排补货 |
| MEDIUM | 16-30天 | 中风险，正常补货计划 |
| LOW | > 30天 | 低风险，库存充足 |

## 数据库表结构 / Database Schema

### 核心表 (Core Tables)

#### 1. pms_commodity_params - 产品SPU日参数表
存储SPU级别的每日参数，包括销量、库存、时间参数和断货点指标。

**关键字段**：
- `commodity_id`, `commodity_code`: 产品标识
- `data_date`: 数据日期
- `platform_sale_num`, `daily_sale_qty`: 销售指标
- `remaining_qty`, `open_intransit_qty`: 库存指标
- `safety_days`, `shipping_days`, `producte_days`: 时间参数
- `rop_qty`, `oos_platform_date`, `risk_level`: 断货点指标

#### 2. pms_commodity_sku_params - 产品SKU日参数表
存储SKU级别的每日参数，字段结构类似SPU表，但粒度更细。

#### 3. pms_commodity_sku_region_warehouse_params - SKU区域仓维度快照表（核心）
**这是最重要的快照表**，按仓库和区域仓维度记录每日监控数据。

**关键字段**：
```sql
monitor_date           -- 监控日期
company_id             -- 企业ID
business_mode          -- 业务模式: FBA/REGIONAL
region_warehouse_id    -- 区域仓ID
warehouse_id           -- 仓库ID（关联wms_warehouse.id）
commodity_sku_id       -- SKU ID

-- 库存指标
onhand_qty             -- 海外仓现有库存
in_transit_qty         -- 在途库存
backlog_qty            -- 余单/未发货
total_available_qty    -- 总可用库存

-- 销售指标
region_order_ratio     -- 区域订单比例
daily_sale_qty         -- 原始日均销量
region_daily_sale_qty  -- 区域日均销量

-- 断货点计算
safety_stock_qty       -- 安全库存数量
rop_qty                -- 再订货点
gap_qty                -- 缺口数量
available_days         -- 可售天数
oos_date_est           -- 预计断货日期
risk_level             -- 风险等级
```

#### 4. pms_commodity_region_warehouse_params - SPU区域仓维度快照表
从SKU快照聚合到SPU级别，用于SPU维度的断货监控。

### 配置表 (Configuration Tables)

#### 5. region_warehouse_config - 区域仓配置表
定义区域仓的基础信息和类型。

```sql
region_warehouse_id       -- 区域仓ID
region_warehouse_code     -- 区域仓编码
region_warehouse_name     -- 区域仓名称
warehouse_type            -- 仓库类型: FBA/REGIONAL
region_code               -- 区域代码(US_WEST/US_EAST等)
```

#### 6. region_warehouse_binding - 区域仓与仓库绑定关系表
定义区域仓与物理/逻辑仓库的绑定关系。

```sql
region_warehouse_id       -- 区域仓ID
warehouse_id              -- 仓库ID（关联wms_warehouse.id）
binding_type              -- 绑定类型: STORAGE/TRANSIT
priority                  -- 优先级
```

#### 7. warehouse_mapping - 仓库映射表
处理第三方仓库编码到wms_warehouse的映射。

```sql
warehouse_id              -- 仓库ID
source_system             -- 来源系统: JH/LX/OWMS/FBA
external_warehouse_id     -- 外部仓库ID
external_warehouse_code   -- 外部仓库编码
mapping_type              -- 映射类型: PHYSICAL/LOGICAL
```

#### 8. region_order_ratio_config - 区域订单比例配置表
配置产品在不同区域的订单分布比例。

```sql
commodity_id              -- 产品ID（NULL表示全局默认）
commodity_sku_id          -- SKU ID（NULL表示SPU级）
region_warehouse_id       -- 区域仓ID
order_ratio               -- 订单比例（0-1之间）
effective_date            -- 生效日期
expiry_date               -- 失效日期
```

## 存储过程 / Stored Procedures

### 1. sp_sync_pms_commodity_sku_region_wh_params_daily
同步产品SKU区域仓日参数

**功能**：
- 基于pms_commodity_sku_params生成区域仓维度快照
- 分别处理REGIONAL和FBA两种模式
- 自动计算断货点指标和风险等级

**调用方式**：
```sql
CALL sp_sync_pms_commodity_sku_region_wh_params_daily(
    1,              -- company_id
    '2024-02-03'    -- monitor_date
);
```

**处理逻辑**：
1. 删除指定日期的已有数据
2. 插入REGIONAL模式数据：
   - 关联region_warehouse_config（warehouse_type='REGIONAL'）
   - 关联region_warehouse_binding获取仓库绑定
   - 关联region_order_ratio_config获取区域比例
   - 从pms_commodity_sku_params获取基础数据
   - 计算区域日均销量、ROP、缺口、可售天数
   - 评估风险等级
3. 插入FBA模式数据（逻辑类似，使用warehouse_type='FBA'）

### 2. sp_sync_pms_commodity_region_wh_params_daily
同步产品SPU区域仓日参数（从SKU聚合）

**功能**：
- 将SKU级别快照聚合到SPU级别
- 重新计算SPU维度的断货点指标

**调用方式**：
```sql
CALL sp_sync_pms_commodity_region_wh_params_daily(
    1,              -- company_id
    '2024-02-03'    -- monitor_date
);
```

**聚合规则**：
- 库存指标：SUM聚合
- 销售指标：SUM聚合日均销量
- 时间参数：MAX取最保守值
- 风险等级：取最严重等级

### 3. sp_sync_jh_shop_to_cos_shop
JH店铺同步到cos_shop

**功能**：
- 从amf_jh_ecommerce同步JH平台店铺到cos_shop
- 确保platform_shop_id与external_id值相同

**调用方式**：
```sql
CALL sp_sync_jh_shop_to_cos_shop();
```

### 4. sp_sync_jh_warehouse_relation
JH仓库关系同步

**功能**：
- 从amf_jh_shop_warehouse同步到cos_shop_warehouse_relation
- relation_type=4表示发货仓

**调用方式**：
```sql
CALL sp_sync_jh_warehouse_relation();
```

## 使用场景 / Use Cases

### 场景1: 每日断货监控
```sql
-- 1. 生成SKU级别快照
CALL sp_sync_pms_commodity_sku_region_wh_params_daily(1, CURDATE());

-- 2. 生成SPU级别快照
CALL sp_sync_pms_commodity_region_wh_params_daily(1, CURDATE());

-- 3. 查询高风险SKU
SELECT 
    business_mode,
    region_warehouse_name,
    warehouse_name,
    commodity_sku_code,
    onhand_qty,
    in_transit_qty,
    region_daily_sale_qty,
    available_days,
    oos_date_est,
    risk_level
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1
  AND monitor_date = CURDATE()
  AND risk_level IN ('CRITICAL', 'HIGH')
ORDER BY available_days ASC;
```

### 场景2: 区域仓库存分析
```sql
-- 按区域仓汇总库存和销售
SELECT 
    region_warehouse_code,
    region_warehouse_name,
    business_mode,
    COUNT(DISTINCT commodity_sku_id) as sku_count,
    SUM(onhand_qty) as total_onhand,
    SUM(in_transit_qty) as total_in_transit,
    SUM(region_daily_sale_qty) as total_daily_sales,
    AVG(available_days) as avg_available_days
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1
  AND monitor_date = CURDATE()
GROUP BY region_warehouse_code, region_warehouse_name, business_mode
ORDER BY business_mode, avg_available_days ASC;
```

### 场景3: FBA vs 区域仓对比
```sql
-- 对比两种模式的库存健康度
SELECT 
    business_mode,
    risk_level,
    COUNT(*) as sku_count,
    SUM(gap_qty) as total_gap_qty,
    AVG(available_days) as avg_available_days
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1
  AND monitor_date = CURDATE()
GROUP BY business_mode, risk_level
ORDER BY business_mode, 
    CASE risk_level 
        WHEN 'CRITICAL' THEN 1 
        WHEN 'HIGH' THEN 2 
        WHEN 'MEDIUM' THEN 3 
        ELSE 4 
    END;
```

### 场景4: 补货缺口计算
```sql
-- 计算需要补货的SKU及数量
SELECT 
    business_mode,
    region_warehouse_code,
    warehouse_name,
    commodity_code,
    commodity_sku_code,
    gap_qty,
    region_daily_sale_qty,
    shipping_days + producte_days as lead_time_days,
    CEIL(gap_qty + region_daily_sale_qty * (shipping_days + producte_days)) as recommended_order_qty
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1
  AND monitor_date = CURDATE()
  AND gap_qty > 0
  AND risk_level IN ('CRITICAL', 'HIGH')
ORDER BY risk_level, available_days ASC;
```

### 场景5: 趋势分析
```sql
-- 分析过去7天的库存和风险趋势
SELECT 
    monitor_date,
    commodity_sku_code,
    business_mode,
    onhand_qty,
    in_transit_qty,
    available_days,
    risk_level
FROM pms_commodity_sku_region_warehouse_params
WHERE company_id = 1
  AND commodity_sku_id = 12345
  AND monitor_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY monitor_date DESC, business_mode;
```

## 数据口径说明 / Data Specification

### 1. 库存指标口径

**海外仓现有库存 (onhand_qty)**
- **区域仓模式**: JH海外仓库存 + LX海外仓库存，按SKU编码匹配合并
- **FBA模式**: FBA平台库存（从平台API获取）
- **数据来源**: pms_commodity_sku_params.remaining_qty（需对接实际仓库系统）

**在途库存 (in_transit_qty)**
- **区域仓模式**: JH shipment + LX发货单（OWMS等），已发未到
- **FBA模式**: FBA shipment（已发往FBA仓但未上架）
- **数据来源**: pms_commodity_sku_params.open_intransit_qty

**余单/未发货 (backlog_qty)**
- 已下单但未发货的数量
- **当前实现**: 预留字段，默认为0
- **后续扩展**: 对接订单系统获取实际数据

### 2. 销售指标口径

**日均销量 (daily_sale_qty)**
- 基础日均销量，通常为最近7天/15天/30天加权平均
- **数据来源**: pms_commodity_sku_params.daily_sale_qty

**区域订单比例 (region_order_ratio)**
- 产品在该区域的订单占比
- **默认值**: REGIONAL模式25%，FBA模式100%
- **配置来源**: region_order_ratio_config表
- **优先级**: SKU级配置 > SPU级配置 > 全局默认

**区域日均销量 (region_daily_sale_qty)**
- 该区域实际日均销量 = daily_sale_qty × region_order_ratio
- 用于该区域的断货点计算

### 3. 时间参数口径

**安全库存天数 (safety_days)**
- 缓冲库存天数，应对销量波动和不确定性
- **默认值**: 15天
- **推荐值**: 根据产品类别调整（S类30-45天，A类20-30天，B/C类15-20天）

**运输天数 (shipping_days)**
- 从国内发货到海外仓上架的时间
- **默认值**: 30天
- **实际值**: 美东50天，美西35天，欧洲40-45天

**生产周期天数 (producte_days)**
- 从下单到生产完成的时间
- **默认值**: 15天
- **实际值**: 根据供应商和产品类型调整

### 4. 断货点计算口径

**安全库存数量 (safety_stock_qty)**
```
safety_stock_qty = CEIL(region_daily_sale_qty × safety_days)
```

**再订货点 (rop_qty)**
```
rop_qty = CEIL(region_daily_sale_qty × (shipping_days + producte_days + safety_days))
```
- 含义：当库存低于此值时应立即下单

**缺口数量 (gap_qty)**
```
gap_qty = rop_qty - total_available_qty
```
- 正值：需要补货的数量
- 负值：库存充足，无需补货

**可售天数 (available_days)**
```
available_days = total_available_qty / region_daily_sale_qty
```
- 按当前销量，现有库存可供销售的天数

**预计断货日期 (oos_date_est)**
```
oos_date_est = monitor_date + available_days
```

## 实施步骤 / Implementation Steps

### 第一步：初始化配置表

```sql
-- 1. 配置区域仓
INSERT INTO region_warehouse_config 
    (company_id, region_warehouse_id, region_warehouse_code, 
     region_warehouse_name, region_code, warehouse_type)
VALUES
    (1, 1001, 'RW_US_WEST', '美西区域仓', 'US_WEST', 'REGIONAL'),
    (1, 1002, 'RW_US_EAST', '美东区域仓', 'US_EAST', 'REGIONAL'),
    (1, 2001, 'FBA_US_WEST', 'FBA美西', 'US_WEST', 'FBA'),
    (1, 2002, 'FBA_US_EAST', 'FBA美东', 'US_EAST', 'FBA');

-- 2. 配置仓库映射（示例）
INSERT INTO warehouse_mapping
    (company_id, warehouse_id, source_system, 
     external_warehouse_code, external_warehouse_name)
VALUES
    (1, 3001, 'JH', 'JH_WH_001', 'JH美西仓'),
    (1, 3002, 'LX', 'LX_WH_001', 'LX美西仓'),
    (1, 4001, 'FBA', 'FBA_LAX1', 'FBA洛杉矶仓');

-- 3. 配置区域仓绑定
INSERT INTO region_warehouse_binding
    (company_id, region_warehouse_id, warehouse_id, 
     warehouse_code, warehouse_name, binding_type)
VALUES
    (1, 1001, 3001, 'JH_WH_001', 'JH美西仓', 'STORAGE'),
    (1, 1001, 3002, 'LX_WH_001', 'LX美西仓', 'STORAGE'),
    (1, 2001, 4001, 'FBA_LAX1', 'FBA洛杉矶仓', 'STORAGE');

-- 4. 配置区域订单比例
INSERT INTO region_order_ratio_config
    (company_id, region_warehouse_id, region_code, 
     order_ratio, effective_date)
VALUES
    (1, 1001, 'US_WEST', 0.3000, '2024-01-01'),
    (1, 1002, 'US_EAST', 0.2500, '2024-01-01'),
    (1, 2001, 'US_WEST', 0.2500, '2024-01-01'),
    (1, 2002, 'US_EAST', 0.2000, '2024-01-01');
```

### 第二步：准备基础参数数据

```sql
-- 确保pms_commodity_sku_params有数据
-- 可以从现有销售、库存表ETL生成
INSERT INTO pms_commodity_sku_params
    (company_id, commodity_id, commodity_code, 
     commodity_sku_id, commodity_sku_code, data_date,
     daily_sale_qty, remaining_qty, open_intransit_qty,
     safety_days, shipping_days, producte_days)
SELECT
    company_id,
    commodity_id,
    commodity_code,
    sku_id,
    sku_code,
    CURDATE(),
    -- 这里需要实际的销量计算逻辑
    daily_sales,
    current_stock,
    in_transit_stock,
    15, 30, 15
FROM your_sales_inventory_source;
```

### 第三步：执行每日同步

```sql
-- 设置定时任务，每日凌晨执行
-- 1. 同步SKU级快照
CALL sp_sync_pms_commodity_sku_region_wh_params_daily(1, CURDATE());

-- 2. 同步SPU级快照
CALL sp_sync_pms_commodity_region_wh_params_daily(1, CURDATE());
```

### 第四步：JH店铺和仓库同步（可选）

```sql
-- 如果使用JH系统，需要同步店铺和仓库关系
CALL sp_sync_jh_shop_to_cos_shop();
CALL sp_sync_jh_warehouse_relation();
```

## 注意事项 / Notes

### 1. 数据来源集成

当前实现中，库存和在途数据来自`pms_commodity_sku_params`表，这只是一个中间抽象层。实际部署时需要：
- 对接JH仓库系统API获取JH海外仓库存
- 对接LX（领星）/OWMS系统获取LX海外仓库存
- 对接FBA API获取FBA平台库存
- 对接物流系统获取在途数据

### 2. 区域订单比例

区域订单比例影响断货点计算的准确性：
- 建议基于历史订单数据分析实际区域分布
- 定期更新比例配置（建议每月或每季度）
- 对于新品，使用同类产品的历史比例

### 3. 时间参数校准

shipping_days、producte_days、safety_days需根据实际情况校准：
- 运输天数：考虑淡旺季、物流供应商、路线差异
- 生产周期：考虑供应商产能、原材料采购周期
- 安全天数：考虑销量波动、供应链稳定性

### 4. 风险等级阈值

当前风险等级阈值为：≤7天（CRITICAL）、≤15天（HIGH）、≤30天（MEDIUM）、>30天（LOW）。
可根据业务实际情况调整存储过程中的阈值。

### 5. 性能优化

- 快照表数据量会随时间增长，建议定期归档历史数据（保留1-3个月）
- 为常用查询维度建立合适的索引
- 考虑分区表方案（按monitor_date分区）

### 6. 数据质量

- 确保pms_commodity_sku_params每日及时更新
- 定期检查异常数据（如负库存、异常大的销量等）
- 建立数据质量监控和告警机制

## 扩展方向 / Future Enhancements

1. **智能补货建议**: 基于断货风险和供应链约束，自动生成最优补货计划
2. **多级库存优化**: 考虑国内仓、海运在途、海外仓的多级库存协同
3. **季节性调整**: 引入季节系数，自动调整安全库存和订单比例
4. **供应商协同**: 与供应商系统对接，实时获取生产进度和产能信息
5. **预测模型**: 使用机器学习预测销量趋势，提升断货预警准确性
6. **成本优化**: 综合考虑库存持有成本、缺货成本、运输成本的最优决策

## 技术支持 / Technical Support

如有问题或建议，请通过以下方式联系：
- GitHub Issue: 提交问题和功能请求
- 技术文档: 参考其他相关文档（DATA_WAREHOUSE_GUIDE.md, STOCKING_MODEL_GUIDE.md）

## 版本历史 / Version History

- **v1.0.0** (2024-02-03): 初始版本
  - 实现FBA和区域仓双模式监控
  - 完成仓库维度库存聚合
  - 实现断货点计算和风险评估
  - 提供4个核心存储过程
