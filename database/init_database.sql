-- ========================================
-- Master Database Initialization Script
-- ========================================
-- Execute this script to create the complete database schema
-- Run: mysql -u root -p < init_database.sql
-- ========================================

SOURCE ddl/01_create_database.sql;
SOURCE ddl/02_users_table.sql;
SOURCE ddl/03_categories_table.sql;
SOURCE ddl/04_products_table.sql;
SOURCE ddl/05_product_images_table.sql;
SOURCE ddl/06_orders_table.sql;
SOURCE ddl/07_order_items_table.sql;
SOURCE ddl/08_cart_table.sql;
SOURCE ddl/09_reviews_table.sql;
SOURCE ddl/10_addresses_table.sql;
SOURCE ddl/11_payments_table.sql;
SOURCE ddl/12_coupons_table.sql;
SOURCE ddl/13_user_coupons_table.sql;

SELECT 'Database initialization completed successfully!' AS message;
