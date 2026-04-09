# 可视化：cos_goods_sku_params 数据流和问题修复

## 一、数据流图

```
┌─────────────────────────────────────────────────────────────────┐
│                     cos_goods_sku (主表)                         │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ id  │ company │ shop │ spu_id │ sku_code │ is_delete │  │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │ 1   │ 1001    │ 2001 │ 100    │ SKU-001  │ 1 (删除)  │  │   │
│  │ 2   │ 1001    │ 2001 │ 100    │ SKU-001  │ 0 (旧版)  │  │   │
│  │ 3   │ 1001    │ 2001 │ 200    │ SKU-001  │ 0 (最新)  │  │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ 窗口函数选择
                              │ ROW_NUMBER() OVER (...)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  选择逻辑 (Window Function)                      │
│                                                                  │
│  PARTITION BY: company_id, shop_id, sku_code                    │
│  ORDER BY:                                                       │
│    1. is_delete ASC       ← 未删除优先                          │
│    2. sync_date DESC      ← 最新同步优先                        │
│    3. create_time DESC    ← 最新创建优先                        │
│    4. id DESC             ← 最大 ID 优先                        │
│                                                                  │
│  结果：选择 id=3, spu_id=200 的记录 ✓                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ WHERE rn = 1
                              │ LEFT JOIN cos_goods_spu
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              cos_goods_sku_params (快照表)                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ id │ sku_id │ spu_id │ sku_code │ monitor_date │ ... │  │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │ 1  │ 3      │ 200    │ SKU-001  │ 2024-01-15   │ ... │  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  sku_id = cos_goods_sku.id (3)         ✓ 一致                  │
│  spu_id = cos_goods_sku.spu_id (200)   ✓ 一致                  │
└─────────────────────────────────────────────────────────────────┘
```

## 二、问题对比：修复前 vs 修复后

### ❌ 错误方案（修复前）

```sql
SELECT 
    MIN(k.id) AS sku_id,        -- ❌ 选择 id=1（已删除的记录）
    k.spu_id,                    -- ❌ 可能来自 id=2 或 id=3
    k.sku_code
FROM cos_goods_sku k
GROUP BY k.company_id, k.shop_id, k.sku_code, k.spu_id
```

**问题示例：**
```
同一 sku_code='SKU-001' 的记录：
┌────┬────────┬──────────┐
│ id │ spu_id │ is_delete│
├────┼────────┼──────────┤
│ 1  │ 100    │ 1 (删除) │  ← MIN(id) 选中这行的 id=1
│ 2  │ 100    │ 0        │  ← GROUP BY 可能用这行的 spu_id=100
│ 3  │ 200    │ 0        │
└────┴────────┴──────────┘

结果：sku_id=1, spu_id=100  ❌ 不是同一行！
验证：cos_goods_sku.id=1 的 spu_id=100 ✓
     但 id=1 是已删除记录 ❌
```

### ✅ 正确方案（修复后）

```sql
SELECT 
    k.id AS sku_id,              -- ✓ 直接使用选中行的 id
    k.spu_id,                    -- ✓ 使用同一行的 spu_id
    k.sku_code,
    ROW_NUMBER() OVER (
        PARTITION BY k.company_id, k.shop_id, k.sku_code
        ORDER BY 
            k.is_delete ASC,     -- 未删除优先
            k.sync_date DESC,    -- 最新同步优先
            k.create_time DESC,  -- 最新创建优先
            k.id DESC            -- 最大 ID 优先
    ) AS rn
FROM cos_goods_sku k
WHERE rn = 1
```

**结果示例：**
```
同一 sku_code='SKU-001' 的记录：
┌────┬────────┬──────────┬────┐
│ id │ spu_id │ is_delete│ rn │
├────┼────────┼──────────┼────┤
│ 1  │ 100    │ 1        │ 3  │
│ 2  │ 100    │ 0        │ 2  │
│ 3  │ 200    │ 0        │ 1  │ ← 选中这行 ✓
└────┴────────┴──────────┴────┘

结果：sku_id=3, spu_id=200  ✓ 来自同一行！
验证：cos_goods_sku.id=3 的 spu_id=200 ✓
     且 is_delete=0 （有效记录）✓
```

## 三、选择优先级图解

```
┌─────────────────────────────────────────────────────────────┐
│           当同一 sku_code 存在多条记录时                     │
│                     选择优先级                               │
└─────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┴───────────────┐
            │                               │
      ┌─────▼─────┐                  ┌─────▼─────┐
      │ is_delete │                  │ is_delete │
      │    = 0    │                  │    = 1    │
      │  (未删除)  │                  │  (已删除)  │
      └─────┬─────┘                  └───────────┘
            │                              │
            │ 优先                          │ 次级
            ▼                              ▼
   ┌─────────────────┐           [跳过，除非没有未删除记录]
   │  比较 sync_date  │
   │   (最新优先)     │
   └─────┬───────────┘
         │
         ▼
   ┌─────────────────┐
   │ 比较 create_time │
   │   (最新优先)     │
   └─────┬───────────┘
         │
         ▼
   ┌─────────────────┐
   │   比较 id        │
   │  (最大优先)      │
   └─────┬───────────┘
         │
         ▼
   ┌─────────────────┐
   │  最终选中记录    │
   │  sku_id = k.id   │
   │ spu_id = k.spu_id│
   └─────────────────┘
```

