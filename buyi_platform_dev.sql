/*
 Navicat Premium Data Transfer

 Source Server         : buyi_dev
 Source Server Type    : MySQL
 Source Server Version : 80036
 Source Host           : rm-7xvjok8xh5ag728vz.mysql.rds.aliyuncs.com:3306
 Source Schema         : buyi_platform_dev

 Target Server Type    : MySQL
 Target Server Version : 80036
 File Encoding         : 65001

 Date: 19/12/2025 14:40:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for amf_jh_cgorders
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_cgorders`;
CREATE TABLE `amf_jh_cgorders` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `shop` varchar(100) NOT NULL COMMENT '店铺名称',
  `warehouse` varchar(50) NOT NULL COMMENT '仓库名称',
  `purchase_sku` varchar(50) NOT NULL COMMENT '采购SKU',
  `quantity` int NOT NULL COMMENT '订单数量',
  `third_party_order_no` varchar(50) NOT NULL COMMENT '三方订单号',
  `has_transaction` varchar(10) NOT NULL COMMENT '是否产生流水',
  `order_date` datetime NOT NULL COMMENT '订单日期',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_third_party_order_no` (`third_party_order_no`),
  KEY `idx_shop` (`shop`),
  KEY `idx_purchase_sku` (`purchase_sku`),
  KEY `idx_order_date` (`order_date`)
) ENGINE=InnoDB AUTO_INCREMENT=1611 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇系统货权三方订单表';

-- ----------------------------
-- Table structure for amf_jh_comapny_goods_group
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_comapny_goods_group`;
CREATE TABLE `amf_jh_comapny_goods_group` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `sku_code_level_first` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `sku_code_level_second` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `sku_code_level_third` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `sku_code_level_forth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `sku_code_level_fifth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `sku_code_level_six` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for amf_jh_company_goods
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_company_goods`;
CREATE TABLE `amf_jh_company_goods` (
  `id` bigint NOT NULL COMMENT '产品主键ID（原始数据唯一标识）',
  `user_key` varchar(64) NOT NULL COMMENT '用户唯一标识（原始数据：如1719307501061）',
  `company_sku` varchar(64) NOT NULL COMMENT '公司产品SKU编码（原始数据：如WL-FZ-39-W-TJ）',
  `company_sku_img` varchar(255) DEFAULT NULL COMMENT '产品图片URL（原始数据部分为null，允许为空）',
  `company_sku_name` varchar(128) NOT NULL COMMENT '公司产品名称（原始数据：如39寸经济款方桌加插座布袋白色-退件）',
  `create_time` datetime DEFAULT NULL COMMENT '记录创建时间（原始数据为null，不强制默认值）',
  `create_user_id` bigint DEFAULT NULL COMMENT '创建人ID（原始数据为null，允许为空）',
  `flag` varchar(10) NOT NULL COMMENT '产品状态标识（原始数据为"2"，如2=退件）',
  `is_shelves` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否上架（原始数据为0，推测0=未上架、1=已上架）',
  `operate_director_id` bigint DEFAULT NULL COMMENT '运营负责人ID（原始数据为null，允许为空）',
  `operate_user_id` bigint DEFAULT NULL COMMENT '最后操作人ID（原始数据为null，允许为空）',
  `pageNum` int DEFAULT NULL COMMENT '分页页码（原始数据查询参数字段，保留存储）',
  `pageSize` int DEFAULT NULL COMMENT '分页条数（原始数据查询参数字段，保留存储）',
  `pageStart` int DEFAULT NULL COMMENT '分页起始位置（原始数据查询参数字段，保留存储）',
  `pro_wh_product_info` varchar(528) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品-仓库关联信息（原始数据格式：仓库SKU,数量,时间）',
  `search_key` varchar(64) DEFAULT NULL COMMENT '搜索关键词（原始数据查询参数字段，保留存储）',
  `search_sku` varchar(64) DEFAULT NULL COMMENT 'SKU搜索词（原始数据查询参数字段，保留存储）',
  `sell_count` int DEFAULT NULL COMMENT '产品累计销售数量（原始数据为null，允许为空）',
  `update_time` datetime DEFAULT NULL COMMENT '记录最后更新时间（原始数据为null，不强制默认值）',
  `update_user_id` bigint DEFAULT NULL COMMENT '最后更新人ID（原始数据为null，允许为空）',
  `update_user_name` varchar(64) DEFAULT NULL COMMENT '最后更新人姓名（原始数据为null，允许为空）',
  `itemlist` json DEFAULT NULL,
  `updat` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_sku` (`company_sku`),
  KEY `idx_user_key` (`user_key`),
  KEY `idx_flag_is_shelves` (`flag`,`is_shelves`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='公司产品信息主表（保留原始数据所有字段）';

-- ----------------------------
-- Table structure for amf_jh_company_goods_item
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_company_goods_item`;
CREATE TABLE `amf_jh_company_goods_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '子表主键ID（自增，原始itemList.id为null）',
  `user_key` varchar(64) DEFAULT NULL COMMENT '用户唯一标识（与主表user_key关联，原始itemList为null）',
  `company_product_id` bigint NOT NULL COMMENT '关联主表产品ID（对应amf_jh_company_goods.id，原始itemList为null）',
  `warehouse_sku` varchar(64) NOT NULL COMMENT '仓库SKU编码（原始itemList：如WL-HGFZ-BG47-B-TJ）',
  `warehouse_sku_num` int DEFAULT NULL COMMENT '仓库SKU数量（原始itemList：如1）',
  `create_user_id` bigint DEFAULT NULL COMMENT '创建人ID（原始itemList为null，允许为空）',
  `create_time` datetime DEFAULT NULL COMMENT '子表记录创建时间（原始itemList为null，允许为空）',
  `update_time` datetime DEFAULT NULL COMMENT '子表记录更新时间（原始itemList：如2024-06-26 14:53:17）',
  `p_length` decimal(10,2) DEFAULT NULL COMMENT '产品长度（单位：如cm，原始itemList为null，支持小数）',
  `p_width` decimal(10,2) DEFAULT NULL COMMENT '产品宽度（单位：如cm，原始itemList为null，支持小数）',
  `p_height` decimal(10,2) DEFAULT NULL COMMENT '产品高度（单位：如cm，原始itemList为null，支持小数）',
  `net_weight` decimal(10,2) DEFAULT NULL COMMENT '产品净重（单位：如kg，原始itemList为null，支持小数）',
  `search_key` varchar(64) DEFAULT NULL COMMENT '搜索关键词（原始itemList为null，保留存储）',
  `warehouse_sku_name` varchar(128) DEFAULT NULL COMMENT '仓库SKU名称（原始itemList为null，允许为空）',
  `name_cn` varchar(128) DEFAULT NULL COMMENT '产品中文名称（原始itemList为null，允许为空）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux` (`company_product_id`,`warehouse_sku`) USING BTREE,
  KEY `idx_company_product_id` (`company_product_id`),
  KEY `idx_warehouse_sku` (`warehouse_sku`),
  KEY `idx_user_warehouse_num` (`user_key`,`warehouse_sku`,`warehouse_sku_num`),
  CONSTRAINT `fk_item_company_product` FOREIGN KEY (`company_product_id`) REFERENCES `amf_jh_company_goods` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13443 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='公司产品-仓库SKU关联子表';

-- ----------------------------
-- Table structure for amf_jh_company_stock
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_company_stock`;
CREATE TABLE `amf_jh_company_stock` (
  `order_date` varchar(255) DEFAULT NULL,
  `business` varchar(255) DEFAULT NULL,
  `account` varchar(255) DEFAULT NULL,
  `local_sku` varchar(255) DEFAULT NULL,
  `factory_code` varchar(255) DEFAULT NULL,
  `remaining_num` int DEFAULT NULL,
  `stock_num` int DEFAULT NULL,
  `create_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `sync_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for amf_jh_ecommerce
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_ecommerce`;
CREATE TABLE `amf_jh_ecommerce` (
  `id` int NOT NULL COMMENT '平台ID',
  `user_key` varchar(50) DEFAULT NULL COMMENT '用户键',
  `platform_name` varchar(50) NOT NULL COMMENT '平台名称',
  `platform_type` tinyint DEFAULT NULL COMMENT '平台类型',
  `business_type` tinyint DEFAULT NULL COMMENT '业务类型',
  `supported_access_way` varchar(255) DEFAULT NULL COMMENT '支持的接入方式',
  `logo_url` varchar(255) DEFAULT NULL COMMENT 'Logo URL',
  `status` tinyint DEFAULT NULL COMMENT '状态',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `is_access` tinyint DEFAULT NULL COMMENT '是否接入',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `file_order_url` varchar(255) DEFAULT NULL COMMENT '订单上传模板URL',
  PRIMARY KEY (`id`),
  KEY `idx_platform_name` (`platform_name`),
  KEY `idx_platform_type` (`platform_type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇电商平台基础资料表';

-- ----------------------------
-- Table structure for amf_jh_orders
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_orders`;
CREATE TABLE `amf_jh_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `sys_number` varchar(50) DEFAULT NULL COMMENT '系统编号',
  `oa_order_id` bigint DEFAULT NULL COMMENT 'OA订单ID',
  `order_sell_product_id` bigint DEFAULT NULL COMMENT '订单销售产品ID',
  `order_wh_product_id` bigint DEFAULT NULL COMMENT '订单仓库产品ID',
  `user_key` varchar(50) DEFAULT NULL COMMENT '用户标识',
  `erp_order_no` varchar(50) DEFAULT NULL COMMENT 'ERP订单号',
  `show_order_no` varchar(50) DEFAULT NULL COMMENT '显示订单号',
  `customer_order_no` varchar(50) DEFAULT NULL COMMENT '客户订单号',
  `order_item_id` varchar(50) DEFAULT NULL COMMENT '订单项ID',
  `shop_id` int DEFAULT NULL COMMENT '店铺ID',
  `shop_show_name` varchar(255) DEFAULT NULL COMMENT '店铺显示名称',
  `order_status` varchar(20) DEFAULT NULL COMMENT '订单状态',
  `trouble_type` varchar(20) DEFAULT NULL COMMENT '问题类型',
  `trouble_reason` varchar(255) DEFAULT NULL COMMENT '问题原因',
  `platform_name` varchar(50) DEFAULT NULL COMMENT '平台名称',
  `platform_type` int DEFAULT NULL COMMENT '平台类型',
  `platform_category_id` varchar(50) DEFAULT NULL COMMENT '平台分类ID',
  `country_code` varchar(10) DEFAULT NULL COMMENT '国家代码',
  `purchase_date` datetime DEFAULT NULL COMMENT '购买日期',
  `order_create_time` datetime DEFAULT NULL COMMENT '订单创建时间',
  `order_update_time` datetime DEFAULT NULL COMMENT '订单更新时间',
  `latest_ship_date` datetime DEFAULT NULL COMMENT '最晚发货日期',
  `handle_time` datetime DEFAULT NULL COMMENT '处理时间',
  `allocation_time` datetime DEFAULT NULL COMMENT '分配时间',
  `label_generate_time` datetime DEFAULT NULL COMMENT '标签生成时间',
  `review_time` datetime DEFAULT NULL COMMENT '审核时间',
  `push_wms_time` datetime DEFAULT NULL COMMENT '推送WMS时间',
  `upload_track_time` datetime DEFAULT NULL COMMENT '上传追踪时间',
  `upload_invoice_time` datetime DEFAULT NULL COMMENT '上传发票时间',
  `delivery_time` datetime DEFAULT NULL COMMENT '发货时间',
  `promisedDeliveryDate` datetime DEFAULT NULL COMMENT '承诺送达日期',
  `dwd_create_time` datetime DEFAULT NULL COMMENT 'DWD创建时间',
  `dwd_update_time` datetime DEFAULT NULL COMMENT 'DWD更新时间',
  `sell_sku` varchar(100) DEFAULT NULL COMMENT '销售SKU',
  `sell_sku_name` varchar(255) DEFAULT NULL COMMENT '销售SKU名称',
  `warehouse_sku` varchar(100) DEFAULT NULL COMMENT '仓库SKU',
  `thirdparty_warehouse_sku` varchar(100) DEFAULT NULL COMMENT '第三方仓库SKU',
  `wh_product_name_cn` varchar(255) DEFAULT NULL COMMENT '仓库产品中文名',
  `wh_product_name_en` varchar(255) DEFAULT NULL COMMENT '仓库产品英文名',
  `warehouse_sku_num` int DEFAULT NULL COMMENT '仓库SKU数量',
  `company_sku` varchar(100) DEFAULT NULL COMMENT '公司SKU',
  `quantity_ordered` int DEFAULT NULL COMMENT '订购数量',
  `purchase_value` decimal(18,2) DEFAULT NULL COMMENT '采购价值',
  `item_price_money` decimal(18,2) DEFAULT NULL COMMENT '商品价格金额',
  `order_total_money` decimal(18,2) DEFAULT NULL COMMENT '订单总金额',
  `shipping_price_money` decimal(18,2) DEFAULT NULL COMMENT '运费金额',
  `gift_wrap_price_money` decimal(18,2) DEFAULT NULL COMMENT '礼品包装价格金额',
  `shipping_tax_money` decimal(18,2) DEFAULT NULL COMMENT '运费税金额',
  `shipping_discount_money` decimal(18,2) DEFAULT NULL COMMENT '运费折扣金额',
  `promotion_discount_money` decimal(18,2) DEFAULT NULL COMMENT '促销折扣金额',
  `fee_currency_code` varchar(10) DEFAULT NULL COMMENT '费用货币代码',
  `fee_currenty_code` varchar(10) DEFAULT NULL COMMENT '费用货币代码(备用)',
  `name` varchar(100) DEFAULT NULL COMMENT '收件人姓名',
  `phone` varchar(50) DEFAULT NULL COMMENT '收件人电话',
  `state_or_province` varchar(50) DEFAULT NULL COMMENT '州/省',
  `city_name` varchar(100) DEFAULT NULL COMMENT '城市名称',
  `postal_code` varchar(50) DEFAULT NULL COMMENT '邮政编码',
  `address_line1` varchar(255) DEFAULT NULL COMMENT '地址行1',
  `address_line2` varchar(255) DEFAULT NULL COMMENT '地址行2',
  `warehouse_id` int DEFAULT NULL COMMENT '仓库ID',
  `shop_assign_warehouse_id` varchar(50) DEFAULT NULL COMMENT '店铺分配仓库ID',
  `warehouse_name` varchar(255) DEFAULT NULL COMMENT '仓库名称',
  `out_warehouse_code` varchar(50) DEFAULT NULL COMMENT '出库代码',
  `wh_shipping_method_id` int DEFAULT NULL COMMENT '仓库配送方式ID',
  `wh_shipping_method_code` varchar(50) DEFAULT NULL COMMENT '仓库配送方式代码',
  `carrier_code` varchar(50) DEFAULT NULL COMMENT '承运商代码',
  `carrier_channel_code` varchar(50) DEFAULT NULL COMMENT '承运商渠道代码',
  `out_carrier_code` varchar(50) DEFAULT NULL COMMENT '外部承运商代码',
  `out_carrier_channel_code` varchar(50) DEFAULT NULL COMMENT '外部承运商渠道代码',
  `tracking_number` varchar(100) DEFAULT NULL COMMENT '追踪号',
  `fulfillment_channel` int DEFAULT NULL COMMENT '履行渠道',
  `p_length` decimal(10,2) DEFAULT NULL COMMENT '产品长度',
  `p_width` decimal(10,2) DEFAULT NULL COMMENT '产品宽度',
  `p_height` decimal(10,2) DEFAULT NULL COMMENT '产品高度',
  `p_length_out` decimal(10,2) DEFAULT NULL COMMENT '产品出库长度',
  `p_width_out` decimal(10,2) DEFAULT NULL COMMENT '产品出库宽度',
  `p_height_out` decimal(10,2) DEFAULT NULL COMMENT '产品出库高度',
  `net_weight` decimal(10,2) DEFAULT NULL COMMENT '净重',
  `rough_weight` decimal(10,2) DEFAULT NULL COMMENT '毛重',
  `purchase_user_id` int DEFAULT NULL COMMENT '采购用户ID',
  `purchase_user_name` varchar(100) DEFAULT NULL COMMENT '采购用户姓名',
  `operate_user_id` int DEFAULT NULL COMMENT '操作用户ID',
  `operate_user_name` varchar(100) DEFAULT NULL COMMENT '操作用户姓名',
  `operate_director_id` int DEFAULT NULL COMMENT '操作主管ID',
  `operate_director_name` varchar(100) DEFAULT NULL COMMENT '操作主管姓名',
  `title` varchar(255) DEFAULT NULL COMMENT '标题',
  `img_url` varchar(255) DEFAULT NULL COMMENT '图片URL',
  `order_remark` varchar(255) DEFAULT NULL COMMENT '订单备注',
  `service_remark` varchar(255) DEFAULT NULL COMMENT '服务备注',
  `asin` varchar(50) DEFAULT NULL COMMENT 'ASIN',
  `buyerProductIdentifier` varchar(100) DEFAULT NULL COMMENT '买家产品标识符',
  `shop_order_no` varchar(50) DEFAULT NULL COMMENT '店铺订单号',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux` (`oa_order_id`,`order_sell_product_id`,`show_order_no`,`sell_sku`,`warehouse_sku`) USING BTREE,
  KEY `idx_erp_order_no` (`erp_order_no`),
  KEY `idx_show_order_no` (`show_order_no`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_platform_name` (`platform_name`),
  KEY `idx_purchase_date` (`purchase_date`),
  KEY `idx_sell_sku` (`sell_sku`),
  KEY `idx_user_key` (`user_key`),
  KEY `idx_order_create_time` (`order_create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=490706 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇销售订单表';

-- ----------------------------
-- Table structure for amf_jh_ordersbak20251202
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_ordersbak20251202`;
CREATE TABLE `amf_jh_ordersbak20251202` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `sys_number` varchar(50) DEFAULT NULL COMMENT '系统编号',
  `oa_order_id` bigint DEFAULT NULL COMMENT 'OA订单ID',
  `order_sell_product_id` bigint DEFAULT NULL COMMENT '订单销售产品ID',
  `order_wh_product_id` bigint DEFAULT NULL COMMENT '订单仓库产品ID',
  `user_key` varchar(50) DEFAULT NULL COMMENT '用户标识',
  `erp_order_no` varchar(50) DEFAULT NULL COMMENT 'ERP订单号',
  `show_order_no` varchar(50) DEFAULT NULL COMMENT '显示订单号',
  `customer_order_no` varchar(50) DEFAULT NULL COMMENT '客户订单号',
  `order_item_id` varchar(50) DEFAULT NULL COMMENT '订单项ID',
  `shop_id` int DEFAULT NULL COMMENT '店铺ID',
  `shop_show_name` varchar(255) DEFAULT NULL COMMENT '店铺显示名称',
  `order_status` varchar(20) DEFAULT NULL COMMENT '订单状态',
  `trouble_type` varchar(20) DEFAULT NULL COMMENT '问题类型',
  `trouble_reason` varchar(255) DEFAULT NULL COMMENT '问题原因',
  `platform_name` varchar(50) DEFAULT NULL COMMENT '平台名称',
  `platform_type` int DEFAULT NULL COMMENT '平台类型',
  `platform_category_id` varchar(50) DEFAULT NULL COMMENT '平台分类ID',
  `country_code` varchar(10) DEFAULT NULL COMMENT '国家代码',
  `purchase_date` datetime DEFAULT NULL COMMENT '购买日期',
  `order_create_time` datetime DEFAULT NULL COMMENT '订单创建时间',
  `order_update_time` datetime DEFAULT NULL COMMENT '订单更新时间',
  `latest_ship_date` datetime DEFAULT NULL COMMENT '最晚发货日期',
  `handle_time` datetime DEFAULT NULL COMMENT '处理时间',
  `allocation_time` datetime DEFAULT NULL COMMENT '分配时间',
  `label_generate_time` datetime DEFAULT NULL COMMENT '标签生成时间',
  `review_time` datetime DEFAULT NULL COMMENT '审核时间',
  `push_wms_time` datetime DEFAULT NULL COMMENT '推送WMS时间',
  `upload_track_time` datetime DEFAULT NULL COMMENT '上传追踪时间',
  `upload_invoice_time` datetime DEFAULT NULL COMMENT '上传发票时间',
  `delivery_time` datetime DEFAULT NULL COMMENT '发货时间',
  `promisedDeliveryDate` datetime DEFAULT NULL COMMENT '承诺送达日期',
  `dwd_create_time` datetime DEFAULT NULL COMMENT 'DWD创建时间',
  `dwd_update_time` datetime DEFAULT NULL COMMENT 'DWD更新时间',
  `sell_sku` varchar(100) DEFAULT NULL COMMENT '销售SKU',
  `sell_sku_name` varchar(255) DEFAULT NULL COMMENT '销售SKU名称',
  `warehouse_sku` varchar(100) DEFAULT NULL COMMENT '仓库SKU',
  `thirdparty_warehouse_sku` varchar(100) DEFAULT NULL COMMENT '第三方仓库SKU',
  `wh_product_name_cn` varchar(255) DEFAULT NULL COMMENT '仓库产品中文名',
  `wh_product_name_en` varchar(255) DEFAULT NULL COMMENT '仓库产品英文名',
  `warehouse_sku_num` int DEFAULT NULL COMMENT '仓库SKU数量',
  `company_sku` varchar(100) DEFAULT NULL COMMENT '公司SKU',
  `quantity_ordered` int DEFAULT NULL COMMENT '订购数量',
  `purchase_value` decimal(18,2) DEFAULT NULL COMMENT '采购价值',
  `item_price_money` decimal(18,2) DEFAULT NULL COMMENT '商品价格金额',
  `order_total_money` decimal(18,2) DEFAULT NULL COMMENT '订单总金额',
  `shipping_price_money` decimal(18,2) DEFAULT NULL COMMENT '运费金额',
  `gift_wrap_price_money` decimal(18,2) DEFAULT NULL COMMENT '礼品包装价格金额',
  `shipping_tax_money` decimal(18,2) DEFAULT NULL COMMENT '运费税金额',
  `shipping_discount_money` decimal(18,2) DEFAULT NULL COMMENT '运费折扣金额',
  `promotion_discount_money` decimal(18,2) DEFAULT NULL COMMENT '促销折扣金额',
  `fee_currency_code` varchar(10) DEFAULT NULL COMMENT '费用货币代码',
  `fee_currenty_code` varchar(10) DEFAULT NULL COMMENT '费用货币代码(备用)',
  `name` varchar(100) DEFAULT NULL COMMENT '收件人姓名',
  `phone` varchar(50) DEFAULT NULL COMMENT '收件人电话',
  `state_or_province` varchar(50) DEFAULT NULL COMMENT '州/省',
  `city_name` varchar(100) DEFAULT NULL COMMENT '城市名称',
  `postal_code` varchar(50) DEFAULT NULL COMMENT '邮政编码',
  `address_line1` varchar(255) DEFAULT NULL COMMENT '地址行1',
  `address_line2` varchar(255) DEFAULT NULL COMMENT '地址行2',
  `warehouse_id` int DEFAULT NULL COMMENT '仓库ID',
  `shop_assign_warehouse_id` varchar(50) DEFAULT NULL COMMENT '店铺分配仓库ID',
  `warehouse_name` varchar(255) DEFAULT NULL COMMENT '仓库名称',
  `out_warehouse_code` varchar(50) DEFAULT NULL COMMENT '出库代码',
  `wh_shipping_method_id` int DEFAULT NULL COMMENT '仓库配送方式ID',
  `wh_shipping_method_code` varchar(50) DEFAULT NULL COMMENT '仓库配送方式代码',
  `carrier_code` varchar(50) DEFAULT NULL COMMENT '承运商代码',
  `carrier_channel_code` varchar(50) DEFAULT NULL COMMENT '承运商渠道代码',
  `out_carrier_code` varchar(50) DEFAULT NULL COMMENT '外部承运商代码',
  `out_carrier_channel_code` varchar(50) DEFAULT NULL COMMENT '外部承运商渠道代码',
  `tracking_number` varchar(100) DEFAULT NULL COMMENT '追踪号',
  `fulfillment_channel` int DEFAULT NULL COMMENT '履行渠道',
  `p_length` decimal(10,2) DEFAULT NULL COMMENT '产品长度',
  `p_width` decimal(10,2) DEFAULT NULL COMMENT '产品宽度',
  `p_height` decimal(10,2) DEFAULT NULL COMMENT '产品高度',
  `p_length_out` decimal(10,2) DEFAULT NULL COMMENT '产品出库长度',
  `p_width_out` decimal(10,2) DEFAULT NULL COMMENT '产品出库宽度',
  `p_height_out` decimal(10,2) DEFAULT NULL COMMENT '产品出库高度',
  `net_weight` decimal(10,2) DEFAULT NULL COMMENT '净重',
  `rough_weight` decimal(10,2) DEFAULT NULL COMMENT '毛重',
  `purchase_user_id` int DEFAULT NULL COMMENT '采购用户ID',
  `purchase_user_name` varchar(100) DEFAULT NULL COMMENT '采购用户姓名',
  `operate_user_id` int DEFAULT NULL COMMENT '操作用户ID',
  `operate_user_name` varchar(100) DEFAULT NULL COMMENT '操作用户姓名',
  `operate_director_id` int DEFAULT NULL COMMENT '操作主管ID',
  `operate_director_name` varchar(100) DEFAULT NULL COMMENT '操作主管姓名',
  `title` varchar(255) DEFAULT NULL COMMENT '标题',
  `img_url` varchar(255) DEFAULT NULL COMMENT '图片URL',
  `order_remark` varchar(255) DEFAULT NULL COMMENT '订单备注',
  `service_remark` varchar(255) DEFAULT NULL COMMENT '服务备注',
  `asin` varchar(50) DEFAULT NULL COMMENT 'ASIN',
  `buyerProductIdentifier` varchar(100) DEFAULT NULL COMMENT '买家产品标识符',
  `shop_order_no` varchar(50) DEFAULT NULL COMMENT '店铺订单号',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux` (`oa_order_id`,`order_sell_product_id`,`order_wh_product_id`) USING BTREE,
  KEY `idx_erp_order_no` (`erp_order_no`),
  KEY `idx_show_order_no` (`show_order_no`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_platform_name` (`platform_name`),
  KEY `idx_purchase_date` (`purchase_date`),
  KEY `idx_sell_sku` (`sell_sku`),
  KEY `idx_user_key` (`user_key`),
  KEY `idx_order_create_time` (`order_create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=247567 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇销售订单表';

-- ----------------------------
-- Table structure for amf_jh_purchase_goods
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_purchase_goods`;
CREATE TABLE `amf_jh_purchase_goods` (
  `id` bigint unsigned NOT NULL COMMENT '商品唯一ID（接口返回的id字段，非自增，确保与后端一致）',
  `user_key` varchar(50) NOT NULL COMMENT '用户标识（接口返回的user_key，用于用户数据隔离）',
  `warehouse_sku` varchar(50) NOT NULL COMMENT '仓库商品SKU（唯一编码，如：AC-ZHYJ-CBGFB-WHITE-B）',
  `name_cn` varchar(200) NOT NULL COMMENT '商品中文名称（如：DKS-505组合右侧层板柜分包款白色-B包）',
  `name_en` varchar(200) NOT NULL COMMENT '商品英文名称（如：AC-ZHYJ-CBGFB-WHITE-B）',
  `category` varchar(50) DEFAULT NULL COMMENT '商品一级分类（接口返回为null，预留字段）',
  `category_id` int unsigned DEFAULT NULL COMMENT '一级分类ID（预留字段）',
  `category_two_id` int unsigned DEFAULT NULL COMMENT '二级分类ID（预留字段）',
  `purchase_category_id` int unsigned DEFAULT NULL COMMENT '采购分类ID（预留字段）',
  `purchase_category_ids` varchar(100) DEFAULT NULL COMMENT '采购分类IDs（多个用逗号分隔，预留字段）',
  `purchase_category_attribute_id` int unsigned DEFAULT NULL COMMENT '采购分类属性ID（预留字段）',
  `rough_weight` decimal(10,2) DEFAULT NULL COMMENT '商品毛重（单位：kg，如：27.45）',
  `net_weight` decimal(10,2) DEFAULT NULL COMMENT '商品净重（单位：kg，如：25.45）',
  `p_length` decimal(10,2) DEFAULT NULL COMMENT '商品长度（单位：cm，如：109）',
  `p_width` decimal(10,2) DEFAULT NULL COMMENT '商品宽度（单位：cm，如：48.5）',
  `p_height` decimal(10,2) DEFAULT NULL COMMENT '商品高度（单位：cm，如：15）',
  `p_length_out` decimal(10,2) DEFAULT NULL COMMENT '外箱长度（单位：cm，如：109）',
  `p_width_out` decimal(10,2) DEFAULT NULL COMMENT '外箱宽度（单位：cm，如：48.5）',
  `p_height_out` decimal(10,2) DEFAULT NULL COMMENT '外箱高度（单位：cm，如：15）',
  `outerbox_number` int unsigned DEFAULT '0' COMMENT '外箱数量（如：1）',
  `out_box_rough_weight` decimal(10,2) DEFAULT NULL COMMENT '外箱毛重（单位：kg，如：27.45）',
  `out_box_net_weight` decimal(10,2) DEFAULT NULL COMMENT '外箱净重（单位：kg，如：25.45）',
  `purchase_value` decimal(12,2) DEFAULT NULL COMMENT '采购价值（如：70）',
  `purchase_currency` varchar(10) DEFAULT NULL COMMENT '采购货币类型（如：USD）',
  `purchase_user_id` int unsigned DEFAULT NULL COMMENT '采购负责人ID（预留字段）',
  `purchase_user_name` varchar(50) DEFAULT NULL COMMENT '采购负责人姓名（预留字段）',
  `purchase_dept_id` int unsigned DEFAULT NULL COMMENT '采购部门ID（预留字段）',
  `purchase_dept_ids` varchar(100) DEFAULT NULL COMMENT '采购部门IDs（多个用逗号分隔，预留字段）',
  `p_status` varchar(50) DEFAULT NULL COMMENT '商品状态（如：onlineproduct-在线商品）',
  `p_nature` varchar(50) DEFAULT NULL COMMENT '商品性质（预留字段）',
  `unint` varchar(20) DEFAULT NULL COMMENT '商品单位（预留字段，接口返回为null）',
  `upc_code` varchar(50) DEFAULT NULL COMMENT 'UPC编码（商品条码，预留字段）',
  `hs_code` varchar(50) DEFAULT NULL COMMENT 'HS编码（海关编码，预留字段）',
  `declare_name_cn` varchar(200) DEFAULT NULL COMMENT '中文申报名称（预留字段）',
  `declare_name_en` varchar(200) DEFAULT NULL COMMENT '英文申报名称（预留字段）',
  `haul_cycle` varchar(50) DEFAULT NULL COMMENT '运输周期（预留字段）',
  `purchase_cycle` varchar(50) DEFAULT NULL COMMENT '采购周期（预留字段）',
  `is_split` char(1) DEFAULT '0' COMMENT '是否可拆分（0-否，1-是，接口返回为0）',
  `is_parts` char(1) DEFAULT '0' COMMENT '是否为配件（0-否，1-是，接口返回为0）',
  `parts_num` int unsigned DEFAULT '0' COMMENT '配件数量（如：0）',
  `launch_time` datetime DEFAULT NULL COMMENT '上线时间（预留字段）',
  `factory_id` int unsigned DEFAULT NULL COMMENT '工厂ID（预留字段）',
  `factory_name` varchar(100) DEFAULT NULL COMMENT '工厂名称（预留字段）',
  `img_url` varchar(500) DEFAULT NULL COMMENT '商品图片URL（预留字段）',
  `fileName` varchar(100) DEFAULT NULL COMMENT '文件名（预留字段，如导入文件名称）',
  `user_dept_ids` varchar(100) DEFAULT '[]' COMMENT '用户部门IDs（JSON格式字符串，如："[]"）',
  `search_key` varchar(100) DEFAULT NULL COMMENT '搜索关键词（预留字段）',
  `search_key_list` varchar(200) DEFAULT NULL COMMENT '搜索关键词列表（多个用逗号分隔，预留字段）',
  `search_sku` varchar(50) DEFAULT NULL COMMENT '搜索SKU（预留字段）',
  `search_sku_list` varchar(200) DEFAULT NULL COMMENT '搜索SKU列表（多个用逗号分隔，预留字段）',
  `query_type` varchar(50) DEFAULT NULL COMMENT '查询类型（预留字段，如：普通查询、高级查询）',
  `child_product_information` text COMMENT '子商品信息（JSON格式文本，预留字段）',
  `is_child_product_information` tinyint unsigned DEFAULT NULL COMMENT '是否为子商品信息（0-否，1-是，预留字段）',
  `warehouse_sku_list` varchar(500) DEFAULT NULL COMMENT '仓库SKU列表（多个用逗号分隔，预留字段）',
  `proWhProductFactoryList` text COMMENT '商品工厂关联列表（JSON格式文本，预留字段）',
  `proWhProductShipmentList` text COMMENT '商品运输关联列表（JSON格式文本，接口返回为空数组）',
  `itemList` text COMMENT '项目列表1（JSON格式文本，预留字段）',
  `itemList2` text COMMENT '项目列表2（JSON格式文本，预留字段）',
  `itemList3` text COMMENT '项目列表3（JSON格式文本，预留字段）',
  `params` text COMMENT '接口请求参数（JSON格式文本，接口返回为null）',
  `pageStart` int unsigned DEFAULT '0' COMMENT '分页起始位置（如：0，接口返回字段）',
  `resultMsg` varchar(100) DEFAULT NULL COMMENT '接口返回消息（成功/失败描述，接口返回为null）',
  `failReason` varchar(200) DEFAULT NULL COMMENT '失败原因（接口返回为null，预留字段）',
  `create_time` datetime NOT NULL COMMENT '记录创建时间（如：2025-11-26 15:06）',
  `update_time` datetime NOT NULL COMMENT '记录更新时间（如：2025-11-26 15:06）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_sku` (`warehouse_sku`) COMMENT '仓库SKU唯一，避免重复商品',
  KEY `idx_user_key` (`user_key`) COMMENT '用户标识索引，用于筛选用户名下商品',
  KEY `idx_p_status` (`p_status`) COMMENT '商品状态索引，用于筛选不同状态商品',
  KEY `idx_create_time` (`create_time`) COMMENT '创建时间索引，用于按时间范围查询'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库采购商品表（对应warehouse/list接口数据结构）';

-- ----------------------------
-- Table structure for amf_jh_sell_goods
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_sell_goods`;
CREATE TABLE `amf_jh_sell_goods` (
  `id` bigint NOT NULL COMMENT '商品ID（主键）',
  `user_key` varchar(64) NOT NULL COMMENT '用户标识',
  `sell_sku` varchar(64) NOT NULL COMMENT '销售SKU',
  `shop_name` varchar(64) NOT NULL COMMENT '店铺名称',
  `operate_user_id` int NOT NULL COMMENT '操作人ID',
  `operate_user_name` varchar(32) NOT NULL COMMENT '操作人姓名',
  `sell_sku_name` varchar(128) NOT NULL COMMENT '销售SKU名称',
  `sell_sku_img` varchar(255) DEFAULT NULL COMMENT '销售SKU图片URL（可为空）',
  `operate_director_id` int DEFAULT NULL COMMENT '操作主管ID（可为空）',
  `operate_director_name` varchar(32) DEFAULT NULL COMMENT '操作主管姓名（可为空）',
  `shop_id` int NOT NULL COMMENT '店铺ID',
  `is_shelves` tinyint NOT NULL COMMENT '是否上架：0=未上架，1=已上架',
  `asin` varchar(64) DEFAULT NULL COMMENT '亚马逊ASIN码（可为空）',
  `is_upload_stock` tinyint NOT NULL COMMENT '是否上传库存：0=否，1=是',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user_id` int NOT NULL COMMENT '创建人ID',
  `user_dept_ids` varchar(128) DEFAULT NULL COMMENT '用户部门ID列表（可为空，如“1,2,3”）',
  `user_dept_ids2` varchar(128) DEFAULT NULL COMMENT '用户部门ID列表2（扩展字段，可为空）',
  `file_name` varchar(128) DEFAULT NULL COMMENT '文件名（可为空）',
  `search_key` varchar(128) DEFAULT NULL COMMENT '搜索关键词（可为空）',
  `search_key_list` varchar(255) DEFAULT NULL COMMENT '搜索关键词列表（可为空，如“桌,黑色”）',
  `stock_num` int DEFAULT NULL COMMENT '库存数量（可为空）',
  `is_split` tinyint NOT NULL COMMENT '是否可拆分：0=否，1=是',
  `max_split_num` int DEFAULT NULL COMMENT '最大拆分数量（可为空）',
  `is_scale_upload_stock` tinyint NOT NULL COMMENT '是否按比例上传库存：0=否，1=是',
  `company_sku` varchar(64) NOT NULL COMMENT '公司内部SKU',
  `platform_type` varchar(32) DEFAULT NULL COMMENT '平台类型（如“Walmart”，可为空）',
  `sellable_qty` int DEFAULT NULL COMMENT '可售数量（可为空）',
  `platform_name` varchar(64) DEFAULT NULL COMMENT '平台名称（可为空）',
  `shop_show_name` varchar(64) DEFAULT NULL COMMENT '店铺展示名称（可为空）',
  `shop_auth_status` tinyint DEFAULT NULL COMMENT '店铺授权状态：0=未授权，1=已授权（可为空）',
  `shop_status` tinyint DEFAULT NULL COMMENT '店铺状态：0=禁用，1=正常（可为空）',
  `platform_category_name` varchar(64) DEFAULT NULL COMMENT '平台类目名称（可为空）',
  `platform_category_id` varchar(64) DEFAULT NULL COMMENT '平台类目ID（可为空）',
  `platform_category_ids` varchar(128) DEFAULT NULL COMMENT '平台类目ID列表（可为空，如“101,102”）',
  `is_has_warehouse` tinyint DEFAULT NULL COMMENT '是否有仓库：0=否，1=是（可为空）',
  `upload_status` tinyint DEFAULT NULL COMMENT '上传状态：0=未上传，1=已上传（可为空）',
  `is_auto_cal_inventory` tinyint DEFAULT NULL COMMENT '是否自动计算库存：0=否，1=是（可为空）',
  `purchase_sku` varchar(64) DEFAULT NULL COMMENT '采购SKU（可为空）',
  `stock_up_days` int DEFAULT NULL COMMENT '备货天数（可为空）',
  `query_type` varchar(32) DEFAULT NULL COMMENT '查询类型（可为空）',
  PRIMARY KEY (`id`) COMMENT '主键索引',
  KEY `idx_shop_id` (`shop_id`) COMMENT '店铺ID索引（优化店铺维度查询）',
  KEY `idx_create_time` (`create_time`) COMMENT '创建时间索引（优化时间范围查询）',
  KEY `idx_company_sku` (`company_sku`) COMMENT '公司SKU索引（优化内部SKU查询）',
  KEY `uk_sell_sku` (`sell_sku`) USING BTREE COMMENT '销售SKU索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='销售商品主表';

-- ----------------------------
-- Table structure for amf_jh_sell_goods_item
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_sell_goods_item`;
CREATE TABLE `amf_jh_sell_goods_item` (
  `id` bigint NOT NULL COMMENT '明细ID（主键）',
  `sell_goods_id` bigint NOT NULL COMMENT '关联销售商品ID（对应amf_jh_sell_goods.id）',
  `user_key` varchar(64) NOT NULL COMMENT '用户标识（与主表一致）',
  `warehouse_sku` varchar(64) NOT NULL COMMENT '仓库SKU',
  `warehouse_name` varchar(128) NOT NULL COMMENT '仓库商品名称',
  `warehouse_sku_num` int NOT NULL COMMENT '仓库SKU数量（关联比例）',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_user_id` int NOT NULL COMMENT '创建人ID',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `shop_id` int NOT NULL COMMENT '店铺ID（与主表一致）',
  `company_wh_product_relation_id` bigint DEFAULT NULL COMMENT '公司仓库商品关联ID（可为空）',
  `scale_num` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '比例系数（默认0.00）',
  `p_length` decimal(10,2) NOT NULL COMMENT '商品长度（单位：cm）',
  `p_width` decimal(10,2) NOT NULL COMMENT '商品宽度（单位：cm）',
  `p_height` decimal(10,2) NOT NULL COMMENT '商品高度（单位：cm）',
  `net_weight` decimal(10,2) NOT NULL COMMENT '商品净重（单位：kg）',
  `search_key` varchar(128) DEFAULT NULL COMMENT '搜索关键词（可为空）',
  PRIMARY KEY (`id`) COMMENT '主键索引',
  KEY `idx_sell_goods_id` (`sell_goods_id`) COMMENT '关联商品ID索引（优化主从表联查）',
  KEY `idx_shop_id` (`shop_id`) COMMENT '店铺ID索引',
  KEY `uk_warehouse_sku` (`warehouse_sku`) USING BTREE COMMENT '仓库SKU索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='销售商品关联仓库明细表';

-- ----------------------------
-- Table structure for amf_jh_shipment
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_shipment`;
CREATE TABLE `amf_jh_shipment` (
  `id` bigint NOT NULL COMMENT '备货发货单主键ID（原始数据唯一标识，如1213、1330）',
  `params` json DEFAULT NULL COMMENT '扩展参数（原始数据均为null，无默认值规避1101报错）',
  `pageStart` int NOT NULL DEFAULT '0' COMMENT '分页起始位置（原始数据均为0）',
  `idList` json DEFAULT NULL COMMENT 'ID列表（原始数据均为null）',
  `user_key` varchar(64) NOT NULL COMMENT '用户唯一标识（原始数据：如1719307501061）',
  `container_no` varchar(64) NOT NULL COMMENT '集装箱/批次编号（原始数据：如OOLU9102952、2025/11/7+CAJW06）',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID（原始数据：如10568、11129）',
  `warehouse_name` varchar(128) NOT NULL COMMENT '仓库名称（原始数据：如CG仓-Meijiajia、CAJW06）',
  `ship_qty` int NOT NULL COMMENT '发货总数量（原始数据：762、10）',
  `receive_qty` int NOT NULL COMMENT '收货总数量（原始数据：762、10）',
  `status` tinyint NOT NULL COMMENT '发货单状态码（原始数据：2=完成）',
  `status_name` varchar(32) NOT NULL COMMENT '发货单状态名称（原始数据：完成）',
  `shipment_date` date NOT NULL COMMENT '发货日期（原始数据：如2025-10-09）',
  `create_time` datetime NOT NULL COMMENT '记录创建时间（原始数据：如2025-10-09 15:34:23）',
  `update_time` datetime NOT NULL COMMENT '记录最后更新时间（原始数据：如2025-11-07 19:03:24）',
  `propertyShipmentSkuList` json NOT NULL COMMENT '发货SKU明细数组（含店铺、SKU、收发数量等）',
  PRIMARY KEY (`id`),
  KEY `idx_user_key` (`user_key`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_status` (`status`),
  KEY `idx_shipment_date` (`shipment_date`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_update_time` (`update_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇系统备货发货主表（含嵌套SKU收发明细）';

-- ----------------------------
-- Table structure for amf_jh_shipment_eta
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_shipment_eta`;
CREATE TABLE `amf_jh_shipment_eta` (
  `container_no` varchar(64) NOT NULL COMMENT '集装箱/批次编号',
  `create_time` datetime DEFAULT NULL COMMENT '明细创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '明细更新时间',
  `shipment_date` date NOT NULL COMMENT '发货日期（原始数据：如2025-10-09）',
  `eta` varchar(30) DEFAULT NULL COMMENT 'eta(已上架、ETA12/12、ETA2026/1/3)',
  `eta_date` date DEFAULT NULL COMMENT 'ETA日期',
  PRIMARY KEY (`container_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇系统备货发货-SKU明细子表';

-- ----------------------------
-- Table structure for amf_jh_shipment_sku
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_shipment_sku`;
CREATE TABLE `amf_jh_shipment_sku` (
  `id` bigint NOT NULL COMMENT 'SKU明细主键ID（原始数据：如14409、16085）',
  `property_shipment_id` bigint NOT NULL COMMENT '关联备货发货单主表ID',
  `user_key` varchar(64) NOT NULL COMMENT '用户唯一标识',
  `shop_id` bigint NOT NULL COMMENT '店铺ID（原始数据：如2601、2600）',
  `shop_show_name` varchar(128) NOT NULL COMMENT '店铺展示名称',
  `container_no` varchar(64) NOT NULL COMMENT '集装箱/批次编号',
  `warehouse_sku` varchar(64) NOT NULL COMMENT '仓库SKU编码（如AP-XZSJ-5C-R）',
  `ship_qty` int NOT NULL COMMENT '该SKU发货数量',
  `receive_qty` int DEFAULT NULL COMMENT '该SKU收货数量',
  `create_time` datetime DEFAULT NULL COMMENT '明细创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '明细更新时间',
  `params` varchar(255) DEFAULT NULL,
  `pageStart` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_property_shipment_id` (`property_shipment_id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_warehouse_sku` (`warehouse_sku`),
  KEY `idx_ship_qty` (`ship_qty`),
  KEY `idx_receive_qty` (`receive_qty`),
  CONSTRAINT `fk_shipment_sku_main` FOREIGN KEY (`property_shipment_id`) REFERENCES `amf_jh_shipment` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇系统备货发货-SKU明细子表';

-- ----------------------------
-- Table structure for amf_jh_shop
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_shop`;
CREATE TABLE `amf_jh_shop` (
  `id` int NOT NULL COMMENT '店铺ID',
  `params` text COMMENT '参数',
  `pageStart` int DEFAULT '0' COMMENT '分页起始值',
  `user_key` varchar(50) DEFAULT NULL COMMENT '用户密钥',
  `platform_type` int DEFAULT NULL COMMENT '平台类型编码',
  `platform_name` varchar(100) DEFAULT NULL COMMENT '平台名称',
  `shop_name` varchar(255) DEFAULT NULL COMMENT '店铺名称',
  `shop_show_name` varchar(255) DEFAULT NULL COMMENT '店铺展示名称',
  `status` tinyint DEFAULT NULL COMMENT '店铺状态（1-正常，0-异常）',
  `country_code` varchar(10) DEFAULT NULL COMMENT '国家编码',
  `currency` varchar(20) DEFAULT NULL COMMENT '货币类型',
  `auth_info` text COMMENT '授权信息（JSON格式）',
  `parent_id` int DEFAULT NULL COMMENT '父店铺ID',
  `is_auto_upload_tracking` tinyint DEFAULT '0' COMMENT '是否自动上传物流跟踪（1-是，0-否）',
  `is_auto_upload_inventory` tinyint DEFAULT '0' COMMENT '是否自动上传库存（1-是，0-否）',
  `is_has_warehouse` tinyint DEFAULT '0' COMMENT '是否有仓库（1-是，0-否）',
  `is_auto_audit` tinyint DEFAULT '0' COMMENT '是否自动审核（1-是，0-否）',
  `is_auto_get_label` tinyint DEFAULT '0' COMMENT '是否自动获取面单（1-是，0-否）',
  `is_auto_split_order` tinyint DEFAULT '0' COMMENT '是否自动拆分订单（1-是，0-否）',
  `is_auto_calculate_inventory` tinyint DEFAULT '0' COMMENT '是否自动计算库存（1-是，0-否）',
  `is_auto_push_order_to_warehouse` tinyint DEFAULT '0' COMMENT '是否自动推单到仓库（1-是，0-否）',
  `order_status` tinyint DEFAULT NULL COMMENT '订单状态',
  `auth_status` tinyint DEFAULT NULL COMMENT '授权状态',
  `create_user_id` int DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `operate_user_id` varchar(500) DEFAULT NULL COMMENT '操作人ID集合（逗号分隔）',
  `operate_dept_id` varchar(500) DEFAULT NULL COMMENT '操作部门ID集合（逗号分隔）',
  `access_way` varchar(100) DEFAULT NULL COMMENT '接入方式',
  `client_id` varchar(100) DEFAULT NULL COMMENT '客户端ID',
  `client_secret` varchar(255) DEFAULT NULL COMMENT '客户端密钥',
  `search_key` varchar(100) DEFAULT NULL COMMENT '搜索关键词',
  `search_dept_ids` varchar(500) DEFAULT NULL COMMENT '搜索部门ID集合',
  `search_user_id` varchar(100) DEFAULT NULL COMMENT '搜索用户ID',
  `platFormTypeList` text COMMENT '平台类型列表',
  `jhy_abroad_code` varchar(100) DEFAULT NULL COMMENT '鲸汇海外编码',
  `jhy_domestic_code` varchar(100) DEFAULT NULL COMMENT '鲸汇国内编码',
  `jhy_shop_code` varchar(100) DEFAULT NULL COMMENT '鲸汇店铺编码',
  `is_get_castleg_order` tinyint DEFAULT NULL COMMENT '是否获取Castleg订单',
  `inventory_scale` varchar(50) DEFAULT NULL COMMENT '库存规模',
  `inventory_fix_qty` int DEFAULT '0' COMMENT '库存固定数量',
  `is_exist` tinyint DEFAULT NULL COMMENT '是否存在',
  `is_join_wayfair_plan` tinyint DEFAULT '0' COMMENT '是否加入Wayfair计划',
  `is_auth_affirm` tinyint DEFAULT '0' COMMENT '是否授权确认',
  `is_auth_allocation_warehouse` tinyint DEFAULT '0' COMMENT '是否授权分配仓库',
  `next_availability_days` int DEFAULT NULL COMMENT '下次可用天数',
  `is_auto_upload_invoice` tinyint DEFAULT '0' COMMENT '是否自动上传发票',
  `is_auth_get_packing_slip` tinyint DEFAULT '0' COMMENT '是否授权获取装箱单',
  `is_add_watermark` tinyint DEFAULT '0' COMMENT '是否添加水印',
  `is_platform_label` tinyint DEFAULT '0' COMMENT '是否平台标签',
  `is_auth_acknowledge` tinyint DEFAULT '0' COMMENT '是否授权确认',
  `dis_warehouse_model` varchar(50) DEFAULT NULL COMMENT '配送仓库模式',
  `is_auth_get_bol` tinyint DEFAULT '0' COMMENT '是否授权获取提单',
  `platform_warehouse_code` varchar(100) DEFAULT NULL COMMENT '平台仓库编码',
  `plat_carrier_code` varchar(100) DEFAULT NULL COMMENT '平台物流商编码',
  `is_partial_shipment` tinyint DEFAULT '0' COMMENT '是否允许部分发货',
  `app_name` varchar(100) DEFAULT NULL COMMENT '应用名称',
  `is_upload_997` tinyint DEFAULT '0' COMMENT '是否上传997',
  `is_allow_dfh_upload_track` tinyint DEFAULT '0' COMMENT '是否允许DFH上传跟踪',
  `spu_assign_warehouse` tinyint DEFAULT '0' COMMENT 'SPU分配仓库',
  `tiktok_shop_type` tinyint DEFAULT '1' COMMENT 'TikTok店铺类型',
  `is_get_lable_in_plat` tinyint DEFAULT '0' COMMENT '是否在平台获取标签',
  `is_ship_later` tinyint DEFAULT '0' COMMENT '是否延迟发货',
  `stock_up_days` int DEFAULT NULL COMMENT '备货天数',
  `is_reconciliation_write_off` tinyint DEFAULT '0' COMMENT '是否对账核销',
  `time_diff` int DEFAULT '0' COMMENT '时间差',
  `ids` text COMMENT 'ID集合',
  `automatically_confirm_receipt_of_orders` tinyint DEFAULT '0' COMMENT '是否自动确认订单收货',
  `is_affect_warehouse_by_age` tinyint DEFAULT '0' COMMENT '是否受仓库年龄影响',
  `inventory_min_threshold` int DEFAULT NULL COMMENT '库存最低阈值',
  `vcdf_obtain_the_waybill_in_advance` tinyint DEFAULT NULL COMMENT 'VCDF是否提前获取运单',
  `does_vc_need_to_verify_the_logistics_provider` tinyint DEFAULT NULL COMMENT 'VC是否需要验证物流商',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇店铺数据表';

-- ----------------------------
-- Table structure for amf_jh_shop_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_shop_warehouse`;
CREATE TABLE `amf_jh_shop_warehouse` (
  `id` int NOT NULL COMMENT '主键ID',
  `warehouse_id` int NOT NULL COMMENT '仓库ID',
  `warehouse_name` varchar(100) NOT NULL COMMENT '仓库名称',
  `shop_warehouse_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺仓库编码',
  `country_code` varchar(10) DEFAULT NULL COMMENT '国家代码',
  `province_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '地区代码',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `status` tinyint DEFAULT NULL COMMENT '状态',
  `seq` int DEFAULT NULL COMMENT '排序',
  `create_user_id` int DEFAULT NULL COMMENT '创建用户ID',
  `user_name` varchar(100) DEFAULT NULL COMMENT '用户名',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `exExpressAccountList` json DEFAULT NULL COMMENT '外部快递账户列表',
  `shopWarehouseExpressBodyList` json DEFAULT NULL COMMENT '店铺仓库快递信息列表',
  `shopId` int DEFAULT NULL COMMENT '店铺ID',
  `platform_type` varchar(50) DEFAULT NULL COMMENT '平台类型',
  `shop_name` varchar(200) DEFAULT NULL COMMENT '店铺名称',
  PRIMARY KEY (`id`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_shop_id` (`shopId`),
  KEY `idx_platform_type` (`platform_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺发货仓关系表';

-- ----------------------------
-- Table structure for amf_jh_shop_warehouse_shipmethod
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_shop_warehouse_shipmethod`;
CREATE TABLE `amf_jh_shop_warehouse_shipmethod` (
  `id` int NOT NULL COMMENT '主键ID',
  `userKey` varchar(100) DEFAULT NULL COMMENT '用户键',
  `shopId` int NOT NULL COMMENT '店铺ID',
  `warehouseId` int NOT NULL COMMENT '仓库ID',
  `shippingMethodId` int DEFAULT NULL COMMENT '运输方式ID',
  `warehouseShippingMethodId` int DEFAULT NULL COMMENT '仓库运输方式ID',
  `isGetExpress` tinyint DEFAULT NULL COMMENT '是否获取快递',
  `carrierCode` varchar(50) DEFAULT NULL COMMENT '承运商代码',
  `carrierChannelCode` varchar(100) DEFAULT NULL COMMENT '承运商渠道代码',
  `code` varchar(100) DEFAULT NULL COMMENT '运输方式代码',
  `nameCn` varchar(200) DEFAULT NULL COMMENT '中文名称',
  `createTime` datetime DEFAULT NULL COMMENT '创建时间',
  `userId` int DEFAULT NULL COMMENT '用户ID',
  `is_choose` tinyint DEFAULT NULL COMMENT '是否选择',
  PRIMARY KEY (`id`),
  KEY `idx_shop_warehouse` (`shopId`,`warehouseId`),
  KEY `idx_carrier` (`carrierCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺发货仓运输方式表';

-- ----------------------------
-- Table structure for amf_jh_shop_warehouse_stock
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_shop_warehouse_stock`;
CREATE TABLE `amf_jh_shop_warehouse_stock` (
  `id` bigint NOT NULL COMMENT '库存记录主键ID（原始数据唯一标识，如9115、6100）',
  `params` json DEFAULT NULL COMMENT '扩展参数（原始数据均为null，无默认值规避1101报错）',
  `pageStart` int NOT NULL DEFAULT '0' COMMENT '分页起始位置（原始数据均为0）',
  `idList` json DEFAULT NULL COMMENT 'ID列表（原始数据均为null）',
  `user_key` varchar(64) NOT NULL COMMENT '用户唯一标识（原始数据：如1719307501061）',
  `shop_id` bigint NOT NULL COMMENT '店铺ID（原始数据：如2600、4102）',
  `shop_show_name` varchar(128) NOT NULL COMMENT '店铺展示名称（原始数据：如Shenzhen Litian Technology Co Ltd、AMAZON_AP）',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID（原始数据：如11113、9903）',
  `warehouse_name` varchar(64) NOT NULL COMMENT '仓库名称（原始数据：如NJF、MEM-R）',
  `warehouse_sku` varchar(64) NOT NULL COMMENT '仓库SKU编码（原始数据：如UK-TJDXG-WHITE、AP-ZHG01-D3CBYG-WHITE）',
  `in_transit_qty` int NOT NULL DEFAULT '0' COMMENT '在途库存数量（原始数据：0、170）',
  `available_qty` int NOT NULL DEFAULT '0' COMMENT '可售库存数量（原始数据：2、8、1）',
  `create_time` datetime NOT NULL COMMENT '记录创建时间（原始数据：如2025-11-28 17:06:13）',
  `update_time` datetime NOT NULL COMMENT '记录最后更新时间（原始数据：如2025-11-28 17:06:38）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_shop_warehouse_sku` (`shop_id`,`warehouse_id`,`warehouse_sku`),
  KEY `idx_user_key` (`user_key`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_warehouse_sku` (`warehouse_sku`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_update_time` (`update_time`),
  KEY `idx_warehouse_available_qty` (`warehouse_id`,`available_qty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇系统货权库存表（店铺-仓库-SKU库存明细）';

-- ----------------------------
-- Table structure for amf_jh_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_warehouse`;
CREATE TABLE `amf_jh_warehouse` (
  `id` int NOT NULL COMMENT '仓库ID',
  `user_key` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户标识',
  `warehouse_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '仓库名称',
  `warehouse_status` int DEFAULT '0' COMMENT '仓库状态(0:停用,1:启用)',
  `warehouse_type` int DEFAULT '0' COMMENT '仓库类型',
  `country_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '国家代码',
  `province_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '省份/州代码',
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '城市',
  `zipcode` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮政编码',
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系电话',
  `detail_address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '详细地址1',
  `detail_address2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '详细地址2',
  `op_mode` int DEFAULT '0' COMMENT '运营模式',
  `is_domestic` int DEFAULT '0' COMMENT '是否国内(0:否,1:是)',
  `from_company` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '来源公司',
  `from_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '来源名称',
  `warehouse_account_id` int DEFAULT NULL COMMENT '仓库账户ID',
  `warehouse_account_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '仓库账户名称',
  `out_warehouse_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '出库代码',
  `wh_warehouse_codes` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '仓库代码列表',
  `create_user_id` int DEFAULT NULL COMMENT '创建用户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_undelivered_get_tracking_number` int DEFAULT '0' COMMENT '未发货获取跟踪号(0:否,1:是)',
  `is_sync_warehouse_inventory` int DEFAULT '0' COMMENT '同步仓库库存(0:否,1:是)',
  `is_drawback` int DEFAULT '0' COMMENT '是否退税(0:否,1:是)',
  `from_mailbox` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱地址',
  `is_delivery_warehouse` int DEFAULT NULL COMMENT '是否发货仓库',
  `jsonList` json DEFAULT NULL COMMENT 'JSON列表',
  `search_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '搜索关键词',
  `warehouse_sp_id` int DEFAULT NULL COMMENT '仓库服务商ID',
  `warehouse_types` json DEFAULT NULL COMMENT '仓库类型列表',
  `sys_type_list` json DEFAULT NULL COMMENT '系统类型列表',
  `warehouse_sp_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '仓库服务商名称',
  `itemList` json DEFAULT NULL COMMENT '项目列表',
  `create_user_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '创建用户名称',
  `exclude_id` int DEFAULT NULL COMMENT '排除ID',
  `is_virtual` int DEFAULT '0' COMMENT '是否虚拟仓库(0:否,1:是)',
  `warehouse_purpose` int DEFAULT '0' COMMENT '仓库用途',
  `platform_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平台类型',
  `overseas_warehouse_id` int DEFAULT NULL COMMENT '海外仓库ID',
  `shop_warehouse_id` int DEFAULT NULL COMMENT '店铺仓库ID',
  `warehouse_name_like` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '仓库名称模糊查询',
  `sys_account` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '系统账户',
  `support_sys_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '支持系统类型',
  `is_custom_add` int DEFAULT NULL COMMENT '是否自定义添加',
  `warehouse_manage_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '仓库管理类型',
  `is_for_shop_order` int DEFAULT '0' COMMENT '是否用于店铺订单(0:否,1:是)',
  `is_for_transfer_order` int DEFAULT '0' COMMENT '是否用于调拨订单(0:否,1:是)',
  `is_return_warehouse` int DEFAULT '0' COMMENT '是否退货仓库(0:否,1:是)',
  `wh_warehouse_sp_id` int DEFAULT NULL COMMENT '仓库服务商ID',
  `is_dock` int DEFAULT '0' COMMENT '是否码头(0:否,1:是)',
  `account_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '账户名称',
  `sys_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '系统类型',
  `whWarehouseSpList` json DEFAULT NULL COMMENT '仓库服务商列表',
  `erp_available_qty` int DEFAULT NULL COMMENT 'ERP可用数量',
  `out_available_qty` int DEFAULT NULL COMMENT '出库可用数量',
  `warehouse_sku` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '仓库SKU',
  `jhy_domestic_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '国内代码',
  `is_exist` int DEFAULT NULL COMMENT '是否存在',
  `warehouse_seq` int DEFAULT NULL COMMENT '仓库序号',
  `is_all_has_permission` int DEFAULT '0' COMMENT '是否全部有权限(0:否,1:是)',
  `permission_user_ids` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '权限用户ID列表',
  `hasPermissionWarehouseIdList` json DEFAULT NULL COMMENT '有权限的仓库ID列表',
  `is_need_watermark` int DEFAULT '0' COMMENT '是否需要水印(0:否,1:是)',
  `is_support_ltl` int DEFAULT '0' COMMENT '是否支持零担(0:否,1:是)',
  `is_push_warehouse_code` int DEFAULT '0' COMMENT '是否推送仓库代码(0:否,1:是)',
  `is_whwarehouse_inventory_warning` int DEFAULT '0' COMMENT '是否仓库库存警告(0:否,1:是)',
  `whwarehouse_inventory_warning_start` int DEFAULT NULL COMMENT '仓库库存警告起始值',
  `third_express_warehouse_code` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '第三方快递仓库代码',
  `delivery_model` int DEFAULT '0' COMMENT '配送模式',
  `configuration` json DEFAULT NULL COMMENT '配置信息',
  `expedited_ship_ids` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '加急发货ID列表',
  `is_bill_channel` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '是否账单渠道',
  `need_return_label` int DEFAULT '0' COMMENT '是否需要退货标签(0:否,1:是)',
  `inventory_type` int DEFAULT '0' COMMENT '库存类型',
  `params` json DEFAULT NULL COMMENT '参数',
  `pageStart` int DEFAULT '0' COMMENT '页码起始值',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='JH仓库表';

-- ----------------------------
-- Table structure for amf_jh_warehouse_set
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_warehouse_set`;
CREATE TABLE `amf_jh_warehouse_set` (
  `id` int NOT NULL COMMENT '仓库ID',
  `warehouse_sp_id` int DEFAULT NULL COMMENT '仓库服务商ID',
  `warehouse_sp_name` varchar(255) DEFAULT NULL COMMENT '仓库服务商名称',
  `warehouse_sp_code` varchar(100) DEFAULT NULL COMMENT '仓库服务商代码',
  `is_custom_add` tinyint DEFAULT NULL COMMENT '是否自定义添加',
  `account_name` varchar(255) DEFAULT NULL COMMENT '账户名称',
  `sys_account` varchar(100) DEFAULT NULL COMMENT '系统账户',
  `sys_type` varchar(100) DEFAULT NULL COMMENT '系统类型',
  `sys_url` varchar(500) DEFAULT NULL COMMENT '系统URL',
  `user_key` varchar(50) DEFAULT NULL COMMENT '用户密钥',
  `auth_info` text COMMENT '授权信息',
  `enabled` tinyint DEFAULT '0' COMMENT '是否启用',
  `is_support_ltl` tinyint DEFAULT '0' COMMENT '是否支持LTL',
  `is_support_yddj` tinyint DEFAULT '0' COMMENT '是否支持约定交货',
  `is_support_signature` tinyint DEFAULT '0' COMMENT '是否支持签名',
  `is_signature` tinyint DEFAULT '0' COMMENT '是否需要签名',
  `is_support_signature_remark` varchar(500) DEFAULT NULL COMMENT '签名备注',
  `service_status` tinyint DEFAULT '0' COMMENT '服务状态',
  `ltl_ship_billing` varchar(100) DEFAULT NULL COMMENT 'LTL发货账单方式',
  `order_comment` varchar(500) DEFAULT NULL COMMENT '订单备注',
  `country_name` varchar(100) DEFAULT NULL COMMENT '国家名称',
  `create_user_id` int DEFAULT NULL COMMENT '创建用户ID',
  `create_user_name` varchar(100) DEFAULT NULL COMMENT '创建用户名称',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_dock` tinyint DEFAULT '0' COMMENT '是否对接',
  `check_out_order` varchar(100) DEFAULT NULL COMMENT '结账订单',
  `auto_audit` tinyint DEFAULT '0' COMMENT '是否自动审核',
  `warehouse_manage_type` varchar(100) DEFAULT NULL COMMENT '仓库管理类型',
  `wh_shipping_method_list` text COMMENT '仓库发货方式列表',
  `wmsShopWarehouseRelation` text COMMENT 'WMS店铺仓库关系',
  `params` text COMMENT '参数',
  `pageStart` int DEFAULT '0' COMMENT '分页起始值',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇仓库数据设置表';

-- ----------------------------
-- Table structure for amf_jh_warehouse_stock
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_warehouse_stock`;
CREATE TABLE `amf_jh_warehouse_stock` (
  `id` bigint unsigned NOT NULL COMMENT '库存记录唯一ID（后台返回主键，无符号避免负数）',
  `warehouse_id` int unsigned NOT NULL COMMENT '仓库ID（关联仓库表主键，如SAV仓库对应ID=5466）',
  `warehouse_sku` varchar(64) NOT NULL COMMENT '仓库内部SKU编码（唯一标识仓库内商品，如UK-WJGLDSJ-C60-O-A）',
  `out_warehouse_sku` varchar(64) NOT NULL COMMENT '外部出库SKU编码（与warehouse_sku一致，可能用于对外发货标识）',
  `warehouse_sku_name` varchar(128) NOT NULL COMMENT '仓库SKU名称（含中文描述，如L桌带文件柜高架灰橡木A包）',
  `warehouse_sku_name_cn` varchar(128) DEFAULT NULL COMMENT '仓库SKU中文名称（预留字段，当前为null）',
  `warehouse_sku_name_en` varchar(64) DEFAULT NULL COMMENT '仓库SKU英文名称（当前与warehouse_sku一致）',
  `warehouse_name` varchar(32) NOT NULL COMMENT '仓库名称（如SAV，与out_warehouse_code一致）',
  `out_warehouse_code` varchar(32) NOT NULL COMMENT '外部仓库编码（用于外部系统对接，如SAV）',
  `out_available_qty` int NOT NULL DEFAULT '0' COMMENT '外部可用库存数量（当前示例均为0）',
  `out_available_qty_private` int DEFAULT '0' COMMENT '外部私有可用库存数量（私有场景专用，当前为0）',
  `out_available_qty_public` int DEFAULT '0' COMMENT '外部公有可用库存数量（公有场景专用，当前为0）',
  `allocation_qty` int DEFAULT '0' COMMENT '已分配库存数量（已锁定待出库，当前为0）',
  `erp_available_qty` int DEFAULT NULL COMMENT 'ERP系统可用库存数量（支持负数，如-19）',
  `total_out_available_qty` int DEFAULT NULL COMMENT '外部可用库存总量（汇总字段，预留）',
  `total_out_available_qty_private` int DEFAULT NULL COMMENT '外部私有可用库存总量（汇总字段，预留）',
  `total_out_available_qty_public` int DEFAULT NULL COMMENT '外部公有可用库存总量（汇总字段，预留）',
  `total_allocation_qty` int DEFAULT NULL COMMENT '已分配库存总量（汇总字段，预留）',
  `plan_qty` int DEFAULT NULL COMMENT '计划库存数量（预留字段，当前为null）',
  `production_qty` int DEFAULT NULL COMMENT '生产中库存数量（预留字段，当前为null）',
  `erp_purchase_onway_qty` int DEFAULT NULL COMMENT 'ERP采购在途数量（预留字段，当前为null）',
  `erp_real_qty` int DEFAULT NULL COMMENT 'ERP实际库存数量（预留字段，当前为null）',
  `erp_domestic_qty` int DEFAULT NULL COMMENT 'ERP国内库存数量（预留字段，当前为null）',
  `current_available_qty` int DEFAULT NULL COMMENT '当前实际可用库存数量（预留字段，当前为null）',
  `transit_qty` int DEFAULT NULL COMMENT '在途库存数量（预留字段，当前为null）',
  `total_plan_qty` int DEFAULT NULL COMMENT '计划库存总量（汇总字段，预留）',
  `total_process_qty` int DEFAULT NULL COMMENT '加工中库存总量（汇总字段，预留）',
  `total_domestic_qty` int DEFAULT NULL COMMENT '国内库存总量（汇总字段，预留）',
  `total_onway_qty` int DEFAULT NULL COMMENT '在途库存总量（汇总字段，预留）',
  `total_oversease_qty` int DEFAULT NULL COMMENT '海外库存总量（汇总字段，预留）',
  `purchase_value` decimal(18,2) DEFAULT NULL COMMENT '采购单价/金额（预留字段，当前为null）',
  `total_plan_amount` decimal(18,2) DEFAULT NULL COMMENT '计划库存总金额（汇总字段，预留）',
  `total_process_amount` decimal(18,2) DEFAULT NULL COMMENT '加工中库存总金额（汇总字段，预留）',
  `total_domestic_amount` decimal(18,2) DEFAULT NULL COMMENT '国内库存总金额（汇总字段，预留）',
  `total_onway_amount` decimal(18,2) DEFAULT NULL COMMENT '在途库存总金额（汇总字段，预留）',
  `total_oversease_amount` decimal(18,2) DEFAULT NULL COMMENT '海外库存总金额（汇总字段，预留）',
  `thirdparty_maintain` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '第三方维护标识（示例值为3，可能代表“自有维护”“第三方维护”等枚举）',
  `thirdparty_maintain_msg` varchar(255) DEFAULT NULL COMMENT '第三方维护说明（预留字段，当前为null）',
  `expect_daily_sell_num` int DEFAULT NULL COMMENT '预计日均销量（预留字段，当前为null）',
  `sell_status` tinyint DEFAULT NULL COMMENT '销售状态（预留枚举字段，如0=下架、1=在售，当前为null）',
  `inventory_status` tinyint DEFAULT NULL COMMENT '库存状态（预留枚举字段，如0=正常、1=缺货，当前为null）',
  `safe_inventory_day_num` int DEFAULT NULL COMMENT '安全库存天数（预留字段，当前为null）',
  `sku_inventory_warning_status` varchar(10) NOT NULL DEFAULT '0' COMMENT 'SKU库存预警状态（示例值为“0”，可能代表“无预警”“预警”等枚举）',
  `create_time` datetime NOT NULL COMMENT '记录创建时间（如2024-06-26 18:11:31）',
  `update_time` datetime NOT NULL COMMENT '记录更新时间（如2025-11-28 17:11:48）',
  `user_key` varchar(64) DEFAULT NULL COMMENT '用户标识（预留字段，可能关联操作人，当前为null）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_amf_jh_warehouse_stock` (`warehouse_sku`,`warehouse_name`) USING BTREE,
  KEY `idx_warehouse_sku` (`warehouse_sku`) COMMENT '索引：按仓库SKU查询',
  KEY `idx_warehouse_id` (`warehouse_id`) COMMENT '普通索引：按仓库ID查询（如查询SAV仓库所有库存）',
  KEY `idx_create_time` (`create_time`) COMMENT '普通索引：按创建时间查询（如查询某时间段新增库存）',
  KEY `idx_sku_warning_status` (`sku_inventory_warning_status`) COMMENT '普通索引：按库存预警状态查询（如筛选预警商品）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库库存主表（存储各仓库SKU的库存数量、状态、金额等信息）';

-- ----------------------------
-- Table structure for amf_jh_warehouse_stock_20251202
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_warehouse_stock_20251202`;
CREATE TABLE `amf_jh_warehouse_stock_20251202` (
  `id` bigint unsigned NOT NULL COMMENT '库存记录唯一ID（后台返回主键，无符号避免负数）',
  `warehouse_id` int unsigned NOT NULL COMMENT '仓库ID（关联仓库表主键，如SAV仓库对应ID=5466）',
  `warehouse_sku` varchar(64) NOT NULL COMMENT '仓库内部SKU编码（唯一标识仓库内商品，如UK-WJGLDSJ-C60-O-A）',
  `out_warehouse_sku` varchar(64) NOT NULL COMMENT '外部出库SKU编码（与warehouse_sku一致，可能用于对外发货标识）',
  `warehouse_sku_name` varchar(128) NOT NULL COMMENT '仓库SKU名称（含中文描述，如L桌带文件柜高架灰橡木A包）',
  `warehouse_sku_name_cn` varchar(128) DEFAULT NULL COMMENT '仓库SKU中文名称（预留字段，当前为null）',
  `warehouse_sku_name_en` varchar(64) DEFAULT NULL COMMENT '仓库SKU英文名称（当前与warehouse_sku一致）',
  `warehouse_name` varchar(32) NOT NULL COMMENT '仓库名称（如SAV，与out_warehouse_code一致）',
  `out_warehouse_code` varchar(32) NOT NULL COMMENT '外部仓库编码（用于外部系统对接，如SAV）',
  `out_available_qty` int NOT NULL DEFAULT '0' COMMENT '外部可用库存数量（当前示例均为0）',
  `out_available_qty_private` int NOT NULL DEFAULT '0' COMMENT '外部私有可用库存数量（私有场景专用，当前为0）',
  `out_available_qty_public` int NOT NULL DEFAULT '0' COMMENT '外部公有可用库存数量（公有场景专用，当前为0）',
  `allocation_qty` int NOT NULL DEFAULT '0' COMMENT '已分配库存数量（已锁定待出库，当前为0）',
  `erp_available_qty` int DEFAULT NULL COMMENT 'ERP系统可用库存数量（支持负数，如-19）',
  `total_out_available_qty` int DEFAULT NULL COMMENT '外部可用库存总量（汇总字段，预留）',
  `total_out_available_qty_private` int DEFAULT NULL COMMENT '外部私有可用库存总量（汇总字段，预留）',
  `total_out_available_qty_public` int DEFAULT NULL COMMENT '外部公有可用库存总量（汇总字段，预留）',
  `total_allocation_qty` int DEFAULT NULL COMMENT '已分配库存总量（汇总字段，预留）',
  `plan_qty` int DEFAULT NULL COMMENT '计划库存数量（预留字段，当前为null）',
  `production_qty` int DEFAULT NULL COMMENT '生产中库存数量（预留字段，当前为null）',
  `erp_purchase_onway_qty` int DEFAULT NULL COMMENT 'ERP采购在途数量（预留字段，当前为null）',
  `erp_real_qty` int DEFAULT NULL COMMENT 'ERP实际库存数量（预留字段，当前为null）',
  `erp_domestic_qty` int DEFAULT NULL COMMENT 'ERP国内库存数量（预留字段，当前为null）',
  `current_available_qty` int DEFAULT NULL COMMENT '当前实际可用库存数量（预留字段，当前为null）',
  `transit_qty` int DEFAULT NULL COMMENT '在途库存数量（预留字段，当前为null）',
  `total_plan_qty` int DEFAULT NULL COMMENT '计划库存总量（汇总字段，预留）',
  `total_process_qty` int DEFAULT NULL COMMENT '加工中库存总量（汇总字段，预留）',
  `total_domestic_qty` int DEFAULT NULL COMMENT '国内库存总量（汇总字段，预留）',
  `total_onway_qty` int DEFAULT NULL COMMENT '在途库存总量（汇总字段，预留）',
  `total_oversease_qty` int DEFAULT NULL COMMENT '海外库存总量（汇总字段，预留）',
  `purchase_value` decimal(18,2) DEFAULT NULL COMMENT '采购单价/金额（预留字段，当前为null）',
  `total_plan_amount` decimal(18,2) DEFAULT NULL COMMENT '计划库存总金额（汇总字段，预留）',
  `total_process_amount` decimal(18,2) DEFAULT NULL COMMENT '加工中库存总金额（汇总字段，预留）',
  `total_domestic_amount` decimal(18,2) DEFAULT NULL COMMENT '国内库存总金额（汇总字段，预留）',
  `total_onway_amount` decimal(18,2) DEFAULT NULL COMMENT '在途库存总金额（汇总字段，预留）',
  `total_oversease_amount` decimal(18,2) DEFAULT NULL COMMENT '海外库存总金额（汇总字段，预留）',
  `thirdparty_maintain` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '第三方维护标识（示例值为3，可能代表“自有维护”“第三方维护”等枚举）',
  `thirdparty_maintain_msg` varchar(255) DEFAULT NULL COMMENT '第三方维护说明（预留字段，当前为null）',
  `expect_daily_sell_num` int DEFAULT NULL COMMENT '预计日均销量（预留字段，当前为null）',
  `sell_status` tinyint DEFAULT NULL COMMENT '销售状态（预留枚举字段，如0=下架、1=在售，当前为null）',
  `inventory_status` tinyint DEFAULT NULL COMMENT '库存状态（预留枚举字段，如0=正常、1=缺货，当前为null）',
  `safe_inventory_day_num` int DEFAULT NULL COMMENT '安全库存天数（预留字段，当前为null）',
  `sku_inventory_warning_status` varchar(10) NOT NULL DEFAULT '0' COMMENT 'SKU库存预警状态（示例值为“0”，可能代表“无预警”“预警”等枚举）',
  `create_time` datetime NOT NULL COMMENT '记录创建时间（如2024-06-26 18:11:31）',
  `update_time` datetime NOT NULL COMMENT '记录更新时间（如2025-11-28 17:11:48）',
  `user_key` varchar(64) DEFAULT NULL COMMENT '用户标识（预留字段，可能关联操作人，当前为null）',
  PRIMARY KEY (`id`),
  KEY `idx_warehouse_sku` (`warehouse_sku`) COMMENT '索引：按仓库SKU查询',
  KEY `idx_warehouse_id` (`warehouse_id`) COMMENT '普通索引：按仓库ID查询（如查询SAV仓库所有库存）',
  KEY `idx_create_time` (`create_time`) COMMENT '普通索引：按创建时间查询（如查询某时间段新增库存）',
  KEY `idx_sku_warning_status` (`sku_inventory_warning_status`) COMMENT '普通索引：按库存预警状态查询（如筛选预警商品）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库库存主表（存储各仓库SKU的库存数量、状态、金额等信息）';

-- ----------------------------
-- Table structure for amf_jh_warehouse_stock_his
-- ----------------------------
DROP TABLE IF EXISTS `amf_jh_warehouse_stock_his`;
CREATE TABLE `amf_jh_warehouse_stock_his` (
  `id` bigint unsigned NOT NULL COMMENT '库存记录唯一ID（后台返回主键，无符号避免负数）',
  `warehouse_id` int unsigned NOT NULL COMMENT '仓库ID（关联仓库表主键，如SAV仓库对应ID=5466）',
  `warehouse_sku` varchar(64) NOT NULL COMMENT '仓库内部SKU编码（唯一标识仓库内商品，如UK-WJGLDSJ-C60-O-A）',
  `out_warehouse_sku` varchar(64) NOT NULL COMMENT '外部出库SKU编码（与warehouse_sku一致，可能用于对外发货标识）',
  `warehouse_sku_name` varchar(128) NOT NULL COMMENT '仓库SKU名称（含中文描述，如L桌带文件柜高架灰橡木A包）',
  `warehouse_sku_name_cn` varchar(128) DEFAULT NULL COMMENT '仓库SKU中文名称（预留字段，当前为null）',
  `warehouse_sku_name_en` varchar(64) DEFAULT NULL COMMENT '仓库SKU英文名称（当前与warehouse_sku一致）',
  `warehouse_name` varchar(32) NOT NULL COMMENT '仓库名称（如SAV，与out_warehouse_code一致）',
  `out_warehouse_code` varchar(32) NOT NULL COMMENT '外部仓库编码（用于外部系统对接，如SAV）',
  `out_available_qty` int NOT NULL DEFAULT '0' COMMENT '外部可用库存数量（当前示例均为0）',
  `out_available_qty_private` int NOT NULL DEFAULT '0' COMMENT '外部私有可用库存数量（私有场景专用，当前为0）',
  `out_available_qty_public` int NOT NULL DEFAULT '0' COMMENT '外部公有可用库存数量（公有场景专用，当前为0）',
  `allocation_qty` int NOT NULL DEFAULT '0' COMMENT '已分配库存数量（已锁定待出库，当前为0）',
  `erp_available_qty` int DEFAULT NULL COMMENT 'ERP系统可用库存数量（支持负数，如-19）',
  `total_out_available_qty` int DEFAULT NULL COMMENT '外部可用库存总量（汇总字段，预留）',
  `total_out_available_qty_private` int DEFAULT NULL COMMENT '外部私有可用库存总量（汇总字段，预留）',
  `total_out_available_qty_public` int DEFAULT NULL COMMENT '外部公有可用库存总量（汇总字段，预留）',
  `total_allocation_qty` int DEFAULT NULL COMMENT '已分配库存总量（汇总字段，预留）',
  `plan_qty` int DEFAULT NULL COMMENT '计划库存数量（预留字段，当前为null）',
  `production_qty` int DEFAULT NULL COMMENT '生产中库存数量（预留字段，当前为null）',
  `erp_purchase_onway_qty` int DEFAULT NULL COMMENT 'ERP采购在途数量（预留字段，当前为null）',
  `erp_real_qty` int DEFAULT NULL COMMENT 'ERP实际库存数量（预留字段，当前为null）',
  `erp_domestic_qty` int DEFAULT NULL COMMENT 'ERP国内库存数量（预留字段，当前为null）',
  `current_available_qty` int DEFAULT NULL COMMENT '当前实际可用库存数量（预留字段，当前为null）',
  `transit_qty` int DEFAULT NULL COMMENT '在途库存数量（预留字段，当前为null）',
  `total_plan_qty` int DEFAULT NULL COMMENT '计划库存总量（汇总字段，预留）',
  `total_process_qty` int DEFAULT NULL COMMENT '加工中库存总量（汇总字段，预留）',
  `total_domestic_qty` int DEFAULT NULL COMMENT '国内库存总量（汇总字段，预留）',
  `total_onway_qty` int DEFAULT NULL COMMENT '在途库存总量（汇总字段，预留）',
  `total_oversease_qty` int DEFAULT NULL COMMENT '海外库存总量（汇总字段，预留）',
  `purchase_value` decimal(18,2) DEFAULT NULL COMMENT '采购单价/金额（预留字段，当前为null）',
  `total_plan_amount` decimal(18,2) DEFAULT NULL COMMENT '计划库存总金额（汇总字段，预留）',
  `total_process_amount` decimal(18,2) DEFAULT NULL COMMENT '加工中库存总金额（汇总字段，预留）',
  `total_domestic_amount` decimal(18,2) DEFAULT NULL COMMENT '国内库存总金额（汇总字段，预留）',
  `total_onway_amount` decimal(18,2) DEFAULT NULL COMMENT '在途库存总金额（汇总字段，预留）',
  `total_oversease_amount` decimal(18,2) DEFAULT NULL COMMENT '海外库存总金额（汇总字段，预留）',
  `thirdparty_maintain` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '第三方维护标识（示例值为3，可能代表“自有维护”“第三方维护”等枚举）',
  `thirdparty_maintain_msg` varchar(255) DEFAULT NULL COMMENT '第三方维护说明（预留字段，当前为null）',
  `expect_daily_sell_num` int DEFAULT NULL COMMENT '预计日均销量（预留字段，当前为null）',
  `sell_status` tinyint DEFAULT NULL COMMENT '销售状态（预留枚举字段，如0=下架、1=在售，当前为null）',
  `inventory_status` tinyint DEFAULT NULL COMMENT '库存状态（预留枚举字段，如0=正常、1=缺货，当前为null）',
  `safe_inventory_day_num` int DEFAULT NULL COMMENT '安全库存天数（预留字段，当前为null）',
  `sku_inventory_warning_status` varchar(10) NOT NULL DEFAULT '0' COMMENT 'SKU库存预警状态（示例值为“0”，可能代表“无预警”“预警”等枚举）',
  `create_time` datetime NOT NULL COMMENT '记录创建时间（如2024-06-26 18:11:31）',
  `update_time` datetime NOT NULL COMMENT '记录更新时间（如2025-11-28 17:11:48）',
  `user_key` varchar(64) DEFAULT NULL COMMENT '用户标识（预留字段，可能关联操作人，当前为null）',
  `doc_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '归档日期',
  PRIMARY KEY (`id`,`doc_date`) USING BTREE,
  KEY `idx_warehouse_sku` (`warehouse_sku`) COMMENT '索引：按仓库SKU查询',
  KEY `idx_warehouse_id` (`warehouse_id`) COMMENT '普通索引：按仓库ID查询（如查询SAV仓库所有库存）',
  KEY `idx_create_time` (`create_time`) COMMENT '普通索引：按创建时间查询（如查询某时间段新增库存）',
  KEY `idx_sku_warning_status` (`sku_inventory_warning_status`) COMMENT '普通索引：按库存预警状态查询（如筛选预警商品）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库库存主表（存储各仓库SKU的库存数量、状态、金额等信息）';

-- ----------------------------
-- Table structure for amf_lx_amzorder
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_amzorder`;
CREATE TABLE `amf_lx_amzorder` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键（原始数据无唯一ID，新增）',
  `phone` varchar(64) DEFAULT '' COMMENT '买家电话（原始数据均为空字符串）',
  `name` varchar(128) DEFAULT '' COMMENT '买家姓名（原始数据均为空字符串）',
  `address` varchar(512) DEFAULT '' COMMENT '买家地址（原始数据均为空字符串）',
  `sid` varchar(32) NOT NULL COMMENT '店铺ID/卖家ID（原始数据：如2307、2313）',
  `seller_name` varchar(128) NOT NULL COMMENT '卖家名称（原始数据：如EP-US、家具AC-US）',
  `amazon_order_id` varchar(64) NOT NULL COMMENT '亚马逊订单唯一ID（原始数据：如111-1494052-4753860）',
  `order_status` varchar(32) NOT NULL COMMENT '订单状态（原始数据：如Shipped）',
  `order_total_amount` decimal(10,2) NOT NULL COMMENT '订单总金额（原始数据：如96.28、118.02）',
  `fulfillment_channel` varchar(32) NOT NULL COMMENT '履约渠道（原始数据：MFN/AFN）',
  `postal_code` varchar(32) DEFAULT '' COMMENT '邮编（原始数据：如60020-1849、84321）',
  `is_return` tinyint NOT NULL COMMENT '是否退货（原始数据：0=否、2=是）',
  `is_mcf_order` tinyint NOT NULL DEFAULT '0' COMMENT '是否MCF订单（原始数据均为0）',
  `is_assessed` tinyint NOT NULL DEFAULT '0' COMMENT '是否已评估（原始数据均为0）',
  `is_replaced_order` tinyint NOT NULL DEFAULT '0' COMMENT '是否替换订单（原始数据均为0）',
  `is_replacement_order` tinyint NOT NULL DEFAULT '0' COMMENT '是否换货订单（原始数据均为0）',
  `is_return_order` tinyint NOT NULL COMMENT '是否退货订单（原始数据：0=否、1=是）',
  `order_total_currency_code` varchar(8) NOT NULL COMMENT '订单金额币种（原始数据：USD）',
  `sales_channel` varchar(64) NOT NULL COMMENT '销售渠道（原始数据：Amazon.com）',
  `tracking_number` varchar(64) DEFAULT '' COMMENT '物流跟踪号（原始数据部分为空）',
  `refund_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '退款金额（原始数据：0、-87.99）',
  `item_list` json NOT NULL COMMENT '订单商品明细数组（含asin/quantity_ordered/seller_sku等）',
  `purchase_date_local` datetime DEFAULT NULL COMMENT '本地采购时间（原始数据：如2025-10-01 06:52:10）',
  `purchase_date_local_utc` datetime DEFAULT NULL COMMENT '采购时间（UTC时区，如2025-10-01 13:52:10）',
  `shipment_date` varchar(64) DEFAULT '' COMMENT '发货时间（原始格式：2025-10-01T20:05:09+00:00）',
  `shipment_date_utc` varchar(20) DEFAULT NULL COMMENT '发货时间（UTC时区，如2025-10-01 20:05:09）',
  `shipment_date_local` varchar(20) DEFAULT NULL COMMENT '发货时间（本地时区，如2025-10-01 13:05:09）',
  `last_update_date` varchar(20) DEFAULT NULL COMMENT '订单最后更新时间（本地时区）',
  `last_update_date_utc` varchar(20) DEFAULT NULL COMMENT '订单最后更新时间（UTC时区）',
  `posted_date` varchar(20) DEFAULT NULL COMMENT '订单提交时间（本地时区，如2025-10-02 10:25:30）',
  `posted_date_utc` varchar(64) DEFAULT '' COMMENT '订单提交时间（UTC格式：2025-10-02T10:25:30Z）',
  `purchase_date` varchar(64) DEFAULT '' COMMENT '采购时间（原始格式：2025-10-01T13:52:10Z）',
  `purchase_date_utc` varchar(20) DEFAULT NULL COMMENT '采购时间（UTC时区，如2025-10-01 13:52:10）',
  `earliest_ship_date` varchar(64) DEFAULT '' COMMENT '最早发货时间（原始格式：2025-10-02T07:00:00Z）',
  `earliest_ship_date_utc` varchar(20) DEFAULT NULL COMMENT '最早发货时间（UTC时区）',
  `gmt_modified` varchar(20) DEFAULT NULL COMMENT '订单修改时间（本地时区）',
  `gmt_modified_utc` varchar(20) DEFAULT NULL COMMENT '订单修改时间（UTC时区）',
  `buyer_email` varchar(128) DEFAULT '' COMMENT '买家邮箱（原始数据均为空）',
  `buyer_name` varchar(128) DEFAULT '' COMMENT '买家名称（原始数据均为空）',
  `hide_time` datetime DEFAULT NULL COMMENT '隐藏时间（原始数据：如2025-10-01 06:52:10）',
  PRIMARY KEY (`id`),
  KEY `idx_sid` (`sid`),
  KEY `idx_seller_name` (`seller_name`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_fulfillment_channel` (`fulfillment_channel`),
  KEY `idx_is_return_order` (`is_return_order`),
  KEY `idx_purchase_date_utc` (`purchase_date_utc`),
  KEY `idx_gmt_modified` (`gmt_modified`),
  KEY `uk_amazon_order_id` (`amazon_order_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=550632 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统亚马逊(AMZ)平台订单主表（含嵌套商品明细）';

-- ----------------------------
-- Table structure for amf_lx_amzorder_1
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_amzorder_1`;
CREATE TABLE `amf_lx_amzorder_1` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键（原始数据无唯一ID，新增）',
  `phone` varchar(64) DEFAULT '' COMMENT '买家电话（原始数据均为空字符串）',
  `name` varchar(128) DEFAULT '' COMMENT '买家姓名（原始数据均为空字符串）',
  `address` varchar(512) DEFAULT '' COMMENT '买家地址（原始数据均为空字符串）',
  `sid` varchar(32) NOT NULL COMMENT '店铺ID/卖家ID（原始数据：如2307、2313）',
  `seller_name` varchar(128) NOT NULL COMMENT '卖家名称（原始数据：如EP-US、家具AC-US）',
  `amazon_order_id` varchar(64) NOT NULL COMMENT '亚马逊订单唯一ID（原始数据：如111-1494052-4753860）',
  `order_status` varchar(32) NOT NULL COMMENT '订单状态（原始数据：如Shipped）',
  `order_total_amount` decimal(10,2) NOT NULL COMMENT '订单总金额（原始数据：如96.28、118.02）',
  `fulfillment_channel` varchar(32) NOT NULL COMMENT '履约渠道（原始数据：MFN/AFN）',
  `postal_code` varchar(32) DEFAULT '' COMMENT '邮编（原始数据：如60020-1849、84321）',
  `is_return` tinyint NOT NULL COMMENT '是否退货（原始数据：0=否、2=是）',
  `is_mcf_order` tinyint NOT NULL DEFAULT '0' COMMENT '是否MCF订单（原始数据均为0）',
  `is_assessed` tinyint NOT NULL DEFAULT '0' COMMENT '是否已评估（原始数据均为0）',
  `is_replaced_order` tinyint NOT NULL DEFAULT '0' COMMENT '是否替换订单（原始数据均为0）',
  `is_replacement_order` tinyint NOT NULL DEFAULT '0' COMMENT '是否换货订单（原始数据均为0）',
  `is_return_order` tinyint NOT NULL COMMENT '是否退货订单（原始数据：0=否、1=是）',
  `order_total_currency_code` varchar(8) NOT NULL COMMENT '订单金额币种（原始数据：USD）',
  `sales_channel` varchar(64) NOT NULL COMMENT '销售渠道（原始数据：Amazon.com）',
  `tracking_number` varchar(64) DEFAULT '' COMMENT '物流跟踪号（原始数据部分为空）',
  `refund_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '退款金额（原始数据：0、-87.99）',
  `item_list` json NOT NULL COMMENT '订单商品明细数组（含asin/quantity_ordered/seller_sku等）',
  `purchase_date_local` datetime DEFAULT NULL COMMENT '本地采购时间（原始数据：如2025-10-01 06:52:10）',
  `purchase_date_local_utc` datetime DEFAULT NULL COMMENT '采购时间（UTC时区，如2025-10-01 13:52:10）',
  `shipment_date` varchar(64) DEFAULT '' COMMENT '发货时间（原始格式：2025-10-01T20:05:09+00:00）',
  `shipment_date_utc` varchar(20) DEFAULT NULL COMMENT '发货时间（UTC时区，如2025-10-01 20:05:09）',
  `shipment_date_local` varchar(20) DEFAULT NULL COMMENT '发货时间（本地时区，如2025-10-01 13:05:09）',
  `last_update_date` varchar(20) DEFAULT NULL COMMENT '订单最后更新时间（本地时区）',
  `last_update_date_utc` varchar(20) DEFAULT NULL COMMENT '订单最后更新时间（UTC时区）',
  `posted_date` varchar(20) DEFAULT NULL COMMENT '订单提交时间（本地时区，如2025-10-02 10:25:30）',
  `posted_date_utc` varchar(64) DEFAULT '' COMMENT '订单提交时间（UTC格式：2025-10-02T10:25:30Z）',
  `purchase_date` varchar(64) DEFAULT '' COMMENT '采购时间（原始格式：2025-10-01T13:52:10Z）',
  `purchase_date_utc` varchar(20) DEFAULT NULL COMMENT '采购时间（UTC时区，如2025-10-01 13:52:10）',
  `earliest_ship_date` varchar(64) DEFAULT '' COMMENT '最早发货时间（原始格式：2025-10-02T07:00:00Z）',
  `earliest_ship_date_utc` varchar(20) DEFAULT NULL COMMENT '最早发货时间（UTC时区）',
  `gmt_modified` varchar(20) DEFAULT NULL COMMENT '订单修改时间（本地时区）',
  `gmt_modified_utc` varchar(20) DEFAULT NULL COMMENT '订单修改时间（UTC时区）',
  `buyer_email` varchar(128) DEFAULT '' COMMENT '买家邮箱（原始数据均为空）',
  `buyer_name` varchar(128) DEFAULT '' COMMENT '买家名称（原始数据均为空）',
  `hide_time` datetime DEFAULT NULL COMMENT '隐藏时间（原始数据：如2025-10-01 06:52:10）',
  PRIMARY KEY (`id`),
  KEY `idx_sid` (`sid`),
  KEY `idx_seller_name` (`seller_name`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_fulfillment_channel` (`fulfillment_channel`),
  KEY `idx_is_return_order` (`is_return_order`),
  KEY `idx_purchase_date_utc` (`purchase_date_utc`),
  KEY `idx_gmt_modified` (`gmt_modified`),
  KEY `uk_amazon_order_id` (`amazon_order_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=717949 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统亚马逊(AMZ)平台订单主表（含嵌套商品明细）';

-- ----------------------------
-- Table structure for amf_lx_amzorder_item
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_amzorder_item`;
CREATE TABLE `amf_lx_amzorder_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '子表自增主键',
  `amzorder_id` bigint DEFAULT NULL COMMENT '关联主表ID',
  `amazon_order_id` varchar(64) NOT NULL COMMENT '关联亚马逊订单ID',
  `asin` varchar(64) NOT NULL COMMENT '商品ASIN码（如B09P3W1H9Y）',
  `quantity_ordered` int NOT NULL COMMENT '订购数量（原始数据均为1）',
  `seller_sku` varchar(64) NOT NULL COMMENT '卖家SKU（如EP-SCTO-32-RH-FM）',
  `local_sku` varchar(64) NOT NULL COMMENT '本地SKU（如EP-SFBZ-TC32-R）',
  `local_name` varchar(128) DEFAULT '' COMMENT '本地商品名称',
  `item_order_status` varchar(32) NOT NULL COMMENT '商品级订单状态',
  PRIMARY KEY (`id`),
  KEY `idx_asin` (`asin`),
  KEY `idx_seller_sku` (`seller_sku`),
  KEY `idx_local_sku` (`local_sku`),
  KEY `fk_amzorder_item_order` (`amazon_order_id`,`asin`,`seller_sku`,`local_sku`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=564558 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='亚马逊订单-商品明细子表';

-- ----------------------------
-- Table structure for amf_lx_amzorder_item_1
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_amzorder_item_1`;
CREATE TABLE `amf_lx_amzorder_item_1` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '子表自增主键',
  `amazon_order_id` varchar(64) NOT NULL COMMENT '关联亚马逊订单ID',
  `asin` varchar(64) NOT NULL COMMENT '商品ASIN码（如B09P3W1H9Y）',
  `quantity_ordered` int NOT NULL COMMENT '订购数量（原始数据均为1）',
  `seller_sku` varchar(64) NOT NULL COMMENT '卖家SKU（如EP-SCTO-32-RH-FM）',
  `local_sku` varchar(64) NOT NULL COMMENT '本地SKU（如EP-SFBZ-TC32-R）',
  `local_name` varchar(128) DEFAULT '' COMMENT '本地商品名称',
  `item_order_status` varchar(32) NOT NULL COMMENT '商品级订单状态',
  PRIMARY KEY (`id`),
  KEY `fk_amzorder_item_order` (`amazon_order_id`),
  KEY `idx_asin` (`asin`),
  KEY `idx_seller_sku` (`seller_sku`),
  KEY `idx_local_sku` (`local_sku`)
) ENGINE=InnoDB AUTO_INCREMENT=787031 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='亚马逊订单-商品明细子表';

-- ----------------------------
-- Table structure for amf_lx_bundled_product_items
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_bundled_product_items`;
CREATE TABLE `amf_lx_bundled_product_items` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '子表自增主键',
  `bundled_product_id` bigint NOT NULL COMMENT '关联捆绑产品主表ID',
  `product_id` bigint NOT NULL COMMENT '子产品ID（原始productId）',
  `sku` varchar(64) NOT NULL COMMENT '子产品SKU',
  `bundled_qty` int NOT NULL COMMENT '子产品捆绑数量',
  `cost_ratio` decimal(10,4) DEFAULT '0.0000' COMMENT '成本占比',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_amf_lx_bundled_product_items` (`bundled_product_id`,`sku`) USING BTREE,
  KEY `idx_bundled_product_id` (`bundled_product_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_sku` (`sku`),
  CONSTRAINT `fk_bundled_item_main` FOREIGN KEY (`bundled_product_id`) REFERENCES `amf_lx_bundledproducts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4096 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='捆绑产品-子产品关联表';

-- ----------------------------
-- Table structure for amf_lx_bundledproducts
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_bundledproducts`;
CREATE TABLE `amf_lx_bundledproducts` (
  `id` bigint NOT NULL COMMENT '捆绑产品主键ID（原始数据唯一标识，如92472、172405）',
  `sku` varchar(64) NOT NULL COMMENT '捆绑产品SKU编码（原始数据：如UK-WJGL-Oak-C60）',
  `product_name` varchar(128) NOT NULL COMMENT '捆绑产品名称（原始数据：如L桌带文件柜-灰橡木）',
  `cg_price` decimal(10,4) NOT NULL COMMENT '捆绑产品采购价（原始数据：如340.0000、355.0000）',
  `status_text` varchar(32) NOT NULL COMMENT '产品状态文本（原始数据：如在售）',
  `bundled_products` json NOT NULL COMMENT '捆绑子产品数组（包含productId/sku/bundledQty/cost_ratio）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sku` (`sku`),
  KEY `idx_status_text` (`status_text`),
  KEY `idx_cg_price` (`cg_price`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统捆绑产品主表（含嵌套子产品信息）';

-- ----------------------------
-- Table structure for amf_lx_fba_stockup
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_fba_stockup`;
CREATE TABLE `amf_lx_fba_stockup` (
  `order_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单号',
  `warehouse` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货仓库（单据）',
  `shipper` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货方',
  `direct_factory_shipment` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '工厂直发',
  `logistics_center_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '物流中心编码',
  `creator` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `creation_time` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建时间',
  `shipper_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货人',
  `shipment_time` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货时间',
  `actual_shipment_time` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实际发货时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注(单据)',
  `order_status` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单状态',
  `print_status` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '打印状态',
  `transport_mode` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '运输方式',
  `logistics_provider` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '物流商',
  `logistics_channel` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '物流渠道',
  `logistics_provider_order_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '物流商单号',
  `estimated_total_cost` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '预估总费用',
  `estimated_logistics_cost` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '预估物流费用',
  `estimated_other_cost` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '预估其他费用',
  `actual_total_cost` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实际总费用',
  `actual_logistics_cost` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实际物流费用',
  `actual_other_cost` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实际其他费用',
  `query_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '查询单号',
  `logistics_estimated_eta` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '物流预计时效',
  `estimated_arrival_time` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '预计到货时间',
  `order_logistics_status` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单物流状态',
  `vat_tax_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'VAT税号',
  `allocation_method` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分摊方式',
  `is_split_calculation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否分抛计算',
  `split_coefficient` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分抛系数',
  `product_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '品名',
  `sku` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKU',
  `declared_quantity` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '申报量(关联量)',
  `store` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺',
  `country` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '国家',
  `msku` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'MSKU',
  `fnsku` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'FNSKU',
  `asin` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ASIN',
  `parent_asin` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '父ASIN',
  `planned_shipment_quantity` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '计划发货量',
  `plan_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '计划编号',
  `shipment_plan_batch_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货计划批次号',
  `packaging_specifications` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '包装规格',
  `unit_net_weight` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单品净重',
  `unit_gross_weight` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单品毛重',
  `total_gross_weight` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '总毛重',
  `total_net_weight` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '总净重',
  `taxes` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '税费',
  `packaging_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '包装类型',
  `shipment_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货件单号',
  `shipment_quantity` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货量',
  `unit_fba_warehouse_cost` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位FBA仓入库成本',
  `unit_auxiliary_material_cost` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位辅料费用',
  `value_source` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '取值来源',
  `unit_freight_cost` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位头程费用',
  `remark_detail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注(单据明细)',
  `available_quantity` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '可用量',
  `pending_inspection_quantity` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '待检待上架量',
  `pending_arrival_quantity` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '待到货量',
  `difference` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '差额',
  `shipment_status` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货件状态',
  `unit_outbound_freight_cost` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位出库头程费用',
  `unit_taxes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位税费',
  `unit_outbound_cost` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位出库费用',
  `purchase_unit_price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购单价',
  `custom_purchase_unit_price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购单价(自定义)',
  `custom_unit_outbound_cost` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位出库费用(自定义)',
  `custom_unit_auxiliary_material_cost` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位辅料费用(自定义)',
  `custom_unit_outbound_freight` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位出库头程(自定义)',
  `custom_unit_fba_warehouse_cost` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位FBA仓入库成本(自定义)',
  `product_link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品链接',
  `per_box_quantity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单箱数量',
  `box_count` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '箱数',
  `box_gross_weight` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '箱子毛重（kg）',
  `box_length` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '箱子长度（cm）',
  `box_width` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '箱子宽度（cm）',
  `box_height` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '箱子高度（cm）',
  `box_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '箱号',
  `warehouse_detail` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货仓库（单据明细）',
  `warehouse_store` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货仓库店铺',
  `warehouse_fnsku` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货仓库FNSKU',
  `transfer_out_quantity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '调出量',
  `position_quantity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓位（数量）',
  `purchase_order_quantity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购单（关联量）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='FBA 发货单详情';

-- ----------------------------
-- Table structure for amf_lx_fbadetail
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_fbadetail`;
CREATE TABLE `amf_lx_fbadetail` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键（原始数据无天然唯一ID，新增）',
  `name` varchar(128) NOT NULL COMMENT '仓库名称（原始数据：如EP-CA加拿大仓、EP-US美国仓）',
  `sid` bigint NOT NULL COMMENT '店铺ID（原始数据：如2308、2307）',
  `asin` varchar(64) NOT NULL COMMENT '亚马逊ASIN码（原始数据：如B01MRH3R0J、B08SJW6DCG）',
  `product_name` varchar(255) DEFAULT '' COMMENT '产品名称（原始数据部分为空）',
  `small_image_url` varchar(512) DEFAULT '' COMMENT '产品小图URL（原始数据含长链接）',
  `seller_sku` varchar(64) NOT NULL COMMENT '卖家SKU（原始数据：如BD-01、EP-01LDK-OB）',
  `fnsku` varchar(64) NOT NULL COMMENT 'FBA仓库SKU（原始数据：如X0038YQO51、X002RPUZVB）',
  `sku` varchar(64) DEFAULT '' COMMENT '本地SKU（原始数据部分为空）',
  `category_text` varchar(64) DEFAULT '' COMMENT '分类文本（原始数据：如家具、空）',
  `cid` bigint NOT NULL DEFAULT '0' COMMENT '分类ID（原始数据：如7709、0）',
  `product_brand_text` varchar(64) DEFAULT '' COMMENT '品牌文本（原始数据：如Ecoprsio、空）',
  `bid` bigint NOT NULL DEFAULT '0' COMMENT '品牌ID（原始数据：如1282、0）',
  `share_type` tinyint NOT NULL DEFAULT '0' COMMENT '共享类型（原始数据均为0）',
  `total` int NOT NULL DEFAULT '0' COMMENT '库存总数',
  `total_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存总价（数值型）',
  `available_total` int NOT NULL DEFAULT '0' COMMENT '可售库存总数',
  `available_total_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '可售库存总价（原始字符串转数值）',
  `afn_fulfillable_quantity` int NOT NULL DEFAULT '0' COMMENT 'AFN可履约数量',
  `afn_fulfillable_quantity_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'AFN可履约数量价格',
  `reserved_fc_transfers` int NOT NULL DEFAULT '0' COMMENT '预留-仓库调拨数量',
  `reserved_fc_transfers_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '预留-仓库调拨价格',
  `reserved_fc_processing` int NOT NULL DEFAULT '0' COMMENT '预留-仓库处理数量',
  `reserved_fc_processing_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '预留-仓库处理价格',
  `reserved_customerorders` int NOT NULL DEFAULT '0' COMMENT '预留-客户订单数量',
  `reserved_customerorders_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '预留-客户订单价格',
  `quantity` int NOT NULL DEFAULT '0' COMMENT '库存数量（通用）',
  `quantity_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存数量价格',
  `afn_unsellable_quantity` int NOT NULL DEFAULT '0' COMMENT 'AFN不可售数量',
  `afn_unsellable_quantity_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'AFN不可售数量价格',
  `afn_inbound_working_quantity` int NOT NULL DEFAULT '0' COMMENT 'AFN入库处理中数量',
  `afn_inbound_working_quantity_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'AFN入库处理中价格',
  `afn_inbound_shipped_quantity` int NOT NULL DEFAULT '0' COMMENT 'AFN入库已发货数量',
  `afn_inbound_shipped_quantity_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'AFN入库已发货价格',
  `afn_inbound_receiving_quantity` int NOT NULL DEFAULT '0' COMMENT 'AFN入库接收中数量',
  `afn_inbound_receiving_quantity_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'AFN入库接收中价格',
  `stock_up_num` int NOT NULL DEFAULT '0' COMMENT '备货数量',
  `stock_up_num_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '备货数量价格',
  `afn_researching_quantity` int NOT NULL DEFAULT '0' COMMENT 'AFN核查中数量',
  `afn_researching_quantity_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'AFN核查中价格',
  `total_fulfillable_quantity` int NOT NULL DEFAULT '0' COMMENT '总可履约数量',
  `inv_age_0_to_90_days` int NOT NULL DEFAULT '0' COMMENT '库存年龄0-90天数量',
  `inv_age_0_to_90_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存年龄0-90天价格',
  `inv_age_271_to_365_days` int NOT NULL DEFAULT '0' COMMENT '库存年龄271-365天数量',
  `inv_age_271_to_365_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存年龄271-365天价格',
  `inv_age_0_to_30_days` int NOT NULL DEFAULT '0' COMMENT '库存年龄0-30天数量',
  `inv_age_0_to_30_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存年龄0-30天价格',
  `inv_age_31_to_60_days` int NOT NULL DEFAULT '0' COMMENT '库存年龄31-60天数量',
  `inv_age_31_to_60_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存年龄31-60天价格',
  `inv_age_61_to_90_days` int NOT NULL DEFAULT '0' COMMENT '库存年龄61-90天数量',
  `inv_age_61_to_90_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存年龄61-90天价格',
  `inv_age_91_to_180_days` int NOT NULL DEFAULT '0' COMMENT '库存年龄91-180天数量',
  `inv_age_91_to_180_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存年龄91-180天价格',
  `inv_age_181_to_270_days` int NOT NULL DEFAULT '0' COMMENT '库存年龄181-270天数量',
  `inv_age_181_to_270_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存年龄181-270天价格',
  `inv_age_271_to_330_days` int NOT NULL DEFAULT '0' COMMENT '库存年龄271-330天数量',
  `inv_age_271_to_330_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存年龄271-330天价格',
  `inv_age_331_to_365_days` int NOT NULL DEFAULT '0' COMMENT '库存年龄331-365天数量',
  `inv_age_331_to_365_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存年龄331-365天价格',
  `inv_age_365_plus_days` int NOT NULL DEFAULT '0' COMMENT '库存年龄365天以上数量',
  `inv_age_365_plus_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '库存年龄365天以上价格',
  `recommended_action` varchar(64) DEFAULT '' COMMENT '推荐操作（原始数据为空）',
  `sell_through` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '售罄率',
  `estimated_excess_quantity` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '预估过剩数量',
  `estimated_storage_cost_next_month` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '下月预估仓储费',
  `fba_minimum_inventory_level` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'FBA最低库存水平',
  `fba_inventory_level_health_status` varchar(64) DEFAULT '' COMMENT 'FBA库存健康状态（原始数据为空）',
  `historical_days_of_supply` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '历史供应天数',
  `historical_days_of_supply_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '历史供应天数对应价格',
  `low_inventory_level_fee_applied` varchar(32) DEFAULT '' COMMENT '低库存费用是否适用（原始数据为空）',
  `fulfillment_channel` varchar(32) NOT NULL COMMENT '履约渠道（原始数据：AMAZON_NA）',
  `cg_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '采购价（原始数据：如185.70、0.00）',
  `cg_transport_costs` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '运输成本（原始数据：如98.79、0.00）',
  `fba_storage_quantity_list` json DEFAULT NULL COMMENT 'FBA仓储数量列表（原始数据为None，JSON类型保留扩展）',
  `sync_date` date DEFAULT NULL COMMENT '同步日期',
  `isdel` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_shop_asin_sellersku_fnsku` (`name`,`sid`,`asin`,`seller_sku`,`fnsku`,`sku`) USING BTREE,
  KEY `idx_name` (`name`),
  KEY `idx_sid` (`sid`),
  KEY `idx_asin` (`asin`),
  KEY `idx_seller_sku` (`seller_sku`),
  KEY `idx_fnsku` (`fnsku`),
  KEY `idx_sku` (`sku`),
  KEY `idx_total` (`total`),
  KEY `idx_afn_fulfillable_quantity` (`afn_fulfillable_quantity`),
  KEY `idx_fulfillment_channel` (`fulfillment_channel`)
) ENGINE=InnoDB AUTO_INCREMENT=37591 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统FBA库存明细表（多维度库存数量/价格/年龄）';

-- ----------------------------
-- Table structure for amf_lx_fbarestock
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_fbarestock`;
CREATE TABLE `amf_lx_fbarestock` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `hash_id` varchar(64) NOT NULL COMMENT '数据唯一哈希ID（如0005deccd0ec9c0b0a31d758b3e92c37）',
  `data_type` tinyint NOT NULL COMMENT '数据类型（原始数据：2）',
  `node_type` tinyint NOT NULL COMMENT '节点类型（原始数据：3）',
  `sid` varchar(32) NOT NULL COMMENT '店铺ID（原始数据：4512、2319）',
  `asin` varchar(64) NOT NULL COMMENT '亚马逊ASIN码（如B0C7BYPGC5、B08BP8V3V9）',
  `msku_fnsku_list` json NOT NULL COMMENT 'MSKU-FNSKU映射列表（嵌套数组）',
  `listing_opentime_list` json NOT NULL COMMENT 'Listing上架时间列表（嵌套数组）',
  `sync_time` datetime NOT NULL COMMENT '数据同步时间（原始格式转datetime：2025-12-04 08:28:52）',
  `amazon_quantity_valid` int NOT NULL DEFAULT '0' COMMENT '亚马逊有效库存数量',
  `amazon_quantity_shipping` int NOT NULL DEFAULT '0' COMMENT '亚马逊发货中库存数量',
  `amazon_quantity_shipping_plan` int NOT NULL DEFAULT '0' COMMENT '亚马逊发货计划库存数量',
  `afn_fulfillable_quantity` int NOT NULL DEFAULT '0' COMMENT 'AFN可履约数量',
  `reserved_fc_transfers` int NOT NULL DEFAULT '0' COMMENT '预留-仓库调拨数量',
  `reserved_fc_processing` int NOT NULL DEFAULT '0' COMMENT '预留-仓库处理数量',
  `afn_inbound_receiving_quantity` int NOT NULL DEFAULT '0' COMMENT 'AFN入库接收中数量',
  `sc_quantity_local_valid` int NOT NULL DEFAULT '0' COMMENT '本地有效库存数量',
  `sc_quantity_oversea_valid` int NOT NULL DEFAULT '0' COMMENT '海外有效库存数量',
  `sc_quantity_oversea_shipping` int NOT NULL DEFAULT '0' COMMENT '海外发货中库存数量',
  `sc_quantity_local_qc` int NOT NULL DEFAULT '0' COMMENT '本地QC中库存数量',
  `sc_quantity_purchase_plan` int NOT NULL DEFAULT '0' COMMENT '采购计划库存数量',
  `sc_quantity_purchase_shipping` int NOT NULL DEFAULT '0' COMMENT '采购发货中库存数量',
  `sc_quantity_local_shipping` int NOT NULL DEFAULT '0' COMMENT '本地发货中库存数量',
  `sales_avg_3` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '近3天销售均值',
  `sales_avg_7` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '近7天销售均值',
  `sales_avg_14` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '近14天销售均值',
  `sales_avg_30` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '近30天销售均值',
  `sales_avg_60` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '近60天销售均值',
  `sales_avg_90` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '近90天销售均值',
  `sales_total_3` int NOT NULL DEFAULT '0' COMMENT '近3天销售总量',
  `sales_total_7` int NOT NULL DEFAULT '0' COMMENT '近7天销售总量',
  `sales_total_14` int NOT NULL DEFAULT '0' COMMENT '近14天销售总量',
  `sales_total_30` int NOT NULL DEFAULT '0' COMMENT '近30天销售总量',
  `sales_total_60` int NOT NULL DEFAULT '0' COMMENT '近60天销售总量',
  `sales_total_90` int NOT NULL DEFAULT '0' COMMENT '近90天销售总量',
  `out_stock_flag` tinyint NOT NULL DEFAULT '0' COMMENT '缺货标识（0=否）',
  `out_stock_date` varchar(32) DEFAULT '' COMMENT '缺货日期（原始数据为空）',
  `estimated_sale_quantity` int NOT NULL DEFAULT '0' COMMENT '预估销售数量',
  `estimated_sale_avg_quantity` int NOT NULL DEFAULT '0' COMMENT '预估销售平均数量',
  `available_sale_days` decimal(10,2) DEFAULT NULL COMMENT '可售天数（允许NULL适配原始None）',
  `fba_available_sale_days` decimal(10,2) DEFAULT NULL COMMENT 'FBA可售天数（允许NULL适配原始None）',
  `available_sale_days_fba` decimal(10,2) DEFAULT NULL COMMENT 'FBA可售天数（重复字段，保留）',
  `quantity_sug_purchase` int NOT NULL DEFAULT '0' COMMENT '建议采购数量',
  `quantity_sug_local_to_oversea` int NOT NULL DEFAULT '0' COMMENT '建议本地调拨至海外数量',
  `quantity_sug_local_to_fba` int NOT NULL DEFAULT '0' COMMENT '建议本地调拨至FBA数量',
  `quantity_sug_oversea_to_fba` int NOT NULL DEFAULT '0' COMMENT '建议海外调拨至FBA数量',
  `out_stock_date_purchase` varchar(32) DEFAULT '' COMMENT '采购缺货日期',
  `out_stock_date_local` varchar(32) DEFAULT '' COMMENT '本地调拨缺货日期',
  `out_stock_date_oversea` varchar(32) DEFAULT '' COMMENT '海外调拨缺货日期',
  `sug_date_purchase` varchar(32) DEFAULT '' COMMENT '建议采购日期',
  `sug_date_send_local` varchar(32) DEFAULT '' COMMENT '建议本地发货日期',
  `sug_date_send_oversea` varchar(32) DEFAULT '' COMMENT '建议海外发货日期',
  `suggest_sm_list` json NOT NULL COMMENT '运输方式建议列表（嵌套数组：海派/空派等）',
  `restock_status` tinyint NOT NULL DEFAULT '0' COMMENT '补货状态（0=未补货）',
  `remark` varchar(255) DEFAULT '' COMMENT '备注（原始数据为空）',
  `star` tinyint NOT NULL DEFAULT '0' COMMENT '星级（原始数据为0）',
  `need_flag` tinyint DEFAULT NULL COMMENT '是否需要补货（允许NULL适配原始None）',
  `item_list` json NOT NULL COMMENT '商品列表（原始数据为空数组）',
  PRIMARY KEY (`id`),
  KEY `idx_sid` (`sid`),
  KEY `idx_asin` (`asin`),
  KEY `idx_sync_time` (`sync_time`),
  KEY `idx_out_stock_flag` (`out_stock_flag`),
  KEY `idx_afn_fulfillable_quantity` (`afn_fulfillable_quantity`),
  KEY `idx_sales_avg_30` (`sales_avg_30`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统FBA补货建议表（含库存/销售/补货维度）';

-- ----------------------------
-- Table structure for amf_lx_fbashipment
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_fbashipment`;
CREATE TABLE `amf_lx_fbashipment` (
  `id` bigint NOT NULL COMMENT '发货单主键ID（原始数据：190992、190991）',
  `shipment_sn` varchar(64) NOT NULL COMMENT '发货单编号（如SP250118605）',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '发货单状态码（1=已发货）',
  `status_name` varchar(32) NOT NULL DEFAULT '' COMMENT '发货单状态名称（如已发货）',
  `shipment_time` date NOT NULL COMMENT '发货日期（如2025-02-06）',
  `shipment_time_second` datetime DEFAULT NULL COMMENT '发货时间（含时分秒：2025-02-06 16:33:52）',
  `wname` varchar(32) NOT NULL DEFAULT '' COMMENT '仓库名称简称（如田、潘）',
  `wid` bigint NOT NULL DEFAULT '0' COMMENT '仓库ID（如4000、3988）',
  `create_user` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人（如吴慧格）',
  `logistics_channel_name` varchar(64) NOT NULL DEFAULT '' COMMENT '物流渠道名称（如默认物流渠道）',
  `expected_arrival_date` date DEFAULT NULL COMMENT '预计到达日期（如2025-03-08）',
  `etd_date` varchar(32) DEFAULT '' COMMENT '预计开航日期（原始数据为空）',
  `eta_date` varchar(32) DEFAULT '' COMMENT '预计到港日期（原始数据为空）',
  `delivery_date` varchar(32) DEFAULT '' COMMENT '交付日期（原始数据为空）',
  `create_time` date NOT NULL COMMENT '创建日期（如2025-01-18）',
  `gmt_create` datetime NOT NULL COMMENT '创建时间（含时分秒：2025-01-18 15:27:32）',
  `update_time` datetime NOT NULL COMMENT '更新时间（如2025-02-06 16:33:52）',
  `last_update_time` datetime DEFAULT NULL COMMENT '最后更新时间（同update_time）',
  `is_pick` tinyint NOT NULL DEFAULT '0' COMMENT '是否已提货（1=是）',
  `pick_time` date DEFAULT NULL COMMENT '提货日期（如2025-02-06）',
  `is_print` tinyint NOT NULL DEFAULT '0' COMMENT '是否已打印（0=否）',
  `print_num` int NOT NULL DEFAULT '0' COMMENT '打印次数',
  `head_fee_type` tinyint NOT NULL DEFAULT '0' COMMENT '计费类型码',
  `head_fee_type_name` varchar(64) DEFAULT '' COMMENT '计费类型名称（如按计费重）',
  `head_fee_type_name_new` varchar(64) DEFAULT '' COMMENT '新计费类型名称（如产品-计费重）',
  `file_id` varchar(64) DEFAULT '' COMMENT '文件ID（原始数据为空）',
  `remark` varchar(255) DEFAULT '' COMMENT '备注（原始数据为空）',
  `is_return_stock` tinyint NOT NULL DEFAULT '0' COMMENT '是否退货入库（0=否）',
  `actual_shipment_time` varchar(32) DEFAULT '' COMMENT '实际发货时间（原始数据为空）',
  `logistics_provider_id` varchar(32) DEFAULT '' COMMENT '物流商ID（如256）',
  `logistics_provider_name` varchar(64) DEFAULT '' COMMENT '物流商名称（如默认物流商）',
  `pay_status` tinyint NOT NULL DEFAULT '0' COMMENT '支付状态（0=未支付）',
  `audit_status` tinyint NOT NULL DEFAULT '0' COMMENT '审核状态（0=未审核）',
  `shipment_user` varchar(64) DEFAULT '' COMMENT '发货人（如吴慧格）',
  `is_exist_declaration` tinyint NOT NULL DEFAULT '0' COMMENT '是否存在申报（0=否）',
  `is_exist_clearance` tinyint NOT NULL DEFAULT '0' COMMENT '是否存在清关（0=否）',
  `third_party_order_mode` tinyint NOT NULL DEFAULT '0' COMMENT '第三方订单模式（0=否）',
  `third_party_order_status` tinyint NOT NULL DEFAULT '0' COMMENT '第三方订单状态',
  `vat_code` varchar(64) DEFAULT '' COMMENT 'VAT编码（原始数据为空）',
  `method_id` varchar(64) DEFAULT '' COMMENT '物流方式ID（原始数据为空）',
  `method_name` varchar(64) DEFAULT '' COMMENT '物流方式名称（原始数据为空）',
  `is_custom_shipment_time` tinyint NOT NULL DEFAULT '0' COMMENT '是否自定义发货时间（0=否）',
  `is_delete` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除（0=否）',
  `destination_fulfillment_center_id` varchar(32) DEFAULT '' COMMENT '目的FBA仓库ID（如SBD3、SMF6）',
  `custom_fields` json NOT NULL COMMENT '自定义字段（空数组）',
  `relate_list` json NOT NULL COMMENT '关联商品列表（核心嵌套数组）',
  `not_relate_list` json NOT NULL COMMENT '非关联商品列表（空数组）',
  `logistics` json NOT NULL COMMENT '物流信息列表（嵌套数组）',
  `logistics_list` json NOT NULL COMMENT '物流信息列表（同logistics，冗余保留）',
  `fileList` json NOT NULL COMMENT '文件列表（空数组）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_shipment_sn` (`shipment_sn`),
  KEY `idx_wname` (`wname`),
  KEY `idx_wid` (`wid`),
  KEY `idx_status` (`status`),
  KEY `idx_shipment_time` (`shipment_time`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_logistics_provider_id` (`logistics_provider_id`),
  KEY `idx_destination_fulfillment_center_id` (`destination_fulfillment_center_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统FBA发货单主表（含嵌套商品/物流信息）';

-- ----------------------------
-- Table structure for amf_lx_fbashipment_item
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_fbashipment_item`;
CREATE TABLE `amf_lx_fbashipment_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `item_id` bigint NOT NULL COMMENT '商品明细ID（原始relate_list.id）',
  `shipment_id` bigint NOT NULL COMMENT '关联发货单主表ID（amf_lx_fbashipment.id）',
  `shipment_sn` varchar(64) NOT NULL COMMENT '关联发货单编号（如SP250118605）',
  `destination_fulfillment_center_id` varchar(32) NOT NULL DEFAULT '' COMMENT '目的FBA仓库ID（如SBD3）',
  `quantity_shipped` varchar(32) NOT NULL DEFAULT '' COMMENT '已发货数量（字符串型）',
  `mid` bigint NOT NULL DEFAULT '0' COMMENT '商品中间ID',
  `is_delete` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除（0=否）',
  `shipment_status` varchar(32) NOT NULL DEFAULT '' COMMENT '发货状态（如CLOSED）',
  `sta_inbound_plan_id` varchar(64) DEFAULT '' COMMENT 'STA入库计划ID',
  `is_sta` tinyint NOT NULL DEFAULT '0' COMMENT '是否STA（1=是/0=否）',
  `wname` varchar(32) NOT NULL DEFAULT '' COMMENT '仓库简称（如田、潘）',
  `wid` bigint NOT NULL DEFAULT '0' COMMENT '仓库ID',
  `pid` bigint NOT NULL DEFAULT '0' COMMENT '产品ID（同mid）',
  `sname` varchar(64) NOT NULL DEFAULT '' COMMENT '店铺+品类名称',
  `product_name` varchar(255) NOT NULL DEFAULT '' COMMENT '产品名称',
  `num` int NOT NULL DEFAULT '0' COMMENT '发货数量（数值型）',
  `pic_url` varchar(512) DEFAULT '' COMMENT '产品图片URL',
  `packing_type` tinyint NOT NULL DEFAULT '0' COMMENT '包装类型码',
  `packing_type_name` varchar(32) DEFAULT '' COMMENT '包装类型名称',
  `fulfillment_network_sku` varchar(64) NOT NULL DEFAULT '' COMMENT 'FBA仓库SKU',
  `sku` varchar(64) NOT NULL DEFAULT '' COMMENT '卖家SKU',
  `fnsku` varchar(64) DEFAULT '' COMMENT 'FNSKU',
  `msku` varchar(64) NOT NULL DEFAULT '' COMMENT 'MSKU',
  `nation` varchar(32) NOT NULL DEFAULT '' COMMENT '发货国家（如美国）',
  `apply_num` int NOT NULL DEFAULT '0' COMMENT '申请发货数量',
  `product_id` bigint NOT NULL DEFAULT '0' COMMENT '产品系统ID',
  `product_mws_id` bigint NOT NULL DEFAULT '0' COMMENT '产品MWS ID',
  `asin` varchar(64) NOT NULL DEFAULT '' COMMENT '亚马逊ASIN',
  `parent_asin` varchar(64) DEFAULT '' COMMENT '父ASIN',
  `remark` varchar(255) DEFAULT '' COMMENT '商品备注',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '商品发货状态码',
  `sid` bigint NOT NULL DEFAULT '0' COMMENT '店铺ID',
  `is_combo` tinyint NOT NULL DEFAULT '0' COMMENT '是否组合商品',
  `total_vw` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '总体积重量',
  `total_nw` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '总净重',
  `total_gw` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '总毛重',
  `create_by_mws` tinyint NOT NULL DEFAULT '0' COMMENT '是否通过MWS创建',
  `whb_code_list` json NOT NULL COMMENT 'WHB编码列表',
  `asin_url` varchar(512) DEFAULT '' COMMENT 'ASIN亚马逊链接',
  `product_valid_num` int NOT NULL DEFAULT '0' COMMENT '产品有效数量',
  `product_qc_num` int NOT NULL DEFAULT '0' COMMENT '产品QC数量',
  `diff_num` int NOT NULL DEFAULT '0' COMMENT '数量差异',
  `shipment_order_list` json NOT NULL COMMENT '发货订单列表',
  `seqs` varchar(64) DEFAULT '' COMMENT '序列号',
  `audit_status` tinyint NOT NULL DEFAULT '0' COMMENT '审核状态',
  `shipment_plan_quantity_total` int NOT NULL DEFAULT '0' COMMENT '发货计划总数量',
  `sta_shipment_id` varchar(64) DEFAULT '' COMMENT 'STA发货单ID',
  `custom_fields` json NOT NULL COMMENT '自定义字段',
  `len` tinyint NOT NULL DEFAULT '0' COMMENT '长度',
  `shipment_id_fba` varchar(64) DEFAULT '' COMMENT 'FBA发货单ID（原始shipment_id）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_item_id` (`item_id`) COMMENT '商品明细ID唯一',
  UNIQUE KEY `uk_shipment_sn_sku` (`shipment_sn`,`sku`) COMMENT '发货单+SKU唯一',
  KEY `idx_shipment_id` (`shipment_id`),
  KEY `idx_sku` (`sku`),
  KEY `idx_asin` (`asin`),
  KEY `idx_destination_fulfillment_center_id` (`destination_fulfillment_center_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32768 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统FBA货单商品明细表（与relate_list字段匹配）';

-- ----------------------------
-- Table structure for amf_lx_fbmorders
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_fbmorders`;
CREATE TABLE `amf_lx_fbmorders` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `order_number` varchar(50) NOT NULL COMMENT '订单编号',
  `amazon_order_id` varchar(50) DEFAULT NULL COMMENT '亚马逊订单号（从platform_list提取）',
  `status` varchar(20) NOT NULL COMMENT '订单状态',
  `order_from` varchar(20) NOT NULL COMMENT '订单来源',
  `country_code` varchar(10) NOT NULL COMMENT '国家代码',
  `purchase_time` datetime NOT NULL COMMENT '下单时间',
  `logistics_type_id` varchar(50) NOT NULL COMMENT '物流类型ID',
  `logistics_provider_id` varchar(50) NOT NULL COMMENT '物流提供商ID',
  `platform_list` json NOT NULL COMMENT '平台列表',
  `logistics_type_name` varchar(50) NOT NULL COMMENT '物流类型名称',
  `logistics_provider_name` varchar(50) NOT NULL COMMENT '物流提供商名称',
  `wid` int NOT NULL COMMENT '仓库ID',
  `warehouse_name` varchar(50) NOT NULL COMMENT '仓库名称',
  `customer_comment` text COMMENT '客户备注',
  PRIMARY KEY (`id`),
  KEY `uk_order_number` (`order_number`) USING BTREE COMMENT '订单编号索引'
) ENGINE=InnoDB AUTO_INCREMENT=539103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统自发货订单表';

-- ----------------------------
-- Table structure for amf_lx_fbmorders_copy1
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_fbmorders_copy1`;
CREATE TABLE `amf_lx_fbmorders_copy1` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `order_number` varchar(50) NOT NULL COMMENT '订单编号',
  `amazon_order_id` varchar(50) DEFAULT NULL COMMENT '亚马逊订单号（从platform_list提取）',
  `status` varchar(20) NOT NULL COMMENT '订单状态',
  `order_from` varchar(20) NOT NULL COMMENT '订单来源',
  `country_code` varchar(10) NOT NULL COMMENT '国家代码',
  `purchase_time` datetime NOT NULL COMMENT '下单时间',
  `logistics_type_id` varchar(50) NOT NULL COMMENT '物流类型ID',
  `logistics_provider_id` varchar(50) NOT NULL COMMENT '物流提供商ID',
  `platform_list` json NOT NULL COMMENT '平台列表',
  `logistics_type_name` varchar(50) NOT NULL COMMENT '物流类型名称',
  `logistics_provider_name` varchar(50) NOT NULL COMMENT '物流提供商名称',
  `wid` int NOT NULL COMMENT '仓库ID',
  `warehouse_name` varchar(50) NOT NULL COMMENT '仓库名称',
  `customer_comment` text COMMENT '客户备注',
  PRIMARY KEY (`id`),
  KEY `uk_order_number` (`order_number`) USING BTREE COMMENT '订单编号索引'
) ENGINE=InnoDB AUTO_INCREMENT=539103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统自发货订单表';

-- ----------------------------
-- Table structure for amf_lx_mporders
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_mporders`;
CREATE TABLE `amf_lx_mporders` (
  `global_order_no` varchar(50) NOT NULL COMMENT '全局订单编号',
  `reference_no` varchar(50) DEFAULT '' COMMENT '外部参考编号',
  `store_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺ID',
  `order_from_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单来源名称（如：线上订单）',
  `delivery_type` int DEFAULT NULL COMMENT '配送类型（1/2/... 表示不同配送方式）',
  `split_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '拆分类型（如：3表示拆分订单）',
  `status` int DEFAULT NULL COMMENT '订单状态（如：4表示待处理）',
  `global_purchase_time` bigint DEFAULT NULL COMMENT '全局下单时间（时间戳）',
  `global_payment_time` bigint DEFAULT NULL COMMENT '全局支付时间（时间戳，可为空）',
  `global_review_time` bigint DEFAULT NULL COMMENT '全局审核时间（时间戳，可为空）',
  `global_distribution_time` bigint DEFAULT NULL COMMENT '全局发货时间（时间戳，可为空）',
  `global_print_time` bigint DEFAULT NULL COMMENT '打印时间（时间戳，可为空）',
  `global_mark_time` bigint DEFAULT NULL COMMENT '标记时间（时间戳）',
  `global_delivery_time` bigint DEFAULT NULL COMMENT '全局送达时间（时间戳）',
  `global_latest_ship_time` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '最晚发货时间（时间戳字符串）',
  `global_cancel_time` bigint DEFAULT NULL COMMENT '取消时间（时间戳）',
  `update_time` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新时间（时间戳字符串）',
  `global_create_time` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '全局创建时间（格式化字符串，如：2025-11-01 08:00:31）',
  `amount_currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '金额货币类型（如：USD）',
  `remark` text COMMENT '订单备注',
  `order_tag` json DEFAULT NULL COMMENT '订单标签数组（含标签类型、编号、名称，如：[{"tag_type":"系统处理类型",...}]）',
  `pending_order_tag` json DEFAULT NULL COMMENT '待处理标签数组（如：["待人工审核"]）',
  `exception_order_tag` json DEFAULT NULL COMMENT '异常标签数组（空数组表示无异常）',
  `wid` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓库ID',
  `warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓库名称（如：SCH、CAR）',
  `buyers_info` json DEFAULT NULL COMMENT '买家信息对象（含买家编号、邮箱、姓名等）',
  `address_info` json DEFAULT NULL COMMENT '收货地址对象（含收件人、电话、地址详情等）',
  `item_info` json DEFAULT NULL COMMENT '商品信息数组（含商品编号、SKU、价格、数量等核心商品数据）',
  `platform_info` json DEFAULT NULL COMMENT '平台信息数组（含平台订单号、来源、状态等）',
  `payment_info` json DEFAULT NULL COMMENT '支付信息数组（含支付方式、金额、时间等）',
  `logistics_info` json DEFAULT NULL COMMENT '物流信息对象（含物流商、重量、费用等）',
  `transaction_info` json DEFAULT NULL COMMENT '交易信息数组（含订单金额、税费、利润等）',
  `original_global_order_no` varchar(50) DEFAULT NULL COMMENT '原始全局订单号（拆分订单时关联原订单，可为空）',
  `customer_shipping_list` json DEFAULT NULL COMMENT '客户选择的物流方式数组（如：["FDEG-FEDEX_HOME"]）',
  `supplier_id` varchar(50) DEFAULT NULL COMMENT '供应商ID（可为空）',
  `is_delete` tinyint DEFAULT '0' COMMENT '删除标识（0：未删除，1：已删除）',
  `order_custom_fields` json DEFAULT NULL COMMENT '订单自定义字段（可为空）',
  `platform_code` varchar(50) DEFAULT NULL COMMENT '平台编码（从platform_info提取）',
  `platform_order_no` varchar(100) DEFAULT NULL COMMENT '平台订单号（从platform_info提取）',
  PRIMARY KEY (`global_order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for amf_lx_mporders_item
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_mporders_item`;
CREATE TABLE `amf_lx_mporders_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `global_order_no` varchar(50) NOT NULL COMMENT '关联的全局订单号',
  `globalItemNo` varchar(50) DEFAULT NULL COMMENT '商品全局编号',
  `item_id` varchar(50) DEFAULT NULL COMMENT '商品项ID',
  `platform_order_no` varchar(50) DEFAULT NULL COMMENT '平台订单号',
  `order_item_no` varchar(100) DEFAULT NULL COMMENT '订单项编号',
  `item_from_name` varchar(50) DEFAULT NULL COMMENT '商品来源名称',
  `msku` varchar(100) DEFAULT NULL COMMENT '商品MSKU',
  `local_sku` varchar(100) DEFAULT NULL COMMENT '本地SKU',
  `product_no` varchar(100) DEFAULT NULL COMMENT '产品编号',
  `local_product_name` varchar(255) DEFAULT NULL COMMENT '本地产品名称',
  `is_bundled` tinyint DEFAULT NULL COMMENT '是否捆绑商品（0/1）',
  `unit_price_amount` decimal(10,2) DEFAULT NULL COMMENT '单价金额',
  `item_price_amount` decimal(10,2) DEFAULT NULL COMMENT '商品总价金额',
  `quantity` int DEFAULT NULL COMMENT '数量',
  `remark` text COMMENT '备注',
  `type` varchar(20) DEFAULT NULL COMMENT '类型（如：产品）',
  `stock_cost_amount` decimal(10,2) DEFAULT NULL COMMENT '库存成本金额',
  `shipping_amount` decimal(10,2) DEFAULT NULL COMMENT '运费金额',
  `discount_amount` decimal(10,2) DEFAULT NULL COMMENT '折扣金额',
  `tax_amount` decimal(10,2) DEFAULT NULL COMMENT '税费金额',
  `sales_revenue_amount` decimal(10,2) DEFAULT NULL COMMENT '销售收入金额',
  `transaction_fee_amount` decimal(10,2) DEFAULT NULL COMMENT '交易手续费金额',
  `data_json` json DEFAULT NULL COMMENT '商品扩展JSON数据',
  `is_delete` tinyint DEFAULT NULL COMMENT '删除标识（0/1）',
  PRIMARY KEY (`id`),
  KEY `global_order_no` (`global_order_no`),
  CONSTRAINT `amf_lx_mporders_item_ibfk_1` FOREIGN KEY (`global_order_no`) REFERENCES `amf_lx_mporders` (`global_order_no`)
) ENGINE=InnoDB AUTO_INCREMENT=126336 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='LX多平台订单商品详情表';

-- ----------------------------
-- Table structure for amf_lx_mpskupair
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_mpskupair`;
CREATE TABLE `amf_lx_mpskupair` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键（原始数据无唯一ID，新增）',
  `store_id` varchar(64) NOT NULL COMMENT '店铺ID（原始数据：如110435522234958336，字符串型避免数值溢出）',
  `store_name` varchar(128) NOT NULL COMMENT '店铺名称（原始数据：如Aheaplus-US、MJJ Walmart）',
  `platform_code` varchar(32) NOT NULL COMMENT '平台编码（原始数据：如10011、10008）',
  `platform_name` varchar(64) NOT NULL COMMENT '平台名称（原始数据：如TikTok、Walmart、eBay）',
  `msku` varchar(64) DEFAULT '' COMMENT '平台SKU（原始数据部分为空字符串）',
  `sku` varchar(64) DEFAULT '' COMMENT '本地SKU（原始数据部分为空字符串）',
  `local_name` varchar(128) DEFAULT '' COMMENT '本地产品名称（原始数据：如DKY-72衣帽架加布兜灰橡木）',
  `modify_time` datetime NOT NULL COMMENT '最后修改时间（原始数据：如2024-07-09 21:02:17）',
  PRIMARY KEY (`id`),
  KEY `idx_store_id` (`store_id`),
  KEY `idx_platform_code` (`platform_code`),
  KEY `idx_platform_name` (`platform_name`),
  KEY `idx_msku` (`msku`),
  KEY `idx_sku` (`sku`),
  KEY `idx_modify_time` (`modify_time`),
  KEY `uk_store_platform_msku_sku` (`store_id`,`platform_code`,`msku`,`sku`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=31943 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统多平台SKU配对表（店铺-平台-SKU关联）';

-- ----------------------------
-- Table structure for amf_lx_platform
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_platform`;
CREATE TABLE `amf_lx_platform` (
  `platform_code` int NOT NULL COMMENT '领星系统平台编码',
  `platform_name` varchar(50) NOT NULL COMMENT '平台名称',
  PRIMARY KEY (`platform_code`) COMMENT '主键：平台编码',
  UNIQUE KEY `idx_platform_code` (`platform_code`) COMMENT '唯一索引：平台编码',
  KEY `idx_platform_name` (`platform_name`) COMMENT '普通索引：平台名称'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统平台编码对照表';

-- ----------------------------
-- Table structure for amf_lx_products
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_products`;
CREATE TABLE `amf_lx_products` (
  `id` bigint NOT NULL COMMENT '产品主键ID（原始数据唯一标识，如49510）',
  `cid` bigint NOT NULL COMMENT '分类ID（原始数据：如7709）',
  `bid` bigint NOT NULL COMMENT '品牌ID（原始数据：如1280、1277）',
  `sku` varchar(64) NOT NULL COMMENT '产品SKU编码（原始数据：如AC-T2-CB-47-O）',
  `sku_identifier` varchar(64) DEFAULT '' COMMENT 'SKU标识符（原始数据均为空字符串）',
  `product_name` varchar(128) NOT NULL COMMENT '产品名称（原始数据：如T2款桌子47寸带布兜插座灰橡木）',
  `pic_url` varchar(512) DEFAULT '' COMMENT '产品图片URL（原始数据部分为空，支持长链接）',
  `cg_delivery` int DEFAULT NULL COMMENT '供货周期（原始数据：如45）',
  `cg_transport_costs` decimal(10,2) DEFAULT '0.00' COMMENT '运输成本（原始数据：如0.00）',
  `purchase_remark` varchar(255) DEFAULT '' COMMENT '采购备注（原始数据均为空字符串）',
  `cg_price` decimal(10,4) NOT NULL COMMENT '产品采购价（原始数据：如153.0000、92.6500）',
  `status` tinyint NOT NULL COMMENT '产品状态（原始数据：1=在售）',
  `open_status` tinyint NOT NULL COMMENT '上架状态（原始数据：1=已上架）',
  `is_combo` tinyint NOT NULL DEFAULT '0' COMMENT '是否组合产品（原始数据：0=否）',
  `create_time` int NOT NULL COMMENT '创建时间戳（原始数据：如1653980067，需转datetime可通过FROM_UNIXTIME()）',
  `update_time` int NOT NULL COMMENT '更新时间戳（原始数据：如1721644198）',
  `product_developer_uid` bigint DEFAULT NULL COMMENT '产品开发人员UID（原始数据：如10161415）',
  `cg_opt_uid` bigint DEFAULT '0' COMMENT '操作人UID（原始数据均为0）',
  `cg_opt_username` varchar(64) DEFAULT '' COMMENT '操作人姓名（原始数据均为空字符串）',
  `spu` varchar(64) DEFAULT '' COMMENT '产品SPU编码（原始数据均为空字符串）',
  `ps_id` bigint DEFAULT '0' COMMENT '未知字段（原始数据均为0，保留字段）',
  `attribute` json DEFAULT NULL COMMENT '产品属性数组（原始数据均为空数组）',
  `brand_name` varchar(64) DEFAULT NULL COMMENT '品牌名称（原始数据：如Armocity、Foxemart）',
  `category_name` varchar(64) DEFAULT NULL COMMENT '分类名称（原始数据：如家具）',
  `status_text` varchar(32) DEFAULT NULL COMMENT '状态文本描述（原始数据：如在售）',
  `product_developer` varchar(64) DEFAULT NULL COMMENT '产品开发人员名称（原始数据：如超级管理员）',
  `supplier_quote` json NOT NULL COMMENT '供应商报价信息数组（嵌套结构，含供应商、报价、阶梯价等）',
  `aux_relation_list` json DEFAULT NULL COMMENT '辅助关联列表（原始数据均为空数组）',
  `custom_fields` json DEFAULT NULL COMMENT '自定义字段数组（原始数据均为空数组）',
  `global_tags` json DEFAULT NULL COMMENT '全局标签数组（原始数据均为空数组）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sku` (`sku`),
  KEY `idx_cid` (`cid`),
  KEY `idx_bid` (`bid`),
  KEY `idx_status_open_status` (`status`,`open_status`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_update_time` (`update_time`),
  KEY `idx_brand_name` (`brand_name`),
  KEY `idx_category_name` (`category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统产品资料主表（保留原始数据所有字段，嵌套结构用JSON存储）';

-- ----------------------------
-- Table structure for amf_lx_shipment
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_shipment`;
CREATE TABLE `amf_lx_shipment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `woo_id` int DEFAULT NULL COMMENT 'woo系统ID',
  `zid` bigint DEFAULT NULL COMMENT '关联的zid',
  `s_wid` int DEFAULT NULL COMMENT '发货仓库ID',
  `s_wname` varchar(50) DEFAULT NULL COMMENT '发货仓库名称',
  `r_wid` int DEFAULT NULL COMMENT '收货仓库ID',
  `overseas_order_no` varchar(50) DEFAULT NULL COMMENT '海外订单号',
  `inbound_order_no` varchar(50) DEFAULT NULL COMMENT '入库订单号',
  `customer_reference_no` varchar(50) DEFAULT NULL COMMENT '客户参考号',
  `create_time` bigint DEFAULT NULL COMMENT '创建时间戳(秒)',
  `tpd_order_no` varchar(50) DEFAULT NULL COMMENT 'TPD订单号',
  `overseas_type` tinyint DEFAULT NULL COMMENT '海外类型(1:常规)',
  `r_wname` varchar(100) DEFAULT NULL COMMENT '收货仓库名称',
  `r_warehouse_type` tinyint DEFAULT NULL COMMENT '收货仓库类型(1:海外仓)',
  `is_profit` tinyint DEFAULT NULL COMMENT '是否盈利(3:未知)',
  `is_api` tinyint DEFAULT NULL COMMENT '是否API创建(0:否)',
  `logistics_id` int DEFAULT NULL COMMENT '物流ID',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注信息',
  `status` int DEFAULT NULL COMMENT '状态(50:待收货)',
  `sub_status` int DEFAULT NULL COMMENT '子状态(0:初始状态)',
  `pick_status` tinyint DEFAULT NULL COMMENT '拣货状态(1:未拣货)',
  `logistics_name` varchar(100) DEFAULT NULL COMMENT '物流渠道名称',
  `logistics_provider_id` int DEFAULT NULL COMMENT '物流商ID',
  `logistics_provider_name` varchar(100) DEFAULT NULL COMMENT '物流商名称',
  `logistics_way_id` bigint DEFAULT NULL COMMENT '物流方式ID',
  `logistics_way_name` varchar(100) DEFAULT NULL COMMENT '物流方式名称',
  `pay_status` tinyint DEFAULT NULL COMMENT '支付状态(4:已支付)',
  `share_id` varchar(20) DEFAULT NULL COMMENT '分摊ID',
  `estimated_time` varchar(20) DEFAULT NULL COMMENT '预计到达时间',
  `arrival_time` varchar(20) DEFAULT NULL COMMENT '实际到达时间',
  `rollback_remark` varchar(500) DEFAULT NULL COMMENT '回滚备注',
  `real_delivery_time` bigint DEFAULT NULL COMMENT '实际发货时间戳',
  `real_delivery_user` varchar(50) DEFAULT NULL COMMENT '实际发货人',
  `packing_type` tinyint DEFAULT NULL COMMENT '包装类型(0:默认)',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除(0:未删除)',
  `uid` bigint DEFAULT NULL COMMENT '用户ID',
  `update_user` varchar(50) DEFAULT NULL COMMENT '更新人',
  `create_user` varchar(50) DEFAULT NULL COMMENT '创建人',
  `wp_code` varchar(50) DEFAULT NULL COMMENT '仓库编码',
  `wp_id` int DEFAULT NULL COMMENT '仓库ID',
  `gmt_modified` datetime DEFAULT NULL COMMENT '修改时间',
  `gmt_create` datetime DEFAULT NULL COMMENT '创建时间',
  `order_print_count` int DEFAULT '0' COMMENT '订单打印次数',
  `file_id` varchar(100) DEFAULT NULL COMMENT '文件ID',
  `logistics_money_status` tinyint DEFAULT NULL COMMENT '物流费用状态(3:已结清)',
  `other_money_status` tinyint DEFAULT NULL COMMENT '其他费用状态(0:未结清)',
  `real_logistics_money_status` tinyint DEFAULT NULL COMMENT '实际物流费用状态',
  `real_other_money_status` tinyint DEFAULT NULL COMMENT '实际其他费用状态',
  `rollback_flag` tinyint DEFAULT '0' COMMENT '回滚标记(0:未回滚)',
  `transportation_mode` varchar(50) DEFAULT NULL COMMENT '运输方式ID',
  `transportation_name` varchar(50) DEFAULT NULL COMMENT '运输方式名称',
  `company_id` bigint DEFAULT NULL COMMENT '公司ID',
  `v_uuid` varchar(50) DEFAULT NULL COMMENT 'UUID标识',
  `is_relate_head_logistics` tinyint DEFAULT NULL COMMENT '是否关联头程物流(1:是)',
  `cost_source` tinyint DEFAULT NULL COMMENT '费用来源(1:默认)',
  `logistics_cost_source` tinyint DEFAULT NULL COMMENT '物流费用来源(1:默认)',
  `volume_parameter` int DEFAULT NULL COMMENT '体积参数',
  `is_points_behind` tinyint DEFAULT '0' COMMENT '是否滞后点(0:否)',
  `points_behind_coeffient` decimal(10,2) DEFAULT '0.00' COMMENT '滞后点系数',
  `request_status` tinyint DEFAULT '0' COMMENT '请求状态(0:初始)',
  `request_lock_time` bigint DEFAULT '0' COMMENT '请求锁定时间戳',
  `packing_task_sn` varchar(50) DEFAULT NULL COMMENT '包装任务编号',
  `awd_sid` int DEFAULT '0' COMMENT 'AWD sid',
  `awd_shipment_id` varchar(50) DEFAULT NULL COMMENT 'AWD shipment ID',
  `is_packing` tinyint(1) DEFAULT '0' COMMENT '是否包装中(0:否)',
  `wait_receive_num` int DEFAULT '0' COMMENT '待收货总数',
  `products` json DEFAULT NULL COMMENT '产品列表(JSON数组)',
  `is_exist_clearance` tinyint DEFAULT '0' COMMENT '是否存在清关(0:否)',
  `is_exist_declaration` tinyint DEFAULT '0' COMMENT '是否存在申报(0:否)',
  `share_name` varchar(100) DEFAULT NULL COMMENT '分摊名称',
  `status_text` varchar(50) DEFAULT NULL COMMENT '状态文本描述',
  `sub_status_text` varchar(50) DEFAULT NULL COMMENT '子状态文本描述',
  `is_specify_batch` tinyint DEFAULT '0' COMMENT '是否指定批次(0:否)',
  `ext_data` json DEFAULT NULL COMMENT '扩展数据(JSON对象)',
  `logistics` json DEFAULT NULL COMMENT '物流信息(JSON数组)',
  `is_new_head_logistics_version` tinyint DEFAULT '1' COMMENT '是否新头程物流版本(1:是)',
  `logistics_tracking_number` varchar(100) DEFAULT NULL COMMENT '物流追踪号',
  PRIMARY KEY (`id`),
  KEY `idx_woo_id` (`woo_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_overseas_order_no` (`overseas_order_no`),
  KEY `idx_gmt_create` (`gmt_create`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='LX shipment 信息表';

-- ----------------------------
-- Table structure for amf_lx_shipment_products
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_shipment_products`;
CREATE TABLE `amf_lx_shipment_products` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `shipment_id` int NOT NULL COMMENT '关联主表ID',
  `uk` varchar(100) NOT NULL COMMENT '唯一标识',
  `product_id` int NOT NULL COMMENT '产品ID',
  `seller_id` varchar(50) DEFAULT '' COMMENT '卖家ID',
  `fnsku` varchar(50) DEFAULT '' COMMENT 'FNSKU',
  `msku` varchar(50) DEFAULT '' COMMENT 'MSKU',
  `stock_num` int NOT NULL COMMENT '库存数量',
  `receive_num` int NOT NULL COMMENT '已收货数量',
  `breakeven_num` int NOT NULL COMMENT '盈亏平衡数量',
  `good_num` int NOT NULL COMMENT '良品数量',
  `sku` varchar(50) NOT NULL COMMENT 'SKU编码',
  `sku_identifier` varchar(50) DEFAULT '' COMMENT 'SKU标识符',
  `pic_url` varchar(255) DEFAULT '' COMMENT '图片URL',
  `seller_name` varchar(100) DEFAULT '' COMMENT '卖家名称',
  `country_name` varchar(50) DEFAULT '' COMMENT '国家名称',
  `product_name` varchar(255) NOT NULL COMMENT '产品名称',
  `product_title` text COMMENT '产品标题',
  `remark` text COMMENT '备注',
  `match_num` int NOT NULL COMMENT '匹配数量',
  `product_code` varchar(50) NOT NULL COMMENT '产品编码',
  `twp_name` varchar(255) NOT NULL COMMENT '产品名称',
  `twp_id` int NOT NULL COMMENT '产品ID',
  `is_relate_aux` tinyint NOT NULL COMMENT '是否关联辅助产品',
  `is_combo` tinyint NOT NULL COMMENT '是否组合产品',
  `wait_receive_num` int NOT NULL COMMENT '待收货数量',
  PRIMARY KEY (`id`),
  KEY `idx_shipment_id` (`shipment_id`),
  KEY `idx_sku` (`sku`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统海外仓备货单产品子表';

-- ----------------------------
-- Table structure for amf_lx_shop
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_shop`;
CREATE TABLE `amf_lx_shop` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `store_id` varchar(50) NOT NULL COMMENT '店铺ID',
  `s_id` int NOT NULL COMMENT '店铺编号',
  `platform_code` varchar(20) NOT NULL COMMENT '平台编码',
  `site_code` varchar(20) DEFAULT '' COMMENT '站点编码',
  `status` tinyint NOT NULL COMMENT '状态（1表示启用）',
  `name` varchar(100) NOT NULL COMMENT '店铺名称',
  `seller_name` varchar(50) NOT NULL COMMENT '卖家名称',
  `is_sync` tinyint NOT NULL COMMENT '是否同步（1表示同步）',
  `country_code` varchar(10) NOT NULL COMMENT '国家编码',
  `currency` varchar(10) NOT NULL COMMENT '货币单位',
  `rate` decimal(10,2) NOT NULL COMMENT '汇率',
  `platform_name` varchar(50) NOT NULL COMMENT '平台名称',
  `site_name_cn` varchar(50) DEFAULT '' COMMENT '站点中文名称',
  `region` varchar(10) DEFAULT '' COMMENT '地区',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_store_id` (`store_id`) COMMENT '店铺ID唯一索引'
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领星系统店铺资料表';

-- ----------------------------
-- Table structure for amf_lx_warehouse_stock
-- ----------------------------
DROP TABLE IF EXISTS `amf_lx_warehouse_stock`;
CREATE TABLE `amf_lx_warehouse_stock` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `wid` int NOT NULL COMMENT '仓库ID',
  `product_id` int NOT NULL COMMENT '产品ID',
  `sku` varchar(50) NOT NULL COMMENT '仓库SKU编码',
  `seller_id` varchar(20) NOT NULL COMMENT '卖家ID',
  `fnsku` varchar(50) DEFAULT NULL COMMENT 'FN SKU编码',
  `product_total` int NOT NULL COMMENT '产品总数量',
  `product_valid_num` int NOT NULL COMMENT '有效库存数量',
  `product_bad_num` int NOT NULL COMMENT '不良品数量',
  `product_qc_num` int NOT NULL COMMENT '质检中数量',
  `product_lock_num` int NOT NULL COMMENT '锁定库存数量',
  `good_lock_num` int NOT NULL COMMENT '良品锁定数量',
  `bad_lock_num` int NOT NULL COMMENT '不良品锁定数量',
  `stock_cost_total` decimal(10,2) NOT NULL COMMENT '库存总成本',
  `quantity_receive` varchar(10) NOT NULL COMMENT '待接收数量',
  `stock_cost` decimal(10,4) NOT NULL COMMENT '单位库存成本',
  `product_onway` int NOT NULL COMMENT '在途数量',
  `transit_head_cost` decimal(10,2) NOT NULL COMMENT '在途头程成本',
  `average_age` int NOT NULL COMMENT '平均库龄（天）',
  `third_inventory` json DEFAULT NULL COMMENT '第三方库存数据：包含sellable/reserved/onway/pending等字段',
  `third_box_inventory` json DEFAULT NULL COMMENT '第三方箱规库存数据：包含sellable/reserved/onway/pending等字段',
  `stock_age_list` json DEFAULT NULL COMMENT '库存年龄分布：0-30天/31-90天/91-180天/180+天数量',
  `available_inventory_box_qty` varchar(10) NOT NULL COMMENT '可用箱规库存数量',
  `purchase_price` decimal(10,4) NOT NULL COMMENT '采购单价',
  `price` decimal(10,4) NOT NULL COMMENT '售价',
  `head_stock_price` decimal(10,4) NOT NULL COMMENT '头程库存单价',
  `stock_price` decimal(10,4) NOT NULL COMMENT '库存单价',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=89 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='LX仓库库存表';

-- ----------------------------
-- Table structure for amf_onhand_stock
-- ----------------------------
DROP TABLE IF EXISTS `amf_onhand_stock`;
CREATE TABLE `amf_onhand_stock` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'SKU明细主键ID',
  `warehouse_sku` varchar(64) NOT NULL COMMENT '仓库SKU编码（如AP-XZSJ-5C-R）',
  `stock_qty` int NOT NULL COMMENT '在仓数量',
  `factory_qty` int NOT NULL COMMENT '在制数量',
  `create_time` datetime DEFAULT NULL COMMENT '明细创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '明细更新时间',
  `isdel` tinyint DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇系统备货发货-SKU明细子表';

-- ----------------------------
-- Table structure for amf_region
-- ----------------------------
DROP TABLE IF EXISTS `amf_region`;
CREATE TABLE `amf_region` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `region` varchar(32) NOT NULL COMMENT '片区（美东/美西/美中/美南）',
  `sort` tinyint NOT NULL DEFAULT '0' COMMENT '同片区内排序值（便于展示）',
  `country` varchar(32) DEFAULT NULL,
  `shipdays` int DEFAULT '0' COMMENT '船运物流到货天数',
  PRIMARY KEY (`id`),
  KEY `idx_region` (`region`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='美国片区-州代码-州名称映射表（海外仓规划专用）';

-- ----------------------------
-- Table structure for amf_spu_rank
-- ----------------------------
DROP TABLE IF EXISTS `amf_spu_rank`;
CREATE TABLE `amf_spu_rank` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `create_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `isdel` tinyint DEFAULT '0',
  `spu` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'SPU编码（如XZSJ-5C红色）',
  `spurank` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '',
  `product_name` varchar(255) DEFAULT NULL COMMENT '商品名称',
  `region` varchar(64) DEFAULT NULL COMMENT '区域',
  `whregion` varchar(64) DEFAULT NULL COMMENT '仓库区域',
  `warehouse_sku` varchar(666) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓库SKU',
  `cnt` int DEFAULT NULL COMMENT '订单份数',
  `qty` int DEFAULT NULL COMMENT '总销量',
  `14qty` int DEFAULT NULL COMMENT '14天销量',
  `7qty` int DEFAULT NULL COMMENT '7天销量',
  `qty1day` decimal(10,2) DEFAULT NULL COMMENT '日均销量',
  `orderdays` int DEFAULT NULL COMMENT '订单天数',
  `abqty` int DEFAULT NULL COMMENT '跨区销量',
  `abregions` varchar(255) DEFAULT NULL COMMENT '跨区域',
  `sumqty` int DEFAULT NULL COMMENT '累计总销量',
  `rumrate` decimal(10,4) DEFAULT NULL COMMENT '累计占比',
  `spucnt` int DEFAULT NULL COMMENT 'SPU个数',
  `qtym` int DEFAULT NULL COMMENT '多平台销量',
  `14qtym` int DEFAULT NULL COMMENT '多平台14天销量',
  `7qtym` int DEFAULT NULL COMMENT '多平台7天销量',
  `qty1daym` decimal(10,2) DEFAULT NULL COMMENT '多平台日均销量',
  `qtya` int DEFAULT NULL COMMENT 'FBA销量',
  `14qtya` int DEFAULT NULL COMMENT 'FBA14天销量',
  `7qtya` int DEFAULT NULL COMMENT 'FBA7天销量',
  `qty1daya` decimal(10,2) DEFAULT NULL COMMENT 'FBA日均销量',
  `qtyo` int DEFAULT NULL COMMENT '欧洲销量',
  `14qtyo` int DEFAULT NULL COMMENT '欧洲14天销量',
  `7qtyo` int DEFAULT NULL COMMENT '欧洲7天销量',
  `qty1dayo` decimal(10,2) DEFAULT NULL COMMENT '欧洲日均销量',
  `qtyc` int DEFAULT NULL COMMENT 'CG销量',
  `14qtyc` int DEFAULT NULL COMMENT 'CG14天销量',
  `7qtyc` int DEFAULT NULL COMMENT 'CG7天销量',
  `qty1dayc` decimal(10,2) DEFAULT NULL COMMENT 'CG日均销量',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18650 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇系统备货发货-SKU明细子表';

-- ----------------------------
-- Table structure for amf_spu_sku
-- ----------------------------
DROP TABLE IF EXISTS `amf_spu_sku`;
CREATE TABLE `amf_spu_sku` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'SKU明细主键ID',
  `warehouse_sku` varchar(64) NOT NULL COMMENT '仓库SKU编码（如AP-XZSJ-5C-R）',
  `stock_qty` int DEFAULT NULL COMMENT '在仓数量',
  `factory_qty` int DEFAULT NULL COMMENT '在制数量',
  `create_time` datetime DEFAULT NULL COMMENT '明细创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '明细更新时间',
  `isdel` tinyint DEFAULT '0',
  `spu` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'SPU编码（如XZSJ-5C红色）',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=228 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鲸汇系统备货发货-SKU明细子表';

-- ----------------------------
-- Table structure for amf_state_region
-- ----------------------------
DROP TABLE IF EXISTS `amf_state_region`;
CREATE TABLE `amf_state_region` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `region` varchar(32) NOT NULL COMMENT '片区（美东/美西/美中/美南）',
  `state_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '州代码（2位缩写）',
  `state_name` varchar(64) NOT NULL COMMENT '州名称（英文全称）',
  `state_name_cn` varchar(64) DEFAULT '' COMMENT '州名称（中文翻译，可选）',
  `sort` tinyint NOT NULL DEFAULT '0' COMMENT '同片区内排序值（便于展示）',
  `country` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_state_code` (`state_code`),
  KEY `idx_region` (`region`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='美国片区-州代码-州名称映射表（海外仓规划专用）';

-- ----------------------------
-- Table structure for amf_warehouse_region
-- ----------------------------
DROP TABLE IF EXISTS `amf_warehouse_region`;
CREATE TABLE `amf_warehouse_region` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `region` varchar(32) NOT NULL COMMENT '片区（美东/美西/美中/美南）',
  `warehouse_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '仓库代码',
  `sort` tinyint NOT NULL DEFAULT '0' COMMENT '同片区内排序值（便于展示）',
  `country` varchar(32) DEFAULT NULL,
  `shipdays` int DEFAULT '0' COMMENT '船运物流到货天数',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_state_code` (`warehouse_code`),
  KEY `idx_region` (`region`)
) ENGINE=InnoDB AUTO_INCREMENT=89 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='美国片区-州代码-州名称映射表（海外仓规划专用）';

-- ----------------------------
-- Table structure for api_request_record
-- ----------------------------
DROP TABLE IF EXISTS `api_request_record`;
CREATE TABLE `api_request_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'PLATFORM：平台请求；SOURCE：来源回调  PENDING：处理中',
  `business_id` bigint NOT NULL COMMENT '业务id',
  `get_param` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'get请求参数',
  `post_param` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'post请求参数',
  `result` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '请求结果',
  `fail_reason` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '失败原因',
  `retry` int DEFAULT NULL COMMENT '重试次数',
  `next_retry_at` datetime DEFAULT NULL COMMENT '下次重试时间',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `u_idx_business_id_source_callback_config_id` (`business_id`,`shop_id`) USING BTREE,
  KEY `idx_shop_id_next_retry_at` (`shop_id`,`next_retry_at`,`type`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5123443434123411342 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='api推送记录';

-- ----------------------------
-- Table structure for api_request_record_backup
-- ----------------------------
DROP TABLE IF EXISTS `api_request_record_backup`;
CREATE TABLE `api_request_record_backup` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint NOT NULL,
  `type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'PLATFORM：平台请求；SOURCE：来源回调',
  `business_id` bigint NOT NULL COMMENT '业务id',
  `get_param` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `post_param` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `result` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `fail_reason` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `retry` int DEFAULT NULL,
  `next_retry_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shop_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shop_host` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_shop_id` (`shop_id`) USING BTREE,
  KEY `index_next_retry_at` (`next_retry_at`) USING BTREE,
  KEY `u_idx_business_id_source_callback_config_id` (`business_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1368 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='api推送备份';

-- ----------------------------
-- Table structure for commodity_sample_garment
-- ----------------------------
DROP TABLE IF EXISTS `commodity_sample_garment`;
CREATE TABLE `commodity_sample_garment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `pms_commodity_id` bigint NOT NULL COMMENT '商品ID',
  `sample_garment_id` bigint NOT NULL COMMENT '款式ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品款式中间表';

-- ----------------------------
-- Table structure for cos_amf_goods_skc
-- ----------------------------
DROP TABLE IF EXISTS `cos_amf_goods_skc`;
CREATE TABLE `cos_amf_goods_skc` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `spu_id` bigint DEFAULT NULL,
  `platform_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台SKC编码',
  `supplier_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商SKC编码',
  `color` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `sync_date` datetime DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='帮采商品skc数据';

-- ----------------------------
-- Table structure for cos_amf_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `cos_amf_goods_sku`;
CREATE TABLE `cos_amf_goods_sku` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `spu_id` bigint DEFAULT NULL COMMENT 'SPU ID',
  `skc_id` bigint DEFAULT NULL COMMENT 'SKC ID',
  `sku_code` varchar(128) DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku名称',
  `platform_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台SKU编码',
  `supplier_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商SKU编码',
  `stl_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统款号',
  `sale_price` decimal(10,2) DEFAULT NULL COMMENT '销售价格',
  `color_size` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色尺码',
  `on_sale` int DEFAULT NULL COMMENT '上架状态：[1:是、0:否]',
  `onsale_time` datetime DEFAULT NULL COMMENT '上架时间',
  `sync_date` datetime DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=147454 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='帮采商品sku数据';

-- ----------------------------
-- Table structure for cos_amf_goods_spu
-- ----------------------------
DROP TABLE IF EXISTS `cos_amf_goods_spu`;
CREATE TABLE `cos_amf_goods_spu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `supplier_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供方货号',
  `platform_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台SPU编码',
  `spu_code` varchar(255) DEFAULT NULL COMMENT 'spu编码',
  `spu_name` varchar(255) DEFAULT NULL COMMENT '商品名称',
  `file_url` varchar(255) DEFAULT NULL COMMENT '图片地址',
  `onsale_status` int DEFAULT NULL COMMENT '商城上架状态',
  `sync_date` datetime DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`),
  KEY `spu_code_index` (`platform_spu_code`) USING BTREE COMMENT 'spu编码索引'
) ENGINE=InnoDB AUTO_INCREMENT=16384 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='帮采商品spu数据';

-- ----------------------------
-- Table structure for cos_combine_goods
-- ----------------------------
DROP TABLE IF EXISTS `cos_combine_goods`;
CREATE TABLE `cos_combine_goods` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `group_code` varchar(64) DEFAULT NULL COMMENT '组合商品编码',
  `group_tag` varchar(255) DEFAULT NULL COMMENT '组合装标签',
  `gb_code` varchar(64) DEFAULT NULL COMMENT '国标码',
  `style_code` varchar(64) DEFAULT NULL COMMENT '款式编码',
  `group_name` varchar(255) DEFAULT NULL COMMENT '组合名称',
  `short_name` varchar(255) DEFAULT NULL COMMENT '商品简称',
  `virtual_cate` varchar(255) DEFAULT NULL COMMENT '虚拟分类',
  `image_url` varchar(512) DEFAULT NULL COMMENT '图片URL',
  `color_spec` varchar(255) DEFAULT NULL COMMENT '颜色规格',
  `stock_sync_disabled` tinyint DEFAULT '0' COMMENT '库存同步禁用(0启用1禁用)',
  `base_price` decimal(10,2) DEFAULT NULL COMMENT '基础售价',
  `length` float DEFAULT NULL COMMENT '长(cm)',
  `width` float DEFAULT NULL COMMENT '宽(cm)',
  `height` float DEFAULT NULL COMMENT '高(cm)',
  `volume` float DEFAULT NULL COMMENT '体积(m³)',
  `weight` float DEFAULT NULL COMMENT '重量(kg)',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `brand_code` varchar(64) DEFAULT NULL COMMENT '品牌编码',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `status` tinyint DEFAULT '1' COMMENT '状态(0下架1上架)',
  `sync_status` tinyint DEFAULT '0' COMMENT '同步状态',
  `virtual_stock` int DEFAULT '0' COMMENT '虚拟库存',
  `assembly_stock` int DEFAULT '0' COMMENT '可组装库存',
  `local_assembly_qty` int DEFAULT '0' COMMENT '本仓可组装数',
  `prepack_location` varchar(64) DEFAULT NULL COMMENT '预包仓位',
  `extra_price1` decimal(10,2) DEFAULT NULL COMMENT '附加价格1',
  `extra_price2` decimal(10,2) DEFAULT NULL COMMENT '附加价格2',
  `extra_price3` decimal(10,2) DEFAULT NULL COMMENT '附加价格3',
  `extra_price4` decimal(10,2) DEFAULT NULL COMMENT '附加价格4',
  `extra_price5` decimal(10,2) DEFAULT NULL COMMENT '附加价格5',
  `color` varchar(64) DEFAULT NULL COMMENT '颜色',
  `size_code` varchar(64) DEFAULT NULL COMMENT '尺码编码',
  `extra_attr3` varchar(255) DEFAULT NULL COMMENT '扩展属性3',
  `extra_attr4` varchar(255) DEFAULT NULL COMMENT '扩展属性4',
  `extra_attr5` varchar(255) DEFAULT NULL COMMENT '扩展属性5',
  `sku_code` varchar(64) DEFAULT NULL COMMENT 'SKU编码',
  `sku_name` varchar(255) DEFAULT NULL COMMENT 'SKU名称',
  `color_spec_detail` varchar(255) DEFAULT NULL COMMENT '颜色规格详情',
  `quantity` int DEFAULT '1' COMMENT '包含数量',
  `allocated_price` decimal(10,2) DEFAULT NULL COMMENT '分摊价格',
  PRIMARY KEY (`id`),
  KEY `idx_group_code` (`group_code`),
  KEY `idx_sku_code` (`sku_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品组合备份表';

-- ----------------------------
-- Table structure for cos_distribution_goods_skc
-- ----------------------------
DROP TABLE IF EXISTS `cos_distribution_goods_skc`;
CREATE TABLE `cos_distribution_goods_skc` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `spu_id` bigint DEFAULT NULL,
  `platform_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台SKC编码',
  `supplier_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商SKC编码',
  `color` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `sync_date` datetime DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='分销商品skc数据';

-- ----------------------------
-- Table structure for cos_distribution_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `cos_distribution_goods_sku`;
CREATE TABLE `cos_distribution_goods_sku` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `spu_id` bigint DEFAULT NULL COMMENT 'SPU ID',
  `skc_id` bigint DEFAULT NULL COMMENT 'SKC ID',
  `platform_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台SKU编码',
  `supplier_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商SKU编码',
  `system_stl_code` varchar(128) DEFAULT NULL COMMENT '系统款号',
  `sale_price` decimal(10,2) DEFAULT NULL COMMENT '销售价格',
  `color_size` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色尺码',
  `on_sale` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '上架状态：是、否',
  `onsale_time` datetime DEFAULT NULL COMMENT '上架时间',
  `sync_date` datetime DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='分销商品sku数据';

-- ----------------------------
-- Table structure for cos_distribution_goods_spu
-- ----------------------------
DROP TABLE IF EXISTS `cos_distribution_goods_spu`;
CREATE TABLE `cos_distribution_goods_spu` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `code_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供方货号',
  `platform_spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台SPU编码',
  `spu_code` varchar(255) DEFAULT NULL COMMENT 'spu编码',
  `spu_name` varchar(255) DEFAULT NULL COMMENT '商品名称',
  `file_url` varchar(255) DEFAULT NULL COMMENT '图片地址',
  `onsale_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商城上架状态',
  `sync_date` datetime DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`),
  KEY `spu_code_index` (`platform_spu_code`) USING BTREE COMMENT 'spu编码索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='分销商品spu数据';

-- ----------------------------
-- Table structure for cos_fba_stock
-- ----------------------------
DROP TABLE IF EXISTS `cos_fba_stock`;
CREATE TABLE `cos_fba_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `fba_stock_id` bigint DEFAULT NULL COMMENT 'fba库存id',
  `sku` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'Sku',
  `asin` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'asin',
  `fn_sku` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'fnSku',
  `share_key` varchar(255) DEFAULT NULL COMMENT '共享的键，用于查询时合并数据',
  `share_type` tinyint DEFAULT NULL COMMENT '共享类型，0：不共享，1：共享',
  `share_shops` varchar(128) DEFAULT NULL COMMENT '共享的国家对应的店铺ID',
  `warehouse_name` varchar(128) DEFAULT NULL COMMENT '仓库名称',
  `total_inventory` int DEFAULT '0' COMMENT '总库存',
  `available` int DEFAULT NULL COMMENT '可售',
  `inbound_shipped` int DEFAULT NULL COMMENT '在途',
  `inbound_receiving` int DEFAULT NULL COMMENT '入库中',
  `inbound_working` int DEFAULT NULL COMMENT '计划入库',
  `reserved_transfer` int DEFAULT NULL COMMENT '待调仓',
  `reserved_processing` int DEFAULT NULL COMMENT '调仓中',
  `research` int DEFAULT NULL COMMENT '调查中',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `fba_stock_id` (`fba_stock_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='FBA库存';

-- ----------------------------
-- Table structure for cos_fba_stock_regroup
-- ----------------------------
DROP TABLE IF EXISTS `cos_fba_stock_regroup`;
CREATE TABLE `cos_fba_stock_regroup` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `fba_stock_id` bigint DEFAULT NULL COMMENT 'fba库存id',
  `sku` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'Sku',
  `asin` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'asin',
  `fn_sku` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'fnSku',
  `share_key` varchar(255) DEFAULT NULL COMMENT '共享的键，用于查询时合并数据',
  `share_type` tinyint DEFAULT NULL COMMENT '共享类型，0：不共享，1：共享',
  `share_shops` varchar(128) DEFAULT NULL COMMENT '共享的国家对应的店铺ID',
  `warehouse_name` varchar(128) DEFAULT NULL COMMENT '仓库名称',
  `total_inventory` int DEFAULT '0' COMMENT '总库存',
  `available` int DEFAULT NULL COMMENT '可售',
  `inbound_shipped` int DEFAULT NULL COMMENT '在途',
  `inbound_receiving` int DEFAULT NULL COMMENT '入库中',
  `inbound_working` int DEFAULT NULL COMMENT '计划入库',
  `reserved_transfer` int DEFAULT NULL COMMENT '待调仓',
  `reserved_processing` int DEFAULT NULL COMMENT '调仓中',
  `research` int DEFAULT NULL COMMENT '调查中',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `fba_stock_id` (`fba_stock_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='FBA库存';

-- ----------------------------
-- Table structure for cos_goods_attribute
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_attribute`;
CREATE TABLE `cos_goods_attribute` (
  `id` bigint NOT NULL COMMENT '主键id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT '店铺商品id',
  `type` tinyint NOT NULL COMMENT '类型：0=shein,1=temu',
  `platform_attribute_id` bigint DEFAULT '0' COMMENT '属性名称id',
  `platform_attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性名称',
  `system_attribute_id` bigint DEFAULT NULL COMMENT '系统属性名称id',
  `system_attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统属性名称',
  `position` int NOT NULL COMMENT '排序',
  `main_attribute` tinyint NOT NULL COMMENT '主属性：0=非主属性，1=主属性',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `attribute_type` tinyint DEFAULT NULL COMMENT '属性类型：0=商品属性，1=销售属性',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk2` (`company_id`,`shop_id`,`goods_id`,`type`,`system_attribute_id`,`deleted`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`goods_id`,`type`,`platform_attribute_id`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_goods_attribute_value
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_attribute_value`;
CREATE TABLE `cos_goods_attribute_value` (
  `id` bigint NOT NULL COMMENT '主键id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT '店铺商品id',
  `type` tinyint NOT NULL COMMENT '类型：0=shein,1=temu',
  `platform_attribute_id` bigint DEFAULT NULL COMMENT '属性名称id',
  `platform_attribute_value_id` bigint DEFAULT NULL COMMENT '属性值id',
  `platform_attribute_value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值',
  `position` int NOT NULL COMMENT '排序',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `system_attribute_id` bigint DEFAULT NULL COMMENT '系统属性名称id',
  `system_attribute_value_id` bigint DEFAULT NULL COMMENT '系统属性值id',
  `system_attribute_value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统属性值',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`goods_id`,`type`,`platform_attribute_id`,`platform_attribute_value_id`,`deleted`) USING BTREE,
  UNIQUE KEY `idx_uk2` (`company_id`,`shop_id`,`goods_id`,`type`,`system_attribute_id`,`system_attribute_value_id`,`deleted`) USING BTREE,
  UNIQUE KEY `idx_uk3` (`company_id`,`shop_id`,`goods_id`,`type`,`platform_attribute_id`,`platform_attribute_value_id`,`platform_attribute_value_name`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_goods_bom
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_bom`;
CREATE TABLE `cos_goods_bom` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品sku编码',
  `stl_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式编码',
  `sku_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `color_attribute` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色规格',
  `quantity` int DEFAULT NULL COMMENT '数量',
  `autoid` int DEFAULT NULL COMMENT '聚水潭商品id',
  `ingredients_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '主料商品编码',
  `ingredients_sku_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '主料商品名称',
  `ingredients_color_attribute` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '主料商品颜色规格',
  `ingredients_price` decimal(10,2) DEFAULT NULL COMMENT '主料商品售价(元)',
  `ingredients_stl_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '主料商品款式编码',
  `auxiliary_materials_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '辅料商品编码',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uni_idx_sku_code` (`sku_code`,`ingredients_sku_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2001729272926048306 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品BOM清单';

-- ----------------------------
-- Table structure for cos_goods_draft(废弃)
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_draft(废弃)`;
CREATE TABLE `cos_goods_draft(废弃)` (
  `id` bigint NOT NULL,
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `system_category_id` bigint NOT NULL COMMENT '系统分类',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `status` tinyint NOT NULL COMMENT '商品状态：0=待编辑，1=待发布，2=发布中，3=发布失败',
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spucode',
  `platform_spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台spucode',
  `supplier_spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商spucode',
  `json_data` json DEFAULT NULL COMMENT 'json数据',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_uk` (`shop_id`,`company_id`,`system_category_id`,`spu_code`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺商品草稿表';

-- ----------------------------
-- Table structure for cos_goods_group
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_group`;
CREATE TABLE `cos_goods_group` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `group_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组合商品编码',
  `group_sku_tag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组合装商品标签',
  `group_gb_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组合装国标码',
  `group_stl_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组合款式编码',
  `group_sku_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组合商品名称',
  `group_sku_simple_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组合商品简称',
  `virtual_category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '虚拟分类',
  `file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片',
  `group_color_attribute` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组合颜色规格',
  `sync_stock_sign` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '禁止库存同步',
  `base_price` decimal(10,2) DEFAULT NULL COMMENT '基本售价',
  `length` float DEFAULT NULL COMMENT '长',
  `width` float DEFAULT NULL COMMENT '宽',
  `high` float DEFAULT NULL COMMENT '高',
  `volume` float DEFAULT NULL COMMENT '体积',
  `weight` float DEFAULT NULL COMMENT '组合重量',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '品牌',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品状态',
  `link_sync_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '链接同步状态',
  `virtual_stock` int DEFAULT NULL COMMENT '虚拟库存',
  `assemblable_stock` int DEFAULT NULL COMMENT '可组装库存',
  `position_assemblable_stock` int DEFAULT NULL COMMENT '本仓可组装数',
  `pre_packaged_space` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '预包仓位',
  `other_price1` decimal(10,2) DEFAULT NULL COMMENT '其它价格1',
  `other_price2` decimal(10,2) DEFAULT NULL COMMENT '其它价格2',
  `other_price3` decimal(10,2) DEFAULT NULL COMMENT '其它价格3',
  `other_price4` decimal(10,2) DEFAULT NULL COMMENT '其它价格4',
  `other_price5` decimal(10,2) DEFAULT NULL COMMENT '其它价格5',
  `color` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `size` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '码数',
  `other_attribute3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其它属性3',
  `other_attribute4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其它属性4',
  `other_attribute5` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其它属性5',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品编码',
  `sku_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `color_attribute` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色及规格',
  `quantity` int DEFAULT NULL COMMENT '数量',
  `selling_price` decimal(10,2) DEFAULT NULL COMMENT '应占售价',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uni_idx_company_group_sku` (`company_id`,`group_sku_code`,`sku_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2001729444137537592 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='组合商品';

-- ----------------------------
-- Table structure for cos_goods_jst_style
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_jst_style`;
CREATE TABLE `cos_goods_jst_style` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `image` varchar(255) DEFAULT NULL,
  `style_code` varchar(255) DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `base_price` varchar(255) DEFAULT NULL,
  `market_price` varchar(255) DEFAULT NULL,
  `brand` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `virtual_category` varchar(255) DEFAULT NULL,
  `supplier_name` varchar(255) DEFAULT NULL,
  `supplier_style_code` varchar(255) DEFAULT NULL,
  `weight` varchar(255) DEFAULT NULL,
  `length` varchar(255) DEFAULT NULL,
  `width` varchar(255) DEFAULT NULL,
  `height` varchar(255) DEFAULT NULL,
  `volume` varchar(255) DEFAULT NULL,
  `unit` varchar(255) DEFAULT NULL,
  `product_status` varchar(255) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `create_time` varchar(255) DEFAULT NULL,
  `update_time` varchar(255) DEFAULT NULL,
  `actual_stock` int DEFAULT NULL,
  `order_occupied` int DEFAULT NULL,
  `warehouse_pending` int DEFAULT NULL,
  `purchase_warehouse` int DEFAULT NULL,
  `return_warehouse` int DEFAULT NULL,
  `defective_warehouse` int DEFAULT NULL,
  `purchase_in_transit` int DEFAULT NULL,
  `repair_in_transit` int DEFAULT NULL,
  `transfer_in_transit` int DEFAULT NULL,
  `virtual_stock` int DEFAULT NULL,
  `yesterday_sales` int DEFAULT NULL,
  `day_before_sales` int DEFAULT NULL,
  `three_day_sales` int DEFAULT NULL,
  `seven_day_sales` int DEFAULT NULL,
  `fifteen_day_sales` int DEFAULT NULL,
  `thirty_day_sales` int DEFAULT NULL,
  `fortyfive_day_sales` int DEFAULT NULL,
  `sixty_day_sales` int DEFAULT NULL,
  `hundredtwenty_day_shipped` int DEFAULT NULL,
  `safety_category` varchar(255) DEFAULT NULL,
  `fabric_composition` varchar(255) DEFAULT NULL,
  `execution_standard` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16504 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_goods_main_data
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_main_data`;
CREATE TABLE `cos_goods_main_data` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `company_code` varchar(255) DEFAULT NULL COMMENT '企业编码',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `shop_name` varchar(255) DEFAULT NULL COMMENT '店铺名称',
  `logic_shop_id` bigint DEFAULT NULL COMMENT '逻辑店铺ID',
  `warehouse_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓库ID',
  `logic_warehouse_id` bigint DEFAULT NULL COMMENT '逻辑仓库ID',
  `channel_id` varchar(128) DEFAULT NULL COMMENT '渠道ID',
  `channel_type` int DEFAULT '4' COMMENT '渠道类型',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `category_id_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分类ID全路径',
  `category_name` varchar(255) DEFAULT NULL COMMENT '分类名称',
  `category_name_path` varchar(512) DEFAULT NULL COMMENT '分类名称全路径',
  `spu_id` bigint DEFAULT NULL COMMENT '商品spu ID',
  `spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品编码',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品图片',
  `skc_id` bigint DEFAULT NULL COMMENT '商品 skc ID',
  `skc_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品 skc编码',
  `sku_id` bigint NOT NULL COMMENT '商品 sku ID',
  `sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品 sku编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品 sku名称',
  `size` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '规格',
  `color` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `code_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货号',
  `stl_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式spu编码',
  `stl_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式sku编码',
  `supplier_skc_code` varchar(128) DEFAULT NULL COMMENT '供应商skc编码',
  `supplier_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商sku编码',
  `supplier_company_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商企业编码',
  `custom_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '自定义sku 编码',
  `group_spu_code` varchar(128) DEFAULT NULL COMMENT '组合商品spu编码',
  `group_skc_code` varchar(128) DEFAULT NULL COMMENT '组合商品skc编码',
  `group_sku_code` varchar(128) DEFAULT NULL COMMENT '组合商品sku编码',
  `group_stl_spu_code` varchar(128) DEFAULT NULL COMMENT '组合款式spu编码',
  `group_stl_sku_code` varchar(128) DEFAULT NULL COMMENT '组合款式sku编码',
  `commodity_id` bigint DEFAULT NULL COMMENT '产品 ID',
  `commodity_code` varchar(128) DEFAULT NULL COMMENT '产品编码',
  `commodity_name` varchar(255) DEFAULT NULL COMMENT '产品名称',
  `commodity_skc_id` bigint DEFAULT NULL COMMENT '产品skcId',
  `commodity_skc_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品skc编码',
  `commodity_sku_id` bigint DEFAULT NULL COMMENT '产品skuId',
  `commodity_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品sku编码',
  `commodity_match_status` int DEFAULT '0' COMMENT '产品匹配状态【0: 未匹配，1:已匹配，2:匹配失败】',
  `quantity` int DEFAULT NULL COMMENT '数量',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `retail_price` decimal(10,2) DEFAULT NULL COMMENT '零售价',
  `cost_price` decimal(10,2) DEFAULT NULL COMMENT '成本价',
  `onsale_date` datetime DEFAULT NULL COMMENT '上架销售时间',
  `onsale_status` int DEFAULT NULL COMMENT '上架销售状态',
  `sync_date` varchar(64) DEFAULT NULL COMMENT '同步时间',
  `is_delete` bigint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  `goods_level` varchar(32) DEFAULT NULL COMMENT '商品等级',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uni_idx_sku_id_stl_code` (`company_id`,`sku_id`,`stl_sku_code`,`is_delete`,`shop_id`) USING BTREE,
  KEY `spu_id_index` (`spu_id`) USING BTREE,
  KEY `skc_id_index` (`skc_id`) USING BTREE,
  KEY `company_id_index` (`company_id`) USING BTREE,
  KEY `shop_id_index` (`shop_id`) USING BTREE,
  KEY `commodity_code_index` (`commodity_code`) USING BTREE,
  KEY `commodity_skc_code_index` (`commodity_skc_code`) USING BTREE,
  KEY `commodity_sku_code_index` (`commodity_sku_code`) USING BTREE,
  KEY `channel_type_index` (`channel_type`) USING BTREE,
  KEY `commodity_id_index` (`commodity_id`) USING BTREE,
  KEY `idx_comp_sku_status_del` (`company_id`,`supplier_sku_code`,`commodity_match_status`)
) ENGINE=InnoDB AUTO_INCREMENT=1997863318613794279 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品主数据';

-- ----------------------------
-- Table structure for cos_goods_match
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_match`;
CREATE TABLE `cos_goods_match` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `goods_skc_id` bigint DEFAULT NULL COMMENT '商品skcId',
  `sku_id` bigint NOT NULL COMMENT '商品skuId',
  `type` tinyint NOT NULL COMMENT '类型：0=Shein,1=Temu,2=SellFox,3=SheinOdm',
  `local_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品skuCode',
  `local_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品skcCode',
  `local_spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品spuCode',
  `commodity_id` bigint DEFAULT NULL COMMENT '产品id',
  `commodity_skc_id` bigint DEFAULT NULL COMMENT '产品skcId',
  `commodity_sku_id` bigint DEFAULT NULL COMMENT '产品skuId',
  `status` tinyint DEFAULT NULL COMMENT '匹配状态：1=已匹配，2=未匹配，3=待创建',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `system_attribute` varchar(1024) DEFAULT NULL COMMENT '系统属性',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`goods_id`,`sku_id`,`type`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_goods_shipment
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_shipment`;
CREATE TABLE `cos_goods_shipment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '公司ID',
  `datasource_type` int DEFAULT NULL COMMENT '数据来源类型【1:月备货，2:固定周期备货，3:断货点】',
  `datasource_id` bigint DEFAULT NULL COMMENT '数据来源ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `logic_shop_id` bigint DEFAULT NULL COMMENT '逻辑店铺ID',
  `logic_warehouse_id` bigint DEFAULT NULL COMMENT '逻辑仓库ID',
  `shipment_status` int DEFAULT NULL COMMENT '发货状态',
  `shipment_date` date DEFAULT NULL COMMENT '发货日期',
  `earliest_date` date DEFAULT NULL COMMENT '最早发货日期',
  `latest_date` date DEFAULT NULL COMMENT '最晚发货日期',
  `abnormal_sign` int DEFAULT NULL COMMENT '异常标识【0:正常，1:异常】',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  `is_useful` smallint DEFAULT '1' COMMENT '是否有效【1:有效，0:无效】',
  PRIMARY KEY (`id`),
  KEY `idex_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1574398357059886473 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品发货单';

-- ----------------------------
-- Table structure for cos_goods_shipment_item
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_shipment_item`;
CREATE TABLE `cos_goods_shipment_item` (
  `id` bigint NOT NULL,
  `shipment_id` bigint DEFAULT NULL COMMENT '发货单ID',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `datasource_type` int DEFAULT NULL COMMENT '数据来源类型【1:月备货，2:固定周期备货，3:断货点】',
  `spu_id` bigint DEFAULT NULL COMMENT '商品id',
  `spu_code` varchar(255) DEFAULT NULL COMMENT '商品 code',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_code` varchar(255) DEFAULT NULL COMMENT 'sku 编码',
  `shipment_qty` int DEFAULT '0' COMMENT '发货数量',
  `received_qty` int DEFAULT '0' COMMENT '实收数量',
  `expect_qty` int DEFAULT NULL COMMENT '预期发货数量',
  `fixed_cycle_day` int DEFAULT '0' COMMENT '固定周期发货天数',
  `per_day_sale_num` double(10,2) DEFAULT NULL COMMENT '日均销售数量',
  `received_date` date DEFAULT NULL COMMENT '收货时间',
  `expect_receive_date` date DEFAULT NULL COMMENT '预计收货时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `is_delete` tinyint DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品发货单明细';

-- ----------------------------
-- Table structure for cos_goods_shop
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_shop`;
CREATE TABLE `cos_goods_shop` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片',
  `stl_file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式主图',
  `shop_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺编号',
  `shop_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺名称',
  `position_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '站点名称',
  `platform_stl_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台店铺款式编码',
  `platform_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台店铺商品编码',
  `online_stl_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '线上款式编码',
  `online_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '线上商品编码',
  `original_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原始商品编码',
  `online_spu_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '线上商品名称',
  `online_color_attribute` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '线上颜色规格',
  `shop_spu_stock` int DEFAULT NULL COMMENT '店铺库存',
  `max_selling_price` decimal(10,2) DEFAULT NULL COMMENT '售价上限',
  `min_selling_price` decimal(10,2) DEFAULT NULL COMMENT '售价下限',
  `shop_selling_price` decimal(10,2) DEFAULT NULL COMMENT '店铺售价',
  `is_onsale` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否上架',
  `link_sync_setting` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '链接同步设置',
  `system_stl_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统款式编码',
  `system_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统商品编码',
  `system_spu_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统商品名称',
  `system_color_attribute` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统颜色规格',
  `system_base_price` decimal(10,2) DEFAULT NULL COMMENT '系统基本售价',
  `system_weight` float DEFAULT NULL COMMENT '系统商品重量',
  `system_goods_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统商品备注',
  `spu_tag` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品标签',
  `virtual_category` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '虚拟分类',
  `category_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品分类',
  `online_link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '线上链接',
  `update_time` datetime DEFAULT NULL COMMENT '最新更新时间',
  `platform_create_time` datetime DEFAULT NULL COMMENT '平台商品创建时间',
  `delivery_time` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货时效',
  `pre_sale_delivery_time` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '预售发货时效',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `offline_time` datetime DEFAULT NULL COMMENT '下架时间',
  `online_gb_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '线上国标码',
  `category_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '类目ID',
  `spu_sign` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品标识',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=263859 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺商品';

-- ----------------------------
-- Table structure for cos_goods_size_library
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_size_library`;
CREATE TABLE `cos_goods_size_library` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `size_data` json DEFAULT NULL COMMENT '尺码数据',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`goods_id`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_goods_skc
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_skc`;
CREATE TABLE `cos_goods_skc` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL,
  `spu_id` bigint DEFAULT NULL,
  `skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台SKC编码',
  `skc_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台SKC名称',
  `supplier_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商SKC编码',
  `color` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `sync_date` datetime DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='帮采商品skc数据';

-- ----------------------------
-- Table structure for cos_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_sku`;
CREATE TABLE `cos_goods_sku` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `logic_shop_id` bigint DEFAULT NULL COMMENT '逻辑店铺ID',
  `logic_warehouse_id` bigint DEFAULT NULL COMMENT '逻辑仓库ID',
  `spu_id` bigint DEFAULT NULL COMMENT 'SPU ID',
  `skc_id` bigint DEFAULT NULL COMMENT 'SKC ID',
  `sku_code` varchar(128) DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku名称',
  `supplier_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商SKU编码',
  `sale_price` decimal(10,2) DEFAULT NULL COMMENT '销售价格',
  `color_size` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色尺码',
  `onsale_status` int DEFAULT NULL COMMENT '上架状态：[1:是、0:否]',
  `onsale_date` date DEFAULT NULL COMMENT '上架时间',
  `produce_days` int DEFAULT '30' COMMENT '生产周期(天)',
  `goods_level` varchar(64) DEFAULT NULL COMMENT '商品等级',
  `sync_date` datetime DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`),
  KEY `idx_spu_id` (`spu_id`) USING BTREE,
  KEY `idx_sku_code` (`sku_code`) USING BTREE,
  KEY `idex_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1574398357060043928 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='帮采商品sku数据';

-- ----------------------------
-- Table structure for cos_goods_sku_attribute
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_sku_attribute`;
CREATE TABLE `cos_goods_sku_attribute` (
  `id` bigint NOT NULL COMMENT '主键id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `goods_id` bigint NOT NULL COMMENT '店铺商品id',
  `type` tinyint NOT NULL COMMENT '类型：0=shein,1=temu',
  `sku_id` bigint NOT NULL COMMENT 'skuId',
  `platform_attribute_id` bigint DEFAULT '0' COMMENT '属性名称id',
  `platform_attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性名称',
  `position` int NOT NULL COMMENT '排序',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `system_attribute_id` bigint DEFAULT '0' COMMENT '系统属性名称id',
  `system_attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统属性名称',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`shop_id`,`company_id`,`goods_id`,`type`,`sku_id`,`platform_attribute_id`,`deleted`) USING BTREE,
  UNIQUE KEY `idx_uk2` (`shop_id`,`company_id`,`goods_id`,`type`,`sku_id`,`system_attribute_id`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_goods_sku_attribute_value
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_sku_attribute_value`;
CREATE TABLE `cos_goods_sku_attribute_value` (
  `id` bigint NOT NULL COMMENT '主键id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `goods_id` bigint NOT NULL COMMENT '店铺商品id',
  `type` tinyint NOT NULL COMMENT '类型：0=shein,1=temu',
  `sku_id` bigint NOT NULL COMMENT 'skuId',
  `platform_attribute_id` bigint DEFAULT '0' COMMENT '属性名称id',
  `platform_attribute_value_id` bigint DEFAULT '0' COMMENT '属性值id',
  `platform_attribute_value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值',
  `position` int NOT NULL COMMENT '排序',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `system_attribute_id` bigint DEFAULT '0' COMMENT '属性名称id',
  `system_attribute_value_id` bigint DEFAULT '0' COMMENT '属性值id',
  `system_attribute_value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`shop_id`,`company_id`,`goods_id`,`type`,`sku_id`,`platform_attribute_id`,`platform_attribute_value_id`,`deleted`) USING BTREE,
  UNIQUE KEY `idx_uk2` (`shop_id`,`company_id`,`goods_id`,`type`,`sku_id`,`system_attribute_id`,`system_attribute_value_id`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_goods_sku_daily_sale
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_sku_daily_sale`;
CREATE TABLE `cos_goods_sku_daily_sale` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '企业id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `goods_id` bigint DEFAULT NULL COMMENT '商品id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_code` varchar(50) DEFAULT NULL COMMENT 'sku 编码',
  `daily_sales` decimal(10,4) DEFAULT '0.0000' COMMENT '日均销量',
  `expected_daily_sales` decimal(10,4) DEFAULT '0.0000' COMMENT '预期日均销量',
  `sync_date` date NOT NULL COMMENT '数据统计截止日',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_sku_date` (`shop_id`,`sku_id`,`sku_code`,`sync_date`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品sku日均销量表';

-- ----------------------------
-- Table structure for cos_goods_sku_intransit_stock
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_sku_intransit_stock`;
CREATE TABLE `cos_goods_sku_intransit_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '企业id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `spu_id` bigint DEFAULT NULL COMMENT '商品id',
  `sku_id` bigint NOT NULL COMMENT 'sku id',
  `sku_code` varchar(50) NOT NULL COMMENT 'sku 编码',
  `external_id` varchar(64) NOT NULL COMMENT '外部集装箱/批次编号',
  `ship_qty` int DEFAULT '0' COMMENT '发货数量',
  `receive_qty` int DEFAULT '0' COMMENT '收货数量',
  `shipment_date` date NOT NULL COMMENT '发货日期',
  `shipment_status` tinyint NOT NULL COMMENT '发货单状态码（0=在途，2=完成）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道sku在途库存表';

-- ----------------------------
-- Table structure for cos_goods_sku_sale
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_sku_sale`;
CREATE TABLE `cos_goods_sku_sale` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `goods_id` bigint DEFAULT NULL COMMENT '商品id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint NOT NULL COMMENT 'sku id',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `fourteen_days_sale_num` int DEFAULT NULL COMMENT '近14天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `total_sale_volume` int DEFAULT NULL COMMENT '总销量',
  `end_date` date NOT NULL COMMENT '数据统计截止日',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_sku` (`end_date`,`sku_id`,`deleted`) USING BTREE,
  KEY `idx_end_date_goods_id` (`end_date` DESC,`goods_id` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道sku销量表';

-- ----------------------------
-- Table structure for cos_goods_sku_sale_and_stock
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_sku_sale_and_stock`;
CREATE TABLE `cos_goods_sku_sale_and_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `goods_id` bigint DEFAULT NULL COMMENT '商品id',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `intransit_stock_num` int DEFAULT NULL COMMENT '在途库存数量',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk` (`goods_id`,`sku_id`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='sku销量和库存';

-- ----------------------------
-- Table structure for cos_goods_sku_stock
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_sku_stock`;
CREATE TABLE `cos_goods_sku_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `goods_id` bigint DEFAULT NULL COMMENT '商品id',
  `sku_id` bigint NOT NULL COMMENT 'sku id',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `intransit_stock_num` int DEFAULT NULL COMMENT '在途库存数量',
  `sync_date` date NOT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_sku` (`sync_date`,`sku_id`,`deleted`) USING BTREE,
  KEY `idx_sync_date_goods_id` (`sync_date` DESC,`goods_id` DESC) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道sku库存表';

-- ----------------------------
-- Table structure for cos_goods_sku_stocking_config
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_sku_stocking_config`;
CREATE TABLE `cos_goods_sku_stocking_config` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT 'shein店铺商品id',
  `goods_skc_id` bigint DEFAULT NULL COMMENT ' skcid',
  `goods_sku_id` bigint NOT NULL COMMENT ' sku id',
  `platform_warehouse_safety_days` int DEFAULT NULL COMMENT '平台仓安全库存天数',
  `platform_warehouse_lead_time` int DEFAULT NULL COMMENT '平台仓前置时间（天数）',
  `platform_warehouse_rop` int DEFAULT NULL COMMENT '平台仓订货点',
  `platform_warehouse_stock_days` int DEFAULT NULL COMMENT '平台仓补货天数',
  `overseas_warehouse_rop` int DEFAULT NULL COMMENT '海外仓订货点',
  `overseas_warehouse_stock_days` int DEFAULT NULL COMMENT '海外仓补货天数',
  `domestic_warehouse_rop` int DEFAULT NULL COMMENT '国内仓订货点',
  `domestic_warehouse_stock_days` int DEFAULT NULL COMMENT '国内仓补货天数',
  `production_cycle` int DEFAULT NULL COMMENT '生产周期',
  `all_warehouses_rop` int DEFAULT NULL COMMENT '全仓订货点',
  `all_warehouses_rop_num` int DEFAULT NULL COMMENT '国内仓订货量',
  `all_warehouses_stock_days` int DEFAULT NULL COMMENT '全仓前置天数',
  `all_warehouses_total_stock_days` int DEFAULT NULL COMMENT '备货总天数',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uni_idx_sku` (`goods_sku_id`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='商品SKU补备货参数表';

-- ----------------------------
-- Table structure for cos_goods_spu
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_spu`;
CREATE TABLE `cos_goods_spu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '公司ID',
  `channel_type` int DEFAULT NULL COMMENT '渠道类型',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `logic_shop_id` bigint DEFAULT NULL COMMENT '逻辑店铺ID',
  `logic_warehouse_id` bigint DEFAULT NULL COMMENT '逻辑仓库ID',
  `supplier_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供方货号',
  `spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu编码',
  `spu_name` varchar(255) DEFAULT NULL COMMENT '商品名称',
  `file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片地址',
  `category_id` varchar(255) DEFAULT NULL COMMENT '分类ID',
  `category_name` varchar(255) DEFAULT NULL COMMENT '分类名称',
  `onsale_status` int DEFAULT NULL COMMENT '商城上架状态',
  `onsale_date` date DEFAULT NULL COMMENT '商品上架日期',
  `sync_date` datetime DEFAULT NULL COMMENT '同步日期',
  `currency` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '币种',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  `is_useful` smallint DEFAULT '1' COMMENT '是否有效【1:有效，0:无效】',
  PRIMARY KEY (`id`),
  KEY `idx_spu_code` (`spu_code`) USING BTREE,
  KEY `idex_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1574398357059886473 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='帮采商品spu数据';

-- ----------------------------
-- Table structure for cos_goods_spu_sale
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_spu_sale`;
CREATE TABLE `cos_goods_spu_sale` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `channel_type` int DEFAULT NULL COMMENT '渠道类型',
  `spu_id` bigint NOT NULL COMMENT '商品id',
  `spu_code` varchar(255) DEFAULT NULL COMMENT '商品编码',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `code_number` varchar(128) DEFAULT NULL COMMENT '货号',
  `file_url` varchar(255) DEFAULT NULL COMMENT '商品图册',
  `category_id` bigint DEFAULT NULL COMMENT '分类id',
  `category_name` varchar(255) DEFAULT NULL COMMENT '分类名称',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `last_month_sale_num` int DEFAULT NULL COMMENT '上个月销量',
  `total_sale_num` int DEFAULT NULL COMMENT '总销量',
  `sync_date` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '数据同步时间',
  `sale_status` int DEFAULT '1' COMMENT '销售状态',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `commodity_match_status` int DEFAULT '1' COMMENT '产品匹配状态',
  `is_delete` bigint DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_spu_id` (`sync_date` DESC,`company_id`,`spu_id`,`is_delete`) USING BTREE,
  KEY `spu_code_index` (`spu_code`) USING BTREE COMMENT 'spu 编码索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道sku销量表';

-- ----------------------------
-- Table structure for cos_goods_spu_stock
-- ----------------------------
DROP TABLE IF EXISTS `cos_goods_spu_stock`;
CREATE TABLE `cos_goods_spu_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `channel_type` int DEFAULT NULL COMMENT '渠道类型',
  `spu_id` bigint NOT NULL COMMENT '商品id',
  `spu_code` varchar(128) DEFAULT NULL COMMENT '商品编码',
  `spu_name` varchar(255) DEFAULT NULL COMMENT '商品名称',
  `code_number` varchar(128) DEFAULT NULL COMMENT '货号',
  `category_id` bigint DEFAULT NULL COMMENT '分类id',
  `category_name` varchar(128) DEFAULT NULL COMMENT '分类名称',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `intransit_stock_num` int DEFAULT NULL COMMENT '在途库存数量',
  `platform_stock_num` int DEFAULT NULL COMMENT '平台库存',
  `total_stock_num` int DEFAULT NULL COMMENT '总库存',
  `physical_inventory_stock_num` int DEFAULT NULL COMMENT '实仓库存',
  `commodity_match_status` int DEFAULT '1' COMMENT '产品匹配状态',
  `sync_date` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` bigint DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_spu_id` (`sync_date` DESC,`company_id`,`spu_id`,`is_delete`) USING BTREE,
  KEY `spu_code_index` (`spu_code`) USING BTREE COMMENT 'spu 编码索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道sku库存表';

-- ----------------------------
-- Table structure for cos_inventory_analysis
-- ----------------------------
DROP TABLE IF EXISTS `cos_inventory_analysis`;
CREATE TABLE `cos_inventory_analysis` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `goods_id` bigint DEFAULT NULL COMMENT '商品id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sales_num_list` varchar(128) DEFAULT NULL COMMENT '销量列表',
  `daily_average` int DEFAULT '0' COMMENT '加权日均销量',
  `precise_daily_average` decimal(10,4) DEFAULT NULL COMMENT '加权日均销量精确值',
  `total_stock_num` int DEFAULT '0' COMMENT '平台库存总计',
  `sale_stock_num` int DEFAULT NULL COMMENT '平台可售库存',
  `intransit_stock_num` int DEFAULT NULL COMMENT '平台在途库存',
  `safe_stock_num` int DEFAULT '0' COMMENT '安全库存',
  `total_demand_num` int DEFAULT '0' COMMENT '最大库存',
  `available_sale_days` int DEFAULT '0' COMMENT '库存可售天数',
  `health_degree` int DEFAULT '0' COMMENT '健康度: 1-请立刻备货, 2-建议备货, 3-正常',
  `stock_up_logic` varchar(64) DEFAULT NULL COMMENT '补货逻辑',
  `suggest_stock_up_num` int DEFAULT '0' COMMENT '建议补货量',
  `suggest_transport_mode` varchar(32) DEFAULT NULL COMMENT '建议运输方式',
  `adjust_stock_up_num` int DEFAULT '0' COMMENT '手工调整量',
  `actual_stock_up_num` int DEFAULT '0' COMMENT '实际补货量',
  `domestic_total_stock_num` int DEFAULT NULL COMMENT '国内仓库存总计',
  `domestic_available_sale_days` int DEFAULT NULL COMMENT '国内仓库存可售天数',
  `is_stock_up` tinyint(1) DEFAULT NULL COMMENT '是否备货',
  `stock_up_demand_num` int DEFAULT NULL COMMENT '备货需求量',
  `suggest_production_num` int DEFAULT '0' COMMENT '建议生产数量',
  `suggest_rop_num` int DEFAULT NULL COMMENT '备货点建议采购量',
  `platform_order_num` int DEFAULT NULL COMMENT '平台下单量',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` bigint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺库存分析结果表';

-- ----------------------------
-- Table structure for cos_jst_goods
-- ----------------------------
DROP TABLE IF EXISTS `cos_jst_goods`;
CREATE TABLE `cos_jst_goods` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片',
  `stl_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式编码',
  `product_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品编码',
  `product_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `product_short_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品简称',
  `color_spec` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色及规格',
  `color_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `specification` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '规格',
  `base_price` decimal(10,2) DEFAULT NULL COMMENT '基本售价',
  `market_price` decimal(10,2) DEFAULT NULL COMMENT '市场|吊牌价',
  `brand_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '品牌',
  `category_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分类',
  `virtual_category` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '虚拟分类',
  `product_tags` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品标签',
  `national_standard_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '国标码',
  `supplier_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商名称',
  `weight` float DEFAULT NULL COMMENT '重量',
  `length` float DEFAULT NULL COMMENT '长',
  `width` float DEFAULT NULL COMMENT '宽',
  `height` float DEFAULT NULL COMMENT '高',
  `volume` float DEFAULT NULL COMMENT '体积',
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位',
  `product_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品状态',
  `inventory_sync` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '库存同步',
  `remark` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `storage_capacity_min` int DEFAULT NULL COMMENT '库容下限',
  `storage_capacity_max` int DEFAULT NULL COMMENT '库容上限',
  `overflow_quantity` int DEFAULT NULL COMMENT '溢出数量',
  `standard_packing_quantity` int DEFAULT NULL COMMENT '标准装箱数量',
  `standard_packing_volume` float DEFAULT NULL COMMENT '标准装箱体积',
  `main_storage_location` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '主仓位',
  `color_extend` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色1',
  `size_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '码数',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `warehouse_stock` int DEFAULT NULL COMMENT '仓库库存数',
  `purchase_feature` varchar(125) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购特征',
  `recommended_purchase_quantity` int DEFAULT NULL COMMENT '建议采购数',
  `seven_day_sales_growth_rate` float DEFAULT NULL COMMENT '近7天销量增长率',
  `actual_inventory` int DEFAULT NULL COMMENT '实际库存数',
  `locked_inventory` int DEFAULT NULL COMMENT '库存锁定数',
  `order_occupied_quantity` int DEFAULT NULL COMMENT '订单占有数',
  `safety_stock_min` int DEFAULT NULL COMMENT '安全库存下限',
  `safety_stock_max` int DEFAULT NULL COMMENT '安全库存上限',
  `safety_stock_days_min` int DEFAULT NULL COMMENT '安全库存天数下限(交货周期)',
  `safety_stock_days_max` int DEFAULT NULL COMMENT '安全库存天数上限',
  `warehouse_pending_delivery` int DEFAULT NULL COMMENT '仓库待发数',
  `purchase_warehouse_stock` int DEFAULT NULL COMMENT '进货仓库存',
  `purchase_in_transit` int DEFAULT NULL COMMENT '采购在途数',
  `transfer_in_transit` int DEFAULT NULL COMMENT '调拨在途数',
  `virtual_inventory` int DEFAULT NULL COMMENT '虚拟库存数',
  `available_quantity` int DEFAULT NULL COMMENT '可用数',
  `public_available_quantity` int DEFAULT NULL COMMENT '公有可用数',
  `cloud_warehouse_available` int DEFAULT NULL COMMENT '运营云仓可用数',
  `inventory_update_time` datetime DEFAULT NULL COMMENT '库存更新时间',
  `cart_not_ordered` int DEFAULT NULL COMMENT '采购车未下单',
  `pending_review_purchase` int DEFAULT NULL COMMENT '待审核采购数',
  `product_attributes` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品属性',
  `out_of_stock_quantity` int DEFAULT NULL COMMENT '缺货库存数',
  `supplier_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商编号',
  `supplier_product_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商商品编码',
  `supplier_style_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商款式编码',
  `order_pending_delivery` int DEFAULT NULL COMMENT '订单待发数',
  `predicted_refund_rate` float DEFAULT NULL COMMENT '预测发货前退款率',
  `expected_arrival_during_shipping` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '计划发货日期内预计到货的采购在途数',
  `inventory_turnover_days` int DEFAULT NULL COMMENT '库存周转天数',
  `purchase_cycle_days` int DEFAULT NULL COMMENT '采购周期（天）',
  `predicted_daily_sales` int DEFAULT NULL COMMENT '预测日均销量',
  `yesterday_sales` int DEFAULT NULL COMMENT '昨天销量',
  `seven_day_sales` int DEFAULT NULL COMMENT '7天销量',
  `fifteen_day_sales` int DEFAULT NULL COMMENT '15天销量',
  `thirty_day_sales` int DEFAULT NULL COMMENT '30天销量',
  `sync_date` varchar(32) DEFAULT NULL COMMENT '同步日期',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79284 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聚水潭普通商品信息';

-- ----------------------------
-- Table structure for cos_jst_goods_group_stock
-- ----------------------------
DROP TABLE IF EXISTS `cos_jst_goods_group_stock`;
CREATE TABLE `cos_jst_goods_group_stock` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `color` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `attribute` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '规格',
  `brand` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '品牌',
  `group_stl_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组合款式编码',
  `group_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组合商品编码',
  `group_sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组合商品名称',
  `qty` int DEFAULT NULL COMMENT '数量',
  `file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片地址链接',
  `order_occupy_qty` int DEFAULT NULL COMMENT '订单占有',
  `waiting_shipment_qty` int DEFAULT NULL COMMENT '仓库待发',
  `min_safe_stock_qty` int DEFAULT NULL COMMENT '安全库存下限',
  `max_safe_stock_qty` int DEFAULT NULL COMMENT '安全库存上限',
  `min_safe_stock_days` int DEFAULT NULL COMMENT '最小安全天数',
  `max_safe_stock_days` int DEFAULT NULL COMMENT '最大安全天数',
  `purchase_in_transit_qty` int DEFAULT NULL COMMENT '采购在途数',
  `return_qty` int DEFAULT NULL COMMENT '销退仓库存',
  `inbound_qty` int DEFAULT NULL COMMENT '进货仓库存',
  `virtual_qty` int DEFAULT NULL COMMENT '虚拟库存',
  `allocate_qty` int DEFAULT NULL COMMENT '调拨在途数',
  `lock_qty` int DEFAULT NULL COMMENT '库存锁定',
  `cloud_warehouses_qty` int DEFAULT NULL COMMENT '运营云仓可用数',
  `available_qty` int DEFAULT NULL COMMENT '可用数',
  `public_available_qty` int DEFAULT NULL COMMENT '公有可用数',
  `create_time` datetime DEFAULT NULL COMMENT '添加时间',
  `sync_date` varchar(32) DEFAULT NULL COMMENT '同步日期',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11812 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聚水潭组合商品库存';

-- ----------------------------
-- Table structure for cos_jst_goods_shop
-- ----------------------------
DROP TABLE IF EXISTS `cos_jst_goods_shop`;
CREATE TABLE `cos_jst_goods_shop` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺编号',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺名称',
  `station_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '站点名称',
  `platform_stl_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台店铺款式编码',
  `file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片',
  `stl_file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式主图',
  `online_spu_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '线上商品名称',
  `online_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '线上款式编码',
  `platform_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台商品sku编码',
  `online_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '线上商品sku编码',
  `system_stl_code` varchar(128) DEFAULT NULL COMMENT '系统款号',
  `system_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统商品编码',
  `system_sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统商品名称',
  `link_sync_setting` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '链接同步设置',
  `color_size` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '线上颜色规格',
  `shop_price` decimal(10,2) DEFAULT NULL COMMENT '店铺售价',
  `shop_stock_qty` int DEFAULT NULL COMMENT '店铺库存',
  `yesterday_sale_qty` int DEFAULT NULL COMMENT '昨日销量',
  `three_days_sale_qty` int DEFAULT NULL COMMENT '近3日销量',
  `seven_days_sale_qty` int DEFAULT NULL COMMENT '近7日销量',
  `fifteen_days_sale_qty` int DEFAULT NULL COMMENT '近15日销量',
  `thirty_days_sale_qty` int DEFAULT NULL COMMENT '近30日销量',
  `thirty_day_gross_margin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '近30日毛利率',
  `fourteen_refund_rate` double DEFAULT NULL COMMENT '近14日支付退款率',
  `on_sale` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否上架',
  `pre_delivery_day` int DEFAULT NULL COMMENT '预售发货时效',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '最新更新时间',
  `onsale_time` datetime DEFAULT NULL COMMENT '平台商品创建时间',
  `offsale_time` datetime DEFAULT NULL COMMENT '下架时间',
  `sync_date` varchar(32) DEFAULT NULL COMMENT '同步时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2001734424500244497 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聚水潭商品归属店铺';

-- ----------------------------
-- Table structure for cos_jst_goods_stock
-- ----------------------------
DROP TABLE IF EXISTS `cos_jst_goods_stock`;
CREATE TABLE `cos_jst_goods_stock` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `wms_house_id` varchar(128) DEFAULT NULL COMMENT '仓库ID',
  `color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `size` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '规格',
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '品牌',
  `stl_spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式spu编码',
  `stl_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式sku编码',
  `stl_sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式sku名称',
  `qty` int DEFAULT NULL COMMENT '数量',
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片地址链接',
  `order_occupied_qty` int DEFAULT NULL COMMENT '订单占有',
  `warehouse_pending_qty` int DEFAULT NULL COMMENT '仓库待发',
  `min_safety_stock_qty` int DEFAULT NULL COMMENT '安全库存下限',
  `max_safety_stock_qty` int DEFAULT NULL COMMENT '安全库存上限',
  `min_safety_days` int DEFAULT NULL COMMENT '最小安全天数',
  `max_safety_days` int DEFAULT NULL COMMENT '最大安全天数',
  `purchase_in_transit_qty` int DEFAULT NULL COMMENT '采购在途数',
  `return_qty` int DEFAULT NULL COMMENT '销退仓库存',
  `inbound_qty` int DEFAULT NULL COMMENT '进货仓库存',
  `virtual_qty` int DEFAULT NULL COMMENT '虚拟库存',
  `allocate_qty` int DEFAULT NULL COMMENT '调拨在途数',
  `lock_qty` int DEFAULT NULL COMMENT '库存锁定',
  `cloud_warehouses_qty` int DEFAULT NULL COMMENT '运营云仓可用数',
  `available_qty` int DEFAULT NULL COMMENT '可用数',
  `public_available_qty` int DEFAULT NULL COMMENT '公有可用数',
  `create_time` datetime DEFAULT NULL COMMENT '添加时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `sync_date` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '同步日期',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2001902905099923458 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聚水潭商品库存';

-- ----------------------------
-- Table structure for cos_jst_shop
-- ----------------------------
DROP TABLE IF EXISTS `cos_jst_shop`;
CREATE TABLE `cos_jst_shop` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `shop_id` int DEFAULT NULL COMMENT '店铺编号',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺名称',
  `shop_short_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺简称',
  `platform_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台类型',
  `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '所属平台',
  `platform_shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台店铺名称',
  `auth_account` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '授权账号',
  `auth_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '授权状态',
  `auth_expire_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '授权过期时间',
  `auth_update_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '授权修改时间',
  `alipay_auth_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付宝授权状态',
  `jd_auth_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '京东授权状态',
  `distribution_enabled` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '启用分销',
  `cainiao_einvoice` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '菜鸟(青龙)电子面单',
  `shop_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺状态',
  `refund_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退款状态',
  `create_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建时间',
  `update_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新时间',
  `sort_order` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '排序',
  `group_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分组名称',
  `order_download` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单下载',
  `after_sale_download` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '售后单下载',
  `sync_delivery` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '同步发货',
  `sync_inventory` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '同步库存',
  `contact_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '联系电话',
  `shipping_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货地址',
  `create_source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建来源',
  `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '标签',
  `shop_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺网址',
  `service_market_version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '服务市场订购版本',
  `jd_reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '京东账号拒绝申请原因',
  `is_shopee_sip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否虾皮SIP',
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `return_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退货手机',
  `return_contact` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退货联系人',
  `return_postcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退货邮编',
  `return_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退货地址',
  `group_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分组id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1995558515053301761 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聚水潭店铺';

-- ----------------------------
-- Table structure for cos_jst_sku_data
-- ----------------------------
DROP TABLE IF EXISTS `cos_jst_sku_data`;
CREATE TABLE `cos_jst_sku_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `autoid` int DEFAULT NULL COMMENT '唯一id，系统自增id（若商品编码有被修改可以用此字段判断唯一）',
  `sku_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品编码',
  `i_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式编码',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `short_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品简称',
  `sale_price` decimal(20,6) DEFAULT NULL COMMENT '销售价',
  `cost_price` decimal(20,6) DEFAULT NULL COMMENT '成本价',
  `properties_value` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色规格',
  `color` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `c_id` int DEFAULT NULL COMMENT '类目id',
  `category` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分类',
  `pic_big` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '大图地址',
  `pic` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片地址',
  `enabled` int DEFAULT NULL COMMENT '是否启用，0：备用，1：启用，-1：禁用',
  `weight` decimal(20,6) DEFAULT NULL COMMENT '重量',
  `market_price` decimal(20,6) DEFAULT NULL COMMENT '市场价',
  `brand` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '品牌',
  `supplier_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商编号',
  `supplier_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商名称',
  `modified` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '修改时间',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '国标码',
  `supplier_sku_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商商品编码',
  `supplier_i_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商商品款号',
  `vc_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '虚拟分类',
  `sku_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品类型',
  `creator` int DEFAULT NULL COMMENT '创建者',
  `created` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `item_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品属性，成品，半成品，原材料，包材',
  `stock_disabled` int DEFAULT NULL COMMENT '是否禁止同步，0=启用同步，1=禁用同步，2=部分禁用',
  `unit` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位',
  `shelf_life` int DEFAULT NULL COMMENT '保质期',
  `labels` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品标签，多个标签时以逗号分隔',
  `production_licence` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '生产许可证',
  `l` decimal(20,6) DEFAULT NULL COMMENT '长',
  `w` decimal(20,6) DEFAULT NULL COMMENT '宽',
  `h` decimal(20,6) DEFAULT NULL COMMENT '高',
  `is_series_number` tinyint(1) DEFAULT NULL COMMENT '是否开启序列号',
  `other_price_1` decimal(20,6) DEFAULT NULL COMMENT '其他价格1',
  `other_price_2` decimal(20,6) DEFAULT NULL COMMENT '其他价格2',
  `other_price_3` decimal(20,6) DEFAULT NULL COMMENT '其他价格3',
  `other_price_4` decimal(20,6) DEFAULT NULL COMMENT '其他价格4',
  `other_price_5` decimal(20,6) DEFAULT NULL COMMENT '其他价格5',
  `other_price_6` decimal(20,6) DEFAULT NULL COMMENT '其他价格6',
  `other_price_7` decimal(20,6) DEFAULT NULL COMMENT '其他价格7',
  `other_price_8` decimal(20,6) DEFAULT NULL COMMENT '其他价格8',
  `other_price_9` decimal(20,6) DEFAULT NULL COMMENT '其他价格9',
  `other_price_10` decimal(20,6) DEFAULT NULL COMMENT '其他价格10',
  `other_1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其他属性1',
  `other_2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其他属性2',
  `other_3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其他属性3',
  `other_4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其他属性4',
  `other_5` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其他属性5',
  `other_6` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其他属性6',
  `other_7` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其他属性7',
  `other_8` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其他属性8',
  `other_9` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其他属性9',
  `other_10` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其他属性10',
  `stock_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '链接同步状态',
  `sku_codes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '辅助码',
  `batch_enabled` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否开启生产批次开关',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uni_idx_company_autoid` (`company_id`,`autoid`) USING BTREE,
  KEY `idx_company_sku` (`company_id`,`sku_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2001704041926758434 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聚水潭普通商品资料表';

-- ----------------------------
-- Table structure for cos_oos_monitor_daily
-- ----------------------------
DROP TABLE IF EXISTS `cos_oos_monitor_daily`;
CREATE TABLE `cos_oos_monitor_daily` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '企业id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `sku_id` bigint NOT NULL COMMENT '渠道sku id',
  `sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '渠道sku编码（冗余便于查询）',
  `commodity_id` bigint DEFAULT NULL COMMENT '产品id（国内仓SPU）',
  `monitor_date` date NOT NULL COMMENT '统计日期（以平台库存快照日期为准）',
  `platform_onhand` int NOT NULL DEFAULT '0' COMMENT '平台可售库存（cos_goods_sku_stock.sale_stock_num）',
  `daily_demand` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '加权日消耗率（件/天）',
  `doc_platform` decimal(12,2) DEFAULT NULL COMMENT '平台覆盖天数=platform_onhand/daily_demand',
  `oos_platform_date` date DEFAULT NULL COMMENT '预计断货日（仅平台库存）',
  `domestic_available_spu` int NOT NULL DEFAULT '0' COMMENT '国内仓可用库存（wms_commodity_stock.sale_stock_num）',
  `domestic_alloc_sku` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '分摊到sku的国内仓可用份额',
  `open_intransit_qty` int NOT NULL DEFAULT '0' COMMENT '直补在途未收数量=SUM(ship_qty-receive_qty) where shipment_status=0',
  `safety_days` int DEFAULT NULL COMMENT '安全库存天数S（config）',
  `lead_time_days` int DEFAULT NULL COMMENT '直补交期L（config.platform_warehouse_lead_time）',
  `production_cycle_days` int DEFAULT NULL COMMENT '生产周期P（config.production_cycle）',
  `stock_days` int DEFAULT NULL COMMENT '补货天数D（config.platform_warehouse_stock_days）',
  `rop_qty` int DEFAULT NULL COMMENT '订货点ROP（config.platform_warehouse_rop）',
  `need_transfer` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '直补最低救火量=ceil(S*demand + L*demand - platform_onhand)下限0',
  `suggest_transfer` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '建议直补量（受domestic_alloc_sku限制前）',
  `suggest_transfer_final` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '建议直补量（min(suggest_transfer, domestic_alloc_sku)）',
  `suggest_produce` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '建议生产量（方案2）',
  `risk_level` tinyint NOT NULL DEFAULT '0' COMMENT '风险等级：0正常，1安全区，2需要生产，3直补来不及，4已断货',
  `rop_trigger` tinyint NOT NULL DEFAULT '0' COMMENT '是否触发ROP：0否1是',
  `low_velocity` tinyint NOT NULL DEFAULT '0' COMMENT '低动销标记：daily_demand<2',
  `reason_json` json DEFAULT NULL COMMENT '原因/计算明细（可选）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_company_shop_sku_date` (`company_id`,`shop_id`,`sku_id`,`monitor_date`,`deleted`) USING BTREE,
  KEY `idx_company_date_risk` (`company_id`,`monitor_date`,`risk_level`) USING BTREE,
  KEY `idx_company_shop_date_risk` (`company_id`,`shop_id`,`monitor_date`,`risk_level`) USING BTREE,
  KEY `idx_company_commodity_date` (`company_id`,`commodity_id`,`monitor_date`) USING BTREE,
  KEY `idx_oos_platform_date` (`oos_platform_date`) USING BTREE,
  KEY `idx_shop_sku_code` (`shop_id`,`sku_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='断货点监控（日粒度，SKU维度）';

-- ----------------------------
-- Table structure for cos_oos_point
-- ----------------------------
DROP TABLE IF EXISTS `cos_oos_point`;
CREATE TABLE `cos_oos_point` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `logic_shop_id` bigint DEFAULT NULL COMMENT '逻辑店铺ID',
  `logic_warehouse_id` bigint DEFAULT NULL COMMENT '逻辑仓库ID',
  `oos_start_date` date DEFAULT NULL COMMENT '电话开始时间',
  `oos_end_date` date DEFAULT NULL COMMENT '断货结束时间',
  `oos_days` int DEFAULT NULL COMMENT '断货天数',
  `oos_type` int DEFAULT NULL COMMENT '断货类型',
  `oos_reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '断货原因',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_oos_point_daily` (`company_id`,`logic_shop_id`,`logic_warehouse_id`,`oos_start_date`,`is_delete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品断货点记录';

-- ----------------------------
-- Table structure for cos_oos_point_item
-- ----------------------------
DROP TABLE IF EXISTS `cos_oos_point_item`;
CREATE TABLE `cos_oos_point_item` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `oos_point_id` bigint DEFAULT NULL COMMENT '采购计划id',
  `spu_id` bigint DEFAULT NULL COMMENT 'spuId',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuId',
  `sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku货号',
  `daily_average` int DEFAULT '0' COMMENT '日均销量',
  `oos_num` int DEFAULT '0' COMMENT '缺货数量',
  `suggest_shipment_num` int DEFAULT '0' COMMENT '建议补货量',
  `suggest_shipment_date` date DEFAULT NULL COMMENT '建议发货时间',
  `suggest_product_num` int DEFAULT NULL COMMENT '建议生产量',
  `suggest_product_date` date DEFAULT NULL COMMENT '建议生产时间',
  `create_by` bigint DEFAULT NULL COMMENT '修改人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `fk_purchase_plan_id` (`oos_point_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='断货点明细记录';

-- ----------------------------
-- Table structure for cos_purchase_plan
-- ----------------------------
DROP TABLE IF EXISTS `cos_purchase_plan`;
CREATE TABLE `cos_purchase_plan` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `summary_sn` varchar(64) DEFAULT NULL COMMENT '合并单号',
  `code` varchar(64) DEFAULT NULL COMMENT '编号',
  `stl_spu_code` varchar(64) DEFAULT NULL COMMENT '款号',
  `source` tinyint DEFAULT '1' COMMENT '来源：1.全仓分析，2.手工创建',
  `type` tinyint DEFAULT '1' COMMENT '类型：1.成品，2.生产',
  `sku_num` int DEFAULT '0' COMMENT 'sku数量',
  `channel_type` tinyint DEFAULT NULL COMMENT '渠道类型',
  `channel_model` tinyint DEFAULT NULL COMMENT '渠道模式',
  `stl_code` varchar(32) DEFAULT NULL COMMENT '款式编码',
  `production_cycle` int DEFAULT NULL COMMENT '生产周期',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_code` (`company_id`,`code`) USING BTREE,
  KEY `idx_company_base` (`company_id`,`is_delete`,`create_time` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='备货采购计划';

-- ----------------------------
-- Table structure for cos_purchase_plan_item
-- ----------------------------
DROP TABLE IF EXISTS `cos_purchase_plan_item`;
CREATE TABLE `cos_purchase_plan_item` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `purchase_plan_id` bigint DEFAULT NULL COMMENT '采购计划id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `spu_id` bigint DEFAULT NULL COMMENT 'spuId',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuId',
  `supplier_sku_code` varchar(128) DEFAULT NULL COMMENT 'sku货号',
  `price` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '申报价格',
  `daily_average` int DEFAULT '0' COMMENT '加权日均销量',
  `precise_daily_average` decimal(10,4) DEFAULT NULL COMMENT '加权日均销量精确值',
  `adjust_daily_average` decimal(10,2) DEFAULT NULL COMMENT '日均销量调整值',
  `domestic_total_stock_num` int DEFAULT NULL COMMENT '国内仓库存合计',
  `domestic_total_stock_days` decimal(10,2) DEFAULT NULL COMMENT '国内仓成品可售天数',
  `short_num` int DEFAULT '0' COMMENT '缺货数量',
  `suggest_num` int DEFAULT '0' COMMENT '建议采购量',
  `adjust_days` int DEFAULT NULL COMMENT '调整天数',
  `actual_num` int DEFAULT '0' COMMENT '实际采购量',
  `suggest_rop_num` int DEFAULT NULL COMMENT '备货点建议采购量',
  `platform_order_num` int DEFAULT NULL COMMENT '平台下单量',
  `status` tinyint DEFAULT '1' COMMENT '供货状态：0-不正常, 1-正常',
  `pending_shipment_num` int DEFAULT NULL COMMENT 'shein odm 已下单未发货数-待发货',
  `not_shipped_num` int DEFAULT NULL COMMENT 'shein odm 已下单未发货数-未触发',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `rop_days` int DEFAULT NULL COMMENT 'rop天数',
  `lt_days` int DEFAULT NULL COMMENT '交付周期天数',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `fk_purchase_plan_id` (`purchase_plan_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='备货采购计划明细';

-- ----------------------------
-- Table structure for cos_purchase_plan_summary
-- ----------------------------
DROP TABLE IF EXISTS `cos_purchase_plan_summary`;
CREATE TABLE `cos_purchase_plan_summary` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `summary_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合并单号',
  `task_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审批单号',
  `verify_status` tinyint DEFAULT '0' COMMENT '审批状态：0.未审批，1.审批中，2:已通过，3:未通过，4:已作废',
  `verify_user_id` bigint DEFAULT NULL COMMENT '审批发起人',
  `verify_time` datetime DEFAULT NULL COMMENT '审批发起时间',
  `scm_sync_status` tinyint DEFAULT '0' COMMENT '同步scm采购单标记【0:未同步，1:已同步】',
  `scm_sync_time` datetime DEFAULT NULL COMMENT '同步scm 采购单时间',
  `scm_purchase_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '同步scm 采购单单号',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否生效【1: 有效，0:无效】',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `channel_type` tinyint DEFAULT NULL COMMENT '渠道类型',
  `channel_model` tinyint DEFAULT NULL COMMENT '渠道模式',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_code` (`company_id`,`summary_sn`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='合并采购计划';

-- ----------------------------
-- Table structure for cos_reminder_event
-- ----------------------------
DROP TABLE IF EXISTS `cos_reminder_event`;
CREATE TABLE `cos_reminder_event` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '公司ID',
  `event_type` tinyint NOT NULL COMMENT '事件类型: 1. 授权到期提醒',
  `event_title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '事件标题',
  `event_content` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '事件详细内容',
  `reminder_date` date NOT NULL COMMENT '提醒日期',
  `reminder_status` tinyint NOT NULL DEFAULT '0' COMMENT '提醒状态: {0. 未读, 1. 已读, 2. 已取消}',
  `priority` tinyint DEFAULT '1' COMMENT '优先级: {1. 高, 2. 中, 3. 低}',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_company_date` (`company_id`,`reminder_date`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='提醒事件表';

-- ----------------------------
-- Table structure for cos_sell_fox_goods
-- ----------------------------
DROP TABLE IF EXISTS `cos_sell_fox_goods`;
CREATE TABLE `cos_sell_fox_goods` (
  `id` bigint NOT NULL,
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '本地spu编码',
  `platform_spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台spucode: 平台spu id',
  `supplier_spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商spucode',
  `system_category_id` bigint DEFAULT NULL COMMENT '系统分类',
  `platform_category_id` int DEFAULT NULL COMMENT '平台分类id',
  `status` tinyint NOT NULL COMMENT '商品状态：0=待编辑，1=待发布，2=上架，3=下架',
  `sync_status` tinyint NOT NULL DEFAULT '0' COMMENT '同步状态：0=不同步，1=待同步，2=同步失败，3=已同步',
  `submit_to_channel` bit(1) NOT NULL DEFAULT b'0' COMMENT '0=未提交到channel,1=已提交到channel',
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `source_type` tinyint DEFAULT NULL COMMENT '数据来源：1=产品推品，2=反向同步，3=创建',
  `on_shelf_time` datetime DEFAULT NULL COMMENT '上架时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='赛狐商品表';

-- ----------------------------
-- Table structure for cos_sell_fox_goods_skc
-- ----------------------------
DROP TABLE IF EXISTS `cos_sell_fox_goods_skc`;
CREATE TABLE `cos_sell_fox_goods_skc` (
  `id` bigint NOT NULL,
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `skc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '本地skc编码',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='赛狐商品SKC表';

-- ----------------------------
-- Table structure for cos_sell_fox_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `cos_sell_fox_goods_sku`;
CREATE TABLE `cos_sell_fox_goods_sku` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `supplier_sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商sku编码',
  `asin` varchar(20) DEFAULT NULL COMMENT 'ASIN编码',
  `buy_box_currency` varchar(10) DEFAULT NULL COMMENT 'Buybox价格币种',
  `buy_box_winner` tinyint(1) DEFAULT NULL COMMENT 'Buybox资格',
  `commodity_id` varchar(50) DEFAULT NULL COMMENT '配对商品ID',
  `commodity_sku` varchar(100) DEFAULT NULL COMMENT '配对商品SKU',
  `currency` varchar(10) DEFAULT NULL COMMENT '币种',
  `dev_id` varchar(50) DEFAULT NULL COMMENT '业务员ID(业绩归属)',
  `dxm_publish_state` varchar(20) DEFAULT NULL COMMENT '产品状态：delete,其它状态，不为delete状态时以onlineStatus为准',
  `fba_fees` decimal(15,2) DEFAULT NULL COMMENT '亚马逊物流费',
  `fee_currency` varchar(10) DEFAULT NULL COMMENT '费用币种',
  `first_order_date` datetime DEFAULT NULL COMMENT '首单时间',
  `first_sale_date` datetime DEFAULT NULL COMMENT '开售时间',
  `fnsku` varchar(50) DEFAULT NULL COMMENT 'FNSKU编码',
  `full_cid` varchar(100) DEFAULT NULL COMMENT '本地分类全路径ID',
  `head_trip_cost` decimal(15,2) DEFAULT NULL COMMENT 'FBA头程费用',
  `is_variation` varchar(2) DEFAULT NULL COMMENT '是否变种:0单品，1组合SKU，2多品',
  `item_dimensions` varchar(200) DEFAULT NULL COMMENT '物品重量等信息(使用|分隔数值加上单位)',
  `listing_id` varchar(50) DEFAULT NULL COMMENT '商品编号',
  `listing_price` decimal(15,2) DEFAULT NULL COMMENT '挂牌价',
  `listing_pricing` decimal(15,2) DEFAULT NULL COMMENT '落地价',
  `main_image` varchar(255) DEFAULT NULL COMMENT '主图URL',
  `marketplace_id` varchar(20) DEFAULT NULL COMMENT '站点ID',
  `online_status` varchar(20) DEFAULT NULL COMMENT '在线状态:可售,不可售',
  `open_date` datetime DEFAULT NULL COMMENT '上架时间',
  `parent_asin` varchar(20) DEFAULT NULL COMMENT '父ASIN',
  `parent_sku` varchar(100) DEFAULT NULL COMMENT '父SKU',
  `per_item_fee` decimal(15,2) DEFAULT NULL COMMENT '计件费用',
  `profit_price` decimal(15,2) DEFAULT NULL COMMENT '毛利润',
  `profit_rate` decimal(5,2) DEFAULT NULL COMMENT '利润率',
  `quantity` int DEFAULT NULL COMMENT '库存/FBA可售数量',
  `rating` decimal(3,1) DEFAULT NULL COMMENT '星级评分',
  `receivable_fba_fee` decimal(15,2) DEFAULT NULL COMMENT '应收物流费，卖家没有维护等于预计物流费',
  `receivable_updatetime` datetime DEFAULT NULL COMMENT '应收物流费更新时间',
  `referral_fee` decimal(15,2) DEFAULT NULL COMMENT '销售佣金',
  `reserved_qty` int DEFAULT NULL COMMENT 'FBA预留数量',
  `ship_cost` decimal(15,2) DEFAULT NULL COMMENT 'FBM发货费用',
  `shipping_price` decimal(15,2) DEFAULT NULL COMMENT '运费',
  `standard_price` decimal(15,2) DEFAULT NULL COMMENT '标准价格',
  `standard_product_id` varchar(50) DEFAULT NULL COMMENT '对应产品ID值',
  `standard_product_type` varchar(20) DEFAULT NULL COMMENT '产品ID类型:UPC、EAN、GTIN、ISBN、asin等',
  `switch_fulfillment_to` varchar(10) DEFAULT NULL COMMENT '物流类型:MFN(商家自发货),AFN(亚马逊配送)',
  `title` varchar(500) DEFAULT NULL COMMENT '商品标题',
  `total_fee` decimal(15,2) DEFAULT NULL COMMENT '总预估费用',
  `unsellable` int DEFAULT NULL COMMENT 'FBA不可售数量',
  `variable_closing_fee` decimal(15,2) DEFAULT NULL COMMENT '交易手续费',
  `warehousing` int DEFAULT NULL COMMENT 'FBA入库数量',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `status` int DEFAULT NULL COMMENT '状态',
  `goods_id` bigint DEFAULT NULL COMMENT '商品id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `label_name` varchar(255) DEFAULT NULL COMMENT '标签名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='赛狐商品Sku表';

-- ----------------------------
-- Table structure for cos_semi_purchase_plan
-- ----------------------------
DROP TABLE IF EXISTS `cos_semi_purchase_plan`;
CREATE TABLE `cos_semi_purchase_plan` (
  `id` bigint NOT NULL,
  `purchase_plan_id` bigint DEFAULT NULL COMMENT '成品采购计划id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `code` varchar(64) DEFAULT NULL COMMENT '编号',
  `stl_code` varchar(32) DEFAULT NULL COMMENT '款号',
  `channel_type` tinyint DEFAULT NULL COMMENT '渠道类型',
  `channel_model` tinyint DEFAULT NULL COMMENT '渠道模式',
  `sku_num` int DEFAULT '0' COMMENT 'sku数量',
  `stock_up_num` int DEFAULT '0' COMMENT '备货总量',
  `is_order` tinyint DEFAULT NULL COMMENT '是否开单',
  `is_platform_order` tinyint DEFAULT NULL COMMENT '是否低于平台下单量',
  `task_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审批单号',
  `verify_status` tinyint DEFAULT '0' COMMENT '审批状态：0.未审批，1.审批中，2:已通过，3:未通过，4:已作废',
  `verify_user_id` bigint DEFAULT NULL COMMENT '审批发起人',
  `verify_time` datetime DEFAULT NULL COMMENT '审批发起时间',
  `scm_req_order_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '领猫scm订单需求编码',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_code` (`company_id`,`code`) USING BTREE,
  KEY `idx_optimized_time` (`company_id`,`is_delete`,`create_time`,`update_time` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='半成品采购计划';

-- ----------------------------
-- Table structure for cos_semi_purchase_plan_item
-- ----------------------------
DROP TABLE IF EXISTS `cos_semi_purchase_plan_item`;
CREATE TABLE `cos_semi_purchase_plan_item` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `semi_purchase_plan_id` bigint DEFAULT NULL COMMENT '半成品采购计划id',
  `stl_code` varchar(64) DEFAULT NULL COMMENT '款号',
  `sku_code` varchar(128) DEFAULT NULL COMMENT '半成品sku编码',
  `color` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `size` varchar(32) DEFAULT NULL COMMENT '尺码',
  `purchase_num` int DEFAULT '0' COMMENT '采购量',
  `actual_purchase_num` int DEFAULT NULL COMMENT '实际采购量',
  `rop_purchase_num` int DEFAULT NULL COMMENT '备货点采购量',
  `platform_order_num` int DEFAULT NULL COMMENT '平台下单量',
  `total_stock_num` int DEFAULT NULL COMMENT '半成品总库存',
  `semi_daily_avg` decimal(10,2) DEFAULT NULL COMMENT '半成品日均销量',
  `total_stock_days` decimal(10,2) DEFAULT NULL COMMENT '半成品库存可售天数',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_stl_delete` (`semi_purchase_plan_id`,`stl_code`,`is_delete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='半成品采购计划明细';

-- ----------------------------
-- Table structure for cos_shein_category_attribute
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_category_attribute`;
CREATE TABLE `cos_shein_category_attribute` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `platform_category_id` bigint NOT NULL COMMENT '平台分类id',
  `attribute_id` bigint NOT NULL COMMENT '属性id',
  `attribute_is_show` tinyint DEFAULT NULL COMMENT '1:展示;0:不展示\r\n',
  `attribute_label` tinyint DEFAULT NULL COMMENT '属性标识。1:主销售标识 0: 不是',
  `attribute_mode` tinyint DEFAULT NULL COMMENT '属性录入方式。0: 手工填写参数；1：下拉列表选择（可多选）；2：销售属性专属 （只针对销售属性，下拉列表选择）；3：下拉列表选择（单选）；4：下拉列表+手工参数/Attribute entry method. 0: fill in the parameters manually; 1: drop-down list selection (multiple selections); 2: Exclusive to sales attributes (only for sales attributes, select from the drop-down list); 3: drop-down list selection (single selection); 4: drop-down list + manual parameters\r\n',
  `attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性名称\r\n',
  `attribute_en_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性名称\r\n(英文)',
  `attribute_source` tinyint DEFAULT NULL COMMENT '属性来源。1：公有属性 2：私有属性\r\n',
  `attribute_status` tinyint DEFAULT NULL COMMENT '外围录入方式 1:外围不填; 2:外围选填; 3:外围必填\r\n',
  `attribute_type` tinyint DEFAULT NULL COMMENT '属性类型 1-销售属性，2-前台尺寸属性，3-成分属性，4-普通属性，5-颜色属性，6-后台尺寸信息\r\n',
  `business_mode` tinyint DEFAULT NULL COMMENT '运营模式 1:OBM自营; 2:简易平台; 3:传统平台; 5:简易平台双模式; 6:SPP纯平台; 7:巴西平台; 8:美国平台; 9:墨西哥平台; 10:泰国平台/Operation mode 1: OBM self-operated; 2: Simple platform; 3: Traditional platform; 5: Simple platform dual mode; 6: SPP pure platform; 7: Brazil platform; 8: US platform; 9: Mexico platform; 10: Thailand platform\r\n',
  `data_dimension` tinyint DEFAULT NULL COMMENT '数据维度 1 skc维度 2 部件维度\r\n',
  `is_sample` tinyint DEFAULT NULL COMMENT '是否横轴销售属性 1是 0否\r\n',
  `supplier_id` bigint DEFAULT NULL COMMENT '供应商id（如果值大于0，则表示是自定义属性）\r\n',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `position` int NOT NULL COMMENT '排序',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`platform_category_id`,`attribute_id`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_shein_category_attribute_value
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_category_attribute_value`;
CREATE TABLE `cos_shein_category_attribute_value` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `platform_category_id` bigint NOT NULL COMMENT '平台分类id',
  `attribute_id` bigint NOT NULL COMMENT '属性id',
  `attribute_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值信息\r\n',
  `attribute_en_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值信息\r\n(英文)',
  `attribute_value_id` bigint DEFAULT NULL COMMENT '属性值id',
  `is_show` tinyint DEFAULT NULL COMMENT '是否展示\r\n',
  `supplier_id` bigint DEFAULT NULL COMMENT '供应商id（如果值大于0，则表示是自定义属性）',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `position` int NOT NULL COMMENT '排序',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`platform_category_id`,`attribute_id`,`attribute_value_id`,`deleted`) USING BTREE,
  UNIQUE KEY `idx_uk2` (`company_id`,`shop_id`,`platform_category_id`,`attribute_id`,`attribute_value`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_shein_goods
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_goods`;
CREATE TABLE `cos_shein_goods` (
  `id` bigint NOT NULL,
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `goods_desc` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '商品描述',
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spucode',
  `platform_spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台spucode',
  `supplier_spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商spucode',
  `system_category_id` bigint DEFAULT NULL COMMENT '系统分类',
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `platform_category_id` int DEFAULT NULL COMMENT '平台分类id',
  `platform_category_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台分类名称',
  `platform_category_full_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台分类名称(包含父级名称)',
  `status` tinyint NOT NULL COMMENT '商品状态：0=待编辑，1=待发布，2=上架，3=下架',
  `sync_status` tinyint NOT NULL COMMENT '同步状态：0=不同步，1=待同步，2=同步失败，3=已同步',
  `sync_fail_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '同步失败原因',
  `submit_to_channel` bit(1) NOT NULL DEFAULT b'0' COMMENT '0=未提交到channel,1=已提交到channel',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `bundle_flag` tinyint DEFAULT NULL COMMENT '是否为多件套：0=不是多件套，1=是多件套',
  `product_type_id` bigint DEFAULT NULL COMMENT '商品类型id（shein分类树有这个字段）',
  `extend_params` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '扩展参数主要用于前端临时存放数据',
  `modify` int NOT NULL DEFAULT '0' COMMENT '第一位为1:全量更新 ,第二位为1:更新库存,第三位为1：更新价格',
  `source_type` tinyint DEFAULT NULL COMMENT '数据来源：1=产品推品，2=反向同步，3=创建',
  `on_shelf_time` datetime DEFAULT NULL COMMENT '上架时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`shop_id`,`company_id`,`spu_code`,`deleted`) USING BTREE,
  UNIQUE KEY `idx_uk2` (`shop_id`,`company_id`,`platform_spu_code`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='shein店铺商品';

-- ----------------------------
-- Table structure for cos_shein_goods_image
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_goods_image`;
CREATE TABLE `cos_shein_goods_image` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `image_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片路径',
  `type` tinyint NOT NULL COMMENT '类型：0=细节图，1=方块图，2=色块图,4=详情图,5=主图',
  `position` int NOT NULL DEFAULT '0' COMMENT '顺序(按类型下增量排序)',
  `goods_id` bigint NOT NULL COMMENT 'shein店铺商品id',
  `goods_skc_id` bigint NOT NULL COMMENT 'shein skcid',
  `image_group_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片组编码，未上新时不用传。已上新（发布成功）后必传',
  `image_item_id` bigint DEFAULT NULL COMMENT '图片唯一id,修改时需要	',
  `site_id_list` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '站点id,json字符串',
  `site_position` int DEFAULT NULL COMMENT '站点排序',
  `transformed_image_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '转换之后的图片连接',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`image_url`,`type`,`goods_id`,`goods_skc_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_shein_goods_sample_info
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_goods_sample_info`;
CREATE TABLE `cos_shein_goods_sample_info` (
  `id` bigint NOT NULL,
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `skc_id` bigint NOT NULL COMMENT 'skuid',
  `attribute` json DEFAULT NULL COMMENT '属性',
  `sample_judge_type` tinyint DEFAULT NULL COMMENT '审版类型(2:大货样衣',
  `reserve_sample_flag` tinyint DEFAULT NULL COMMENT '是否留样(1:是;2:否)，固定给2',
  `spot_flag` tinyint DEFAULT NULL COMMENT '是否现货(1:是;2:否)',
  `version_review_method` tinyint DEFAULT NULL COMMENT '审版方式：1=实物审版',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_shein_goods_skc
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_goods_skc`;
CREATE TABLE `cos_shein_goods_skc` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT 'shein店铺商品id',
  `skc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'skc编码',
  `supplier_skc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商spucode',
  `platform_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台spucode',
  `position` int NOT NULL DEFAULT '0' COMMENT '顺序',
  `platform_attribute_id` bigint DEFAULT '0' COMMENT '属性名称id',
  `platform_attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性名称',
  `platform_attribute_value_id` bigint DEFAULT '0' COMMENT '属性值id',
  `platform_attribute_value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `system_attribute_id` bigint DEFAULT '0' COMMENT '系统属性名称id',
  `system_attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统属性名称',
  `system_attribute_value_id` bigint DEFAULT '0' COMMENT '系统属性值id',
  `system_attribute_value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统属性值',
  `status` tinyint NOT NULL COMMENT '商品状态：0=待编辑，1=待发布，2=上架，3=下架',
  `sync_status` tinyint NOT NULL COMMENT '同步状态：0=不同步，1=待同步，2=同步失败，3=已同步',
  `sync_fail_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '同步失败原因',
  `on_shelf_time` datetime DEFAULT NULL COMMENT '首次上架时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`goods_id`,`skc_code`,`deleted`) USING BTREE,
  UNIQUE KEY `idx_uk2` (`company_id`,`shop_id`,`goods_id`,`platform_skc_code`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_shein_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_goods_sku`;
CREATE TABLE `cos_shein_goods_sku` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT 'shein店铺商品id',
  `goods_skc_id` bigint NOT NULL COMMENT 'shein skcid',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `supplier_sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商spucode',
  `platform_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台spucode',
  `supply_price` decimal(10,2) DEFAULT NULL COMMENT '供货价',
  `weight` int DEFAULT NULL COMMENT '重量，单位克',
  `length` int DEFAULT NULL COMMENT '长，单位厘米',
  `width` int DEFAULT NULL COMMENT '宽，单位厘米',
  `height` int DEFAULT NULL COMMENT '高，单位厘米',
  `position` int NOT NULL COMMENT '排序',
  `sync_status` tinyint DEFAULT NULL COMMENT '同步状态：0=不同步，1=待同步，2=同步失败，3=已同步',
  `status` tinyint NOT NULL COMMENT 'sku状态：0=新建，1=上架，2=下架',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `sales_status` tinyint DEFAULT NULL COMMENT '销售状态：0=正常供应，1=暂时缺货',
  `modify` int DEFAULT '0' COMMENT '第一位为1:全量更新 ,第二位为1:更新库存,第三位为1：更新价格',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`sku_code`,`deleted`) USING BTREE,
  UNIQUE KEY `idx_uk2` (`company_id`,`shop_id`,`platform_sku_code`,`deleted`) USING BTREE,
  KEY `idx_goods_id` (`goods_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_shein_goods_sku_stock
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_goods_sku_stock`;
CREATE TABLE `cos_shein_goods_sku_stock` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT 'shein店铺商品id',
  `goods_skc_id` bigint NOT NULL COMMENT 'shein skcid',
  `goods_sku_id` bigint NOT NULL COMMENT 'sku id',
  `stock` int NOT NULL COMMENT '库存',
  `warehouse_code` varbinary(255) DEFAULT NULL COMMENT '仓库编码',
  `warehouse_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓库名称',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`goods_id`,`goods_skc_id`,`goods_sku_id`,`warehouse_code`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_shein_odm_category
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_odm_category`;
CREATE TABLE `cos_shein_odm_category` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '产品分类id',
  `parent_id` int NOT NULL DEFAULT '0' COMMENT '父节点id',
  `category_id_path` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '父节点分类id路径',
  `category_path` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '父节点分类路径',
  `company_id` int NOT NULL DEFAULT '0' COMMENT '企业id',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '品类名称',
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '品类编码',
  `declare_info` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '报关信息',
  `order_num` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `use_domain` tinyint NOT NULL DEFAULT '0' COMMENT '用于哪个领域（0商品属性，1企业信息属性）',
  `commodity_type` tinyint NOT NULL DEFAULT '1' COMMENT '商品类型（1普通商品，2虚拟商品）',
  `file_url` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '文件url',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_user` int unsigned DEFAULT NULL,
  `update_user` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=125006 DEFAULT CHARSET=utf8mb3 COMMENT='产品分类表';

-- ----------------------------
-- Table structure for cos_shein_odm_goods
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_odm_goods`;
CREATE TABLE `cos_shein_odm_goods` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `code_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供方货号',
  `category_id` bigint DEFAULT NULL COMMENT '末级分类id',
  `category_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '末级分类',
  `supply_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应状态',
  `goods_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品层次',
  `goods_label` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品标签',
  `onsale_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商城上架状态',
  `spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SPU',
  `skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKC',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKU',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性集',
  `today_sale_num` int DEFAULT NULL COMMENT '今日销量',
  `seven_sale_num` int DEFAULT NULL COMMENT 'SKU近七天销量',
  `middle_east_seven_sale_num` int DEFAULT NULL COMMENT 'SKU近七天中东销量',
  `skc_seven_sale_num` int DEFAULT NULL COMMENT 'SKC近七天销量',
  `current_month_sale_num` int DEFAULT NULL COMMENT '本月销量',
  `last_month_sale_num` int DEFAULT NULL COMMENT '上月销量',
  `pending_shipment_num` int DEFAULT NULL COMMENT '已下单未发货数-待发货',
  `not_shipped_num` int DEFAULT NULL COMMENT '已下单未发货数-未触发',
  `transit_quantity` int DEFAULT NULL COMMENT '在途数量',
  `stock_quantity` int DEFAULT NULL COMMENT '库存数量',
  `available_days` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '可售天数',
  `is_warning_days` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否低于预警天数',
  `JIT_sale_days` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'JIT可售天数',
  `JIT_is_warning_days` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'JIT是否低于预警天数',
  `JIT_delivery_days` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'JIT货期',
  `JIT_stock_days` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'JIT备货天数',
  `delivery_days` float DEFAULT NULL COMMENT '货期',
  `stock_days` float DEFAULT NULL COMMENT '备货天数',
  `stock_warning_days` float DEFAULT NULL COMMENT '备货预警天数',
  `produce_rate` float DEFAULT NULL COMMENT '生产周期',
  `operate_delivery_days` float DEFAULT NULL COMMENT '运营货期',
  `forecast_daily_sale_num` int DEFAULT NULL COMMENT '预测日销',
  `merchants_actual_stock_num` int DEFAULT NULL COMMENT '商家实际库存',
  `merchants_avaliable_stock_num` int DEFAULT NULL COMMENT '商家可用库存',
  `merchants_sale_stock_num` int DEFAULT NULL COMMENT '商家可售库存',
  `fefund_waiting_stock_num` int DEFAULT NULL COMMENT '已退货待签收',
  `sellable_inventory_source` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '可售库存来源',
  `is_parting_sku_price` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否分SKU定价',
  `advice_stock_num` int DEFAULT NULL COMMENT '建议备货数量',
  `price` decimal(10,2) DEFAULT NULL,
  `onsale_date` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '上架日期',
  `removal_date` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '下架日期',
  `sixty_refund_num` int DEFAULT NULL COMMENT '60天客退量',
  `quality_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '质量等级',
  `is_multicolor_skc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否存在复色SKC',
  `advice_purchase_num` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SHEIN仓备货建议下单数',
  `is_infringes` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否侵权',
  `producing_total_num` int DEFAULT NULL COMMENT '生产中总数',
  `awaiting_storage_num` int DEFAULT NULL COMMENT '待入库总数',
  `refunding_storage_num` int DEFAULT NULL COMMENT '退货待入库数',
  `producing_storage_num` int DEFAULT NULL COMMENT '生产待入库数',
  `other_storage_num` int DEFAULT NULL COMMENT '其他待入库数',
  `stocking_standards` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备货标准',
  `next_stocking_standard_num` int DEFAULT NULL COMMENT '下一期备货标准值',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `sync_date` varchar(64) DEFAULT NULL COMMENT '同步日期',
  `sale_sync_mark` int DEFAULT '0' COMMENT '销售同步标记【0:未同步，1:已同步】',
  `stock_sync_mark` int DEFAULT '0' COMMENT '库存同步标记【0:未同步，1:已同步】',
  `commodity_sale_sync_mark` int DEFAULT '0' COMMENT '产品销量同步标记',
  `commodity_stock_sync_mark` int DEFAULT '0' COMMENT '产品库存同步标记',
  PRIMARY KEY (`id`),
  KEY `spu_code_index` (`spu_code`) USING BTREE,
  KEY `skc_code_index` (`skc_code`) USING BTREE,
  KEY `sku_code_index` (`sku_code`) USING BTREE,
  KEY `sync_date_index` (`sync_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Shein odm 商品数据';

-- ----------------------------
-- Table structure for cos_shein_odm_goods_skc
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_odm_goods_skc`;
CREATE TABLE `cos_shein_odm_goods_skc` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `code_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供方货号',
  `category_id` bigint DEFAULT NULL COMMENT '末级分类ID',
  `category_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '末级分类',
  `spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SPU',
  `skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKC',
  `is_parting_sku_price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否分SKU定价',
  `onsale_date` date DEFAULT NULL COMMENT '上架日期',
  `removal_date` date DEFAULT NULL COMMENT '下架日期',
  `is_multicolor_skc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否存在复色SKC',
  `sync_date` varchar(64) DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除',
  `onsale_status` smallint DEFAULT NULL COMMENT '销售状态',
  `supply_status` smallint DEFAULT NULL COMMENT '供应商状态',
  PRIMARY KEY (`id`),
  KEY `skc_code_index` (`skc_code`) USING BTREE COMMENT 'skc 编码索引'
) ENGINE=InnoDB AUTO_INCREMENT=1997217518083485701 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Shein odm 商品skc数据';

-- ----------------------------
-- Table structure for cos_shein_odm_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_odm_goods_sku`;
CREATE TABLE `cos_shein_odm_goods_sku` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `code_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供方货号',
  `supplier_sku_code` varchar(255) DEFAULT NULL COMMENT '供应商sku编码',
  `category_id` bigint DEFAULT NULL COMMENT '末级分类ID',
  `category_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '末级分类',
  `spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SPU',
  `skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKC',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKU',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性集',
  `price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  `onsale_date` date DEFAULT NULL COMMENT '上架日期',
  `removal_date` date DEFAULT NULL COMMENT '下架日期',
  `sync_date` varchar(64) DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除',
  `onsale_status` smallint DEFAULT NULL COMMENT '销售状态',
  `supply_status` smallint DEFAULT NULL COMMENT '供应状态',
  `goods_level` varchar(32) DEFAULT NULL COMMENT '商品等级',
  PRIMARY KEY (`id`),
  KEY `sku_code_index` (`sku_code`) USING BTREE COMMENT 'sku编码索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Shein odm 商品sku数据';

-- ----------------------------
-- Table structure for cos_shein_odm_goods_spu
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_odm_goods_spu`;
CREATE TABLE `cos_shein_odm_goods_spu` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `code_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供方货号',
  `category_id` bigint DEFAULT NULL,
  `category_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '末级分类',
  `supply_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应状态',
  `goods_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品层次',
  `goods_label` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品标签',
  `goods_match_status` int DEFAULT '0' COMMENT '商品匹配状态',
  `onsale_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商城上架状态',
  `spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SPU',
  `spu_name` varchar(255) DEFAULT NULL COMMENT '商品名称',
  `file_url` varchar(255) DEFAULT NULL COMMENT '图片地址',
  `delivery_days` float DEFAULT NULL COMMENT '货期',
  `stock_days` float DEFAULT NULL COMMENT '备货天数',
  `stock_warning_days` float DEFAULT NULL COMMENT '备货预警天数',
  `produce_rate` float DEFAULT NULL COMMENT '生产周期',
  `operate_delivery_days` float DEFAULT NULL COMMENT '运营货期',
  `sellable_inventory_source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '可售库存来源',
  `price` decimal(10,2) DEFAULT NULL COMMENT '商品单价',
  `onsale_date` date DEFAULT NULL COMMENT '上架日期',
  `removal_date` date DEFAULT NULL COMMENT '下架日期',
  `quality_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '质量等级',
  `is_multicolor_skc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否存在复色SKC',
  `is_infringes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否侵权',
  `stocking_standards` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备货标准',
  `next_stocking_standard_num` int DEFAULT NULL COMMENT '下一期备货标准值',
  `sync_date` varchar(64) DEFAULT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`),
  KEY `spu_code_index` (`spu_code`) USING BTREE COMMENT 'spu编码索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Shein odm 商品spu数据';

-- ----------------------------
-- Table structure for cos_shein_odm_main_data
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_odm_main_data`;
CREATE TABLE `cos_shein_odm_main_data` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `spu_id` bigint DEFAULT NULL COMMENT '商品ID',
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品编码',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品图片',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc ID',
  `skc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'skc编码',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku ID',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku名称',
  `size` varchar(32) DEFAULT NULL COMMENT '尺码',
  `color` varchar(32) DEFAULT NULL COMMENT '颜色',
  `code_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货号',
  `stl_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式spu编码',
  `stl_sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式sku编码',
  `supplier_sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商sku编码',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `sync_date` varchar(64) DEFAULT NULL COMMENT '同步时间',
  `sync_status` int DEFAULT '0' COMMENT '同步状态',
  PRIMARY KEY (`id`),
  KEY `spu_code_index` (`spu_code`) USING BTREE COMMENT 'spu 编码索引',
  KEY `skc_code_index` (`skc_code`) USING BTREE COMMENT 'skc编码索引',
  KEY `sku_code_index` (`sku_code`) USING BTREE COMMENT 'sku编码索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='shein odm 商品主数据';

-- ----------------------------
-- Table structure for cos_shein_odm_order
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_odm_order`;
CREATE TABLE `cos_shein_odm_order` (
  `id` bigint DEFAULT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `order_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单号',
  `JIT_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'JIT编码',
  `supplier_sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商SKU',
  `code_number` varchar(64) DEFAULT NULL COMMENT '货号',
  `order_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '下单数量',
  `order_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单类型',
  `order_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单状态',
  `order_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '下单时间',
  `delivery_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货时间',
  `skc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKC',
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SPU',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性集',
  `price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单价格',
  `current_time_consumption` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '当前耗时（小时）',
  `remaining_shipping_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '剩余发货时间（小时）',
  `is_risk` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '有无风险',
  `delivery_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '送货数量',
  `delivery_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单号',
  `genuine_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '正品数量',
  `defective_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '次品数量',
  `refund_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退单时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单备注',
  `sale_day` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '可售天数',
  `is_reconsideration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否复议单',
  `existing_stock_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '现有库存数',
  `warehouse_sku_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓库sku库存数',
  `stockup_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备货类型',
  `is_first_order` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否首单',
  `request_delivery_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '要求送达时间',
  `production_schedule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '生产进度',
  `estimated_shipping_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '估计物流时间',
  `is_first_produce` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否优先生产',
  `request_finish_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '要求完成时间',
  `finish_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '完成时间',
  `wms_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '库位',
  `export_mode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '出口模式',
  `invoice_tax_rate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开票税率',
  `tax_refund_rate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '预计退税率',
  `order_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单标签',
  `compliance_report_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合规报告状态',
  `BOM_version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'BOM版本号',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `sync_date` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '同步时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_shein_odm_virtual_wms
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_odm_virtual_wms`;
CREATE TABLE `cos_shein_odm_virtual_wms` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'skc 编码',
  `spu_code` varchar(64) DEFAULT NULL COMMENT 'spu 编码',
  `spu_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `code_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货号',
  `sale_mode` int DEFAULT NULL COMMENT '销售模式',
  `sale_modu_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '销售模式备注',
  `onsale_status` int DEFAULT NULL COMMENT '在售状态',
  `spu_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品等级',
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件地址',
  `jit_wms_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'jit 库位',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku名称',
  `supplier_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商sku编码',
  `total_stock_num` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '总库存',
  `merchants_avaliable_stock` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商家仓可用库存',
  `merchants_pre_occupy_stock` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商家仓预占库存',
  `merchants_occupy_stock` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商家仓占用库存',
  `physical_warehouse_stock` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实仓可用库存',
  `physical_warehouse_pre_stock` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实仓预占库存',
  `physical_warehouse_oaccupy_stock` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实仓占用库存',
  `physical_warehouse_inner_stock` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实仓国内库存',
  `physical_warehouse_out_stock` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实仓海外库存',
  `maintenance_method` int DEFAULT NULL COMMENT '维护方式',
  `sync_date` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '同步时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_shein_shop_site
-- ----------------------------
DROP TABLE IF EXISTS `cos_shein_shop_site`;
CREATE TABLE `cos_shein_shop_site` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `site_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '站点名称',
  `site_abbr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '站点缩写',
  `currency` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '币种',
  `store_type` tinyint DEFAULT NULL COMMENT '店铺模式：1-平台类型，2-自营类型\r\n',
  `symbol_left` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货币左侧符号\r\n',
  `symbol_right` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货币右侧符号\r\n',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`site_abbr`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺站点';

-- ----------------------------
-- Table structure for cos_shop
-- ----------------------------
DROP TABLE IF EXISTS `cos_shop`;
CREATE TABLE `cos_shop` (
  `id` bigint NOT NULL COMMENT '主键',
  `external_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `channel_type` tinyint NOT NULL COMMENT '店铺类型: {1. SHEIN, 2. TEMU, 3. AMAZON, 4. SHEIN ODM,5:Tiktok,6:分销渠道}',
  `channel_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺模式: {1-OBM全托管(供应商模式), 2-半托管模式, 3-平台模式, 4-全托管,5:SHEIN自营,6:FBA,7:FBM,8:Tiktok自营,9:Tiktok全托管,10:分销渠道}',
  `channel_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺名称',
  `company_id` bigint DEFAULT NULL COMMENT '公司id',
  `open_key_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'shein',
  `secret_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'shein使用',
  `authorized_site` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '授权站点',
  `authorized_time` datetime DEFAULT NULL COMMENT '授权时间',
  `authorized_status` tinyint DEFAULT NULL COMMENT '授权状态:{AUTHORIZED:1,已授权;AUTH_EXPIRE:2,授权失效}',
  `active` bit(1) DEFAULT NULL COMMENT '是否启用:{ENABLE:1,启用;DISABLE:0,禁用}',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL COMMENT '删除标记：0=未删除，大于0：删除',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '授权码',
  `access_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'temu',
  `expired_time` datetime DEFAULT NULL COMMENT '授权码过期时间',
  `refresh_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'temu',
  `language` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '语言',
  `currency` varchar(32) DEFAULT NULL COMMENT '币种',
  `us_order_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '美区订单token(temu)',
  `euro_order_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '欧区订单token(temu)',
  `type` varchar(255) DEFAULT NULL COMMENT '类型：test  test这个类型的店铺，不会进行推送',
  `platform_shop_id` bigint DEFAULT NULL COMMENT '平台店铺id',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`channel_type`,`channel_name`,`company_id`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_shop_channel_model
-- ----------------------------
DROP TABLE IF EXISTS `cos_shop_channel_model`;
CREATE TABLE `cos_shop_channel_model` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `channel_type_code` int NOT NULL COMMENT '渠道类型编码',
  `code` int NOT NULL COMMENT '渠道模式编码',
  `name` varchar(100) NOT NULL COMMENT '渠道模式名称',
  `is_active` tinyint DEFAULT '1' COMMENT '是否启用：0-禁用，1-启用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`channel_type_code`,`code`,`deleted`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺渠道类型模式表';

-- ----------------------------
-- Table structure for cos_shop_channel_type
-- ----------------------------
DROP TABLE IF EXISTS `cos_shop_channel_type`;
CREATE TABLE `cos_shop_channel_type` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` int NOT NULL COMMENT '渠道类型编码',
  `name` varchar(100) NOT NULL COMMENT '渠道类型名称',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `is_active` tinyint DEFAULT '1' COMMENT '是否启用：0-禁用，1-启用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`,`deleted`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺渠道类型表';

-- ----------------------------
-- Table structure for cos_shop_warehouse_relation
-- ----------------------------
DROP TABLE IF EXISTS `cos_shop_warehouse_relation`;
CREATE TABLE `cos_shop_warehouse_relation` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint NOT NULL DEFAULT '0' COMMENT '企业id，与warehouse表保持一致',
  `shop_id` bigint NOT NULL COMMENT '店铺ID，关联cos_shop.id',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID，关联wms_warehouse.id',
  `relation_type` tinyint DEFAULT '1' COMMENT '关系类型: {1-默认仓库, 2-备选仓库, 3-退货仓库, 4-发货仓库}',
  `priority` int DEFAULT '1' COMMENT '优先级，数值越小优先级越高',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除（与warehouse表保持一致）',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_shop_warehouse` (`shop_id`,`warehouse_id`,`is_delete`) USING BTREE COMMENT '同一店铺同一仓库只能有一条有效关系',
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺仓库关系表';

-- ----------------------------
-- Table structure for cos_stockup_plan
-- ----------------------------
DROP TABLE IF EXISTS `cos_stockup_plan`;
CREATE TABLE `cos_stockup_plan` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL,
  `logic_shop_id` bigint DEFAULT NULL COMMENT '逻辑区域店铺ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `stockup_type` int DEFAULT NULL COMMENT '备货计划类型【1:月度备货，2:固定周期补货，3:断货点监控补货】',
  `stockup_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备货计划编码',
  `stockup_status` int DEFAULT NULL COMMENT '备货单类型【0:未确认，1:已确认】',
  `stockup_num` int DEFAULT NULL COMMENT '备货数量',
  `stockup_date` date DEFAULT NULL COMMENT '备货时间',
  `stockup_week` int DEFAULT NULL COMMENT '备货周',
  `stockup_cycle` int DEFAULT NULL COMMENT '备货周期（天）',
  `stockup_month` varchar(255) DEFAULT NULL COMMENT '备货归属月份',
  `safe_stock_days` int DEFAULT NULL COMMENT '安全库存天数',
  `shipping_days` int DEFAULT NULL COMMENT '海运物流时间',
  `daily_avg` decimal(10,2) DEFAULT NULL COMMENT '日均销量',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品spu备货计划';

-- ----------------------------
-- Table structure for cos_stockup_plan_item
-- ----------------------------
DROP TABLE IF EXISTS `cos_stockup_plan_item`;
CREATE TABLE `cos_stockup_plan_item` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL,
  `stockup_id` bigint DEFAULT NULL COMMENT '备货计划ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `spu_id` bigint DEFAULT NULL,
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台SPU编码',
  `sku_id` bigint DEFAULT NULL,
  `sku_code` varchar(255) DEFAULT NULL,
  `platform_stock_num` int DEFAULT NULL COMMENT '海外仓库存',
  `warehosue_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓库编码',
  `warehouse_type` int DEFAULT NULL COMMENT '仓库类型【1:美西、2:美中、3:美南、4:美东】',
  `shipping_days` int DEFAULT NULL COMMENT '物流时效',
  `safety_stock_days` int DEFAULT NULL COMMENT '安全库存天数',
  `produce_days` int DEFAULT NULL COMMENT '生产周期',
  `stock_rate` int DEFAULT NULL COMMENT '备货频次',
  `stock_rate_day` int DEFAULT NULL COMMENT '备货周期天数',
  `daily_sale_num` float DEFAULT NULL COMMENT '日均销量',
  `stock_weighting_rate` float DEFAULT NULL COMMENT '加权库存分配比例',
  `stock_weighting_num` int DEFAULT NULL COMMENT 'spu 加权国内仓库存',
  `need_stockup` int DEFAULT NULL COMMENT '是否需要备货【0: 否、1: 是、2:不确定】',
  `suggest_stockup_num` int DEFAULT NULL COMMENT '建议备货数量',
  `actual_stockup_num` int DEFAULT NULL COMMENT '实际备货数量',
  `stockup_date` date DEFAULT NULL COMMENT '下次备货时间点',
  `produce_date` date DEFAULT NULL COMMENT '最近生产时间点',
  `suggest_produce_num` int DEFAULT NULL COMMENT '建议生产数量',
  `actual_produce_num` int DEFAULT NULL COMMENT '实际生产数量',
  `need_product` int DEFAULT NULL COMMENT '是否需要生产【0: 否、1: 是、2:不确定】',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `is_delete` smallint DEFAULT '0' COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`),
  KEY `spu_code_index` (`spu_code`) USING BTREE COMMENT 'spu编码索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品spu备货计划明细';

-- ----------------------------
-- Table structure for cos_temu_category_attribute
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_category_attribute`;
CREATE TABLE `cos_temu_category_attribute` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `platform_category_id` bigint NOT NULL COMMENT '平台分类id',
  `attribute_id` bigint NOT NULL COMMENT '属性id(对应temu pid)',
  `ref_pid` bigint DEFAULT NULL COMMENT '引用属性id\n',
  `attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性名称(对应temu  name)',
  `attribute_en_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性名称\r\n(英文)',
  `parent_spec_id` bigint DEFAULT NULL COMMENT '规格id\n ',
  `number_input_title` varchar(64) DEFAULT NULL COMMENT '数值录入Title\n        - ',
  `max_value` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '输入最大值：文本类型代表文本最长长度、 数值类型代表数字最大值、时间类型代表时间最大值',
  `value_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值单位',
  `choose_max_num` int DEFAULT NULL COMMENT '最大可勾选数目',
  `template_pid` bigint DEFAULT NULL COMMENT '模板属性id',
  `required` tinyint DEFAULT NULL COMMENT '属性是否必填:1=必填，0=不必填',
  `input_max_num` int DEFAULT NULL COMMENT '最大可输入数目,为0时代表不可输入',
  `value_precision` int DEFAULT NULL COMMENT '小数点允许最大精度,为0时代表不允许输入小数',
  `property_value_type` int DEFAULT NULL COMMENT '属性值类型',
  `min_value` varchar(64) DEFAULT NULL COMMENT '输入最小值\n ',
  `feature` int DEFAULT NULL COMMENT '属性特性\n: 0=商品属性，1=颜色，2=尺码',
  `control_type` int DEFAULT NULL COMMENT '控件类型',
  `value_rule` int DEFAULT NULL COMMENT '\n数值规则：SUM_OF_VALUES_IS_100(1, "数值之和等于100")',
  `sale` tinyint DEFAULT NULL COMMENT '是否销售属性：1=是销售属性,0=不是销售属性',
  `parent_template_pid` bigint DEFAULT NULL COMMENT '模板父属性ID\n        - ',
  `main_sale` tinyint DEFAULT NULL COMMENT '是否为主销售属性: 1=主 ，2=非主',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `position` int NOT NULL COMMENT '排序',
  `show_condition` json DEFAULT NULL COMMENT '属性展示条件',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`platform_category_id`,`attribute_id`,`ref_pid`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_temu_category_attribute_limit
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_category_attribute_limit`;
CREATE TABLE `cos_temu_category_attribute_limit` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `platform_category_id` bigint NOT NULL COMMENT '平台分类id',
  `input_max_spec_num` int DEFAULT NULL COMMENT '模板允许的最大的自定义规格数量\n    - ',
  `choose_all_qualify_spec` tinyint DEFAULT NULL COMMENT '限定规格是否必须全选\n ,1=全选，0=不用全选',
  `single_spec_value_num` int DEFAULT NULL COMMENT '单个自定义规格值上限\n ',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`platform_category_id`,`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_temu_category_attribute_value
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_category_attribute_value`;
CREATE TABLE `cos_temu_category_attribute_value` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `platform_category_id` bigint NOT NULL COMMENT '平台分类id',
  `attribute_id` bigint NOT NULL COMMENT '属性id',
  `attribute_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值信息(temu value)',
  `attribute_en_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值信息\r\n(英文)',
  `attribute_value_id` bigint DEFAULT NULL COMMENT '属性值id(temu vid)',
  `spec_id` bigint DEFAULT NULL COMMENT '规格id',
  `extend_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '\n属性组扩展信息',
  `group` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值组',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `position` int NOT NULL COMMENT '排序',
  `source` tinyint DEFAULT NULL COMMENT '数据来源：1=从平台同步回来，2=自定义',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`platform_category_id`,`attribute_id`,`attribute_value_id`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_temu_fully_goods
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_fully_goods`;
CREATE TABLE `cos_temu_fully_goods` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺唯一标识',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺名称',
  `spu_id` bigint DEFAULT NULL COMMENT 'spu id',
  `spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SPU编号',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKC编码',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKU ID',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品全称',
  `supplier_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKC货号',
  `supplier_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKU货号',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品图片链接',
  `image_audit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片审核状态',
  `inventory_status` varchar(255) DEFAULT NULL COMMENT '备货状态',
  `review_count` int DEFAULT NULL COMMENT '累计评论数',
  `rating` decimal(3,1) DEFAULT NULL COMMENT '商品评分(0-5分)',
  `recommend_replenish` varchar(8) DEFAULT NULL COMMENT '是否建议补货(Y/N)',
  `has_ad_exposure` varchar(8) DEFAULT NULL COMMENT '是否广告曝光(Y/N)',
  `goods_supply_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '即将断货/已断码/已断货',
  `is_out_of_stock` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否缺货(Y/N)',
  `days_on_site` int DEFAULT NULL COMMENT '上架天数',
  `is_hot_item_low_stock` varchar(8) DEFAULT NULL COMMENT '热销款是否库存不足(Y/N)',
  `is_hot_item` varchar(8) DEFAULT NULL COMMENT '是否热销款(Y/N)',
  `product_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品类型',
  `color_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品颜色',
  `warehouse_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备货仓库分组',
  `currency` varchar(8) DEFAULT NULL COMMENT '交易币种',
  `declared_price` decimal(12,2) DEFAULT NULL COMMENT '海关申报价格',
  `price_status` varchar(32) DEFAULT NULL COMMENT '价格状态',
  `price_adjust_status` varchar(32) DEFAULT NULL COMMENT '调价状态',
  `out_stock_qty` int DEFAULT NULL COMMENT '缺货数量',
  `recent_add_to_cart` int DEFAULT NULL COMMENT '7日加购量',
  `total_add_to_cart` int DEFAULT NULL COMMENT '累计加购量',
  `subscription_alert` int DEFAULT NULL COMMENT '到货提醒订阅数',
  `daily_sales` int DEFAULT NULL COMMENT '日销量',
  `weekly_sales` int DEFAULT NULL COMMENT '周销量',
  `monthly_sales` int DEFAULT NULL COMMENT '月销量',
  `remaining_production` int DEFAULT NULL COMMENT '剩余未生产数',
  `available_stock` int DEFAULT NULL COMMENT '可售库存',
  `pre_allocated_stock` int DEFAULT NULL COMMENT '预占库存',
  `temporarily_unavailable` int DEFAULT NULL COMMENT '不可用库存',
  `shipped_stock` int DEFAULT NULL COMMENT '已发货数量',
  `pending_shipment` int DEFAULT NULL COMMENT '待发货库存',
  `pending_approval` int DEFAULT NULL COMMENT '待审核库存',
  `replenish_logic` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备货逻辑',
  `recommended_qty` int DEFAULT NULL COMMENT '建议备货量',
  `stock_days` int DEFAULT NULL COMMENT '库存可售天数',
  `warehouse_days` int DEFAULT NULL COMMENT '仓内库存可售天数',
  `sale_days` int DEFAULT NULL COMMENT '可售天数',
  `listing_date` date DEFAULT NULL COMMENT '上架日期',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `collection_date` date DEFAULT NULL COMMENT '数据采集日期',
  PRIMARY KEY (`id`),
  KEY `idx_temp` (`sku_code`,`id`),
  KEY `idx_cos_temu_fully_temp` (`sku_code`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1967148719342957540 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_temu_goods
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_goods`;
CREATE TABLE `cos_temu_goods` (
  `id` bigint NOT NULL,
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `goods_name_en` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品英文名称',
  `goods_desc` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '商品描述',
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spucode',
  `platform_spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台spucode',
  `supplier_spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商spucode',
  `system_category_id` bigint DEFAULT NULL COMMENT '系统分类',
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `platform_category_id` int DEFAULT NULL COMMENT '平台分类id',
  `platform_category_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台分类名称',
  `platform_category_full_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台分类名称(包含父级名称)',
  `status` tinyint DEFAULT NULL COMMENT '商品状态：0=待编辑，1=待发布，2=上架，3=下架',
  `sync_status` tinyint DEFAULT '0' COMMENT '同步状态：0=不同步，1=待同步，2=同步失败，3=已同步',
  `sync_fail_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '同步失败原因',
  `submit_to_channel` bit(1) DEFAULT b'0' COMMENT '0=未提交到channel,1=已提交到channel',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `modify` int DEFAULT '0' COMMENT '第一位为1:全量更新 ,第二位为1:更新库存,第三位为1：更新价格，第四位为1：更新尺码表',
  `source_type` tinyint DEFAULT NULL COMMENT '数据来源：1=产品推品，2=反向同步，3=创建',
  `producer` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '产地: CN=中国',
  `region_id` bigint DEFAULT NULL COMMENT '产地省份：Temu省份枚举值',
  `operation_site` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '站点',
  `image_url` varchar(512) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '图片地址',
  `sensitive_attributes` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '敏感 PURE_ELECTRIC(110001, "纯电"),    INTERNAL_ELECTRIC(120001, "内电"),    MAGNETISM(130001, "磁性"),    LIQUID(140001, "液体"),    POWDER(150001, "粉末"),    PASTE(160001, "膏体"),    CUTTER(170001, "刀具")',
  `package_shape` tinyint DEFAULT NULL COMMENT '\n外包装形状0:不规则形状\n1:长方体\n2:圆柱体',
  `package_type` tinyint DEFAULT NULL COMMENT '外包装类型0:硬包装\n1:软包装+硬物\n2:软包装+软物',
  `max_battery_capacity` int DEFAULT NULL COMMENT '最大电池容量 (Wh)',
  `max_liquid_capacity` int DEFAULT NULL COMMENT '最大液体容量 (mL)',
  `max_knife_length` int DEFAULT NULL COMMENT '最大刀具长度 (cm)\n',
  `knife_tip_angle_degrees` int DEFAULT NULL COMMENT '刀尖角度',
  `cat_type` tinyint DEFAULT NULL COMMENT '0：未分类，1：服饰类',
  `on_shelf_time` datetime DEFAULT NULL COMMENT '上架时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk2` (`shop_id`,`company_id`,`platform_spu_code`,`deleted`) USING BTREE,
  KEY `idx_uk` (`company_id`,`shop_id`,`spu_code`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='pdd商品表';

-- ----------------------------
-- Table structure for cos_temu_goods_category
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_goods_category`;
CREATE TABLE `cos_temu_goods_category` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT 'shein店铺商品id',
  `type` tinyint DEFAULT NULL COMMENT '类型：1=一级分类，2=二级分类',
  `platform_category_id` bigint DEFAULT NULL COMMENT '平台分类id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `platform_category_name` varchar(255) DEFAULT NULL COMMENT '平台分类名称',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`goods_id`,`type`,`platform_category_id`,`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_temu_goods_image
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_goods_image`;
CREATE TABLE `cos_temu_goods_image` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `image_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片路径',
  `type` tinyint NOT NULL COMMENT '类型：0=细节图，1=方块图，2=色块图,4=详情图,5=主图 ,6=商品素材图，7=外包装图片',
  `position` int NOT NULL DEFAULT '0' COMMENT '顺序(按类型下增量排序)',
  `goods_id` bigint NOT NULL COMMENT 'shein店铺商品id',
  `goods_skc_id` bigint DEFAULT NULL COMMENT 'shein skcid',
  `goods_sku_id` bigint DEFAULT NULL COMMENT 'skuid',
  `transformed_image_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '转换之后的图片连接',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`image_url`,`type`,`goods_id`,`goods_skc_id`,`goods_sku_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_temu_goods_semi_managed
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_goods_semi_managed`;
CREATE TABLE `cos_temu_goods_semi_managed` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `site_id` tinyint DEFAULT NULL COMMENT '站点id',
  `site_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '站点名称',
  `freight_template_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '运费模板id',
  `shipment_limit_second` int DEFAULT NULL COMMENT '发货时效，单位秒',
  `warehouse_region_id_list` int DEFAULT NULL COMMENT '发货仓库地区id',
  `warehouse_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货仓id',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk` (`company_id`,`shop_id`,`goods_id`,`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='半托管商品信息';

-- ----------------------------
-- Table structure for cos_temu_goods_skc
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_goods_skc`;
CREATE TABLE `cos_temu_goods_skc` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT 'shein店铺商品id',
  `skc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'skc编码',
  `supplier_skc_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商spucode',
  `platform_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台spucode',
  `position` int NOT NULL DEFAULT '0' COMMENT '顺序',
  `platform_attribute_id` bigint DEFAULT '0' COMMENT '属性名称id',
  `platform_attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性名称',
  `platform_attribute_value_id` bigint DEFAULT '0' COMMENT '属性值id',
  `platform_attribute_value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `system_attribute_id` bigint DEFAULT '0' COMMENT '系统属性名称id',
  `system_attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统属性名称',
  `system_attribute_value_id` bigint DEFAULT '0' COMMENT '系统属性值id',
  `system_attribute_value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系统属性值',
  `select_status` int DEFAULT NULL COMMENT '0. 已弃用, 1. 待平台选品, 14. 待卖家修改, 15. 已修改, 16. 服饰可加色, 2. 待上传生产资料, 3. 待寄样, 4. 寄样中, 5. 待平台审版, 6. 审版不合格, 7. 平台核价中, 8. 待修改生产资料, 9. 核价未通过, 10. 待下首单, 11. 已下首单, 12. 已加入站点, 13. 已下架, 17. 已终止',
  `on_shelf_time` datetime DEFAULT NULL COMMENT '上架时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_uk2` (`company_id`,`shop_id`,`goods_id`,`platform_skc_code`,`deleted`) USING BTREE,
  KEY `idx_uk1` (`company_id`,`shop_id`,`goods_id`,`skc_code`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='pdd商品SKU表';

-- ----------------------------
-- Table structure for cos_temu_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_goods_sku`;
CREATE TABLE `cos_temu_goods_sku` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `goods_id` bigint NOT NULL COMMENT 'shein店铺商品id',
  `goods_skc_id` bigint NOT NULL COMMENT 'shein skcid',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `supplier_sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商spucode',
  `platform_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台spucode',
  `supply_price` decimal(10,2) DEFAULT NULL COMMENT '供货价',
  `weight` int DEFAULT NULL COMMENT '重量，单位克',
  `length` int DEFAULT NULL COMMENT '长，单位厘米',
  `width` int DEFAULT NULL COMMENT '宽，单位厘米',
  `height` int DEFAULT NULL COMMENT '高，单位厘米',
  `position` int NOT NULL COMMENT '排序',
  `status` tinyint NOT NULL COMMENT 'sku状态：0=新建，1=上架，2=下架',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  `modify` int DEFAULT '0' COMMENT '第一位为1:全量更新 ,第二位为1:更新库存,第三位为1：更新价格',
  `type` tinyint DEFAULT NULL COMMENT '类型：1=单品，2=组合装，3=混合套装',
  `quantity` int DEFAULT NULL COMMENT '数量',
  `unit` tinyint DEFAULT NULL COMMENT '单位：0=件，1=双，3=包',
  `sales_status` tinyint DEFAULT NULL COMMENT '销售状态：0=正常供应，1=暂时缺货',
  `stock` int DEFAULT NULL COMMENT '仓库库存',
  `color_size` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '颜色尺寸',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_uk2` (`company_id`,`shop_id`,`goods_id`,`goods_skc_id`,`platform_sku_code`,`deleted`),
  KEY `idx_uk1` (`company_id`,`shop_id`,`goods_id`,`goods_skc_id`,`sku_code`,`deleted`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='pdd商品SKU表';

-- ----------------------------
-- Table structure for cos_temu_semi_goods
-- ----------------------------
DROP TABLE IF EXISTS `cos_temu_semi_goods`;
CREATE TABLE `cos_temu_semi_goods` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺ID',
  `shop_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '店铺名称',
  `image_url` varchar(255) DEFAULT NULL COMMENT '商品主图URL',
  `spu_id` bigint DEFAULT NULL COMMENT 'spu id',
  `spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu编码',
  `supplier_spu_code` varchar(128) DEFAULT NULL COMMENT '货号',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'skc code',
  `supplier_skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'skc 货号',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku_code',
  `supplier_sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商sku编码',
  `sales_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品销售类型(Hot/Regular)',
  `product_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品类型',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `sku_spec` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKU详细信息',
  `site_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '站点',
  `is_hot` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否旺款(Y/N)',
  `daily_skc_sales` int DEFAULT NULL COMMENT '当日SKC销量',
  `daily_sku_sales` int DEFAULT NULL COMMENT '当日SKU销量',
  `start_time` datetime DEFAULT NULL COMMENT '活动开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '活动结束时间',
  `forecast_7d_sales` int DEFAULT NULL COMMENT '7日销量预测',
  `forecast_14d_sales` int DEFAULT NULL COMMENT '14日销量预测',
  `forecast_30d_sales` int DEFAULT NULL COMMENT '30日销量预测',
  `available_stock` int DEFAULT NULL COMMENT '可用库存量',
  `stock_cover_days` int DEFAULT NULL COMMENT '库存可售天数',
  `stock_health_score` decimal(5,2) DEFAULT NULL COMMENT '库存健康评分(0-100)',
  `weekly_sales` int DEFAULT NULL COMMENT '近7天销量',
  `monthly_sales` int DEFAULT NULL COMMENT '近30天销量',
  `operating_site` varchar(255) DEFAULT NULL COMMENT '经营站点代码',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_cos_temu_semi_temp` (`sku_code`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=542996 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cos_tiktok_goods_skc
-- ----------------------------
DROP TABLE IF EXISTS `cos_tiktok_goods_skc`;
CREATE TABLE `cos_tiktok_goods_skc` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `spu_id` bigint DEFAULT NULL COMMENT 'spu id',
  `spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'spu code',
  `supplier_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '货号',
  `skc_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'skc code',
  `color_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品属性',
  `promotion_price` decimal(10,2) DEFAULT NULL COMMENT '推款价格',
  `settlement_price` decimal(10,2) DEFAULT NULL COMMENT '预估结算价格（不含税）',
  PRIMARY KEY (`id`),
  KEY `shop_id_index` (`shop_id`) USING BTREE,
  KEY `spu_code_index` (`spu_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2001898281692696636 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Tiktok商品SKC信息';

-- ----------------------------
-- Table structure for cos_tiktok_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `cos_tiktok_goods_sku`;
CREATE TABLE `cos_tiktok_goods_sku` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺名称',
  `spu_id` bigint DEFAULT NULL COMMENT 'spu id',
  `spu_code` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'spu code',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `skc_code` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'skc code',
  `sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'sku code',
  `supplier_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '供应商 SKU编码',
  `combined_skus` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组合SKU编码',
  `color_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '尺码',
  `size_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '颜色',
  `sales_attributes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '销售属性（如颜色、尺寸等）',
  `global_listing_policy_inventory_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '全球Listing政策库存类型',
  `global_listing_policy_price_sync` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '全球Listing政策价格同步',
  `identifier_code_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '标识代码类型（如条形码类型）',
  `currency` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '价格货币单位',
  `sale_price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '售价',
  `tax_exclusive_price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '不含税价格',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sku_code_company` (`sku_code`,`company_id`) USING BTREE,
  KEY `spu_code_index` (`spu_code`) USING BTREE,
  KEY `shop_id_index` (`shop_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Tiktok商品SKU信息';

-- ----------------------------
-- Table structure for cos_tiktok_goods_spu
-- ----------------------------
DROP TABLE IF EXISTS `cos_tiktok_goods_spu`;
CREATE TABLE `cos_tiktok_goods_spu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺名称',
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'spu',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'spu名称',
  `file_url` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '图片地址',
  `supplier_spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '货号',
  `category_path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '分类全路基',
  `category_id` bigint DEFAULT NULL COMMENT '末级分类ID',
  `category_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分类全路径',
  `goods_status` int DEFAULT NULL COMMENT '商品状态',
  `listing_date` datetime DEFAULT NULL COMMENT '上市时间',
  `sale_price` decimal(10,2) DEFAULT NULL COMMENT '销售价',
  `cost_price` decimal(10,2) DEFAULT NULL COMMENT '成本价',
  `product_pid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品PID',
  `create_date` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  `data_type` int DEFAULT '1' COMMENT '数据类型【1:全托，2:自营】',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_spu_code_company` (`spu_code`,`company_id`) USING BTREE,
  KEY `company_id_index` (`company_id`) USING BTREE,
  KEY `shop_id_index` (`shop_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2001898281621393415 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='ods_tiktok_全托_商品列表';

-- ----------------------------
-- Table structure for cos_tiktok_sell_info
-- ----------------------------
DROP TABLE IF EXISTS `cos_tiktok_sell_info`;
CREATE TABLE `cos_tiktok_sell_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺ID',
  `shop_name` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺名称',
  `spu_code` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SPU编码',
  `sku_code` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU编码',
  `supplier_spu_code` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '货号',
  `order_id` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单ID',
  `children_order_id` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子单ID',
  `out_warehouse_dates` date DEFAULT NULL COMMENT '出库日期',
  `sell_country` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '销售国家',
  `Self_add_pri_key` bigint DEFAULT NULL COMMENT '自增主键',
  `goods_sort` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品分类',
  `goods_attribute` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品属性',
  `quantity` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '数量',
  `price` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '单价',
  `pay_amount` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '应结算金额',
  `goods_amount` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '货款总金额',
  `currency` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '币种',
  `pre_pay_dates` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '预计结算日期',
  `activity_info` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动信息',
  `expend_info` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '出资信息',
  `pay_type` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '结算类型',
  `warn_list` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '预警单/处置单',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=139446 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dwd_tiktok_销售明细表';

-- ----------------------------
-- Table structure for cos_tk_order
-- ----------------------------
DROP TABLE IF EXISTS `cos_tk_order`;
CREATE TABLE `cos_tk_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` varchar(255) DEFAULT NULL COMMENT '订单唯一标识',
  `country` varchar(255) DEFAULT NULL COMMENT '销售国家/地区',
  `sku_code` varchar(255) DEFAULT NULL COMMENT '商品SKU编码',
  `spu_code` varchar(255) DEFAULT NULL COMMENT '商品SPU编码',
  `ship_date` date DEFAULT NULL COMMENT '出库日期',
  `product_code` varchar(255) DEFAULT NULL COMMENT '商品货号',
  `category` varchar(255) DEFAULT NULL COMMENT '商品分类',
  `product_attr` varchar(255) DEFAULT NULL COMMENT '商品属性',
  `quantity` int DEFAULT NULL COMMENT '商品数量',
  `unit_price` decimal(10,2) DEFAULT NULL COMMENT '商品单价',
  `settlement_amount` decimal(10,2) DEFAULT NULL COMMENT '应结算金额',
  `currency` varchar(255) DEFAULT NULL COMMENT '交易币种',
  `promotion_info` varchar(255) DEFAULT NULL COMMENT '促销活动信息',
  `sub_order_id` varchar(255) DEFAULT NULL COMMENT '子订单ID',
  `total_amount` decimal(10,2) DEFAULT NULL COMMENT '货款总金额',
  `estimated_settle_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '预计结算日期',
  `funding_info` varchar(255) DEFAULT NULL COMMENT '出资方信息',
  `settlement_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '结算类型',
  `warning_handling` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '预警单/处置单',
  `account_name` varchar(255) DEFAULT NULL COMMENT '账户名称',
  `store_name` varchar(255) DEFAULT NULL COMMENT '店铺名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4068 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='TK 订单表';

-- ----------------------------
-- Table structure for cos_warehouse_config
-- ----------------------------
DROP TABLE IF EXISTS `cos_warehouse_config`;
CREATE TABLE `cos_warehouse_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mode` tinyint NOT NULL COMMENT '1.日均销量补货法   2.固定订货周期模型   3.需求与前置时间波动模型',
  `type` tinyint NOT NULL COMMENT '1.日均销量  2.安全库存天数  3.前置时间  4.备货天数  5.服务水平  6.二次订货间隔',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '唯一标识',
  `parameter` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '参数',
  `condition` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '条件',
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '数值',
  `company_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公司id',
  `warehouse_id` varchar(255) DEFAULT NULL COMMENT '仓库id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2001530850897956865 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for cpc_accept_detail
-- ----------------------------
DROP TABLE IF EXISTS `cpc_accept_detail`;
CREATE TABLE `cpc_accept_detail` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint DEFAULT NULL COMMENT '订单ID',
  `arrival_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `detail_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `match_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `payer_acctname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `payer_acctno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `pending_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `refund_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `total_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `virtualno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for cpc_account
-- ----------------------------
DROP TABLE IF EXISTS `cpc_account`;
CREATE TABLE `cpc_account` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业ID',
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户ID',
  `user_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户提交信息',
  `txn_seqno` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户订单号',
  `user_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户状态。ACTIVATE_PENDING :已登记或开户失败（原待激活）CHECK_PENDING :审核中（原待审核）REMITTANCE_VALID_PENDING :审核通过，待打款验证（企业用户使用，暂未要求）NORMAL :正常CANCEL :销户PAUSE :暂停ACTIVATE_PENDING_NEW ：待激活',
  `oid_userno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP系统用户编号。用户注册成功后ACCP系统返回的用户编号。',
  `accp_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP系统交易单号',
  `ret_code` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '请求结果代码。0000交易成功，对企业开户绑定法人卡时交易申请成功，需要再次验证短信。',
  `ret_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '请求结果描述',
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '授权令牌。绑定账户类型是法人银行卡时验证使用，有效期30分钟。',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '错误原因',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=159 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户开户申请表';

-- ----------------------------
-- Table structure for cpc_account_change
-- ----------------------------
DROP TABLE IF EXISTS `cpc_account_change`;
CREATE TABLE `cpc_account_change` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业ID',
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户ID',
  `user_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户提交信息',
  `txn_seqno` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户订单号',
  `user_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户状态。ACTIVATE_PENDING :已登记或开户失败（原待激活）CHECK_PENDING :审核中（原待审核）REMITTANCE_VALID_PENDING :审核通过，待打款验证（企业用户使用，暂未要求）NORMAL :正常CANCEL :销户PAUSE :暂停ACTIVATE_PENDING_NEW ：待激活',
  `oid_userno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP系统用户编号。用户注册成功后ACCP系统返回的用户编号。',
  `accp_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP系统交易单号',
  `ret_code` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '请求结果代码。0000交易成功，对企业开户绑定法人卡时交易申请成功，需要再次验证短信。',
  `ret_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '请求结果描述',
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '授权令牌。绑定账户类型是法人银行卡时验证使用，有效期30分钟。',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '错误原因',
  `change_type` tinyint(1) DEFAULT '1' COMMENT '1银行信息变更，2手机号变更，默认1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `action` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作类型。LINKEDACCT_CHANGE_ENPR：企业更换绑定银行账号。',
  `linked_agrtno` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '绑卡协议号。',
  `source_txn_seq` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源订单',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户账户申请变更表';

-- ----------------------------
-- Table structure for cpc_bank_code
-- ----------------------------
DROP TABLE IF EXISTS `cpc_bank_code`;
CREATE TABLE `cpc_bank_code` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '编码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行名称',
  `bank_type` tinyint DEFAULT '0' COMMENT '银行支持类型：0.企业银行，1.借记卡，2.信用卡',
  `logo_url` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'logo地址',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='支付银行code对应的地址';

-- ----------------------------
-- Table structure for cpc_charging
-- ----------------------------
DROP TABLE IF EXISTS `cpc_charging`;
CREATE TABLE `cpc_charging` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `merchant_order_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户订单号',
  `accp_transaction_serial_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP交易单号',
  `merchant_user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户用户号',
  `business_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '业务类型',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品名称',
  `transaction_mode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易方式',
  `transaction_category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易小类',
  `transaction_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易金额',
  `service_charge` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '手续费',
  `accp_accounting_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP账务日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='手续费对账单';

-- ----------------------------
-- Table structure for cpc_client_white_ip
-- ----------------------------
DROP TABLE IF EXISTS `cpc_client_white_ip`;
CREATE TABLE `cpc_client_white_ip` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `client_code` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '客户端,platform:服务市场',
  `white_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '白名单ip',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_client_code` (`client_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for cpc_excel_reconciliation
-- ----------------------------
DROP TABLE IF EXISTS `cpc_excel_reconciliation`;
CREATE TABLE `cpc_excel_reconciliation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `accp_accounting_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP账务日期',
  `accp_transaction_serial_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP交易单号',
  `accp_transaction_ticket_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP交易流水号',
  `handling_fee` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '手续费',
  `merchant_order_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户订单号',
  `merchant_order_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户订单时间',
  `order_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单金额',
  `order_completion_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单完成时间',
  `order_creation_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单创建时间',
  `order_information` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单信息',
  `pay_for_products` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付产品',
  `payee_account_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方账户类型',
  `payee_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方ID',
  `payee_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方名称',
  `payee_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方类型',
  `payer_account_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '付款方账户类型',
  `payer_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '付款方ID',
  `payer_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '付款方类型',
  `payment_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式',
  `platform_merchant_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '平台商户号',
  `receipt_remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款备注',
  `trading_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易状态',
  `transaction_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易类型',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_accp_date` (`accp_accounting_date`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=143 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='对账Excel对象';

-- ----------------------------
-- Table structure for cpc_order
-- ----------------------------
DROP TABLE IF EXISTS `cpc_order`;
CREATE TABLE `cpc_order` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `source_in` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'platform' COMMENT '商户来源，如：platform',
  `timestamp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '时间戳，格式yyyyMMddHHmmss HH以24小时为准，如20170309143712。timestamp 与连连服务器的时间(北京时间)之间的误差不能超过30分钟',
  `source_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源商户系统唯一交易流水号。由商户自定义',
  `real_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付中心生成的支付订单号',
  `accp_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP订单号',
  `txn_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方信息规则,com.lmc.pay.core.enums.TradeTxnTypeEnum',
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户ID',
  `user_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '	用户类型。默认：注册用户。注册用户：REGISTERED匿名用户：ANONYMOUS',
  `return_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付成功跳转地址',
  `notify_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易结果异步通知接收地址，建议HTTPS协议',
  `pay_expire` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付有效期，逾期将会关闭交易。单位：分钟，默认3天；建议:最短失效时间间隔大于5分钟',
  `txn_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户系统交易时间。格式：yyyyMMddHHmmss',
  `total_amount` decimal(10,2) DEFAULT NULL,
  `fee_amount` decimal(10,2) DEFAULT NULL,
  `pay_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT '支付状态：0待支付，1已支付',
  `pay_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式：微信扫码，WECHAT_NATIVE，支付宝：ALIPAY_NATIVE，线下转账：LZB',
  `gateway_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '回调二维码地址，成功才有',
  `ret_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '返回码',
  `ret_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '返回问题',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=602 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='创单信息总表';

-- ----------------------------
-- Table structure for cpc_order_copy
-- ----------------------------
DROP TABLE IF EXISTS `cpc_order_copy`;
CREATE TABLE `cpc_order_copy` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `source_in` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'platform' COMMENT '商户来源，如：platform',
  `timestamp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '时间戳，格式yyyyMMddHHmmss HH以24小时为准，如20170309143712。timestamp 与连连服务器的时间(北京时间)之间的误差不能超过30分钟',
  `source_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源商户系统唯一交易流水号。由商户自定义',
  `real_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付中心生成的支付订单号',
  `accp_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP订单号',
  `txn_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方信息规则,com.lmc.pay.core.enums.TradeTxnTypeEnum',
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户ID',
  `user_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' 用户类型。默认：注册用户。注册用户：REGISTERED匿名用户：ANONYMOUS',
  `return_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付成功跳转地址',
  `notify_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易结果异步通知接收地址，建议HTTPS协议',
  `pay_expire` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付有效期，逾期将会关闭交易。单位：分钟，默认3天；建议:最短失效时间间隔大于5分钟',
  `txn_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户系统交易时间。格式：yyyyMMddHHmmss',
  `total_amount` decimal(10,2) DEFAULT NULL,
  `fee_amount` decimal(10,2) DEFAULT NULL,
  `pay_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT '支付状态：0待支付，1已支付',
  `pay_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式：微信扫码，WECHAT_NATIVE，支付宝：ALIPAY_NATIVE，线下转账：LZB',
  `gateway_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '回调二维码地址，成功才有',
  `ret_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '返回码',
  `ret_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '返回问题',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for cpc_order_info
-- ----------------------------
DROP TABLE IF EXISTS `cpc_order_info`;
CREATE TABLE `cpc_order_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cpc_order_id` bigint DEFAULT NULL COMMENT '订单ID',
  `company_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业ID',
  `total_amount` decimal(10,2) DEFAULT NULL,
  `company_commission_amount` decimal(20,2) DEFAULT NULL,
  `platform_commission_amount` decimal(20,2) DEFAULT NULL,
  `order_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单信息，在查询API和支付通知中原样返回，可作为自定义参数使用。',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品描述信息。',
  `goods_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单及商品展示地址',
  `txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单号',
  `txn_item_seqno` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原结算明细编码',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `settle_period` int DEFAULT NULL COMMENT '结算周期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1090 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='订单详细表';

-- ----------------------------
-- Table structure for cpc_pap_agree_apply
-- ----------------------------
DROP TABLE IF EXISTS `cpc_pap_agree_apply`;
CREATE TABLE `cpc_pap_agree_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户ID',
  `txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '流水号',
  `sign_start_time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '授权开始时间',
  `sign_invalid_time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '授权结束时间',
  `single_limit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单笔限额',
  `daily_limit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单日限额',
  `monthly_limit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单月限额',
  `pap_agree_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '委托代发协议号',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '协议状态',
  `agreement_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '免密协议类型。WITH_HOLD：免密代扣,WITH_WITHDRAW：免密提现',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for cpc_pay_result
-- ----------------------------
DROP TABLE IF EXISTS `cpc_pay_result`;
CREATE TABLE `cpc_pay_result` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `oid_partner` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户号，ACCP系统分配给平台商户的唯一编号',
  `txn_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易类型。\r\n用户充值：USER_TOPUP\r\n商户充值：MCH_TOPUP\r\n普通消费：GENERAL_CONSUME\r\n担保消费：SECURED_CONSUME\r\n内部代发：INNER_FUND_EXCHANGE\r\n定向内部代发：INNER_DIRECT_EXCHANGE',
  `accounting_date` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '账务日期，ACCP系统交易账务日期，交易成功时返回，格式为yyyymmdd',
  `finish_time` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付完成时间。格式：yyyyMMddHHmmss',
  `accp_txno` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP系统交易单号。\r\n',
  `chnl_txno` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '渠道交易单号。',
  `txn_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '	支付交易状态。\r\nTRADE_SUCCESS:交易成功\r\n支付交易最终状态以此为准，商户按此进行后续业务逻辑处理。',
  `bankcode` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行编码',
  `linked_agrtno` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '绑卡协议号\r\n',
  `pay_chnl_txno` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '渠道流水号。如微信支付单号。',
  `sub_chnl_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '渠道商家订单号。如微信商家订单号。',
  `txn_seqno` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户系统唯一交易流水号。由商户自定义',
  `txn_time` varchar(14) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户系统交易时间。\r\n格式：yyyyMMddHHmmss',
  `total_amount` decimal(20,2) DEFAULT NULL,
  `order_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单信息，原样返回创单时传的订单信息。',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=257 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='订单支付成功回调';

-- ----------------------------
-- Table structure for cpc_payee_info
-- ----------------------------
DROP TABLE IF EXISTS `cpc_payee_info`;
CREATE TABLE `cpc_payee_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `trade_info_id` bigint DEFAULT NULL COMMENT '订单ID',
  `payee_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方id，收款方标识，收款方为用户时，为用户user_id，收款方为平台商户时，取平台商户号',
  `payee_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方类型。用户：USER，平台商户：MERCHANT',
  `payee_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '	收款方确认金额。单位：元，精确到小数点后两位',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='收款方信息';

-- ----------------------------
-- Table structure for cpc_payer_info
-- ----------------------------
DROP TABLE IF EXISTS `cpc_payer_info`;
CREATE TABLE `cpc_payer_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `pay_result_id` bigint DEFAULT NULL,
  `payer_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '付款方类型。\r\n用户：USER\r\n平台商户：MERCHANT',
  `payer_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '付款方标识。\r\n付款方为用户时设置user_id 。\r\n付款方为商户时设置平台商户号',
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '付款方式',
  `amount` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '付款金额。付款方式对应的金额，单位为元，精确到小数点后两位。\r\n所有的付款方式金额相加必须和订单总金额一致。',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=257 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='付款方信息';

-- ----------------------------
-- Table structure for cpc_payment_info
-- ----------------------------
DROP TABLE IF EXISTS `cpc_payment_info`;
CREATE TABLE `cpc_payment_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `source_in` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'platform' COMMENT '来源',
  `company_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业ID',
  `payment_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '打款单唯一编码',
  `payment_time` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '打款年月日',
  `merchant_total_amount` decimal(20,2) DEFAULT NULL,
  `total_amount` decimal(20,2) DEFAULT NULL,
  `company_total_amount` decimal(20,2) DEFAULT NULL,
  `platform_total_amount` decimal(20,2) DEFAULT NULL,
  `user_total_amount` decimal(20,2) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='打款单';

-- ----------------------------
-- Table structure for cpc_refund
-- ----------------------------
DROP TABLE IF EXISTS `cpc_refund`;
CREATE TABLE `cpc_refund` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户ID',
  `original_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源订单单号',
  `original_total_amount` decimal(10,2) DEFAULT NULL,
  `source_txn_seqno` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源客户端订单号',
  `refund_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退款单号',
  `source_refund_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原退款单号',
  `refund_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT '退款状态，0待退款，1已退款',
  `refund_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退款时间YYYYMMDD',
  `refund_total_amount` decimal(10,2) DEFAULT NULL,
  `refund_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退款原支付方式',
  `refund_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退款原因',
  `ret_code` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '结果CODE',
  `ret_msg` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '结果描述',
  `accp_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `chnl_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=234 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='退款信息表';

-- ----------------------------
-- Table structure for cpc_refund_payee
-- ----------------------------
DROP TABLE IF EXISTS `cpc_refund_payee`;
CREATE TABLE `cpc_refund_payee` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cpc_refund_id` bigint NOT NULL,
  `payee_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '原收款方ID',
  `payee_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '原收款方类型',
  `refund_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '退款金额',
  `payee_accttype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原收款方账户类型',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=329 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='退款原收款方信息表';

-- ----------------------------
-- Table structure for cpc_region_info
-- ----------------------------
DROP TABLE IF EXISTS `cpc_region_info`;
CREATE TABLE `cpc_region_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `source` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'lianlian' COMMENT 'lianlian：连连',
  `parent_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '000000' COMMENT '父编码，默认000000',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '编码',
  `region` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '地区',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=437 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='地区信息';

-- ----------------------------
-- Table structure for cpc_settlement
-- ----------------------------
DROP TABLE IF EXISTS `cpc_settlement`;
CREATE TABLE `cpc_settlement` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业ID',
  `payment_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '打款单订单',
  `accp_confirm_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '担保确认单号。ACCP系统担保确认交易单号。',
  `accp_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP系统交易单号。',
  `confirm_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '确认订单号。担保确认交易商户系统唯一交易流水号',
  `confirm_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '确认时间。担保确认交易商户系统交易时间，格式：yyyyMMddHHmmss',
  `confirm_amount` decimal(20,2) DEFAULT NULL,
  `real_txn_seqno` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户系统唯一交易流水号。由商户自定义',
  `source_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原订单编码',
  `source_item_txn_seqno` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原结算明细编码',
  `total_amount` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单总金额，单位为元，精确到小数点后两位。',
  `settlement_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '1:收款，2退款',
  `source_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT '0线上，1线下',
  `status_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT '0:等待结算，1:已结算，2结算中',
  `is_useful` tinyint(1) DEFAULT '1' COMMENT '1有效，0无效，默认1',
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原担保消费交易付款方user_id，用户在商户系统中的唯一编号',
  `settlement_time` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '结算日期',
  `ret_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `ret_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `company_commission_amount` decimal(10,2) DEFAULT NULL,
  `platform_commission_amount` decimal(10,2) DEFAULT NULL,
  `real_company_commission_amount` decimal(10,2) DEFAULT NULL,
  `real_platform_commission_amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=417 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='结算单信息';

-- ----------------------------
-- Table structure for cpc_settlement_payee
-- ----------------------------
DROP TABLE IF EXISTS `cpc_settlement_payee`;
CREATE TABLE `cpc_settlement_payee` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `settlement_id` bigint NOT NULL COMMENT '结算单ID',
  `payee_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方id，收款方标识，收款方为用户时，为用户user_id，收款方为平台商户时，取平台商户号',
  `payee_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方类型。用户：USER，平台商户：MERCHANT',
  `payee_amount` decimal(10,2) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=736 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='结算单-收款人信息';

-- ----------------------------
-- Table structure for cpc_transfer_info
-- ----------------------------
DROP TABLE IF EXISTS `cpc_transfer_info`;
CREATE TABLE `cpc_transfer_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `source_txn_seq` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原请求订单ID',
  `real_txn_seq` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '对接连连的订单ID',
  `request_info` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '请求的数据集',
  `response_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '返回数据',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=137 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for cpc_transfer_morepyee
-- ----------------------------
DROP TABLE IF EXISTS `cpc_transfer_morepyee`;
CREATE TABLE `cpc_transfer_morepyee` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `oid_partner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商户号，ACCP系统分配给平台商户的唯一编号',
  `txn_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易类型。\r\n用户充值：USER_TOPUP\r\n商户充值：MCH_TOPUP\r\n普通消费：GENERAL_CONSUME\r\n担保消费：SECURED_CONSUME\r\n内部代发：INNER_FUND_EXCHANGE\r\n定向内部代发：INNER_DIRECT_EXCHANGE',
  `accounting_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '账务日期，ACCP系统交易账务日期，交易成功时返回，格式为yyyyMMdd',
  `finish_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付完成时间。格式：yyyyMMddHHmmss',
  `accp_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ACCP系统交易单号。',
  `chnl_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '        渠道交易单号',
  `txn_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付交易状态。\r\nTRADE_SUCCESS:交易成功\r\n支付交易最终状态以此为准，商户按此进行后续业务逻辑处理。',
  `bankcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行编码。',
  `linked_agrtno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '        绑卡协议号',
  `pay_chnl_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '        渠道流水号。如微信支付单号。',
  `sub_chnl_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '渠道商家订单号。如微信商家订单号。\r\n',
  `order_info` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单数据集',
  `pay_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付订单号',
  `source_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原订单号',
  `payer_info` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '付款方信息',
  `payee_info` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款方信息',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='内部代码返回值表';

-- ----------------------------
-- Table structure for cpc_virtual_info
-- ----------------------------
DROP TABLE IF EXISTS `cpc_virtual_info`;
CREATE TABLE `cpc_virtual_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `accp_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `notify_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `cust_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `virtualno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `payer_acctname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `freeze_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `virtualname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `payer_acctno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `detail_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='虚拟卡数据信息表';

-- ----------------------------
-- Table structure for cpc_withdrawal_info
-- ----------------------------
DROP TABLE IF EXISTS `cpc_withdrawal_info`;
CREATE TABLE `cpc_withdrawal_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ret_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `ret_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `payer_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `payer_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `total_amount` decimal(20,2) DEFAULT NULL,
  `fee_amount` decimal(20,2) DEFAULT NULL,
  `source_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源订单号',
  `txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `txn_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `chnl_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '0待提现，1已提现',
  `txn_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'TRADE_ING',
  `accp_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `bankcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `accounting_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `withdrawal_time` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '可提现时间，年月日',
  `finish_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `company_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业ID',
  `failure_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '失败原因',
  `source_type` tinyint DEFAULT '0' COMMENT '默认0：普通提现，1外部代发',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=179 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='提现信息表';

-- ----------------------------
-- Table structure for css_app
-- ----------------------------
DROP TABLE IF EXISTS `css_app`;
CREATE TABLE `css_app` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `app_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '应用id:来自环信',
  `app_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '应用key: orgId#appName',
  `app_client_id` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '应用Client ID',
  `app_client_secret` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '应用Client Secret',
  `app_token` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '应用token：环信有效期933120000',
  `end_point` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '连接地址',
  `rest_api_uri` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '连接地址',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '用户名',
  `device_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '后端服务设备id',
  `user_token` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '用户token：环信有效期1天',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='应用表';

-- ----------------------------
-- Table structure for css_device
-- ----------------------------
DROP TABLE IF EXISTS `css_device`;
CREATE TABLE `css_device` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `app_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '应用id:来自环信',
  `user_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户id',
  `device_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '用户设备id',
  `last_connect_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '上次连接时间',
  `last_operate_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '上次操作时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=282 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户设备表';

-- ----------------------------
-- Table structure for css_message
-- ----------------------------
DROP TABLE IF EXISTS `css_message`;
CREATE TABLE `css_message` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `session_id` bigint unsigned NOT NULL COMMENT '会话id',
  `app_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '应用id:来自环信',
  `type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'text' COMMENT '消息类型：text、image、video',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime(3) DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `update_time` datetime(3) DEFAULT CURRENT_TIMESTAMP(3) COMMENT '更新时间',
  `create_by` bigint DEFAULT '0' COMMENT '创建人id',
  `update_by` bigint DEFAULT '0' COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_session_id` (`session_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=367 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='客服系统消息表';

-- ----------------------------
-- Table structure for css_session
-- ----------------------------
DROP TABLE IF EXISTS `css_session`;
CREATE TABLE `css_session` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `css_app_id` int NOT NULL DEFAULT '0' COMMENT '应用id',
  `app_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '应用id:来自环信',
  `from_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '发信人id',
  `from_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '发信人名称',
  `to_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '收信人id',
  `to_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '收信人名称',
  `subject` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订阅主题：from_id-to_id',
  `unread_size` int NOT NULL DEFAULT '0' COMMENT '未读数',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime(3) DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `update_time` datetime(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
  `create_by` bigint DEFAULT '0' COMMENT '创建人id',
  `update_by` bigint DEFAULT '0' COMMENT '创建人id或更新人id',
  `from_avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发信人头像',
  `to_avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收信人头像',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_appId_fromId_toId` (`app_id`,`from_id`,`to_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=302 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='客服会话表';

-- ----------------------------
-- Table structure for dwd_jushuitan_sell_analysis_order_info
-- ----------------------------
DROP TABLE IF EXISTS `dwd_jushuitan_sell_analysis_order_info`;
CREATE TABLE `dwd_jushuitan_sell_analysis_order_info` (
  `shop_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺编号',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺',
  `goods_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品编码',
  `goods_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品名称',
  `style_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '款式编码',
  `shop_style_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺款式编码',
  `supplier_goods_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '供应商商品编码',
  `shop_goods_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺商品编码',
  `deliver_dates` datetime DEFAULT NULL COMMENT '发货日期',
  `combination_goods_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组合装商品编',
  `combination_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组合装实体编码',
  `in_order_num` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '内部订单号',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '标记多标签',
  `after_Sale_order_num` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '售后单号',
  `order_sort` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单类型',
  `on_line_order_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线上订单号',
  `out_platform_order_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '平台外部订单号',
  `order_status` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单状态',
  `deliver_warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '发货仓',
  `operate_warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '运营云仓',
  `is_pre_sell_goods` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否预售商品',
  `distributer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分销商',
  `flag` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '小旗',
  `buyer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '买家账号',
  `buyer_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '买家ID',
  `buyer_message` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '买家留言',
  `buyer_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '卖家备注',
  `order_dates` datetime DEFAULT NULL COMMENT '订单日期',
  `pay_dates` date DEFAULT NULL COMMENT '付款日期',
  `confirm_receive_dates` date DEFAULT NULL COMMENT '确认收货日期',
  `supply_market_pay_dates` date DEFAULT NULL COMMENT '供销支付时间',
  `salesman` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '业务员',
  `receiveer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收货人',
  `province` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '省',
  `city` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '市',
  `district` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '区县',
  `express_company` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '快递公司',
  `express_order_num` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '快递单号',
  `after_Sale_register_dates` date DEFAULT NULL COMMENT '售后登记日期',
  `after_Sale_affirm_dates` date DEFAULT NULL COMMENT '售后确认日期',
  `after_Sale_in_warehouse_dates` date DEFAULT NULL COMMENT '售后进仓日期',
  `after_Sale_in_warehouse_order` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '售后进仓单号',
  `after_Sale_sort` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '售后分类',
  `question_sort` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '问题类型',
  `old_on_line_order_num` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '原始线上订单号',
  `virtual_sort` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '虚拟分类',
  `goods_sort` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品分类',
  `brand_sort` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '品牌',
  `brand_short` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品简称',
  `colour_ize` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '颜色规格',
  `on_line_colour_ize` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线上颜色规格',
  `supplier` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '供应商',
  `supplier_style` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '供应商款号',
  `basic_price` decimal(10,2) DEFAULT NULL COMMENT '基本售价',
  `cost_price` decimal(10,2) DEFAULT NULL COMMENT '成本价',
  `cost_price_source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '成本价来源',
  `sell_quantity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '销售数量',
  `gift_quantity` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '赠品数量',
  `price0_goods_quantity` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '价格为零的商品数量',
  `real_deliver_quantity` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '实发数量',
  `real_deliver_amount` decimal(10,2) DEFAULT NULL COMMENT '实发金额',
  `sell_amount` decimal(10,2) DEFAULT NULL COMMENT '销售金额',
  `sell_cost` decimal(10,2) DEFAULT NULL COMMENT '销售成本',
  `real_deliver_cost` decimal(10,2) DEFAULT NULL COMMENT '实发成本',
  `sell_profit` decimal(10,2) DEFAULT NULL COMMENT '销售毛利',
  `sell_profit_rate` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '销售毛利率',
  `pay_amount` decimal(10,2) DEFAULT NULL COMMENT '已付金额',
  `should_pay_amount` decimal(10,2) DEFAULT NULL COMMENT '应付金额',
  `price` decimal(10,2) DEFAULT NULL COMMENT '售价',
  `colour` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '颜色',
  `size` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '码数',
  `basic_amount` decimal(10,2) DEFAULT NULL COMMENT '基本金额',
  `return_quantity` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '退货数量',
  `real_return_quantity` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '实退数量',
  `return_amount` decimal(10,2) DEFAULT NULL COMMENT '退货金额',
  `return_cost` decimal(10,2) DEFAULT NULL COMMENT '退货成本',
  `real_return_cost` decimal(10,2) DEFAULT NULL COMMENT '实退成本',
  `real_return_amount` decimal(10,2) DEFAULT NULL COMMENT '实退金额',
  `freight_income` decimal(10,2) DEFAULT NULL COMMENT '运费收入',
  `freight_income_share` decimal(10,2) DEFAULT NULL COMMENT '运费收入分摊',
  `freight_expend` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '运费支出',
  `freight_expend_share` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '运费支出分摊',
  `discount_amount` decimal(10,2) DEFAULT NULL COMMENT '优惠金额',
  `order_weight` float DEFAULT NULL COMMENT '订单重量',
  `order_goods_weight` float DEFAULT NULL COMMENT '订单商品重量',
  `goods_site` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商店站点',
  `goods_source` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单来源',
  `note` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '便签',
  `other_price1` decimal(10,2) DEFAULT NULL COMMENT '其它价格1',
  `other_price2` decimal(10,2) DEFAULT NULL COMMENT '其它价格2',
  `other_price3` decimal(10,2) DEFAULT NULL COMMENT '其它价格3',
  `other_price4` decimal(10,2) DEFAULT NULL COMMENT '其它价格4',
  `other_price5` decimal(10,2) DEFAULT NULL COMMENT '其它价格5',
  `buy_price` decimal(10,2) DEFAULT NULL COMMENT '采购价',
  `other_attribute3` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '其它属性3',
  `other_attribute4` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '其它属性4',
  `other_attribute5` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '其它属性5',
  `currency` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '币种',
  `international_order_num` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '国际单号',
  `remaining_deliver_times` varchar(85) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '剩余发货时间',
  `pay_sort` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '付款方式',
  `payer_express` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '买家指定物流',
  `receive_country` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收货国家地区',
  `real_express` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '实发物流渠道',
  `out_freight_expend_share` decimal(10,2) DEFAULT NULL COMMENT '境外运费支出分摊',
  `out_income_share` decimal(10,2) DEFAULT NULL COMMENT '境外收入总计分摊',
  `out_expend_share` decimal(10,2) DEFAULT NULL COMMENT '境外支出总计分摊',
  `on_line_goods` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线上商品名',
  `on_line_order_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线上子订单编号',
  `out_order_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '出仓单号',
  `discount_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '优惠券名称',
  `goods_design_weight` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品资料设置重量',
  `exchange_rate` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '汇率',
  `subsidy` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '平台补贴金额',
  `pre_deliver_dates` date DEFAULT NULL COMMENT '预计发货日期',
  `market_price` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '市场吊牌价',
  `international_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '国标码',
  `unit` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '单位',
  `market_amount` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '市场吊牌金额',
  `order_pay_times` date DEFAULT NULL COMMENT '订单支付时间',
  `po_num` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'po号',
  `operate_warehouse_deliver` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '运营云仓发货',
  `order_note` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单明细商品备注',
  `expert_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '达人编号',
  `expert_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '达人名称',
  `activity_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动编号',
  `activity_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动名称',
  `is_special` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否特殊单',
  `send_times` date DEFAULT NULL COMMENT '妥投时间',
  `in_son_order_num` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '内部子订单号',
  `shop_sort_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺分组名称',
  `order_volume` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单体积',
  `order_goods_volume` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单商品体积',
  `order_goods_amount` decimal(10,2) DEFAULT NULL COMMENT '订单商品成交金额',
  `platform_order_status` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '平台订单状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dwd_聚水潭_销售主题分析_订单明细';

-- ----------------------------
-- Table structure for dwd_prd_sales_detail_info
-- ----------------------------
DROP TABLE IF EXISTS `dwd_prd_sales_detail_info`;
CREATE TABLE `dwd_prd_sales_detail_info` (
  `types` varchar(85) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '来源类别（如聚水潭-分销、赛狐-亚马逊等）',
  `shop_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺信息（JSON格式，含店铺ID、名称、区域等）',
  `order_info` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单信息（JSON格式，含订单ID、子单ID、状态等）',
  `product_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品编码信息（JSON格式，含SPU、SKU、货号等）',
  `product_dimension` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品维度信息（JSON格式，含分类、属性、标签等）',
  `time_info` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '时间信息（JSON格式，含订单日期、发货日期等）',
  `sale_date` date DEFAULT NULL COMMENT '销售日期（根据来源类别从time_info提取）',
  `quantity_info` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '数量信息（JSON格式，含销量、库存、退货量等）',
  `price_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '价格信息（JSON格式，含单价、折扣、原价等）',
  `amount_info` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '金额信息（JSON格式，含销售额、成本、利润等）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dwd_商品_销售明细表';

-- ----------------------------
-- Table structure for dwd_prd_stock_info
-- ----------------------------
DROP TABLE IF EXISTS `dwd_prd_stock_info`;
CREATE TABLE `dwd_prd_stock_info` (
  `tab` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '来源表',
  `warehouse_info` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '仓库信息',
  `shop_info` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店信息',
  `product_code` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品编码',
  `product_info` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品详细信息',
  `time_info` varchar(85) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '时间信息',
  `update_date` date DEFAULT NULL COMMENT '更新日期',
  `stock_quantity_info` varchar(85) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '库存数量信息',
  `age_info` varchar(85) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '库龄信息',
  `price_info` varchar(85) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品单价',
  `amount_info` varchar(85) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '库存金额'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dwd_商品_库存明细表';

-- ----------------------------
-- Table structure for dwd_prd_tiktok_self_stock_info
-- ----------------------------
DROP TABLE IF EXISTS `dwd_prd_tiktok_self_stock_info`;
CREATE TABLE `dwd_prd_tiktok_self_stock_info` (
  `shop_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺ID',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku_id',
  `warehouse_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '仓库名字',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  `shop_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺名称',
  `attribute` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '属性',
  `seller_sku` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'seller_sku',
  `product_id` bigint DEFAULT NULL COMMENT '产品id',
  `product_title` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品名称',
  `total` int DEFAULT NULL COMMENT '总库存',
  `in_shop_stock` int DEFAULT NULL COMMENT '可见库存',
  `to_be_dispatched` int DEFAULT NULL COMMENT '待发货',
  `insert_time` datetime DEFAULT NULL COMMENT '插入时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dwd_tiktok_自营_库存表';

-- ----------------------------
-- Table structure for dwd_si_sell_detail_info
-- ----------------------------
DROP TABLE IF EXISTS `dwd_si_sell_detail_info`;
CREATE TABLE `dwd_si_sell_detail_info` (
  `id` bigint DEFAULT NULL COMMENT '自增主键',
  `shop_id` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  `goods_id` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  `skc` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  `supplier_item_num` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL,
  `spu` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  `sku_id` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  `update_dates` date DEFAULT NULL COMMENT '更新日期',
  `shop_name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '店铺名称',
  `pic_link` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '图片链接',
  `goods_sort` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '商品分类',
  `list_dates` date DEFAULT NULL COMMENT '上架日期',
  `list_day` int DEFAULT NULL COMMENT '上架天数',
  `label` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '标签',
  `sell_quantity` int DEFAULT NULL COMMENT '当天销量',
  `pay_order_num` int DEFAULT NULL COMMENT '购买单数',
  `ordered_parameter` int DEFAULT NULL COMMENT '下单参数',
  `7_sell_quantity` int DEFAULT NULL COMMENT '近7天销量',
  `30_sell_quantity` int DEFAULT NULL COMMENT '近30天销量',
  `stay_deliver` int DEFAULT NULL COMMENT '待发货',
  `in_transit` int DEFAULT NULL COMMENT '在途',
  `stay_list` int DEFAULT NULL COMMENT '待上架',
  `seller_all_stock` int DEFAULT NULL COMMENT '商家仓总库存',
  `virtual_stock` int DEFAULT NULL COMMENT '虚拟销售库存',
  `plan_rush_purchase_num` int DEFAULT NULL COMMENT '预计急采数',
  `sell_days` int DEFAULT NULL COMMENT '可售天数',
  `advice_order_num` int DEFAULT NULL COMMENT '建议下单数',
  `ordered_num` int DEFAULT NULL COMMENT '已下单数',
  `plan_ordered_num` int DEFAULT NULL COMMENT '拟下单数',
  `auto_order_status` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '自动下单状态',
  `update_times` datetime DEFAULT NULL COMMENT '更新时间',
  `info_sort` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '类型 半托管 ODM OBM',
  `attribute` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '属性集',
  `supply_status` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '供应状态',
  `list_status` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '上架状态',
  `sell_model` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '销售模式',
  `goods_level` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '商品层次',
  `sku_code` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'sisku',
  `price` double DEFAULT NULL COMMENT '价格',
  `quality_level` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '质量等级',
  `stock` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '库存',
  `indiana_stock` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '海外仓在库数量',
  `pre_occupied_num` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '预占数',
  `min_vmi_spot_advice` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '现货建议_最小',
  `max_vmi_spot_advice` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '现货建议_最大',
  `jit_available` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '待入库',
  `usable_stock_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '商家仓总库存_新',
  KEY `idx_update_date` (`update_dates` DESC) USING BTREE,
  KEY `idx_update_dates` (`update_dates`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dwd_si_销售明细(只能用OBM数据)';

-- ----------------------------
-- Table structure for dwd_temu_full_sell_info
-- ----------------------------
DROP TABLE IF EXISTS `dwd_temu_full_sell_info`;
CREATE TABLE `dwd_temu_full_sell_info` (
  `shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺ID',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺名称',
  `sell_date` date DEFAULT NULL COMMENT '销售日期',
  `spu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SPU',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品名称',
  `SKC` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKC',
  `skc_item_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKC货号',
  `SKU_ID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU ID',
  `sku_item_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU货号',
  `pic_link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '图片链接',
  `pic_examine` int DEFAULT NULL COMMENT '图审 1 图审未完成 2 图审完成',
  `stock_up_sort` int DEFAULT NULL COMMENT '备货情况 1 暂时无法备货 2正常备货',
  `comment_num` int DEFAULT NULL COMMENT '评论数',
  `score` double DEFAULT NULL COMMENT '评分',
  `is_advice_stock_up` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否建议备货',
  `is_advice_ad` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否站处广告曝光',
  `out_stock_break_code` int DEFAULT NULL COMMENT '断货断码 1 即将断货/2 已断码/3 已断货 其他为null',
  `is_lack` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否缺货',
  `is_lack_hot` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否热销款库存不足',
  `is_hot` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否热销款',
  `sort` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型',
  `site_times` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '加入站点时长',
  `colour` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '颜色',
  `stock_up_warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '备货仓组',
  `currency` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '币种',
  `declare_price` double DEFAULT NULL COMMENT '申报价格',
  `deposit_status` int DEFAULT NULL COMMENT '开款价格状态 0 其他 2 已生效',
  `adjust_price_status` int DEFAULT NULL COMMENT '调价状态 3 调价失败 2 改价成功 0: 其他',
  `lack_quantity` int DEFAULT NULL COMMENT '缺货数量',
  `7_add_car_quantity` int DEFAULT NULL COMMENT '近7日用户购加数量',
  `all_add_car_quantity` int DEFAULT NULL COMMENT '用户累计加购数量',
  `subscribe_remind_goods` int DEFAULT NULL COMMENT '已订阅待提醒到货',
  `1_sell_quantity` int DEFAULT NULL COMMENT '1天销量',
  `7_sell_quantity` int DEFAULT NULL COMMENT '7天销量',
  `30_sell_quantity` int DEFAULT NULL COMMENT '30天销量',
  `remaining_unproduce_num` int DEFAULT NULL COMMENT '剩余未生产数',
  `available_stock` int DEFAULT NULL COMMENT '仓内可用库存',
  `pre_occupy_stock` int DEFAULT NULL COMMENT '仓内预占用库存',
  `disable_stock` int DEFAULT NULL COMMENT '仓内暂不可用库存',
  `deliver_stock` int DEFAULT NULL COMMENT '已发货库存',
  `stay_deliver_stock` int DEFAULT NULL COMMENT '已创建备货单待发货库存',
  `stay_examine_stock` int DEFAULT NULL COMMENT '待审核备货库存',
  `stock_up_logic` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '备货逻辑',
  `advice_stock_up_quantity` int DEFAULT NULL COMMENT '建议备货量',
  `stock_up_available_sell_days` int DEFAULT NULL COMMENT '库存可售天数',
  `warehouse_available_sell_days` int DEFAULT NULL COMMENT '仓内库存可售天数',
  `available_sell_days` int DEFAULT NULL COMMENT '可售天数',
  `list_dates` date DEFAULT NULL COMMENT '上架日期',
  `update_dates` datetime DEFAULT NULL COMMENT '更新时间',
  KEY `idx_sell_date_shop_sku` (`sell_date` DESC,`shop_id`,`SKU_ID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dwd_temu_全托管日销售表';

-- ----------------------------
-- Table structure for dwd_temu_half_info
-- ----------------------------
DROP TABLE IF EXISTS `dwd_temu_half_info`;
CREATE TABLE `dwd_temu_half_info` (
  `auto_inc_id` bigint DEFAULT NULL COMMENT '自增主键',
  `shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺ID',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺名称',
  `spu_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SPU ID',
  `product_name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '商品名称',
  `product_image_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '商品图片链接',
  `skc_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKC ID',
  `skc_item_code` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'SKC货号',
  `sku_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU ID',
  `sku_item_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU货号',
  `sku_spec` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU规格',
  `sku_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU类型(爆款/平款)',
  `start_date` date DEFAULT NULL COMMENT '开始日期',
  `end_date` date DEFAULT NULL COMMENT '结束日期',
  `site_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '站点代码',
  `product_category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品分类',
  `skc_popular` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKC是否旺款',
  `daily_skc_sales` int DEFAULT NULL COMMENT '今日SKC销量',
  `daily_sku_sales` int DEFAULT NULL COMMENT '今日SKU销量',
  `forecast_sales_7d` int DEFAULT NULL COMMENT '未来7日预计销量',
  `forecast_sales_14d` int DEFAULT NULL COMMENT '未来14日预计销量',
  `forecast_sales_30d` int DEFAULT NULL COMMENT '未来30日预计销量',
  `fulfillment_mode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '销售可用库存',
  `inventory_available_days` int DEFAULT NULL COMMENT '库存可售天数',
  `stockout_health_score` double DEFAULT NULL COMMENT '售罄健康分',
  `operation_site` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '经营站点',
  `last_updated_at` datetime DEFAULT NULL COMMENT '最后更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dwd_temu_半托管日销售表';

-- ----------------------------
-- Table structure for dwd_tiktok_self_order_sku_info
-- ----------------------------
DROP TABLE IF EXISTS `dwd_tiktok_self_order_sku_info`;
CREATE TABLE `dwd_tiktok_self_order_sku_info` (
  `id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '记录ID',
  `shop_id` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺ID',
  `shop_name` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺名称',
  `order_id` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单ID',
  `update_times` datetime DEFAULT NULL COMMENT '更新时间',
  `connectid` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '连接ID（系统字段）',
  `commerce_platform` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电商平台',
  `order_type` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单类型',
  `status` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '状态',
  `cancellation_initiator` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '取消订单发起方',
  `is_buyer_request_cancel` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否买家申请取消',
  `is_replacement_order` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否替换订单',
  `is_cod` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否货到付款',
  `is_on_hold_order` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否暂停订单',
  `is_sample_order` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否样品订单',
  `has_updated_recipient_address` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否更新收件地址',
  `fulfillment_type` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '履约类型',
  `delivery_type` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '配送类型',
  `shipping_type` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '运输类型',
  `split_or_combine_tag` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '拆分/合并标签',
  `shipping_provider` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '物流商',
  `delivery_option_id` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '配送选项ID',
  `delivery_option_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '配送选项名称',
  `warehouse_id` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '仓库ID',
  `replaced_order_id` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '替换订单ID',
  `packages` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '包裹信息',
  `payment_method_name` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '支付方式名称',
  `buyer_email` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '买家邮箱',
  `buyer_message` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '买家留言',
  `seller_note` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '卖家备注',
  `cpf` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '纳税人识别号（巴西等国家）',
  `user_id` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '用户ID',
  `recipient_address_address_detail` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件地址-详细地址',
  `recipient_address_address_line1` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件地址-地址行1',
  `recipient_address_address_line2` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件地址-地址行2',
  `recipient_address_address_line3` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件地址-地址行3',
  `recipient_address_address_line4` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件地址-地址行4',
  `recipient_address_district_info` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件地址-区域信息',
  `recipient_address_first_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件人-名',
  `recipient_address_full_address` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件地址-完整地址',
  `recipient_address_last_name` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件人-姓',
  `recipient_address_name` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件人姓名',
  `recipient_address_phone_number` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件人电话号码',
  `recipient_address_postal_code` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件地址-邮政编码',
  `recipient_address_region_code` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收件地址-地区代码',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `paid_time` datetime DEFAULT NULL COMMENT '支付时间',
  `collection_time` datetime DEFAULT NULL COMMENT '揽收时间',
  `delivery_time` datetime DEFAULT NULL COMMENT '送达时间',
  `request_cancel_time` datetime DEFAULT NULL COMMENT '申请取消时间',
  `release_date` datetime DEFAULT NULL COMMENT '释放日期',
  `cancel_order_sla_time` datetime DEFAULT NULL COMMENT '取消订单时效时间',
  `collection_due_time` datetime DEFAULT NULL COMMENT '揽收截止时间',
  `delivery_due_time` datetime DEFAULT NULL COMMENT '送达截止时间',
  `shipping_due_time` datetime DEFAULT NULL COMMENT '运输截止时间',
  `pick_up_cut_off_time` datetime DEFAULT NULL COMMENT '取件截止时间',
  `fast_dispatch_sla_time` datetime DEFAULT NULL COMMENT '快速发货时效时间',
  `rts_sla_time` datetime DEFAULT NULL COMMENT '发货时效时间',
  `tts_sla_time` datetime DEFAULT NULL COMMENT '平台处理时效时间',
  `delivery_sla_time` datetime DEFAULT NULL COMMENT '配送时效时间',
  `delivery_option_required_delivery_time` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '配送选项要求送达时间',
  `handling_duration_days` int DEFAULT NULL COMMENT '处理时长-天数',
  `handling_duration_type` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '处理时长-类型',
  `payment_currency` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '支付币种',
  `currency` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '币种',
  `display_status` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '展示状态',
  `is_gift` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否为赠品',
  `package_id` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '包裹ID',
  `package_status` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '包裹状态',
  `product_id` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品ID',
  `product_name` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品名称',
  `seller_sku` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '卖家SKU',
  `shipping_provider_id` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '物流商ID',
  `shipping_provider_name` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '物流商名称',
  `sku_id` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU ID',
  `sku_image` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU图片',
  `sku_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU名称',
  `sku_type` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU类型',
  `tracking_number` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '物流跟踪号',
  `self_update_time` date DEFAULT NULL COMMENT '同步时间(原表没有)',
  `rts_time` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '发货时间',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `platform_discount` decimal(10,2) DEFAULT NULL COMMENT '平台折扣',
  `quantity` int DEFAULT NULL COMMENT '销量',
  `sale_price` decimal(10,2) DEFAULT NULL COMMENT '售价',
  `seller_discount` decimal(10,2) DEFAULT NULL COMMENT '卖家折扣',
  `payment_original_shipping_fee` decimal(10,2) DEFAULT NULL COMMENT '支付-原始运费',
  `payment_original_total_product_price` decimal(10,2) DEFAULT NULL COMMENT '支付-原始产品总价',
  `payment_platform_discount` decimal(10,2) DEFAULT NULL COMMENT '支付-平台折扣',
  `payment_product_tax` float DEFAULT NULL COMMENT '支付-产品税',
  `payment_seller_discount` decimal(10,2) DEFAULT NULL COMMENT '支付-卖家折扣',
  `payment_shipping_fee` decimal(10,2) DEFAULT NULL COMMENT '支付-运费',
  `payment_shipping_fee_platform_discount` decimal(10,2) DEFAULT NULL COMMENT '支付-运费平台折扣',
  `payment_shipping_fee_seller_discount` decimal(10,2) DEFAULT NULL COMMENT '支付-运费卖家折扣',
  `payment_shipping_fee_tax` decimal(10,2) DEFAULT NULL COMMENT '支付-运费税',
  `payment_sub_total` decimal(10,2) DEFAULT NULL COMMENT '支付-小计',
  `payment_tax` decimal(10,2) DEFAULT NULL COMMENT '支付-税费',
  `payment_total_amount` decimal(10,2) DEFAULT NULL COMMENT '支付-总金额'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dwd_TIKTOK订单报告_商品详情';

-- ----------------------------
-- Table structure for dwd_tiktok_sell_info
-- ----------------------------
DROP TABLE IF EXISTS `dwd_tiktok_sell_info`;
CREATE TABLE `dwd_tiktok_sell_info` (
  `order_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单ID',
  `son_order_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子单ID',
  `sku_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU编码',
  `spu_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SPU编码',
  `out_warehouse_dates` date DEFAULT NULL COMMENT '出库日期',
  `sell_country` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '销售国家',
  `shop_name` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺名称',
  `Self_add_pri_key` bigint DEFAULT NULL COMMENT '自增主键',
  `item_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '货号',
  `goods_sort` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品分类',
  `goods_attribute` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品属性',
  `quantity` int DEFAULT NULL COMMENT '数量',
  `price` decimal(10,4) DEFAULT NULL COMMENT '单价',
  `pay_amount` decimal(10,4) DEFAULT NULL COMMENT '应结算金额',
  `goods_amount` decimal(10,4) DEFAULT NULL COMMENT '货款总金额',
  `currency` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '币种',
  `pre_pay_dates` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '预计结算日期',
  `activity_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动信息',
  `expend_info` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '出资信息',
  `pay_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '结算类型',
  `warn_list` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '预警单/处置单',
  `insert_time` datetime DEFAULT NULL COMMENT '插入时间',
  UNIQUE KEY `uk_order_sku_date` (`order_id`,`son_order_id`,`sku_code`,`spu_code`,`out_warehouse_dates`) USING BTREE,
  KEY `idx_warehouse_date_sku` (`out_warehouse_dates`,`sku_code`,`spu_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='dwd_tiktok_销售明细表';

-- ----------------------------
-- Table structure for event_call_back_data
-- ----------------------------
DROP TABLE IF EXISTS `event_call_back_data`;
CREATE TABLE `event_call_back_data` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL COMMENT '平台类型',
  `event_type` varchar(255) DEFAULT NULL COMMENT '事件类型 参考:WebhookEventEnum',
  `data` text COMMENT '事件数据',
  `creat_time` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for lm_scm_req_order
-- ----------------------------
DROP TABLE IF EXISTS `lm_scm_req_order`;
CREATE TABLE `lm_scm_req_order` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `code` varchar(64) DEFAULT NULL COMMENT '订单需求单号',
  `brand` varchar(64) DEFAULT NULL COMMENT '品牌',
  `production_type` varchar(32) DEFAULT NULL COMMENT '生产类型',
  `pdt_codes` varchar(512) DEFAULT NULL COMMENT '款号',
  `order_date` datetime DEFAULT NULL COMMENT '制单日期',
  `order_type` varchar(32) DEFAULT NULL COMMENT '单据类型',
  `channel_business` varchar(16) DEFAULT NULL COMMENT '渠道商',
  `store` varchar(128) DEFAULT NULL COMMENT '仓库名称',
  `store_code` varchar(64) DEFAULT NULL COMMENT '仓库编码',
  `customer` varchar(128) DEFAULT NULL COMMENT '客户名称',
  `customer_code` varchar(64) DEFAULT NULL COMMENT '客户编码',
  `customer_short_name` varchar(64) DEFAULT NULL COMMENT '客户简称',
  `total_qty` decimal(18,4) DEFAULT NULL COMMENT '总数量',
  `total_amt` decimal(18,4) DEFAULT NULL COMMENT '总金额',
  `total_price` decimal(18,4) DEFAULT NULL COMMENT '总价格(同totalAmt)',
  `contract_no` varchar(64) DEFAULT NULL COMMENT '合同号',
  `currency` varchar(32) DEFAULT '人民币' COMMENT '币种',
  `follow_man` varchar(64) DEFAULT NULL COMMENT '跟单员',
  `tags` varchar(256) DEFAULT NULL COMMENT '标签',
  `inner_code` varchar(64) DEFAULT NULL COMMENT '内部单号',
  `ov_date` datetime DEFAULT NULL COMMENT '结案日期',
  `statuz` tinyint DEFAULT NULL COMMENT 'SCM订单状态：【0.未审核, 1.已审核, 7.已结案 9.已作废, 80.审批中】',
  `check_man` varchar(64) DEFAULT NULL COMMENT '审核人',
  `att01` varchar(255) DEFAULT NULL COMMENT '扩展属性1',
  `att02` varchar(255) DEFAULT NULL COMMENT '扩展属性2',
  `att03` varchar(255) DEFAULT NULL COMMENT '扩展属性3',
  `att04` varchar(255) DEFAULT NULL COMMENT '扩展属性4',
  `att05` varchar(255) DEFAULT NULL COMMENT '扩展属性5',
  `att06` varchar(255) DEFAULT NULL COMMENT '扩展属性6',
  `att07` varchar(255) DEFAULT NULL COMMENT '扩展属性7',
  `att08` varchar(255) DEFAULT NULL COMMENT '扩展属性8',
  `check_date` datetime DEFAULT NULL COMMENT '审核日期',
  `remark` varchar(512) DEFAULT NULL COMMENT '备注',
  `create_user` varchar(64) DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `modify_user` varchar(64) DEFAULT NULL COMMENT '修改人',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `deliver_date` datetime DEFAULT NULL COMMENT '交货日期',
  `sale_type` varchar(32) DEFAULT NULL COMMENT '销售类型',
  `api_code` varchar(64) DEFAULT NULL COMMENT '外部单号',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_code` (`code`) USING BTREE,
  KEY `idx_pdt_codes` (`pdt_codes`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2001855485510291457 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领猫订单需求表';

-- ----------------------------
-- Table structure for ods_tiktok_all_prd_dimension_info
-- ----------------------------
DROP TABLE IF EXISTS `ods_tiktok_all_prd_dimension_info`;
CREATE TABLE `ods_tiktok_all_prd_dimension_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺id',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '店铺名称',
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'spu',
  `sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'sku',
  `barcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU条形码',
  `category_name` text COLLATE utf8mb4_bin COMMENT '分类',
  `key_attribute_name` text COLLATE utf8mb4_bin COMMENT '属性',
  `price` decimal(10,2) DEFAULT NULL COMMENT '价格',
  `jit_wait_ship_qty` int DEFAULT NULL COMMENT '已售待发货',
  `inventory_qty` int DEFAULT NULL COMMENT '售卖中库存',
  `supplier_product_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'SKU货号',
  `skc_supplier_product_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '货号',
  `product_pid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '商品PID',
  `on_sale_count` int DEFAULT NULL COMMENT '在库库存',
  `in_transit_count` int DEFAULT NULL COMMENT '在途库存',
  `to_confirm_count` int DEFAULT NULL COMMENT '备货待确认数量',
  `stock_up_count` int DEFAULT NULL COMMENT '备货中数量',
  `total_sales` int DEFAULT NULL COMMENT '累计销量',
  `sales_volume_3` int DEFAULT NULL COMMENT '近3天销量',
  `sales_volume_7` int DEFAULT NULL COMMENT '近7天销量',
  `sales_volume_14` int DEFAULT NULL COMMENT '近14天销量',
  `sales_volume_30` int DEFAULT NULL COMMENT '近30天销量',
  `size_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '销售属性',
  `update_date` datetime DEFAULT NULL COMMENT '更新时间',
  `image_url` varchar(1024) COLLATE utf8mb4_bin DEFAULT NULL,
  `product_name` varchar(512) COLLATE utf8mb4_bin DEFAULT NULL,
  `insert_time` datetime DEFAULT NULL COMMENT '插入时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1610976 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='ods_tiktok_全托_商品列表';

-- ----------------------------
-- Table structure for ods_tiktok_self_prd_dimension_info
-- ----------------------------
DROP TABLE IF EXISTS `ods_tiktok_self_prd_dimension_info`;
CREATE TABLE `ods_tiktok_self_prd_dimension_info` (
  `id` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '商品ID',
  `shop_id` text COLLATE utf8mb4_bin COMMENT '店铺ID',
  `shop_name` text COLLATE utf8mb4_bin COMMENT '店铺名称',
  `status` text COLLATE utf8mb4_bin COMMENT '状态（商品状态）',
  `title` text COLLATE utf8mb4_bin COMMENT '商品标题',
  `create_time` text COLLATE utf8mb4_bin COMMENT '创建时间',
  `update_time` text COLLATE utf8mb4_bin COMMENT '更新时间',
  `sales_regions` text COLLATE utf8mb4_bin COMMENT '销售地区',
  `category_chains` text COLLATE utf8mb4_bin COMMENT '分类链（类目层级关系）',
  `brand_id` text COLLATE utf8mb4_bin COMMENT '品牌ID',
  `brand_name` text COLLATE utf8mb4_bin COMMENT '品牌名称',
  `main_images` text COLLATE utf8mb4_bin COMMENT '主图（商品主图）',
  `video_id` text COLLATE utf8mb4_bin COMMENT '视频ID',
  `video_cover_url` text COLLATE utf8mb4_bin COMMENT '视频封面URL',
  `video_format` text COLLATE utf8mb4_bin COMMENT '视频格式',
  `video_url` text COLLATE utf8mb4_bin COMMENT '视频URL',
  `video_width` text COLLATE utf8mb4_bin COMMENT '视频宽度',
  `video_height` text COLLATE utf8mb4_bin COMMENT '视频高度',
  `video_size` text COLLATE utf8mb4_bin COMMENT '视频大小',
  `description` text COLLATE utf8mb4_bin COMMENT '商品描述',
  `is_cod_allowed` text COLLATE utf8mb4_bin COMMENT '是否允许货到付款（COD）',
  `delivery_options` text COLLATE utf8mb4_bin COMMENT '配送选项',
  `external_product_id` text COLLATE utf8mb4_bin COMMENT '外部商品ID',
  `product_types` text COLLATE utf8mb4_bin COMMENT '商品类型',
  `is_not_for_sale` text COLLATE utf8mb4_bin COMMENT '是否禁售',
  `recommended_categories` text COLLATE utf8mb4_bin COMMENT '推荐分类',
  `manufacturer_ids` text COLLATE utf8mb4_bin COMMENT '制造商ID',
  `is_pre_owned` text COLLATE utf8mb4_bin COMMENT '是否为二手商品',
  `product_attributes` text COLLATE utf8mb4_bin COMMENT '商品属性',
  `audit_failed_reasons` text COLLATE utf8mb4_bin COMMENT '审核失败原因',
  `responsible_person_ids` text COLLATE utf8mb4_bin COMMENT '负责人ID',
  `listing_quality_tier` text COLLATE utf8mb4_bin COMMENT 'Listing质量等级',
  `integrated_platform_statuses` text COLLATE utf8mb4_bin COMMENT '集成平台状态',
  `shipping_insurance_requirement` text COLLATE utf8mb4_bin COMMENT '运费险要求',
  `minimum_order_quantity` text COLLATE utf8mb4_bin COMMENT '最小订购数量',
  `audit_status` text COLLATE utf8mb4_bin COMMENT '审核状态',
  `package_dimensions_height` text COLLATE utf8mb4_bin COMMENT '包裹尺寸-高度',
  `package_dimensions_length` text COLLATE utf8mb4_bin COMMENT '包裹尺寸-长度',
  `package_dimensions_unit` text COLLATE utf8mb4_bin COMMENT '包裹尺寸-单位',
  `package_dimensions_width` text COLLATE utf8mb4_bin COMMENT '包裹尺寸-宽度',
  `package_weight_unit` text COLLATE utf8mb4_bin COMMENT '包裹重量-单位',
  `package_weight_value` text COLLATE utf8mb4_bin COMMENT '包裹重量-数值',
  `size_chart_image_width` text COLLATE utf8mb4_bin COMMENT '尺码表图片-宽度',
  `size_chart_image_height` text COLLATE utf8mb4_bin COMMENT '尺码表图片-高度',
  `size_chart_image_thumb_urls` text COLLATE utf8mb4_bin COMMENT '尺码表图片-缩略图URL',
  `size_chart_image_uri` text COLLATE utf8mb4_bin COMMENT '尺码表图片-URI',
  `size_chart_image_urls` text COLLATE utf8mb4_bin COMMENT '尺码表图片-URL',
  `size_chart_template_id` text COLLATE utf8mb4_bin COMMENT '尺码表模板ID',
  `connectid` text COLLATE utf8mb4_bin COMMENT 'connectId（系统字段）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='ods_tiktok_自营商品维度信息';

-- ----------------------------
-- Table structure for ods_tiktok_self_prd_sku_dimension_info
-- ----------------------------
DROP TABLE IF EXISTS `ods_tiktok_self_prd_sku_dimension_info`;
CREATE TABLE `ods_tiktok_self_prd_sku_dimension_info` (
  `id` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'SKU ID',
  `shop_id` text COLLATE utf8mb4_bin COMMENT '店铺ID',
  `shop_name` text COLLATE utf8mb4_bin COMMENT '店铺名称',
  `product_id` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '商品ID',
  `update_time` text COLLATE utf8mb4_bin COMMENT '更新时间',
  `create_time` text COLLATE utf8mb4_bin COMMENT '创建时间',
  `seller_sku` text COLLATE utf8mb4_bin COMMENT '卖家SKU编码',
  `sales_attributes` text COLLATE utf8mb4_bin COMMENT '销售属性（如颜色、尺寸等）',
  `global_listing_policy_inventory_type` text COLLATE utf8mb4_bin COMMENT '全球Listing政策库存类型',
  `global_listing_policy_price_sync` text COLLATE utf8mb4_bin COMMENT '全球Listing政策价格同步',
  `identifier_code_type` text COLLATE utf8mb4_bin COMMENT '标识代码类型（如条形码类型）',
  `price_currency` text COLLATE utf8mb4_bin COMMENT '价格货币单位',
  `price_sale_price` text COLLATE utf8mb4_bin COMMENT '售价',
  `price_tax_exclusive_price` text COLLATE utf8mb4_bin COMMENT '不含税价格',
  `combined_skus` text COLLATE utf8mb4_bin COMMENT '组合SKU（捆绑销售的SKU组合）',
  `connectid` text COLLATE utf8mb4_bin COMMENT 'connectId（系统字段）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='ods_tiktok_自营商品sku维度信息';

-- ----------------------------
-- Table structure for oms_cart_item
-- ----------------------------
DROP TABLE IF EXISTS `oms_cart_item`;
CREATE TABLE `oms_cart_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `spu_id` bigint DEFAULT NULL COMMENT '商品id',
  `spu_code` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '商品编码',
  `spu_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '商品名称',
  `spu_type` int DEFAULT NULL COMMENT '商品类型【1:实物商品，2:虚拟商品】',
  `sku_id` bigint unsigned DEFAULT '0' COMMENT 'sku id',
  `sku_code` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku名称',
  `sku_extend` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku 扩展数据',
  `customer_id` bigint DEFAULT NULL COMMENT '客户id',
  `company_id` bigint unsigned DEFAULT '0' COMMENT '商品所属企业id',
  `customer_nickname` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '客户昵称',
  `quantity` int DEFAULT NULL COMMENT '购买数量',
  `price` decimal(10,2) DEFAULT NULL COMMENT '添加到购物车的价格',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `product_sn` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '商品条码',
  `product_attr` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '商品销售属性',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  `region_code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '' COMMENT '服务区域编码',
  `region_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '' COMMENT '服务区域名称',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_sku_id` (`sku_id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE,
  KEY `index_customer_id` (`customer_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1691995783659917313 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='购物车表';

-- ----------------------------
-- Table structure for oms_operate_log
-- ----------------------------
DROP TABLE IF EXISTS `oms_operate_log`;
CREATE TABLE `oms_operate_log` (
  `id` bigint NOT NULL,
  `operate_type` int DEFAULT NULL COMMENT '操作类型',
  `operate_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作类型名称',
  `operate_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作原因',
  `operate_time` datetime DEFAULT NULL COMMENT '操作时间',
  `operate_certificate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作凭证',
  `file_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '附件资料',
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单号',
  `purchase_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购单号',
  `operate_user_id` bigint DEFAULT NULL COMMENT '操作人id',
  `opereate_user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作人姓名',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效【0:无效，1:有效】',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除【0:未删除，1:已删除】',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_order
-- ----------------------------
DROP TABLE IF EXISTS `oms_order`;
CREATE TABLE `oms_order` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `operate_company_id` bigint DEFAULT NULL COMMENT '运营平台企业id',
  `customer_id` bigint DEFAULT '0' COMMENT '顾客id',
  `customer_company_id` bigint DEFAULT NULL COMMENT '客户企业ID',
  `trade_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易流水号【生成规则：10位 时间戳 + 6位随机数字】',
  `trade_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '等第三方支付平台的商户订单号',
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '订单号【企业ID后6位 + 10 位时间戳 + 6位随机数】',
  `operate_type` tinyint DEFAULT '1' COMMENT '订单运营方式【1:非自营（默认), 2:自营】',
  `order_type` tinyint DEFAULT '1' COMMENT '订单类型【1:采购订单，2:服务订单，3:FOB-OEM 订单，4: 委托服务订单】',
  `order_status` int DEFAULT '0' COMMENT '订单状态【-1：已取消；0:待付款，1:待发货，2:发货中，3:待收货，4:已收货，5:交易完成(待评价)，6:交易完成(已评价)，7:取消中，8:售后审核中，9:售后审核驳回，10:售后审核通过，11:买家退货中，12:二次审核通过，13:二次审核驳回，14:退款中，15:已完成】',
  `order_business_type` int DEFAULT '0' COMMENT '订单业务类型【0:担保交易订单，1:应收订单，2:应付订单】',
  `pay_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '应付总额',
  `original_order_amount` decimal(24,6) DEFAULT NULL COMMENT '原订单金额',
  `total_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '商品总额',
  `freight_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '运费金额',
  `promotion_amount` decimal(24,6) DEFAULT NULL COMMENT '优惠金额',
  `order_promotion_rate` decimal(24,6) DEFAULT NULL COMMENT '订单优惠比例',
  `sku_promotion_amount` decimal(24,6) DEFAULT NULL COMMENT '商品优惠金额',
  `freight_promotion_amount` decimal(24,6) DEFAULT NULL COMMENT '运费优惠金额',
  `order_service_rate` decimal(20,6) DEFAULT NULL COMMENT '订单服务费用比例',
  `total_quantity` int DEFAULT '0' COMMENT '商品sku总数',
  `source_type` int DEFAULT '0' COMMENT '订单来源[0:正常订单；1：内部转账虚拟单]',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `payment_days` int DEFAULT NULL COMMENT '支付账期',
  `pay_type` tinyint DEFAULT NULL COMMENT '支付方式【0:担保交易，1:分期，2:账期】',
  `pay_status` int DEFAULT NULL COMMENT '支付状态【0:未支付，1:已支付，2：部分支付，3：尾款待支付】',
  `qrcode_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '二维码唯一标识id',
  `qrcode_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '二维码地址',
  `refund_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '售后工单id',
  `refund_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '售后工单单号',
  `delivery_time` datetime DEFAULT NULL COMMENT '发货时间',
  `receive_time` datetime DEFAULT NULL COMMENT '确认收货时间',
  `comment_time` datetime DEFAULT NULL COMMENT '评价时间',
  `settle_amount` decimal(20,6) DEFAULT NULL COMMENT '结算金额',
  `settle_status` int DEFAULT NULL COMMENT '结算状态【0:未结算，1:已结算，2:结算失败】',
  `settle_time` datetime DEFAULT NULL COMMENT '结算时间',
  `settle_type` int DEFAULT '1' COMMENT '结算类型【1:月维度结算、2:订单维度结算】',
  `pay_method` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式【1:支付宝、2:微信、3:线上转账、4:线下转账】',
  `pay_method_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式名称',
  `order_commission_rate` float DEFAULT NULL COMMENT '订单分佣比例',
  `platform_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '平台分佣金额',
  `company_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '企业分佣金额',
  `cancel_status` int DEFAULT NULL COMMENT '订单取消状态【0:未取消，1:取消中，2:已取消】',
  `is_changed` tinyint DEFAULT NULL COMMENT '是否经过改价【0: 否，1: 是】',
  `is_refund` tinyint(3) unsigned zerofill DEFAULT NULL COMMENT '是否售后订单【0:否，1:是】',
  `production_mode` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '生产模式',
  `pay_remind` tinyint(1) DEFAULT '0' COMMENT '支付成功消息推送【0:否，1是】',
  `wait_pay_remind` tinyint(1) DEFAULT NULL COMMENT '待支付成功消息推送【0:否，1是】',
  `pay_setting_id` bigint DEFAULT NULL COMMENT '支付设置id',
  `last_pay_status` tinyint DEFAULT NULL COMMENT '尾款 （ 0 全部 1 已完结  2 未完结)',
  `close_date` datetime DEFAULT NULL COMMENT '关单时间',
  `close_status` int DEFAULT NULL COMMENT '关单状态【0:未申请，1:审批中，2:已关单，3：关单取消】',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '订单备注',
  `relation_order_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '关联订单流水号',
  `purchase_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购单流水号',
  `purchase_id` bigint DEFAULT NULL COMMENT '采购单id',
  `self_order_type` tinyint(1) DEFAULT NULL COMMENT '自营订单类型 1:供应商采购订单 2:平台订单',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE,
  KEY `index_customer_id` (`customer_id`) USING BTREE,
  KEY `inedx_order_sn` (`order_sn`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1713845298494836737 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='订单主表';

-- ----------------------------
-- Table structure for oms_order_census
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_census`;
CREATE TABLE `oms_order_census` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `customer_id` bigint DEFAULT '0' COMMENT '顾客id',
  `trade_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易流水号【生成规则：10位 时间戳 + 6位随机数字】',
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '订单号【企业ID后6位 + 10 位时间戳 + 6位随机数】',
  `order_amount` decimal(24,6) DEFAULT NULL COMMENT '订单金额',
  `spu_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '商品总额',
  `freight_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '运费金额',
  `promotion_amount` decimal(24,6) DEFAULT NULL COMMENT '优惠金额',
  `order_promotion_rate` decimal(24,6) DEFAULT NULL COMMENT '订单优惠比例',
  `spu_promotion_amount` decimal(24,6) DEFAULT NULL COMMENT '商品优惠金额',
  `freight_promotion_amount` decimal(24,6) DEFAULT NULL COMMENT '运费优惠金额',
  `total_quantity` int DEFAULT '0' COMMENT '商品总数',
  `confirm_quantity` int DEFAULT NULL COMMENT '已确认收货数量',
  `dispatch_quantity` int DEFAULT NULL COMMENT '已发货数量',
  `refund_quantity` int DEFAULT NULL COMMENT '已退商品总数',
  `refunding_quantity` int DEFAULT NULL COMMENT '售后中商品总数',
  `pay_amount` decimal(20,6) DEFAULT NULL COMMENT '已支付金额',
  `settle_amount` decimal(20,6) DEFAULT NULL COMMENT '已结算金额',
  `order_commission_rate` decimal(20,6) DEFAULT NULL COMMENT '订单分佣比例',
  `platform_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '平台分佣金额',
  `company_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '企业分佣金额',
  `platform_refund_amount` decimal(20,6) DEFAULT NULL COMMENT '平台已退款金额',
  `company_refund_amount` decimal(20,6) DEFAULT NULL COMMENT '企业已退款金额',
  `is_useful` tinyint(1) DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0:正常；1:已删除】',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE,
  KEY `index_customer_id` (`customer_id`) USING BTREE,
  KEY `inedx_order_sn` (`order_sn`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1713845298566139905 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_order_delivery
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_delivery`;
CREATE TABLE `oms_order_delivery` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `company_id` bigint DEFAULT NULL COMMENT '商家企业id',
  `delivery_type` int DEFAULT NULL COMMENT '物流类型1、发货单，2、退货单',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收货人电话',
  `receiver_post_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收货人邮编',
  `receiver_province` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省份/直辖市',
  `receiver_city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '城市',
  `receiver_region` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区',
  `receiver_detail_address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '详细地址',
  `delivery_status` int DEFAULT '0' COMMENT '物流状态【0->运输中；1->已收货】',
  `delivery_time` datetime DEFAULT NULL COMMENT '发货时间',
  `receive_time` datetime DEFAULT NULL COMMENT '确认收货时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1713845298536779777 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='订单物流记录表';

-- ----------------------------
-- Table structure for oms_order_delivery_item
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_delivery_item`;
CREATE TABLE `oms_order_delivery_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '订单编码',
  `dispatch_sn` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '发货单编号',
  `delivery_id` bigint DEFAULT NULL COMMENT '物流id',
  `delivery_item_type` tinyint DEFAULT NULL COMMENT '物流明细类型【1:实际物流，2:虚拟物流】',
  `delivery_abbreviation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '物流快递简码',
  `package_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '装箱单编码',
  `delivery_item_status` int DEFAULT NULL COMMENT '物流明细状态[0:未发货、1:已发货、2:运输中、3:已收货、4:拒绝收货、5:已退回、6:退货已收货  -1:已取消]',
  `delivery_sn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '物流单号',
  `delivery_company_id` bigint DEFAULT NULL COMMENT '物流公司id',
  `delivery_company_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '物流公司名称',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `company_id` bigint DEFAULT NULL,
  `delivery_manual_status` tinyint DEFAULT '0' COMMENT '手动确认物流明细状态[0:未发货、1:已发货、2:运输中、3:已收货、4:拒绝收货、5:已退回、6:退货已收货]',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_package_code` (`package_code`) USING BTREE,
  KEY `index_order_id` (`order_id`) USING BTREE,
  KEY `index_order_sn` (`order_sn`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1547065694124289464 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物流分包明细表';

-- ----------------------------
-- Table structure for oms_order_dispatch
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_dispatch`;
CREATE TABLE `oms_order_dispatch` (
  `id` bigint NOT NULL,
  `order_item_id` bigint DEFAULT NULL COMMENT 'order_item表id',
  `dispatch_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单号',
  `dispatch_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单名称',
  `dispatch_type` tinyint DEFAULT NULL COMMENT '发货单类型【1:物流发货，2:自发货】',
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `customer_id` bigint DEFAULT NULL COMMENT '顾客id',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `sku_num` int DEFAULT NULL COMMENT 'sku发货数量',
  `dispatch_status` tinyint DEFAULT NULL COMMENT '发货单状态(-1 已驳回 0 待审核 1 待支付 2 待发货 3 待收货 4 已收货 5 已结算',
  `dispatch_date` datetime DEFAULT NULL COMMENT '发货时间',
  `received_date` datetime DEFAULT NULL COMMENT '签收时间',
  `receivable_quantity` int DEFAULT NULL COMMENT '应收数量',
  `receivable_amount` decimal(20,6) DEFAULT NULL COMMENT '应收金额',
  `received_quantity` int DEFAULT NULL COMMENT '实收数量',
  `received_amount` decimal(20,6) DEFAULT NULL COMMENT '实收金额',
  `account_dispatch_status` tinyint DEFAULT '0' COMMENT '支付状态( 0 默认 1 待结账  2 待支付 3 已支付 ）',
  `account_period_date` datetime DEFAULT NULL COMMENT '账期统计时间',
  `operate_type` int DEFAULT '1' COMMENT '运营类型【1:非自营，2:自营】',
  `pay_type` tinyint DEFAULT NULL COMMENT '支付方式【0:担保交易，1:分期，2:账期】',
  `order_type` tinyint DEFAULT NULL COMMENT '订单类型【1:采购订单，2:服务订单，3:FOB-OEM 订单，4: 委托服务订单】',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT '1',
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `self_dispatch_status` tinyint DEFAULT NULL COMMENT '发货单状态(-1 已驳回 0 待审核 1 待支付 2 待发货 3 待收货 4 已收货 5 已结算',
  `relation_dispatch_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '关联发货单流水号',
  `self_dispatch_type` tinyint(1) DEFAULT NULL COMMENT '自营发货单类型【 1:采购发货单 2:订单发货单】',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_dispatch_sn` (`dispatch_sn`) USING BTREE,
  KEY `index_order_id` (`order_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='发货单';

-- ----------------------------
-- Table structure for oms_order_dispatch_item
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_dispatch_item`;
CREATE TABLE `oms_order_dispatch_item` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `dispatch_id` bigint DEFAULT NULL COMMENT '发货单id',
  `dispatch_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单号',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `order_item_id` bigint DEFAULT NULL COMMENT '订单明细id',
  `spu_id` bigint DEFAULT NULL COMMENT '商品id',
  `spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu编码',
  `spu_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu名称',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku名称',
  `sku_url` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku地址',
  `sku_num` int DEFAULT NULL COMMENT 'sku数量',
  `receipt_num` int DEFAULT NULL COMMENT '实收sku数量',
  `receipt_status` int DEFAULT NULL COMMENT '收货状态【0:未收货，1：部分收货，2:全部收货】',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT '1',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `dispatch_status` tinyint DEFAULT NULL COMMENT '发货单状态(-1 已驳回 0 待审核 1 待支付 2 待发货 3 待收货 4 已收货 5 已结算',
  `sku_purchase_num` int DEFAULT NULL COMMENT '订单采购数量',
  `sku_price` decimal(10,2) DEFAULT NULL COMMENT 'sku价格',
  `expect_deliver_date` datetime DEFAULT NULL COMMENT '期望交付时间',
  `sku_total_num` int DEFAULT NULL COMMENT '应交付总数量',
  `sku_received_quantity` int DEFAULT NULL,
  `receipt_price` decimal(10,2) DEFAULT NULL COMMENT '实收金额',
  `sku_receivable_amount` decimal(10,2) DEFAULT NULL COMMENT '应收金额',
  `sku_settle_price` decimal(10,2) DEFAULT NULL COMMENT '供应商sku结算价格',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_dispatch_sn` (`dispatch_sn`) USING BTREE,
  KEY `index_order_id` (`order_id`) USING BTREE,
  KEY `index_product_id` (`spu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='发货单明细';

-- ----------------------------
-- Table structure for oms_order_dispatch_verify
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_dispatch_verify`;
CREATE TABLE `oms_order_dispatch_verify` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `customer_id` bigint DEFAULT '0' COMMENT '顾客id',
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '订单号【企业ID后6位 + 10 位时间戳 + 6位随机数】',
  `dispatch_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单号',
  `verify_type` int DEFAULT NULL COMMENT '审批类型【0】',
  `verify_status` int DEFAULT NULL COMMENT '审批状态【0:未审批、1:审批通过，2:审批未通过】',
  `verify_time` datetime DEFAULT NULL COMMENT '审批时间',
  `verify_history_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '审批历史数据',
  `goods_amount` decimal(24,6) DEFAULT NULL COMMENT '商品金额',
  `pre_receive_amount` decimal(24,6) DEFAULT NULL COMMENT '预收货款',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `operate_by` bigint DEFAULT NULL COMMENT '运营端操作人员',
  `operate_time` datetime DEFAULT NULL COMMENT '运营端操作时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '审批备注',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE,
  KEY `index_customer_id` (`customer_id`) USING BTREE,
  KEY `inedx_order_sn` (`order_sn`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_order_finish_verify
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_finish_verify`;
CREATE TABLE `oms_order_finish_verify` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `customer_id` bigint DEFAULT '0' COMMENT '顾客id',
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '订单号【企业ID后6位 + 10 位时间戳 + 6位随机数】',
  `verify_type` int DEFAULT NULL COMMENT '审批类型【0】',
  `verify_status` int DEFAULT NULL COMMENT '审批状态【0:审批中、1:审批通过，2:审批未通过】',
  `verify_time` datetime DEFAULT NULL COMMENT '审批时间',
  `verify_history_data` json DEFAULT NULL COMMENT '审批历史数据（运营端展示数据）',
  `deliver_history_data` json DEFAULT NULL COMMENT '关单历史数据（商家端展示数据）',
  `receivable_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '应收货物总金额',
  `pay_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '已支付金额',
  `freight_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '额外运费',
  `subsidy_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '额外补贴',
  `advance_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '最终预收货款',
  `service_receivable_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '服务费应收货物总金额',
  `service_pay_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '服务费已支付金额',
  `service_advance_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '服务费最终预收货款',
  `settle_deadline` datetime DEFAULT NULL COMMENT '回款截止时间',
  `self_finish_type` tinyint(1) DEFAULT NULL COMMENT '订单关单类型 1:供应商关单 2:平台关单订单',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `operate_by` bigint DEFAULT NULL COMMENT '运营端操作人员',
  `operate_time` datetime DEFAULT NULL COMMENT '运营端操作时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '审批备注',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE,
  KEY `index_customer_id` (`customer_id`) USING BTREE,
  KEY `inedx_order_sn` (`order_sn`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_order_history
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_history`;
CREATE TABLE `oms_order_history` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `spu_id` bigint DEFAULT NULL COMMENT '商品id',
  `spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品编码',
  `spu_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `spu_type` int DEFAULT NULL COMMENT '商品类型【1:实物商品，2:虚拟商品】',
  `spu_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品货号',
  `spu_attr` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品销售属性',
  `company_id` bigint unsigned DEFAULT '0' COMMENT '商品所属企业id',
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品图片地址',
  `spu_extend` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品扩展数据',
  `customer_id` bigint DEFAULT NULL COMMENT '客户id',
  `customer_nickname` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '客户昵称',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_delete` int DEFAULT '0' COMMENT '是否删除',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1684947624941195267 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_order_installment
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_installment`;
CREATE TABLE `oms_order_installment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `customer_id` bigint DEFAULT '0' COMMENT '顾客id',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '订单号【企业ID后6位 + 10 位时间戳 + 6位随机数】',
  `pay_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第三方支付渠道支付流水号',
  `order_type` int DEFAULT '1' COMMENT '订单类型【1:采购订单，2:服务订单】',
  `order_status` int DEFAULT '0' COMMENT '订单明细状态【-1：已取消；0:待付款，1:待发货，2:发货中，3:待收货，4:已收货，5:交易完成(待评价)，6:交易完成(已评价)，7:取消中，8:售后审核中，9:售后审核驳回，10:售后审核通过，11:买家退货中，12:二次审核通过，13:二次审核驳回，14:退款中，15:已完成】',
  `installment_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分期流水号',
  `installment_number` int DEFAULT NULL COMMENT '当前分期期数',
  `installment_amount` decimal(20,6) DEFAULT NULL COMMENT '当前分期应付总额',
  `paid_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '已支付总额',
  `spu_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '商品总额',
  `freight_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '运费金额',
  `promotion_amount` decimal(24,6) DEFAULT NULL COMMENT '优惠金额',
  `pay_method` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式【1:支付宝、2:微信、3:线上转账、4:线下转账】',
  `pay_method_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式名称',
  `order_commission_rate` float DEFAULT NULL COMMENT '订单分佣比例',
  `platform_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '平台分佣金额',
  `company_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '企业分佣金额',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE,
  KEY `index_customer_id` (`customer_id`) USING BTREE,
  KEY `inedx_order_sn` (`order_sn`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='订单分期记录表';

-- ----------------------------
-- Table structure for oms_order_item
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_item`;
CREATE TABLE `oms_order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '订单编号',
  `order_status` int DEFAULT NULL COMMENT '订单明细状态【-1：已取消；0:待付款，1:待发货，2:发货中，3:待收货，4:已收货，5:交易完成(待评价)，6:交易完成(已评价)，7:取消中，8:退货审核中，9:审核失败，10:审核成功，11:退款中，12:退款成功】',
  `trade_sn` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '交易流水号【复用订单主表】',
  `base_price` decimal(24,6) DEFAULT NULL COMMENT '销售价格',
  `ladder_price` decimal(24,6) DEFAULT NULL COMMENT '阶梯价格',
  `delivery_num` int unsigned DEFAULT '0' COMMENT '发货数量',
  `real_price` decimal(24,6) DEFAULT NULL COMMENT '该商品经过优惠后的分解金额',
  `spu_id` bigint unsigned DEFAULT '0' COMMENT '商品id',
  `spu_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'spu编码',
  `spu_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '商品名称',
  `spu_commission_rate` decimal(20,4) DEFAULT NULL COMMENT '商品分佣比例',
  `sku_id` bigint unsigned DEFAULT '0' COMMENT 'sku id',
  `sku_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku 编码',
  `custom_code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT 'sku自定义编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku名称',
  `sku_num` int DEFAULT NULL COMMENT '购买数量',
  `sku_url` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku图片地址',
  `region_code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '服务区域编码',
  `region_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '服务区域名称',
  `promotion_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '商品促销名称',
  `promotion_price` decimal(24,6) DEFAULT NULL COMMENT '商品促销分解金额',
  `promotion_num` int DEFAULT NULL COMMENT '商品促销分解数量',
  `wm_sku_price` decimal(24,6) DEFAULT NULL COMMENT '加权平均商品金额',
  `wm_freight_price` decimal(24,6) DEFAULT NULL COMMENT '加权平均运费金额',
  `wm_promotion_price` decimal(24,6) DEFAULT NULL COMMENT '加权平均促销金额',
  `wm_sku_promotion_price` decimal(24,6) DEFAULT NULL COMMENT '加权平均商品促销金额',
  `wm_freight_promotion_price` decimal(24,6) DEFAULT NULL COMMENT '加权平均运费促销金额',
  `product_sale_attr` json DEFAULT NULL COMMENT '商品销售属性快照',
  `product_sku_attr` json DEFAULT NULL COMMENT '商品基本属性快照',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  `code_number` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '货号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_order_id` (`order_id`) USING BTREE,
  KEY `index_order_sn` (`order_sn`) USING BTREE,
  KEY `index_sku_id` (`sku_id`) USING BTREE,
  KEY `index_sku_code` (`sku_code`) USING BTREE,
  KEY `index_spu_id` (`spu_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1713845298520002562 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='订单中所包含的商品';

-- ----------------------------
-- Table structure for oms_order_package
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_package`;
CREATE TABLE `oms_order_package` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `package_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '装箱单编码',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '订单编号',
  `dispatch_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '发货单编码【多个编码逗号隔开】',
  `product_sale_attr` json DEFAULT NULL COMMENT '商品销售数据',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `sku_total` int DEFAULT NULL COMMENT 'sku总数目',
  `deliver_goods_total` int DEFAULT NULL COMMENT '发货总件数',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_dispatch_code` (`dispatch_code`) USING BTREE,
  KEY `index_package_code` (`package_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1713846956515790849 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='装箱单\r\n';

-- ----------------------------
-- Table structure for oms_order_package_item
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_package_item`;
CREATE TABLE `oms_order_package_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `package_id` bigint DEFAULT NULL COMMENT '装箱单id',
  `package_sn` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '装箱单编码',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '订单编号',
  `dispatch_id` bigint DEFAULT NULL COMMENT '发货单id',
  `dispatch_sn` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '发货单编码',
  `spu_code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'spu编码',
  `spu_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'spu名称',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku名称',
  `sku_url` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku地址',
  `sku_num` int DEFAULT NULL COMMENT 'sku发货数量',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `order_item_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_dispatch_code` (`dispatch_sn`) USING BTREE,
  KEY `index_package_code` (`package_sn`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3097 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='装箱单明细\r\n';

-- ----------------------------
-- Table structure for oms_order_period
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_period`;
CREATE TABLE `oms_order_period` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `customer_id` bigint DEFAULT '0' COMMENT '顾客id',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '订单号【企业ID后6位 + 10 位时间戳 + 6位随机数】',
  `pay_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第三方支付渠道支付流水号',
  `order_type` int DEFAULT '1' COMMENT '订单类型【1:采购订单，2:服务订单】',
  `order_status` int DEFAULT '0' COMMENT '订单明细状态【-1：已取消；0:待付款，1:待发货，2:发货中，3:待收货，4:已收货，5:交易完成(待评价)，6:交易完成(已评价)，7:取消中，8:售后审核中，9:售后审核驳回，10:售后审核通过，11:买家退货中，12:二次审核通过，13:二次审核驳回，14:退款中，15:已完成】',
  `period_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '账期流水号',
  `period_number` int DEFAULT NULL COMMENT '当前账期期数',
  `period_amount` decimal(20,6) DEFAULT NULL COMMENT '账期应付总额',
  `paid_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '已支付总额',
  `spu_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '商品总额',
  `freight_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '运费金额',
  `promotion_amount` decimal(24,6) DEFAULT NULL COMMENT '优惠金额',
  `pay_method` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式【1:支付宝、2:微信、3:线上转账、4:线下转账】',
  `pay_method_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式名称',
  `order_commission_rate` float DEFAULT NULL COMMENT '订单分佣比例',
  `platform_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '平台分佣金额',
  `company_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '企业分佣金额',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE,
  KEY `index_customer_id` (`customer_id`) USING BTREE,
  KEY `inedx_order_sn` (`order_sn`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_order_purchase
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_purchase`;
CREATE TABLE `oms_order_purchase` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '供应商id',
  `company_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商家名称',
  `operate_company_id` bigint DEFAULT NULL COMMENT '自运营平台id',
  `customer_id` bigint DEFAULT '0' COMMENT '顾客id',
  `customer_company_id` bigint DEFAULT NULL COMMENT '客户企业ID',
  `purchase_type` int DEFAULT '1' COMMENT '采购单类型【1:分期采购单，2:账期采购单】',
  `operate_type` tinyint DEFAULT '1' COMMENT '运营类型【1:非自营，2:自营】',
  `purchase_status` int DEFAULT '0' COMMENT '采购单状态【-1：已取消；0:未确认，1:已确认】',
  `order_amount` decimal(24,6) DEFAULT NULL COMMENT '订单金额',
  `total_quantity` int DEFAULT '0' COMMENT '商品sku总数',
  `source_type` int DEFAULT '0' COMMENT '订单来源[0: 正常采购单；1：内部转账单]',
  `pay_type` int DEFAULT NULL COMMENT '支付类型',
  `order_commission_rate` float DEFAULT NULL COMMENT '订单分佣比例',
  `order_service_rate` decimal(10,2) DEFAULT NULL COMMENT '订单服务费用比例',
  `spu_id` bigint DEFAULT NULL COMMENT '商品id',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `spu_attribute_data` json DEFAULT NULL COMMENT '商品规则属性',
  `sku_data` json DEFAULT NULL COMMENT 'sku json 数据',
  `customer_receive_address_id` bigint DEFAULT NULL COMMENT '客户收货地址id',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '订单备注',
  `useful_model` tinyint DEFAULT NULL COMMENT '是否有样衣 0 否 1是',
  `model_provide` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '样衣提供方',
  `pay_setting_id` bigint DEFAULT NULL COMMENT '支付设置id',
  `order_rfq_id` bigint DEFAULT NULL COMMENT '询价单id',
  `order_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单编号',
  `purchase_sn` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购单编号',
  `follower` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '跟单员',
  `production_mode` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '生产模式',
  `customer_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `customer_phone` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `order_service_amount` decimal(20,6) DEFAULT NULL COMMENT '订单服务费',
  `spu_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `trade_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '流水号',
  `order_id` bigint DEFAULT NULL,
  `expect_deliver_date` datetime DEFAULT NULL COMMENT '期望交付时间',
  `salesman_id` bigint DEFAULT NULL COMMENT '销售员id',
  `salesman_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '销售员姓名',
  `merchandiser_id` bigint DEFAULT NULL COMMENT '跟单员id',
  `merchandiser_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '跟单员姓名',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE,
  KEY `index_customer_id` (`customer_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1713845297085550593 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_order_remit
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_remit`;
CREATE TABLE `oms_order_remit` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `remit_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收货单流水号',
  `remit_order_type` tinyint DEFAULT '1' COMMENT '结算订单类型 3:生产订单 4:委托服务订单',
  `remit_amount` decimal(24,6) DEFAULT NULL COMMENT '打款金额',
  `remit_user_id` bigint DEFAULT NULL COMMENT '打款用户',
  `remit_status` int DEFAULT NULL COMMENT '打款状态【0:未打款，1:已打款，2:打款失败】',
  `remit_date` datetime DEFAULT NULL COMMENT '打款时间',
  `remit_object_num` int DEFAULT NULL COMMENT '打款方数量',
  `remit_phase` tinyint DEFAULT NULL COMMENT '分期/账期支付阶段 1:首付款 2:货款 3:尾款 4:账期',
  `settle_type` int DEFAULT NULL COMMENT '结算类型【1:正向交易，2:负向交易】',
  `dispatch_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单号',
  `purchase_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购单单号',
  `pay_summary_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付汇总单号',
  `pay_amount` decimal(24,6) DEFAULT NULL COMMENT '支付金额',
  `platform_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '平台分佣金额',
  `company_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '企业分佣金额',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_dispatch_sn` (`remit_sn`) USING BTREE,
  KEY `index_order_id` (`order_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='打款记录表';

-- ----------------------------
-- Table structure for oms_order_remit_item
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_remit_item`;
CREATE TABLE `oms_order_remit_item` (
  `id` bigint NOT NULL,
  `remit_id` bigint DEFAULT NULL COMMENT '应付账款记录id',
  `customer_id` bigint DEFAULT NULL COMMENT '买家id',
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `receipt_id` bigint DEFAULT NULL COMMENT '收货单id',
  `receipt_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收货单流水号',
  `spu_id` bigint DEFAULT NULL COMMENT '商品id',
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu编码',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu名称',
  `spu_commission_rate` decimal(20,0) DEFAULT NULL COMMENT '商品分佣比例',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku名称',
  `sku_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku地址',
  `sku_num` int DEFAULT NULL COMMENT 'sku数量',
  `sku_price` decimal(20,6) DEFAULT NULL COMMENT 'sku 单价',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_order_id` (`order_id`) USING BTREE,
  KEY `index_product_id` (`spu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='打款明细记录';

-- ----------------------------
-- Table structure for oms_order_rfq
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_rfq`;
CREATE TABLE `oms_order_rfq` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `customer_id` bigint DEFAULT '0' COMMENT '顾客id',
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `rfq_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '询价单号',
  `rfq_order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '询价单关联订单号',
  `rfq_content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '询价内容',
  `rfq_status` int DEFAULT '0' COMMENT '询价单状态【-1：已取消；0:待确认，1:已确认，2:已作废】',
  `rfq_communicate_status` int DEFAULT NULL COMMENT '运营沟通状态【-1：已取消；0:待确认，1:已接单，2:已拒单】',
  `rfq_files` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '询价单附件',
  `rfq_picture` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '询价单图片',
  `rfq_time` datetime DEFAULT NULL COMMENT '询价时间',
  `pay_type` int DEFAULT NULL COMMENT '支付方式',
  `spu_id` bigint DEFAULT NULL COMMENT '商品id',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `sku_data` json DEFAULT NULL COMMENT 'sku json 数据',
  `spu_attribute_data` json DEFAULT NULL COMMENT '商品规则属性',
  `order_commission_rate` decimal(10,2) DEFAULT NULL COMMENT '订单分佣比例',
  `order_service_rate` decimal(10,2) DEFAULT NULL COMMENT '委托服务比例',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '询价单备注',
  `code_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE,
  KEY `index_customer_id` (`customer_id`) USING BTREE,
  KEY `inedx_rfq_sn` (`rfq_sn`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1689052811872047105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_order_service_info
-- ----------------------------
DROP TABLE IF EXISTS `oms_order_service_info`;
CREATE TABLE `oms_order_service_info` (
  `id` bigint NOT NULL COMMENT '主键id',
  `order_id` bigint DEFAULT '0' COMMENT '订单id',
  `order_sn` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '' COMMENT '订单编号',
  `service_object` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '服务对象',
  `service_object_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '服务对象编号',
  `customer_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '买家备注',
  `customer_attachment` json DEFAULT NULL COMMENT '买家附件',
  `service_report` json DEFAULT NULL COMMENT '服务报告',
  `is_useful` tinyint NOT NULL DEFAULT '1' COMMENT '是否有效【0：无效，1：有效】',
  `is_delete` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：【0-未删除, 1-已删除】',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_user` bigint NOT NULL DEFAULT '0' COMMENT '更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_order_id` (`order_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='订单服务信息表';

-- ----------------------------
-- Table structure for oms_pay_bill
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_bill`;
CREATE TABLE `oms_pay_bill` (
  `id` bigint NOT NULL COMMENT 'id',
  `bill_sn` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '账单号',
  `bill_type` int DEFAULT NULL COMMENT '账单模式【1:单周，2:双周，3:月结，4:自定义】',
  `summary_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '汇总账单号',
  `pay_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '外部支付流水号',
  `pay_phase` tinyint DEFAULT NULL COMMENT '分期/账期支付阶段 1:首付款 2:货款 3:尾款 4:账期',
  `pay_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '应付总额',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `pay_type` int DEFAULT NULL COMMENT '支付方式【1:分期，2：账期】',
  `pay_status` int DEFAULT '0' COMMENT '支付状态【0:未申请、1:审批中、2:已付款、3:已取消、4:打款失败、5:已驳回】',
  `pay_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式：微信扫码，WECHAT_NATIVE，支付宝：ALIPAY_NATIVE，线下转账：LZB',
  `pay_rate` decimal(10,2) DEFAULT NULL COMMENT '支付比例',
  `settle_type` int DEFAULT '1' COMMENT '阶段类型【1:周期结算、2:订单结算】',
  `settle_status` int DEFAULT NULL COMMENT '结算状态【0:待结算、1:已结算】',
  `purchase_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购单单号',
  `order_id` bigint DEFAULT NULL COMMENT '订单ID',
  `order_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `dispatch_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单单号',
  `operate_company_id` bigint DEFAULT NULL COMMENT '运营方企业id',
  `company_id` bigint DEFAULT NULL COMMENT '供应商id',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有效【1、有效；0、无效】',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime(3) DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_pay_bill_summary
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_bill_summary`;
CREATE TABLE `oms_pay_bill_summary` (
  `id` bigint NOT NULL COMMENT 'id',
  `operate_company_id` bigint DEFAULT NULL COMMENT '运营方企业id',
  `company_id` bigint DEFAULT NULL COMMENT '供应商id',
  `summary_sn` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '汇总账单号',
  `summary_type` int DEFAULT NULL COMMENT '汇总账单模式【1:分期，2:账期】',
  `company_show_status` tinyint DEFAULT '0' COMMENT '供应商是否展示',
  `pay_type` int DEFAULT '1' COMMENT '支付类型【1:供应商结算，2:内部转账】',
  `pay_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '外部支付流水号',
  `payable_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '应付总额',
  `reward_punish_amount` decimal(24,6) DEFAULT NULL COMMENT '奖惩总额',
  `expected_amount` decimal(24,6) DEFAULT NULL COMMENT '预估金额',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `pay_status` int DEFAULT '0' COMMENT '支付状态【0:未申请、1:审批中、2:已付款、3:已取消、4:打款失败、5:已驳回】',
  `pay_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式：微信扫码，WECHAT_NATIVE，支付宝：ALIPAY_NATIVE，线下转账：LZB',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '补扣款描述',
  `settle_status` int DEFAULT NULL COMMENT '结算状态【0:待结算、1:已结算】',
  `settle_date` datetime DEFAULT NULL COMMENT '结算时间',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有效【1、有效；0、无效】',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime(3) DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime(3) DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='应付账单汇总表';

-- ----------------------------
-- Table structure for oms_pay_history
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_history`;
CREATE TABLE `oms_pay_history` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `pay_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '外部支付流水号',
  `pay_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '应付总额',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `pay_type` int DEFAULT NULL COMMENT '支付方式【1-->银联】',
  `pay_status` int DEFAULT NULL COMMENT '支付状态',
  `confirm_time` datetime DEFAULT NULL COMMENT '确认时间',
  `pay_subject` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '交易内容',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='支付信息表';

-- ----------------------------
-- Table structure for oms_pay_offline
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_offline`;
CREATE TABLE `oms_pay_offline` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `operate_company_id` bigint DEFAULT NULL COMMENT '运营平台ID',
  `combined_pay_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合并支付流水号',
  `pay_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '外部收款流水号',
  `pay_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '应收总额',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `pay_subject` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '交易内容',
  `file_url` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件地址',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有效【1、有效；0、无效】',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='线下收款记录表';

-- ----------------------------
-- Table structure for oms_pay_record
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_record`;
CREATE TABLE `oms_pay_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `operate_company_id` bigint DEFAULT NULL COMMENT '运营平台ID',
  `combined_pay_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合并支付流水号',
  `trade_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易流水号【生成规则：T + 6位 时间戳 + 6位随机数字】',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `dispatch_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单号',
  `pay_summary_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付汇总单号',
  `pay_order_type` tinyint DEFAULT '1' COMMENT '支付订单类型 1:普通订单 2:服务订单 3: FOB 订单 4:委托服务订单',
  `pay_phase` tinyint DEFAULT NULL COMMENT '分期/账期支付阶段 1:首付款 2:货款 3:尾款 4:账期',
  `pay_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '支付流水号',
  `pay_no` varbinary(128) DEFAULT NULL COMMENT '外部支付流水号',
  `pay_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '应收总额',
  `pay_ratio` decimal(10,2) DEFAULT NULL COMMENT '支付比例',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `pay_type` int DEFAULT NULL COMMENT '支付方式【1:分期、2:账期】',
  `pay_status` int DEFAULT NULL COMMENT '支付状态【0:未支付，1:已支付，2：支付失败】',
  `settle_type` int DEFAULT '1' COMMENT '结算类型【1:周期结算、2:订单结算】',
  `settle_status` int DEFAULT NULL COMMENT '结算状态【0:未结算、1:结算中、2:已结算】',
  `settle_time` datetime DEFAULT NULL COMMENT '结算时间',
  `pay_subject` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '交易内容',
  `collection_date` datetime DEFAULT NULL COMMENT '回款时间',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效【1、有效；0、无效】',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `self_pay_type` tinyint(1) DEFAULT NULL COMMENT '自营订单支付类型 1:供应商订单支付 2:平台订单支付',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1713847866226774017 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='应收账款明细表';

-- ----------------------------
-- Table structure for oms_pay_refund
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_refund`;
CREATE TABLE `oms_pay_refund` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `company_id` bigint DEFAULT NULL COMMENT '商家id',
  `original_trade_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源订单交易流水号',
  `original_order_id` bigint DEFAULT NULL COMMENT '源订单id',
  `original_order_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源订单单号',
  `source_pay_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源订单/发货单支付单单号',
  `source_remit_txn_seqno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源订单/发货单结算打款单号',
  `original_total_amount` decimal(20,6) DEFAULT NULL COMMENT '源支付单支付总金额',
  `refund_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退款单号',
  `refund_status` int DEFAULT '0' COMMENT '退款状态，0待退款，1已退款',
  `refund_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退款时间YYYYMMDD',
  `refund_total_amount` decimal(20,6) DEFAULT NULL COMMENT '退款总金额',
  `platform_commission_refund_amount` decimal(20,6) DEFAULT NULL COMMENT '平台分佣退款金额',
  `company_commission_refund_amount` decimal(20,6) DEFAULT NULL COMMENT '企业分佣退款金额',
  `refund_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退款原支付方式',
  `refund_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '退款原因',
  `ret_code` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '结果CODE',
  `ret_msg` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '结果描述',
  `accp_txno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1661744562563059713 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_pay_reward_punish_record
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_reward_punish_record`;
CREATE TABLE `oms_pay_reward_punish_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `business_type` int DEFAULT NULL COMMENT '业务类型【1:应付账款，2:应收账款】',
  `summary_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '汇总账单流水号',
  `trade_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易流水号',
  `order_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `dispatch_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单号',
  `company_id` bigint DEFAULT NULL COMMENT '供应商企业id',
  `purchase_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购单号',
  `operate_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作流水号',
  `operate_time` datetime DEFAULT NULL COMMENT '支付时间',
  `operate_status` int DEFAULT NULL COMMENT '操作状态【0: 未执行，1：已处理，2：已补扣款】',
  `operate_description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作说明',
  `pay_phase` tinyint DEFAULT NULL COMMENT '分期/账期支付阶段 1:首付款 2:货款 3:尾款 4:账期',
  `operate_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '奖励处罚金额',
  `operate_type` tinyint DEFAULT '1' COMMENT '操作类型 1:奖励 2:处罚',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效【1、有效；0、无效】',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1692478380747919361 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_pay_setting
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_setting`;
CREATE TABLE `oms_pay_setting` (
  `id` bigint NOT NULL,
  `pay_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式编码',
  `pay_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式名称',
  `pay_type` int DEFAULT NULL COMMENT '支付类型(1:分期，2:账期)',
  `pay_installment_num` int DEFAULT NULL COMMENT '分期次数',
  `settle_type` int DEFAULT '1' COMMENT '结算类型【1:周期结算、2:订单结算】',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='支付方式设置表';

-- ----------------------------
-- Table structure for oms_pay_setting_accredit
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_setting_accredit`;
CREATE TABLE `oms_pay_setting_accredit` (
  `id` bigint NOT NULL,
  `pay_setting_id` bigint DEFAULT NULL COMMENT '支付方式id',
  `object_id` bigint DEFAULT NULL COMMENT '授权对象id',
  `object_type` int DEFAULT NULL COMMENT '授权对象类型【1:买家，2:卖家】',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='支付方式授权表';

-- ----------------------------
-- Table structure for oms_pay_setting_item
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_setting_item`;
CREATE TABLE `oms_pay_setting_item` (
  `id` bigint NOT NULL,
  `pay_setting_id` bigint DEFAULT NULL COMMENT '支付设置id',
  `pay_item_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式明细编码',
  `pay_item_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式明细名称',
  `pay_type` int DEFAULT NULL COMMENT '支付类型: 1.定金; 2.货款; 3.尾款; 4.账期',
  `pay_days` int DEFAULT NULL COMMENT '支付账期(1:单周 2:双周 3:月)',
  `pay_rate` decimal(20,2) DEFAULT NULL COMMENT '支付比例',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `pay_days_time` date DEFAULT NULL COMMENT '支付账期日-根据结算周期和订单账期推算得出',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='支付方式设置明细';

-- ----------------------------
-- Table structure for oms_pay_summary
-- ----------------------------
DROP TABLE IF EXISTS `oms_pay_summary`;
CREATE TABLE `oms_pay_summary` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `operate_company_id` bigint DEFAULT NULL COMMENT '运营企业ID',
  `combined_pay_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合并支付流水号',
  `pay_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '支付流水号',
  `pay_no` varbinary(128) DEFAULT NULL COMMENT '外部支付流水号',
  `pay_phase` tinyint DEFAULT NULL COMMENT '分期/账期支付阶段 1:首付款 2:货款 3:尾款 4:账期 5:混合模式',
  `pay_amount` decimal(24,6) DEFAULT '0.000000' COMMENT '应付总额',
  `original_pay_amount` decimal(24,6) DEFAULT NULL COMMENT '原应付金额',
  `reward_punish_amount` decimal(24,6) DEFAULT NULL COMMENT '惩奖金额',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `pay_type` int DEFAULT NULL COMMENT '支付方式【1:银联】',
  `pay_status` int DEFAULT NULL COMMENT '支付状态【0:未支付、1:已支付、2:支付失败】',
  `pay_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付方式：微信扫码，WECHAT_NATIVE，支付宝：ALIPAY_NATIVE，线下转账：LZB, 线下转账：OFFLINE',
  `settle_status` int DEFAULT NULL COMMENT '结算状态【0:未结算，1:结算中，2:已结算】',
  `settle_time` datetime DEFAULT NULL COMMENT '结算时间',
  `link_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付链接地址',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '补扣款描述',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效【1、有效；0、已取消；-1: 已作废】',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1712010592560222209 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_purchase_transfer
-- ----------------------------
DROP TABLE IF EXISTS `oms_purchase_transfer`;
CREATE TABLE `oms_purchase_transfer` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `transfer_sn` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '转账单编号',
  `transfer_type` int DEFAULT '1' COMMENT '转账单类型【1:内部转账单，2:外部转账单】',
  `transfer_status` int DEFAULT '0' COMMENT '转账单状态【0:未确认，1:已确认】',
  `payer_company_id` bigint DEFAULT NULL COMMENT '付款运营平台ID',
  `payee_company_id` bigint DEFAULT NULL COMMENT '收款运营平台ID',
  `purchase_id` bigint DEFAULT NULL COMMENT '采购单id',
  `purchase_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购单编码',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单编号',
  `pay_status` int DEFAULT NULL COMMENT '转账状态【0:未支付，1:已支付，2:支付失败】',
  `pay_date` datetime DEFAULT NULL COMMENT '转账到账时间',
  `pay_amount` decimal(24,6) DEFAULT NULL COMMENT '转账金额',
  `total_quantity` int DEFAULT '0' COMMENT '商品总数',
  `spu_data` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品数据',
  `sku_data` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku 数据',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `create_by` bigint unsigned DEFAULT '0',
  `update_by` bigint unsigned DEFAULT '0',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '订单备注',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='内部转账虚拟采购表';

-- ----------------------------
-- Table structure for oms_refund_delivery
-- ----------------------------
DROP TABLE IF EXISTS `oms_refund_delivery`;
CREATE TABLE `oms_refund_delivery` (
  `id` bigint NOT NULL,
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `delivery_type` int DEFAULT NULL COMMENT '退货类型1、物流，2、自发货',
  `customer_id` bigint DEFAULT NULL COMMENT '买家id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `refund_id` bigint DEFAULT NULL COMMENT '售后工单id',
  `logistics_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物流单号',
  `logistics_status` int DEFAULT '0' COMMENT '物流状态【0 已发货 1、待签收 2、已签收】',
  `logistics_company` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物流公司名称',
  `logistics_tab` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物流公司标识',
  `company_address_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '企业收货地址',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有效',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_refund_id` (`refund_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='买家退货表';

-- ----------------------------
-- Table structure for oms_refund_order
-- ----------------------------
DROP TABLE IF EXISTS `oms_refund_order`;
CREATE TABLE `oms_refund_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint DEFAULT NULL COMMENT '客户id',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `company_id` bigint DEFAULT NULL COMMENT '供应商id',
  `refund_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '售后单号',
  `real_price` decimal(20,6) DEFAULT NULL COMMENT '实付金额',
  `refund_type` int DEFAULT NULL COMMENT '售后类型[1:取消订单、2:退货退款、3:补发，4:退款]',
  `refund_time` datetime DEFAULT NULL COMMENT '退款时间',
  `apply_time` datetime DEFAULT NULL COMMENT '售后申请时间',
  `refund_status` int DEFAULT NULL COMMENT '售后状态:(1:待审核  2:待买家退货 3:待卖家收货 4:待发货 5:待收货 6 退款中 7 退款成功 8已取消\r\n9 已驳回 10 已完成)',
  `refund_amount` decimal(20,6) DEFAULT NULL COMMENT '售后金额',
  `freight_amount` decimal(20,6) DEFAULT NULL COMMENT '运费金额',
  `total_amount` decimal(20,6) DEFAULT NULL COMMENT '商品金额',
  `promotion_amount` decimal(20,6) DEFAULT NULL COMMENT '优惠金额',
  `refund_num` int DEFAULT NULL COMMENT '退货数量',
  `platform_refund_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '平台退款分佣金额',
  `company_refund_commission_amount` decimal(20,6) DEFAULT NULL COMMENT '企业退款分佣金额',
  `reason_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '售后原因',
  `reason_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '售后原因描述',
  `deadline_start_time` datetime DEFAULT NULL COMMENT '售后开始时间',
  `deadline_end_time` datetime DEFAULT NULL COMMENT '售后货截止时间',
  `company_address_id` bigint DEFAULT NULL COMMENT '企业收货地址',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `proof_pics` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '凭证图片，以逗号隔开',
  `reject_reason` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '驳回原因描述',
  `max_refund_amount` decimal(20,2) DEFAULT NULL COMMENT '最大售后金额保留2位数字',
  `refund_order_type` tinyint(1) DEFAULT NULL COMMENT '退款订单类型 1 普通订单 2 服务订单',
  `dispatch_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单编码',
  `settle_refund_amount` decimal(10,2) DEFAULT NULL COMMENT '供应商结算sku售后金额',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1686570656474468355 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='售后订单记录表\r\n';

-- ----------------------------
-- Table structure for oms_refund_order_history
-- ----------------------------
DROP TABLE IF EXISTS `oms_refund_order_history`;
CREATE TABLE `oms_refund_order_history` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `refund_id` bigint DEFAULT NULL COMMENT '售后订单id',
  `customer_id` bigint DEFAULT NULL COMMENT '客户id',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `company_id` bigint DEFAULT NULL COMMENT '供应商id',
  `reason_type` int DEFAULT NULL COMMENT '售后原因',
  `refund_type` int DEFAULT NULL COMMENT '售后类型[1:取消订单、2:退货退款、3:补发，4:退款]',
  `apply_time` datetime DEFAULT NULL COMMENT '售后申请时间',
  `refund_time` datetime DEFAULT NULL COMMENT '退款时间',
  `refund_status` int DEFAULT NULL COMMENT '售后状态:(1:待审核  2:待买家退货 3:待卖家收货 4:待发货 5:待收货 6 退款中 7 退款成功 8已取消\r\n9 已驳回 10 已完成)',
  `refund_amount` decimal(20,6) DEFAULT NULL COMMENT '售后金额',
  `reason_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '售后原因描述',
  `deadline_start_time` datetime DEFAULT NULL COMMENT '售后开始时间',
  `deadline_end_time` datetime DEFAULT NULL COMMENT '售后货截止时间',
  `company_address_id` bigint DEFAULT NULL COMMENT '企业收货地址',
  `operation_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作类型',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `freight_amount` decimal(20,6) DEFAULT NULL COMMENT '运费金额',
  `total_amount` decimal(20,6) DEFAULT NULL COMMENT '商品金额',
  `real_price` decimal(20,6) DEFAULT NULL COMMENT '实付金额',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `operation_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1692475236689252353 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='售后订单历史记录\r\n';

-- ----------------------------
-- Table structure for oms_refund_order_item
-- ----------------------------
DROP TABLE IF EXISTS `oms_refund_order_item`;
CREATE TABLE `oms_refund_order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `refund_id` bigint DEFAULT NULL COMMENT '工单id',
  `refund_sn` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '售后订单流水号',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '订单编号',
  `customer_id` bigint DEFAULT NULL COMMENT '客户id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `apply_time` datetime DEFAULT NULL COMMENT '申请时间',
  `refund_type` int DEFAULT NULL COMMENT '售后类型[1:取消订单、2:退货退款、3:补发，4:退款]',
  `apply_status` int DEFAULT NULL COMMENT '售后状态:(1:待审核  2:待买家退货 3:待卖家收货 4:待发货 5:待收货 6 退款中 7 退款成功 8已取消\r\n9 已驳回 10 已完成)',
  `handle_time` datetime DEFAULT NULL COMMENT '处理时间',
  `handle_user_id` bigint DEFAULT NULL COMMENT '处理人员',
  `handle_status` int DEFAULT NULL COMMENT '处理状态【0:未处理、1:已处理】',
  `handle_note` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '处理备注',
  `refund_amount` decimal(20,6) DEFAULT NULL COMMENT '退款金额',
  `refund_count` int DEFAULT NULL COMMENT '退货数量',
  `refund_time` datetime DEFAULT NULL COMMENT '退款时间',
  `spu_id` bigint DEFAULT NULL COMMENT '退货商品id',
  `spu_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '商品名称',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuId',
  `sku_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku名称：颜色：红色；尺码：xl;',
  `sku_price` decimal(10,4) DEFAULT NULL COMMENT 'sku单价',
  `sku_real_price` decimal(10,2) DEFAULT NULL COMMENT 'sku实际支付单价',
  `region_code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '服务区域编码',
  `region_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '服务区域名称',
  `proof_pics` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '凭证图片，以逗号隔开',
  `receive_status` int DEFAULT NULL COMMENT '收货状态【0:未收货，1:已收货，2:拒绝收货】',
  `receive_time` datetime DEFAULT NULL COMMENT '收货时间',
  `receive_note` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '收货备注',
  `is_useful` tinyint DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `spu_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '商品编码',
  `sku_freight_price` decimal(10,4) DEFAULT NULL COMMENT 'sku平摊运费',
  `is_last` int DEFAULT NULL COMMENT '是否最后1笔标识 1：是',
  `refund_order_type` tinyint(1) DEFAULT NULL COMMENT '退款订单类型 1 普通订单 2 服务订单',
  `order_service_rate` decimal(10,4) DEFAULT NULL COMMENT '托管服务比例',
  `order_service_amount` decimal(10,4) DEFAULT NULL COMMENT '托管服务费',
  `sku_settle_price` decimal(10,2) DEFAULT NULL COMMENT '供应商sku结算价格',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1686570656487051265 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='订单售后明细';

-- ----------------------------
-- Table structure for oms_refund_reason
-- ----------------------------
DROP TABLE IF EXISTS `oms_refund_reason`;
CREATE TABLE `oms_refund_reason` (
  `id` bigint NOT NULL,
  `reason_type` int DEFAULT NULL COMMENT '原因类型',
  `reason_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '原因名称',
  `sort` int DEFAULT NULL COMMENT '排序',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `is_useful` tinyint DEFAULT '1',
  `is_delete` tinyint DEFAULT '0',
  `business_type` tinyint DEFAULT '1' COMMENT '业务类型：1.实物商品，2.虚拟商品',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='退货原因表';

-- ----------------------------
-- Table structure for oms_refund_rule
-- ----------------------------
DROP TABLE IF EXISTS `oms_refund_rule`;
CREATE TABLE `oms_refund_rule` (
  `id` bigint NOT NULL,
  `action_type` int DEFAULT NULL COMMENT '操作类型【1:取消订单，2:退货退款，3:补发，4:退款】',
  `rule_type` int DEFAULT NULL COMMENT '规则类型',
  `rule_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '规则名称',
  `rule_express` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '规则表达式',
  `group_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '组套',
  `before_rule_id` bigint DEFAULT NULL COMMENT '前置规则id',
  `after_rule_id` bigint DEFAULT NULL COMMENT '后置规则id',
  `logic_type` int DEFAULT NULL COMMENT '逻辑类型【1:与，2:或】',
  `sort` int DEFAULT NULL COMMENT '排序',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `is_useful` tinyint DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='售后规则表';

-- ----------------------------
-- Table structure for oms_settle_daily_collect
-- ----------------------------
DROP TABLE IF EXISTS `oms_settle_daily_collect`;
CREATE TABLE `oms_settle_daily_collect` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `account_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '账户编号',
  `user_id` bigint DEFAULT NULL COMMENT '用户id',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户姓名',
  `collect_date` date DEFAULT NULL COMMENT '汇总日期',
  `collect_type` int DEFAULT NULL COMMENT '汇总类型',
  `total_amount` decimal(24,10) DEFAULT NULL COMMENT '交易总金额',
  `total_count` int DEFAULT NULL COMMENT '交易总笔数',
  `settle_status` int DEFAULT NULL COMMENT '结算状态',
  `risk_day` int DEFAULT NULL COMMENT '风险预存期天数',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `is_useful` tinyint DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `remark` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='每日待结算汇总';

-- ----------------------------
-- Table structure for oms_settle_record
-- ----------------------------
DROP TABLE IF EXISTS `oms_settle_record`;
CREATE TABLE `oms_settle_record` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `operate_company_id` bigint DEFAULT NULL COMMENT '运营平台id',
  `trade_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易流水号【生成规则：10位 时间戳 + 6位随机数字】',
  `order_id` bigint DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '订单流水号',
  `dispatch_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '发货单号',
  `settle_order_type` tinyint DEFAULT '1' COMMENT '支付订单类型 1:生产订单 2:委托服务订单',
  `settle_phase` tinyint DEFAULT NULL COMMENT '分期/账期结算阶段 1:首付款 2:货款 3:尾款 4:账期',
  `settle_type` int DEFAULT NULL COMMENT '结算类型【1:正向交易，2:负向交易】',
  `settle_mode` int DEFAULT NULL COMMENT '结算发起方式【1:自动结算，2:手动确认结算】',
  `settle_date` datetime DEFAULT NULL COMMENT '结算日期',
  `settle_amount` decimal(24,6) DEFAULT NULL COMMENT '结算金额',
  `settle_status` int DEFAULT NULL COMMENT '结算状态【0:未结算，1:已结算，2:已取消】',
  `settle_fee` decimal(24,6) DEFAULT NULL COMMENT '结算手续费',
  `settle_user_id` bigint DEFAULT NULL COMMENT '结算用户',
  `account_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '账户编号',
  `remit_amount` decimal(24,6) DEFAULT NULL COMMENT '结算打款金额',
  `remit_confirm_time` datetime DEFAULT NULL COMMENT '打款确认时间',
  `remit_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '打款备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='结算记录';

-- ----------------------------
-- Table structure for oms_settle_summary
-- ----------------------------
DROP TABLE IF EXISTS `oms_settle_summary`;
CREATE TABLE `oms_settle_summary` (
  `id` bigint NOT NULL COMMENT 'id',
  `summary_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '结算单汇总流水号',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `account_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '账户编号',
  `user_id` bigint DEFAULT NULL COMMENT '用户id',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户姓名',
  `collect_date` date DEFAULT NULL COMMENT '汇总日期',
  `collect_type` int DEFAULT NULL COMMENT '汇总类型',
  `total_amount` decimal(24,10) DEFAULT NULL COMMENT '交易总金额',
  `total_count` int DEFAULT NULL COMMENT '交易总笔数',
  `settle_status` int DEFAULT NULL COMMENT '结算状态',
  `settle_date` datetime DEFAULT NULL COMMENT '结算时间',
  `risk_day` int DEFAULT NULL COMMENT '风险预存期天数',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改者',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `is_useful` tinyint DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `remark` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for oms_transfer_pay
-- ----------------------------
DROP TABLE IF EXISTS `oms_transfer_pay`;
CREATE TABLE `oms_transfer_pay` (
  `id` bigint NOT NULL,
  `pay_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '付款单号',
  `payee_company_id` bigint NOT NULL COMMENT '企业ID',
  `payee_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收款人',
  `payee_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '付款申请账户类型：BANKACCT_PRI对私，BANKACCT_PUB对公',
  `bank_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '对公银行必须',
  `cnaps_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '大额行号。银行大额行号，收款方类型为对公银行账户必须',
  `payee_bank` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收款人开户行',
  `payee_card` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收款方卡号',
  `pay_amount` decimal(10,2) NOT NULL COMMENT '付款金额',
  `payment_time` datetime DEFAULT NULL COMMENT '付款时间',
  `progress` tinyint DEFAULT '1' COMMENT '0,待审批1.审批中，2.已到账，3打款失败，4已取消，5审批驳回,6打款中',
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '附件路径',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `source_sn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源订单信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人或更新人',
  `payer_company_id` bigint NOT NULL COMMENT '付款企业ID',
  `payer_company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '付款企业名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for open_call_record
-- ----------------------------
DROP TABLE IF EXISTS `open_call_record`;
CREATE TABLE `open_call_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `app_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'appId',
  `url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用url',
  `param_json` json DEFAULT NULL COMMENT '调用参数',
  `result_json` json DEFAULT NULL COMMENT '返回结果',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `req_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '请求时间',
  `end_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '请求时间',
  `consume_time` bigint DEFAULT NULL COMMENT '消耗时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `creator` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `changer` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1600756018302951425 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='调用记录表';

-- ----------------------------
-- Table structure for open_commodity
-- ----------------------------
DROP TABLE IF EXISTS `open_commodity`;
CREATE TABLE `open_commodity` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL COMMENT '商品id',
  `commodity_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `category_id` bigint NOT NULL COMMENT '分类id',
  `category_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '分类名称',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '分类名称',
  `commodity_json` json DEFAULT NULL COMMENT '商品内容',
  `syn` tinyint NOT NULL DEFAULT '0' COMMENT '是否同步：0-禁止同步, 1-允许同步',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `creator` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `changer` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1593991938397310977 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='对外同步商品';

-- ----------------------------
-- Table structure for open_sign
-- ----------------------------
DROP TABLE IF EXISTS `open_sign`;
CREATE TABLE `open_sign` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `app_key` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'app key',
  `app_secret` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'app密钥',
  `company_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '公司名称',
  `enable` tinyint NOT NULL DEFAULT '0' COMMENT '是否启用：0-不启用, 1-启用',
  `expiration` datetime NOT NULL COMMENT '有效期',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `creator` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '创建人',
  `changer` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_app_id` (`app_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='签名授权表';

-- ----------------------------
-- Table structure for open_syn_order_record
-- ----------------------------
DROP TABLE IF EXISTS `open_syn_order_record`;
CREATE TABLE `open_syn_order_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `app_key` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'app key',
  `third_user_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '第三方用户id',
  `third_tenant_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '第三方租户id',
  `max_id` bigint unsigned NOT NULL COMMENT '最大订单id',
  `last_update_time` datetime NOT NULL COMMENT '最大更新时间',
  `user_id` bigint DEFAULT NULL COMMENT '企业用户ID或会员ID',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `creator` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '创建人',
  `changer` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='同步订单记录表';

-- ----------------------------
-- Table structure for open_third_order
-- ----------------------------
DROP TABLE IF EXISTS `open_third_order`;
CREATE TABLE `open_third_order` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `app_key` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'app key',
  `third_user_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '第三方用户id',
  `third_tenant_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '第三方租户id',
  `order_sn` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '订单编号',
  `supplier_code` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '供应商编码',
  `supplier_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '供应商名称',
  `user_id` bigint DEFAULT NULL COMMENT '企业用户ID或会员ID',
  `order_status` tinyint DEFAULT '0' COMMENT '订单状态|-1：取消订单；0:未支付，1:已支付，2:发货中，3:已发货，4:已收货，5:退货审核中，6:审核失败，7:审核成功，8:退款中，9:退款成功，10：已结算，11：交易成功',
  `pay_status` tinyint DEFAULT '0' COMMENT '支付状态|0:未支付，1：已支付，2：支付失败',
  `push_status` tinyint DEFAULT '0' COMMENT '推送状态',
  `original_order_json` json DEFAULT NULL COMMENT '原始订单状态',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `creator` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '创建人',
  `changer` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '更新人',
  `third_operator_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '第三方操作用户id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_third_user_id` (`third_user_id`,`order_sn`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1640284283916787713 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='第三方订单表';

-- ----------------------------
-- Table structure for open_third_sign
-- ----------------------------
DROP TABLE IF EXISTS `open_third_sign`;
CREATE TABLE `open_third_sign` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `app_key` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '关联open_sigin app key',
  `third_app_key` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'app key',
  `third_app_secret` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'app密钥',
  `company_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '公司名称',
  `enable` tinyint NOT NULL DEFAULT '0' COMMENT '是否启用：0-不启用, 1-启用',
  `expiration` datetime NOT NULL COMMENT '有效期',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `creator` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '创建人',
  `changer` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_app_id` (`app_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='第三方签名授权表';

-- ----------------------------
-- Table structure for open_third_user
-- ----------------------------
DROP TABLE IF EXISTS `open_third_user`;
CREATE TABLE `open_third_user` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `app_key` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'app key',
  `third_user_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '第三方用户id',
  `third_tenant_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '第三方租户id',
  `mobile_phone` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '手机号',
  `user_id` bigint DEFAULT NULL COMMENT '企业用户ID或会员ID',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `creator` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '创建人',
  `changer` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_third_user_id` (`third_user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1640286625382801409 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='第三方用户表';

-- ----------------------------
-- Table structure for pms_category_mapping_relation
-- ----------------------------
DROP TABLE IF EXISTS `pms_category_mapping_relation`;
CREATE TABLE `pms_category_mapping_relation` (
  `id` bigint NOT NULL COMMENT '主键',
  `source` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '来源:1688...',
  `other_category` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第三方类目信息',
  `category` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '领猫类目信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `create_by` bigint unsigned DEFAULT '0' COMMENT '创建人',
  `update_by` bigint unsigned DEFAULT '0' COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='第三方类目信息与领猫类目信息关系表';

-- ----------------------------
-- Table structure for pms_commodity
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity`;
CREATE TABLE `pms_commodity` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '文件url',
  `commodity_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '产品编码',
  `commodity_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '产品名称',
  `sale_price` decimal(10,2) DEFAULT '0.00' COMMENT '销售价格',
  `group_id` bigint DEFAULT '0' COMMENT '组id',
  `group_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '分组组名',
  `category_id` bigint DEFAULT '0' COMMENT '分类id',
  `category_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '分类名称',
  `category_id_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分类全路径',
  `category_name_path` varchar(512) DEFAULT NULL COMMENT '分类名称全路径',
  `sale_status` tinyint DEFAULT '0' COMMENT '商品状态：【0-在售, 1-下架】',
  `use_status` tinyint DEFAULT '0' COMMENT '是否删除：【0-未删除, 1-已删除】',
  `purchase_price` decimal(10,2) DEFAULT '0.00' COMMENT '采购价',
  `cost_price` decimal(10,2) DEFAULT NULL COMMENT '成本价',
  `refer_price` decimal(10,2) DEFAULT NULL COMMENT '款式参考售价',
  `premium_rate` decimal(10,2) DEFAULT '0.00' COMMENT '费率',
  `tax_rate` decimal(10,2) DEFAULT NULL COMMENT '税率',
  `code_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '货号',
  `stl_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款号',
  `production_cycle` int DEFAULT NULL COMMENT '生产周期(天)',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_company_id` (`company_id`) USING BTREE,
  KEY `idx_code_number` (`code_number`) USING BTREE,
  KEY `commodity_code_index` (`commodity_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1996655748385476625 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='产品主表';

-- ----------------------------
-- Table structure for pms_commodity_activity
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_activity`;
CREATE TABLE `pms_commodity_activity` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品id',
  `commodity_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `original_price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `activity_price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `support_activity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `support_ticket` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `use_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品活动表';

-- ----------------------------
-- Table structure for pms_commodity_adjust_stock_log
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_adjust_stock_log`;
CREATE TABLE `pms_commodity_adjust_stock_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `commodity_sku_id` bigint NOT NULL DEFAULT '0' COMMENT '商品sku id',
  `operation` tinyint NOT NULL DEFAULT '0' COMMENT '操作类型:0:新增 1 减少 2 修改',
  `adjust_stock` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '调整的库存数',
  `stock` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '库存',
  `adjust_reason` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '调整原因',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1630778235795148804 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品调整库存记录表';

-- ----------------------------
-- Table structure for pms_commodity_attribute
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_attribute`;
CREATE TABLE `pms_commodity_attribute` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `attribute_name_id` bigint NOT NULL DEFAULT '0' COMMENT '属性名称id',
  `attribute_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性编码',
  `attribute_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性名称',
  `attribute_value_id` bigint NOT NULL DEFAULT '0' COMMENT '属性值id',
  `attribute_value` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性值',
  `attribute_value_type` tinyint NOT NULL DEFAULT '1' COMMENT '属性值类型：1-单选、2-多选、3-短文本、4-长文本、5-图片、6-图集、7-图文、8-数字、9-日期、10-时间',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `sort_num` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `idx_category_id_commodity_id` (`attribute_value_id`,`commodity_id`) USING BTREE,
  KEY `idx_attribute_name_id` (`attribute_name_id`) USING BTREE,
  KEY `idx_attribute_value_id` (`attribute_value_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1947209860286386177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品属性表';

-- ----------------------------
-- Table structure for pms_commodity_base_price
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_base_price`;
CREATE TABLE `pms_commodity_base_price` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `commodity_sku_id` bigint NOT NULL DEFAULT '0' COMMENT '商品sku id',
  `min_sale_unit` int NOT NULL DEFAULT '0' COMMENT '最小销售单元',
  `price` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '价格',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `settle_price` decimal(20,10) DEFAULT '0.0000000000' COMMENT '结算价格',
  `temu_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'TEMU售价',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1946138144252497936 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品基础价';

-- ----------------------------
-- Table structure for pms_commodity_bk
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_bk`;
CREATE TABLE `pms_commodity_bk` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `file_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '文件url',
  `commodity_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '商品名称',
  `spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'spu编码',
  `sale_price` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '销售价格',
  `stock` decimal(20,10) DEFAULT '0.0000000000' COMMENT '库存',
  `group_id` bigint DEFAULT '0' COMMENT '组id',
  `group_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '分组组名',
  `category_id` bigint NOT NULL DEFAULT '0' COMMENT '分类id',
  `category_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '分类名称',
  `freight_template_id` bigint DEFAULT '0' COMMENT '运费模板id',
  `freight_template_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '运费模板名称',
  `commodity_Status` tinyint NOT NULL DEFAULT '0' COMMENT '商品状态：0-在售, 1-下架',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_by` bigint DEFAULT NULL COMMENT '创建人id或更新人id',
  `min_sale_unit` int DEFAULT NULL COMMENT '最小销售单元',
  `source_category_id` bigint DEFAULT '0' COMMENT '分类原id',
  `source_category_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '分类原名称',
  `search_category_id` bigint DEFAULT '0' COMMENT '搜索分类id',
  `sale_index` decimal(20,10) DEFAULT NULL COMMENT '销售指标',
  `composite_index` decimal(20,10) DEFAULT NULL COMMENT '综合指标',
  `fee` decimal(20,10) DEFAULT '0.0000000000' COMMENT '扣点比例',
  `on_sale` tinyint DEFAULT '0' COMMENT '商品状态：0-在售, 1-禁售',
  `cal_reason` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '操作原因',
  `score` double DEFAULT NULL COMMENT '评分',
  `max_sale_price` decimal(20,10) DEFAULT '0.0000000000' COMMENT '最高销售价格',
  `move_source` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '迁移来源',
  `code_number` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '货号',
  `custom` tinyint DEFAULT '0' COMMENT '是否定制：0-非定制, 1-定制',
  `push_type` tinyint DEFAULT '0' COMMENT '是否平台推款：0-不是平台推款, 1-是平台推款',
  `sale_channel` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '1' COMMENT '销售渠道：0-全部, 1-服务市场, 2-线下展厅,3-TEMU',
  `product_desc` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '产品详情-临时',
  `refer_price` decimal(10,2) DEFAULT NULL COMMENT '款式参考售价',
  `sample_garment_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式编码',
  `sample_garment_id` bigint DEFAULT NULL COMMENT '款式ID',
  `commodity_source_type` tinyint DEFAULT '0' COMMENT '货源类型：0-自主研发，1-供应商供款',
  `file_path` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '附件路径',
  `customer_style_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '客户款号',
  `size_detail_values` json DEFAULT NULL COMMENT '尺码表',
  `commodity_note` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `production_cycle` int DEFAULT NULL COMMENT '生产周期(天)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_company_id` (`company_id`) USING BTREE,
  KEY `idx_code_number` (`code_number`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1950708408994894066 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品主表';

-- ----------------------------
-- Table structure for pms_commodity_category_search
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_category_search`;
CREATE TABLE `pms_commodity_category_search` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `category_id` bigint NOT NULL DEFAULT '0' COMMENT '商品标签id',
  `parent_category_id` bigint NOT NULL DEFAULT '0' COMMENT '商品标签id',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `index_name` (`category_id`,`commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1950625868451811330 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品分类检索辅助表';

-- ----------------------------
-- Table structure for pms_commodity_code_manage
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_code_manage`;
CREATE TABLE `pms_commodity_code_manage` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '产品编码',
  `spu_count` int NOT NULL DEFAULT '1' COMMENT '产品数量',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for pms_commodity_relation
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_relation`;
CREATE TABLE `pms_commodity_relation` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `company_id` bigint NOT NULL DEFAULT '0' COMMENT '公司id',
  `fob_commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `fob_company_id` bigint NOT NULL DEFAULT '0' COMMENT 'fob公司id',
  `source_type` bigint NOT NULL DEFAULT '0' COMMENT '来源类型：1-商家推款',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `idx_fob_commodity_id` (`fob_commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1713845298410819587 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品fob关系';

-- ----------------------------
-- Table structure for pms_commodity_rich_text
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_rich_text`;
CREATE TABLE `pms_commodity_rich_text` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `commodity_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '商品文本',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1947173632131899395 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品富文本';

-- ----------------------------
-- Table structure for pms_commodity_skc
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_skc`;
CREATE TABLE `pms_commodity_skc` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `company_id` bigint DEFAULT NULL COMMENT '公司id',
  `commodity_id` bigint DEFAULT '0' COMMENT '产品id',
  `commodity_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品编码',
  `commodity_skc_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '产品skc编码',
  `commodity_skc_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品skc名称',
  `custom_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '自定义编码',
  `sort_num` int DEFAULT '0' COMMENT '排序序号',
  `sale_price` decimal(10,4) DEFAULT '0.0000' COMMENT '销售价',
  `purchase_price` decimal(10,4) DEFAULT '0.0000' COMMENT '采购价',
  `color` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色名称',
  `color_code` varchar(64) DEFAULT NULL COMMENT '颜色编码',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有效',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `idx_custom_code` (`custom_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1996655748385476626 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='产品skc';

-- ----------------------------
-- Table structure for pms_commodity_skc_attachment
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_skc_attachment`;
CREATE TABLE `pms_commodity_skc_attachment` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '供应商id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `file_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件名称',
  `file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件地址',
  `file_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件类型（0图片，1附件）',
  `business_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '数据业务类型',
  `file_version` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件版本',
  `file_version_value` int DEFAULT NULL COMMENT '文件版本数值',
  `file_business_type` int DEFAULT NULL COMMENT '文件业务类型【1:工艺单，2:BOM单，3:尺寸表，4:纸样，5:合价表】',
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `table_relation` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '关联表',
  `table_relation_id` bigint DEFAULT NULL COMMENT '关联表主键id',
  `sorted` int DEFAULT NULL COMMENT '排序字段（按类型分类）',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for pms_commodity_skc_bk
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_skc_bk`;
CREATE TABLE `pms_commodity_skc_bk` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `company_id` bigint DEFAULT NULL COMMENT '公司id',
  `commodity_id` bigint DEFAULT '0' COMMENT '商品id',
  `skc_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT 'sku编码',
  `custom_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '自定义编码',
  `skc_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku名称',
  `stock_num` int DEFAULT '0' COMMENT '库存数量',
  `sort_num` int DEFAULT '0' COMMENT '排序序号',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有效',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `price` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT '价格(销售价)',
  `settle_price` decimal(20,4) DEFAULT '0.0000' COMMENT '结算价格(采购价)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `idx_custom_code` (`custom_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1950626733078220801 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品skc';

-- ----------------------------
-- Table structure for pms_commodity_skc_spec
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_skc_spec`;
CREATE TABLE `pms_commodity_skc_spec` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `company_id` bigint DEFAULT NULL COMMENT '公司id',
  `commodity_id` bigint DEFAULT '0' COMMENT '商品id',
  `skc_id` bigint DEFAULT NULL COMMENT 'sku id',
  `spec_attribute_name_id` bigint DEFAULT '0' COMMENT '商品规格属性名id',
  `spec_attribute_value_id` bigint DEFAULT '0' COMMENT '商品规格属性值id',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1728002670897270802 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品spec_sku表';

-- ----------------------------
-- Table structure for pms_commodity_skc_spec_value
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_skc_spec_value`;
CREATE TABLE `pms_commodity_skc_spec_value` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `company_id` bigint DEFAULT NULL COMMENT '公司id',
  `commodity_id` bigint DEFAULT '0' COMMENT '商品id',
  `skc_id` bigint DEFAULT '0' COMMENT '商品规格id',
  `skc_spec_id` bigint DEFAULT NULL COMMENT 'skc 属性值id',
  `attribute_value_id` bigint DEFAULT NULL COMMENT '属性值id',
  `attribute_value_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值名称',
  `sort_num` int DEFAULT '0' COMMENT '排序序号',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `idx_attribute_value_id` (`attribute_value_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1728002670825967623 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品规格值表';

-- ----------------------------
-- Table structure for pms_commodity_sku
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_sku`;
CREATE TABLE `pms_commodity_sku` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint DEFAULT '0' COMMENT '产品id',
  `commodity_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品编码',
  `commodity_skc_id` bigint DEFAULT NULL COMMENT '产品skc ID',
  `commodity_skc_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品skc 编码',
  `commodity_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '产品sku编码',
  `commodity_sku_name` varchar(255) DEFAULT NULL COMMENT '产品sku名称',
  `custom_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '自定义编码',
  `color` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `color_code` varchar(128) DEFAULT NULL COMMENT '颜色编码',
  `size_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '规格',
  `color_size` varchar(128) DEFAULT NULL COMMENT '颜色规格',
  `sale_status` tinyint DEFAULT '1' COMMENT '销售状态：【0-在售, 1-禁售】',
  `use_status` tinyint DEFAULT '0' COMMENT '是否删除：【0-未删除, 1-已删除】',
  `create_by` bigint DEFAULT NULL COMMENT '创建人id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人id',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `idx_custom_code` (`custom_code`) USING BTREE,
  KEY `commodity_sku_code` (`commodity_sku_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1996655748385476628 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='产品sku';

-- ----------------------------
-- Table structure for pms_commodity_sku_bk
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_sku_bk`;
CREATE TABLE `pms_commodity_sku_bk` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `skc_id` bigint DEFAULT NULL COMMENT '商品skc ID',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'sku编码',
  `custom_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '自定义编码',
  `stock` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '库存',
  `sort_num` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `jst_stock` int DEFAULT '0' COMMENT '聚水潭库存',
  `custom` tinyint NOT NULL DEFAULT '0' COMMENT '是否定制：0-非定制, 1-定制',
  `is_stock_up` tinyint NOT NULL DEFAULT '0' COMMENT '是否备货：0-否，1-是',
  `temu_stock` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'TEMU库存',
  `sku_delivery_spec` json DEFAULT NULL COMMENT 'sku运输规格',
  `sku_status` tinyint DEFAULT '1' COMMENT '销售状态：0-在售, 1-禁售',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `idx_custom_code` (`custom_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1950626711896985602 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品sku';

-- ----------------------------
-- Table structure for pms_commodity_sku_delivery_spec
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_sku_delivery_spec`;
CREATE TABLE `pms_commodity_sku_delivery_spec` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `sku_id` bigint NOT NULL DEFAULT '0' COMMENT '商品sku id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `weight` int DEFAULT NULL COMMENT '重量，单位克',
  `length` int DEFAULT NULL COMMENT '长，单位厘米',
  `width` int DEFAULT NULL COMMENT '宽，单位厘米',
  `height` int DEFAULT NULL COMMENT '高，单位厘米',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品sku运输规格表';

-- ----------------------------
-- Table structure for pms_commodity_spec
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_spec`;
CREATE TABLE `pms_commodity_spec` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `attribute_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性名称',
  `key_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性编码',
  `attribute_name_id` bigint NOT NULL COMMENT '属性名id',
  `sort_num` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `idx_attribute_name_id` (`attribute_name_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1946138144206360579 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品规格表';

-- ----------------------------
-- Table structure for pms_commodity_spec_sku
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_spec_sku`;
CREATE TABLE `pms_commodity_spec_sku` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `spec_attribute_name_id` bigint NOT NULL DEFAULT '0' COMMENT '商品规格属性名id',
  `spec_attribute_value_id` bigint NOT NULL DEFAULT '0' COMMENT '商品规格属性值id',
  `commodity_sku_id` bigint NOT NULL DEFAULT '0' COMMENT '商品sku id',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1946138144252497935 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品spec_sku表';

-- ----------------------------
-- Table structure for pms_commodity_spec_value
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_spec_value`;
CREATE TABLE `pms_commodity_spec_value` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `commodity_spec_id` bigint NOT NULL DEFAULT '0' COMMENT '商品规格id',
  `attribute_value` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性值',
  `attribute_value_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `attribute_value_id` bigint NOT NULL COMMENT '属性值id',
  `sort_num` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `idx_attribute_value_id` (`attribute_value_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1946138144206360583 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品规格值表';

-- ----------------------------
-- Table structure for pms_commodity_tag
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_tag`;
CREATE TABLE `pms_commodity_tag` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tag_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '标签名',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `out_tag_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否外部标签：0-否, 1-是',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1693826300311113729 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品标签';

-- ----------------------------
-- Table structure for pms_commodity_tag_relation
-- ----------------------------
DROP TABLE IF EXISTS `pms_commodity_tag_relation`;
CREATE TABLE `pms_commodity_tag_relation` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `commodity_tag_id` bigint NOT NULL DEFAULT '0' COMMENT '商品标签id',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1693831557174923265 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品标签关系';

-- ----------------------------
-- Table structure for pms_custom_color
-- ----------------------------
DROP TABLE IF EXISTS `pms_custom_color`;
CREATE TABLE `pms_custom_color` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '颜色名',
  `rgb` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT 'RGB值',
  `pantone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '潘通色',
  `cmyk` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT 'CMYK值',
  `company_id` bigint NOT NULL COMMENT '公司ID',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1690896060601470977 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='自定义颜色表';

-- ----------------------------
-- Table structure for pms_delivery_region
-- ----------------------------
DROP TABLE IF EXISTS `pms_delivery_region`;
CREATE TABLE `pms_delivery_region` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `freight_template_id` bigint NOT NULL COMMENT '运费模版ID',
  `first_num` int DEFAULT NULL COMMENT '首件',
  `first_weight` decimal(10,2) DEFAULT NULL COMMENT '首重kg',
  `first_fee` decimal(10,2) DEFAULT NULL COMMENT '首费（元）',
  `continue_num` int DEFAULT NULL COMMENT '续件',
  `continue_weight` decimal(10,2) DEFAULT NULL COMMENT '续重kg',
  `continue_fee` decimal(10,2) DEFAULT NULL COMMENT '续重费（元）',
  `destination` varchar(1600) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '目的地（省、市、区id）',
  `destination_name` varchar(1600) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '目的地（省、市、区name）',
  `destination_tree` json DEFAULT NULL COMMENT '目的地树形数据',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='配送区域';

-- ----------------------------
-- Table structure for pms_detect_text
-- ----------------------------
DROP TABLE IF EXISTS `pms_detect_text`;
CREATE TABLE `pms_detect_text` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `original_file_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '文件url',
  `file_uri` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '文件uri',
  `detect_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测文本',
  `detect_type` tinyint DEFAULT '0' COMMENT '检测类型：0-url、1-text',
  `check_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-通过, 1-未通过',
  `check_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测结果文本',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_cid` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for pms_file_index
-- ----------------------------
DROP TABLE IF EXISTS `pms_file_index`;
CREATE TABLE `pms_file_index` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `business_id` bigint NOT NULL DEFAULT '0' COMMENT '业务id',
  `business_type` int NOT NULL DEFAULT '0' COMMENT '业务类型：0 商品sku 1:商品图片 2:商品视频 ...',
  `file_type` tinyint NOT NULL DEFAULT '0' COMMENT '文件类型：0:图片 1:视频 ...',
  `pic_type` int DEFAULT NULL COMMENT '图片类型: 1.细节图；2.方形图；3.色块图',
  `file_uri` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '文件uri',
  `file_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '文件名',
  `sort_num` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity` (`commodity_id` DESC) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1946138144235720706 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='文件库';

-- ----------------------------
-- Table structure for pms_freight_template
-- ----------------------------
DROP TABLE IF EXISTS `pms_freight_template`;
CREATE TABLE `pms_freight_template` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `freight_template_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '运费模版名称',
  `charge_type` int DEFAULT NULL COMMENT '计价方式计价方式【1:按件 、2:按重量、 3:按体积、4:按金额】',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `general_system` tinyint DEFAULT NULL COMMENT '是否系统通用 1:是、0：否',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='运费模版';

-- ----------------------------
-- Table structure for pms_group
-- ----------------------------
DROP TABLE IF EXISTS `pms_group`;
CREATE TABLE `pms_group` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '分组名称',
  `sort_num` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品分组表';

-- ----------------------------
-- Table structure for pms_hot_key
-- ----------------------------
DROP TABLE IF EXISTS `pms_hot_key`;
CREATE TABLE `pms_hot_key` (
  `id` bigint NOT NULL,
  `hot_key_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '热词名',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0：正常，1：删除】',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品热词表';

-- ----------------------------
-- Table structure for pms_move_task
-- ----------------------------
DROP TABLE IF EXISTS `pms_move_task`;
CREATE TABLE `pms_move_task` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `shop_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '店铺链接',
  `source` tinyint NOT NULL DEFAULT '0' COMMENT '来源：0-1688, 1-其它',
  `task_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务id',
  `all_num` int NOT NULL DEFAULT '0' COMMENT '商品总数',
  `success_num` int NOT NULL DEFAULT '0' COMMENT '成功总数',
  `fail_num` int NOT NULL DEFAULT '0' COMMENT '失败总数',
  `fail_shop_url` int NOT NULL DEFAULT '0' COMMENT '失败任务url',
  `task_status` tinyint NOT NULL DEFAULT '0' COMMENT '任务状态：0-搬家中, 1-已完成，-1-失败',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `company_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '公司名称',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `creator` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '创建人',
  `update_user` bigint NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  `changer` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for pms_move_task_detail
-- ----------------------------
DROP TABLE IF EXISTS `pms_move_task_detail`;
CREATE TABLE `pms_move_task_detail` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `task_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务id',
  `source` tinyint NOT NULL DEFAULT '0' COMMENT '来源：0-1688, 1-其它',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `commodity_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `commodity_content` json DEFAULT NULL COMMENT '商品内容',
  `product_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '产品id',
  `task_status` tinyint NOT NULL DEFAULT '0' COMMENT '任务状态：0-搬家中, 1-已完成',
  `update_task_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '更新的任务id',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `company_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公司名称',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `creator` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `changer` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '修改人',
  `code_number` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='搬家任务明细表';

-- ----------------------------
-- Table structure for pms_product_ladder_price
-- ----------------------------
DROP TABLE IF EXISTS `pms_product_ladder_price`;
CREATE TABLE `pms_product_ladder_price` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint DEFAULT NULL,
  `product_attribute_item_id` bigint DEFAULT NULL COMMENT '商品属性项id',
  `spu_code` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `spu_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `sku_code` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'sku名称',
  `ladder_count` int DEFAULT NULL COMMENT '阶梯商品数量',
  `ladder_discount` decimal(10,2) DEFAULT NULL COMMENT '阶梯折扣比例',
  `ladder_price` decimal(10,2) DEFAULT NULL COMMENT '阶梯折后价格',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='产品阶梯价格表';

-- ----------------------------
-- Table structure for pms_virtual_commodity
-- ----------------------------
DROP TABLE IF EXISTS `pms_virtual_commodity`;
CREATE TABLE `pms_virtual_commodity` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `file_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '文件url',
  `commodity_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '商品名称',
  `spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'spu编码',
  `sale_price` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '销售价格',
  `stock` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '库存',
  `fee` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '扣点比例',
  `group_id` bigint NOT NULL DEFAULT '0' COMMENT '组id',
  `group_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '分组组名',
  `category_id` bigint NOT NULL DEFAULT '0' COMMENT '分类id',
  `category_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '分类名称',
  `source_category_id` bigint NOT NULL DEFAULT '0' COMMENT '分类原id',
  `composite_index` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '综合指标',
  `sale_index` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '销量指标',
  `source_category_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '分类原名称',
  `on_sale` tinyint NOT NULL DEFAULT '0' COMMENT '商品状态：0-在售, 1-禁售',
  `cal_reason` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '操作原因',
  `commodity_status` tinyint NOT NULL DEFAULT '0' COMMENT '商品状态：0-销售中, 1-下架',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `score` double DEFAULT NULL COMMENT '评分',
  `max_sale_price` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '最高销售价格',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1625120105820196865 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='虚拟商品主表';

-- ----------------------------
-- Table structure for pms_virtual_commodity_attribute
-- ----------------------------
DROP TABLE IF EXISTS `pms_virtual_commodity_attribute`;
CREATE TABLE `pms_virtual_commodity_attribute` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `key_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性标识',
  `attribute_name_id` bigint NOT NULL DEFAULT '0' COMMENT '属性名称id',
  `business_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '业务编码',
  `parent_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '父类编码',
  `attribute_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性编码',
  `attribute_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性名称',
  `attribute_value_id` bigint NOT NULL DEFAULT '0' COMMENT '属性值id',
  `attribute_value_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性值名称',
  `attribute_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性值',
  `attribute_value_type` tinyint DEFAULT '0' COMMENT '属性值类型：1-单选、2-多选、3-短文本、4-长文本、5-图片、6-图集、7-图文、8-数字、9-日期、10-时间',
  `invalid` tinyint DEFAULT '0' COMMENT '合规：0-不合规、1-合规',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `name_sort_num` int NOT NULL DEFAULT '0' COMMENT '属性名排序序号',
  `value_sort_num` int NOT NULL DEFAULT '0' COMMENT '属性值排序序号',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1625120106382512132 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='虚拟商品规格属性表';

-- ----------------------------
-- Table structure for pms_virtual_commodity_rich_text
-- ----------------------------
DROP TABLE IF EXISTS `pms_virtual_commodity_rich_text`;
CREATE TABLE `pms_virtual_commodity_rich_text` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `commodity_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '商品文本',
  `invalid` tinyint DEFAULT '0' COMMENT '合规：0-不合规、1-合规',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1625120106458009602 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='虚拟商品富文本';

-- ----------------------------
-- Table structure for pms_virtual_commodity_sku
-- ----------------------------
DROP TABLE IF EXISTS `pms_virtual_commodity_sku`;
CREATE TABLE `pms_virtual_commodity_sku` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` bigint NOT NULL DEFAULT '0' COMMENT '商品id',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'sku编码',
  `custom_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '自定义编码',
  `file_uri` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '文件uri',
  `spec` json DEFAULT NULL COMMENT '规格配置',
  `config` json DEFAULT NULL COMMENT '配置',
  `sort_num` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1625120106097020929 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='虚拟商品sku';

-- ----------------------------
-- Table structure for post_sale_report
-- ----------------------------
DROP TABLE IF EXISTS `post_sale_report`;
CREATE TABLE `post_sale_report` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sales_tracking_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '售后单号',
  `sku_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku_id',
  `sku_item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku货号',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品名称',
  `sku_attribute` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku属性',
  `expenditure_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支出类型',
  `expenditure_amount` decimal(10,2) DEFAULT NULL COMMENT '支出金额',
  `currency` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支出币种',
  `financial_time` datetime DEFAULT NULL COMMENT '财务时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk` (`sales_tracking_number`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1900466882785161236 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='售后表';

-- ----------------------------
-- Table structure for settlement_report
-- ----------------------------
DROP TABLE IF EXISTS `settlement_report`;
CREATE TABLE `settlement_report` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `settlement_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '结算单号',
  `sku_id` varchar(255) DEFAULT NULL COMMENT 'skuId',
  `product_name` varchar(255) DEFAULT NULL COMMENT '商品名称',
  `quality_score` decimal(10,2) DEFAULT NULL COMMENT '品质分',
  `reason` varchar(255) DEFAULT NULL COMMENT '原因',
  `language` varchar(255) DEFAULT NULL COMMENT '语种',
  `post_sale_apply_time` int DEFAULT NULL COMMENT '售后申请时间: 年份',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk` (`settlement_number`) USING BTREE,
  KEY `idx_sku_id` (`sku_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1878740312970342411 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='结算表';

-- ----------------------------
-- Table structure for spider_collect_company_etl_shop
-- ----------------------------
DROP TABLE IF EXISTS `spider_collect_company_etl_shop`;
CREATE TABLE `spider_collect_company_etl_shop` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '一键搬家公司商品清洗数据主键',
  `size_data` json DEFAULT NULL COMMENT '尺码数据',
  `viewdata` json DEFAULT NULL COMMENT '视频图片链接',
  `remark` json DEFAULT NULL COMMENT '描述',
  `collect_company_id` bigint DEFAULT NULL COMMENT '公司采集表主键',
  `status` int DEFAULT NULL COMMENT ' 0:初始状态   1: 清洗完成 2:同步完成',
  `collect_source_id` bigint DEFAULT NULL COMMENT '采集得源数据id',
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '消息',
  `push_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '推送消息',
  `assembly_req_market_param` json DEFAULT NULL COMMENT '组装的请求商品添加的参数',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `update_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '服务市场公司id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=25232 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for spider_collect_company_source_shop
-- ----------------------------
DROP TABLE IF EXISTS `spider_collect_company_source_shop`;
CREATE TABLE `spider_collect_company_source_shop` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '一键搬家公司商品源数据主键',
  `company_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '公司名称',
  `product_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品id',
  `company_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '公司链接',
  `product_title` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品标题',
  `url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品链接',
  `price` decimal(16,2) DEFAULT NULL COMMENT '商品价格',
  `attr` json DEFAULT NULL COMMENT '商品属性',
  `size_data` json DEFAULT NULL COMMENT '尺码数据',
  `viewdata` json DEFAULT NULL COMMENT '视频图片链接',
  `approdata` json DEFAULT NULL COMMENT '批发价格/起批量',
  `detail_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '详情地址',
  `remark` json DEFAULT NULL COMMENT '描述',
  `collect_company_id` bigint DEFAULT NULL COMMENT '公司采集表主键',
  `channel` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采集渠道',
  `total_count` int DEFAULT NULL COMMENT '总记录数',
  `current_index` int DEFAULT NULL COMMENT '当前拉取索引位置',
  `status` int DEFAULT NULL COMMENT '0:初始状态 1: 清洗完成',
  `validate_message` json DEFAULT NULL COMMENT '校验商品信息',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `update_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '服务市场公司id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=25237 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for spider_collect_exec_company
-- ----------------------------
DROP TABLE IF EXISTS `spider_collect_exec_company`;
CREATE TABLE `spider_collect_exec_company` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '一键搬家公司数据主键',
  `company_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '公司链接地址',
  `channel` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '搬家渠道',
  `status` int DEFAULT NULL COMMENT '状态 0: 受理中, 1: 处理中 2: 处理完成 -1:处理失败',
  `company_id` bigint DEFAULT NULL COMMENT '公司id',
  `message` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '描述',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `update_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `collect_count` int DEFAULT NULL COMMENT '采集条数',
  `clean_count` int DEFAULT NULL COMMENT '清洗条数',
  `collect_total_count` int DEFAULT NULL COMMENT '采集总条数',
  `push_count` int DEFAULT NULL COMMENT '推送条数',
  `shop_map` json DEFAULT NULL COMMENT '商品集合信息',
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '公司名称',
  `update_task_id` bigint DEFAULT NULL,
  `spider_task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for stl_sample_garment
-- ----------------------------
DROP TABLE IF EXISTS `stl_sample_garment`;
CREATE TABLE `stl_sample_garment` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `sm_code` varchar(100) NOT NULL COMMENT '样衣编号',
  `statuz` int DEFAULT NULL COMMENT '状态',
  `sm_src_name` varchar(100) DEFAULT NULL COMMENT '来源',
  `brand_name` varchar(100) DEFAULT NULL COMMENT '品牌',
  `year_name` varchar(20) DEFAULT NULL COMMENT '年份',
  `season_name` varchar(20) DEFAULT NULL COMMENT '季节',
  `band_name` varchar(50) DEFAULT NULL COMMENT '波段',
  `sm_name` varchar(200) DEFAULT NULL COMMENT '样衣名称',
  `ctg` varchar(50) DEFAULT NULL COMMENT '分类编码',
  `ctg_name` varchar(100) DEFAULT NULL COMMENT '分类名称',
  `big_ctg_name` varchar(100) DEFAULT NULL COMMENT '大类名称',
  `big_ctg_code` varchar(50) DEFAULT NULL COMMENT '大类编码',
  `sm_list_date` date DEFAULT NULL COMMENT '上市日期',
  `sm_price` decimal(10,2) DEFAULT NULL COMMENT '吊牌价',
  `designer` varchar(50) DEFAULT NULL COMMENT '设计师',
  `design_group_name` varchar(100) DEFAULT NULL COMMENT '设计组',
  `profile_info` varchar(200) DEFAULT NULL COMMENT '廓形值',
  `profile_info_code` varchar(50) DEFAULT NULL COMMENT '廓形编码',
  `series_info_code` varchar(50) DEFAULT NULL COMMENT '系列编码',
  `series_info` varchar(100) DEFAULT NULL COMMENT '系列',
  `brand_code` varchar(50) DEFAULT NULL COMMENT '品牌编码',
  `year_code` varchar(20) DEFAULT NULL COMMENT '年份编码',
  `unit_code` varchar(50) DEFAULT NULL COMMENT '单位编码',
  `unit_name` varchar(50) DEFAULT NULL COMMENT '单位名称',
  `season_code` varchar(20) DEFAULT NULL COMMENT '季节编码',
  `band_code` varchar(50) DEFAULT NULL COMMENT '波段编码',
  `size_group_name` varchar(100) DEFAULT NULL COMMENT '尺码组名称',
  `size_group_code` varchar(50) DEFAULT NULL COMMENT '尺码组编码',
  `sp_code` varchar(50) DEFAULT NULL COMMENT '供应商编码',
  `composition` varchar(200) DEFAULT NULL COMMENT '成份',
  `sp_short_name` varchar(100) DEFAULT NULL COMMENT '供应商',
  `telphone` varchar(20) DEFAULT NULL COMMENT '供应商联系方式',
  `degree` varchar(10) DEFAULT NULL COMMENT '等级',
  `origin_country` varchar(50) DEFAULT NULL COMMENT '原产地',
  `origin_brand` varchar(100) DEFAULT NULL COMMENT '原品牌',
  `print_tag_count` int DEFAULT NULL COMMENT '打印标签数',
  `is_disable` int DEFAULT NULL COMMENT '冻结状态 0正常;1冻结',
  `is_suit` int DEFAULT NULL COMMENT '是否套装 0否 1套装',
  `remark` text COMMENT '备注',
  `customer_name` varchar(100) DEFAULT NULL COMMENT '客户名称',
  `customer_code` varchar(50) DEFAULT NULL COMMENT '客户编码',
  `create_user` varchar(50) DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `cost_price` decimal(10,2) DEFAULT NULL COMMENT '成本价',
  `is_picked` int DEFAULT NULL COMMENT '评审 0待审，1 通过，2不通过',
  `good_code` varchar(100) DEFAULT NULL COMMENT '供应商货号',
  `retail_price` decimal(10,2) DEFAULT NULL COMMENT '建议零售价',
  `tags` varchar(200) DEFAULT NULL COMMENT '标签，多个英文逗号隔开',
  `sex` varchar(10) DEFAULT NULL COMMENT '性别',
  `img_url` varchar(500) DEFAULT NULL COMMENT '图片地址',
  `att01` varchar(200) DEFAULT NULL COMMENT '扩展一',
  `att02` varchar(200) DEFAULT NULL COMMENT '扩展二',
  `att03` varchar(200) DEFAULT NULL COMMENT '扩展三',
  `att04` varchar(200) DEFAULT NULL COMMENT '扩展四',
  `att05` varchar(200) DEFAULT NULL COMMENT '扩展五',
  `att06` varchar(200) DEFAULT NULL COMMENT '扩展六',
  `att07` varchar(200) DEFAULT NULL COMMENT '扩展七',
  `att08` varchar(200) DEFAULT NULL COMMENT '扩展八',
  `att09` varchar(200) DEFAULT NULL COMMENT '扩展九',
  `att10` varchar(200) DEFAULT NULL COMMENT '扩展十',
  `att11` varchar(200) DEFAULT NULL COMMENT '扩展十一',
  `att12` varchar(200) DEFAULT NULL COMMENT '扩展十二',
  `att13` varchar(200) DEFAULT NULL COMMENT '扩展十三',
  `att14` varchar(200) DEFAULT NULL COMMENT '扩展十四',
  `att15` varchar(200) DEFAULT NULL COMMENT '扩展十五',
  `att16` varchar(200) DEFAULT NULL COMMENT '扩展十六',
  `att17` varchar(200) DEFAULT NULL COMMENT '扩展十七',
  `att18` varchar(200) DEFAULT NULL COMMENT '扩展十八',
  `att19` varchar(200) DEFAULT NULL COMMENT '扩展十九',
  `att20` varchar(200) DEFAULT NULL COMMENT '扩展二十',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_sm_code` (`sm_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领猫样衣主表';

-- ----------------------------
-- Table structure for stl_sample_sku
-- ----------------------------
DROP TABLE IF EXISTS `stl_sample_sku`;
CREATE TABLE `stl_sample_sku` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sample_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '样衣sku编码',
  `sample_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '样衣名称',
  `color_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色编码',
  `color_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `color_frozen` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色冻结',
  `size_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '尺码组',
  `size_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '尺码编码',
  `size_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '尺码',
  `sample_spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '样衣编号',
  `source_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '来源',
  `brand_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '品牌',
  `supplier_company_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商编码',
  `supplier_company_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商',
  `code_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货号',
  `tag_price` decimal(10,2) DEFAULT NULL COMMENT '吊牌价',
  `cost_price` decimal(10,2) DEFAULT NULL COMMENT '成本价',
  `retail_price` decimal(10,2) DEFAULT NULL COMMENT '建议零售价',
  `tag` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '标签',
  `gender` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '性别',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2001902504262111238 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for stl_sample_spu
-- ----------------------------
DROP TABLE IF EXISTS `stl_sample_spu`;
CREATE TABLE `stl_sample_spu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `image_url` varchar(255) DEFAULT NULL COMMENT '商品图片URL',
  `sample_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品状态',
  `is_prototype` varchar(8) DEFAULT NULL COMMENT '是否打样(Y/N)',
  `selection_status` varchar(16) DEFAULT NULL COMMENT '选款状态',
  `sample_source` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品来源',
  `category_name_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '完整分类路径',
  `category_first` varchar(128) DEFAULT NULL,
  `category_second` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '二级分类',
  `category_third` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '三级分类',
  `category_fourth` varchar(128) DEFAULT NULL,
  `gender` varchar(32) DEFAULT NULL COMMENT '适用性别',
  `brand_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '品牌名称',
  `year` varchar(32) DEFAULT NULL COMMENT '年份',
  `season` varchar(32) DEFAULT NULL COMMENT '季节',
  `wave` varchar(32) DEFAULT NULL COMMENT '波段',
  `grade` varchar(32) DEFAULT NULL COMMENT '商品等级',
  `sample_spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '样衣编号',
  `is_set` varchar(8) DEFAULT NULL COMMENT '是否套装(Y/N)',
  `is_frozen` varchar(64) DEFAULT NULL COMMENT '是否冻结(Y/N)',
  `sample_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '样衣名称',
  `pattern_code` varchar(255) DEFAULT NULL COMMENT '版型库编号',
  `launch_date` date DEFAULT NULL COMMENT '上市日期',
  `selection_date` date DEFAULT NULL COMMENT '选款日期',
  `client_abbr` varchar(64) DEFAULT NULL COMMENT '客户简称',
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品链接',
  `unit` varchar(32) DEFAULT NULL COMMENT '计量单位',
  `design_team` varchar(64) DEFAULT NULL COMMENT '设计组',
  `designer` varchar(64) DEFAULT NULL COMMENT '设计师',
  `series` varchar(64) DEFAULT NULL COMMENT '产品系列',
  `pattern` varchar(64) DEFAULT NULL COMMENT '花版编号',
  `style` varchar(128) DEFAULT NULL COMMENT '产品风格',
  `silhouette` varchar(64) DEFAULT NULL COMMENT '廓形类型',
  `supplier_code` varchar(64) DEFAULT NULL COMMENT '供应商编码',
  `supplier` varchar(128) DEFAULT NULL COMMENT '供应商名称',
  `origin` varchar(128) DEFAULT NULL COMMENT '原产地',
  `original_brand` varchar(128) DEFAULT NULL COMMENT '原品牌',
  `product_code` varchar(64) DEFAULT NULL COMMENT '商品货号',
  `color` varchar(64) DEFAULT NULL COMMENT '颜色',
  `main_fabric` varchar(192) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '主力面料',
  `tag_price` decimal(10,2) DEFAULT NULL COMMENT '吊牌价',
  `cost_price` decimal(10,2) DEFAULT NULL COMMENT '成本价',
  `suggested_price` decimal(10,2) DEFAULT NULL COMMENT '建议零售价',
  `financial_cost` decimal(10,2) DEFAULT NULL COMMENT '财务成本价',
  `sample_tracking` varchar(32) DEFAULT NULL COMMENT '样衣跟单员',
  `tags` varchar(64) DEFAULT NULL COMMENT '商品标签',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `maintainer` varchar(42) DEFAULT NULL COMMENT '维护人员',
  `design_highlight` varchar(64) DEFAULT NULL COMMENT '设计卖点',
  `care_instruction` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '洗涤说明',
  `material` varchar(128) DEFAULT NULL COMMENT '材料成份',
  `craft_note` varchar(128) DEFAULT NULL COMMENT '工艺说明',
  `standard` varchar(32) DEFAULT NULL COMMENT '执行标准',
  `safety_class` varchar(32) DEFAULT NULL COMMENT '安全类别',
  `is_hot` varchar(32) DEFAULT NULL COMMENT '是否畅销(Y/N)',
  `craft` varchar(64) DEFAULT NULL COMMENT '工艺类型',
  `sample_style` varchar(64) DEFAULT NULL COMMENT '样衣风格',
  `target_group` varchar(64) DEFAULT NULL COMMENT '目标人群',
  `element` varchar(64) DEFAULT NULL COMMENT '设计元素',
  `promotion_attr` varchar(64) DEFAULT NULL COMMENT '推款属性',
  `product_position` varchar(64) DEFAULT NULL COMMENT '产品定位',
  `info_source` varchar(6) DEFAULT NULL COMMENT '信息来源',
  `knit_component` varchar(128) DEFAULT NULL COMMENT '汗布成分',
  `cup_detail` varchar(64) DEFAULT NULL COMMENT '杯垫细节',
  `target_price` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '目标价',
  `production_cycle` varchar(16) DEFAULT NULL COMMENT '生产周期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1988578737519726595 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for stl_style_sku
-- ----------------------------
DROP TABLE IF EXISTS `stl_style_sku`;
CREATE TABLE `stl_style_sku` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL,
  `stl_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `stl_sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `color_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `color_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `color_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `color_freeze` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `size_group` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `size_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `size_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `gb_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `stl_spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `sex` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `brand` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `style_resource` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `company_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `code_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `category_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `bulk_cargo_time` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `company_id_index` (`company_id`) USING BTREE,
  KEY `stl_sku_code_index` (`stl_sku_code`) USING BTREE,
  KEY `stl_spu_code_index` (`stl_spu_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2001336600562372617 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for stl_style_spu
-- ----------------------------
DROP TABLE IF EXISTS `stl_style_spu`;
CREATE TABLE `stl_style_spu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件地址',
  `BOM_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'BOM 状态',
  `style_resource` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式来源',
  `category_name_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分类全路径',
  `category_first` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第一级分类',
  `category_second` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第二级分类',
  `category_third` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第三级分类',
  `category_fourth` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '第四级分类',
  `sex` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '性别',
  `brand_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '品牌',
  `year` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '年份',
  `season` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '季节',
  `band_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '波段',
  `stl_spu_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式编码',
  `stl_spu_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式名称',
  `sample_grament_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '样衣编码',
  `is_group` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否组套',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '状态',
  `pattern_library_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '模式库代码',
  `listing_date` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '上市时间',
  `selection_date` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '选品日期',
  `customer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '客户名称',
  `link_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '链接地址',
  `unit` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单元',
  `design_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '设计组',
  `designer` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '设计师',
  `series` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '系列',
  `follow_edition` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '花型版本',
  `style` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '风格',
  `outline` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '轮廓',
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业名称',
  `company_simple_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业简称',
  `company_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业编码',
  `original_product_address` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原产地',
  `original_brand` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '原始品牌',
  `level` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '等级',
  `code_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货号',
  `main_fabric` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '主要成份',
  `follower` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '跟单员',
  `target` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '标签',
  `tag_price` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '吊牌价',
  `cost_price` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '成本价',
  `msrp` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '建议零售价',
  `financial_costs` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '财务成本',
  `ingredients` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `progress_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `safe_level` varchar(54) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `excetion_standards` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `selling_point` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `washing_instrations` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `maintenance_man` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `shipment_date` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `is_selling` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `produce_crafts` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `style_show` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `person` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `element` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `push_attribute` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `product_positioning` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `information_resource` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `sweat_cloth_composition` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `plate_shape` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `target_factory_price` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `production_cycle` int DEFAULT NULL COMMENT '生产周期',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_stl_spu_code` (`stl_spu_code`),
  KEY `company_id_index` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2001336600562372609 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for stl_style_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `stl_style_warehouse`;
CREATE TABLE `stl_style_warehouse` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `warehouse_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓库名称',
  `warehouse_code` varchar(64) DEFAULT NULL COMMENT '仓库编码',
  `channel_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '渠道商名称',
  `channel_value` varchar(16) DEFAULT NULL COMMENT '渠道商编码',
  `stl_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式编号',
  `stl_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式名称',
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '品牌',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'SKU',
  `color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `size` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '尺码',
  `operate_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47956 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for sys_account
-- ----------------------------
DROP TABLE IF EXISTS `sys_account`;
CREATE TABLE `sys_account` (
  `id` bigint NOT NULL,
  `user_id` bigint DEFAULT NULL COMMENT '企业用户ID或会员ID',
  `user_type` int DEFAULT NULL COMMENT '账户类型 1:企业用户、2:会员用户',
  `company_id` bigint DEFAULT NULL COMMENT '企业ID【单纯买家有企业名称，无企业ID】',
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业名称',
  `company_mode` int DEFAULT NULL COMMENT '企业类型(1企业;2个体)',
  `account_type` int DEFAULT NULL COMMENT '开户账户类型(1对公账户；2对私账户)',
  `bank_account_name` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户账户名称',
  `account_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '开户账户卡号',
  `bank_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行名称',
  `bank_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行编码',
  `bank_branch_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行支行名称',
  `base_account_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业基本户银行名称',
  `base_account_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业基本户银行编码',
  `base_account_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业基本户银行卡号',
  `bank_save_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行预留手机号',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '邮箱',
  `settle_period` int DEFAULT NULL COMMENT '结算周期',
  `service_fee` decimal(10,2) DEFAULT NULL COMMENT '平台服务费',
  `taxpayer` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '纳税人',
  `province` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户行所在省份',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户行所在城市',
  `areas` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户行所在区',
  `detail_address` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户行详细地址',
  `mobile_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收款人手机号',
  `credit_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '纳税人识别号（统一社会信用代码）',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `creditCode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `is_agree_lianlian_deal` tinyint DEFAULT NULL COMMENT '是否同意连连协议',
  `trade_password` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易密码',
  `open_account_status` tinyint DEFAULT NULL COMMENT '开户状态 0:开户中 1:开户成功 2:开户失败',
  `pay_channel` tinyint DEFAULT NULL COMMENT '支付通道 1:连连支付',
  `lianlian_open_account_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '连连支付开户状态:ACTIVATE_PENDING :已登记或开户失败（原待激活）CHECK_PENDING :审核中（原待审核）REMITTANCE_VALID_PENDING :审核通过，待打款验证（企业用户使用，暂未要求）NORMAL :正常 CANCEL :销户PAUSE :暂停 ACTIVATE_PENDING_NEW ：待激活',
  `fail_reason` varchar(320) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户失败原因',
  `lianlian_oid_userno` varchar(320) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '连连支付ACCP系统用户编号',
  `bank_branch_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行支行开户行号',
  `lianlian_update_time` datetime DEFAULT NULL COMMENT '连连回调更新时间',
  `pay_deposit_days` int DEFAULT '1' COMMENT '用户支付定金后结算天数',
  `ask_receipt_days` int DEFAULT '1' COMMENT '用户确认收货后结算天数',
  `payment_end_days` int DEFAULT '1' COMMENT '用户支付尾款后结算天数',
  `fob_business_type` tinyint(1) DEFAULT '1' COMMENT '供应商fob营业类型 1:fob非自营 2:fob自营',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='资金账户表';

-- ----------------------------
-- Table structure for sys_account_change
-- ----------------------------
DROP TABLE IF EXISTS `sys_account_change`;
CREATE TABLE `sys_account_change` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint DEFAULT NULL COMMENT '企业用户ID或会员ID',
  `user_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '变更内容',
  `account_change_type` tinyint DEFAULT NULL COMMENT '开户变更类型 1-银行卡信息变更 2-绑定手机号码变更 3-开户基本信息变更 ...',
  `account_change_status` tinyint DEFAULT NULL COMMENT '开户变更结果 1-正常 5-失败',
  `lianlian_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '连连变更状态',
  `fail_reason` varchar(320) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '变更失败原因',
  `lianlian_oid_userno` varchar(320) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '连连支付ACCP系统用户编号',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除 0：未删除 1删除',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效 0：无效 1有效',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='资金账户变更记录表';

-- ----------------------------
-- Table structure for sys_approval_task
-- ----------------------------
DROP TABLE IF EXISTS `sys_approval_task`;
CREATE TABLE `sys_approval_task` (
  `id` bigint NOT NULL,
  `task_id` bigint NOT NULL COMMENT '任务ID',
  `approval_template_id` bigint NOT NULL COMMENT '审批模板ID',
  `nick_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '人名（冗余）',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户名',
  `order_num` int NOT NULL COMMENT '顺序编号',
  `status` tinyint DEFAULT '0' COMMENT '0：待审批，1：审批通过，2：驳回,3申请',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审批备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人或更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_approval_template
-- ----------------------------
DROP TABLE IF EXISTS `sys_approval_template`;
CREATE TABLE `sys_approval_template` (
  `id` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '审批模板名称',
  `user_process` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审批人（手机号，切割）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人或更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_attachment
-- ----------------------------
DROP TABLE IF EXISTS `sys_attachment`;
CREATE TABLE `sys_attachment` (
  `id` bigint NOT NULL,
  `file_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件名称',
  `file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件地址',
  `file_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件类型（0图片，1附件）',
  `table_relation` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '关联表',
  `table_relation_id` bigint DEFAULT NULL COMMENT '关联表主键id',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `business_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '业务类型',
  `sorted` int DEFAULT NULL COMMENT '排序字段（按类型分类）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_attribute_linkage
-- ----------------------------
DROP TABLE IF EXISTS `sys_attribute_linkage`;
CREATE TABLE `sys_attribute_linkage` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `attribute_id` bigint NOT NULL DEFAULT '0' COMMENT '属性ID',
  `attribute_value_id` bigint NOT NULL DEFAULT '0' COMMENT '属性值ID',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='属性联动表';

-- ----------------------------
-- Table structure for sys_attribute_manage
-- ----------------------------
DROP TABLE IF EXISTS `sys_attribute_manage`;
CREATE TABLE `sys_attribute_manage` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '属性ID',
  `code` varchar(12) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '属性编码',
  `key_code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '属性唯一键值',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '属性名',
  `status` tinyint(1) DEFAULT NULL COMMENT '属性状态：0-禁用、1-正常',
  `type` tinyint(1) NOT NULL COMMENT '属性分类：0-基础属性、1-关键属性、2-销售属性、3-自定义属性、4-独立属性',
  `value_type` tinyint NOT NULL COMMENT '属性值类型：1-单选、2-多选、3-短文本、4-长文本、5-图片、6-图集、7-图文、8-数字、9-日期、10-时间',
  `template` json DEFAULT NULL COMMENT '属性规则',
  `sorts` int NOT NULL DEFAULT '0' COMMENT '排序',
  `is_required` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否必填：1-是，0-否',
  `is_custom` tinyint(1) NOT NULL DEFAULT '0' COMMENT '自定义属性：1-是，0-否',
  `remark` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '属性说明',
  `source_id` bigint unsigned DEFAULT NULL COMMENT '原始属性id，来源于初始化数据',
  `company_id` bigint NOT NULL DEFAULT '0' COMMENT '企业ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2054 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='属性表';

-- ----------------------------
-- Table structure for sys_attribute_type_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_attribute_type_config`;
CREATE TABLE `sys_attribute_type_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `key_code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '' COMMENT '属性类型的唯一键值',
  `attribute_type` tinyint NOT NULL DEFAULT '0' COMMENT '属性类型',
  `attribute_type_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '属性类型名称',
  `sorts` int NOT NULL DEFAULT '0' COMMENT '排序',
  `allow_search` tinyint NOT NULL DEFAULT '0' COMMENT '允许作为检索字段（0不允许，1允许）',
  `use_domain` tinyint NOT NULL DEFAULT '0' COMMENT '用于哪个领域（0商品属性，1企业信息属性）',
  `commodity_type` tinyint NOT NULL DEFAULT '1' COMMENT '商品类型（1普通商品，2虚拟商品）',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='属性类型配置表';

-- ----------------------------
-- Table structure for sys_attribute_value
-- ----------------------------
DROP TABLE IF EXISTS `sys_attribute_value`;
CREATE TABLE `sys_attribute_value` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '属性值ID',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '属性值状态， 0-禁用、1-正常',
  `value` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '' COMMENT '属性值',
  `value_name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '属性值名称',
  `value_mode` tinyint DEFAULT '0' COMMENT '属性值存储方式（0-普通数据，1-范围数据）',
  `attribute_id` bigint unsigned NOT NULL COMMENT '属性ID',
  `commodity_category_id` int unsigned NOT NULL DEFAULT '0' COMMENT '商品分类id',
  `source_id` bigint unsigned DEFAULT NULL COMMENT '原始属性值id，来源于初始化数据',
  `company_id` bigint NOT NULL DEFAULT '0' COMMENT '企业ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4137 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='属性值表';

-- ----------------------------
-- Table structure for sys_attribute_value_0919backup
-- ----------------------------
DROP TABLE IF EXISTS `sys_attribute_value_0919backup`;
CREATE TABLE `sys_attribute_value_0919backup` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '属性值ID',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '属性值状态， 0-禁用、1-正常',
  `value` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '' COMMENT '属性值',
  `value_name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '属性值名称',
  `value_mode` tinyint DEFAULT '0' COMMENT '属性值存储方式（0-普通数据，1-范围数据）',
  `attribute_id` bigint unsigned NOT NULL COMMENT '属性ID',
  `commodity_category_id` int unsigned NOT NULL DEFAULT '0' COMMENT '商品分类id',
  `source_id` bigint unsigned DEFAULT NULL COMMENT '原始属性值id，来源于初始化数据',
  `company_id` bigint NOT NULL DEFAULT '0' COMMENT '企业ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4137 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='属性值表';

-- ----------------------------
-- Table structure for sys_audit_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_audit_log`;
CREATE TABLE `sys_audit_log` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL,
  `table_name` varchar(255) DEFAULT NULL,
  `operation` varchar(255) DEFAULT NULL,
  `record_status` int DEFAULT NULL,
  `change_data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `cost` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_name` varchar(128) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `old_data` varchar(512) DEFAULT NULL,
  `new_data` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for sys_category
-- ----------------------------
DROP TABLE IF EXISTS `sys_category`;
CREATE TABLE `sys_category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '产品分类id',
  `parent_id` bigint NOT NULL DEFAULT '0' COMMENT '父节点id',
  `category_id_path` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '父节点分类id路径',
  `category_path` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '父节点分类路径',
  `company_id` bigint DEFAULT '0' COMMENT '企业id',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '' COMMENT '品类名称',
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '' COMMENT '品类编码',
  `declare_info` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '' COMMENT '报关信息',
  `order_num` int DEFAULT '0' COMMENT '排序序号',
  `use_domain` tinyint DEFAULT '0' COMMENT '用于哪个领域（0商品属性，1企业信息属性）',
  `commodity_type` tinyint DEFAULT '1' COMMENT '商品类型（1普通商品，2虚拟商品）',
  `file_url` varchar(255) DEFAULT NULL COMMENT '文件url',
  `use_status` tinyint DEFAULT '0' COMMENT '状态：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_user` bigint unsigned DEFAULT NULL,
  `update_user` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1955478939333955593 DEFAULT CHARSET=utf8mb3 COMMENT='产品分类表';

-- ----------------------------
-- Table structure for sys_category_attribute_relation
-- ----------------------------
DROP TABLE IF EXISTS `sys_category_attribute_relation`;
CREATE TABLE `sys_category_attribute_relation` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '品类属性关系表ID',
  `attribute_id` bigint unsigned NOT NULL COMMENT '属性ID',
  `category_id` int unsigned NOT NULL COMMENT '品类ID',
  `is_customized` tinyint NOT NULL DEFAULT '0' COMMENT '是否自定义配置属性值集合：0-否、1-是',
  `is_inherited` tinyint NOT NULL DEFAULT '0' COMMENT '从父节点继承：0 否, 1 是',
  `deletable` tinyint NOT NULL DEFAULT '1' COMMENT '能否删除/能否解绑：0-不可删除, 1-可删除',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否已删除：0-未删除, 1-已删除',
  `company_id` int NOT NULL COMMENT '企业ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `create_user` int unsigned DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `update_user` int unsigned DEFAULT NULL,
  `source_category_id` int unsigned NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11051 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='品类属性关系表';

-- ----------------------------
-- Table structure for sys_category_attribute_relation_backup0918
-- ----------------------------
DROP TABLE IF EXISTS `sys_category_attribute_relation_backup0918`;
CREATE TABLE `sys_category_attribute_relation_backup0918` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '品类属性关系表ID',
  `attribute_id` bigint unsigned NOT NULL COMMENT '属性ID',
  `category_id` int unsigned NOT NULL COMMENT '品类ID',
  `is_customized` tinyint NOT NULL DEFAULT '0' COMMENT '是否自定义配置属性值集合：0-否、1-是',
  `is_inherited` tinyint NOT NULL DEFAULT '0' COMMENT '从父节点继承：0 否, 1 是',
  `deletable` tinyint NOT NULL DEFAULT '1' COMMENT '能否删除/能否解绑：0-不可删除, 1-可删除',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否已删除：0-未删除, 1-已删除',
  `company_id` int NOT NULL COMMENT '企业ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `create_user` int unsigned DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `update_user` int unsigned DEFAULT NULL,
  `source_category_id` int unsigned NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11051 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='品类属性关系表';

-- ----------------------------
-- Table structure for sys_category_backup0918
-- ----------------------------
DROP TABLE IF EXISTS `sys_category_backup0918`;
CREATE TABLE `sys_category_backup0918` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '产品分类id',
  `parent_id` int NOT NULL DEFAULT '0' COMMENT '父节点id',
  `category_id_path` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '父节点分类id路径',
  `category_path` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '父节点分类路径',
  `company_id` int NOT NULL DEFAULT '0' COMMENT '企业id',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '品类名称',
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '品类编码',
  `declare_info` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '报关信息',
  `order_num` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `use_domain` tinyint NOT NULL DEFAULT '0' COMMENT '用于哪个领域（0商品属性，1企业信息属性）',
  `commodity_type` tinyint NOT NULL DEFAULT '1' COMMENT '商品类型（1普通商品，2虚拟商品）',
  `file_url` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '文件url',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_user` int unsigned DEFAULT NULL,
  `update_user` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2204 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='产品分类表';

-- ----------------------------
-- Table structure for sys_collect_information
-- ----------------------------
DROP TABLE IF EXISTS `sys_collect_information`;
CREATE TABLE `sys_collect_information` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '品牌店铺名称',
  `user_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '姓名',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '手机号',
  `industry` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '行业',
  `channel` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '渠道',
  `company` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '公司',
  `contact_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系方式',
  `contact_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `solve_status` tinyint(1) DEFAULT NULL COMMENT '处理状态',
  `business_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '业务类型',
  `role` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '角色',
  `customer_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '客户类型',
  `area` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '区域',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `is_delete` tinyint(1) DEFAULT '0',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建日期',
  `appointment_time` datetime DEFAULT NULL COMMENT '预约时间',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新日期',
  `area_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='卖场采集信息表';

-- ----------------------------
-- Table structure for sys_color_manage
-- ----------------------------
DROP TABLE IF EXISTS `sys_color_manage`;
CREATE TABLE `sys_color_manage` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '颜色表ID',
  `attribute_value_id` bigint unsigned NOT NULL COMMENT '属性值ID',
  `rgb` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'RGB值',
  `pantone` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '潘通色',
  `cmyk` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'CMYK值',
  `source_id` bigint unsigned DEFAULT NULL COMMENT '原始颜色id，来源于初始化数据',
  `company_id` bigint NOT NULL COMMENT '企业ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_user` bigint NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1075 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='颜色表';

-- ----------------------------
-- Table structure for sys_company
-- ----------------------------
DROP TABLE IF EXISTS `sys_company`;
CREATE TABLE `sys_company` (
  `id` bigint NOT NULL,
  `parent_id` bigint DEFAULT NULL COMMENT '上级id',
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业名称',
  `company_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业/服务类型，多个使用逗号分隔',
  `company_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业编码【内部使用，8位流水号】',
  `company_feature` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业特色',
  `company_guarantee` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易支持',
  `company_business_scope` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业经营范围',
  `company_business_scope_tree` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '主营业务树',
  `province` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省份（代码）',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '城市（代码）',
  `areas` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区域（代码）',
  `company_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业地址',
  `company_phone` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业联系方式',
  `company_owner` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业法人',
  `company_contacter` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业联系人',
  `company_contacter_phone` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业联系人方式',
  `company_contacter_wechat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '业务联系人微信号',
  `company_owner_card` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业法人身份证号码',
  `company_business_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业统一社会信用代码',
  `longitude` float DEFAULT NULL COMMENT '经度',
  `latitude` float DEFAULT NULL COMMENT '纬度',
  `company_images` varchar(4000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业图册',
  `company_video_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业宣传视频地址',
  `auth_pic` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '入驻认证授权图片',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `if_accredit_business_info` tinyint DEFAULT NULL COMMENT '是否授权企业工商信息（默认0未授权，1授权）',
  `company_status` tinyint DEFAULT '0' COMMENT '入驻开户状态（0未提交入驻审核，1入驻已提交待审核，2入驻审核驳回，3入驻成功待开户，4开户审核中，5开户失败，6开户成功）',
  `settled_step` int DEFAULT NULL COMMENT '入驻步骤',
  `verify_status` int DEFAULT NULL COMMENT '认证状态（初始未完成0,完成1，2失败）',
  `is_finish_info` int DEFAULT NULL COMMENT '是否完善资料信息(0未完成，1完成)',
  `company_mold` tinyint DEFAULT '0' COMMENT '【0普通供应商，1托管企业】',
  `company_mold_default` tinyint DEFAULT '0' COMMENT '【是否为默认托管企业:1.是，0.否】',
  `service_guarantee` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '服务保障',
  `pay_setting_id` bigint DEFAULT NULL COMMENT '支付设置id',
  `scm_show_flag` tinyint DEFAULT '0' COMMENT 'scm是否透出。默认0不透出，1透出',
  `source_in` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '数据来源',
  `factory_verified` tinyint DEFAULT '0' COMMENT '是否验厂 0:未验厂 1:已验厂',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业信息表';

-- ----------------------------
-- Table structure for sys_company_archives
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_archives`;
CREATE TABLE `sys_company_archives` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL,
  `company_archives_approve_status` int DEFAULT NULL COMMENT '企业档案审批状态【1已提交审核中/2审核通过/3审核失败】',
  `company_summary` json DEFAULT NULL COMMENT '企业概要介绍',
  `company_production_capacity` json DEFAULT NULL COMMENT '企业生产能力',
  `company_service_capacity` json DEFAULT NULL COMMENT '企业服务能力',
  `company_production_equipment` json DEFAULT NULL COMMENT '企业生产设备',
  `company_certificate` json DEFAULT NULL COMMENT '企业证书',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `check_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审核人',
  `check_time` datetime DEFAULT NULL COMMENT '审核时间',
  `check_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审核备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业档案快照表';

-- ----------------------------
-- Table structure for sys_company_bank
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_bank`;
CREATE TABLE `sys_company_bank` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '企业ID',
  `sys_account_id` bigint DEFAULT NULL COMMENT '企业开户ID',
  `account_type` tinyint DEFAULT NULL COMMENT '账户类型0对私，1对公，2他人',
  `account_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '账户名称',
  `company_payee_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '对私：BANKACCT_PRI，对公BANKACCT_PUB',
  `bank_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行名称',
  `bank_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行卡号',
  `bank_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '银行编码',
  `bank_branch_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支行名称',
  `bank_branch_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支行编码',
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件路径',
  `reject_content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '驳回原因',
  `status` tinyint DEFAULT '1' COMMENT '0审批中，1可用，2驳回，他人银行需要审批',
  `default_flag` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT '默认状态，1是，0否，默认0',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人或更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_company_certificate
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_certificate`;
CREATE TABLE `sys_company_certificate` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `certificate_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '证书名称',
  `certificate_picture` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '证书图片',
  `certificate_status` tinyint DEFAULT NULL COMMENT '证书审核状态0/1/2/3(未审核/审核中/审核通过/审核不通过)',
  `is_useful` tinyint DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业资质证书';

-- ----------------------------
-- Table structure for sys_company_certificate_lianlian_relation
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_certificate_lianlian_relation`;
CREATE TABLE `sys_company_certificate_lianlian_relation` (
  `id` bigint NOT NULL COMMENT '主键id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `company_legal_id` bigint DEFAULT NULL COMMENT '企业法人表id',
  `open_license_lianlian_docid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '营业执照对应连连docid唯一编号',
  `card_front_lianlian_docid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '法人身份证正面对应连连docid唯一编号',
  `card_back_lianlian_docid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '法人身份证反面对应连连docid唯一编号',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除 0:未删除 1:已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业证件与连连文件上传关系表';

-- ----------------------------
-- Table structure for sys_company_check
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_check`;
CREATE TABLE `sys_company_check` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `check_type` int DEFAULT NULL COMMENT '资料审核类型（1入驻信息；2开户信息；3基本信息；4档案资料；5认证资料）',
  `check_content` json DEFAULT NULL COMMENT '审核内容json',
  `status` int DEFAULT NULL COMMENT '审核状态（1审核中；2通过；3驳回/失败）',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `check_by` bigint DEFAULT NULL COMMENT '审核人',
  `check_time` datetime DEFAULT NULL COMMENT '审核时间',
  `check_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审核备注',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业审核备份表';

-- ----------------------------
-- Table structure for sys_company_cmb_bank_trade_detail
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_cmb_bank_trade_detail`;
CREATE TABLE `sys_company_cmb_bank_trade_detail` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `etydat` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易日：交易发生的日期',
  `etytim` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易时间：交易发生的时间，只有小时有效',
  `naryur` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '摘要',
  `amtcdr` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '借贷标记 C:贷；D:借',
  `refnbr` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '流水号:	\r\n银行会计系统交易流水号,可以和回单命名中的流水号关联',
  `vltdat` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '起息日：	\r\n开始计息的日期',
  `trscod` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易类型:见附录A.9',
  `trsamt` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易金额',
  `trsblv` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '余额:帐户的联机余额',
  `reqnbr` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '流程实例号:企业银行交易序号，唯一标示企业银行客户端发起的一笔交易',
  `busnam` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '业务名称',
  `nusage` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用途',
  `yurref` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '业务参考号:企业银行客户端录入的业务参考号。用企业银行做的交易会有业务参考号，没有票据号，在柜台或其它地方生成的交易有票据号或其它的唯一标识，都统一称为业务参考号',
  `busnar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '业务摘要',
  `otrnar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '其它摘要',
  `bbknbr` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '分行号：招商分行',
  `rpybbk` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收/付方开户地区分行号',
  `rpynam` varchar(62) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收/付方名称',
  `rpyacc` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收/付方帐号',
  `rpybbn` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收/付方开户行行号',
  `rpybnk` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收/付方开户行名',
  `rpyadr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收/付方开户行地址',
  `gsbbbk` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '母/子公司所在地区分行: 见A.1 招商分行，母/子公司帐号的开户行所在地区，如北京、上海、深圳等',
  `gsbacc` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '母/子公司帐号',
  `gsbnam` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '母/子公司名称',
  `infflg` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '信息标志: 	\r\n用于标识收/付方帐号和母/子公司的信息。为空表示付方帐号和子公司；为“1”表示收方帐号和子公司；为“2”表示收方帐号和母公司；为“3”表示原收方帐号和子公司',
  `athflg` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '有否附件信息标志:Y：是\r\n\r\nN：否',
  `chknbr` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '票据号: ',
  `rsvflg` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '冲帐标志: *为冲帐，X为补帐\r\n\r\n（冲账交易与原交易借贷相反）',
  `narext` varchar(34) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '扩展摘要: 有效位数为16',
  `trsanl` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '交易分析码: 1-2位取值含义见附录A.8交易分析码，3-6位取值含义见trscod字段说明。',
  `refsub` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商务支付订单号: 由商务支付订单产生',
  `frmcod` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业识别码: 开通收方识别功能的账户可以通过此码识别付款方',
  `status` int DEFAULT NULL COMMENT '0: 初始状态 1: 受理成功 2: 处理中 3: 交易成功 9: 交易失败',
  `out_in` int DEFAULT NULL COMMENT '1: 付款 0: 收款',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `err_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '错误消息',
  `refund_id` bigint DEFAULT NULL COMMENT '退款映射的id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3524 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业企查查认证';

-- ----------------------------
-- Table structure for sys_company_contract
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_contract`;
CREATE TABLE `sys_company_contract` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `contract_company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '签约主体名称',
  `contract_company_id` bigint DEFAULT NULL COMMENT '签约主体ID',
  `contract_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合同编码',
  `contract_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '合同名称',
  `contract_file_path` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合同文件路径',
  `delete_flag` tinyint DEFAULT '1' COMMENT '1可用，0删除',
  `start_time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合同开始时间',
  `end_time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合同结束时间',
  `create_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人名',
  `update_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业合同明细';

-- ----------------------------
-- Table structure for sys_company_delivery_address
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_delivery_address`;
CREATE TABLE `sys_company_delivery_address` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `company_id` bigint NOT NULL DEFAULT '0' COMMENT '企业id',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '姓名',
  `cellphone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '手机号码',
  `province` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '市',
  `area` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区',
  `detail_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '详细地址',
  `all_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '全路径地址',
  `address_type` tinyint DEFAULT '1' COMMENT '地址类型【1:收货地址，2:发货地址】',
  `zip_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '邮编',
  `is_default` tinyint DEFAULT '0' COMMENT '是否默认地址【0:否，1:是】',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否在用【0:否，1:是】',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除【0:否，1:是】',
  `create_by` bigint DEFAULT '0' COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT '0' COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1625134845728526337 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商家端发货地址';

-- ----------------------------
-- Table structure for sys_company_equipment
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_equipment`;
CREATE TABLE `sys_company_equipment` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `equipment_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '设备名称',
  `equipment_brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '设备品牌',
  `equipment_version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '设备型号',
  `equipment_num` int DEFAULT NULL COMMENT '设备数量',
  `equipment_picture` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '设备图片',
  `equipment_status` int DEFAULT NULL COMMENT '企业设备审核状态【0:无效、1:有效】',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业设备';

-- ----------------------------
-- Table structure for sys_company_factory_audit_report
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_factory_audit_report`;
CREATE TABLE `sys_company_factory_audit_report` (
  `id` bigint NOT NULL COMMENT '主键',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `factory_audit_report` json DEFAULT NULL COMMENT '验厂报告',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除 0:未删除 1:删除',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否有效 0:失效 1:有效',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业验厂报告表';

-- ----------------------------
-- Table structure for sys_company_history
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_history`;
CREATE TABLE `sys_company_history` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '企业id',
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业名称',
  `company_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业类型，多个使用逗号分隔',
  `company_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业组织机构代码',
  `company_status` int DEFAULT NULL COMMENT '企业审核状态（1已提交审核中/2审核通过/3审核失败）',
  `company_feature` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业特色',
  `company_guarantee` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '服务保障',
  `company_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业地址',
  `province` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省份代码',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '城市代码',
  `areas` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区域代码',
  `company_phone` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业联系方式',
  `company_owner` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业法人',
  `company_owner_card` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业法人身份证号码',
  `company_business_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业营业执照号码',
  `compant_business_scope` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业经营范围',
  `company_business_scope_tree` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '主营业务树',
  `longitude` float DEFAULT NULL COMMENT '经度',
  `latitude` float DEFAULT NULL COMMENT '纬度',
  `company_images` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业图册',
  `company_video_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业宣传视频地址',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `check_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审核人',
  `check_time` datetime DEFAULT NULL COMMENT '审核时间',
  `check_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审核备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业信息变更记录表';

-- ----------------------------
-- Table structure for sys_company_info
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_info`;
CREATE TABLE `sys_company_info` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `attribute_id` bigint DEFAULT NULL COMMENT '属性id',
  `attribute_value_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值id',
  `key_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性keyCode',
  `attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性名称',
  `attribute_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业资料属性信息表';

-- ----------------------------
-- Table structure for sys_company_legal
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_legal`;
CREATE TABLE `sys_company_legal` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `register_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业注册地址',
  `company_owner` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业法人',
  `company_owner_phone` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '法人手机号',
  `card_type` int DEFAULT NULL COMMENT '证件类型',
  `card_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '证件号码',
  `card_expires` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '证件有效期',
  `sex` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '法人性别',
  `credit_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业统一社会信用代码',
  `open_expires` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '营业期限',
  `open_license_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '营业执照url',
  `card_front_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '证件正面url',
  `card_back_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '证件反面url',
  `passport_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '护照或港澳台通行证url',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业法人信息表';

-- ----------------------------
-- Table structure for sys_company_operation_record
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_operation_record`;
CREATE TABLE `sys_company_operation_record` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `operation` int DEFAULT NULL COMMENT '操作方（1企业申请操作；2运营审核/禁用/启用操作）',
  `operation_type` int DEFAULT NULL COMMENT '操作类型（1入驻；2开户变更；3信息变更；4档案变更；5认证变更；6禁用；7启用；8财务）',
  `check_info_id` bigint DEFAULT NULL COMMENT '备份id',
  `operator` bigint DEFAULT NULL COMMENT '操作人',
  `operation_time` datetime DEFAULT NULL COMMENT '操作时间',
  `operation_content` varchar(4000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作内容',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='申请审核操作记录表';

-- ----------------------------
-- Table structure for sys_company_other_history
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_other_history`;
CREATE TABLE `sys_company_other_history` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `check_backup_id` bigint DEFAULT NULL COMMENT '关联checkId',
  `company_certificate` json DEFAULT NULL COMMENT '企业证书',
  `company_equipment` json DEFAULT NULL COMMENT '企业设备',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业设备证书备份表';

-- ----------------------------
-- Table structure for sys_company_out_tag_relation
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_out_tag_relation`;
CREATE TABLE `sys_company_out_tag_relation` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `company_tag_id` bigint DEFAULT NULL COMMENT '外部标签id',
  `tag_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '外部标签名',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='供应商外部标签关系表';

-- ----------------------------
-- Table structure for sys_company_product_capacity
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_product_capacity`;
CREATE TABLE `sys_company_product_capacity` (
  `product_capacity_id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `producer_num` int DEFAULT NULL COMMENT '生产人数',
  `month_product_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '月产值',
  `purchase_days` int DEFAULT NULL COMMENT '原材料采购天数',
  `quality_auth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '生产质量认证',
  `manage_auth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '管理体系认证',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`product_capacity_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业生产能力';

-- ----------------------------
-- Table structure for sys_company_qcc_baseinfo
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_qcc_baseinfo`;
CREATE TABLE `sys_company_qcc_baseinfo` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `expire_time` datetime DEFAULT NULL COMMENT '过期时间',
  `key_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业KeyNo',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业名称',
  `oper_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '法定代表人ID\r\n',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '法定代表人\r\n',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '登记状态',
  `start_date` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '成立日期，精确到天，如“2022-01-01”',
  `regist_capi` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '注册资本\r\n',
  `rec_cap` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实缴资本',
  `check_date` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '核准日期，精确到天，如“2022-01-01”',
  `org_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组织机构代码',
  `no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '工商注册号',
  `credit_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '统一社会信用代码',
  `econ_kind` varchar(48) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业类型',
  `term_start` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '营业期限始，精确到天，如“2022-01-01”',
  `term_end` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '营业期限至，精确到天，如无规定期限',
  `taxpayer_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '纳税人资质',
  `belong_org` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '登记机关',
  `person_scope` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '人员规模',
  `insured_count` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '参保人数',
  `english_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '英文名',
  `i_x_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '进出口企业代码',
  `address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '注册地址',
  `scope` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '经营范围',
  `is_on_stock` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否上市（0-未上市，1-上市）',
  `stock_number` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '股票代码（如A股和港股同时存在，优先显示',
  `stock_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '上市类型（A股、中概股、港股、科创板、新三板、新四',
  `image_url` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'Logo地址',
  `phone_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '联系电话',
  `email` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '邮箱',
  `web_site_url` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '官网',
  `ent_nature` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业性质，0-大陆企业，1-社会组织 ，3-中国',
  `area_code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '行政区划代码',
  `area` json DEFAULT NULL COMMENT '所属区域',
  `industry` json DEFAULT NULL COMMENT '国民行业分类数据',
  `used_name_list` json DEFAULT NULL COMMENT '曾用名',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=232 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业企查查认证';

-- ----------------------------
-- Table structure for sys_company_serve_capacity
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_serve_capacity`;
CREATE TABLE `sys_company_serve_capacity` (
  `serve_capacity_id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `diy_min_buy_num` int DEFAULT NULL COMMENT '定制起订量',
  `oem_min_buy_num` int DEFAULT NULL COMMENT '贴牌起订量',
  `is_support_foreign_order` tinyint DEFAULT NULL COMMENT '是否接外贸订单（0不支持，1支持）',
  `value_added_tax_invoice` tinyint DEFAULT NULL COMMENT '是否支持增值税发票（0不支持，1支持）',
  `process_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '加工方式',
  `invoice_point` double(20,2) DEFAULT NULL COMMENT '发票点数',
  `is_useful` tinyint DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  PRIMARY KEY (`serve_capacity_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业服务能力';

-- ----------------------------
-- Table structure for sys_company_statistic_info
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_statistic_info`;
CREATE TABLE `sys_company_statistic_info` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '会员id',
  `consume_amount` decimal(10,2) DEFAULT NULL COMMENT '累计消费金额',
  `order_count` int DEFAULT NULL COMMENT '成交数量',
  `rebuy_rate` float DEFAULT NULL COMMENT '回头率',
  `answer_rate` float DEFAULT NULL COMMENT '响应率',
  `fulfillment_rate` float DEFAULT NULL COMMENT '履约率',
  `refund_order_count` int DEFAULT NULL COMMENT '退货数量',
  `attend_count` int DEFAULT NULL COMMENT '关注数量',
  `recent_order_time` datetime DEFAULT NULL COMMENT '最后一次下订单时间',
  `score` float unsigned zerofill DEFAULT NULL COMMENT '评级',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='企业静态信息';

-- ----------------------------
-- Table structure for sys_company_survey
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_survey`;
CREATE TABLE `sys_company_survey` (
  `survey_id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '企业id',
  `company_context` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '公司简介',
  `set_up_time` date DEFAULT NULL COMMENT '成立时间',
  `year_exchange_money` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '年交易额',
  `company_area` double DEFAULT NULL COMMENT '公司面积',
  `employee_num` int DEFAULT NULL COMMENT '员工总数',
  `is_support_sample` tinyint DEFAULT NULL COMMENT '是否支持打样（0不支持，1支持）',
  `is_support_foreign` tinyint DEFAULT NULL COMMENT '是否支持外贸（0不支持，1支持）',
  `own_brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '自有品牌',
  `process_machinery` int DEFAULT NULL COMMENT '加工设备',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`survey_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业概况';

-- ----------------------------
-- Table structure for sys_company_tag
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_tag`;
CREATE TABLE `sys_company_tag` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `tag_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '标签名',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品标签';

-- ----------------------------
-- Table structure for sys_company_tag_relation
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_tag_relation`;
CREATE TABLE `sys_company_tag_relation` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `company_tag_id` bigint NOT NULL DEFAULT '0' COMMENT '公司标签id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_and_tag_id` (`company_tag_id`,`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='公司标签关系';

-- ----------------------------
-- Table structure for sys_company_verify
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_verify`;
CREATE TABLE `sys_company_verify` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '企业名称',
  `company_business_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '统一社会信用代码',
  `company_owner` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '法人',
  `company_owner_card` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '法人身份证号',
  `verify_type` tinyint DEFAULT NULL COMMENT '真实性验证方式(1打款认证/2扫码认证)',
  `bank_account_name` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户名称',
  `create_time` datetime DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省份名称',
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '市名称',
  `bank_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户银行',
  `account_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '对公账户号',
  `verify_status` tinyint DEFAULT NULL COMMENT '验证状态（1已提交审核中/2审核通过/3审核失败）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业认证表快照表';

-- ----------------------------
-- Table structure for sys_company_verify_account
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_verify_account`;
CREATE TABLE `sys_company_verify_account` (
  `id` bigint NOT NULL COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `verify_type` int DEFAULT NULL COMMENT '认证方式',
  `public_account_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户名称',
  `public_account_bank` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户银行',
  `public_account_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '对公账户',
  `province` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省份',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '城市',
  `areas` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区域',
  `account_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '开户详细地址',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '认证备注',
  `alipay_certify_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付宝人脸认证初始化返回操作唯一标识',
  `alipay_certify_url` varchar(5012) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '支付宝人脸识别认证url',
  `verify_status` tinyint(1) DEFAULT '0' COMMENT '认证状态 0:未认证 1:认证中 2:认证成功 3:认证失败',
  `out_serial_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '认证退款流水号',
  `in_serial_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '认证打款流水号',
  `refund_status` tinyint(1) DEFAULT NULL COMMENT '退款状态：1退款中，2退款成功，3退款失败',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='企业认证账户表';

-- ----------------------------
-- Table structure for sys_company_visitor_detail
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_visitor_detail`;
CREATE TABLE `sys_company_visitor_detail` (
  `id` bigint NOT NULL,
  `record_id` bigint DEFAULT NULL COMMENT '主记录id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `visitor_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '访客id',
  `visitor_date` datetime DEFAULT NULL COMMENT '访问时间',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='企业访客统计表';

-- ----------------------------
-- Table structure for sys_company_visitor_record
-- ----------------------------
DROP TABLE IF EXISTS `sys_company_visitor_record`;
CREATE TABLE `sys_company_visitor_record` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `visitor_count` int DEFAULT NULL COMMENT '访客数量',
  `census_date` datetime DEFAULT NULL COMMENT '统计日期',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='企业访客统计表';

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `config_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '参数键名',
  `config_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '参数名称',
  `config_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '参数键值',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `is_useful` tinyint DEFAULT NULL COMMENT '状态（0不启用，1启用）',
  `is_system` tinyint DEFAULT NULL COMMENT '是否全局配置',
  `create_time` datetime DEFAULT NULL COMMENT '创建日期',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新日期',
  `remark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='系统参数配置信息表';

-- ----------------------------
-- Table structure for sys_config_item
-- ----------------------------
DROP TABLE IF EXISTS `sys_config_item`;
CREATE TABLE `sys_config_item` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `config_id` bigint DEFAULT NULL COMMENT '配置ID',
  `ref_obj_id` bigint DEFAULT NULL COMMENT '配置项引用对象ID',
  `config_item_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '参数项编码',
  `config_item_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '参数项名称',
  `config_item_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '参数键值',
  `data_type` int DEFAULT NULL COMMENT '数据类型【1:number，2:boolean,3:string】',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `is_useful` tinyint DEFAULT NULL COMMENT '状态（0不启用，1启用）',
  `create_time` datetime DEFAULT NULL COMMENT '创建日期',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='系统参数配置信息表';

-- ----------------------------
-- Table structure for sys_content
-- ----------------------------
DROP TABLE IF EXISTS `sys_content`;
CREATE TABLE `sys_content` (
  `id` bigint NOT NULL,
  `content_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '内容标题',
  `content_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '内容描述',
  `content_menu_id` bigint NOT NULL COMMENT '内容菜单ID',
  `top_menu_id` bigint DEFAULT NULL COMMENT '顶级内容菜单ID',
  `is_useful` tinyint DEFAULT '1' COMMENT '状态（0不启用，1启用，2,隐藏）',
  `create_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='内容表';

-- ----------------------------
-- Table structure for sys_content_management
-- ----------------------------
DROP TABLE IF EXISTS `sys_content_management`;
CREATE TABLE `sys_content_management` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '编号',
  `type` tinyint DEFAULT NULL COMMENT '内容类型: 1.定制，2.服务，3.供应商，4.现货',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '内容详情',
  `content_id` bigint DEFAULT NULL COMMENT '内容id',
  `sort` tinyint DEFAULT NULL COMMENT '排序值',
  `start_date` date DEFAULT NULL COMMENT '生效日期开始',
  `end_date` date DEFAULT NULL COMMENT '生效日期结束',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有效',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `image_url` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片地址',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='H5内容管理表';

-- ----------------------------
-- Table structure for sys_content_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_content_menu`;
CREATE TABLE `sys_content_menu` (
  `id` bigint NOT NULL,
  `parent_id` bigint NOT NULL DEFAULT '0' COMMENT '父级ID,0为根节点',
  `content_menu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '内容名称',
  `content_menu_source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '内容菜单对应路径',
  `is_delete` tinyint DEFAULT '0' COMMENT '删除（0未删除，1删除）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人或更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='标签类型表';

-- ----------------------------
-- Table structure for sys_customer
-- ----------------------------
DROP TABLE IF EXISTS `sys_customer`;
CREATE TABLE `sys_customer` (
  `id` bigint NOT NULL,
  `ums_customer_id` bigint NOT NULL COMMENT '主账号用户ID',
  `customer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '客户名称',
  `customer_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '客户编码',
  `business_license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '营业执照',
  `legal_person` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '法人',
  `operating_year` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '经营年限',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '地址',
  `introduce` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '简介',
  `sale_follow_user_id` bigint DEFAULT NULL COMMENT '销售跟进人',
  `sale_follow_user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '销售跟进人名字',
  `create_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_customer_tag
-- ----------------------------
DROP TABLE IF EXISTS `sys_customer_tag`;
CREATE TABLE `sys_customer_tag` (
  `id` bigint NOT NULL,
  `customer_id` bigint NOT NULL COMMENT '用户ID',
  `tag_id` bigint DEFAULT NULL COMMENT '标签名称ID',
  `out_tag_status` int DEFAULT NULL COMMENT '外部标签状态',
  `create_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户标签名称关联表';

-- ----------------------------
-- Table structure for sys_customer_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_customer_user`;
CREATE TABLE `sys_customer_user` (
  `id` bigint NOT NULL,
  `sys_customer_id` bigint NOT NULL COMMENT '系统客户管理表ID',
  `ums_customer_id` bigint DEFAULT NULL COMMENT '子账户对应的ID',
  `role_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `contact` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '联系人',
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '手机号',
  `is_delete` tinyint DEFAULT '1' COMMENT '删除状态，1可用，0不可，默认1',
  `create_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_customized_attribute_value
-- ----------------------------
DROP TABLE IF EXISTS `sys_customized_attribute_value`;
CREATE TABLE `sys_customized_attribute_value` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '定制属性值ID',
  `category_attribute_id` bigint unsigned NOT NULL COMMENT '品类属性关联ID',
  `attribute_value_id` bigint unsigned NOT NULL COMMENT '属性值ID',
  `company_id` int NOT NULL DEFAULT '0' COMMENT '企业id',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `create_user` int unsigned DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `update_user` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3421 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='定制属性值表';

-- ----------------------------
-- Table structure for sys_data_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_data_log`;
CREATE TABLE `sys_data_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `content` text COMMENT '内容',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='数据日志';

-- ----------------------------
-- Table structure for sys_delivery
-- ----------------------------
DROP TABLE IF EXISTS `sys_delivery`;
CREATE TABLE `sys_delivery` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `delivery_company_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '' COMMENT '物流公司名称',
  `delivery_company_code` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '物流公司编码',
  `query_url` varchar(520) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '物流查询接口',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `delivery_type` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '物流类型',
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3385 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='物流公司';

-- ----------------------------
-- Table structure for sys_dict
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict`;
CREATE TABLE `sys_dict` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `parent_id` bigint DEFAULT '0' COMMENT '上级id',
  `dict_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '字典名称',
  `dict_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '字典编码',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新日期',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `is_delete` tinyint DEFAULT '0' COMMENT '删除（0未删除，1删除）',
  `is_useful` tinyint DEFAULT '1' COMMENT '状态（0不启用，1启用）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `dict_code` (`dict_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='字典编码信息表';

-- ----------------------------
-- Table structure for sys_dict_item
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_item`;
CREATE TABLE `sys_dict_item` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `dict_id` bigint DEFAULT NULL COMMENT '字典id',
  `item_text` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '字典项文本',
  `item_value` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '字典项值',
  `item_sort` int DEFAULT NULL COMMENT '排序',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新日期',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `is_delete` tinyint DEFAULT '0' COMMENT '删除（0未删除，1删除）',
  `is_useful` tinyint DEFAULT '1' COMMENT '状态（0不启用，1启用）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='字典项信息表';

-- ----------------------------
-- Table structure for sys_draft_box
-- ----------------------------
DROP TABLE IF EXISTS `sys_draft_box`;
CREATE TABLE `sys_draft_box` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `business_type` tinyint NOT NULL COMMENT '业务类型：1-款式，2-产品',
  `draft_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '草稿内容',
  `sample_garment_info` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式信息',
  `category_id` bigint DEFAULT NULL COMMENT '商品类目',
  `push_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货源类型',
  `company_search_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商信息',
  `customer_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '客户信息',
  `product_info_condition` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品信息',
  `sale_channel` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '销售渠道',
  `is_stock_up` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否备货：0-否，1-是',
  `is_delete` tinyint(1) DEFAULT '0' COMMENT '逻辑删除【0->正常；1->已删除】',
  `create_by` bigint NOT NULL COMMENT '创建人id',
  `update_by` bigint NOT NULL COMMENT '创建人id或更新人id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `printing_progress` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '打版进度'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_file_record
-- ----------------------------
DROP TABLE IF EXISTS `sys_file_record`;
CREATE TABLE `sys_file_record` (
  `id` bigint unsigned NOT NULL COMMENT 'id',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件名',
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '文件地址url',
  `status` int NOT NULL DEFAULT '0' COMMENT '上传状态，0-进行中，1-已完成，2-上传失败',
  `file_type` int NOT NULL DEFAULT '0' COMMENT '文件类型：0-导出文件，1-错误文件',
  `opt_modular` int NOT NULL DEFAULT '1' COMMENT '操作模块：1-普通商品，2-虚拟商品，3-供应商，4-订单，5-用户列表，6-定制商品',
  `use_status` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人或者修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='文件上传记录表';

-- ----------------------------
-- Table structure for sys_jst_auth
-- ----------------------------
DROP TABLE IF EXISTS `sys_jst_auth`;
CREATE TABLE `sys_jst_auth` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `company_id` bigint NOT NULL COMMENT '公司id',
  `is_cover` tinyint NOT NULL DEFAULT '0' COMMENT '是否覆盖服务市场库存：0-否, 1-是',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '聚水潭授权码',
  `access_token` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '聚水潭访问令牌',
  `expires_time` bigint DEFAULT NULL COMMENT '访问令牌过期时间',
  `refresh_token` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '聚水潭更新令牌',
  `is_useful` tinyint NOT NULL DEFAULT '1' COMMENT '是否有效【0：无效，1：有效】',
  `is_delete` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：【0-未删除, 1-已删除】',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_user` bigint NOT NULL DEFAULT '0' COMMENT '更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='聚水潭授权表';

-- ----------------------------
-- Table structure for sys_keyword_recommend
-- ----------------------------
DROP TABLE IF EXISTS `sys_keyword_recommend`;
CREATE TABLE `sys_keyword_recommend` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '编号',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '模块',
  `keyword` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '关键词',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有效',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='推荐关键词表';

-- ----------------------------
-- Table structure for sys_max_attribute_code
-- ----------------------------
DROP TABLE IF EXISTS `sys_max_attribute_code`;
CREATE TABLE `sys_max_attribute_code` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '最大属性编码表ID',
  `code` int NOT NULL COMMENT '最大值',
  `company_id` bigint NOT NULL COMMENT '企业ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_user` bigint NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_companyid` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='最大属性编码表';

-- ----------------------------
-- Table structure for sys_operation_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_operation_user`;
CREATE TABLE `sys_operation_user` (
  `id` bigint unsigned NOT NULL COMMENT 'id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `nick_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '昵称',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_by` bigint NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  `white_flag` tinyint(1) DEFAULT '0' COMMENT '白名单0否1是默认0',
  `status` tinyint DEFAULT '1' COMMENT '用户状态，1正常，0禁用',
  `feishu_account` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '飞书账号',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户编码',
  `delete_flag` tinyint DEFAULT '1' COMMENT '删除状态，1正常，0已删除，默认1',
  `can_change_price_flag` tinyint DEFAULT NULL COMMENT '是否可以修改价格',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='运营端用户表';

-- ----------------------------
-- Table structure for sys_purchase_demand
-- ----------------------------
DROP TABLE IF EXISTS `sys_purchase_demand`;
CREATE TABLE `sys_purchase_demand` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '编号',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '标题',
  `summary` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '简介',
  `detail` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '详情',
  `contact` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '电话',
  `wechat` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '微信',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有效',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='购买需求表';

-- ----------------------------
-- Table structure for sys_region
-- ----------------------------
DROP TABLE IF EXISTS `sys_region`;
CREATE TABLE `sys_region` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '编码',
  `parent_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '上级编码',
  `region_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区域名称',
  `region_level` int DEFAULT NULL COMMENT '区域级别，用0, 1，2，3标识\r\n            0级代表国家\r\n            一级省级行政区：省，直辖市，自治区\r\n            二级地级行政区：地级市，地区，自治州\r\n            三级县级行政区: 市辖区，县级市，县，自治县、旗',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3263 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='区域信息表';

-- ----------------------------
-- Table structure for sys_region_hot
-- ----------------------------
DROP TABLE IF EXISTS `sys_region_hot`;
CREATE TABLE `sys_region_hot` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `region_id` bigint NOT NULL COMMENT '行政区域ID',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '编码',
  `region_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区域名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='热门区域表';

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `id` bigint NOT NULL,
  `role_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '角色名称',
  `role_sign` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '角色标识',
  `remark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人',
  `update_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人或更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_sample_garment
-- ----------------------------
DROP TABLE IF EXISTS `sys_sample_garment`;
CREATE TABLE `sys_sample_garment` (
  `id` bigint NOT NULL,
  `garment_total_num` int DEFAULT '0' COMMENT '样衣总数，冗余字段',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '名称',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '编码',
  `supplier_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商名称',
  `company_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商手机号',
  `contacts_price` decimal(10,2) DEFAULT NULL COMMENT '供应商报价',
  `internal_evaluation` decimal(10,2) DEFAULT NULL COMMENT '内部核价',
  `process_cost` decimal(10,2) DEFAULT NULL COMMENT '加工费',
  `sale_price` decimal(10,2) DEFAULT NULL COMMENT '售价',
  `article_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '货号',
  `color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `size` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '尺码',
  `style` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '风格',
  `fabric` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '面料',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '成分',
  `product_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '商品链接',
  `selling_point` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '卖点',
  `printing_progress` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '打版进度',
  `typography` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '版型',
  `encryption_flag` tinyint DEFAULT '0' COMMENT '是否加0否，1是',
  `warehouse_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '库位',
  `borrow_flag` tinyint DEFAULT '0' COMMENT '借还状态,0未借出，1已借出',
  `revision_comments` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '修版意见',
  `pic_url` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图片地址',
  `appendix` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '附件',
  `video_url` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '视频地址',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  `customer_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '客户名称',
  `customer_style_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '客户款号',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '样衣类型',
  `category_id` int DEFAULT NULL COMMENT '商品类目ID',
  `category_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '编码CODE冗余',
  `company_id` bigint DEFAULT NULL COMMENT '供应商ID',
  `sync_commodity` tinyint DEFAULT '0' COMMENT '是否已同步商品，1是，0否,默认否',
  `merchandiser_id` bigint DEFAULT NULL COMMENT '跟单员',
  `size_table_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '尺寸表信息',
  `real_pic` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '实物图',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='样衣主表';

-- ----------------------------
-- Table structure for sys_sample_garment_attribute
-- ----------------------------
DROP TABLE IF EXISTS `sys_sample_garment_attribute`;
CREATE TABLE `sys_sample_garment_attribute` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sample_garment_id` bigint NOT NULL COMMENT '款式ID',
  `attribute_name_id` bigint NOT NULL DEFAULT '0' COMMENT '属性名称id',
  `attribute_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '属性名称',
  `attribute_value_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值信息',
  `attribute_value` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值',
  `attribute_value_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值类型',
  `attribute_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '属性值类型',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=14033 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_sample_garment_extend
-- ----------------------------
DROP TABLE IF EXISTS `sys_sample_garment_extend`;
CREATE TABLE `sys_sample_garment_extend` (
  `id` bigint NOT NULL,
  `sample_garment_id` bigint NOT NULL COMMENT '款式管理ID（原样衣管理）',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '样衣编码',
  `color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `color_id` int DEFAULT NULL COMMENT '颜色ID',
  `size` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '尺码',
  `size_id` int DEFAULT NULL COMMENT '尺码ID',
  `stock` int DEFAULT NULL COMMENT '库存',
  `warehouse_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '库位',
  `borrow_flag` tinyint DEFAULT '0' COMMENT '借还状态,0未借出，1已借出',
  `file_path` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '附件路径',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_sample_garment_sku
-- ----------------------------
DROP TABLE IF EXISTS `sys_sample_garment_sku`;
CREATE TABLE `sys_sample_garment_sku` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sample_garment_id` bigint NOT NULL COMMENT '款式管理ID（原样衣管理）',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '样衣编码',
  `color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '颜色',
  `color_id` int DEFAULT NULL COMMENT '颜色ID',
  `size` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '尺码',
  `size_id` int DEFAULT NULL COMMENT '尺码ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3536 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_sample_garment_template
-- ----------------------------
DROP TABLE IF EXISTS `sys_sample_garment_template`;
CREATE TABLE `sys_sample_garment_template` (
  `id` bigint NOT NULL,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `key_code` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '绑定的类型，逗号切割',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='样衣打印模板';

-- ----------------------------
-- Table structure for sys_search_keyword
-- ----------------------------
DROP TABLE IF EXISTS `sys_search_keyword`;
CREATE TABLE `sys_search_keyword` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '编号',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '模块',
  `keyword` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '关键词',
  `device` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '设备',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '浏览器',
  `region` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '地区',
  `user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '用户',
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'ip地址',
  `others` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '其他信息',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有效',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='搜索关键词表';

-- ----------------------------
-- Table structure for sys_shop_platform
-- ----------------------------
DROP TABLE IF EXISTS `sys_shop_platform`;
CREATE TABLE `sys_shop_platform` (
  `id` int NOT NULL COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '平台名',
  `app_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'appKey',
  `app_secret` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'appSecret',
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '描述',
  `server_url` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '服务url',
  `redirect_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '回调url',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='电商平台配置表';

-- ----------------------------
-- Table structure for sys_tag
-- ----------------------------
DROP TABLE IF EXISTS `sys_tag`;
CREATE TABLE `sys_tag` (
  `id` bigint NOT NULL,
  `tag_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `tag_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '标签描述',
  `tag_menu_id` bigint NOT NULL COMMENT '标签菜单ID',
  `is_useful` tinyint DEFAULT '1' COMMENT '状态（0不启用，1启用，2,废弃）',
  `create_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='标签名称表';

-- ----------------------------
-- Table structure for sys_tag_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_tag_menu`;
CREATE TABLE `sys_tag_menu` (
  `id` bigint NOT NULL,
  `parent_id` bigint NOT NULL DEFAULT '0' COMMENT '父级ID,0为根节点',
  `tag_menu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标签名称',
  `tag_menu_source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '标签对应路径',
  `is_delete` tinyint DEFAULT '0' COMMENT '删除（0未删除，1删除）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人id',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '创建人id或更新人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='标签类型表';

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用户名',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '昵称',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '密码',
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `wx_open_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '微信openId',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '电子邮件',
  `mobile` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '手机号码',
  `birthday` date DEFAULT NULL COMMENT '出生日期',
  `user_status` int DEFAULT NULL COMMENT '用户状态',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '头像',
  `sex` int DEFAULT NULL COMMENT '性别',
  `if_admin` tinyint DEFAULT NULL COMMENT '是否是超级管理员',
  `is_useful` tinyint DEFAULT '1' COMMENT '有效状态（0不启用，1启用）',
  `is_delete` tinyint DEFAULT NULL,
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建日期',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新日期',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `is_confirm` tinyint(1) DEFAULT NULL COMMENT '是否同意协议 0 不同意 1 同意1688搬家',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='用户信息表';

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `role_id` bigint DEFAULT NULL COMMENT '角色ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Table structure for sys_verify_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_verify_config`;
CREATE TABLE `sys_verify_config` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `business_mode` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审批业务模式',
  `business_type` tinyint DEFAULT '1' COMMENT '审批业务来源：1.采购单合并审批',
  `verify_object_type` tinyint DEFAULT '2' COMMENT '审批对象类型【1:用户，2:角色】',
  `verify_object_id` bigint DEFAULT NULL COMMENT '审批对象ID【用户ID，角色ID】',
  `verify_node` int DEFAULT '0' COMMENT '审批节点',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_start` tinyint DEFAULT NULL COMMENT '流程开始标记',
  `is_finish` tinyint DEFAULT NULL COMMENT '流程结束标记',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_code` (`company_id`,`business_mode`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='审批流程配置';

-- ----------------------------
-- Table structure for sys_verify_node
-- ----------------------------
DROP TABLE IF EXISTS `sys_verify_node`;
CREATE TABLE `sys_verify_node` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `task_sn` varchar(64) DEFAULT NULL COMMENT '审批任务编码',
  `current_verify_node` int DEFAULT '1' COMMENT '当前审批节点',
  `current_verify_status` int DEFAULT '1' COMMENT '当前审批状态',
  `verify_time` datetime DEFAULT NULL COMMENT '审批时间',
  `verify_user_id` bigint DEFAULT NULL COMMENT '审批人',
  `verify_object_type` tinyint DEFAULT NULL COMMENT '审批对象类型【1:用户，2:角色】',
  `verify_object_id` bigint DEFAULT NULL COMMENT '审批对象ID【用户ID，角色ID】',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_code` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='审批流程节点';

-- ----------------------------
-- Table structure for sys_verify_task
-- ----------------------------
DROP TABLE IF EXISTS `sys_verify_task`;
CREATE TABLE `sys_verify_task` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `business_mode` varchar(128) DEFAULT NULL COMMENT '业务模式',
  `task_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '任务编码',
  `task_status` tinyint DEFAULT '1' COMMENT '审批状态【0:未审批，1：审批中，2：审批通过，3:审批不通过，4:已作废】\n',
  `fail_reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审批不通过原因',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_finish` tinyint DEFAULT NULL COMMENT '是否审批结束',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_code` (`company_id`,`task_sn`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='审批流程任务';

-- ----------------------------
-- Table structure for tag_application_log
-- ----------------------------
DROP TABLE IF EXISTS `tag_application_log`;
CREATE TABLE `tag_application_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户ID',
  `tag_id` bigint unsigned NOT NULL COMMENT '标签ID',
  `operation_type` int DEFAULT NULL COMMENT '操作类型',
  `old_value` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '旧值',
  `new_value` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '新值',
  `operator` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作人',
  `application_scenario` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '应用场景',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_operation` (`user_id`,`operation_type`),
  KEY `idx_created_at` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签应用记录表';

-- ----------------------------
-- Table structure for tag_business_rule
-- ----------------------------
DROP TABLE IF EXISTS `tag_business_rule`;
CREATE TABLE `tag_business_rule` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `rule_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '规则名称',
  `rule_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '规则编码',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '规则描述',
  `rule_type` int DEFAULT NULL COMMENT '规则类型',
  `condition_expression` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '条件表达式',
  `action_expression` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '执行动作',
  `target_tag_id` bigint unsigned DEFAULT NULL COMMENT '目标标签ID',
  `priority` int unsigned DEFAULT '0' COMMENT '执行优先级',
  `effective_time` date DEFAULT NULL COMMENT '生效时间',
  `expiry_time` date DEFAULT NULL COMMENT '失效时间',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否激活',
  `last_executed_at` timestamp NULL DEFAULT NULL COMMENT '最后执行时间',
  `execution_count` int unsigned DEFAULT '0' COMMENT '执行次数',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `rule_code` (`rule_code`),
  KEY `idx_rule_code` (`rule_code`),
  KEY `idx_rule_type` (`rule_type`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_priority` (`priority`)
) ENGINE=InnoDB AUTO_INCREMENT=1998585378214383617 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='业务规则表';

-- ----------------------------
-- Table structure for tag_category
-- ----------------------------
DROP TABLE IF EXISTS `tag_category`;
CREATE TABLE `tag_category` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `category_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类名称',
  `category_code` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类编码',
  `parent_id` bigint unsigned DEFAULT '0' COMMENT '父级分类ID',
  `category_level` tinyint unsigned DEFAULT '1' COMMENT '分类层级',
  `sort_order` int unsigned DEFAULT '0' COMMENT '排序权重',
  `description` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类描述',
  `is_system` tinyint(1) DEFAULT '0' COMMENT '是否系统分类',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_level_sort` (`category_level`,`sort_order`)
) ENGINE=InnoDB AUTO_INCREMENT=1998564678808244225 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签分类表';

-- ----------------------------
-- Table structure for tag_definition
-- ----------------------------
DROP TABLE IF EXISTS `tag_definition`;
CREATE TABLE `tag_definition` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `company_id` bigint DEFAULT NULL COMMENT '企业ID',
  `tag_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标签名称',
  `tag_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标签编码',
  `category_id` bigint unsigned DEFAULT NULL COMMENT '分类ID',
  `data_type` enum('string','number','boolean','date') COLLATE utf8mb4_unicode_ci DEFAULT 'string' COMMENT '数据类型',
  `schedule_express` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '调度表达式',
  `default_value` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '默认值',
  `value_range` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '取值范围',
  `is_required` tinyint(1) DEFAULT '0' COMMENT '是否必填',
  `is_multi` tinyint(1) DEFAULT '0' COMMENT '是否多选',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '标签描述',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：1启用 0禁用',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `tag_code` (`tag_code`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_tag_code` (`tag_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=1996781771903078401 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签定义表';

-- ----------------------------
-- Table structure for tag_rule_condition_template
-- ----------------------------
DROP TABLE IF EXISTS `tag_rule_condition_template`;
CREATE TABLE `tag_rule_condition_template` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `template_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模板名称',
  `condition_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '条件类型',
  `template_expression` json NOT NULL COMMENT '模板表达式',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '模板描述',
  `is_system` tinyint(1) DEFAULT '0' COMMENT '是否系统模板',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_condition_type` (`condition_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='规则条件模板表';

-- ----------------------------
-- Table structure for tag_rule_execution_log
-- ----------------------------
DROP TABLE IF EXISTS `tag_rule_execution_log`;
CREATE TABLE `tag_rule_execution_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `rule_id` bigint unsigned NOT NULL COMMENT '规则ID',
  `execution_status` enum('success','failed','partial') COLLATE utf8mb4_unicode_ci DEFAULT 'success' COMMENT '执行状态',
  `affected_users` int unsigned DEFAULT '0' COMMENT '影响用户数',
  `error_message` text COLLATE utf8mb4_unicode_ci COMMENT '错误信息',
  `start_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
  `end_time` timestamp NULL DEFAULT NULL COMMENT '结束时间',
  `execution_duration` int unsigned DEFAULT NULL COMMENT '执行时长(秒)',
  PRIMARY KEY (`id`),
  KEY `idx_rule_id` (`rule_id`),
  KEY `idx_execution_status` (`execution_status`),
  KEY `idx_start_time` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='规则执行日志表';

-- ----------------------------
-- Table structure for tag_user_permission
-- ----------------------------
DROP TABLE IF EXISTS `tag_user_permission`;
CREATE TABLE `tag_user_permission` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `tag_id` int unsigned DEFAULT NULL COMMENT '标签ID',
  `tag_value` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '标签值',
  `confidence_score` float DEFAULT '1' COMMENT '置信度',
  `data_source` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '数据来源',
  `effective_date` date DEFAULT NULL COMMENT '生效日期',
  `expiry_date` date DEFAULT NULL COMMENT '失效日期',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_tag` (`user_id`,`tag_id`,`effective_date`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_tag_id` (`tag_id`),
  KEY `idx_effective_date` (`effective_date`),
  KEY `idx_expiry_date` (`expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户标签授权表';

-- ----------------------------
-- Table structure for translate_info
-- ----------------------------
DROP TABLE IF EXISTS `translate_info`;
CREATE TABLE `translate_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `text` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '翻译源文件',
  `source_language` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '源语种',
  `target_language` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '目标语种',
  `result` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '翻译结果',
  PRIMARY KEY (`id`),
  KEY `index` (`source_language`,`text`,`target_language`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2212 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for ums_customer
-- ----------------------------
DROP TABLE IF EXISTS `ums_customer`;
CREATE TABLE `ums_customer` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nick_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '昵称',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用户姓名',
  `dept` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '部门',
  `position` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '职位',
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '手机号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '密码',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `sex` tinyint(1) DEFAULT NULL COMMENT '性别',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '头像',
  `register_time` datetime DEFAULT NULL COMMENT '注册时间',
  `open_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'openId',
  `session_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_useful` tinyint(1) DEFAULT '1' COMMENT '1可用，0不可用，2已注销',
  `is_delete` tinyint(1) DEFAULT '0',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建日期',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新日期',
  `app_source` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '服务来源',
  `source_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '来源手机号',
  `wx_open_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '微信openId',
  `tro_service_ratio` decimal(8,2) DEFAULT NULL,
  `pay_setting_id` bigint DEFAULT NULL COMMENT '支付设置id',
  `salesman_id` bigint DEFAULT NULL COMMENT '销售员id',
  `salesman_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '销售员姓名',
  `parent_id` bigint DEFAULT '0' COMMENT '父账号ID，默认为0主账号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1706135837017772033 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='客户信息表';

-- ----------------------------
-- Table structure for ums_customer_collect
-- ----------------------------
DROP TABLE IF EXISTS `ums_customer_collect`;
CREATE TABLE `ums_customer_collect` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `collect_type` int DEFAULT NULL COMMENT '收藏类型【1:商品、2:供应商】',
  `custom_id` bigint DEFAULT NULL COMMENT '客户id',
  `collect_object_id` bigint DEFAULT NULL COMMENT '收藏对象id',
  `tag_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_useful` tinyint(1) DEFAULT '1',
  `is_delete` tinyint(1) DEFAULT '0',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1689529684372623361 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='客户收藏表';

-- ----------------------------
-- Table structure for ums_customer_collect_tag
-- ----------------------------
DROP TABLE IF EXISTS `ums_customer_collect_tag`;
CREATE TABLE `ums_customer_collect_tag` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tag_type` int DEFAULT NULL COMMENT '标签类型【1:商品、2:供应商】',
  `tag_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '标签名称',
  `tag_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '标签编码',
  `is_system` tinyint DEFAULT NULL COMMENT '系统初始化【0:否、1:是】',
  `custom_id` bigint DEFAULT NULL COMMENT '客户id',
  `is_useful` tinyint(1) DEFAULT '1',
  `is_delete` tinyint(1) DEFAULT '0',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1580552283186401281 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='客户收藏标签表';

-- ----------------------------
-- Table structure for ums_customer_company
-- ----------------------------
DROP TABLE IF EXISTS `ums_customer_company`;
CREATE TABLE `ums_customer_company` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint DEFAULT NULL COMMENT '客户id',
  `company_type` int DEFAULT NULL COMMENT '企业类型【1:企业、2:个体工商户】',
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '企业名称',
  `business_license_sn` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '营业执照注册号',
  `main_business_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '主营业务，使用，分隔',
  `verify_status` int DEFAULT NULL COMMENT '认证状态【0:未认证、1:已认证】',
  `is_useful` tinyint(1) DEFAULT '1',
  `is_delete` tinyint(1) DEFAULT '0',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建日期',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1688820556687872001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='客户所属企业表';

-- ----------------------------
-- Table structure for ums_customer_contract
-- ----------------------------
DROP TABLE IF EXISTS `ums_customer_contract`;
CREATE TABLE `ums_customer_contract` (
  `id` bigint NOT NULL,
  `customer_id` bigint DEFAULT NULL COMMENT '用户ID',
  `contract_company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '签约主体名称',
  `contract_company_id` bigint DEFAULT NULL COMMENT '签约主体ID',
  `contract_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合同编码',
  `contract_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '合同名称',
  `contract_file_path` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合同文件路径',
  `delete_flag` tinyint DEFAULT '1' COMMENT '1可用，0删除',
  `start_time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合同开始时间',
  `end_time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合同结束时间',
  `create_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建人名',
  `update_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户合同明细';

-- ----------------------------
-- Table structure for ums_customer_receive_address
-- ----------------------------
DROP TABLE IF EXISTS `ums_customer_receive_address`;
CREATE TABLE `ums_customer_receive_address` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint DEFAULT NULL COMMENT '客户id',
  `consignee_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收货人姓名',
  `consignee_mobile` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收货人联系方式',
  `consignee_telephone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '收货人固定电话',
  `province` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '市',
  `area` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区',
  `detail_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '详细地址',
  `zip_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '邮编',
  `all_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '全路径地址',
  `address_type` tinyint DEFAULT '1' COMMENT '地址类型【1:收货地址，2:发货地址】',
  `is_default` tinyint DEFAULT NULL COMMENT '是否默认地址【0:否，1:是】',
  `is_useful` tinyint DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1706135837080686593 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='客户收货地址';

-- ----------------------------
-- Table structure for ums_customer_statistic_info
-- ----------------------------
DROP TABLE IF EXISTS `ums_customer_statistic_info`;
CREATE TABLE `ums_customer_statistic_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint DEFAULT NULL COMMENT '会员id',
  `consume_amount` decimal(10,2) DEFAULT NULL COMMENT '累计消费金额',
  `order_count` int DEFAULT NULL COMMENT '订单数量',
  `refund_order_count` int DEFAULT NULL COMMENT '退货数量',
  `login_count` int DEFAULT NULL COMMENT '登录次数',
  `attend_count` int DEFAULT NULL COMMENT '关注数量',
  `recent_order_time` datetime DEFAULT NULL COMMENT '最后一次下订单时间',
  `tag_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '自定义标签',
  `tag_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '自定义名称',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='客户统计信息';

-- ----------------------------
-- Table structure for unify_authentication
-- ----------------------------
DROP TABLE IF EXISTS `unify_authentication`;
CREATE TABLE `unify_authentication` (
  `id` bigint NOT NULL,
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '账号',
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '手机号',
  `open_id` char(28) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'openId',
  `user_id` bigint DEFAULT NULL,
  `customer_id` bigint DEFAULT NULL,
  `session_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_delete` tinyint(1) DEFAULT '0',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建日期',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='统一登录认证信息表';

-- ----------------------------
-- Table structure for wms_channel_warehouse_config
-- ----------------------------
DROP TABLE IF EXISTS `wms_channel_warehouse_config`;
CREATE TABLE `wms_channel_warehouse_config` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司id',
  `channel_type` tinyint NOT NULL COMMENT '店铺类型:{1. SHEIN, 2. TEMU, 3. AMAZON, 4. SHEIN ODM,5:Tiktok,6:分销渠道}',
  `channel_model` tinyint DEFAULT NULL COMMENT '店铺模式: {1-OBM全托管(供应商模式), 2-半托管模式, 3-平台模式, 4-全托管,5:SHEIN自营,6:FBA,7:FBM,8:Tiktok自营,9:Tiktok全托管,10:分销渠道}',
  `finished_jst_warehouse_id` bigint DEFAULT NULL COMMENT '聚水潭成品仓库id',
  `semi_jst_warehouse_id` bigint DEFAULT NULL COMMENT '聚水潭半成品仓库id',
  `finished_wms_co_id` bigint DEFAULT NULL COMMENT '聚水潭成品仓库coid',
  `semi_wms_co_id` bigint DEFAULT NULL COMMENT '聚水潭半成品仓库coid',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint NOT NULL DEFAULT '0' COMMENT '删除标记：0=未删除，大于0：删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='渠道仓库配置';

-- ----------------------------
-- Table structure for wms_commodity_sale
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_sale`;
CREATE TABLE `wms_commodity_sale` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint NOT NULL COMMENT '产品id',
  `commodity_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品编码',
  `commodity_name` varchar(255) DEFAULT NULL COMMENT '产品名称',
  `code_number` varchar(128) DEFAULT NULL COMMENT '货号',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `sync_date` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '数据同步时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_spu` (`sync_date` DESC,`commodity_id`,`is_delete`) USING BTREE,
  KEY `index_company_spu` (`company_id`,`commodity_id`) USING BTREE,
  KEY `sync_date_index` (`sync_date`) USING BTREE,
  KEY `commodity_id_index` (`commodity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品spu销量';

-- ----------------------------
-- Table structure for wms_commodity_shop_sale
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_shop_sale`;
CREATE TABLE `wms_commodity_shop_sale` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint NOT NULL COMMENT '产品id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `sync_date` date NOT NULL COMMENT '数据同步日期',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_spu` (`company_id`,`sync_date` DESC,`shop_id`,`commodity_id`,`is_delete`) USING BTREE,
  KEY `index_company_spu` (`company_id`,`commodity_id`) USING BTREE,
  KEY `commodity_id_index` (`commodity_id`),
  KEY `idx_company_date_range` (`company_id`,`sync_date`,`is_delete`,`shop_id`,`commodity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品spu店铺销量';

-- ----------------------------
-- Table structure for wms_commodity_shop_stock
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_shop_stock`;
CREATE TABLE `wms_commodity_shop_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint NOT NULL COMMENT '产品id',
  `shop_id` bigint NOT NULL COMMENT '产品id',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `sync_date` date NOT NULL COMMENT '数据同步日期',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_spu` (`sync_date` DESC,`shop_id`,`commodity_id`,`is_delete`) USING BTREE,
  KEY `company_id_index` (`company_id`) USING BTREE,
  KEY `commodity_id_index` (`commodity_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for wms_commodity_skc_sale
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_skc_sale`;
CREATE TABLE `wms_commodity_skc_sale` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint DEFAULT NULL COMMENT '产品id',
  `commodity_skc_id` bigint NOT NULL COMMENT '产品skcId',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `fifteen_days_sale_num` int DEFAULT '0' COMMENT '近15天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `sync_date` date NOT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_skc_date_delete` (`commodity_skc_id`,`sync_date`,`is_delete`) USING BTREE,
  KEY `idx_sync_date` (`sync_date` DESC) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品skc销量';

-- ----------------------------
-- Table structure for wms_commodity_skc_shop_sale
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_skc_shop_sale`;
CREATE TABLE `wms_commodity_skc_shop_sale` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `commodity_id` bigint DEFAULT NULL COMMENT '产品id',
  `commodity_skc_id` bigint NOT NULL COMMENT '产品skcId',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `fifteen_days_sale_num` int DEFAULT '0' COMMENT '近15天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `sync_date` date NOT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_shop_skc_date_delete` (`shop_id`,`commodity_skc_id`,`sync_date`,`is_delete`) USING BTREE,
  UNIQUE KEY `uni_idx_company_date_shop_skc` (`company_id`,`sync_date`,`shop_id`,`commodity_skc_id`,`is_delete`),
  KEY `idx_sync_date` (`sync_date` DESC) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品skc店铺销量';

-- ----------------------------
-- Table structure for wms_commodity_skc_shop_stock
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_skc_shop_stock`;
CREATE TABLE `wms_commodity_skc_shop_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint NOT NULL COMMENT '产品id',
  `commodity_skc_id` bigint NOT NULL COMMENT '产品skcId',
  `shop_id` bigint NOT NULL COMMENT '产品id',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `sync_date` date NOT NULL COMMENT '数据同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_shop_skc` (`company_id`,`sync_date` DESC,`shop_id`,`commodity_skc_id`,`is_delete`) USING BTREE,
  KEY `company_id_index` (`company_id`) USING BTREE,
  KEY `commodity_id_index` (`commodity_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品skc店铺库存';

-- ----------------------------
-- Table structure for wms_commodity_skc_stock
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_skc_stock`;
CREATE TABLE `wms_commodity_skc_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint NOT NULL COMMENT '产品id',
  `commodity_skc_id` bigint NOT NULL COMMENT '产品skcId',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `sync_date` date NOT NULL COMMENT '数据同步日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_skc` (`company_id`,`sync_date` DESC,`commodity_skc_id`,`is_delete`) USING BTREE,
  KEY `company_id_index` (`company_id`) USING BTREE,
  KEY `commodity_id_index` (`commodity_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品skc库存';

-- ----------------------------
-- Table structure for wms_commodity_sku_occupied_stock
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_sku_occupied_stock`;
CREATE TABLE `wms_commodity_sku_occupied_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '企业ID字段',
  `commodity_id` bigint NOT NULL COMMENT '产品SKU ID',
  `commodity_skc_id` bigint NOT NULL COMMENT '产品SKC ID',
  `commodity_sku_id` bigint NOT NULL COMMENT '产品SKU ID',
  `commodity_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品款式编码',
  `commodity_sku_code` varchar(100) NOT NULL COMMENT '产品SKU编号',
  `wms_co_id` bigint NOT NULL COMMENT 'WMS系统中的公司ID',
  `purchase_qty` int DEFAULT '0' COMMENT '采购在途数',
  `min_qty` int DEFAULT NULL COMMENT '安全库存下限',
  `allocate_qty` int DEFAULT '0' COMMENT '调拨在途数',
  `virtual_qty` int DEFAULT '0' COMMENT '虚拟库存量',
  `order_lock` int DEFAULT '0' COMMENT '订单锁定数量',
  `max_qty` int DEFAULT NULL COMMENT '安全库存上限',
  `pick_lock` int DEFAULT '0' COMMENT '仓库待发数',
  `qty` int NOT NULL COMMENT '主仓实际库存',
  `in_qty` int DEFAULT '0' COMMENT '进货仓库存',
  `defective_qty` int DEFAULT '0' COMMENT '次品库存',
  `return_qty` int DEFAULT '0' COMMENT '销退仓库存',
  `lock_qty` int DEFAULT NULL COMMENT '库存锁定数',
  `sale_refund_qty` int DEFAULT NULL COMMENT '销退在途数',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `modified` datetime DEFAULT NULL COMMENT '聚水潭库存的最后修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_commodity_sku_co` (`company_id`,`commodity_sku_id`,`wms_co_id`),
  KEY `idx_company_co_sku` (`company_id`,`wms_co_id`,`commodity_sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品的商品占用库存信息表';

-- ----------------------------
-- Table structure for wms_commodity_sku_sale
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_sku_sale`;
CREATE TABLE `wms_commodity_sku_sale` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint DEFAULT NULL COMMENT '产品id',
  `commodity_code` varchar(64) DEFAULT NULL COMMENT '产品编码',
  `commodity_skc_id` bigint DEFAULT NULL COMMENT '产品skcId',
  `commodity_sku_id` bigint NOT NULL COMMENT '产品skuId',
  `supplier_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku供应商编码',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `fifteen_days_sale_num` int DEFAULT '0' COMMENT '近15天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `total_sale_volume` int DEFAULT NULL COMMENT '总销量',
  `today_sale_amount` decimal(24,6) DEFAULT NULL COMMENT '今日销售额',
  `sync_date` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '同步日期',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_sku` (`sync_date` DESC,`commodity_sku_id`,`is_delete`),
  UNIQUE KEY `uni_idx_sku_date_delete` (`commodity_sku_id`,`sync_date`,`is_delete`),
  KEY `index_company_end_date_warehouse` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品sku销量';

-- ----------------------------
-- Table structure for wms_commodity_sku_shop_sale
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_sku_shop_sale`;
CREATE TABLE `wms_commodity_sku_shop_sale` (
  `id` bigint NOT NULL COMMENT '主键ID',
  `company_id` bigint NOT NULL COMMENT '企业id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `commodity_id` bigint DEFAULT NULL COMMENT '产品id',
  `commodity_skc_id` bigint DEFAULT NULL COMMENT '产品skcId',
  `commodity_sku_id` bigint NOT NULL COMMENT '产品skuId',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `fifteen_days_sale_num` int DEFAULT '0' COMMENT '近15天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `total_sale_volume` int DEFAULT NULL COMMENT '总销量',
  `sync_date` date NOT NULL COMMENT '数据同步日期',
  `is_delete` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_sku` (`company_id`,`sync_date` DESC,`shop_id`,`commodity_sku_id`,`is_delete`) USING BTREE,
  KEY `idx_shop_id` (`shop_id`) USING BTREE,
  KEY `idx_commodity_id` (`commodity_id`) USING BTREE,
  KEY `idx_commodity_sku_id` (`commodity_sku_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品SKU店铺销量表';

-- ----------------------------
-- Table structure for wms_commodity_sku_shop_stock
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_sku_shop_stock`;
CREATE TABLE `wms_commodity_sku_shop_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint NOT NULL COMMENT '产品id',
  `commodity_skc_id` bigint DEFAULT NULL COMMENT '产品skcId',
  `commodity_sku_id` bigint NOT NULL COMMENT '产品skuId',
  `shop_id` bigint NOT NULL COMMENT '产品id',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `sync_date` date NOT NULL COMMENT '数据同步日期',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_sku` (`company_id`,`sync_date` DESC,`shop_id`,`commodity_sku_id`,`is_delete`) USING BTREE,
  KEY `company_id_index` (`company_id`) USING BTREE,
  KEY `commodity_id_index` (`commodity_id`) USING BTREE,
  KEY `idx_optimized_query` (`sync_date`,`company_id`,`is_delete`,`shop_id`,`commodity_id`,`commodity_sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for wms_commodity_sku_stock
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_sku_stock`;
CREATE TABLE `wms_commodity_sku_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint DEFAULT NULL COMMENT '产品id',
  `commodity_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品spu编码',
  `commodity_name` varchar(128) DEFAULT NULL COMMENT '产品名称',
  `commodity_skc_id` bigint DEFAULT NULL COMMENT '产品skcId',
  `commodity_sku_id` bigint NOT NULL COMMENT '产品skuId',
  `supplier_sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商sku编码',
  `mini_stock_num` int DEFAULT NULL COMMENT '最低库存数量',
  `pre_stock_num` int DEFAULT '0' COMMENT '预扣库存数量',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `virtual_stock_num` int DEFAULT '0' COMMENT '虚拟库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `total_stock_num` int DEFAULT '0' COMMENT '总库存数量',
  `sync_date` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'curdate()' COMMENT '数据同步时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_sku` (`sync_date` DESC,`commodity_sku_id`,`is_delete`) USING BTREE,
  KEY `index_sku_id` (`commodity_sku_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='产品sku库存信息';

-- ----------------------------
-- Table structure for wms_commodity_stock
-- ----------------------------
DROP TABLE IF EXISTS `wms_commodity_stock`;
CREATE TABLE `wms_commodity_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `commodity_id` bigint NOT NULL COMMENT '产品id',
  `commodity_code` varchar(128) DEFAULT NULL COMMENT '产品编码',
  `commodity_name` varchar(255) DEFAULT NULL COMMENT '产品名称',
  `code_number` varchar(128) DEFAULT NULL COMMENT 'spu货号',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `sync_date` varchar(64) NOT NULL DEFAULT 'curdate()' COMMENT '同步日期',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uni_idx_date_spu` (`sync_date` DESC,`commodity_id`,`is_delete`) USING BTREE,
  KEY `company_id_index` (`company_id`) USING BTREE,
  KEY `sync_date_index` (`sync_date`) USING BTREE,
  KEY `commodity_id_index` (`commodity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品spu库存';

-- ----------------------------
-- Table structure for wms_delivery_order
-- ----------------------------
DROP TABLE IF EXISTS `wms_delivery_order`;
CREATE TABLE `wms_delivery_order` (
  `id` bigint NOT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT 'spu id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `skc_code` varchar(32) DEFAULT NULL COMMENT 'skc编码',
  `delivery_order_sn` varchar(32) DEFAULT NULL COMMENT '发货单号',
  `delivery_method` tinyint DEFAULT '0' COMMENT '发货方式: [0:无;1:自送;2:公司指定物流;3:第三方物流;]',
  `express_delivery_sn` varchar(32) DEFAULT NULL COMMENT '快递单号',
  `express_contact_number` varchar(24) DEFAULT NULL COMMENT '快递电话号码',
  `expect_pick_up_goods_time` bigint DEFAULT NULL COMMENT '预约取货时间(毫秒)',
  `receive_warehouse_name` varchar(32) DEFAULT NULL COMMENT '收货仓名称',
  `delivery_warehouse_name` varchar(32) DEFAULT NULL COMMENT '发货仓名称',
  `purchase_num` int DEFAULT NULL COMMENT '下单数量',
  `deliver_num` int DEFAULT NULL COMMENT '实发数量',
  `receive_num` int DEFAULT NULL COMMENT '实收数量',
  `package_sn` json DEFAULT NULL COMMENT '包裹号',
  `deliver_time` bigint DEFAULT NULL COMMENT '发货时间(毫秒)',
  `receive_time` bigint DEFAULT NULL COMMENT '收货时间(毫秒)',
  `inbound_time` bigint DEFAULT NULL COMMENT '入库时间(毫秒)',
  `status` tinyint DEFAULT NULL COMMENT '发货单状态，0：待装箱发货，1：待仓库收货，2：已收货，3：已入库，4：已退货，5：已取消，6：部分收货',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `index_company_skc` (`company_id`,`shop_id`,`skc_id`,`delivery_order_sn`,`is_delete`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='发货单';

-- ----------------------------
-- Table structure for wms_delivery_order_bk
-- ----------------------------
DROP TABLE IF EXISTS `wms_delivery_order_bk`;
CREATE TABLE `wms_delivery_order_bk` (
  `id` bigint NOT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT 'spu id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `skc_code` varchar(32) DEFAULT NULL COMMENT 'skc编码',
  `delivery_order_sn` varchar(32) DEFAULT NULL COMMENT '发货单号',
  `delivery_method` tinyint DEFAULT '0' COMMENT '发货方式: [0:无;1:自送;2:公司指定物流;3:第三方物流;]',
  `express_delivery_sn` varchar(32) DEFAULT NULL COMMENT '快递单号',
  `express_contact_number` varchar(24) DEFAULT NULL COMMENT '快递电话号码',
  `expect_pick_up_goods_time` bigint DEFAULT NULL COMMENT '预约取货时间(毫秒)',
  `receive_warehouse_name` varchar(32) DEFAULT NULL COMMENT '收货仓名称',
  `delivery_warehouse_name` varchar(32) DEFAULT NULL COMMENT '发货仓名称',
  `purchase_num` int DEFAULT NULL COMMENT '下单数量',
  `deliver_num` int DEFAULT NULL COMMENT '实发数量',
  `receive_num` int DEFAULT NULL COMMENT '实收数量',
  `package_sn` json DEFAULT NULL COMMENT '包裹号',
  `deliver_time` bigint DEFAULT NULL COMMENT '发货时间(毫秒)',
  `receive_time` bigint DEFAULT NULL COMMENT '收货时间(毫秒)',
  `inbound_time` bigint DEFAULT NULL COMMENT '入库时间(毫秒)',
  `status` tinyint DEFAULT NULL COMMENT '发货单状态，0：待装箱发货，1：待仓库收货，2：已收货，3：已入库，4：已退货，5：已取消，6：部分收货',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `index_company_skc` (`company_id`,`shop_id`,`skc_id`,`delivery_order_sn`,`is_delete`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='发货单';

-- ----------------------------
-- Table structure for wms_input_item
-- ----------------------------
DROP TABLE IF EXISTS `wms_input_item`;
CREATE TABLE `wms_input_item` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `input_record_id` bigint DEFAULT NULL COMMENT '入库记录id',
  `spu_id` bigint DEFAULT NULL COMMENT '商品id',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_num` int DEFAULT NULL COMMENT '入库数量',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否生效',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='库存入库明细\n';

-- ----------------------------
-- Table structure for wms_input_record
-- ----------------------------
DROP TABLE IF EXISTS `wms_input_record`;
CREATE TABLE `wms_input_record` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `operate_type` int DEFAULT NULL COMMENT '操作类型',
  `operate_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作流水号',
  `operate_num` int DEFAULT NULL COMMENT '入库数量',
  `operate_status` int DEFAULT NULL COMMENT '操作状态',
  `operate_time` datetime DEFAULT NULL COMMENT '操作时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否生效',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='库存入库记录';

-- ----------------------------
-- Table structure for wms_inventory_transfer
-- ----------------------------
DROP TABLE IF EXISTS `wms_inventory_transfer`;
CREATE TABLE `wms_inventory_transfer` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `trans_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '调拨单号',
  `warehouse_id` bigint DEFAULT NULL COMMENT '仓库id',
  `trans_source` tinyint DEFAULT '1' COMMENT '来源：1.全仓分析，2.手工创建',
  `trans_type` tinyint DEFAULT '1' COMMENT '类型：1.成品，2.生产',
  `sku_num` int DEFAULT '0' COMMENT 'sku数量',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_code` (`company_id`,`trans_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='库存调拨单';

-- ----------------------------
-- Table structure for wms_inventory_transfer_item
-- ----------------------------
DROP TABLE IF EXISTS `wms_inventory_transfer_item`;
CREATE TABLE `wms_inventory_transfer_item` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `warehouse_id` bigint DEFAULT NULL COMMENT '仓库id',
  `trans_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '调拨单号',
  `trans_item_code` varchar(64) DEFAULT NULL COMMENT '调拨明细单号',
  `spu_code` varchar(64) DEFAULT NULL COMMENT 'spu 编码',
  `sku_code` varchar(64) DEFAULT '0' COMMENT 'sku 编码',
  `sku_num` int DEFAULT NULL COMMENT 'sku 数量',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_code` (`company_id`,`trans_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='库存调拨单';

-- ----------------------------
-- Table structure for wms_jst_inventory
-- ----------------------------
DROP TABLE IF EXISTS `wms_jst_inventory`;
CREATE TABLE `wms_jst_inventory` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '企业ID字段',
  `i_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '款式编码',
  `purchase_qty` int DEFAULT '0' COMMENT '采购在途数',
  `min_qty` int DEFAULT NULL COMMENT '安全库存下限',
  `allocate_qty` int DEFAULT '0' COMMENT '调拨在途数',
  `platform_sku_id` varchar(100) NOT NULL COMMENT '聚水潭SKU编号',
  `virtual_qty` int DEFAULT '0' COMMENT '虚拟库存量',
  `order_lock` int DEFAULT '0' COMMENT '订单锁定数量',
  `max_qty` int DEFAULT NULL COMMENT '安全库存上限',
  `pick_lock` int DEFAULT '0' COMMENT '仓库待发数',
  `wms_co_id` bigint NOT NULL COMMENT 'WMS系统中的公司ID',
  `qty` int NOT NULL COMMENT '主仓实际库存',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '物品名称',
  `modified` datetime NOT NULL COMMENT '最后修改时间',
  `in_qty` int DEFAULT '0' COMMENT '进货仓库存',
  `defective_qty` int DEFAULT '0' COMMENT '次品库存',
  `return_qty` int DEFAULT '0' COMMENT '销退仓库存',
  `ts` bigint DEFAULT NULL COMMENT '时间戳',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `lock_qty` int DEFAULT NULL COMMENT '库存锁定数',
  `sale_refund_qty` int DEFAULT NULL COMMENT '销退在途数',
  PRIMARY KEY (`id`),
  KEY `idx_company_sku_id` (`company_id`,`platform_sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聚水潭库存信息表';

-- ----------------------------
-- Table structure for wms_jst_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `wms_jst_warehouse`;
CREATE TABLE `wms_jst_warehouse` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL COMMENT '公司ID',
  `wms_co_id` bigint NOT NULL COMMENT 'WMS系统中的公司ID',
  `is_main` tinyint(1) DEFAULT '0' COMMENT '是否为主公司',
  `name` varchar(100) NOT NULL COMMENT '仓库名称',
  `co_id` bigint NOT NULL COMMENT '聚水潭公司ID',
  `remark1` varchar(255) DEFAULT '' COMMENT '备注1',
  `status` varchar(20) NOT NULL COMMENT '状态(生效/失效等)',
  `remark2` varchar(255) DEFAULT '' COMMENT '备注2',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聚水潭仓库信息表';

-- ----------------------------
-- Table structure for wms_output_item
-- ----------------------------
DROP TABLE IF EXISTS `wms_output_item`;
CREATE TABLE `wms_output_item` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `output_record_id` bigint DEFAULT NULL COMMENT '出库记录id',
  `spu_id` bigint DEFAULT NULL COMMENT '商品id',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_num` int DEFAULT NULL COMMENT '入库数量',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否生效',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='库存出库明细';

-- ----------------------------
-- Table structure for wms_output_record
-- ----------------------------
DROP TABLE IF EXISTS `wms_output_record`;
CREATE TABLE `wms_output_record` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `operate_type` int DEFAULT NULL COMMENT '操作类型',
  `operate_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作流水号',
  `operate_num` int DEFAULT NULL COMMENT '出库数量',
  `operate_time` datetime DEFAULT NULL COMMENT '出库时间',
  `operate_status` int DEFAULT NULL COMMENT '出库状态',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `is_useful` tinyint DEFAULT NULL COMMENT '是否生效',
  `is_delete` tinyint DEFAULT NULL COMMENT '是否删除',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='库存出库记录';

-- ----------------------------
-- Table structure for wms_purchase_order
-- ----------------------------
DROP TABLE IF EXISTS `wms_purchase_order`;
CREATE TABLE `wms_purchase_order` (
  `id` bigint NOT NULL,
  `purchase_plan_id` bigint DEFAULT NULL COMMENT '采购计划id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `code_number` varchar(128) DEFAULT NULL COMMENT '货号',
  `spu_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '产品名称',
  `skc_id` bigint DEFAULT NULL COMMENT 'skcId',
  `custom_code` varchar(64) DEFAULT NULL COMMENT 'skc自定义编码',
  `file_url` varchar(256) DEFAULT NULL COMMENT '图片地址',
  `category_id` bigint DEFAULT NULL COMMENT '分类',
  `category_name` varchar(64) DEFAULT NULL COMMENT '分类',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_purchase_plan_id` (`purchase_plan_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='备货采购单';

-- ----------------------------
-- Table structure for wms_purchase_order_item
-- ----------------------------
DROP TABLE IF EXISTS `wms_purchase_order_item`;
CREATE TABLE `wms_purchase_order_item` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `purchase_plan_id` bigint DEFAULT NULL COMMENT '采购计划id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skcId',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuId',
  `custom_code` varchar(64) DEFAULT NULL COMMENT 'sku自定义编码',
  `spec_values_str` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '规格值拼接',
  `price` decimal(20,10) NOT NULL DEFAULT '0.0000000000' COMMENT '申报价格',
  `daily_average` int DEFAULT '0' COMMENT '加权日均销量',
  `short_num` int DEFAULT '0' COMMENT '缺货数量',
  `suggest_num` int DEFAULT '0' COMMENT '建议采购量',
  `actual_num` int DEFAULT '0' COMMENT '实际采购量',
  `status` tinyint DEFAULT '1' COMMENT '供货状态：0-不正常, 1-正常',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_custom_code` (`company_id`,`custom_code`) USING BTREE,
  KEY `index_purchase_plan_id_skc_id` (`purchase_plan_id`,`skc_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='备货采购单明细';

-- ----------------------------
-- Table structure for wms_purchase_plan
-- ----------------------------
DROP TABLE IF EXISTS `wms_purchase_plan`;
CREATE TABLE `wms_purchase_plan` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `summary_sn` varchar(64) DEFAULT NULL COMMENT '合并单号',
  `code` varchar(64) DEFAULT NULL COMMENT '编号',
  `warehouse_id` bigint DEFAULT NULL COMMENT '仓库id',
  `source` tinyint DEFAULT '1' COMMENT '来源：1.全仓分析，2.手工创建',
  `type` tinyint DEFAULT '1' COMMENT '类型：1.成品，2.生产',
  `sku_num` int DEFAULT '0' COMMENT 'sku数量',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `channel_type` tinyint DEFAULT NULL COMMENT '渠道类型',
  `channel_model` tinyint DEFAULT NULL COMMENT '渠道模式',
  `stl_code` varchar(32) DEFAULT NULL COMMENT '款式编码',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_code` (`company_id`,`code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='备货采购计划';

-- ----------------------------
-- Table structure for wms_purchase_plan_summary
-- ----------------------------
DROP TABLE IF EXISTS `wms_purchase_plan_summary`;
CREATE TABLE `wms_purchase_plan_summary` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `summary_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '合并单号',
  `task_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '审批单号',
  `verify_status` tinyint DEFAULT '0' COMMENT '审批状态：0.未审批，1.审批中，2:已通过，3:未通过，4:已作废',
  `verify_user_id` bigint DEFAULT NULL COMMENT '审批发起人',
  `verify_time` datetime DEFAULT NULL COMMENT '审批发起时间',
  `scm_sync_status` tinyint DEFAULT '0' COMMENT '同步scm采购单标记【0:未同步，1:已同步】',
  `scm_sync_time` datetime DEFAULT NULL COMMENT '同步scm 采购单时间',
  `scm_purchase_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '同步scm 采购单单号',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否生效【1: 有效，0:无效】',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `channel_type` tinyint DEFAULT NULL COMMENT '渠道类型',
  `channel_model` tinyint DEFAULT NULL COMMENT '渠道模式',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_code` (`company_id`,`summary_sn`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='备货采购计划';

-- ----------------------------
-- Table structure for wms_shop_warehouse_relation
-- ----------------------------
DROP TABLE IF EXISTS `wms_shop_warehouse_relation`;
CREATE TABLE `wms_shop_warehouse_relation` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `warehouse_id` bigint DEFAULT NULL COMMENT '仓库id',
  `relation_type` tinyint DEFAULT NULL COMMENT '关系类型: {1-默认仓库, 2-备选仓库, 3-退货仓库, 4-发货仓库}',
  `priority` int DEFAULT NULL COMMENT '优先级，数值越小优先级越高',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1950194615860727840 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺仓库关系表';

-- ----------------------------
-- Table structure for wms_sku_sale
-- ----------------------------
DROP TABLE IF EXISTS `wms_sku_sale`;
CREATE TABLE `wms_sku_sale` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_code` varchar(128) DEFAULT NULL COMMENT 'sku编码',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `fifteen_days_sale_num` int DEFAULT '0' COMMENT '近15天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `total_sale_volume` int DEFAULT NULL COMMENT '总销量',
  `end_date` date NOT NULL DEFAULT (curdate()) COMMENT '数据统计截止日',
  `warehouse_id` bigint DEFAULT '0' COMMENT '仓库id',
  `today_sale_amount` decimal(24,6) DEFAULT NULL COMMENT '今日销售额',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk` (`company_id`,`sku_id`,`warehouse_id`,`end_date`,`is_delete`),
  KEY `index_company_end_date_warehouse` (`company_id`,`end_date` DESC,`warehouse_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品sku销量';

-- ----------------------------
-- Table structure for wms_sku_sale_bk
-- ----------------------------
DROP TABLE IF EXISTS `wms_sku_sale_bk`;
CREATE TABLE `wms_sku_sale_bk` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sku_code` varchar(128) DEFAULT NULL COMMENT 'sku编码',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `fifteen_days_sale_num` int DEFAULT '0' COMMENT '近15天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `total_sale_volume` int DEFAULT NULL COMMENT '总销量',
  `end_date` date NOT NULL DEFAULT (curdate()) COMMENT '数据统计截止日',
  `warehouse_id` bigint DEFAULT '0' COMMENT '仓库id',
  `today_sale_amount` decimal(24,6) DEFAULT NULL COMMENT '今日销售额',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk` (`company_id`,`sku_id`,`warehouse_id`,`end_date`,`is_delete`),
  KEY `index_company_end_date_warehouse` (`company_id`,`end_date` DESC,`warehouse_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='sku销量';

-- ----------------------------
-- Table structure for wms_sku_stock
-- ----------------------------
DROP TABLE IF EXISTS `wms_sku_stock`;
CREATE TABLE `wms_sku_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu编码',
  `code_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu货号',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuId',
  `sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `custom_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku自定义编码',
  `mini_stock_num` int DEFAULT NULL COMMENT '最低库存数量',
  `pre_stock_num` int DEFAULT '0' COMMENT '预扣库存数量',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `virtual_stock_num` int DEFAULT '0' COMMENT '虚拟库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `total_stock_num` int DEFAULT '0' COMMENT '总库存数量',
  `sync_date` date NOT NULL DEFAULT (curdate()) COMMENT '数据同步时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有用：0-否, 1-是',
  `jst_stock` int DEFAULT '0' COMMENT '聚水潭库存',
  `warehouse_id` bigint DEFAULT NULL COMMENT '仓库id',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk` (`company_id`,`sku_id`,`warehouse_id`,`sync_date` DESC,`is_delete`) USING BTREE,
  KEY `index_sku_id` (`sku_id`) USING BTREE,
  KEY `index_company_spu_num` (`company_id`,`spu_id`,`sale_stock_num`) USING BTREE,
  KEY `idx_sync_date_warehouse` (`sync_date` DESC,`warehouse_id`) USING BTREE,
  KEY `idx_sync_date_spu_id` (`sync_date` DESC,`spu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='产品sku库存信息';

-- ----------------------------
-- Table structure for wms_sku_stock_bk
-- ----------------------------
DROP TABLE IF EXISTS `wms_sku_stock_bk`;
CREATE TABLE `wms_sku_stock_bk` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu编码',
  `code_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu货号',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuId',
  `sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `custom_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku自定义编码',
  `mini_stock_num` int DEFAULT NULL COMMENT '最低库存数量',
  `pre_stock_num` int DEFAULT '0' COMMENT '预扣库存数量',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `virtual_stock_num` int DEFAULT '0' COMMENT '虚拟库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `total_stock_num` int DEFAULT '0' COMMENT '总库存数量',
  `sync_date` date NOT NULL DEFAULT (curdate()) COMMENT '数据同步时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否有用：0-否, 1-是',
  `jst_stock` int DEFAULT '0' COMMENT '聚水潭库存',
  `warehouse_id` bigint DEFAULT NULL COMMENT '仓库id',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk` (`company_id`,`sku_id`,`warehouse_id`,`sync_date` DESC,`is_delete`) USING BTREE,
  KEY `index_sku_id` (`sku_id`) USING BTREE,
  KEY `index_company_spu_num` (`company_id`,`spu_id`,`sale_stock_num`) USING BTREE,
  KEY `idx_sync_date_warehouse` (`sync_date` DESC,`warehouse_id`) USING BTREE,
  KEY `idx_sync_date_spu_id` (`sync_date` DESC,`spu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品sku库存信息';

-- ----------------------------
-- Table structure for wms_sku_stock_history
-- ----------------------------
DROP TABLE IF EXISTS `wms_sku_stock_history`;
CREATE TABLE `wms_sku_stock_history` (
  `id` bigint NOT NULL,
  `stock_id` bigint DEFAULT NULL COMMENT '库存id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu编码',
  `spu_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu名称',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuId',
  `sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku名称',
  `mini_stock_num` int DEFAULT NULL COMMENT '最低库存数量',
  `pre_stock_num` int DEFAULT '0' COMMENT '预扣库存数量',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `virtual_stock_num` int DEFAULT '0' COMMENT '虚拟库存数量',
  `total_stock_num` int DEFAULT '0' COMMENT '总库存数量',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品sku库存历史信息';

-- ----------------------------
-- Table structure for wms_sku_stock_inventory
-- ----------------------------
DROP TABLE IF EXISTS `wms_sku_stock_inventory`;
CREATE TABLE `wms_sku_stock_inventory` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `spu_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu编码',
  `spu_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'spu名称',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuId',
  `sku_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'sku名称',
  `mini_stock_num` int DEFAULT NULL COMMENT '最低库存数量',
  `pre_stock_num` int DEFAULT '0' COMMENT '预扣库存数量',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `virtual_stock_num` int DEFAULT '0' COMMENT '虚拟库存数量',
  `total_stock_num` int DEFAULT '0' COMMENT '总库存数量',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_delete` tinyint DEFAULT NULL,
  `is_useful` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='商品sku库存盘点信息';

-- ----------------------------
-- Table structure for wms_sku_stock_statistic
-- ----------------------------
DROP TABLE IF EXISTS `wms_sku_stock_statistic`;
CREATE TABLE `wms_sku_stock_statistic` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuId',
  `sku_code` varchar(128) DEFAULT NULL COMMENT 'sku编码',
  `custom_code` varchar(64) DEFAULT NULL COMMENT 'sku自定义编码',
  `today` int DEFAULT '0' COMMENT '今日销量',
  `week` int DEFAULT '0' COMMENT '近7日销量',
  `month` int DEFAULT '0' COMMENT '本月销量',
  `last_month` int DEFAULT '0' COMMENT '上月销量',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `warehouse_stock_num` int DEFAULT '0' COMMENT '仓库库存',
  `prepare_stock_num` int DEFAULT '0' COMMENT '备货库存',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk` (`company_id`,`sku_id`,`is_delete`),
  KEY `index_company_custom_code` (`company_id`,`custom_code`) USING BTREE,
  KEY `index_spu_id` (`spu_id` DESC) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1978365269894107140 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='sku库存和销量统计';

-- ----------------------------
-- Table structure for wms_sku_stock_statistic_bk
-- ----------------------------
DROP TABLE IF EXISTS `wms_sku_stock_statistic_bk`;
CREATE TABLE `wms_sku_stock_statistic_bk` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint DEFAULT NULL COMMENT 'skuId',
  `sku_code` varchar(128) DEFAULT NULL COMMENT 'sku编码',
  `custom_code` varchar(64) DEFAULT NULL COMMENT 'sku自定义编码',
  `today` int DEFAULT '0' COMMENT '今日销量',
  `week` int DEFAULT '0' COMMENT '近7日销量',
  `month` int DEFAULT '0' COMMENT '本月销量',
  `last_month` int DEFAULT '0' COMMENT '上月销量',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `warehouse_stock_num` int DEFAULT '0' COMMENT '仓库库存',
  `prepare_stock_num` int DEFAULT '0' COMMENT '备货库存',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk` (`company_id`,`sku_id`,`is_delete`),
  KEY `index_company_custom_code` (`company_id`,`custom_code`) USING BTREE,
  KEY `index_spu_id` (`spu_id` DESC) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1950742772575244531 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='sku库存和销量统计';

-- ----------------------------
-- Table structure for wms_spu_sale
-- ----------------------------
DROP TABLE IF EXISTS `wms_spu_sale`;
CREATE TABLE `wms_spu_sale` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `spu_code` varchar(128) DEFAULT NULL COMMENT 'spu编码',
  `today_sale_num` int DEFAULT '0' COMMENT '今日销量',
  `seven_days_sale_num` int DEFAULT '0' COMMENT '近7天销量',
  `thirty_days_sale_num` int DEFAULT '0' COMMENT '近30天销量',
  `end_date` date NOT NULL DEFAULT (curdate()) COMMENT '数据统计截止日',
  `sync_date` varchar(64) DEFAULT NULL COMMENT '数据同步时间',
  `warehouse_id` bigint DEFAULT '0' COMMENT '仓库id',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_spu` (`company_id`,`spu_id`) USING BTREE,
  KEY `sync_date_index` (`sync_date`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品spu销量';

-- ----------------------------
-- Table structure for wms_spu_stock
-- ----------------------------
DROP TABLE IF EXISTS `wms_spu_stock`;
CREATE TABLE `wms_spu_stock` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `code_number` varchar(128) DEFAULT NULL COMMENT 'spu货号',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `warehouse_id` bigint DEFAULT '0' COMMENT '仓库id',
  `sync_date` date NOT NULL DEFAULT (curdate()) COMMENT '同步日期',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_spu_id` (`spu_id` DESC) USING BTREE,
  KEY `company_id_index` (`company_id`) USING BTREE,
  KEY `sync_date_index` (`sync_date`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品spu库存';

-- ----------------------------
-- Table structure for wms_spu_stock_statistic
-- ----------------------------
DROP TABLE IF EXISTS `wms_spu_stock_statistic`;
CREATE TABLE `wms_spu_stock_statistic` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `spu_name` varchar(128) DEFAULT NULL COMMENT 'spu名称',
  `code_number` varchar(128) DEFAULT NULL COMMENT 'spu货号',
  `today` int DEFAULT '0' COMMENT '今日销量',
  `week` int DEFAULT '0' COMMENT '近7日销量',
  `month` int DEFAULT '0' COMMENT '本月销量',
  `last_month` int DEFAULT NULL COMMENT '上月销量',
  `lock_stock_num` int DEFAULT '0' COMMENT '锁定库存数量',
  `sale_stock_num` int DEFAULT '0' COMMENT '在售库存数量',
  `actual_stock_num` int DEFAULT '0' COMMENT '实物库存数量',
  `intransit_stock_num` int DEFAULT '0' COMMENT '在途库存数量',
  `warehouse_stock_num` int DEFAULT '0' COMMENT '仓库库存',
  `prepare_stock_num` int DEFAULT '0' COMMENT '备货库存',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_spu_id` (`spu_id` DESC) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='spu库存和销量统计';

-- ----------------------------
-- Table structure for wms_stock_up_order
-- ----------------------------
DROP TABLE IF EXISTS `wms_stock_up_order`;
CREATE TABLE `wms_stock_up_order` (
  `id` bigint NOT NULL,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `spu_id` bigint DEFAULT NULL COMMENT 'spu id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `skc_code` varchar(32) DEFAULT NULL COMMENT 'skc编码',
  `stock_up_order_sn` varchar(32) DEFAULT NULL COMMENT '备货单号',
  `deliver_time` bigint DEFAULT NULL COMMENT '发货时间(毫秒)',
  `receive_time` bigint DEFAULT NULL COMMENT '收货时间(毫秒)',
  `deliver_order_sn` varchar(32) DEFAULT NULL COMMENT '发货单号',
  `expect_latest_deliver_time` bigint DEFAULT NULL COMMENT '最晚发货时间(毫秒)',
  `expect_latest_arrival_time` bigint DEFAULT NULL COMMENT '最晚到达时间(毫秒)',
  `receive_warehouse_name` varchar(32) DEFAULT NULL COMMENT '收货仓库名称',
  `purchase_time` bigint DEFAULT NULL COMMENT '下单时间（毫秒数）',
  `status` tinyint DEFAULT '0' COMMENT '状态：0-待接单；1-已接单，待发货；2-已送货；3-已收货；4-已拒收；5-已验收，全部退回；6-已验收；7-已入库；8-作废；9-已超时；10-已取消',
  `is_can_join_deliver_platform` tinyint(1) DEFAULT '0' COMMENT '是否可以加入发货台：0-否，1-是',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `index_company_skc` (`company_id`,`shop_id`,`skc_id`,`stock_up_order_sn`,`is_delete`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='备货单';

-- ----------------------------
-- Table structure for wms_stock_up_order_sku
-- ----------------------------
DROP TABLE IF EXISTS `wms_stock_up_order_sku`;
CREATE TABLE `wms_stock_up_order_sku` (
  `id` bigint NOT NULL,
  `stock_up_order_id` bigint DEFAULT NULL COMMENT '备货单id',
  `sku_id` bigint NOT NULL COMMENT 'sku id',
  `sku_code` varchar(32) DEFAULT NULL COMMENT 'sku编码',
  `purchase_quantity` int DEFAULT '0' COMMENT '备货数量',
  `deliver_quantity` int DEFAULT '0' COMMENT '送货数量',
  `real_receive_authentic_quantity` int DEFAULT '0' COMMENT '入库数量',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_stock_up_order_id` (`stock_up_order_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='备货单sku';

-- ----------------------------
-- Table structure for wms_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `wms_warehouse`;
CREATE TABLE `wms_warehouse` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL DEFAULT '0' COMMENT '企业id',
  `country` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '国家',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓库名称',
  `platform` tinyint DEFAULT NULL COMMENT '平台: 1-聚水潭, 2-SHEIN, 3-TEMU',
  `type` tinyint DEFAULT NULL COMMENT '类型: 1-平台, 2-自建仓库, 3.第三方',
  `total_amount` decimal(20,4) DEFAULT '0.0000' COMMENT '库存货值',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  `is_useful` tinyint DEFAULT '1' COMMENT '是否启用：0-停用, 1-启用',
  `platform_warehouse_id` varchar(128) DEFAULT NULL COMMENT '第三方仓库id',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `detail_address` varchar(255) DEFAULT NULL COMMENT '详细地址',
  `zipcode` varchar(20) DEFAULT NULL COMMENT '邮编',
  `phone` varchar(30) DEFAULT NULL COMMENT '联系电话',
  `warehouse_sp_id` int DEFAULT NULL COMMENT '仓库服务商ID',
  `warehouse_sp_name` varchar(32) DEFAULT NULL COMMENT '仓库服务商名称',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='仓库信息表';

-- ----------------------------
-- Table structure for wms_warehouse_analysis
-- ----------------------------
DROP TABLE IF EXISTS `wms_warehouse_analysis`;
CREATE TABLE `wms_warehouse_analysis` (
  `id` bigint NOT NULL,
  `company_id` bigint DEFAULT NULL COMMENT '企业id',
  `warehouse_id` bigint DEFAULT NULL COMMENT '仓库id',
  `spu_id` bigint DEFAULT NULL COMMENT '产品id',
  `skc_id` bigint DEFAULT NULL COMMENT 'skc id',
  `sku_id` bigint DEFAULT NULL COMMENT 'sku id',
  `sales_num_list` varchar(128) DEFAULT NULL COMMENT '销量列表',
  `daily_average` int DEFAULT '0' COMMENT '加权日均销量',
  `total_stock_num` int DEFAULT '0' COMMENT '库存总计',
  `safe_stock_num` int DEFAULT '0' COMMENT '安全库存',
  `total_demand_num` int DEFAULT '0' COMMENT '最大库存',
  `available_sale_days` int DEFAULT '0' COMMENT '库存可售天数',
  `health_degree` int DEFAULT '0' COMMENT '健康度: 1-请立刻备货, 2-建议备货, 3-正常',
  `stock_up_logic` varchar(64) DEFAULT NULL COMMENT '补货逻辑',
  `suggest_stock_up_num` int DEFAULT '0' COMMENT '建议补货量',
  `suggest_transport_mode` varchar(32) DEFAULT NULL COMMENT '建议运输方式',
  `adjust_stock_up_num` int DEFAULT '0' COMMENT '手工调整量',
  `actual_stock_up_num` int DEFAULT '0' COMMENT '实际补货量',
  `domestic_total_stock_num` int DEFAULT NULL COMMENT '国内仓库存总计',
  `domestic_available_sale_days` int DEFAULT NULL COMMENT '国内仓库存可售天数',
  `is_stock_up` tinyint DEFAULT NULL COMMENT '是否备货',
  `suggest_production_num` int DEFAULT '0' COMMENT '建议生产数量',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_sku` (`company_id`,`skc_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库分析结果表';

-- ----------------------------
-- Table structure for wms_warehouse_group
-- ----------------------------
DROP TABLE IF EXISTS `wms_warehouse_group`;
CREATE TABLE `wms_warehouse_group` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL DEFAULT '0' COMMENT '企业id',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '仓组名称',
  `type` tinyint DEFAULT NULL COMMENT '类型: 1-平台, 2-自建仓库, 3.第三方, 4.虚拟仓',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='仓组信息表';

-- ----------------------------
-- Table structure for wms_warehouse_group_relation
-- ----------------------------
DROP TABLE IF EXISTS `wms_warehouse_group_relation`;
CREATE TABLE `wms_warehouse_group_relation` (
  `id` bigint NOT NULL,
  `company_id` bigint NOT NULL DEFAULT '0' COMMENT '企业id',
  `warehouse_group_id` bigint NOT NULL COMMENT '仓组id',
  `warehouse_id` bigint NOT NULL COMMENT '仓库id',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` tinyint DEFAULT '0' COMMENT '是否删除：0-未删除, 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_company_id` (`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='仓组关系表';


-- ===========================================
-- 基于产品的断货点监控模型 - 数据库架构
-- Product-Based Stockout Monitoring Model - Database Schema
-- ===========================================
-- 
-- 本文件包含产品级别断货点监控模型的数据库表结构和存储过程
-- 用于集成国内仓余单/实物库存数据(amf_jh_company_stock)

-- ----------------------------
-- 1. 产品级别断货点监控快照表 (每日快照)
-- Product-Level Stockout Monitoring Snapshot Table (Daily Snapshot)
-- ----------------------------
DROP TABLE IF EXISTS `cos_oos_spu_monitor_daily`;
CREATE TABLE `cos_oos_spu_monitor_daily` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` BIGINT NOT NULL COMMENT '企业ID',
  `commodity_id` BIGINT NOT NULL COMMENT '产品ID（国内仓SPU）',
  `commodity_code` VARCHAR(128) COMMENT '产品编码',
  `monitor_date` DATE NOT NULL COMMENT '监控日期（快照日期）',
  
  -- 国内仓库存数据（来自amf_jh_company_stock）
  `domestic_remaining_qty` INT NOT NULL DEFAULT 0 COMMENT '国内仓余单数量 = SUM(remaining_num)',
  `domestic_actual_stock_qty` INT NOT NULL DEFAULT 0 COMMENT '国内仓实物库存 = SUM(stock_num)',
  `domestic_stock_sync_date` DATE COMMENT '国内仓库存同步日期（amf_jh_company_stock.sync_date）',
  
  -- 海外仓库存数据（聚合自SKU级别）
  `platform_total_onhand` INT NOT NULL DEFAULT 0 COMMENT '平台可售库存总量（所有SKU汇总）',
  `domestic_available_spu` INT NOT NULL DEFAULT 0 COMMENT '国内仓可用库存（wms_commodity_stock）',
  `open_intransit_qty` INT NOT NULL DEFAULT 0 COMMENT '直补在途未收数量（所有SKU汇总）',
  
  -- 需求与风险指标
  `weighted_daily_demand` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '加权日消耗率（所有SKU汇总）',
  `doc_days` DECIMAL(12,2) COMMENT '覆盖天数 = (platform_total_onhand + domestic_actual_stock_qty) / weighted_daily_demand',
  `oos_date_estimate` DATE COMMENT '预计断货日期',
  
  -- 建议补货量
  `suggest_transfer_qty` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '建议直补量',
  `suggest_produce_qty` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '建议生产量',
  
  -- 风险等级
  `risk_level` TINYINT NOT NULL DEFAULT 0 COMMENT '风险等级：0正常，1安全区，2需要生产，3直补来不及，4已断货',
  `risk_reason` TEXT COMMENT '风险原因说明',
  
  -- SKU数量统计
  `active_sku_count` INT NOT NULL DEFAULT 0 COMMENT '活跃SKU数量',
  `high_risk_sku_count` INT NOT NULL DEFAULT 0 COMMENT '高风险SKU数量',
  
  -- 元数据
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_by` BIGINT COMMENT '创建人',
  `deleted` BIGINT NOT NULL DEFAULT 0 COMMENT '删除标记：0=未删除，大于0：删除时间戳',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_commodity_date` (`company_id`, `commodity_id`, `monitor_date`, `deleted`),
  KEY `idx_company_date` (`company_id`, `monitor_date`),
  KEY `idx_commodity_date` (`commodity_id`, `monitor_date`),
  KEY `idx_risk_level` (`risk_level`, `monitor_date`),
  KEY `idx_oos_date` (`oos_date_estimate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC 
COMMENT='产品级别断货点监控快照表（日粒度，SPU维度）';

-- ----------------------------
-- 2. 国内仓库存索引优化
-- Optimize amf_jh_company_stock table indexes
-- ----------------------------
-- 为amf_jh_company_stock表添加索引以提升查询性能
ALTER TABLE `amf_jh_company_stock` 
  ADD INDEX IF NOT EXISTS `idx_sync_date` (`sync_date`),
  ADD INDEX IF NOT EXISTS `idx_local_sku` (`local_sku`),
  ADD INDEX IF NOT EXISTS `idx_sync_date_local_sku` (`sync_date`, `local_sku`);

-- ----------------------------
-- 3. local_sku到产品SKU映射视图
-- Local SKU to Product SKU Mapping View
-- ----------------------------
-- 创建映射视图，用于将amf_jh_company_stock.local_sku映射到pms_commodity_sku
DROP VIEW IF EXISTS `v_domestic_stock_to_product`;
CREATE VIEW `v_domestic_stock_to_product` AS
SELECT 
  s.local_sku,
  ps.commodity_id,
  ps.commodity_code,
  ps.commodity_sku_code,
  ps.custom_code,
  ps.company_id,
  s.remaining_num,
  s.stock_num,
  s.sync_date,
  s.order_date,
  s.business,
  s.account,
  s.factory_code
FROM amf_jh_company_stock s
LEFT JOIN pms_commodity_sku ps ON (
  -- 映射规则：local_sku匹配custom_code或commodity_sku_code
  s.local_sku = ps.custom_code 
  OR s.local_sku = ps.commodity_sku_code
)
WHERE ps.use_status = 0  -- 未删除的SKU
  AND ps.sale_status = 0  -- 在售状态
  AND s.sync_date IS NOT NULL;

-- ----------------------------
-- 4. 存储过程：计算产品级别断货点监控快照
-- Stored Procedure: Calculate Product-Level Stockout Monitoring Snapshot
-- ----------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_calculate_spu_stockout_snapshot`$$

CREATE PROCEDURE `sp_calculate_spu_stockout_snapshot`(
  IN p_monitor_date DATE,
  IN p_company_id BIGINT
)
BEGIN
  /*
   * 功能说明：
   * 计算指定日期的产品级别断货点监控快照
   * 
   * 参数：
   *   p_monitor_date - 监控日期，如果为NULL则使用当前日期
   *   p_company_id   - 企业ID，如果为NULL则处理所有企业
   * 
   * 实现逻辑：
   * 1. 从amf_jh_company_stock获取最近的sync_date数据
   * 2. 按local_sku聚合remaining_num和stock_num
   * 3. 通过v_domestic_stock_to_product映射到产品
   * 4. 聚合SKU级别的断货监控数据到产品级别
   * 5. 计算风险等级和建议补货量
   * 
   * 幂等性：使用INSERT ... ON DUPLICATE KEY UPDATE确保可重复执行
   */
  
  DECLARE v_monitor_date DATE;
  DECLARE v_latest_sync_date DATE;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    -- 错误处理：回滚事务
    ROLLBACK;
    RESIGNAL;
  END;
  
  -- 设置默认值
  SET v_monitor_date = IFNULL(p_monitor_date, CURDATE());
  
  -- 查找最近的sync_date（不晚于monitor_date）
  SELECT MAX(sync_date) INTO v_latest_sync_date
  FROM amf_jh_company_stock
  WHERE sync_date <= v_monitor_date;
  
  -- 如果没有找到数据，退出
  IF v_latest_sync_date IS NULL THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = '没有找到国内仓库存数据（amf_jh_company_stock）';
  END IF;
  
  -- 开启事务
  START TRANSACTION;
  
  -- 插入或更新产品级别快照数据
  INSERT INTO cos_oos_spu_monitor_daily (
    company_id,
    commodity_id,
    commodity_code,
    monitor_date,
    domestic_remaining_qty,
    domestic_actual_stock_qty,
    domestic_stock_sync_date,
    platform_total_onhand,
    domestic_available_spu,
    open_intransit_qty,
    weighted_daily_demand,
    doc_days,
    oos_date_estimate,
    suggest_transfer_qty,
    suggest_produce_qty,
    risk_level,
    risk_reason,
    active_sku_count,
    high_risk_sku_count,
    create_by,
    deleted
  )
  SELECT 
    -- 基础信息
    COALESCE(v.company_id, p_company_id, 0) AS company_id,
    v.commodity_id,
    v.commodity_code,
    v_monitor_date AS monitor_date,
    
    -- 国内仓库存（从amf_jh_company_stock聚合）
    COALESCE(SUM(v.remaining_num), 0) AS domestic_remaining_qty,
    COALESCE(SUM(v.stock_num), 0) AS domestic_actual_stock_qty,
    v_latest_sync_date AS domestic_stock_sync_date,
    
    -- 海外仓库存（从SKU级别汇总）
    COALESCE(SUM(sku.platform_onhand), 0) AS platform_total_onhand,
    COALESCE(MAX(sku.domestic_available_spu), 0) AS domestic_available_spu,
    COALESCE(SUM(sku.open_intransit_qty), 0) AS open_intransit_qty,
    
    -- 需求指标
    COALESCE(SUM(sku.daily_demand), 0) AS weighted_daily_demand,
    
    -- 覆盖天数计算
    CASE 
      WHEN COALESCE(SUM(sku.daily_demand), 0) > 0 THEN
        (COALESCE(SUM(sku.platform_onhand), 0) + COALESCE(SUM(v.stock_num), 0)) / SUM(sku.daily_demand)
      ELSE NULL
    END AS doc_days,
    
    -- 预计断货日期
    CASE 
      WHEN COALESCE(SUM(sku.daily_demand), 0) > 0 THEN
        DATE_ADD(v_monitor_date, INTERVAL FLOOR(
          (COALESCE(SUM(sku.platform_onhand), 0) + COALESCE(SUM(v.stock_num), 0)) / SUM(sku.daily_demand)
        ) DAY)
      ELSE NULL
    END AS oos_date_estimate,
    
    -- 建议补货量（从SKU级别汇总）
    COALESCE(SUM(sku.suggest_transfer_final), 0) AS suggest_transfer_qty,
    COALESCE(SUM(sku.suggest_produce), 0) AS suggest_produce_qty,
    
    -- 风险等级（取最高风险）
    COALESCE(MAX(sku.risk_level), 0) AS risk_level,
    
    -- 风险原因
    CASE 
      WHEN MAX(sku.risk_level) >= 4 THEN '已断货'
      WHEN MAX(sku.risk_level) = 3 THEN '直补来不及'
      WHEN MAX(sku.risk_level) = 2 THEN '需要生产'
      WHEN MAX(sku.risk_level) = 1 THEN '安全区'
      ELSE '正常'
    END AS risk_reason,
    
    -- SKU统计
    COUNT(DISTINCT sku.sku_id) AS active_sku_count,
    SUM(CASE WHEN sku.risk_level >= 3 THEN 1 ELSE 0 END) AS high_risk_sku_count,
    
    -- 元数据
    NULL AS create_by,
    0 AS deleted
    
  FROM v_domestic_stock_to_product v
  LEFT JOIN cos_oos_monitor_daily sku ON (
    v.commodity_id = sku.commodity_id
    AND sku.monitor_date = v_monitor_date
    AND sku.deleted = 0
  )
  WHERE v.sync_date = v_latest_sync_date
    AND (p_company_id IS NULL OR v.company_id = p_company_id)
    AND v.commodity_id IS NOT NULL
  GROUP BY 
    v.company_id,
    v.commodity_id,
    v.commodity_code
  
  -- 幂等性：如果记录已存在则更新
  ON DUPLICATE KEY UPDATE
    domestic_remaining_qty = VALUES(domestic_remaining_qty),
    domestic_actual_stock_qty = VALUES(domestic_actual_stock_qty),
    domestic_stock_sync_date = VALUES(domestic_stock_sync_date),
    platform_total_onhand = VALUES(platform_total_onhand),
    domestic_available_spu = VALUES(domestic_available_spu),
    open_intransit_qty = VALUES(open_intransit_qty),
    weighted_daily_demand = VALUES(weighted_daily_demand),
    doc_days = VALUES(doc_days),
    oos_date_estimate = VALUES(oos_date_estimate),
    suggest_transfer_qty = VALUES(suggest_transfer_qty),
    suggest_produce_qty = VALUES(suggest_produce_qty),
    risk_level = VALUES(risk_level),
    risk_reason = VALUES(risk_reason),
    active_sku_count = VALUES(active_sku_count),
    high_risk_sku_count = VALUES(high_risk_sku_count),
    update_time = CURRENT_TIMESTAMP;
  
  -- 提交事务
  COMMIT;
  
  -- 返回处理结果
  SELECT 
    v_monitor_date AS monitor_date,
    v_latest_sync_date AS sync_date_used,
    COUNT(*) AS records_processed,
    SUM(CASE WHEN risk_level >= 3 THEN 1 ELSE 0 END) AS high_risk_count
  FROM cos_oos_spu_monitor_daily
  WHERE monitor_date = v_monitor_date
    AND deleted = 0
    AND (p_company_id IS NULL OR company_id = p_company_id);
    
END$$

DELIMITER ;

-- ----------------------------
-- 5. 校验SQL查询
-- Validation SQL Queries
-- ----------------------------

-- 查询示例1：查看指定日期的产品级别断货监控数据
-- SELECT * FROM cos_oos_spu_monitor_daily 
-- WHERE monitor_date = '2024-01-01' 
-- AND deleted = 0
-- ORDER BY risk_level DESC, weighted_daily_demand DESC;

-- 查询示例2：查看高风险产品
-- SELECT 
--   commodity_id,
--   commodity_code,
--   monitor_date,
--   domestic_actual_stock_qty,
--   platform_total_onhand,
--   weighted_daily_demand,
--   doc_days,
--   oos_date_estimate,
--   risk_level,
--   risk_reason
-- FROM cos_oos_spu_monitor_daily
-- WHERE monitor_date = CURDATE()
-- AND risk_level >= 3
-- AND deleted = 0
-- ORDER BY risk_level DESC, doc_days ASC;

-- 查询示例3：验证国内仓库存数据聚合准确性
-- SELECT 
--   v.commodity_id,
--   v.commodity_code,
--   COUNT(*) AS local_sku_count,
--   SUM(v.remaining_num) AS total_remaining,
--   SUM(v.stock_num) AS total_stock,
--   s.domestic_remaining_qty,
--   s.domestic_actual_stock_qty,
--   s.monitor_date
-- FROM v_domestic_stock_to_product v
-- JOIN cos_oos_spu_monitor_daily s ON (
--   v.commodity_id = s.commodity_id 
--   AND s.monitor_date = CURDATE()
-- )
-- WHERE v.sync_date = (SELECT MAX(sync_date) FROM amf_jh_company_stock WHERE sync_date <= CURDATE())
-- GROUP BY v.commodity_id, v.commodity_code, s.domestic_remaining_qty, s.domestic_actual_stock_qty, s.monitor_date;

-- ----------------------------
-- 6. 使用说明
-- Usage Instructions
-- ----------------------------

/*
存储过程调用示例：

1. 计算今天的快照（所有企业）：
   CALL sp_calculate_spu_stockout_snapshot(CURDATE(), NULL);

2. 计算指定日期的快照（所有企业）：
   CALL sp_calculate_spu_stockout_snapshot('2024-01-01', NULL);

3. 计算指定企业的快照：
   CALL sp_calculate_spu_stockout_snapshot(CURDATE(), 123);

4. 重新计算已存在的快照（幂等性）：
   CALL sp_calculate_spu_stockout_snapshot('2024-01-01', NULL);
   -- 多次执行结果一致

索引使用说明：
- idx_sync_date: 快速定位最新的sync_date
- idx_local_sku: 快速查找特定SKU的库存
- idx_sync_date_local_sku: 组合索引，优化聚合查询性能

性能优化建议：
1. 定期清理历史快照数据（保留90天或更长）
2. 使用批量处理：每天凌晨统一执行快照计算
3. 监控存储过程执行时间，必要时添加分区表
4. 考虑为大表添加分区：按monitor_date月度分区
*/

-- ----------------------------
-- View structure for v_amf_jh_lx_order
-- ----------------------------
DROP VIEW IF EXISTS `v_amf_jh_lx_order`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_amf_jh_lx_order` AS select (`amf_jh_orders`.`purchase_date` + interval 8 hour) AS `purchase_date`,(`amf_jh_orders`.`delivery_time` + interval 8 hour) AS `delivery_time`,ifnull(`amf_jh_orders`.`warehouse_sku`,`amf_jh_company_goods_item`.`warehouse_sku`) AS `warehouse_sku`,`amf_jh_orders`.`quantity_ordered` AS `quantity_ordered`,ifnull(`amf_jh_orders`.`warehouse_sku_num`,`amf_jh_orders`.`quantity_ordered`) AS `warehouse_sku_num`,`amf_jh_orders`.`warehouse_name` AS `warehouse_name`,`amf_state_region`.`region` AS `region`,`amf_warehouse_region`.`region` AS `whregion`,ifnull(`amf_spu_sku`.`spu`,`amf_jh_orders`.`warehouse_sku`) AS `spu`,`amf_jh_orders`.`wh_product_name_cn` AS `product_name`,`amf_jh_orders`.`platform_name` AS `platform_name`,`amf_jh_orders`.`country_code` AS `country_code`,`amf_jh_orders`.`shop_show_name` AS `shop_name`,`amf_jh_orders`.`show_order_no` AS `order_no` from (((((`amf_jh_orders` left join `amf_state_region` on((`amf_jh_orders`.`state_or_province` = `amf_state_region`.`state_code`))) left join `amf_warehouse_region` on((`amf_jh_orders`.`warehouse_name` = `amf_warehouse_region`.`warehouse_code`))) left join `amf_jh_company_goods` on(((`amf_jh_orders`.`company_sku` = `amf_jh_company_goods`.`company_sku`) and (`amf_jh_orders`.`warehouse_sku` is null)))) left join `amf_jh_company_goods_item` on((`amf_jh_company_goods`.`id` = `amf_jh_company_goods_item`.`company_product_id`))) left join `amf_spu_sku` on(((ifnull(`amf_jh_orders`.`warehouse_sku`,`amf_jh_company_goods_item`.`warehouse_sku`) = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0)))) where (`amf_jh_orders`.`order_status` = 'FH') union all select from_unixtime(`a`.`global_purchase_time`) AS `purchase_date`,from_unixtime(`a`.`global_delivery_time`) AS `delivery_time`,ifnull(`b`.`local_sku`,`b`.`msku`) AS `warehouse_sku`,`b`.`quantity` AS `quantity_ordered`,`b`.`quantity` AS `warehouse_sku_num`,ifnull(`a`.`warehouse_name`,'') AS `warehouse_name`,ifnull(`amf_warehouse_region`.`region`,'美西') AS `region`,ifnull(`amf_warehouse_region`.`region`,'美西') AS `whregion`,ifnull(`amf_spu_sku`.`spu`,`b`.`local_sku`) AS `spu`,`b`.`local_product_name` AS `product_name`,`amf_lx_shop`.`platform_name` AS `platform_name`,`a`.`amount_currency` AS `country_code`,`amf_lx_shop`.`name` AS `shop_name`,`a`.`platform_order_no` AS `order_no` from (((((`amf_lx_mporders` `a` join `amf_lx_mporders_item` `b` on((`a`.`global_order_no` = `b`.`global_order_no`))) left join `amf_lx_platform` on((`a`.`platform_code` = `amf_lx_platform`.`platform_code`))) left join `amf_warehouse_region` on((`a`.`warehouse_name` = `amf_warehouse_region`.`warehouse_code`))) left join `amf_spu_sku` on(((`b`.`local_sku` = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0)))) left join `amf_lx_shop` on((`a`.`store_id` = `amf_lx_shop`.`store_id`))) where ((`a`.`wid` <> 0) and (`a`.`status` = 6) and (`a`.`platform_code` in ('10001','10002'))) union all select `a`.`purchase_date_local` AS `purchase_date`,`a`.`shipment_date_local` AS `delivery_time`,ifnull(`amf_lx_products`.`sku`,if((`b`.`local_sku` = ''),`b`.`seller_sku`,`b`.`local_sku`)) AS `warehouse_sku`,`b`.`quantity_ordered` AS `quantity_ordered`,(`b`.`quantity_ordered` * 1) AS `warehouse_sku_num`,'FBA' AS `warehouse_name`,'FBA' AS `region`,'FBA' AS `whregion`,ifnull(`amf_spu_sku`.`spu`,`b`.`local_sku`) AS `spu`,`b`.`local_name` AS `product_name`,`a`.`sales_channel` AS `platform_name`,`a`.`order_total_currency_code` AS `country_code`,`a`.`seller_name` AS `shop_name`,`a`.`amazon_order_id` AS `order_no` from (((`amf_lx_amzorder` `a` join `amf_lx_amzorder_item` `b` on((`a`.`id` = `b`.`amzorder_id`))) left join `amf_lx_products` on((`b`.`local_sku` = `amf_lx_products`.`sku`))) left join `amf_spu_sku` on(((ifnull(`amf_lx_products`.`sku`,if((`b`.`local_sku` = ''),`b`.`seller_sku`,`b`.`local_sku`)) = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0)))) where (`a`.`fulfillment_channel` = 'AFN') union all select `amf_jh_cgorders`.`order_date` AS `purchase_date`,`amf_jh_cgorders`.`order_date` AS `delivery_time`,`amf_jh_cgorders`.`purchase_sku` AS `warehouse_sku`,`amf_jh_cgorders`.`quantity` AS `quantity_ordered`,`amf_jh_cgorders`.`quantity` AS `warehouse_sku_num`,`amf_jh_cgorders`.`warehouse` AS `warehouse_name`,'CG' AS `region`,`amf_warehouse_region`.`region` AS `whregion`,ifnull(`amf_spu_sku`.`spu`,`amf_jh_cgorders`.`purchase_sku`) AS `spu`,'' AS `product_name`,'CG' AS `platform_name`,'' AS `country_code`,`amf_jh_cgorders`.`shop` AS `shop_name`,`amf_jh_cgorders`.`third_party_order_no` AS `order_no` from ((`amf_jh_cgorders` left join `amf_warehouse_region` on((`amf_jh_cgorders`.`warehouse` = `amf_warehouse_region`.`warehouse_code`))) left join `amf_spu_sku` on(((`amf_jh_cgorders`.`purchase_sku` = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0))));

-- ----------------------------
-- View structure for v_amf_jh_orders
-- ----------------------------
DROP VIEW IF EXISTS `v_amf_jh_orders`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_amf_jh_orders` AS select `amf_jh_orders`.`purchase_date` AS `purchase_date`,`amf_jh_orders`.`shop_show_name` AS `shop_show_name`,`amf_jh_orders`.`order_status` AS `order_status`,`amf_jh_orders`.`platform_name` AS `platform_name`,`amf_jh_orders`.`sell_sku` AS `sell_sku`,`amf_jh_orders`.`warehouse_sku` AS `warehouse_sku`,`amf_jh_orders`.`warehouse_sku_num` AS `warehouse_sku_num`,`amf_jh_orders`.`company_sku` AS `company_sku`,`amf_jh_orders`.`quantity_ordered` AS `quantity_ordered`,`amf_jh_orders`.`purchase_value` AS `purchase_value`,`amf_jh_orders`.`state_or_province` AS `state_or_province`,`amf_jh_orders`.`warehouse_name` AS `warehouse_name`,`amf_state_region`.`region` AS `region`,`amf_warehouse_region`.`region` AS `whregion`,ifnull(`amf_spu_sku`.`spu`,`amf_jh_orders`.`warehouse_sku`) AS `spu` from (((`amf_jh_orders` left join `amf_state_region` on((`amf_jh_orders`.`state_or_province` = `amf_state_region`.`state_code`))) left join `amf_warehouse_region` on((`amf_jh_orders`.`warehouse_name` = `amf_warehouse_region`.`warehouse_code`))) left join `amf_spu_sku` on(((`amf_jh_orders`.`warehouse_sku` = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0)))) where (`amf_jh_orders`.`order_status` <> 'QX');

-- ----------------------------
-- View structure for v_amf_lx_warehouse_stock
-- ----------------------------
DROP VIEW IF EXISTS `v_amf_lx_warehouse_stock`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_amf_lx_warehouse_stock` AS select (case `amf_lx_warehouse_stock`.`wid` when 9488 then '欧洲DE EUWE' when 9487 then '欧洲UK UKNH02' else '' end) AS `warehouse_name`,'欧洲' AS `region`,`amf_lx_warehouse_stock`.`sku` AS `sku`,`amf_lx_products`.`product_name` AS `product_name`,sum(`amf_lx_warehouse_stock`.`product_valid_num`) AS `stock_qty`,sum(`amf_lx_warehouse_stock`.`product_onway`) AS `onroad_qty` from (`amf_lx_warehouse_stock` join `amf_lx_products` on((`amf_lx_warehouse_stock`.`product_id` = `amf_lx_products`.`id`))) where (`amf_lx_warehouse_stock`.`wid` in (9488,9487)) group by (case `amf_lx_warehouse_stock`.`wid` when 9488 then '欧洲DE EUWE' when 9487 then '欧洲UK UKNH02' else '' end),`amf_lx_warehouse_stock`.`sku`,`amf_lx_products`.`product_name`;

-- ----------------------------
-- View structure for v_amf_onhand_stock
-- ----------------------------
DROP VIEW IF EXISTS `v_amf_onhand_stock`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_amf_onhand_stock` AS select `amf_jh_company_stock`.`local_sku` AS `warehouse_sku`,sum(ifnull(`amf_jh_company_stock`.`stock_num`,0)) AS `stock_qty`,sum((ifnull(`amf_jh_company_stock`.`remaining_num`,0) - ifnull(`amf_jh_company_stock`.`stock_num`,0))) AS `factory_qty`,0 AS `isdel` from `amf_jh_company_stock` group by `amf_jh_company_stock`.`local_sku`;

-- ----------------------------
-- View structure for v_amf_onroad_stock
-- ----------------------------
DROP VIEW IF EXISTS `v_amf_onroad_stock`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_amf_onroad_stock` AS select `amf_jh_shipment_sku`.`warehouse_sku` AS `warehouse_sku`,`amf_jh_shipment_sku`.`shop_show_name` AS `shop_show_name`,`amf_warehouse_region`.`region` AS `region`,`amf_jh_shipment`.`warehouse_name` AS `warehouse_name`,`amf_jh_shipment`.`container_no` AS `container_no`,`amf_jh_shipment`.`status_name` AS `status_name`,`amf_jh_shipment`.`shipment_date` AS `shipment_date`,`amf_jh_shipment_sku`.`ship_qty` AS `ship_qty`,`amf_jh_shipment_sku`.`receive_qty` AS `receive_qty`,`amf_jh_shipment_sku`.`update_time` AS `update_time`,`amf_warehouse_region`.`shipdays` AS `shipdays`,if(((`amf_jh_shipment_eta`.`eta_date` + interval 8 day) < now()),(date_format(now(),'%Y-%m-%d') + interval 1 day),(`amf_jh_shipment_eta`.`eta_date` + interval 8 day)) AS `arridate`,((`amf_jh_shipment_eta`.`eta_date` + interval 8 day) < now()) AS `lated`,`amf_jh_shipment_eta`.`eta` AS `eta`,ifnull(`amf_spu_sku`.`spu`,`amf_jh_shipment_sku`.`warehouse_sku`) AS `spu` from ((((`amf_jh_shipment` join `amf_jh_shipment_sku` on((`amf_jh_shipment`.`id` = `amf_jh_shipment_sku`.`property_shipment_id`))) join `amf_warehouse_region` on((`amf_jh_shipment`.`warehouse_name` = `amf_warehouse_region`.`warehouse_code`))) join `amf_jh_shipment_eta` on((`amf_jh_shipment_sku`.`container_no` = `amf_jh_shipment_eta`.`container_no`))) left join `amf_spu_sku` on(((`amf_jh_shipment_sku`.`warehouse_sku` = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0)))) where ((`amf_jh_shipment`.`status` = 0) and ((`amf_jh_shipment_eta`.`eta` <> '已上架') or (`amf_jh_shipment_eta`.`eta` is null)) and (`amf_jh_shipment`.`shipment_date` >= DATE'2025-08-01')) union all select `a`.`sku` AS `warehouse_sku`,`a`.`store` AS `shop_show_name`,'FBA' AS `region`,'FBA' AS `warehouse_name`,'' AS `container_no`,`a`.`shipment_status` AS `status_name`,`a`.`shipment_time` AS `shipment_date`,`a`.`shipment_quantity` AS `ship_qty`,0 AS `receive_qty`,NULL AS `update_time`,35 AS `shipdays`,`a`.`estimated_arrival_time` AS `arridate`,(`a`.`estimated_arrival_time` < now()) AS `lated`,`a`.`estimated_arrival_time` AS `estimated_arrival_time`,ifnull(`amf_spu_sku`.`spu`,`a`.`sku`) AS `spu` from (`amf_lx_fba_stockup` `a` left join `amf_spu_sku` on(((`a`.`sku` = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0)))) where (`a`.`shipment_status` = 'WORKING') union all select `b`.`sku` AS `warehouse_sku`,'' AS `shop_show_name`,'欧洲' AS `region`,`a`.`r_wname` AS `warehouse_name`,'' AS `container_no`,'' AS `status_name`,`a`.`real_delivery_time` AS `shipment_date`,`b`.`stock_num` AS `ship_qty`,0 AS `receive_qty`,`a`.`gmt_modified` AS `update_time`,35 AS `shipdays`,`a`.`estimated_time` AS `arridate`,(`a`.`estimated_time` < now()) AS `lated`,`a`.`estimated_time` AS `estimated_arrival_time`,ifnull(`amf_spu_sku`.`spu`,`b`.`sku`) AS `spu` from ((`amf_lx_shipment` `a` join `amf_lx_shipment_products` `b` on((`a`.`id` = `b`.`shipment_id`))) left join `amf_spu_sku` on(((`b`.`sku` = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0))));

-- ----------------------------
-- View structure for v_amf_warehouse_stock
-- ----------------------------
DROP VIEW IF EXISTS `v_amf_warehouse_stock`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_amf_warehouse_stock` AS select `amf_jh_warehouse_stock`.`warehouse_sku` AS `warehouse_sku`,`amf_jh_warehouse_stock`.`warehouse_sku_name` AS `warehouse_sku_name`,ifnull(`amf_warehouse_region`.`region`,'') AS `region`,`amf_jh_warehouse_stock`.`warehouse_name` AS `warehouse_name`,`amf_jh_warehouse_stock`.`out_available_qty` AS `available_qty`,ifnull(`amf_spu_sku`.`spu`,`amf_jh_warehouse_stock`.`warehouse_sku`) AS `spu` from ((`amf_jh_warehouse_stock` left join `amf_warehouse_region` on((`amf_jh_warehouse_stock`.`warehouse_name` = `amf_warehouse_region`.`warehouse_code`))) left join `amf_spu_sku` on(((`amf_jh_warehouse_stock`.`warehouse_sku` = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0)))) where (`amf_jh_warehouse_stock`.`out_available_qty` <> 0) union all select `amf_lx_warehouse_stock`.`sku` AS `warehouse_sku`,`amf_lx_products`.`product_name` AS `warehouse_sku_name`,'欧洲' AS `region`,(case `amf_lx_warehouse_stock`.`wid` when 9488 then '欧洲DE EUWE' when 9487 then '欧洲UK UKNH02' else '' end) AS `warehouse_name`,`amf_lx_warehouse_stock`.`product_valid_num` AS `available_qty`,ifnull(`amf_spu_sku`.`spu`,`amf_lx_warehouse_stock`.`sku`) AS `spu` from ((`amf_lx_warehouse_stock` left join `amf_lx_products` on((`amf_lx_warehouse_stock`.`product_id` = `amf_lx_products`.`id`))) left join `amf_spu_sku` on(((`amf_lx_warehouse_stock`.`sku` = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0)))) where ((`amf_lx_warehouse_stock`.`wid` in (9488,9487)) and (`amf_lx_warehouse_stock`.`product_valid_num` <> 0)) union all select `amf_lx_fbadetail`.`seller_sku` AS `warehouse_sku`,`amf_lx_fbadetail`.`product_name` AS `warehouse_sku_name`,'FBA' AS `region`,'FBA' AS `warehouse_name`,`amf_lx_fbadetail`.`available_total` AS `available_qty`,ifnull(`amf_spu_sku`.`spu`,`amf_lx_fbadetail`.`seller_sku`) AS `spu` from (`amf_lx_fbadetail` left join `amf_spu_sku` on(((`amf_lx_fbadetail`.`seller_sku` = `amf_spu_sku`.`warehouse_sku`) and (`amf_spu_sku`.`isdel` = 0)))) where (`amf_lx_fbadetail`.`available_total` <> 0);

-- ----------------------------
-- Function structure for f_getday1qtyrate
-- ----------------------------
DROP FUNCTION IF EXISTS `f_getday1qtyrate`;
delimiter ;;
CREATE FUNCTION `f_getday1qtyrate`(a_region varchar(20),  a_stock1 int,  a_stock2 int,  a_stock3 int,  a_stock4 int)
 RETURNS decimal(10,2)
  SQL SECURITY INVOKER
BEGIN
  declare ret DECIMAL(10,2) DEFAULT 0.00;
  #Routine body goes here...
  set ret = if(a_stock1 >0 and a_stock2 >0 and  a_stock3 >0 and  a_stock4 >0 , case a_region when '美东' then 0.27 when '美南' then 0.33 when '美中' then 0.1 when '美西' then 0.30 else 0.0 end,0.0);
--   
--   30%	35%	10%	25%
-- 东	南	中	西
-- 30%	35%	10%	25%
-- 30%	50%	20%	25%
-- 0%	59%	16%	25%
-- 51%	0%	24%	25%
-- 30%	40%	0%	25%
-- 30%	35%	10%	25%
-- 0%	74%	27%	0%
-- 66%	0%	34%	0%
-- 41%	60%	0%	0%
-- 45%	55%	25%	0%
-- 0%	0%	36%	25%
-- 0%	59%	0%	25%
-- 0%	68%	21%	-30%
-- 53%	0%	0%	25%
-- 66%	-25%	22%	-35%
-- 44%	42%	0%	-10%
-- 0%	0%	100%	0%
-- 0%	100%	0%	0%
-- 0%	91%	34%	0%
-- 100%	0%	0%	0%
-- 81%	0%	44%	0%
-- 54%	71%	0%	0%
-- 0%	0%	0%	25%
-- 0%	0%	37%	-65%
-- 0%	74%	0%	-40%
-- 65%	0%	0%	-45%
-- 0%	0%	0%	100%
-- 100%	0%	0%	0%
-- 0%	100%	0%	0%
-- 0%	0%	100%	0%
-- 0%	0%	0%	0%
-- 0%	0%	0%	0%
-- 
--   
  
  
RETURN ret;
END
;;
delimiter ;

-- ----------------------------
-- Function structure for f_getday1qtyrate1
-- ----------------------------
DROP FUNCTION IF EXISTS `f_getday1qtyrate1`;
delimiter ;;
CREATE FUNCTION `f_getday1qtyrate1`(a_region varchar(20),  -- 区域
    a_stock1 int,          -- 库存维度1
    a_stock2 int,          -- 库存维度2
    a_stock3 int,          -- 库存维度3
    a_stock4 int)
 RETURNS decimal(5,2)
  SQL SECURITY INVOKER
BEGIN
  # 声明变量
  DECLARE v_total_stock INT DEFAULT 0;  -- 总库存
  DECLARE v_day1_rate DECIMAL(5,2) DEFAULT 0.00;  -- 日均1天消耗率/可用率
  DECLARE v_region_weight DECIMAL(5,2) DEFAULT 1.00;  -- 区域权重

  # 步骤1：处理空值（将NULL转为0）
  SET a_stock1 = IFNULL(a_stock1, 0);
  SET a_stock2 = IFNULL(a_stock2, 0);
  SET a_stock3 = IFNULL(a_stock3, 0);
  SET a_stock4 = IFNULL(a_stock4, 0);

  # 步骤2：按区域设置权重（可根据业务调整）
  CASE a_region
    WHEN '华东' THEN SET v_region_weight = 1.20;  -- 华东区域权重1.2
    WHEN '华南' THEN SET v_region_weight = 1.10;  -- 华南区域权重1.1
    WHEN '华北' THEN SET v_region_weight = 0.95;  -- 华北区域权重0.95
    ELSE SET v_region_weight = 1.00;  -- 其他区域默认权重1.0
  END CASE;

  # 步骤3：计算总库存（可根据业务调整库存聚合规则）
  SET v_total_stock = a_stock1 + a_stock2 + a_stock3 + a_stock4;

  # 步骤4：计算1天库存比率（示例逻辑：日均消耗率=核心库存/总库存*区域权重）
  # 【可根据实际业务替换规则】此处示例：以a_stock1为核心库存，计算占比
  IF v_total_stock = 0 THEN
    SET v_day1_rate = 0.00;  -- 总库存为0时返回0，避免除零错误
  ELSE
    SET v_day1_rate = ROUND((a_stock1 / v_total_stock) * v_region_weight, 2);
  END IF;

  # 步骤5：返回结果（确保在0.00~100.00区间，可根据业务调整）
  RETURN LEAST(GREATEST(v_day1_rate, 0.00), 100.00);
END
;;
delimiter ;

-- ----------------------------
-- Function structure for f_getregionshipdays
-- ----------------------------
DROP FUNCTION IF EXISTS `f_getregionshipdays`;
delimiter ;;
CREATE FUNCTION `f_getregionshipdays`(a_region VARCHAR(20))
 RETURNS int
  DETERMINISTIC
  SQL SECURITY INVOKER
BEGIN
    /*
    函数功能：根据区域名称获取对应的发货天数
    参数说明：a_region - 区域名称（VARCHAR(20)）
    返回值：int - 发货天数（无匹配时默认返回35）
    依赖表：amf_region（包含region和shipdays字段）
    */
    DECLARE ret INT DEFAULT 35;  -- 默认发货天数35天
    
    -- 处理空值参数：若输入区域为空，直接返回默认值
    IF a_region IS NULL OR TRIM(a_region) = '' THEN
        RETURN ret;
    END IF;
    
    -- 查询指定区域的发货天数（精准匹配）
    SELECT shipdays INTO ret
    FROM amf_region
    WHERE region = TRIM(a_region)  -- 去除输入参数首尾空格
    LIMIT 1;  -- 确保只取一条结果，避免多行匹配报错
    
    -- 若查询结果为NULL（无匹配区域），重置为默认值35
    IF ret IS NULL THEN
        SET ret = 35;
    END IF;
    
    RETURN ret;
END
;;
delimiter ;

-- ----------------------------
-- Function structure for generate_snowflake_id
-- ----------------------------
DROP FUNCTION IF EXISTS `generate_snowflake_id`;
delimiter ;;
CREATE FUNCTION `generate_snowflake_id`()
 RETURNS bigint
  READS SQL DATA 
BEGIN
    DECLARE epoch BIGINT DEFAULT 1288834974657; -- 2010-11-04 09:42:54 UTC
    DECLARE timestamp BIGINT;
    DECLARE machine_id INT DEFAULT 1; -- 机器标识（0-1023）
    DECLARE sequence INT DEFAULT 0;
    DECLARE last_timestamp BIGINT DEFAULT -1;
    
    -- 获取当前毫秒时间戳
    SET timestamp = (UNIX_TIMESTAMP(NOW(3)) * 1000) - epoch;
    
    -- 处理时钟回拨
    IF timestamp < last_timestamp THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Clock moved backwards';
    END IF;
    
    -- 同一毫秒内序列号递增
    IF last_timestamp = timestamp THEN
        SET sequence = (sequence + 1) & 4095; -- 12位序列号掩码
        IF sequence = 0 THEN -- 当前毫秒序列号耗尽
            SET timestamp = wait_next_millis(last_timestamp);
        END IF;
    ELSE
        SET sequence = 0;
    END IF;
    
    SET last_timestamp = timestamp;
    
    -- 组合64位ID：时间戳(41位)|机器ID(10位)|序列号(12位)
    RETURN (timestamp << 22) | (machine_id << 12) | sequence;
END
;;
delimiter ;

-- ----------------------------
-- Function structure for next_id
-- ----------------------------
DROP FUNCTION IF EXISTS `next_id`;
delimiter ;;
CREATE FUNCTION `next_id`()
 RETURNS bigint
BEGIN
    DECLARE epoch BIGINT DEFAULT 1609459200000; -- 2021-01-01
    DECLARE seq BIGINT DEFAULT 0;
    DECLARE machine_id BIGINT DEFAULT 1; -- 机器ID
    
    SET @current_time = UNIX_TIMESTAMP() * 1000;
    SET @id = (@current_time - epoch) << 22 | (machine_id << 12) | (seq % 4096);
    
    RETURN @id;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for TestSnowId
-- ----------------------------
DROP PROCEDURE IF EXISTS `TestSnowId`;
delimiter ;;
CREATE PROCEDURE `TestSnowId`()
BEGIN
	DECLARE i INT DEFAULT 1;
	CREATE TEMPORARY TABLE IF NOT EXISTS temp_numbers ( number BIGINT );
	WHILE i <= 5000 DO
	    INSERT INTO temp_numbers ( number ) VALUES (SnowId ());
		SET i = i + 1;
	END WHILE;
	SELECT * FROM temp_numbers;
	DROP TEMPORARY TABLE IF EXISTS temp_numbers;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for update_fully_spu_skc_sku_ids
-- ----------------------------
DROP PROCEDURE IF EXISTS `update_fully_spu_skc_sku_ids`;
delimiter ;;
CREATE PROCEDURE `update_fully_spu_skc_sku_ids`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_spu_code VARCHAR(64);
    DECLARE v_skc_code VARCHAR(64);
		DECLARE v_sku_code VARCHAR(64);
    DECLARE v_spu_id BIGINT;
    DECLARE v_skc_id BIGINT;
    DECLARE v_sku_id BIGINT;
		DECLARE v_count INT;
		
    -- 声明游标：获取所有不重复的spu_code
    DECLARE spu_cursor CURSOR FOR 
        SELECT DISTINCT spu_code FROM cos_temu_fully_goods 
				WHERE spu_id is null AND spu_code IS NOT NULL;
    
    -- 声明游标：获取所有不重复的skc_code
    DECLARE skc_cursor CURSOR FOR 
        SELECT DISTINCT skc_code FROM cos_temu_fully_goods 
				WHERE skc_id is null AND skc_code IS NOT NULL;
				
		 -- 声明游标：获取所有sku_code
    DECLARE sku_cursor CURSOR FOR 
        SELECT DISTINCT sku_code FROM cos_temu_fully_goods 
        WHERE sku_id is null AND sku_code IS NOT NULL;
    
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- 更新SPU_ID
    OPEN spu_cursor;
    spu_loop: LOOP
        FETCH spu_cursor INTO v_spu_code;
        IF done THEN
            LEAVE spu_loop;
        END IF;
        -- 为每个spu_code生成雪花ID
        SET v_spu_id = generate_snowflake_id();
        -- 更新所有相同spu_code记录的spu_id
        UPDATE cos_temu_fully_goods 
        SET spu_id = v_spu_id 
        WHERE spu_code = v_spu_code;
    END LOOP;
    CLOSE spu_cursor;
    SET done = FALSE;
    
    -- 更新SKC_ID
    OPEN skc_cursor;
    skc_loop: LOOP
        FETCH skc_cursor INTO v_skc_code;
        IF done THEN
            LEAVE skc_loop;
        END IF;
        
        -- 为每个skc_code生成雪花ID
        SET v_skc_id = generate_snowflake_id();
        
        -- 更新所有相同skc_code记录的skc_id
        UPDATE cos_temu_fully_goods 
        SET skc_id = v_skc_id 
        WHERE skc_code = v_skc_code;
    END LOOP;
    CLOSE skc_cursor;
		SET done = FALSE;
		
		OPEN sku_cursor;
    sku_loop: LOOP
        FETCH sku_cursor INTO v_sku_code;
        IF done THEN
            LEAVE sku_loop;
        END IF;
        
        -- 为每个sku_code生成唯一雪花ID
        UPDATE cos_temu_fully_goods 
        SET sku_id = generate_snowflake_id()
        WHERE sku_code = v_sku_code;
    END LOOP;
    CLOSE sku_cursor;
		
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for update_fuuly_spu_skc_sku_ids
-- ----------------------------
DROP PROCEDURE IF EXISTS `update_fuuly_spu_skc_sku_ids`;
delimiter ;;
CREATE PROCEDURE `update_fuuly_spu_skc_sku_ids`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_spu_code VARCHAR(64);
    DECLARE v_skc_code VARCHAR(64);
		DECLARE v_sku_code VARCHAR(64);
    DECLARE v_spu_id BIGINT;
    DECLARE v_skc_id BIGINT;
    DECLARE v_sku_id BIGINT;
		DECLARE v_count INT;
		
    -- 声明游标：获取所有不重复的spu_code
    DECLARE spu_cursor CURSOR FOR 
        SELECT DISTINCT spu_code FROM cos_temu_fully_goods 
				WHERE spu_id IS NULL AND spu_code IS NOT NULL;
    
    -- 声明游标：获取所有不重复的skc_code
    DECLARE skc_cursor CURSOR FOR 
        SELECT DISTINCT skc_code FROM cos_temu_fully_goods 
				WHERE skc_id IS NULL AND skc_code IS NOT NULL;
				
		 -- 声明游标：获取所有sku_code
    DECLARE sku_cursor CURSOR FOR 
        SELECT DISTINCT sku_code FROM cos_temu_fully_goods 
        WHERE sku_id IS NULL AND sku_code IS NOT NULL;
    
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- 更新SPU_ID
    OPEN spu_cursor;
    spu_loop: LOOP
        FETCH spu_cursor INTO v_spu_code;
        IF done THEN
            LEAVE spu_loop;
        END IF;
        
        -- 为每个spu_code生成雪花ID
        SET v_spu_id = generate_snowflake_id();
        
        -- 更新所有相同spu_code记录的spu_id
        UPDATE cos_temu_fully_goods 
        SET spu_id = v_spu_id 
        WHERE spu_code = v_spu_code;
    END LOOP;
    CLOSE spu_cursor;
--     SET done = FALSE;
    
    -- 更新SKC_ID
    OPEN skc_cursor;
    skc_loop: LOOP
        FETCH skc_cursor INTO v_skc_code;
        IF done THEN
            LEAVE skc_loop;
        END IF;
        
        -- 为每个skc_code生成雪花ID
        SET v_skc_id = generate_snowflake_id();
        
        -- 更新所有相同skc_code记录的skc_id
        UPDATE cos_temu_fully_goods 
        SET skc_id = v_skc_id 
        WHERE skc_code = v_skc_code;
    END LOOP;
    CLOSE skc_cursor;
-- 		SET done = FALSE;
		
		OPEN sku_cursor;
    sku_loop: LOOP
        FETCH sku_cursor INTO v_sku_code;
        IF done THEN
            LEAVE sku_loop;
        END IF;
        
        -- 为每个sku_code生成唯一雪花ID
        UPDATE cos_temu_fully_goods 
        SET sku_id = generate_snowflake_id()
        WHERE sku_code = v_sku_code;
    END LOOP;
    CLOSE sku_cursor;
		
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for update_semi_spu_skc_sku_ids
-- ----------------------------
DROP PROCEDURE IF EXISTS `update_semi_spu_skc_sku_ids`;
delimiter ;;
CREATE PROCEDURE `update_semi_spu_skc_sku_ids`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_spu_code VARCHAR(64);
    DECLARE v_skc_code VARCHAR(64);
		DECLARE v_sku_code VARCHAR(64);
    DECLARE v_spu_id BIGINT;
    DECLARE v_skc_id BIGINT;
    DECLARE v_sku_id BIGINT;
		DECLARE v_count INT;
		
    -- 声明游标：获取所有不重复的spu_code
    DECLARE spu_cursor CURSOR FOR 
        SELECT DISTINCT spu_code FROM cos_temu_semi_goods 
				WHERE spu_id is null AND spu_code IS NOT NULL;
    
    -- 声明游标：获取所有不重复的skc_code
    DECLARE skc_cursor CURSOR FOR 
        SELECT DISTINCT skc_code FROM cos_temu_semi_goods 
				WHERE skc_id is null AND skc_code IS NOT NULL;
				
		 -- 声明游标：获取所有sku_code
    DECLARE sku_cursor CURSOR FOR 
        SELECT DISTINCT sku_code FROM cos_temu_semi_goods 
        WHERE sku_id is null AND sku_code IS NOT NULL;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- 更新SPU_ID
    OPEN spu_cursor;
    spu_loop: LOOP
        FETCH spu_cursor INTO v_spu_code;
        IF done THEN
            LEAVE spu_loop;
        END IF;
        -- 为每个spu_code生成雪花ID
        SET v_spu_id = generate_snowflake_id();
        -- 更新所有相同spu_code记录的spu_id
        UPDATE cos_temu_semi_goods 
        SET spu_id = v_spu_id 
        WHERE spu_code = v_spu_code;
    END LOOP;
    CLOSE spu_cursor;
		SET done = FALSE;
    
    
    -- 更新SKC_ID
    OPEN skc_cursor;
    skc_loop: LOOP
        FETCH skc_cursor INTO v_skc_code;
        IF done THEN
            LEAVE skc_loop;
        END IF;
        
        -- 为每个skc_code生成雪花ID
        SET v_skc_id = generate_snowflake_id();
        
        -- 更新所有相同skc_code记录的skc_id
        UPDATE cos_temu_semi_goods 
        SET skc_id = v_skc_id 
        WHERE skc_code = v_skc_code;
    END LOOP;
    CLOSE skc_cursor;
		SET done = FALSE;
	
		
		OPEN sku_cursor;
    sku_loop: LOOP
        FETCH sku_cursor INTO v_sku_code;
        IF done THEN
            LEAVE sku_loop;
        END IF;
        
        -- 为每个sku_code生成唯一雪花ID
        UPDATE cos_temu_semi_goods 
        SET sku_id = generate_snowflake_id()
        WHERE sku_code = v_sku_code;
    END LOOP;
    CLOSE sku_cursor;
		
END
;;
delimiter ;

-- ----------------------------
-- Function structure for wait_next_millis
-- ----------------------------
DROP FUNCTION IF EXISTS `wait_next_millis`;
delimiter ;;
CREATE FUNCTION `wait_next_millis`(last_timestamp BIGINT)
 RETURNS bigint
BEGIN
    DECLARE current BIGINT;
    SET current = (UNIX_TIMESTAMP(NOW(3)) * 1000) - 1288834974657;
    WHILE current <= last_timestamp DO
        SET current = (UNIX_TIMESTAMP(NOW(3)) * 1000) - 1288834974657;
    END WHILE;
    RETURN current;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_jh_shipment
-- ----------------------------
DROP TRIGGER IF EXISTS `ins_amf_jh_shipment`;
delimiter ;;
CREATE TRIGGER `ins_amf_jh_shipment` AFTER INSERT ON `amf_jh_shipment` FOR EACH ROW begin
declare jsn json;
set jsn = NEW.propertyShipmentSkuList;
INSERT INTO `amf_jh_shipment_sku` (
  `id`, `property_shipment_id`, `user_key`, `shop_id`, `shop_show_name`,
  `container_no`, `warehouse_sku`, `ship_qty`, `receive_qty`,
  `create_time`, `update_time`
)
SELECT
  jt.id,
  jt.property_shipment_id,
  jt.user_key,
  jt.shop_id,
  jt.shop_show_name,
  jt.container_no,
  jt.warehouse_sku,
  jt.ship_qty,
  jt.receive_qty,
  jt.create_time,
  jt.update_time
FROM
  JSON_TABLE(
  jsn,
  '$[*]' COLUMNS (
    id BIGINT PATH '$.id',
    property_shipment_id BIGINT PATH '$.property_shipment_id',
    user_key VARCHAR(64) PATH '$.user_key',
    shop_id BIGINT PATH '$.shop_id',
    shop_show_name VARCHAR(128) PATH '$.shop_show_name',
    container_no VARCHAR(64) PATH '$.container_no',
    warehouse_sku VARCHAR(64) PATH '$.warehouse_sku',
    ship_qty INT PATH '$.ship_qty',
    receive_qty INT PATH '$.receive_qty',
    create_time DATETIME PATH '$.create_time',
    update_time DATETIME PATH '$.update_time'
  )
) jt;
end
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_jh_shipment
-- ----------------------------
DROP TRIGGER IF EXISTS `upd_amf_jh_shipment`;
delimiter ;;
CREATE TRIGGER `upd_amf_jh_shipment` AFTER UPDATE ON `amf_jh_shipment` FOR EACH ROW begin
declare jsn json;
set jsn = NEW.propertyShipmentSkuList;
replace INTO `amf_jh_shipment_sku` (
  `id`, `property_shipment_id`, `user_key`, `shop_id`, `shop_show_name`,
  `container_no`, `warehouse_sku`, `ship_qty`, `receive_qty`,
  `create_time`, `update_time`
)
SELECT
  jt.id,
  jt.property_shipment_id,
  jt.user_key,
  jt.shop_id,
  jt.shop_show_name,
  jt.container_no,
  jt.warehouse_sku,
  jt.ship_qty,
  jt.receive_qty,
  jt.create_time,
  jt.update_time
FROM
  JSON_TABLE(
  jsn,
  '$[*]' COLUMNS (
    id BIGINT PATH '$.id',
    property_shipment_id BIGINT PATH '$.property_shipment_id',
    user_key VARCHAR(64) PATH '$.user_key',
    shop_id BIGINT PATH '$.shop_id',
    shop_show_name VARCHAR(128) PATH '$.shop_show_name',
    container_no VARCHAR(64) PATH '$.container_no',
    warehouse_sku VARCHAR(64) PATH '$.warehouse_sku',
    ship_qty INT PATH '$.ship_qty',
    receive_qty INT PATH '$.receive_qty',
    create_time DATETIME PATH '$.create_time',
    update_time DATETIME PATH '$.update_time'
  )
) jt;
end
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_jh_warehouse_stock
-- ----------------------------
DROP TRIGGER IF EXISTS `del_amf_warehouse_stock`;
delimiter ;;
CREATE TRIGGER `del_amf_warehouse_stock` AFTER DELETE ON `amf_jh_warehouse_stock` FOR EACH ROW BEGIN

INSERT INTO `amf_jh_warehouse_stock_his` (`id`, `warehouse_id`, `warehouse_sku`, `out_warehouse_sku`, `warehouse_sku_name`, `warehouse_sku_name_cn`, `warehouse_sku_name_en`, `warehouse_name`, `out_warehouse_code`, `out_available_qty`, `out_available_qty_private`, `out_available_qty_public`, `allocation_qty`, `erp_available_qty`, `total_out_available_qty`, `total_out_available_qty_private`, `total_out_available_qty_public`, `total_allocation_qty`, `plan_qty`, `production_qty`, `erp_purchase_onway_qty`, `erp_real_qty`, `erp_domestic_qty`, `current_available_qty`, `transit_qty`, `total_plan_qty`, `total_process_qty`, `total_domestic_qty`, `total_onway_qty`, `total_oversease_qty`, `purchase_value`, `total_plan_amount`, `total_process_amount`, `total_domestic_amount`, `total_onway_amount`, `total_oversease_amount`, `thirdparty_maintain`, `thirdparty_maintain_msg`, `expect_daily_sell_num`, `sell_status`, `inventory_status`, `safe_inventory_day_num`, `sku_inventory_warning_status`, `create_time`, `update_time`, `user_key`) VALUES (OLD.`id`,OLD.`warehouse_id`,OLD.`warehouse_sku`,OLD.`out_warehouse_sku`,OLD.`warehouse_sku_name`,OLD.`warehouse_sku_name_cn`,OLD.`warehouse_sku_name_en`,OLD.`warehouse_name`,OLD.`out_warehouse_code`,OLD.`out_available_qty`,OLD.`out_available_qty_private`,OLD.`out_available_qty_public`,OLD.`allocation_qty`,OLD.`erp_available_qty`,OLD.`total_out_available_qty`,OLD.`total_out_available_qty_private`,OLD.`total_out_available_qty_public`,OLD.`total_allocation_qty`,OLD.`plan_qty`,OLD.`production_qty`,OLD.`erp_purchase_onway_qty`,OLD.`erp_real_qty`,OLD.`erp_domestic_qty`,OLD.`current_available_qty`,OLD.`transit_qty`,OLD.`total_plan_qty`,OLD.`total_process_qty`,OLD.`total_domestic_qty`,OLD.`total_onway_qty`,OLD.`total_oversease_qty`,OLD.`purchase_value`,OLD.`total_plan_amount`,OLD.`total_process_amount`,OLD.`total_domestic_amount`,OLD.`total_onway_amount`,OLD.`total_oversease_amount`,OLD.`thirdparty_maintain`,OLD.`thirdparty_maintain_msg`,OLD.`expect_daily_sell_num`,OLD.`sell_status`,OLD.`inventory_status`,OLD.`safe_inventory_day_num`,OLD.`sku_inventory_warning_status`,OLD.`create_time`,OLD.`update_time`,OLD.`user_key`);


END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_amzorder
-- ----------------------------
DROP TRIGGER IF EXISTS `upd_amf_lx_amzorder`;
delimiter ;;
CREATE TRIGGER `upd_amf_lx_amzorder` AFTER UPDATE ON `amf_lx_amzorder` FOR EACH ROW BEGIN
  declare vid bigint;
  declare vamazon_order_id varchar(80);
  declare vjs json;
  set vid = NEW.id;
  set vamazon_order_id= NEW.amazon_order_id;
  set vjs = NEW.item_list;
  replace INTO `amf_lx_amzorder_item` (  `amzorder_id`, `amazon_order_id`,`asin`, `quantity_ordered`, `seller_sku`, `local_sku`, `local_name`, `item_order_status`)
  SELECT
    vid,
    vamazon_order_id,
    jt.asin,
    jt.quantity_ordered,
    jt.seller_sku,
    jt.local_sku,
    jt.local_name,
    jt.order_status
  FROM
     JSON_TABLE(
    vjs,
    '$[*]' COLUMNS (
      asin VARCHAR(64) PATH '$.asin',
      quantity_ordered INT PATH '$.quantity_ordered',
      seller_sku VARCHAR(64) PATH '$.seller_sku',
      local_sku VARCHAR(64) PATH '$.local_sku',
      local_name VARCHAR(128) PATH '$.local_name',
      order_status VARCHAR(32) PATH '$.order_status'
    )
  ) jt;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_amzorder
-- ----------------------------
DROP TRIGGER IF EXISTS `ins_amf_lx_amzorder`;
delimiter ;;
CREATE TRIGGER `ins_amf_lx_amzorder` AFTER INSERT ON `amf_lx_amzorder` FOR EACH ROW BEGIN
  declare vid bigint;
  declare vamazon_order_id varchar(80);
  declare vjs json;
  set vid = NEW.id;
  set vamazon_order_id= NEW.amazon_order_id;
  set vjs = NEW.item_list;
  replace INTO `amf_lx_amzorder_item` (  `amzorder_id`, `amazon_order_id`,`asin`, `quantity_ordered`, `seller_sku`, `local_sku`, `local_name`, `item_order_status`)
  SELECT
    vid,
    vamazon_order_id,
    jt.asin,
    jt.quantity_ordered,
    jt.seller_sku,
    jt.local_sku,
    jt.local_name,
    jt.order_status
  FROM
     JSON_TABLE(
    vjs,
    '$[*]' COLUMNS (
      asin VARCHAR(64) PATH '$.asin',
      quantity_ordered INT PATH '$.quantity_ordered',
      seller_sku VARCHAR(64) PATH '$.seller_sku',
      local_sku VARCHAR(64) PATH '$.local_sku',
      local_name VARCHAR(128) PATH '$.local_name',
      order_status VARCHAR(32) PATH '$.order_status'
    )
  ) jt;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_bundledproducts
-- ----------------------------
DROP TRIGGER IF EXISTS `ins_amf_lx_bundledproducts`;
delimiter ;;
CREATE TRIGGER `ins_amf_lx_bundledproducts` AFTER INSERT ON `amf_lx_bundledproducts` FOR EACH ROW begin
declare vid BIGINT;
declare vjson json;
set vid = NEW.id;
set vjson = NEW.bundled_products;

replace INTO `amf_lx_bundled_product_items` (
  `bundled_product_id`, `product_id`, `sku`, `bundled_qty`, `cost_ratio`
)
SELECT
  vid AS bundled_product_id,
  jt.productId,
  jt.sku,
  jt.bundledQty,
  jt.cost_ratio
FROM
 JSON_TABLE(
  vjson,
  '$[*]' COLUMNS (
    productId BIGINT PATH '$.productId',
    sku VARCHAR(64) PATH '$.sku',
    bundledQty INT PATH '$.bundledQty',
    cost_ratio DECIMAL(10,4) PATH '$.cost_ratio'
  )
) jt;

END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_bundledproducts
-- ----------------------------
DROP TRIGGER IF EXISTS `upd_amf_lx_bundledproducts`;
delimiter ;;
CREATE TRIGGER `upd_amf_lx_bundledproducts` AFTER UPDATE ON `amf_lx_bundledproducts` FOR EACH ROW begin
declare vid BIGINT;
declare vjson json;
set vid = NEW.id;
set vjson = NEW.bundled_products;

replace INTO `amf_lx_bundled_product_items` (
  `bundled_product_id`, `product_id`, `sku`, `bundled_qty`, `cost_ratio`
)
SELECT
  vid AS bundled_product_id,
  jt.productId,
  jt.sku,
  jt.bundledQty,
  jt.cost_ratio
FROM
 JSON_TABLE(
  vjson,
  '$[*]' COLUMNS (
    productId BIGINT PATH '$.productId',
    sku VARCHAR(64) PATH '$.sku',
    bundledQty INT PATH '$.bundledQty',
    cost_ratio DECIMAL(10,4) PATH '$.cost_ratio'
  )
) jt;

END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_fbadetail
-- ----------------------------
DROP TRIGGER IF EXISTS `ins_amf_lx_fbadetail`;
delimiter ;;
CREATE TRIGGER `ins_amf_lx_fbadetail` BEFORE INSERT ON `amf_lx_fbadetail` FOR EACH ROW BEGIN
	set NEW.sync_date = now();
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_fbadetail
-- ----------------------------
DROP TRIGGER IF EXISTS `upd_amf_lx_fabdetail`;
delimiter ;;
CREATE TRIGGER `upd_amf_lx_fabdetail` BEFORE UPDATE ON `amf_lx_fbadetail` FOR EACH ROW BEGIN
	set NEW.sync_date = now();
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_fbmorders
-- ----------------------------
DROP TRIGGER IF EXISTS `ins_amf_lx_fbmorders`;
delimiter ;;
CREATE TRIGGER `ins_amf_lx_fbmorders` BEFORE INSERT ON `amf_lx_fbmorders` FOR EACH ROW BEGIN
set NEW.amazon_order_id = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(NEW.platform_list, '$[0]')), '');
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_fbmorders_copy1
-- ----------------------------
DROP TRIGGER IF EXISTS `ins_amf_lx_fbmorders_copy1`;
delimiter ;;
CREATE TRIGGER `ins_amf_lx_fbmorders_copy1` BEFORE INSERT ON `amf_lx_fbmorders_copy1` FOR EACH ROW BEGIN
set NEW.amazon_order_id = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(NEW.platform_list, '$[0]')), '');
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_mporders
-- ----------------------------
DROP TRIGGER IF EXISTS `ins_amf_lx_mporders`;
delimiter ;;
CREATE TRIGGER `ins_amf_lx_mporders` AFTER INSERT ON `amf_lx_mporders` FOR EACH ROW BEGIN
  declare vid varchar(80);
  declare vjs json;
  set vid = NEW.global_order_no;
  set vjs = NEW.item_info;

INSERT INTO amf_lx_mporders_item (
    global_order_no,
    globalItemNo,
    item_id,
    platform_order_no,
    order_item_no,
    item_from_name,
    msku,
    local_sku,
    product_no,
    local_product_name,
    is_bundled,
    unit_price_amount,
    item_price_amount,
    quantity,
    remark,
    type,
    stock_cost_amount,
    shipping_amount,
    discount_amount,
    tax_amount,
    sales_revenue_amount,
    transaction_fee_amount,
    data_json,
    is_delete
)
SELECT 
    vid,
    jt.globalItemNo,
    jt.id AS item_id,
    jt.platform_order_no,
    jt.order_item_no,
    jt.item_from_name,
    jt.msku,
    jt.local_sku,
    jt.product_no,
    jt.local_product_name,
    jt.is_bundled,
    -- 将字符串金额转为DECIMAL（若原JSON中是字符串格式）
    CAST(jt.unit_price_amount AS DECIMAL(10,2)) AS unit_price_amount,
    CAST(jt.item_price_amount AS DECIMAL(10,2)) AS item_price_amount,
    jt.quantity,
    jt.remark,
    jt.type,
    CAST(jt.stock_cost_amount AS DECIMAL(10,2)) AS stock_cost_amount,
    CAST(jt.shipping_amount AS DECIMAL(10,2)) AS shipping_amount,
    CAST(jt.discount_amount AS DECIMAL(10,2)) AS discount_amount,
    CAST(jt.tax_amount AS DECIMAL(10,2)) AS tax_amount,
    CAST(jt.sales_revenue_amount AS DECIMAL(10,2)) AS sales_revenue_amount,
    CAST(jt.transaction_fee_amount AS DECIMAL(10,2)) AS transaction_fee_amount,
    jt.data_json AS data_json,
    jt.is_delete
FROM 
    JSON_TABLE(
        vjs,
        '$[*]' COLUMNS (
            globalItemNo VARCHAR(50) PATH '$.globalItemNo',
            id VARCHAR(50) PATH '$.id',
            platform_order_no VARCHAR(50) PATH '$.platform_order_no',
            order_item_no VARCHAR(100) PATH '$.order_item_no',
            item_from_name VARCHAR(50) PATH '$.item_from_name',
            msku VARCHAR(100) PATH '$.msku',
            local_sku VARCHAR(100) PATH '$.local_sku',
            product_no VARCHAR(100) PATH '$.product_no',
            local_product_name VARCHAR(255) PATH '$.local_product_name',
            is_bundled TINYINT PATH '$.is_bundled',
            unit_price_amount VARCHAR(20) PATH '$.unit_price_amount',  -- 先按字符串取，再转换
            item_price_amount VARCHAR(20) PATH '$.item_price_amount',
            quantity INT PATH '$.quantity',
            remark TEXT PATH '$.remark',
            type VARCHAR(20) PATH '$.type',
            stock_cost_amount VARCHAR(20) PATH '$.stock_cost_amount',
            shipping_amount VARCHAR(20) PATH '$.shipping_amount',
            discount_amount VARCHAR(20) PATH '$.discount_amount',
            tax_amount VARCHAR(20) PATH '$.tax_amount',
            sales_revenue_amount VARCHAR(20) PATH '$.sales_revenue_amount',
            transaction_fee_amount VARCHAR(20) PATH '$.transaction_fee_amount',
            data_json JSON PATH '$.data_json',
            is_delete TINYINT PATH '$.is_delete'
        )
    ) AS jt;
    
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_mporders
-- ----------------------------
DROP TRIGGER IF EXISTS `ins_amf_lx_mporders_before`;
delimiter ;;
CREATE TRIGGER `ins_amf_lx_mporders_before` BEFORE INSERT ON `amf_lx_mporders` FOR EACH ROW BEGIN
-- 1. 校验platform_info是否为有效JSON，避免提取报错
  IF JSON_VALID(NEW.platform_info) THEN
    -- 提取平台编码（数组第一个元素），空值则设为''
    SET NEW.platform_code = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(NEW.platform_info, '$[0].platform_code')), '');
    -- 提取平台订单号（数组第一个元素），空值则设为''
    SET NEW.platform_order_no = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(NEW.platform_info, '$[0].platform_order_no')), '');
  ELSE
    -- 无效JSON时，字段置空
    SET NEW.platform_code = '';
    SET NEW.platform_order_no = '';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_mporders
-- ----------------------------
DROP TRIGGER IF EXISTS `upd_amf_lx_mporders`;
delimiter ;;
CREATE TRIGGER `upd_amf_lx_mporders` AFTER UPDATE ON `amf_lx_mporders` FOR EACH ROW BEGIN
  declare vid varchar(80);
  declare vjs json;
  set vid = NEW.global_order_no;
  set vjs = NEW.item_info;

replace INTO amf_lx_mporders_item (
    global_order_no,
    globalItemNo,
    item_id,
    platform_order_no,
    order_item_no,
    item_from_name,
    msku,
    local_sku,
    product_no,
    local_product_name,
    is_bundled,
    unit_price_amount,
    item_price_amount,
    quantity,
    remark,
    type,
    stock_cost_amount,
    shipping_amount,
    discount_amount,
    tax_amount,
    sales_revenue_amount,
    transaction_fee_amount,
    data_json,
    is_delete
)
SELECT 
    vid,
    jt.globalItemNo,
    jt.id AS item_id,
    jt.platform_order_no,
    jt.order_item_no,
    jt.item_from_name,
    jt.msku,
    jt.local_sku,
    jt.product_no,
    jt.local_product_name,
    jt.is_bundled,
    -- 将字符串金额转为DECIMAL（若原JSON中是字符串格式）
    CAST(jt.unit_price_amount AS DECIMAL(10,2)) AS unit_price_amount,
    CAST(jt.item_price_amount AS DECIMAL(10,2)) AS item_price_amount,
    jt.quantity,
    jt.remark,
    jt.type,
    CAST(jt.stock_cost_amount AS DECIMAL(10,2)) AS stock_cost_amount,
    CAST(jt.shipping_amount AS DECIMAL(10,2)) AS shipping_amount,
    CAST(jt.discount_amount AS DECIMAL(10,2)) AS discount_amount,
    CAST(jt.tax_amount AS DECIMAL(10,2)) AS tax_amount,
    CAST(jt.sales_revenue_amount AS DECIMAL(10,2)) AS sales_revenue_amount,
    CAST(jt.transaction_fee_amount AS DECIMAL(10,2)) AS transaction_fee_amount,
    jt.data_json AS data_json,
    jt.is_delete
FROM 
    JSON_TABLE(
        vjs,
        '$[*]' COLUMNS (
            globalItemNo VARCHAR(50) PATH '$.globalItemNo',
            id VARCHAR(50) PATH '$.id',
            platform_order_no VARCHAR(50) PATH '$.platform_order_no',
            order_item_no VARCHAR(100) PATH '$.order_item_no',
            item_from_name VARCHAR(50) PATH '$.item_from_name',
            msku VARCHAR(100) PATH '$.msku',
            local_sku VARCHAR(100) PATH '$.local_sku',
            product_no VARCHAR(100) PATH '$.product_no',
            local_product_name VARCHAR(255) PATH '$.local_product_name',
            is_bundled TINYINT PATH '$.is_bundled',
            unit_price_amount VARCHAR(20) PATH '$.unit_price_amount',  -- 先按字符串取，再转换
            item_price_amount VARCHAR(20) PATH '$.item_price_amount',
            quantity INT PATH '$.quantity',
            remark TEXT PATH '$.remark',
            type VARCHAR(20) PATH '$.type',
            stock_cost_amount VARCHAR(20) PATH '$.stock_cost_amount',
            shipping_amount VARCHAR(20) PATH '$.shipping_amount',
            discount_amount VARCHAR(20) PATH '$.discount_amount',
            tax_amount VARCHAR(20) PATH '$.tax_amount',
            sales_revenue_amount VARCHAR(20) PATH '$.sales_revenue_amount',
            transaction_fee_amount VARCHAR(20) PATH '$.transaction_fee_amount',
            data_json JSON PATH '$.data_json',
            is_delete TINYINT PATH '$.is_delete'
        )
    ) AS jt;
    
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table amf_lx_shipment
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_amf_lx_shipment_after_insert`;
delimiter ;;
CREATE TRIGGER `trg_amf_lx_shipment_after_insert` AFTER INSERT ON `amf_lx_shipment` FOR EACH ROW BEGIN
    -- 声明循环变量处理products数组
    DECLARE i INT DEFAULT 0;
    DECLARE total_products INT;
    DECLARE product_json JSON;
    
    -- 当products不为NULL时才进行处理
    IF NEW.products IS NOT NULL THEN
        -- 获取products数组长度
        SET total_products = JSON_LENGTH(NEW.products);
        
        -- 循环处理每个product子项
        WHILE i < total_products DO
            -- 提取单个product对象
            SET product_json = JSON_EXTRACT(NEW.products, CONCAT('$[', i, ']'));
            
            -- 插入子表（严格对应子表字段类型和约束）
            INSERT INTO amf_lx_shipment_products (
                shipment_id,
                uk,
                product_id,
                seller_id,
                fnsku,
                msku,
                stock_num,
                receive_num,
                breakeven_num,
                good_num,
                sku,
                sku_identifier,
                pic_url,
                seller_name,
                country_name,
                product_name,
                product_title,
                remark,
                match_num,
                product_code,
                twp_name,
                twp_id,
                is_relate_aux,
                is_combo,
                wait_receive_num
            ) VALUES (
                NEW.id,  -- 关联主表ID
                -- 处理非空字段，确保JSON提取值不为NULL
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.uk')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.product_id')), 0),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.seller_id')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.fnsku')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.msku')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.stock_num')), 0),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.receive_num')), 0),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.breakeven_num')), 0),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.good_num')), 0),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.sku')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.sku_identifier')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.pic_url')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.seller_name')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.country_name')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.product_name')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.product_title')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.remark')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.match_num')), 0),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.product_code')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.twp_name')), ''),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.twp_id')), 0),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.is_relate_aux')), 0),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.is_combo')), 0),
                COALESCE(JSON_UNQUOTE(JSON_EXTRACT(product_json, '$.wait_receive_num')), 0)
            );
            
            SET i = i + 1;
        END WHILE;
        
--         -- 校验主表wait_receive_num与子项总和是否一致（处理NULL场景）
--         IF NEW.wait_receive_num IS NOT NULL THEN
--             IF NEW.wait_receive_num != (
--                 SELECT COALESCE(SUM(wait_receive_num), 0) 
--                 FROM amf_lx_shipment_products 
--                 WHERE shipment_id = NEW.id
--             ) THEN
--                 SIGNAL SQLSTATE '45000' 
--                 SET MESSAGE_TEXT = '主表待收货数量与子项总和不一致', MYSQL_ERRNO = 1001;
--             END IF;
--         END IF;
    END IF;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
