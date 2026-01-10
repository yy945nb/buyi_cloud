#!/usr/bin/env python3
"""
SQL Refactoring Script
This script refactors the SQL file to use common patterns and eliminate duplication.
"""

import re
from typing import Dict, List, Tuple
from sql_templates import (
    ENGINE_CONFIGS, COMMON_COLUMNS, COMMON_INDEXES,
    generate_table_header, generate_table_footer
)


class SQLRefactor:
    """Refactor SQL file to eliminate duplication."""
    
    def __init__(self, input_file: str):
        self.input_file = input_file
        self.content = None
        self.statistics = {
            'tables_processed': 0,
            'patterns_replaced': 0,
            'lines_before': 0,
            'lines_after': 0,
        }
    
    def load(self):
        """Load the SQL file."""
        with open(self.input_file, 'r', encoding='utf-8') as f:
            self.content = f.read()
        self.statistics['lines_before'] = len(self.content.split('\n'))
    
    def normalize_table_headers(self):
        """Standardize all table header comment blocks."""
        # Pattern for table structure comments
        pattern = r'-- ----------------------------\n-- Table structure for ([^\n]+)\n-- ----------------------------\nDROP TABLE IF EXISTS `([^`]+)`;'
        
        def replacement(match):
            table_name = match.group(2)
            self.statistics['patterns_replaced'] += 1
            return generate_table_header(table_name)
        
        self.content = re.sub(pattern, replacement, self.content)
    
    def normalize_engine_specifications(self):
        """Standardize ENGINE specifications."""
        # Most common pattern: ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
        standard_engine = ENGINE_CONFIGS['default']
        
        # Pattern 1: ENGINE with AUTO_INCREMENT
        pattern1 = r'ENGINE=InnoDB AUTO_INCREMENT=\d+ DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci(?! ROW_FORMAT| COMMENT)'
        
        def replace_with_auto_increment(match):
            self.statistics['patterns_replaced'] += 1
            auto_inc = re.search(r'AUTO_INCREMENT=(\d+)', match.group(0)).group(1)
            return f'ENGINE=InnoDB AUTO_INCREMENT={auto_inc} DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci'
        
        self.content = re.sub(pattern1, replace_with_auto_increment, self.content)
        
        # Pattern 2: ENGINE without AUTO_INCREMENT (standardize spacing)
        pattern2 = r'ENGINE=InnoDB\s+DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci(?! ROW_FORMAT| COMMENT| AUTO_INCREMENT)'
        self.content = re.sub(pattern2, standard_engine, self.content)
        self.statistics['patterns_replaced'] += len(re.findall(pattern2, self.content))
    
    def normalize_timestamp_columns(self):
        """Standardize timestamp column definitions."""
        replacements = [
            # Normalize create_time with DEFAULT CURRENT_TIMESTAMP
            (
                r"`create_time`\s+datetime\s+DEFAULT\s+CURRENT_TIMESTAMP\s+COMMENT\s+'创建时间'",
                COMMON_COLUMNS['create_time_auto']
            ),
            # Normalize update_time with ON UPDATE CURRENT_TIMESTAMP
            (
                r"`update_time`\s+datetime\s+DEFAULT\s+CURRENT_TIMESTAMP\s+ON\s+UPDATE\s+CURRENT_TIMESTAMP\s+COMMENT\s+'更新时间'",
                COMMON_COLUMNS['update_time_auto']
            ),
            # Normalize create_time NOT NULL
            (
                r"`create_time`\s+datetime\s+NOT\s+NULL\s+COMMENT\s+'创建时间'",
                COMMON_COLUMNS['create_time_not_null']
            ),
            # Normalize update_time NOT NULL
            (
                r"`update_time`\s+datetime\s+NOT\s+NULL\s+COMMENT\s+'更新时间'",
                COMMON_COLUMNS['update_time_not_null']
            ),
        ]
        
        for pattern, replacement in replacements:
            count = len(re.findall(pattern, self.content))
            if count > 0:
                self.content = re.sub(pattern, replacement, self.content)
                self.statistics['patterns_replaced'] += count
    
    def normalize_id_columns(self):
        """Standardize ID column definitions."""
        # Normalize bigint id columns
        pattern1 = r"`id`\s+bigint\s+NOT\s+NULL\s+AUTO_INCREMENT"
        replacement1 = COMMON_COLUMNS['id_auto']
        count1 = len(re.findall(pattern1, self.content))
        if count1 > 0:
            self.content = re.sub(pattern1, replacement1, self.content)
            self.statistics['patterns_replaced'] += count1
        
        # Normalize int id columns
        pattern2 = r"`id`\s+int\s+NOT\s+NULL\s+AUTO_INCREMENT"
        replacement2 = COMMON_COLUMNS['id_int_auto']
        count2 = len(re.findall(pattern2, self.content))
        if count2 > 0:
            self.content = re.sub(pattern2, replacement2, self.content)
            self.statistics['patterns_replaced'] += count2
    
    def normalize_user_tracking_columns(self):
        """Standardize user tracking columns."""
        # Normalize create_user_id
        pattern1 = r"`create_user_id`\s+bigint\s+DEFAULT\s+NULL\s+COMMENT\s+'创建人ID'"
        replacement1 = COMMON_COLUMNS['create_user_id']
        count1 = len(re.findall(pattern1, self.content))
        if count1 > 0:
            self.content = re.sub(pattern1, replacement1, self.content)
            self.statistics['patterns_replaced'] += count1
        
        # Normalize update_user_id
        pattern2 = r"`update_user_id`\s+bigint\s+DEFAULT\s+NULL\s+COMMENT\s+'更新人ID'"
        replacement2 = COMMON_COLUMNS['update_user_id']
        count2 = len(re.findall(pattern2, self.content))
        if count2 > 0:
            self.content = re.sub(pattern2, replacement2, self.content)
            self.statistics['patterns_replaced'] += count2
    
    def normalize_common_indexes(self):
        """Standardize common index definitions."""
        # Normalize create_time index
        pattern1 = r"KEY\s+`idx_create_time`\s+\(`create_time`\)\s+COMMENT\s+'创建时间索引[^']*'"
        replacement1 = COMMON_INDEXES['idx_create_time']
        count1 = len(re.findall(pattern1, self.content))
        if count1 > 0:
            self.content = re.sub(pattern1, replacement1, self.content)
            self.statistics['patterns_replaced'] += count1
    
    def count_tables(self):
        """Count the number of tables processed."""
        tables = re.findall(r'CREATE TABLE `([^`]+)`', self.content)
        self.statistics['tables_processed'] = len(tables)
    
    def refactor(self):
        """Perform all refactoring operations."""
        print("Starting SQL refactoring...")
        print(f"Processing {self.input_file}...")
        
        self.load()
        print(f"✓ Loaded file ({self.statistics['lines_before']} lines)")
        
        self.normalize_table_headers()
        print("✓ Normalized table headers")
        
        self.normalize_id_columns()
        print("✓ Normalized ID columns")
        
        self.normalize_timestamp_columns()
        print("✓ Normalized timestamp columns")
        
        self.normalize_user_tracking_columns()
        print("✓ Normalized user tracking columns")
        
        self.normalize_common_indexes()
        print("✓ Normalized common indexes")
        
        self.normalize_engine_specifications()
        print("✓ Normalized ENGINE specifications")
        
        self.count_tables()
        self.statistics['lines_after'] = len(self.content.split('\n'))
        
        return self.content
    
    def save(self, output_file: str):
        """Save the refactored SQL to a file."""
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(self.content)
        print(f"✓ Saved refactored SQL to {output_file}")
    
    def print_statistics(self):
        """Print refactoring statistics."""
        print("\n" + "=" * 60)
        print("REFACTORING STATISTICS")
        print("=" * 60)
        print(f"Tables processed:     {self.statistics['tables_processed']}")
        print(f"Patterns replaced:    {self.statistics['patterns_replaced']}")
        print(f"Lines before:         {self.statistics['lines_before']}")
        print(f"Lines after:          {self.statistics['lines_after']}")
        lines_diff = self.statistics['lines_before'] - self.statistics['lines_after']
        print(f"Lines reduced:        {lines_diff} ({lines_diff/self.statistics['lines_before']*100:.1f}%)")
        print("=" * 60)


def main():
    """Main function."""
    import sys
    
    input_file = 'buyi_platform_dev.sql'
    output_file = 'buyi_platform_dev_refactored.sql'
    
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    if len(sys.argv) > 2:
        output_file = sys.argv[2]
    
    try:
        refactor = SQLRefactor(input_file)
        refactor.refactor()
        refactor.save(output_file)
        refactor.print_statistics()
        
        print("\n✓ Refactoring completed successfully!")
        print(f"\nOriginal file: {input_file}")
        print(f"Refactored file: {output_file}")
        print("\nTo replace the original file, run:")
        print(f"  mv {output_file} {input_file}")
        
    except Exception as e:
        print(f"\n✗ Error during refactoring: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
