#!/bin/bash
# ============================================================
# 脚本名称: validate_stored_procedure.sh
# 功能: 验证存储过程的SQL语法
# 用法: ./validate_stored_procedure.sh
# ============================================================

set -e

echo "======================================================"
echo "验证存储过程: sp_sync_cos_goods_sku_params_daily"
echo "======================================================"
echo ""

SQL_FILE="sp_sync_cos_goods_sku_params_daily.sql"

# 检查SQL文件是否存在
if [ ! -f "$SQL_FILE" ]; then
    echo "❌ 错误: 找不到文件 $SQL_FILE"
    exit 1
fi

echo "✓ SQL文件存在: $SQL_FILE"

# 检查基本语法结构
echo ""
echo "检查SQL语法结构..."

# 检查DELIMITER
if grep -q "DELIMITER" "$SQL_FILE"; then
    echo "✓ DELIMITER 声明正确"
else
    echo "❌ 缺少 DELIMITER 声明"
    exit 1
fi

# 检查DROP PROCEDURE
if grep -q "DROP PROCEDURE IF EXISTS" "$SQL_FILE"; then
    echo "✓ DROP PROCEDURE 语句存在"
else
    echo "❌ 缺少 DROP PROCEDURE 语句"
    exit 1
fi

# 检查CREATE PROCEDURE
if grep -q "CREATE PROCEDURE \`sp_sync_cos_goods_sku_params_daily\`" "$SQL_FILE"; then
    echo "✓ CREATE PROCEDURE 语句正确"
else
    echo "❌ CREATE PROCEDURE 语句有误"
    exit 1
fi

# 检查BEGIN/END对
BEGIN_COUNT=$(grep -c "BEGIN" "$SQL_FILE")
END_COUNT=$(grep -c "END" "$SQL_FILE")
if [ "$BEGIN_COUNT" -eq "$END_COUNT" ]; then
    echo "✓ BEGIN/END 配对正确 (各$BEGIN_COUNT个)"
else
    echo "⚠ BEGIN/END 可能不匹配 (BEGIN:$BEGIN_COUNT, END:$END_COUNT)"
fi

# 检查事务处理
if grep -q "START TRANSACTION" "$SQL_FILE"; then
    echo "✓ 包含事务开始语句"
else
    echo "⚠ 未找到 START TRANSACTION"
fi

if grep -q "COMMIT" "$SQL_FILE"; then
    echo "✓ 包含事务提交语句"
else
    echo "⚠ 未找到 COMMIT"
fi

# 检查临时表清理
TEMP_TABLES=(
    "tmp_jh_shop_mapping"
    "tmp_fba_shop_mapping"
    "tmp_mp_shop_mapping"
    "tmp_jh_sales"
    "tmp_fba_sales"
    "tmp_mp_sales"
    "tmp_fba_inventory"
    "tmp_jh_inventory"
)

echo ""
echo "检查临时表管理..."
for table in "${TEMP_TABLES[@]}"; do
    CREATE_COUNT=$(grep -c "CREATE TEMPORARY TABLE $table" "$SQL_FILE")
    DROP_COUNT=$(grep -c "DROP TEMPORARY TABLE IF EXISTS $table" "$SQL_FILE")
    
    if [ "$CREATE_COUNT" -eq 1 ] && [ "$DROP_COUNT" -ge 1 ]; then
        echo "✓ 临时表 $table 管理正确"
    else
        echo "⚠ 临时表 $table 可能管理不当 (CREATE:$CREATE_COUNT, DROP:$DROP_COUNT)"
    fi
done

# 检查关键功能点
echo ""
echo "检查关键功能..."

if grep -q "日均销量 = (7天销量/7) × 0.5 + (15天销量/15) × 0.3 + (30天销量/30) × 0.2" "$SQL_FILE"; then
    echo "✓ 包含加权销量公式说明"
fi

if grep -q "INSERT INTO cos_goods_sku_params" "$SQL_FILE"; then
    echo "✓ 包含数据插入语句"
fi

if grep -q "ON DUPLICATE KEY UPDATE" "$SQL_FILE"; then
    echo "✓ 实现UPSERT模式"
fi

# 检查注释完整性
COMMENT_COUNT=$(grep -c "^[[:space:]]*--" "$SQL_FILE")
echo ""
echo "✓ 包含 $COMMENT_COUNT 行注释"

# 统计代码行数
TOTAL_LINES=$(wc -l < "$SQL_FILE")
echo "✓ 总行数: $TOTAL_LINES"

echo ""
echo "======================================================"
echo "✓ 基本语法验证通过！"
echo "======================================================"
echo ""
echo "注意: 此脚本仅进行基本的语法结构检查"
echo "建议在实际数据库环境中进行完整测试"
echo ""
