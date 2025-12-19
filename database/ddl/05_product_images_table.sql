-- ========================================
-- Product Images Table
-- ========================================
-- Stores product images
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `product_images` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Image ID',
  `product_id` BIGINT UNSIGNED NOT NULL COMMENT 'Product ID',
  `image_url` VARCHAR(255) NOT NULL COMMENT 'Image URL',
  `thumbnail_url` VARCHAR(255) DEFAULT NULL COMMENT 'Thumbnail URL',
  `is_primary` TINYINT NOT NULL DEFAULT 0 COMMENT 'Is primary image: 0=no, 1=yes',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT 'Display order',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_sort_order` (`sort_order`),
  CONSTRAINT `fk_product_images_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Product images table';
