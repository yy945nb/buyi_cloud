# 快速开始指南 - sp_sync_cos_goods_sku_params_daily

## 📋 快速概览

这是一个MySQL存储过程，用于同步商品SKU的销量和库存参数。

**核心功能**: 
- ✅ 支持 JH/FBA/MP 三种店铺类型
- ✅ 加权日均销量计算
- ✅ 自动库存同步
- ✅ 幂等性设计

## 🚀 快速部署

### 1. 创建存储过程

```bash
mysql -u username -p database_name < sp_sync_cos_goods_sku_params_daily.sql
```

### 2. 执行同步

```sql
-- 使用当前日期
CALL sp_sync_cos_goods_sku_params_daily(NULL);

-- 或指定日期
CALL sp_sync_cos_goods_sku_params_daily('2026-02-01');
```

### 3. 验证结果

```sql
SELECT * FROM cos_goods_sku_params 
WHERE monitor_date = CURDATE() 
AND deleted = 0 
LIMIT 10;
```

## 📊 关键数据说明

### 店铺类型映射
| 类型 | 源表 | 目标表 | 映射字段 |
|------|------|--------|---------|
| JH | amf_jh_shop | cos_shop | id → platform_shop_id |
| FBA | amf_lx_shop | cos_shop | store_id → external_id |
| MP | amf_lx_mporders | cos_shop | store_id → external_id |

### 销量日期字段
| 类型 | 日期字段 | 说明 |
|------|---------|------|
| JH | delivery_time | 发货时间 |
| FBA | shipment_date_utc | UTC发货时间 |
| MP | global_create_time | 全局创建时间 |

### 日均销量公式
```
日均销量 = (7天销量/7) × 0.5 + (15天销量/15) × 0.3 + (30天销量/30) × 0.2
```

## 🔍 常用查询

### 查看今日同步数据
```sql
SELECT 
    shop_id,
    COUNT(*) AS sku_count,
    SUM(platform_inventory) AS total_inventory,
    AVG(daily_avg_sales) AS avg_sales
FROM cos_goods_sku_params
WHERE monitor_date = CURDATE() AND deleted = 0
GROUP BY shop_id;
```

### 查看特定SKU的销量趋势
```sql
SELECT 
    monitor_date,
    sales_7d,
    sales_15d,
    sales_30d,
    daily_avg_sales,
    platform_inventory
FROM cos_goods_sku_params
WHERE sku_id = 'YOUR_SKU_ID' 
    AND deleted = 0
ORDER BY monitor_date DESC
LIMIT 30;
```

## ⚙️ 定时任务设置

### 使用MySQL Event
```sql
CREATE EVENT evt_sync_daily
ON SCHEDULE EVERY 1 DAY
STARTS CONCAT(CURDATE() + INTERVAL 1 DAY, ' 02:00:00')
DO CALL sp_sync_cos_goods_sku_params_daily(NULL);
```

### 使用Cron
```bash
# 每天凌晨2点执行
0 2 * * * /usr/bin/mysql -u user -p'pass' db_name -e "CALL sp_sync_cos_goods_sku_params_daily(NULL);"
```

## 📚 文档索引

1. **sp_sync_cos_goods_sku_params_daily.sql** - 存储过程源代码
2. **SP_SYNC_COS_GOODS_SKU_PARAMS_DAILY_README.md** - 详细文档
3. **IMPLEMENTATION_SUMMARY_SP_SYNC.md** - 实现总结
4. **validate_stored_procedure.sh** - 验证脚本

## 🆘 故障排查

### 问题：店铺映射失败
```sql
-- 检查映射关系
SELECT COUNT(*) FROM amf_jh_shop jh
INNER JOIN cos_shop cs ON jh.id = cs.platform_shop_id;

SELECT COUNT(*) FROM amf_lx_shop lx
INNER JOIN cos_shop cs ON lx.store_id = cs.external_id;
```

### 问题：销量数据为0
```sql
-- 检查订单数据
SELECT COUNT(*) FROM amf_jh_orders
WHERE order_status = 'FH'
    AND delivery_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);
```

### 问题：执行失败
```bash
# 检查语法
./validate_stored_procedure.sh

# 查看MySQL错误日志
tail -f /var/log/mysql/error.log
```

## 💡 最佳实践

1. **首次执行**: 先在测试环境验证
2. **历史数据**: 可以指定日期重新计算历史数据
3. **性能监控**: 记录每次执行的耗时
4. **数据备份**: 定期备份 cos_goods_sku_params 表
5. **定期检查**: 每周检查数据质量和完整性

## 📞 技术支持

遇到问题请参考详细文档或联系技术团队。

---

**版本**: v1.0  
**更新日期**: 2026-02-02  
**维护团队**: Buyi Cloud Development Team
