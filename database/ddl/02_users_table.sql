-- ========================================
-- Users Table
-- ========================================
-- Stores user account information
-- ========================================

USE `buyi_cloud`;

CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'User ID',
  `username` VARCHAR(50) NOT NULL COMMENT 'Username',
  `email` VARCHAR(100) NOT NULL COMMENT 'Email address',
  `password_hash` VARCHAR(255) NOT NULL COMMENT 'Password hash',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT 'Phone number',
  `avatar_url` VARCHAR(255) DEFAULT NULL COMMENT 'Avatar URL',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT 'Status: 0=inactive, 1=active, 2=banned',
  `user_type` TINYINT NOT NULL DEFAULT 1 COMMENT 'User type: 1=regular, 2=vip, 3=admin',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update time',
  `last_login_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'Last login time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  KEY `idx_phone` (`phone`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User accounts table';
