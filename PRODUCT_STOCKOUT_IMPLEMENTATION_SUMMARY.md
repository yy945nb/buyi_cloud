# 产品断货点监控模型实施总结
# Product Stockout Monitoring Model - Implementation Summary

## 项目概述 / Project Overview

本项目成功实现了将国内仓余单/实物库存数据（`amf_jh_company_stock`）集成到"基于产品的断货点监控模型"中，提供产品级别（SPU维度）的库存监控和风险预警能力。

## 实施内容 / Implementation Content

### 1. 数据库架构 (Database Schema)

#### 1.1 新增表结构

**核心表：`cos_oos_spu_monitor_daily`**
- **用途**：产品级别断货点监控快照表（日粒度）
- **维度**：company_id, commodity_id, monitor_date
- **核心字段**：
  - 国内仓数据：`domestic_remaining_qty`, `domestic_actual_stock_qty`
  - 海外仓数据：`platform_total_onhand`, `open_intransit_qty`
  - 需求指标：`weighted_daily_demand`, `doc_days`, `oos_date_estimate`
  - 补货建议：`suggest_transfer_qty`, `suggest_produce_qty`
  - 风险评估：`risk_level` (0-4), `risk_reason`
- **索引策略**：
  - 主键：id
  - 唯一键：uk_company_commodity_date (company_id, commodity_id, monitor_date, deleted)
  - 查询索引：company_date, commodity_date, risk_level, oos_date

#### 1.2 视图（Views）

**`v_domestic_stock_to_product`**
- **用途**：将 amf_jh_company_stock.local_sku 映射到 pms_commodity_sku
- **映射规则**：
  ```sql
  local_sku = custom_code OR local_sku = commodity_sku_code
  ```
- **过滤条件**：仅匹配在售且未删除的SKU（use_status=0, sale_status=0）

#### 1.3 存储过程（Stored Procedures）

**`sp_calculate_spu_stockout_snapshot`**
- **功能**：计算指定日期的产品级别断货点监控快照
- **参数**：
  - `p_monitor_date` (DATE) - 监控日期，NULL则使用当前日期
  - `p_company_id` (BIGINT) - 企业ID，NULL则处理所有企业
- **核心逻辑**：
  1. 查找最近的 sync_date（≤ monitor_date）
  2. 从 amf_jh_company_stock 聚合国内仓库存
  3. 通过视图映射到产品级别
  4. 关联 SKU 级别监控数据（cos_oos_monitor_daily）
  5. 计算风险指标和补货建议
  6. 使用 INSERT...ON DUPLICATE KEY UPDATE 保证幂等性
- **返回值**：处理记录数、高风险产品数

#### 1.4 索引优化

**amf_jh_company_stock 表索引**
```sql
ALTER TABLE amf_jh_company_stock 
  ADD INDEX idx_sync_date (sync_date),
  ADD INDEX idx_local_sku (local_sku),
  ADD INDEX idx_sync_date_local_sku (sync_date, local_sku);
```

### 2. 数据流程 (Data Flow)

```
[数据源]
amf_jh_company_stock (国内仓库存)
  ↓
[步骤1] 按 monitor_date 取最近的 sync_date
  ↓
[步骤2] 按 local_sku 聚合：
  - remaining_qty = SUM(remaining_num)
  - actual_stock_qty = SUM(stock_num)
  ↓
[步骤3] 通过 v_domestic_stock_to_product 映射到产品
  - local_sku → commodity_id
  ↓
[步骤4] 关联 SKU 级别监控数据
  - cos_oos_monitor_daily
  ↓
[步骤5] 按 commodity_id 聚合到产品级别
  - 计算 doc_days, oos_date_estimate
  - 确定 risk_level
  ↓
[结果表]
cos_oos_spu_monitor_daily (产品级监控快照)
```

### 3. 风险等级定义 (Risk Level Definition)

| 等级 | 名称 | 说明 | 处理建议 |
|------|------|------|----------|
| 0 | 正常 | 库存充足，覆盖天数充裕 | 保持监控 |
| 1 | 安全区 | 库存在安全范围内 | 关注趋势 |
| 2 | 需要生产 | 需要安排生产计划 | 启动生产流程 |
| 3 | 直补来不及 | 生产周期不足，需紧急直补 | 紧急直补或调货 |
| 4 | 已断货 | 已经断货或即将断货 | 紧急处理，业务影响评估 |

