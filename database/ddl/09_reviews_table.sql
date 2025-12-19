-- ========================================
-- Product Reviews Table
-- ========================================
-- Stores product reviews and ratings
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `reviews` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Review ID',
  `product_id` BIGINT UNSIGNED NOT NULL COMMENT 'Product ID',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'User ID',
  `order_id` BIGINT UNSIGNED NOT NULL COMMENT 'Order ID',
  `rating` TINYINT NOT NULL COMMENT 'Rating: 1-5 stars',
  `title` VARCHAR(100) DEFAULT NULL COMMENT 'Review title',
  `content` TEXT NOT NULL COMMENT 'Review content',
  `images` JSON DEFAULT NULL COMMENT 'Review images array',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT 'Status: 0=pending, 1=approved, 2=rejected',
  `helpful_count` INT NOT NULL DEFAULT 0 COMMENT 'Helpful count',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update time',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_status` (`status`),
  KEY `idx_rating` (`rating`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_rating` CHECK (`rating` >= 1 AND `rating` <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Product reviews table';
