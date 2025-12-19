-- ========================================
-- User Addresses Table
-- ========================================
-- Stores user shipping addresses
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `addresses` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Address ID',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'User ID',
  `recipient_name` VARCHAR(50) NOT NULL COMMENT 'Recipient name',
  `phone` VARCHAR(20) NOT NULL COMMENT 'Phone number',
  `province` VARCHAR(50) NOT NULL COMMENT 'Province',
  `city` VARCHAR(50) NOT NULL COMMENT 'City',
  `district` VARCHAR(50) NOT NULL COMMENT 'District',
  `address` VARCHAR(255) NOT NULL COMMENT 'Detailed address',
  `postcode` VARCHAR(10) DEFAULT NULL COMMENT 'Postcode',
  `is_default` TINYINT NOT NULL DEFAULT 0 COMMENT 'Is default address: 0=no, 1=yes',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update time',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_default` (`is_default`),
  CONSTRAINT `fk_addresses_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User addresses table';
