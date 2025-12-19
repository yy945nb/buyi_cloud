# Buyi Cloud Database Schema

This directory contains the MySQL DDL (Data Definition Language) scripts for the Buyi Cloud e-commerce system.

## Database Structure

The database is designed to support a full-featured e-commerce platform with the following main components:

### Core Tables

1. **users** - User account management
2. **categories** - Product category hierarchy
3. **products** - Product catalog
4. **product_images** - Product images management
5. **orders** - Order management
6. **order_items** - Order line items
7. **cart** - Shopping cart
8. **reviews** - Product reviews and ratings
9. **addresses** - User shipping addresses
10. **payments** - Payment records
11. **coupons** - Promotional coupons
12. **user_coupons** - User coupon ownership and usage

## Installation

### Prerequisites

- MySQL 5.7+ or MariaDB 10.2+
- Database user with CREATE, ALTER, and INSERT privileges

### Quick Start

1. Navigate to the database directory:
```bash
cd database
```

2. Execute the master initialization script:
```bash
mysql -u root -p < init_database.sql
```

Or run individual DDL files in order:
```bash
mysql -u root -p < ddl/01_create_database.sql
mysql -u root -p < ddl/02_users_table.sql
# ... and so on
```

### Alternative: Execute from MySQL CLI

```sql
SOURCE /path/to/buyi_cloud/database/init_database.sql;
```

## Database Design Features

### Character Set and Collation
- Uses `utf8mb4` character set for full Unicode support (including emojis)
- Uses `utf8mb4_unicode_ci` collation for better sorting and comparison

### Indexing Strategy
- Primary keys on all tables
- Unique indexes on business keys (username, email, SKU, order numbers)
- Foreign key indexes for referential integrity
- Composite indexes for common query patterns
- Status and date indexes for filtering and sorting

### Data Integrity
- Foreign key constraints for referential integrity
- Check constraints for data validation
- Default values for common fields
- Timestamp tracking (created_at, updated_at)

### Performance Considerations
- InnoDB engine for ACID compliance and better concurrency
- Appropriate indexes for common queries
- Denormalized fields in order_items for historical data preservation

## Schema Overview

### User Management
```
users
├── Basic Info (username, email, phone)
├── Authentication (password_hash)
├── Profile (avatar_url)
└── Status tracking (status, user_type)
```

### Product Catalog
```
categories (hierarchical structure)
└── products
    ├── Basic Info (name, description, SKU)
    ├── Pricing (price, original_price, cost_price)
    ├── Inventory (stock_quantity)
    ├── Statistics (sales_count, view_count)
    └── product_images
```

### Order Management
```
orders
├── Order Info (order_no, total_amount)
├── Payment Info (payment_method, payment_status)
├── Shipping Info (recipient details, shipping_status)
├── order_items (order line items)
└── payments (payment records)
```

### Marketing & Engagement
```
coupons
└── user_coupons (user coupon ownership)

reviews (product reviews and ratings)
```

### Shopping Experience
```
cart (shopping cart items)
addresses (user shipping addresses)
```

## Field Naming Conventions

- Snake case for table and column names
- Descriptive names that clearly indicate purpose
- Consistent suffixes:
  - `_id` for foreign keys
  - `_at` for timestamps
  - `_count` for counters
  - `_url` for URLs
  - `_status` for status fields

## Status Codes

### User Status
- 0: Inactive
- 1: Active
- 2: Banned

### Order Status
- 1: Pending
- 2: Paid
- 3: Shipped
- 4: Completed
- 5: Cancelled

### Payment Status
- 0: Unpaid
- 1: Paid
- 2: Refunded

### Review Status
- 0: Pending
- 1: Approved
- 2: Rejected

## Maintenance

### Backup
```bash
mysqldump -u root -p buyi_cloud > backup_$(date +%Y%m%d).sql
```

### Restore
```bash
mysql -u root -p buyi_cloud < backup_YYYYMMDD.sql
```

## Future Enhancements

Potential additions for future versions:
- Wishlist table
- Product variants (size, color)
- Shipping providers and tracking
- Refund management
- Customer service tickets
- Inventory logging
- Price history
- Search logs and analytics
- Notification preferences
- User sessions

## License

This database schema is part of the Buyi Cloud project.