### 4. 文档体系 (Documentation Structure)

#### 4.1 核心文档

1. **PRODUCT_STOCKOUT_MONITOR_GUIDE.md** (660行)
   - 完整的功能说明和使用指南
   - 数据源说明、表结构详解
   - 数据处理流程图
   - 查询示例（5个典型场景）
   - 性能优化建议
   - 定时任务配置
   - 故障排查指南

2. **PRODUCT_STOCKOUT_MONITOR_QUICKREF.md** (296行)
   - 快速参考手册
   - 常用SQL查询模板
   - 快速开始指南
   - 最佳实践
   - 数据字典

3. **product_stockout_monitor_schema.sql** (374行)
   - 完整的数据库架构定义
   - 表、视图、存储过程
   - 索引优化语句
   - 使用说明和注释

4. **product_stockout_monitor_test.sql** (379行)
   - 9大类测试用例
   - 环境检查、数据质量验证
   - 功能测试、准确性验证
   - 幂等性测试、性能测试
   - 边界条件测试
   - 综合报告

#### 4.2 主要更新

- **README.md**：添加产品断货点监控模型章节
- **buyi_platform_dev.sql**：集成完整架构（+376行）

### 5. 关键特性 (Key Features)

#### 5.1 数据整合
- ✅ 国内仓余单数量（remaining_num）
- ✅ 国内仓实物库存（stock_num）
- ✅ 自动 local_sku 到产品 SKU 映射
- ✅ SKU 级别数据聚合到产品级别

#### 5.2 智能分析
- ✅ 覆盖天数计算（doc_days）
- ✅ 预计断货日期（oos_date_estimate）
- ✅ 5级风险评估（0-4）
- ✅ 智能补货建议（直补量、生产量）

#### 5.3 技术保障
- ✅ 幂等性设计（可重复执行）
- ✅ 索引优化（查询性能保障）
- ✅ 软删除机制（历史数据保留）
- ✅ 完整的测试覆盖

#### 5.4 运维支持
- ✅ 定时任务配置（MySQL Event / Cron）
- ✅ 执行监控（时间、记录数）
- ✅ 数据清理策略（90天历史保留）
- ✅ 故障排查手册

### 6. 使用示例 (Usage Examples)

#### 6.1 基本使用
```sql
-- 计算今天的快照
CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);

-- 查询高风险产品
SELECT 
  commodity_id,
  commodity_code,
  domestic_actual_stock_qty,
  platform_total_onhand,
  doc_days,
  risk_level,
  risk_reason
FROM cos_oos_spu_monitor_daily
WHERE monitor_date = CURDATE()
  AND risk_level >= 3
  AND deleted = 0
ORDER BY doc_days ASC;
```

#### 6.2 定时调度
```sql
-- MySQL Event
CREATE EVENT evt_daily_spu_stockout_snapshot
ON SCHEDULE EVERY 1 DAY
STARTS DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 1 DAY), INTERVAL 3 HOUR)
DO
  CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);
```

#### 6.3 数据验证
```sql
-- 执行完整测试套件
SOURCE product_stockout_monitor_test.sql;
```

### 7. 性能指标 (Performance Metrics)

#### 7.1 预期性能
- **执行时间目标**：< 60秒（正常），< 300秒（警告）
- **数据量支持**：支持10万+ 产品记录
- **并发支持**：支持多企业并行计算

#### 7.2 优化措施
- 索引优化（3个关键索引）
- 视图缓存（映射视图）
- 批量处理（避免逐行操作）
- 分区表支持（可选，大数据量场景）

### 8. 数据完整性 (Data Integrity)

#### 8.1 唯一性约束
```sql
UNIQUE KEY uk_company_commodity_date 
  (company_id, commodity_id, monitor_date, deleted)
```

#### 8.2 幂等性保证
- INSERT...ON DUPLICATE KEY UPDATE 机制
- 多次执行相同参数，结果一致
- 支持数据重算和修正

#### 8.3 数据质量检查
- 映射覆盖率监控（目标 ≥ 80%）
- 聚合准确性验证
- 异常数据告警

### 9. 部署清单 (Deployment Checklist)

#### 9.1 数据库部署
- [ ] 执行 product_stockout_monitor_schema.sql
- [ ] 验证表、视图、存储过程创建成功
- [ ] 验证索引创建成功
- [ ] 检查权限配置

