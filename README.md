# buyi_cloud

## 促销模型设计 (Promotion Model Design)

本仓库包含布艺云平台的促销管理系统设计。

### 📁 文件说明

- **promotion_model.sql** - 完整的数据库表结构定义（包含示例数据）
- **PROMOTION_MODEL_DESIGN.md** - 详细设计文档（中文）
- **PROMOTION_MODEL_EN.md** - 设计文档（英文）
- **promotion_model_diagram.txt** - 实体关系图
- **buyi_platform_dev.sql** - 原有平台数据库结构

### 🎯 支持的促销类型

1. **折扣促销 (DISCOUNT)** - 百分比或固定金额折扣
2. **满减促销 (FULL_REDUCTION)** - 满X元减Y元
3. **满赠促销 (FULL_GIFT)** - 买X送Y
4. **优惠券 (COUPON)** - 各类优惠券
5. **限时抢购 (FLASH_SALE)** - 秒杀活动
6. **组合套餐 (BUNDLE)** - 商品组合优惠

### 💾 数据库表结构

7个核心表：

1. **promotion_activity** - 促销活动主表
2. **promotion_rule** - 促销规则表
3. **promotion_product** - 促销商品关联表
4. **promotion_coupon** - 优惠券表
5. **promotion_user_coupon** - 用户优惠券表
6. **promotion_usage_record** - 促销使用记录表
7. **promotion_statistics** - 促销统计表

### ✨ 核心特性

- ✅ 支持多种促销类型
- ✅ 灵活的规则配置
- ✅ 预算控制和使用限制
- ✅ 促销叠加支持
- ✅ 用户定向（新用户、VIP等）
- ✅ 平台和地区定向
- ✅ 限时抢购库存管理
- ✅ 完整的使用追踪
- ✅ 统计分析功能

### 🚀 快速开始

执行SQL文件创建促销表：

```bash
mysql -u username -p database_name < promotion_model.sql
```

### 📖 文档

详细文档请查看：
- **PROMOTION_MODEL_DESIGN.md** - 完整的设计文档（中文）
- **PROMOTION_MODEL_EN.md** - 设计规范（英文）
- **promotion_model_diagram.txt** - ER图和关系说明