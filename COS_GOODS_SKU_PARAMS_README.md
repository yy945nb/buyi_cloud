# cos_goods_sku_params 存储过程实现 - 完整解决方案

## 📋 项目概述

本项目实现了 `cos_goods_sku_params` 表及其同步存储过程 `sp_sync_cos_goods_sku_params_daily`，用于每日同步商品 SKU 参数快照。核心目标是**确保 `sku_id` 和 `spu_id` 与主表 `cos_goods_sku` 保持一致**，避免常见的数据不一致问题。

## 🎯 核心问题与解决方案

### 问题
使用 `MIN(id)` + `GROUP BY` 聚合时，`sku_id` 和 `spu_id` 可能来自不同的 `cos_goods_sku` 记录，导致数据不一致。

### 解决方案
使用 **窗口函数** `ROW_NUMBER()` 按明确优先级选择唯一记录，确保所有字段来自同一行。

```sql
-- ✅ 正确做法
ROW_NUMBER() OVER (
    PARTITION BY company_id, shop_id, sku_code
    ORDER BY 
        is_delete ASC,      -- 1. 未删除优先
        sync_date DESC,     -- 2. 最新同步优先
        create_time DESC,   -- 3. 最新创建优先
        id DESC             -- 4. 最大 ID 优先
) AS rn
WHERE rn = 1
```

## 📁 文件导航

| 文件 | 说明 | 适用人群 |
|------|------|----------|
| **[QUICKSTART.md](./QUICKSTART.md)** | 🚀 快速部署指南 | 运维人员、DBA |
| **[VISUALIZATION.md](./VISUALIZATION.md)** | 📊 可视化图解 | 所有人 |
| **[FIX_GUIDE.md](./FIX_GUIDE.md)** | 🔧 技术详解 | 开发人员 |
| **[PR_SUMMARY.md](./PR_SUMMARY.md)** | 📝 PR 完整摘要 | 项目经理、审核人员 |
| **[cos_goods_sku_params_procedure.sql](./cos_goods_sku_params_procedure.sql)** | 💾 表定义 + 存储过程 | 部署使用 |
| **[cos_goods_sku_params_test.sql](./cos_goods_sku_params_test.sql)** | 🧪 测试和验证 | QA、开发人员 |

## 🚀 快速开始（3 步）

### 1️⃣ 导入定义
```bash
mysql -h <host> -u <user> -p <database> < cos_goods_sku_params_procedure.sql
```

### 2️⃣ 执行同步
```sql
-- 同步昨天的数据
CALL sp_sync_cos_goods_sku_params_daily(NULL);
```

### 3️⃣ 验证数据
```sql
-- 检查一致性（应该返回 0 行）
SELECT COUNT(*) FROM cos_goods_sku_params p
LEFT JOIN cos_goods_sku k ON p.sku_id = k.id
WHERE p.deleted = 0 AND (k.id IS NULL OR p.spu_id != k.spu_id);
```

## ✨ 关键特性

### ✅ 数据一致性保证
- `sku_id` 直接使用 `cos_goods_sku.id`
- `spu_id` 直接使用 `cos_goods_sku.spu_id`
- 两个字段保证来自同一行记录

### ✅ 智能记录选择
当同一 `sku_code` 有多条记录时，按以下优先级选择：
1. **未删除** 的记录
2. **最新同步** 的记录
3. **最新创建** 的记录
4. **最大 ID** 的记录

### ✅ 幂等性保证
- 使用 `REPLACE INTO` 语句
- 唯一键约束：`(company_id, shop_id, sku_id, monitor_date, deleted)`
- 多次执行相同日期不会产生重复记录

### ✅ 完整的验证体系
- 数据一致性检查查询
- 重复记录检测查询
- 幂等性验证测试
- 性能分析工具

## 📊 表结构说明

