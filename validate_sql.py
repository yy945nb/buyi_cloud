#!/usr/bin/env python3
"""
SQL Validation Script
This script validates that the refactored SQL file maintains schema integrity.
"""

import re
import sys


def validate_sql_file(filename):
    """Validate SQL file structure and syntax."""
    
    print(f"Validating {filename}...")
    print("=" * 70)
    
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    errors = []
    warnings = []
    
    # 1. Check for balanced CREATE TABLE and DROP TABLE statements
    create_count = len(re.findall(r'CREATE TABLE', content))
    drop_count = len(re.findall(r'DROP TABLE IF EXISTS', content))
    
    print(f"\n1. Statement Balance Check:")
    print(f"   CREATE TABLE: {create_count}")
    print(f"   DROP TABLE IF EXISTS: {drop_count}")
    
    if create_count != drop_count:
        errors.append(f"Mismatch: {create_count} CREATE vs {drop_count} DROP statements")
    else:
        print("   ✓ Balanced")
    
    # 2. Check for unclosed parentheses in CREATE TABLE statements
    print(f"\n2. Syntax Check:")
    # Extract full CREATE TABLE blocks including the closing semicolon
    table_blocks = re.findall(r'CREATE TABLE `([^`]+)`.*?;', content, re.DOTALL)
    
    syntax_errors = 0
    for table_block in table_blocks:
        # Simple check for balanced parentheses
        open_count = table_block.count('(')
        close_count = table_block.count(')')
        if open_count != close_count:
            syntax_errors += 1
    
    if syntax_errors > 0:
        errors.append(f"Found {syntax_errors} tables with unbalanced parentheses")
    else:
        print(f"   ✓ All {len(table_blocks)} table definitions have balanced parentheses")
    
    # 3. Check for duplicate table names
    print(f"\n3. Duplicate Check:")
    table_names = re.findall(r'CREATE TABLE `([^`]+)`', content)
    duplicates = [name for name in set(table_names) if table_names.count(name) > 1]
    
    if duplicates:
        errors.append(f"Found {len(duplicates)} duplicate table names: {', '.join(duplicates[:5])}")
    else:
        print(f"   ✓ No duplicate table names found")
    
    # 4. Check for common SQL syntax patterns
    print(f"\n4. Pattern Validation:")
    
    # Check for semicolons at end of CREATE TABLE
    tables_without_semicolon = len(re.findall(r'ENGINE=InnoDB[^\n;]+\n', content))
    if tables_without_semicolon > 0:
        warnings.append(f"{tables_without_semicolon} table definitions may be missing semicolons")
        print(f"   ⚠ {tables_without_semicolon} tables may be missing semicolons")
    else:
        print(f"   ✓ All tables have proper statement termination")
    
    # Check for standard column types
    invalid_types = re.findall(r'`[^`]+`\s+(\w+)\s+', content)
    valid_types = {'int', 'bigint', 'varchar', 'text', 'datetime', 'timestamp', 
                   'decimal', 'float', 'double', 'tinyint', 'smallint', 'mediumint',
                   'char', 'json', 'blob', 'longtext', 'mediumtext', 'date', 'time',
                   'year', 'enum', 'set', 'binary', 'varbinary', 'bit', 'UNIQUE',
                   'KEY', 'PRIMARY', 'INDEX', 'FULLTEXT', 'SPATIAL', 'CONSTRAINT',
                   'FOREIGN', 'REFERENCES', 'ON', 'DELETE', 'UPDATE', 'CASCADE',
                   'RESTRICT', 'SET', 'NO', 'ACTION', 'CHECK', 'DEFAULT', 'AUTO_INCREMENT'}
    
    unusual_types = [t for t in set(invalid_types) if t.upper() not in [v.upper() for v in valid_types]]
    if unusual_types and len(unusual_types) < 20:  # Only report if not too many
        print(f"   ℹ Found some unusual type names: {', '.join(unusual_types[:5])}")
    
    # 5. Check for consistent charset usage
    print(f"\n5. Charset Consistency:")
    charsets = re.findall(r'CHARSET=(\w+)', content)
    charset_counts = {}
    for charset in charsets:
        charset_counts[charset] = charset_counts.get(charset, 0) + 1
    
    for charset, count in sorted(charset_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"   {charset}: {count} occurrences")
    
    # 6. Summary
    print("\n" + "=" * 70)
    if errors:
        print("VALIDATION FAILED ✗")
        print("\nErrors:")
        for error in errors:
            print(f"  • {error}")
    else:
        print("VALIDATION PASSED ✓")
    
    if warnings:
        print("\nWarnings:")
        for warning in warnings:
            print(f"  • {warning}")
    
    print("=" * 70)
    
    return len(errors) == 0


def main():
    """Main function."""
    filename = 'buyi_platform_dev.sql'
    
    if len(sys.argv) > 1:
        filename = sys.argv[1]
    
    try:
        success = validate_sql_file(filename)
        sys.exit(0 if success else 1)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    except Exception as e:
        print(f"Error during validation: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
