-- ========================================
-- Products Table
-- ========================================
-- Stores product information
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `products` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Product ID',
  `category_id` BIGINT UNSIGNED NOT NULL COMMENT 'Category ID',
  `name` VARCHAR(200) NOT NULL COMMENT 'Product name',
  `slug` VARCHAR(200) NOT NULL COMMENT 'Product slug for URLs',
  `sku` VARCHAR(50) NOT NULL COMMENT 'Stock Keeping Unit',
  `description` TEXT DEFAULT NULL COMMENT 'Product description',
  `price` DECIMAL(10,2) NOT NULL COMMENT 'Product price',
  `original_price` DECIMAL(10,2) DEFAULT NULL COMMENT 'Original price before discount',
  `cost_price` DECIMAL(10,2) DEFAULT NULL COMMENT 'Cost price',
  `stock_quantity` INT NOT NULL DEFAULT 0 COMMENT 'Stock quantity',
  `sales_count` INT NOT NULL DEFAULT 0 COMMENT 'Total sales count',
  `view_count` INT NOT NULL DEFAULT 0 COMMENT 'View count',
  `weight` DECIMAL(10,2) DEFAULT NULL COMMENT 'Product weight in kg',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT 'Status: 0=offline, 1=online, 2=out_of_stock',
  `is_featured` TINYINT NOT NULL DEFAULT 0 COMMENT 'Is featured product: 0=no, 1=yes',
  `is_new` TINYINT NOT NULL DEFAULT 0 COMMENT 'Is new arrival: 0=no, 1=yes',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sku` (`sku`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_price` (`price`),
  KEY `idx_sales_count` (`sales_count`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_featured` (`is_featured`),
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Products table';
