#include "../include/shopping_cart.h"
#include <algorithm>

/**
- 实现如下功能，满足20%折扣的商品将以“ DIS_20”开头的产品代码作为标识。购买此类产品后，客户每消费$20可赚取1点会员积分。
- 实现一组产品的报价功能，支持“满100减50”的特殊商品，该商品将以“DISCOUNT_50_PER_100”开头的产品代码作为标识。跨品类商品无此折扣
- 实现如下功能，当购买总价超过$500，将给予5%的折扣。且实现在输出账单中包含 原总价格，总折扣，折扣后总价 和 总获取会员积分数
 */

Order ShoppingCart::Checkout() {
    double original_total = 0;
    double product_discounts = 0;
    int loyalty_points_earned = 0;

    for(auto &product : products_) {
        const double price = product.GetPrice();
        original_total += price;
        double discount = 0;
        const std::string& code = product.GetProductCode();
        
        if (code.find("DIS_10") == 0) {
            discount = price * 0.10;
            loyalty_points_earned += static_cast<int>(price / 10);
        } else if (code.find("DIS_15") == 0) {
            discount = price * 0.15;
            loyalty_points_earned += static_cast<int>(price / 15);
        } else if (code.find("DIS_20") == 0) {
            discount = price * 0.20;
            loyalty_points_earned += static_cast<int>(price / 20);
        } else if (code.find("DISCOUNT_50_PER_100") == 0) {
            int multiples = static_cast<int>(price) / 100;
            discount = multiples * 50;
            loyalty_points_earned += static_cast<int>(price / 5);
        } else {
            loyalty_points_earned += static_cast<int>(price / 5);
        }
        
        product_discounts += discount;
    }
    
    double subtotal = original_total - product_discounts;
    double total_discount = product_discounts;
    double final_price = subtotal;
    
    if (subtotal > 500) {
        double order_discount = subtotal * 0.05;
        total_discount += order_discount;
        final_price -= order_discount;
    }
    
    return Order(original_total, total_discount, final_price, loyalty_points_earned);
}

std::ostream &operator<<(std::ostream &os, const ShoppingCart &cart) {
    os << "Customer: " << cart.customer_.GetName() << std::endl
       << "Bought: " << std::endl;
    std::vector<std::string> result;
    std::transform(cart.products_.begin(), cart.products_.end(), std::back_inserter(result),
                   [](const Product &p) { return "- " + p.GetName() + ", " + std::to_string(p.GetPrice()); });
    auto begin = result.begin();
    auto end = result.end();
    if (begin != end) {
        os << *begin++;
    }
    while (begin != end) {
        os << std::endl << *begin++;
    }
    return os;
}
