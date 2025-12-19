-- ========================================
-- Sample Data for Testing
-- ========================================
-- This script inserts sample data for development and testing
-- ========================================

USE `buyi_cloud`;

-- Insert sample users
INSERT INTO `users` (`username`, `email`, `password_hash`, `phone`, `status`, `user_type`) VALUES
('admin', 'admin@buyi.com', '$2y$10$YourHashedPasswordHere', '13800138000', 1, 3),
('john_doe', 'john@example.com', '$2y$10$YourHashedPasswordHere', '13800138001', 1, 1),
('jane_smith', 'jane@example.com', '$2y$10$YourHashedPasswordHere', '13800138002', 1, 2),
('test_user', 'test@example.com', '$2y$10$YourHashedPasswordHere', '13800138003', 1, 1);

-- Insert sample categories
INSERT INTO `categories` (`parent_id`, `name`, `slug`, `description`, `sort_order`, `status`) VALUES
(0, 'Electronics', 'electronics', 'Electronic devices and accessories', 1, 1),
(0, 'Fashion', 'fashion', 'Clothing and accessories', 2, 1),
(0, 'Home & Garden', 'home-garden', 'Home and garden products', 3, 1),
(1, 'Smartphones', 'smartphones', 'Mobile phones and accessories', 1, 1),
(1, 'Laptops', 'laptops', 'Laptops and accessories', 2, 1),
(2, 'Men\'s Clothing', 'mens-clothing', 'Men\'s fashion', 1, 1),
(2, 'Women\'s Clothing', 'womens-clothing', 'Women\'s fashion', 2, 1);

-- Insert sample products
INSERT INTO `products` (`category_id`, `name`, `slug`, `sku`, `description`, `price`, `original_price`, `stock_quantity`, `status`, `is_featured`) VALUES
(4, 'iPhone 15 Pro', 'iphone-15-pro', 'IP15P-001', 'Latest iPhone with advanced features', 999.99, 1099.99, 50, 1, 1),
(4, 'Samsung Galaxy S24', 'samsung-galaxy-s24', 'SGS24-001', 'Premium Android smartphone', 899.99, 999.99, 40, 1, 1),
(5, 'MacBook Pro 16"', 'macbook-pro-16', 'MBP16-001', 'High-performance laptop for professionals', 2499.99, 2699.99, 20, 1, 1),
(5, 'Dell XPS 15', 'dell-xps-15', 'DXP15-001', 'Premium Windows laptop', 1799.99, 1999.99, 30, 1, 0),
(6, 'Men\'s Casual Shirt', 'mens-casual-shirt', 'MCS-001', 'Comfortable cotton shirt', 29.99, 39.99, 100, 1, 0),
(7, 'Women\'s Summer Dress', 'womens-summer-dress', 'WSD-001', 'Elegant summer dress', 49.99, 69.99, 80, 1, 0);

-- Insert sample product images
INSERT INTO `product_images` (`product_id`, `image_url`, `thumbnail_url`, `is_primary`, `sort_order`) VALUES
(1, '/images/products/iphone-15-pro-1.jpg', '/images/products/thumbs/iphone-15-pro-1.jpg', 1, 1),
(1, '/images/products/iphone-15-pro-2.jpg', '/images/products/thumbs/iphone-15-pro-2.jpg', 0, 2),
(2, '/images/products/samsung-s24-1.jpg', '/images/products/thumbs/samsung-s24-1.jpg', 1, 1),
(3, '/images/products/macbook-pro-1.jpg', '/images/products/thumbs/macbook-pro-1.jpg', 1, 1);

-- Insert sample addresses
INSERT INTO `addresses` (`user_id`, `recipient_name`, `phone`, `province`, `city`, `district`, `address`, `postcode`, `is_default`) VALUES
(2, 'John Doe', '13800138001', 'Beijing', 'Beijing', 'Chaoyang', '123 Main Street, Building 5, Apt 101', '100000', 1),
(3, 'Jane Smith', '13800138002', 'Shanghai', 'Shanghai', 'Pudong', '456 River Road, Tower A, Floor 20', '200000', 1);

-- Insert sample coupons
INSERT INTO `coupons` (`code`, `name`, `type`, `discount_value`, `min_purchase_amount`, `total_quantity`, `start_time`, `end_time`, `status`) VALUES
('WELCOME10', 'Welcome Discount', 2, 10.00, 50.00, 1000, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1),
('SAVE50', 'Save $50', 1, 50.00, 200.00, 500, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1),
('SUMMER20', 'Summer Sale 20%', 2, 20.00, 100.00, 2000, NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 1);

-- Insert sample orders
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `discount_amount`, `shipping_fee`, `paid_amount`, `status`, `payment_method`, `payment_status`, `shipping_status`, `recipient_name`, `recipient_phone`, `recipient_address`, `paid_at`) VALUES
('ORD20240101001', 2, 1029.98, 100.00, 10.00, 939.98, 2, 'alipay', 1, 0, 'John Doe', '13800138001', 'Beijing, Chaoyang, 123 Main Street, Building 5, Apt 101', NOW()),
('ORD20240101002', 3, 2549.98, 50.00, 20.00, 2519.98, 3, 'wechat', 1, 1, 'Jane Smith', '13800138002', 'Shanghai, Pudong, 456 River Road, Tower A, Floor 20', DATE_SUB(NOW(), INTERVAL 1 DAY));

-- Insert sample order items
INSERT INTO `order_items` (`order_id`, `product_id`, `product_name`, `product_sku`, `product_image`, `price`, `quantity`, `total_amount`) VALUES
(1, 1, 'iPhone 15 Pro', 'IP15P-001', '/images/products/iphone-15-pro-1.jpg', 999.99, 1, 999.99),
(1, 5, 'Men\'s Casual Shirt', 'MCS-001', '/images/products/mens-shirt-1.jpg', 29.99, 1, 29.99),
(2, 3, 'MacBook Pro 16"', 'MBP16-001', '/images/products/macbook-pro-1.jpg', 2499.99, 1, 2499.99),
(2, 6, 'Women\'s Summer Dress', 'WSD-001', '/images/products/womens-dress-1.jpg', 49.99, 1, 49.99);

-- Insert sample reviews
INSERT INTO `reviews` (`product_id`, `user_id`, `order_id`, `rating`, `title`, `content`, `status`) VALUES
(1, 2, 1, 5, 'Excellent phone!', 'The iPhone 15 Pro is absolutely amazing. Great camera, fast performance, and beautiful design.', 1),
(3, 3, 2, 5, 'Best laptop ever', 'Perfect for my work as a developer. Fast, reliable, and great screen quality.', 1),
(5, 2, 1, 4, 'Good quality shirt', 'Nice fabric and fit. Would buy again.', 1);

-- Insert sample cart items
INSERT INTO `cart` (`user_id`, `product_id`, `quantity`) VALUES
(2, 2, 1),
(2, 4, 1),
(3, 5, 2);

-- Insert sample payments
INSERT INTO `payments` (`payment_no`, `order_id`, `user_id`, `payment_method`, `amount`, `status`, `transaction_id`, `paid_at`) VALUES
('PAY20240101001', 1, 2, 'alipay', 939.98, 1, 'ALIPAY123456789', NOW()),
('PAY20240101002', 2, 3, 'wechat', 2519.98, 1, 'WECHAT987654321', DATE_SUB(NOW(), INTERVAL 1 DAY));

SELECT 'Sample data inserted successfully!' AS message;
