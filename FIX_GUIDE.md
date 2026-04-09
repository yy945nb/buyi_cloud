# cos_goods_sku_params 存储过程修复说明

## 问题背景

用户反馈执行 `sp_sync_cos_goods_sku_params_daily` 存储过程后，`cos_goods_sku_params` 表中的 `spu_id` 和 `sku_id` 与 `cos_goods_sku` 主数据表不一致。

## 问题分析

根据常见的存储过程设计问题，导致数据不一致的主要原因包括：

### 1. MIN(id) 聚合导致的问题
```sql
-- 错误示例：使用 MIN(k.id) 但 GROUP BY 包含 spu_id
SELECT 
    MIN(k.id) AS sku_id,  -- 可能选到最小 ID
    k.spu_id,             -- 但使用的是另一行的 spu_id
    k.sku_code
FROM cos_goods_sku k
GROUP BY k.company_id, k.shop_id, k.sku_code, k.spu_id
```

**问题**：当同一个 `(company_id, shop_id, sku_code)` 对应多个 SKU 记录（不同的 `id` 和 `spu_id`）时：
- `MIN(k.id)` 会选择 ID 最小的行
- 但 `GROUP BY` 中的 `k.spu_id` 可能来自另一行
- 导致 `sku_id` 和 `spu_id` 不是来自同一条 `cos_goods_sku` 记录

### 2. 软删除记录干扰
- 当存在已删除的历史记录时（`is_delete = 1`），`MIN(id)` 可能选到旧的已删除记录
- 应该优先选择未删除的记录

### 3. JOIN 导致的 spu_id 覆盖
```sql
-- 错误示例：JOIN 后覆盖 spu_id
SELECT 
    k.id AS sku_id,
    spu.id AS spu_id,  -- 从 spu 表获取，可能与 k.spu_id 不一致
    k.sku_code
FROM cos_goods_sku k
LEFT JOIN cos_goods_spu spu ON k.spu_code = spu.spu_code
```

**问题**：按 `spu_code` 关联可能匹配到错误的 `spu_id`，与 `cos_goods_sku.spu_id` 不一致。

## 修复方案

### 核心原则
1. **确保 sku_id 和 spu_id 来自同一行** `cos_goods_sku` 记录
2. **使用窗口函数代替聚合函数**，明确记录选择优先级
3. **不对 id 做 MIN/MAX 聚合**，直接使用 `cos_goods_sku.id` 作为 `sku_id`
4. **保持数据来源一致性**，`spu_id` 直接从选中的 `cos_goods_sku` 行获取

### 实现方案

#### 1. 表结构设计
```sql
CREATE TABLE `cos_goods_sku_params` (
  -- ... 其他字段
  `spu_id` bigint COMMENT 'SPU ID - 必须与 sku_id 对应的 cos_goods_sku.spu_id 一致',
  `sku_id` bigint COMMENT 'SKU ID - 对应 cos_goods_sku.id',
  `monitor_date` date NOT NULL COMMENT '监控日期',
  `deleted` smallint DEFAULT '0',
  UNIQUE KEY `uk_sku_monitor` (`company_id`, `shop_id`, `sku_id`, `monitor_date`, `deleted`)
)
```

**关键点**：
- 唯一键使用 `sku_id`（即 `cos_goods_sku.id`）而不是 `sku_code`
- 确保同一 SKU 记录在同一监控日期只有一条快照

#### 2. 窗口函数选择策略
```sql
SELECT 
    k.id AS sku_id,      -- 直接使用 cos_goods_sku.id
    k.spu_id,            -- 直接使用 cos_goods_sku.spu_id
    k.sku_code,
    ROW_NUMBER() OVER (
        PARTITION BY k.company_id, k.shop_id, k.sku_code
        ORDER BY 
            k.is_delete ASC,      -- 优先未删除
            k.sync_date DESC,     -- 最新同步
            k.create_time DESC,   -- 最新创建
            k.id DESC             -- 最大 ID
    ) AS rn
FROM cos_goods_sku k
WHERE rn = 1  -- 只取优先级最高的记录
```

