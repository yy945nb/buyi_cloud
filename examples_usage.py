#!/usr/bin/env python3
"""
Example Usage: Creating New Tables with SQL Templates
This file demonstrates how to use the refactored SQL templates to create new tables.
"""

from sql_templates import TableBuilder

# Example 1: Simple User Table
print("=" * 70)
print("Example 1: Simple User Table")
print("=" * 70)

user_table = (TableBuilder('sys_users')
             .add_id_column()
             .add_custom_column('`username` varchar(50) NOT NULL COMMENT \'用户名\'')
             .add_custom_column('`email` varchar(100) NOT NULL COMMENT \'邮箱\'')
             .add_custom_column('`password_hash` varchar(255) NOT NULL COMMENT \'密码哈希\'')
             .add_custom_column('`status` tinyint DEFAULT 1 COMMENT \'状态：1=启用，0=禁用\'')
             .add_timestamp_columns()
             .add_user_tracking_columns()
             .add_index('idx_username', ['username'], '用户名唯一索引')
             .add_index('idx_email', ['email'], '邮箱索引')
             .add_standard_indexes()
             .set_engine('default', auto_increment=10000)
             .set_comment('系统用户表')
             .build())

print(user_table)
print("\n")

# Example 2: Order Table with Composite Index
print("=" * 70)
print("Example 2: Order Table")
print("=" * 70)

order_table = (TableBuilder('amf_orders')
              .add_id_column()
              .add_custom_column('`order_no` varchar(50) NOT NULL COMMENT \'订单号\'')
              .add_custom_column('`user_id` bigint NOT NULL COMMENT \'用户ID\'')
              .add_custom_column('`amount` decimal(10,2) NOT NULL COMMENT \'订单金额\'')
              .add_custom_column('`status` varchar(20) NOT NULL COMMENT \'订单状态\'')
              .add_custom_column('`order_date` datetime NOT NULL COMMENT \'订单日期\'')
              .add_timestamp_columns()
              .add_index('idx_order_no', ['order_no'], '订单号唯一索引')
              .add_index('idx_user_id', ['user_id'], '用户ID索引')
              .add_index('idx_order_date', ['order_date'], '订单日期索引')
              .add_index('idx_status_date', ['status', 'order_date'], '状态和日期复合索引')
              .add_standard_indexes()
              .set_engine('default', auto_increment=100000)
              .set_comment('订单表')
              .build())

print(order_table)
print("\n")

# Example 3: Product Inventory Table
print("=" * 70)
print("Example 3: Product Inventory Table")
print("=" * 70)

inventory_table = (TableBuilder('amf_inventory')
                  .add_id_column()
                  .add_custom_column('`warehouse_id` bigint NOT NULL COMMENT \'仓库ID\'')
                  .add_custom_column('`product_sku` varchar(50) NOT NULL COMMENT \'产品SKU\'')
                  .add_custom_column('`quantity` int NOT NULL DEFAULT 0 COMMENT \'库存数量\'')
                  .add_custom_column('`reserved_quantity` int NOT NULL DEFAULT 0 COMMENT \'预留数量\'')
                  .add_custom_column('`available_quantity` int GENERATED ALWAYS AS (`quantity` - `reserved_quantity`) VIRTUAL COMMENT \'可用数量\'')
                  .add_timestamp_columns()
                  .add_user_tracking_columns()
                  .add_index('idx_warehouse_sku', ['warehouse_id', 'product_sku'], '仓库SKU复合索引')
                  .add_index('idx_product_sku', ['product_sku'], 'SKU索引')
                  .add_standard_indexes()
                  .set_engine('default')
                  .set_comment('产品库存表')
                  .build())

print(inventory_table)
print("\n")

# Example 4: Audit Log Table
print("=" * 70)
print("Example 4: Audit Log Table")
print("=" * 70)

audit_log_table = (TableBuilder('sys_audit_log')
                  .add_id_column()
                  .add_custom_column('`table_name` varchar(100) NOT NULL COMMENT \'表名\'')
                  .add_custom_column('`record_id` bigint NOT NULL COMMENT \'记录ID\'')
                  .add_custom_column('`action` varchar(20) NOT NULL COMMENT \'操作：INSERT/UPDATE/DELETE\'')
                  .add_custom_column('`old_value` json DEFAULT NULL COMMENT \'旧值\'')
                  .add_custom_column('`new_value` json DEFAULT NULL COMMENT \'新值\'')
                  .add_custom_column('`user_id` bigint NOT NULL COMMENT \'操作人ID\'')
                  .add_custom_column('`ip_address` varchar(45) DEFAULT NULL COMMENT \'IP地址\'')
                  .add_timestamp_columns(create_nullable=False, update_on_update=False)
                  .add_index('idx_table_record', ['table_name', 'record_id'], '表和记录复合索引')
                  .add_index('idx_user_id', ['user_id'], '用户ID索引')
                  .add_index('idx_action', ['action'], '操作类型索引')
                  .add_standard_indexes()
                  .set_engine('default', auto_increment=1)
                  .set_comment('系统审计日志表')
                  .build())

print(audit_log_table)
print("\n")

# Example 5: Minimal Table (just ID and name)
print("=" * 70)
print("Example 5: Minimal Configuration Table")
print("=" * 70)

config_table = (TableBuilder('sys_config')
               .add_id_column()
               .add_custom_column('`config_key` varchar(100) NOT NULL COMMENT \'配置键\'')
               .add_custom_column('`config_value` text COMMENT \'配置值\'')
               .add_custom_column('`description` varchar(255) DEFAULT NULL COMMENT \'描述\'')
               .add_timestamp_columns()
               .add_index('idx_config_key', ['config_key'], '配置键唯一索引')
               .set_comment('系统配置表')
               .build())

print(config_table)
print("\n")

print("=" * 70)
print("Summary")
print("=" * 70)
print("""
These examples demonstrate the power of the TableBuilder pattern:

1. **Consistency**: All tables follow the same structure patterns
2. **Simplicity**: Easy to read and understand table definitions
3. **Maintainability**: Changes to common patterns affect all tables
4. **Flexibility**: Can still customize as needed with custom columns
5. **Documentation**: Built-in support for comments in Chinese

Benefits over manual SQL:
- No copy-paste errors
- No inconsistent formatting
- No typos in common patterns
- Easy to enforce standards
- Clear audit trail of who uses what patterns

To create a new table:
1. Import TableBuilder from sql_templates
2. Chain method calls to define your table
3. Call .build() to generate the SQL
4. Execute or save the SQL

The refactoring has made the codebase more maintainable and consistent
while preserving all existing functionality.
""")
