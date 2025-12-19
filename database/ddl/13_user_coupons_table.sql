-- ========================================
-- User Coupons Table
-- ========================================
-- Stores user coupon ownership and usage
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `user_coupons` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'User coupon ID',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'User ID',
  `coupon_id` BIGINT UNSIGNED NOT NULL COMMENT 'Coupon ID',
  `order_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Order ID (if used)',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT 'Status: 0=unused, 1=used, 2=expired',
  `used_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'Usage time',
  `expire_at` TIMESTAMP NOT NULL COMMENT 'Expiration time',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_user_coupons_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_coupons_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User coupons table';