**优先级规则**：
1. 未删除的记录优先（`is_delete = 0`）
2. 最近同步的记录优先（`sync_date DESC`）
3. 最新创建的记录优先（`create_time DESC`）
4. 最大 ID 优先（`id DESC`）

#### 3. 关联 SPU 表补充信息
```sql
LEFT JOIN cos_goods_spu spu 
    ON base.spu_id = spu.id  -- 用 spu_id 关联，不是 spu_code
    AND spu.is_delete = 0
```

**关键点**：
- 使用 `spu_id` 关联，不使用 `spu_code`
- 只用于补充 `spu_code` 等信息，不改变 `spu_id`

#### 4. 幂等性保证
```sql
REPLACE INTO cos_goods_sku_params (...)
```

使用 `REPLACE INTO` 确保重复执行不会产生重复记录。

## 验证方法

### 1. 检测多 SPU 映射
```sql
-- 检查同一 sku_code 是否对应多个 spu_id
SELECT company_id, shop_id, sku_code, 
       COUNT(DISTINCT spu_id) AS spu_count
FROM cos_goods_sku
WHERE is_delete = 0
GROUP BY company_id, shop_id, sku_code
HAVING spu_count > 1;
```

### 2. 验证数据一致性
```sql
-- 检查 params 表与主表的一致性
SELECT p.*, k.spu_id AS actual_spu_id
FROM cos_goods_sku_params p
LEFT JOIN cos_goods_sku k ON p.sku_id = k.id
WHERE p.spu_id != k.spu_id OR k.id IS NULL;
```

### 3. 检查重复记录
```sql
-- 确保没有违反唯一键约束
SELECT company_id, shop_id, sku_id, monitor_date, deleted, COUNT(*)
FROM cos_goods_sku_params
GROUP BY company_id, shop_id, sku_id, monitor_date, deleted
HAVING COUNT(*) > 1;
```

## 使用方法

```sql
-- 导入表和存储过程
source cos_goods_sku_params_procedure.sql;

-- 同步昨天的数据（默认）
CALL sp_sync_cos_goods_sku_params_daily(NULL);

-- 同步指定日期
CALL sp_sync_cos_goods_sku_params_daily('2024-01-15');

-- 验证数据一致性
-- 执行文件中的验证查询
```

## 风险评估

### 低风险
- 新建表和存储过程，不影响现有功能
- 使用 `REPLACE INTO` 保证幂等性
- 包含完整的验证查询

### 注意事项
1. **历史数据处理**：首次执行可能需要同步历史日期的数据
2. **性能考虑**：窗口函数在大数据量时可能较慢，建议：
   - 在 `cos_goods_sku` 表的 `(company_id, shop_id, sku_code, is_delete, sync_date, create_time, id)` 上创建复合索引
   - 按批次同步数据
3. **数据质量**：如果 `cos_goods_sku` 本身存在同一 `sku_code` 映射多个 `spu_id` 的情况，需要先清理主数据

## 测试建议

1. **单元测试**：
   - 测试单条记录同步
   - 测试多条记录（同一 sku_code 多个版本）同步
   - 测试软删除记录处理

2. **集成测试**：
   - 模拟存在重复 sku_code 的场景
   - 验证幂等性（多次执行相同日期）
   - 验证数据一致性

3. **性能测试**：
   - 测试大数据量同步（如 10万+ 记录）
   - 监控执行时间和资源消耗

## 后续优化建议

1. **添加执行日志表**：记录每次同步的执行情况、耗时、记录数等
2. **异常处理**：添加 DECLARE ... HANDLER 处理异常情况
3. **增量同步**：考虑只同步变更的记录，提高效率
4. **监控告警**：当发现数据不一致时发送告警

## 文件清单

- `cos_goods_sku_params_procedure.sql`：表定义、存储过程和验证查询
- `FIX_GUIDE.md`：本文档
