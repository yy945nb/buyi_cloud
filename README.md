# buyi_cloud

## Database Schema Management

This repository contains the database schema for the buyi_cloud platform.

### Files

- `buyi_platform_dev.sql` - Main database schema (refactored for consistency)
- `sql_templates.py` - Reusable SQL pattern templates
- `refactor_sql.py` - Script for refactoring SQL files to use common patterns
- `SQL_REFACTORING.md` - Detailed documentation about the refactoring approach

### Recent Improvements

The SQL schema has been refactored to eliminate code duplication:
- **432 tables** standardized with consistent patterns
- **783+ duplicated patterns** replaced with reusable templates
- Common column definitions (timestamps, IDs, user tracking)
- Standardized ENGINE configurations
- Consistent index naming patterns

For more details, see [SQL_REFACTORING.md](SQL_REFACTORING.md)

### Usage

#### Creating New Tables

Use the `TableBuilder` class from `sql_templates.py`:

```python
from sql_templates import TableBuilder

new_table = (TableBuilder('my_table')
            .add_id_column()
            .add_custom_column('`name` varchar(100) NOT NULL')
            .add_timestamp_columns()
            .set_comment('My table description')
            .build())
```

#### Refactoring SQL Files

```bash
python3 refactor_sql.py input.sql output.sql
```