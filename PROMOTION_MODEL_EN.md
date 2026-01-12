# Promotion Model Design

## Quick Start

This repository contains a comprehensive promotion management system design for the buyi_cloud e-commerce platform.

### Files

- **promotion_model.sql** - Complete database schema with 7 tables for promotion management
- **PROMOTION_MODEL_DESIGN.md** - Detailed design documentation (Chinese)
- **PROMOTION_MODEL_EN.md** - Design documentation (English)
- **promotion_model_diagram.txt** - Entity relationship diagram

### Installation

1. Execute the SQL file to create the promotion tables:
```bash
mysql -u username -p database_name < promotion_model.sql
```

2. The SQL file includes sample data for testing different promotion types.

## Promotion Types Supported

1. **DISCOUNT** - Percentage or fixed amount discounts
2. **FULL_REDUCTION** - Spend X get Y off
3. **FULL_GIFT** - Buy X get free gift
4. **COUPON** - Coupon-based promotions
5. **FLASH_SALE** - Limited time flash sales
6. **BUNDLE** - Product bundle deals

## Database Tables

### Core Tables

1. **promotion_activity** - Main promotion activity information
2. **promotion_rule** - Promotion calculation rules
3. **promotion_product** - Products eligible for promotions
4. **promotion_coupon** - Coupon management
5. **promotion_user_coupon** - User coupon records
6. **promotion_usage_record** - Promotion usage tracking
7. **promotion_statistics** - Daily promotion statistics

## Key Features

- ✅ Multiple promotion types
- ✅ Flexible rule configuration
- ✅ Budget control and usage limits
- ✅ Stackable promotions
- ✅ User-specific promotions (new users, VIP, etc.)
- ✅ Platform and region targeting
- ✅ Real-time inventory for flash sales
- ✅ Comprehensive usage tracking
- ✅ Statistical analysis

## Example Usage

### Creating a Discount Promotion

```sql
-- Create 20% off promotion
INSERT INTO promotion_activity (
  activity_no, activity_name, activity_type,
  start_time, end_time, status
) VALUES (
  'PROMO2026001', 'Winter Sale', 'DISCOUNT',
  '2026-01-01 00:00:00', '2026-01-31 23:59:59', 1
);

-- Add discount rule
INSERT INTO promotion_rule (
  activity_id, rule_type, discount_type, discount_value
) VALUES (
  LAST_INSERT_ID(), 'DISCOUNT', 'PERCENTAGE', 80.00
);
```

### Creating a Coupon

```sql
-- Create $50 off coupon
INSERT INTO promotion_coupon (
  activity_id, coupon_code, coupon_name,
  discount_type, discount_value, min_order_amount
) VALUES (
  1, 'SAVE50', '$50 Off Coupon',
  'FIXED_AMOUNT', 50.00, 100.00
);
```

## Integration with Existing System

The promotion model integrates with existing order tables through:
- Order number references
- Product SKU associations
- User ID tracking
- Discount amount fields

## Documentation

For detailed documentation, see:
- **PROMOTION_MODEL_DESIGN.md** (Chinese) - Complete design document
- **PROMOTION_MODEL_EN.md** (English) - Full design specifications

## Architecture Highlights

- **Flexible Rules**: Support for complex promotion rules with conditions and thresholds
- **Scalability**: Designed for high-concurrency scenarios with proper indexing
- **Tracking**: Complete audit trail of promotion usage
- **Analytics**: Built-in statistics for promotion performance analysis
- **Security**: User limits, budget controls, and concurrent access handling

## Future Enhancements

- AI-powered personalized promotions
- Dynamic pricing based on inventory
- A/B testing framework
- Social sharing capabilities
- Cross-platform promotion sync

## License

This design is part of the buyi_cloud platform project.
