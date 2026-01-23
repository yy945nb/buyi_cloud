// 订单处理规则链示例
// Order Processing Rule Chain Example

chain {
    id: "order_processing"
    name: "订单处理流程"
    version: "1.0.0"
    description: "完整的订单处理规则链，包含库存检查、价格计算、会员折扣等"
    
    config {
        maxDepth: 100
        executionTimeout: 60000
        enableLogging: true
    }
    
    // 开始节点，指向第一个处理节点
    start -> checkStock
    
    // 步骤1: 检查库存
    node checkStock {
        type: rule
        expression: `stock >= quantity`
        output: "hasStock"
        description: "检查商品库存是否充足"
        next: checkStockResult
    }
    
    // 步骤2: 根据库存检查结果分支
    condition checkStockResult {
        expression: `hasStock == true`
        then: calculateBasePrice
        else: outOfStock
    }
    
    // 库存不足处理
    node outOfStock {
        type: rule
        expression: `"STOCK_INSUFFICIENT"`
        output: "orderStatus"
        description: "设置订单状态为库存不足"
    }
    
    // 步骤3: 计算基础价格
    node calculateBasePrice {
        type: rule
        expression: `unitPrice * quantity`
        output: "basePrice"
        description: "计算基础价格 = 单价 × 数量"
        next: checkVip
    }
    
    // 步骤4: 检查是否为VIP会员
    condition checkVip {
        expression: `isVip == true`
        then: applyVipDiscount
        else: applyNormalDiscount
    }
    
    // VIP会员折扣: 8折
    node applyVipDiscount {
        type: rule
        expression: `basePrice * 0.8`
        output: "discountedPrice"
        description: "VIP会员享受8折优惠"
        next: calculateTax
    }
    
    // 普通会员折扣: 95折
    node applyNormalDiscount {
        type: rule
        expression: `basePrice * 0.95`
        output: "discountedPrice"
        description: "普通会员享受95折优惠"
        next: calculateTax
    }
    
    // 步骤5: 计算税费
    node calculateTax {
        type: rule
        expression: `discountedPrice * taxRate`
        output: "taxAmount"
        description: "计算税费"
        params {
            taxRate: 0.13
        }
        next: calculateFinalPrice
    }
    
    // 步骤6: 计算最终价格
    node calculateFinalPrice {
        type: rule
        expression: `discountedPrice + taxAmount`
        output: "finalPrice"
        description: "最终价格 = 折扣后价格 + 税费"
        next: setOrderSuccess
    }
    
    // 步骤7: 设置订单成功状态
    node setOrderSuccess {
        type: rule
        expression: `"ORDER_SUCCESS"`
        output: "orderStatus"
        description: "订单处理完成"
    }
    
    end
}
