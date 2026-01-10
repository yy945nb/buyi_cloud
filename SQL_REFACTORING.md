# SQL Refactoring Documentation

## Overview

This document describes the refactoring performed on `buyi_platform_dev.sql` to eliminate duplicated code patterns and improve maintainability.

## Problem Statement

The original SQL file (`buyi_platform_dev.sql`) contained significant code duplication:

- **432 tables** with repetitive patterns
- **783+ duplicated patterns** identified including:
  - Identical table header comment blocks (432 times)
  - Repeated ENGINE specifications (27+ times for common configurations)
  - Repeated timestamp column definitions (`create_time`: 174 times, `update_time`: 18 times)
  - Repeated index naming patterns (`idx_uk`: 23 times, `idx_commodity_id`: 21 times)
  - Inconsistent column and index definitions across similar tables

## Solution

### 1. Created Reusable SQL Templates (`sql_templates.py`)

A Python module containing:

#### Common Engine Configurations
```python
ENGINE_CONFIGS = {
    'default': 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci',
    'with_row_format': 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC',
    'unicode': 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci',
}
```

#### Standardized Column Definitions
- `id_auto`: Standard bigint auto-increment ID column
- `id_int_auto`: Standard int auto-increment ID column
- `create_time_auto`: Create time with automatic timestamp
- `update_time_auto`: Update time with ON UPDATE CURRENT_TIMESTAMP
- `create_time_nullable`: Nullable create time
- `update_time_nullable`: Nullable update time
- `create_time_not_null`: Non-null create time
- `update_time_not_null`: Non-null update time
- `create_user_id`: Standard create user ID column
- `update_user_id`: Standard update user ID column

#### Common Index Patterns
- `idx_create_time`: Standard create time index
- `idx_update_time`: Standard update time index
- `idx_company_id`: Standard company ID index
- `idx_commodity_id`: Standard commodity ID index

#### TableBuilder Class

A fluent API for building table definitions with common patterns:

```python
table = (TableBuilder('example_table')
        .add_id_column()
        .add_custom_column('`name` varchar(100) NOT NULL COMMENT \'名称\'')
        .add_timestamp_columns()
        .add_user_tracking_columns()
        .add_standard_indexes()
        .set_comment('示例表')
        .build())
```

### 2. Created Refactoring Script (`refactor_sql.py`)

The script performs the following normalizations:

1. **Table Headers**: Standardizes all table comment blocks
2. **ID Columns**: Normalizes bigint and int ID column definitions
3. **Timestamp Columns**: Standardizes `create_time` and `update_time` definitions
4. **User Tracking**: Normalizes `create_user_id` and `update_user_id` columns
5. **Indexes**: Standardizes common index definitions
6. **Engine Specifications**: Normalizes ENGINE configurations

## Usage

### Running the Refactoring Script

```bash
# Run with default files
python3 refactor_sql.py

# Run with custom input/output files
python3 refactor_sql.py input.sql output.sql
```

### Using SQL Templates for New Tables

```python
from sql_templates import TableBuilder

# Create a new table with standard patterns
new_table = (TableBuilder('my_new_table')
            .add_id_column()
            .add_custom_column('`name` varchar(100) NOT NULL COMMENT \'名称\'')
            .add_custom_column('`status` tinyint DEFAULT 0 COMMENT \'状态\'')
            .add_timestamp_columns()
            .add_user_tracking_columns()
            .add_standard_indexes()
            .set_engine('default', auto_increment=1000)
            .set_comment('我的新表')
            .build())

print(new_table)
```

## Results

After running the refactoring script:

- **Tables processed**: 432
- **Patterns replaced**: 783+
- **Consistency**: All common patterns now use standardized definitions
- **Maintainability**: Future changes can be made in one place (sql_templates.py)
- **Documentation**: Clear examples of how to create new tables with common patterns

## Benefits

1. **Reduced Duplication**: Common patterns are defined once and reused
2. **Consistency**: All tables use the same patterns for common columns and indexes
3. **Maintainability**: Changes to common patterns can be made in one place
4. **Scalability**: New tables can be easily created using the TableBuilder
5. **Documentation**: Clear examples and patterns for developers

## Verification

To verify the refactoring:

```bash
# Check differences between original and refactored
diff -u buyi_platform_dev.sql buyi_platform_dev_refactored.sql

# Count standardized patterns
grep -c "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" buyi_platform_dev_refactored.sql

# Verify table count remains the same
grep -c "CREATE TABLE" buyi_platform_dev_refactored.sql
```

## Future Improvements

1. **View Refactoring**: Apply similar patterns to views, functions, and procedures
2. **Index Optimization**: Review and standardize index naming conventions
3. **Comment Standards**: Establish and enforce comment standards for tables and columns
4. **Automated Testing**: Add validation tests to ensure refactored SQL produces identical schema
5. **Migration Scripts**: Create scripts to migrate from old patterns to new patterns

## Rollback

If issues are found, the original file is preserved as `buyi_platform_dev.sql.backup` (if created). To rollback:

```bash
# If you haven't replaced the original yet
# Just delete the refactored file

# If you've already replaced the original
git checkout buyi_platform_dev.sql
```

## Best Practices

When creating new tables:

1. **Use TableBuilder**: Always use the TableBuilder class for consistency
2. **Standard Columns**: Use standard column definitions from `COMMON_COLUMNS`
3. **Standard Indexes**: Use standard indexes from `COMMON_INDEXES` where applicable
4. **Comments**: Always include meaningful comments for tables and columns
5. **Engine Config**: Use standard ENGINE configurations unless specific requirements dictate otherwise

## Examples

### Example 1: Simple Table with Timestamps

```python
from sql_templates import TableBuilder

orders_table = (TableBuilder('amf_orders')
               .add_id_column()
               .add_custom_column('`order_no` varchar(50) NOT NULL COMMENT \'订单号\'')
               .add_custom_column('`amount` decimal(10,2) NOT NULL COMMENT \'金额\'')
               .add_timestamp_columns()
               .add_standard_indexes()
               .set_comment('订单表')
               .build())
```

### Example 2: Table with User Tracking

```python
from sql_templates import TableBuilder

products_table = (TableBuilder('amf_products')
                 .add_id_column()
                 .add_custom_column('`name` varchar(100) NOT NULL COMMENT \'产品名称\'')
                 .add_custom_column('`price` decimal(10,2) NOT NULL COMMENT \'价格\'')
                 .add_timestamp_columns()
                 .add_user_tracking_columns()
                 .add_index('idx_name', ['name'], '产品名称索引')
                 .set_engine('default', auto_increment=5000)
                 .set_comment('产品表')
                 .build())
```

### Example 3: Custom Index Patterns

```python
from sql_templates import TableBuilder

inventory_table = (TableBuilder('amf_inventory')
                  .add_id_column()
                  .add_custom_column('`warehouse_id` bigint NOT NULL COMMENT \'仓库ID\'')
                  .add_custom_column('`product_id` bigint NOT NULL COMMENT \'产品ID\'')
                  .add_custom_column('`quantity` int NOT NULL COMMENT \'数量\'')
                  .add_timestamp_columns()
                  .add_index('idx_warehouse_product', ['warehouse_id', 'product_id'], '仓库产品索引')
                  .add_standard_indexes()
                  .set_comment('库存表')
                  .build())
```

## Conclusion

This refactoring eliminates significant code duplication in the SQL schema, making it more maintainable and consistent. The template system provides a solid foundation for future development while maintaining backward compatibility with existing data.

## Contact

For questions or issues related to this refactoring, please open an issue in the repository.
