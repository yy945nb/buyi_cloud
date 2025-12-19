# Buyi Cloud E-commerce Platform

A cloud-based e-commerce platform database schema for modern online shopping experiences.

## Features

- Complete MySQL database schema for e-commerce
- User management and authentication
- Product catalog with categories and images
- Order management and tracking
- Shopping cart functionality
- Payment processing records
- Product reviews and ratings
- Coupon and discount system
- User address management

## Quick Start

### Database Installation

1. Navigate to the database directory:
```bash
cd database
```

2. Run the initialization script:
```bash
mysql -u root -p < init_database.sql
```

3. (Optional) Load sample data:
```bash
mysql -u root -p < migrations/sample_data.sql
```

## Database Schema

The database includes the following tables:

- **users** - User accounts
- **categories** - Product categories (hierarchical)
- **products** - Product catalog
- **product_images** - Product images
- **orders** - Customer orders
- **order_items** - Order line items
- **cart** - Shopping cart
- **reviews** - Product reviews
- **addresses** - Shipping addresses
- **payments** - Payment records
- **coupons** - Promotional coupons
- **user_coupons** - User coupon ownership

## Documentation

Detailed documentation is available in the [database/README.md](database/README.md) file.

## Database Design

- **Engine**: InnoDB for ACID compliance
- **Character Set**: utf8mb4 for full Unicode support
- **Collation**: utf8mb4_unicode_ci
- **Features**: Foreign keys, indexes, timestamps, status tracking

## Requirements

- MySQL 5.7+ or MariaDB 10.2+
- Database user with appropriate privileges

## License

This project is part of the Buyi Cloud platform.