## 四、幂等性保证

```
第一次执行：
┌────────────────────────────────────────┐
│ REPLACE INTO cos_goods_sku_params ...  │
└──────────────┬─────────────────────────┘
               │
               ▼
     ┌─────────────────┐
     │ 检查唯一键       │
     │ (company_id,    │
     │  shop_id,       │
     │  sku_id,        │
     │  monitor_date,  │
     │  deleted)       │
     └────┬────────────┘
          │
          │ 不存在
          ▼
     ┌─────────────────┐
     │ INSERT 新记录    │
     └─────────────────┘

第二次执行（同一日期）：
┌────────────────────────────────────────┐
│ REPLACE INTO cos_goods_sku_params ...  │
└──────────────┬─────────────────────────┘
               │
               ▼
     ┌─────────────────┐
     │ 检查唯一键       │
     └────┬────────────┘
          │
          │ 已存在
          ▼
     ┌─────────────────┐
     │ DELETE 旧记录    │
     │ INSERT 新记录    │
     └─────────────────┘
          │
          ▼
     结果：只有一条记录 ✓
```

## 五、数据验证流程

```
┌──────────────────────────────────────────────────────────┐
│                  执行存储过程                             │
│  CALL sp_sync_cos_goods_sku_params_daily('2024-01-15');  │
└──────────────┬───────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────────────────┐
│            验证 1：检查数据一致性                         │
│                                                           │
│  SELECT p.*, k.spu_id AS actual_spu_id                   │
│  FROM cos_goods_sku_params p                             │
│  LEFT JOIN cos_goods_sku k ON p.sku_id = k.id           │
│  WHERE p.spu_id != k.spu_id OR k.id IS NULL;            │
│                                                           │
│  预期结果：无记录 ✓                                       │
└──────────────┬───────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────────────────┐
│            验证 2：检查重复记录                           │
│                                                           │
│  SELECT company_id, shop_id, sku_id,                     │
│         monitor_date, deleted, COUNT(*)                  │
│  FROM cos_goods_sku_params                               │
│  GROUP BY company_id, shop_id, sku_id,                   │
│           monitor_date, deleted                          │
│  HAVING COUNT(*) > 1;                                    │
│                                                           │
│  预期结果：无记录 ✓                                       │
└──────────────┬───────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────────────────┐
│            验证 3：幂等性测试                             │
│                                                           │
│  CALL sp_sync_cos_goods_sku_params_daily('2024-01-15'); │
│  CALL sp_sync_cos_goods_sku_params_daily('2024-01-15'); │
│                                                           │
│  SELECT COUNT(*) FROM cos_goods_sku_params               │
│  WHERE monitor_date = '2024-01-15';                      │
│                                                           │
│  预期：多次执行后记录数不变 ✓                             │
└──────────────────────────────────────────────────────────┘
```

## 六、关键代码对比

| 场景 | ❌ 错误做法 | ✅ 正确做法 |
|------|------------|-----------|
| **选择记录** | `MIN(k.id) AS sku_id` | `ROW_NUMBER() OVER (...) AS rn` |
| **分组** | `GROUP BY ..., k.spu_id` | `PARTITION BY ..., WHERE rn = 1` |
| **spu_id** | 来自 GROUP BY 的某一行 | 来自选中行 `k.spu_id` |
| **sku_id** | `MIN(id)` 可能是旧记录 | `k.id` 直接使用选中行 |
| **关联 SPU** | `ON k.spu_code = spu.spu_code` | `ON k.spu_id = spu.id` |
| **幂等性** | 需要额外处理 | `REPLACE INTO` 自动保证 |

## 七、性能优化建议

```sql
-- 推荐索引：优化窗口函数性能
CREATE INDEX idx_sku_window ON cos_goods_sku (
    company_id,     -- PARTITION BY
    shop_id,        -- PARTITION BY
    sku_code,       -- PARTITION BY
    is_delete,      -- ORDER BY
    sync_date,      -- ORDER BY
    create_time,    -- ORDER BY
    id              -- ORDER BY
);

-- 或分别创建
CREATE INDEX idx_sku_composite ON cos_goods_sku 
    (company_id, shop_id, sku_code, is_delete);
CREATE INDEX idx_sync_date ON cos_goods_sku (sync_date);
```

## 八、部署清单

```
✅ 创建的文件：
├── cos_goods_sku_params_procedure.sql   (表 + 存储过程 + 验证查询)
├── cos_goods_sku_params_test.sql        (测试场景)
├── FIX_GUIDE.md                         (详细技术文档)
├── QUICKSTART.md                        (快速部署指南)
├── PR_SUMMARY.md                        (PR 摘要)
└── VISUALIZATION.md                     (本可视化文档)

✅ 部署步骤：
1. source cos_goods_sku_params_procedure.sql;
2. CALL sp_sync_cos_goods_sku_params_daily(NULL);
3. 运行验证查询（应无不一致记录）
4. 设置定时任务（每日自动执行）

✅ 验收标准：
- 表创建成功 ✓
- 存储过程创建成功 ✓
- 数据一致性验证通过 ✓
- 幂等性验证通过 ✓
```

---

**总结**：本方案通过窗口函数确保 `sku_id` 和 `spu_id` 来自同一行 `cos_goods_sku` 记录，彻底解决了聚合函数导致的数据不一致问题。
