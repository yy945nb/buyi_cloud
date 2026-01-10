#!/usr/bin/env python3
"""
Test suite for SQL templates and refactoring
"""

import unittest
from sql_templates import (
    TableBuilder, 
    COMMON_COLUMNS, 
    ENGINE_CONFIGS,
    generate_table_header,
    generate_table_footer,
)


class TestSQLTemplates(unittest.TestCase):
    """Test SQL template functions."""
    
    def test_table_header_generation(self):
        """Test that table headers are generated correctly."""
        header = generate_table_header('test_table')
        self.assertIn('Table structure for test_table', header)
        self.assertIn('DROP TABLE IF EXISTS `test_table`', header)
    
    def test_table_footer_default(self):
        """Test default table footer generation."""
        footer = generate_table_footer('test_table')
        self.assertIn('ENGINE=InnoDB', footer)
        self.assertIn('DEFAULT CHARSET=utf8mb4', footer)
        self.assertIn('COLLATE=utf8mb4_0900_ai_ci', footer)
    
    def test_table_footer_with_auto_increment(self):
        """Test table footer with AUTO_INCREMENT."""
        footer = generate_table_footer('test_table', auto_increment=1000)
        self.assertIn('AUTO_INCREMENT=1000', footer)
    
    def test_table_footer_with_comment(self):
        """Test table footer with comment."""
        footer = generate_table_footer('test_table', comment='Test table')
        self.assertIn("COMMENT='Test table'", footer)
    
    def test_common_columns_definitions(self):
        """Test that common column definitions are present."""
        self.assertIn('id_auto', COMMON_COLUMNS)
        self.assertIn('create_time', COMMON_COLUMNS['create_time_auto'])
        self.assertIn('update_time', COMMON_COLUMNS['update_time_auto'])
    
    def test_engine_configs(self):
        """Test that engine configurations are defined."""
        self.assertIn('default', ENGINE_CONFIGS)
        self.assertIn('unicode', ENGINE_CONFIGS)
        self.assertIn('ENGINE=InnoDB', ENGINE_CONFIGS['default'])


class TestTableBuilder(unittest.TestCase):
    """Test TableBuilder class."""
    
    def test_simple_table_creation(self):
        """Test creating a simple table."""
        table = (TableBuilder('simple_table')
                .add_id_column()
                .add_custom_column('`name` varchar(100) NOT NULL')
                .build())
        
        self.assertIn('CREATE TABLE `simple_table`', table)
        self.assertIn('`id` bigint NOT NULL AUTO_INCREMENT', table)
        self.assertIn('`name` varchar(100) NOT NULL', table)
        self.assertIn('PRIMARY KEY (`id`)', table)
    
    def test_table_with_timestamps(self):
        """Test creating a table with timestamp columns."""
        table = (TableBuilder('timestamp_table')
                .add_id_column()
                .add_timestamp_columns()
                .build())
        
        self.assertIn('CREATE TABLE `timestamp_table`', table)
        self.assertIn('create_time', table)
        self.assertIn('update_time', table)
        self.assertIn('DEFAULT CURRENT_TIMESTAMP', table)
    
    def test_table_with_user_tracking(self):
        """Test creating a table with user tracking columns."""
        table = (TableBuilder('tracking_table')
                .add_id_column()
                .add_user_tracking_columns()
                .build())
        
        self.assertIn('CREATE TABLE `tracking_table`', table)
        self.assertIn('create_user_id', table)
        self.assertIn('update_user_id', table)
    
    def test_table_with_indexes(self):
        """Test creating a table with indexes."""
        table = (TableBuilder('indexed_table')
                .add_id_column()
                .add_timestamp_columns()
                .add_standard_indexes()
                .build())
        
        self.assertIn('CREATE TABLE `indexed_table`', table)
        self.assertIn('idx_create_time', table)
    
    def test_table_with_comment(self):
        """Test creating a table with a comment."""
        table = (TableBuilder('commented_table')
                .add_id_column()
                .set_comment('This is a test table')
                .build())
        
        self.assertIn("COMMENT='This is a test table'", table)
    
    def test_table_with_custom_engine(self):
        """Test creating a table with custom engine."""
        table = (TableBuilder('unicode_table')
                .add_id_column()
                .set_engine('unicode')
                .build())
        
        self.assertIn('utf8mb4_unicode_ci', table)
    
    def test_complete_table(self):
        """Test creating a complete table with all features."""
        table = (TableBuilder('complete_table')
                .add_id_column()
                .add_custom_column('`name` varchar(100) NOT NULL COMMENT \'名称\'')
                .add_custom_column('`status` tinyint DEFAULT 0 COMMENT \'状态\'')
                .add_timestamp_columns()
                .add_user_tracking_columns()
                .add_index('idx_name', ['name'], '名称索引')
                .add_standard_indexes()
                .set_engine('default', auto_increment=5000)
                .set_comment('完整示例表')
                .build())
        
        # Verify all components are present
        self.assertIn('CREATE TABLE `complete_table`', table)
        self.assertIn('DROP TABLE IF EXISTS `complete_table`', table)
        self.assertIn('`id` bigint NOT NULL AUTO_INCREMENT', table)
        self.assertIn('`name` varchar(100) NOT NULL', table)
        self.assertIn('`status` tinyint DEFAULT 0', table)
        self.assertIn('create_time', table)
        self.assertIn('update_time', table)
        self.assertIn('create_user_id', table)
        self.assertIn('update_user_id', table)
        self.assertIn('idx_name', table)
        self.assertIn('idx_create_time', table)
        self.assertIn('PRIMARY KEY (`id`)', table)
        self.assertIn('ENGINE=InnoDB AUTO_INCREMENT=5000', table)
        self.assertIn("COMMENT='完整示例表'", table)


