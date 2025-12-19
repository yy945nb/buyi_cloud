# Database Schema Diagram

## Entity Relationship Overview

```
┌─────────────┐
│   users     │
└─────────────┘
      │
      │ 1:N
      ├──────────┐
      │          │
      ▼          ▼
┌─────────┐  ┌────────┐
│addresses│  │  cart  │
└─────────┘  └────────┘
                  │
      ┌───────────┴──────────┐
      │                      │
      │ N:1                  │ N:1
      ▼                      ▼
┌────────────┐         ┌────────────┐
│  products  │◄────────│ categories │
└────────────┘         └────────────┘
      │                      │
      │ 1:N                  │ (self-referential)
      ├──────────┬───────────┤
      │          │           │
      ▼          ▼           ▼
┌────────────┐ ┌─────────┐
│product_    │ │ reviews │
│  images    │ └─────────┘
└────────────┘

┌─────────────┐
│   orders    │
└─────────────┘
      │
      │ 1:N
      ├──────────┬──────────┐
      │          │          │
      ▼          ▼          ▼
┌────────────┐ ┌──────────┐
│order_items │ │ payments │
└────────────┘ └──────────┘

┌─────────────┐
│   coupons   │
└─────────────┘
      │
      │ 1:N
      ▼
┌─────────────┐
│user_coupons │
└─────────────┘
```

## Table Relationships

### Core User Flow
1. **users** → Central table for user management
   - Has many `addresses` (shipping locations)
   - Has many `cart` items (shopping cart)
   - Has many `orders`
   - Has many `reviews`
   - Has many `user_coupons`

### Product Catalog
2. **categories** → Hierarchical category structure
   - Self-referential: each category can have a parent_id
   - Has many `products`

3. **products** → Product catalog
   - Belongs to one `category`
   - Has many `product_images`
   - Has many `reviews`
   - Referenced by `cart` items
   - Referenced by `order_items`

4. **product_images** → Product image gallery
   - Belongs to one `product`

### Order Management
5. **orders** → Customer orders
   - Belongs to one `user`
   - Has many `order_items`
   - Has many `payments`
   - Referenced by `reviews`
   - Referenced by `user_coupons` (when used)

6. **order_items** → Order line items
   - Belongs to one `order`
   - References `product` (snapshot data stored)

### Supporting Features
7. **cart** → Shopping cart
   - Belongs to one `user`
   - References one `product`

8. **reviews** → Product reviews
   - Belongs to one `user`
   - Belongs to one `product`
   - Belongs to one `order` (verified purchase)

9. **addresses** → User shipping addresses
   - Belongs to one `user`

10. **payments** → Payment records
    - Belongs to one `order`
    - Belongs to one `user`

11. **coupons** → Promotional coupons
    - Has many `user_coupons`

12. **user_coupons** → User coupon ownership
    - Belongs to one `user`
    - Belongs to one `coupon`
    - Optionally references `order` (when used)

## Key Design Patterns

### Cascade Deletes
When a parent record is deleted, related child records are automatically removed:
- Delete user → cascades to addresses, cart, orders, reviews, payments, user_coupons
- Delete category → cascades to products (and their images)
- Delete product → cascades to product_images, cart items, order_items
- Delete order → cascades to order_items, payments

### Set NULL on Delete
- user_coupons.order_id → Set to NULL if order is deleted (preserves coupon usage history)

### Denormalized Snapshot Data
The `order_items` table stores snapshot data (product name, SKU, price, image) to preserve historical information even if the product is modified or deleted later.

## Status Field Values

### users.status
- 0: Inactive
- 1: Active
- 2: Banned

### products.status
- 0: Offline
- 1: Online
- 2: Out of stock

### orders.status
- 1: Pending
- 2: Paid
- 3: Shipped
- 4: Completed
- 5: Cancelled

### orders.payment_status
- 0: Unpaid
- 1: Paid
- 2: Refunded

### orders.shipping_status
- 0: Unshipped
- 1: Shipped
- 2: Received

### reviews.status
- 0: Pending
- 1: Approved
- 2: Rejected

### payments.status
- 0: Pending
- 1: Success
- 2: Failed
- 3: Refunded

### user_coupons.status
- 0: Unused
- 1: Used
- 2: Expired

### coupons.type
- 1: Fixed amount discount
- 2: Percentage discount

## Indexes Summary

All tables have:
- Primary key indexes on `id`
- Foreign key indexes for relationships
- Status field indexes for filtering
- Timestamp indexes for sorting and date filtering
- Unique indexes on business keys (username, email, SKU, order numbers, etc.)

## Character Set & Collation

All tables use:
- **Character Set**: `utf8mb4` (full Unicode support including emojis)
- **Collation**: `utf8mb4_unicode_ci` (case-insensitive, accent-sensitive)
- **Engine**: InnoDB (ACID compliance, foreign key support)
