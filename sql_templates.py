"""
SQL Templates and Common Patterns
This module contains reusable SQL patterns to eliminate code duplication.
"""

# Common ENGINE specifications
ENGINE_CONFIGS = {
    'default': 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci',
    'with_row_format': 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC',
    'unicode': 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci',
}

# Common column definitions
COMMON_COLUMNS = {
    'id_auto': '`id` bigint NOT NULL AUTO_INCREMENT',
    'id_int_auto': '`id` int NOT NULL AUTO_INCREMENT',
    'create_time_auto': '`create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT \'创建时间\'',
    'update_time_auto': '`update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT \'更新时间\'',
    'create_time_nullable': '`create_time` datetime DEFAULT NULL COMMENT \'创建时间\'',
    'update_time_nullable': '`update_time` datetime DEFAULT NULL COMMENT \'更新时间\'',
    'create_time_not_null': '`create_time` datetime NOT NULL COMMENT \'创建时间\'',
    'update_time_not_null': '`update_time` datetime NOT NULL COMMENT \'更新时间\'',
    'update_time_on_update': '`update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT \'修改时间\'',
    'create_user_id': '`create_user_id` bigint DEFAULT NULL COMMENT \'创建人ID\'',
    'update_user_id': '`update_user_id` bigint DEFAULT NULL COMMENT \'更新人ID\'',
}

# Common index patterns
COMMON_INDEXES = {
    'idx_create_time': 'KEY `idx_create_time` (`create_time`) COMMENT \'创建时间索引\'',
    'idx_update_time': 'KEY `idx_update_time` (`update_time`) COMMENT \'更新时间索引\'',
    'idx_company_id': 'KEY `idx_company_id` (`company_id`)',
    'idx_commodity_id': 'KEY `idx_commodity_id` (`commodity_id`)',
}

# Common primary key patterns
PRIMARY_KEYS = {
    'id': 'PRIMARY KEY (`id`)',
    'id_composite': 'PRIMARY KEY (`id`,`{column}`)',
}

def generate_table_header(table_name: str) -> str:
    """Generate standardized table header with comments."""
    return f"""-- ----------------------------
-- Table structure for {table_name}
-- ----------------------------
DROP TABLE IF EXISTS `{table_name}`;"""

def generate_table_footer(table_name: str, engine_type: str = 'default', 
                         auto_increment: int = None, comment: str = None) -> str:
    """Generate standardized table footer with ENGINE specification."""
    engine = ENGINE_CONFIGS.get(engine_type, ENGINE_CONFIGS['default'])
    
    if auto_increment:
        engine = engine.replace('ENGINE=InnoDB', f'ENGINE=InnoDB AUTO_INCREMENT={auto_increment}')
    
    if comment:
        engine += f" COMMENT='{comment}'"
    
    return f") {engine};"

def generate_timestamp_columns(create_nullable: bool = False, 
                              update_on_update: bool = True) -> str:
    """Generate standardized timestamp columns."""
    if create_nullable:
        create_col = COMMON_COLUMNS['create_time_nullable']
    else:
        create_col = COMMON_COLUMNS['create_time_auto']
    
    if update_on_update:
        update_col = COMMON_COLUMNS['update_time_auto']
    else:
        update_col = COMMON_COLUMNS['update_time_nullable']
    
    return f"  {create_col},\n  {update_col}"

def generate_user_tracking_columns() -> str:
    """Generate standardized user tracking columns."""
    return f"""  {COMMON_COLUMNS['create_user_id']},
  {COMMON_COLUMNS['update_user_id']}"""

def generate_standard_indexes(include_timestamps: bool = True) -> str:
    """Generate standard indexes for common columns."""
    indexes = []
    if include_timestamps:
        indexes.append(COMMON_INDEXES['idx_create_time'])
    return ',\n  '.join(indexes) if indexes else ''