class TestRefactoringBenefits(unittest.TestCase):
    """Test cases demonstrating refactoring benefits."""
    
    def test_consistency_in_column_definitions(self):
        """Test that using templates ensures consistency."""
        # Create two tables with the same pattern
        table1 = (TableBuilder('table1')
                 .add_id_column()
                 .add_timestamp_columns()
                 .build())
        
        table2 = (TableBuilder('table2')
                 .add_id_column()
                 .add_timestamp_columns()
                 .build())
        
        # Extract timestamp definitions from both tables
        import re
        
        create_time_match_1 = re.search(r'`create_time`[^\n]+', table1)
        create_time_match_2 = re.search(r'`create_time`[^\n]+', table2)
        
        # Verify matches found
        self.assertIsNotNone(create_time_match_1, "create_time not found in table1")
        self.assertIsNotNone(create_time_match_2, "create_time not found in table2")
        
        create_time_1 = create_time_match_1.group(0)
        create_time_2 = create_time_match_2.group(0)
        
        # They should be identical (except for leading whitespace)
        self.assertEqual(create_time_1.strip(), create_time_2.strip())
    
    def test_reusability_reduces_duplication(self):
        """Test that templates reduce code duplication."""
        # Before refactoring: Each table would have full column definition
        # After refactoring: Use common template
        
        # Create multiple tables using the same pattern
        tables = []
        for i in range(5):
            table = (TableBuilder(f'table_{i}')
                    .add_id_column()
                    .add_timestamp_columns()
                    .build())
            tables.append(table)
        
        # Verify all have consistent timestamp columns
        import re
        timestamp_patterns = []
        for t in tables:
            match = re.search(r'`create_time`[^\n]+', t)
            if match:
                timestamp_patterns.append(match.group(0))
        
        # Verify we found patterns for all tables
        self.assertEqual(len(timestamp_patterns), 5, "Should find create_time in all 5 tables")
        
        # All should be identical
        self.assertEqual(len(set([p.strip() for p in timestamp_patterns])), 1,
                        "All create_time definitions should be identical")


def run_tests():
    """Run all tests."""
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add all test cases
    suite.addTests(loader.loadTestsFromTestCase(TestSQLTemplates))
    suite.addTests(loader.loadTestsFromTestCase(TestTableBuilder))
    suite.addTests(loader.loadTestsFromTestCase(TestRefactoringBenefits))
    
    # Run tests with verbose output
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Return success status
    return result.wasSuccessful()


if __name__ == '__main__':
    import sys
    success = run_tests()
    sys.exit(0 if success else 1)
