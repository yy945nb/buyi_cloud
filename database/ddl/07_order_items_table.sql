-- ========================================
-- Order Items Table
-- ========================================
-- Stores order item details
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `order_items` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Order item ID',
  `order_id` BIGINT UNSIGNED NOT NULL COMMENT 'Order ID',
  `product_id` BIGINT UNSIGNED NOT NULL COMMENT 'Product ID',
  `product_name` VARCHAR(200) NOT NULL COMMENT 'Product name (snapshot)',
  `product_sku` VARCHAR(50) NOT NULL COMMENT 'Product SKU (snapshot)',
  `product_image` VARCHAR(255) DEFAULT NULL COMMENT 'Product image (snapshot)',
  `price` DECIMAL(10,2) NOT NULL COMMENT 'Unit price',
  `quantity` INT NOT NULL COMMENT 'Quantity',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT 'Total amount',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Order items table';