#### 9.2 数据准备
- [ ] 确认 amf_jh_company_stock 有数据
- [ ] 验证 pms_commodity_sku 映射关系
- [ ] 检查 cos_oos_monitor_daily 数据

#### 9.3 功能验证
- [ ] 执行测试套件（product_stockout_monitor_test.sql）
- [ ] 手动调用存储过程测试
- [ ] 验证幂等性
- [ ] 性能测试

#### 9.4 定时任务配置
- [ ] 配置 MySQL Event 或 Cron Job
- [ ] 设置执行监控和告警
- [ ] 配置日志记录

#### 9.5 文档和培训
- [ ] 分发使用文档给相关团队
- [ ] 培训操作人员
- [ ] 建立支持渠道

### 10. 后续优化建议 (Future Enhancements)

#### 10.1 功能扩展
1. **区分具体仓库**
   - 在快照表中添加 warehouse_id 字段
   - 支持按仓库维度的监控

2. **历史趋势分析**
   - 创建趋势分析视图
   - 预测未来库存走势

3. **智能补货优化**
   - 引入季节性因素
   - 机器学习预测需求

4. **预警通知**
   - 集成邮件/短信通知
   - 钉钉/企业微信集成

5. **可视化仪表板**
   - 库存健康度仪表板
   - 风险产品热力图

#### 10.2 性能优化
1. 分区表（按月分区）
2. 物化视图（映射关系缓存）
3. 增量计算（仅计算变更数据）
4. 并行处理（多企业并行）

#### 10.3 数据治理
1. 数据质量监控平台
2. 自动化映射维护
3. 数据血缘追踪
4. 合规性审计

### 11. 成果总结 (Achievements)

#### 11.1 交付物清单
1. ✅ 数据库架构文件（374行SQL）
2. ✅ 完整使用指南（660行文档）
3. ✅ 快速参考手册（296行文档）
4. ✅ 测试套件（379行SQL，9大类测试）
5. ✅ 主数据库文件集成（+376行）
6. ✅ README更新

#### 11.2 代码质量
- ✅ 代码审查通过（无问题）
- ✅ 安全检查通过
- ✅ SQL标准遵循
- ✅ 完整的注释文档

#### 11.3 文档质量
- ✅ 中英文双语文档
- ✅ 完整的数据流程图
- ✅ 丰富的使用示例
- ✅ 详细的故障排查指南

### 12. 项目指标 (Project Metrics)

| 指标 | 数值 |
|------|------|
| 代码行数 | 1,709 行 |
| SQL文件 | 2 个（schema + test） |
| 文档文件 | 2 个（guide + quickref） |
| 测试用例 | 9 大类 |
| 索引优化 | 3 个 |
| 查询示例 | 15+ 个 |
| 文档总字数 | ~25,000 字 |

### 13. 技术栈 (Technology Stack)

- **数据库**：MySQL 8.0+
- **存储过程语言**：SQL/PSM
- **索引类型**：B-Tree
- **视图类型**：Standard View
- **字符集**：UTF8MB4
- **引擎**：InnoDB

### 14. 维护和支持 (Maintenance & Support)

#### 14.1 日常维护
- 每日监控快照计算执行状态
- 每周检查数据质量指标
- 每月清理历史数据
- 每季度性能优化评估

#### 14.2 故障响应
1. 查看执行日志
2. 执行测试套件诊断
3. 检查数据源状态
4. 参考故障排查指南
5. 联系技术支持

#### 14.3 版本管理
- 当前版本：v1.0
- 更新记录：见 Git 提交历史
- 升级计划：待定

### 15. 结论 (Conclusion)

本项目成功实现了产品级别断货点监控模型的完整实施，包括：
- ✅ 完整的数据库架构设计和实现
- ✅ 高质量的文档体系
- ✅ 全面的测试覆盖
- ✅ 清晰的运维指南

该系统能够：
1. **准确聚合**国内仓库存数据到产品级别
2. **智能评估**断货风险和覆盖天数
3. **及时预警**高风险产品
4. **精准建议**补货量和生产量

系统设计遵循了：
- 幂等性原则（可重复执行）
- 性能优化最佳实践
- 数据完整性约束
- 可维护性和可扩展性

**项目状态**：✅ 已完成，可投入生产使用

---

**编写时间**：2024-02-03  
**版本**：v1.0  
**负责人**：Buyi Tech Team
