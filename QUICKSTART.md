# Quick Start Guide: cos_goods_sku_params 存储过程部署

## 快速部署步骤

### 1. 部署脚本（生产环境）

```bash
# 连接到数据库
mysql -h <host> -u <user> -p <database>

# 导入存储过程和表定义
source cos_goods_sku_params_procedure.sql;

# 验证表已创建
SHOW TABLES LIKE 'cos_goods_sku_params';

# 验证存储过程已创建
SHOW PROCEDURE STATUS WHERE Db = '<database>' AND Name = 'sp_sync_cos_goods_sku_params_daily';
```

### 2. 首次同步数据

```sql
-- 同步昨天的数据（推荐）
CALL sp_sync_cos_goods_sku_params_daily(NULL);

-- 或指定特定日期
CALL sp_sync_cos_goods_sku_params_daily('2024-01-15');
```

### 3. 验证数据质量

```sql
-- 快速检查：查看同步的记录数
SELECT monitor_date, COUNT(*) AS record_count
FROM cos_goods_sku_params
GROUP BY monitor_date
ORDER BY monitor_date DESC
LIMIT 10;

-- 深度检查：验证 sku_id 和 spu_id 一致性（应该没有结果）
SELECT p.*, k.spu_id AS actual_spu_id
FROM cos_goods_sku_params p
LEFT JOIN cos_goods_sku k ON p.sku_id = k.id
WHERE p.deleted = 0
  AND (k.id IS NULL OR p.spu_id != k.spu_id)
LIMIT 10;
```

### 4. 设置定时任务

使用 MySQL Event Scheduler：

```sql
-- 启用 Event Scheduler
SET GLOBAL event_scheduler = ON;

-- 创建每日定时任务（每天凌晨 1:00 执行）
CREATE EVENT IF NOT EXISTS evt_sync_cos_goods_sku_params_daily
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 1 HOUR)
DO
  CALL sp_sync_cos_goods_sku_params_daily(NULL);

-- 查看定时任务状态
SHOW EVENTS WHERE Name = 'evt_sync_cos_goods_sku_params_daily';
```

或使用 Cron Job：

```bash
# 编辑 crontab
crontab -e

# 添加定时任务（每天凌晨 1:00 执行）
0 1 * * * mysql -h <host> -u <user> -p<password> <database> -e "CALL sp_sync_cos_goods_sku_params_daily(NULL);" >> /var/log/sku_sync.log 2>&1
```

## 核心特性说明

### ✅ 已修复的问题

1. **sku_id 和 spu_id 一致性**
   - ✅ 使用窗口函数代替 MIN 聚合
   - ✅ 确保两个 ID 来自同一行 cos_goods_sku
   - ✅ 避免 JOIN 覆盖 spu_id

2. **重复记录处理**
   - ✅ 优先选择未删除记录
   - ✅ 按时间戳选择最新记录
   - ✅ 明确的优先级规则

3. **幂等性**
   - ✅ 使用 REPLACE INTO
   - ✅ 唯一键约束保证不重复

### 🔍 数据选择规则

当同一个 `(company_id, shop_id, sku_code)` 有多条记录时，按以下优先级选择：

1. **is_delete = 0**（未删除优先）
2. **sync_date DESC**（最新同步优先）
3. **create_time DESC**（最新创建优先）
4. **id DESC**（最大 ID 优先）

### 📊 表结构关键点

```sql
-- 唯一键：基于 sku_id（cos_goods_sku.id），不是 sku_code
UNIQUE KEY `uk_sku_monitor` (`company_id`, `shop_id`, `sku_id`, `monitor_date`, `deleted`)

-- sku_id：对应 cos_goods_sku.id
-- spu_id：必须与 sku_id 对应行的 spu_id 一致
```

## 常见问题处理

### Q1: 发现数据不一致怎么办？

```sql
-- 运行诊断查询
source cos_goods_sku_params_test.sql;

-- 检查主数据质量
SELECT company_id, shop_id, sku_code, 
       COUNT(DISTINCT spu_id) AS spu_count
FROM cos_goods_sku
WHERE is_delete = 0
GROUP BY company_id, shop_id, sku_code
HAVING spu_count > 1;
```

### Q2: 如何重新同步某一天的数据？

```sql
-- 删除该天数据
DELETE FROM cos_goods_sku_params 
WHERE monitor_date = '2024-01-15';

-- 重新同步
CALL sp_sync_cos_goods_sku_params_daily('2024-01-15');
```

### Q3: 性能问题怎么优化？

```sql
-- 添加复合索引优化窗口函数
CREATE INDEX idx_sku_window ON cos_goods_sku (
    company_id, shop_id, sku_code, 
    is_delete, sync_date, create_time, id
);

-- 检查执行计划
EXPLAIN SELECT ... FROM cos_goods_sku ...
```

### Q4: 如何批量同步历史数据？

```sql
-- 创建临时存储过程批量同步
DELIMITER $$
CREATE PROCEDURE batch_sync_history(IN start_date DATE, IN end_date DATE)
BEGIN
    DECLARE v_date DATE;
    SET v_date = start_date;
    
    WHILE v_date <= end_date DO
        CALL sp_sync_cos_goods_sku_params_daily(v_date);
        SET v_date = DATE_ADD(v_date, INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

-- 执行批量同步（例如：同步过去 30 天）
CALL batch_sync_history(DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_SUB(CURDATE(), INTERVAL 1 DAY));

-- 清理临时存储过程
DROP PROCEDURE IF EXISTS batch_sync_history;
```

## 监控建议

### 每日监控指标

1. **同步记录数**：是否在合理范围
2. **数据一致性检查**：无不一致记录
3. **执行时间**：是否在可接受范围
4. **错误日志**：检查同步失败情况

### 监控 SQL

```sql
-- 每日同步趋势
SELECT 
    monitor_date,
    COUNT(*) AS record_count,
    MAX(sync_date) AS last_sync_time,
    TIMESTAMPDIFF(SECOND, MIN(sync_date), MAX(sync_date)) AS sync_duration_seconds
FROM cos_goods_sku_params
WHERE monitor_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY monitor_date
ORDER BY monitor_date DESC;

-- 数据质量监控（应该返回 0）
SELECT COUNT(*) AS inconsistent_count
FROM cos_goods_sku_params p
LEFT JOIN cos_goods_sku k ON p.sku_id = k.id
WHERE p.deleted = 0
  AND p.monitor_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
  AND (k.id IS NULL OR p.spu_id != k.spu_id);
```

## 文件说明

| 文件 | 用途 | 执行时机 |
|------|------|----------|
| `cos_goods_sku_params_procedure.sql` | 表和存储过程定义 | 部署时执行一次 |
| `cos_goods_sku_params_test.sql` | 测试和验证查询 | 测试环境验证 |
| `FIX_GUIDE.md` | 详细技术文档 | 开发人员阅读 |
| `QUICKSTART.md` | 本快速指南 | 运维人员参考 |

## 支持与反馈

如遇到问题，请提供以下信息：

1. 执行的 SQL 命令
2. 错误信息或日志
3. 验证查询结果
4. 数据库版本和配置

## 回滚方案

如需回滚：

```sql
-- 1. 删除定时任务
DROP EVENT IF EXISTS evt_sync_cos_goods_sku_params_daily;

-- 2. 删除存储过程
DROP PROCEDURE IF EXISTS sp_sync_cos_goods_sku_params_daily;

-- 3. 删除表（注意：会丢失所有数据）
DROP TABLE IF EXISTS cos_goods_sku_params;
```

## 版本历史

- **v1.0** (2024-01): 初始版本，修复 sku_id/spu_id 一致性问题