```sql
cos_goods_sku_params
├── id (主键)
├── company_id
├── shop_id
├── sku_id          ← 对应 cos_goods_sku.id
├── spu_id          ← 必须与 sku_id 对应行的 spu_id 一致
├── sku_code
├── monitor_date    ← 监控日期
├── deleted         ← 软删除标记
└── ... (其他字段)

UNIQUE KEY: (company_id, shop_id, sku_id, monitor_date, deleted)
```

## 🔍 验证清单

执行存储过程后，运行以下检查：

- [ ] **一致性检查**：`sku_id` 和 `spu_id` 与主表匹配
- [ ] **无重复记录**：同一唯一键只有一条记录
- [ ] **幂等性验证**：多次执行结果相同
- [ ] **记录数合理**：同步的记录数在预期范围内

详细验证查询见 [cos_goods_sku_params_test.sql](./cos_goods_sku_params_test.sql)

## 📈 性能优化

如果数据量大，建议添加以下索引：

```sql
CREATE INDEX idx_sku_window ON cos_goods_sku (
    company_id, shop_id, sku_code, 
    is_delete, sync_date, create_time, id
);
```

## 🔄 定时任务设置

### MySQL Event Scheduler
```sql
CREATE EVENT evt_sync_cos_goods_sku_params_daily
ON SCHEDULE EVERY 1 DAY STARTS '2024-01-01 01:00:00'
DO CALL sp_sync_cos_goods_sku_params_daily(NULL);
```

### Cron Job
```bash
0 1 * * * mysql -h <host> -u <user> -p<pwd> <db> \
  -e "CALL sp_sync_cos_goods_sku_params_daily(NULL);"
```

## 🐛 问题排查

### 发现数据不一致？

1. **检查主数据质量**
   ```sql
   -- 查找同一 sku_code 对应多个 spu_id 的情况
   SELECT sku_code, COUNT(DISTINCT spu_id) AS spu_count
   FROM cos_goods_sku WHERE is_delete = 0
   GROUP BY sku_code HAVING spu_count > 1;
   ```

2. **运行完整验证**
   ```bash
   mysql < cos_goods_sku_params_test.sql
   ```

3. **查看详细文档**
   - [FIX_GUIDE.md](./FIX_GUIDE.md) - 技术详解
   - [VISUALIZATION.md](./VISUALIZATION.md) - 可视化分析

## 📚 扩展阅读

### 核心概念
- **窗口函数**：为什么优于聚合函数
- **幂等性**：REPLACE INTO vs INSERT ... ON DUPLICATE KEY UPDATE
- **数据一致性**：如何确保外键关系正确

### 相关文件
- `cos_goods_sku` 表：主商品 SKU 数据
- `cos_goods_spu` 表：商品 SPU 主数据

## 🤝 贡献与反馈

如遇到问题或有改进建议，请：

1. 查阅相关文档
2. 运行验证查询确认问题
3. 提供完整的错误信息和环境配置
4. 参考 [FIX_GUIDE.md](./FIX_GUIDE.md) 中的解决方案

## 📜 版本历史

- **v1.0** (2024-02): 初始实现
  - 创建表和存储过程
  - 修复 sku_id/spu_id 一致性问题
  - 完整的文档和测试套件

## 📌 重要提醒

⚠️ **生产环境部署前**：
- [ ] 在测试环境充分验证
- [ ] 检查主数据质量（运行诊断查询）
- [ ] 评估性能影响（大数据量时考虑添加索引）
- [ ] 准备回滚方案
- [ ] 通知相关团队

✅ **部署后检查**：
- [ ] 验证数据一致性
- [ ] 确认无重复记录
- [ ] 检查定时任务设置
- [ ] 监控执行性能

---

**快速链接**：
- 🚀 [快速开始](./QUICKSTART.md)
- 📊 [可视化图解](./VISUALIZATION.md)
- 🔧 [技术详解](./FIX_GUIDE.md)
- 📝 [PR 摘要](./PR_SUMMARY.md)
- 💾 [SQL 脚本](./cos_goods_sku_params_procedure.sql)
- 🧪 [测试脚本](./cos_goods_sku_params_test.sql)