class TableBuilder:
    """Builder class for constructing SQL table definitions with common patterns."""
    
    def __init__(self, table_name: str):
        self.table_name = table_name
        self.columns = []
        self.indexes = []
        self.primary_key = None
        self.engine_type = 'default'
        self.auto_increment = None
        self.comment = None
    
    def add_id_column(self, column_type: str = 'bigint', auto_increment: bool = True):
        """Add standard ID column."""
        if column_type == 'int':
            self.columns.append(COMMON_COLUMNS['id_int_auto'])
        else:
            self.columns.append(COMMON_COLUMNS['id_auto'])
        
        if auto_increment:
            self.primary_key = PRIMARY_KEYS['id']
        return self
    
    def add_timestamp_columns(self, create_nullable: bool = False, 
                            update_on_update: bool = True):
        """Add standard timestamp columns."""
        if create_nullable:
            self.columns.append(COMMON_COLUMNS['create_time_nullable'])
        else:
            self.columns.append(COMMON_COLUMNS['create_time_auto'])
        
        if update_on_update:
            self.columns.append(COMMON_COLUMNS['update_time_auto'])
        else:
            self.columns.append(COMMON_COLUMNS['update_time_nullable'])
        return self
    
    def add_user_tracking_columns(self):
        """Add standard user tracking columns."""
        self.columns.append(COMMON_COLUMNS['create_user_id'])
        self.columns.append(COMMON_COLUMNS['update_user_id'])
        return self
    
    def add_custom_column(self, column_def: str):
        """Add a custom column definition."""
        self.columns.append(f"  {column_def}")
        return self
    
    def add_index(self, index_name: str, columns: list, comment: str = None):
        """Add an index."""
        cols = ', '.join([f'`{col}`' for col in columns])
        index_def = f"  KEY `{index_name}` ({cols})"
        if comment:
            index_def += f" COMMENT '{comment}'"
        self.indexes.append(index_def)
        return self
    
    def add_standard_indexes(self, include_timestamps: bool = True):
        """Add standard indexes."""
        if include_timestamps:
            self.indexes.append(f"  {COMMON_INDEXES['idx_create_time']}")
        return self
    
    def set_engine(self, engine_type: str = 'default', auto_increment: int = None):
        """Set the engine type and auto_increment value."""
        self.engine_type = engine_type
        self.auto_increment = auto_increment
        return self
    
    def set_comment(self, comment: str):
        """Set the table comment."""
        self.comment = comment
        return self
    
    def build(self) -> str:
        """Build the complete table definition."""
        parts = [generate_table_header(self.table_name)]
        parts.append(f"CREATE TABLE `{self.table_name}` (")
        
        # Add columns
        column_lines = []
        for col in self.columns:
            if not col.strip().startswith('`'):
                col = f"  {col}"
            column_lines.append(col)
        
        # Add primary key
        if self.primary_key:
            column_lines.append(f"  {self.primary_key}")
        
        # Add indexes
        column_lines.extend(self.indexes)
        
        parts.append(',\n'.join(column_lines))
        
        # Add footer
        footer = generate_table_footer(
            self.table_name,
            self.engine_type,
            self.auto_increment,
            self.comment
        )
        parts.append(footer)
        
        return '\n'.join(parts)


# Example usage function
def example_usage():
    """Example of how to use the TableBuilder."""
    # Example 1: Simple table with standard columns
    table1 = (TableBuilder('example_table')
             .add_id_column()
             .add_custom_column('`name` varchar(100) NOT NULL COMMENT \'名称\'')
             .add_custom_column('`status` tinyint DEFAULT 0 COMMENT \'状态\'')
             .add_timestamp_columns()
             .add_standard_indexes()
             .set_comment('示例表')
             .build())
    
    print(table1)
    print("\n\n")
    
    # Example 2: Table with user tracking
    table2 = (TableBuilder('user_tracking_table')
             .add_id_column()
             .add_custom_column('`data` varchar(255) COMMENT \'数据\'')
             .add_timestamp_columns()
             .add_user_tracking_columns()
             .set_engine('default', auto_increment=1000)
             .set_comment('用户追踪表')
             .build())
    
    print(table2)


if __name__ == '__main__':
    example_usage()
