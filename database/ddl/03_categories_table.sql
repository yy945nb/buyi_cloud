-- ========================================
-- Categories Table
-- ========================================
-- Stores product categories hierarchy
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `categories` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Category ID',
  `parent_id` BIGINT UNSIGNED DEFAULT 0 COMMENT 'Parent category ID, 0 for root',
  `name` VARCHAR(100) NOT NULL COMMENT 'Category name',
  `slug` VARCHAR(100) NOT NULL COMMENT 'Category slug for URLs',
  `description` TEXT DEFAULT NULL COMMENT 'Category description',
  `icon_url` VARCHAR(255) DEFAULT NULL COMMENT 'Category icon URL',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT 'Display order',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT 'Status: 0=inactive, 1=active',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_status` (`status`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Product categories table';
