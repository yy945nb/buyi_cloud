-- ========================================
-- Orders Table
-- ========================================
-- Stores order information
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `orders` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Order ID',
  `order_no` VARCHAR(32) NOT NULL COMMENT 'Order number',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'User ID',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT 'Total amount',
  `discount_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Discount amount',
  `shipping_fee` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Shipping fee',
  `paid_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Paid amount',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT 'Order status: 1=pending, 2=paid, 3=shipped, 4=completed, 5=cancelled',
  `payment_method` VARCHAR(20) DEFAULT NULL COMMENT 'Payment method: alipay, wechat, credit_card, etc.',
  `payment_status` TINYINT NOT NULL DEFAULT 0 COMMENT 'Payment status: 0=unpaid, 1=paid, 2=refunded',
  `shipping_status` TINYINT NOT NULL DEFAULT 0 COMMENT 'Shipping status: 0=unshipped, 1=shipped, 2=received',
  `recipient_name` VARCHAR(50) NOT NULL COMMENT 'Recipient name',
  `recipient_phone` VARCHAR(20) NOT NULL COMMENT 'Recipient phone',
  `recipient_address` VARCHAR(255) NOT NULL COMMENT 'Recipient address',
  `recipient_postcode` VARCHAR(10) DEFAULT NULL COMMENT 'Recipient postcode',
  `remark` TEXT DEFAULT NULL COMMENT 'Order remark',
  `paid_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'Payment time',
  `shipped_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'Shipping time',
  `completed_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'Completion time',
  `cancelled_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'Cancellation time',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Orders table';
