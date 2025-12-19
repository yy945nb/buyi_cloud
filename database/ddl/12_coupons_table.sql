-- ========================================
-- Coupons Table
-- ========================================
-- Stores coupon information
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `coupons` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Coupon ID',
  `code` VARCHAR(32) NOT NULL COMMENT 'Coupon code',
  `name` VARCHAR(100) NOT NULL COMMENT 'Coupon name',
  `type` TINYINT NOT NULL COMMENT 'Type: 1=fixed_amount, 2=percentage',
  `discount_value` DECIMAL(10,2) NOT NULL COMMENT 'Discount value',
  `min_purchase_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Minimum purchase amount',
  `max_discount_amount` DECIMAL(10,2) DEFAULT NULL COMMENT 'Maximum discount amount (for percentage type)',
  `total_quantity` INT NOT NULL COMMENT 'Total quantity',
  `used_quantity` INT NOT NULL DEFAULT 0 COMMENT 'Used quantity',
  `per_user_limit` INT NOT NULL DEFAULT 1 COMMENT 'Per user usage limit',
  `start_time` TIMESTAMP NOT NULL COMMENT 'Start time',
  `end_time` TIMESTAMP NOT NULL COMMENT 'End time',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT 'Status: 0=inactive, 1=active',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`),
  KEY `idx_status` (`status`),
  KEY `idx_start_end_time` (`start_time`, `end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Coupons table';
