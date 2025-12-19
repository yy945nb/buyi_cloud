-- ========================================
-- Payments Table
-- ========================================
-- Stores payment records
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `payments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Payment ID',
  `payment_no` VARCHAR(32) NOT NULL COMMENT 'Payment number',
  `order_id` BIGINT UNSIGNED NOT NULL COMMENT 'Order ID',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'User ID',
  `payment_method` VARCHAR(20) NOT NULL COMMENT 'Payment method',
  `amount` DECIMAL(10,2) NOT NULL COMMENT 'Payment amount',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT 'Status: 0=pending, 1=success, 2=failed, 3=refunded',
  `transaction_id` VARCHAR(100) DEFAULT NULL COMMENT 'Third-party transaction ID',
  `paid_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'Payment time',
  `refunded_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'Refund time',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_payment_no` (`payment_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_payments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Payments table';
