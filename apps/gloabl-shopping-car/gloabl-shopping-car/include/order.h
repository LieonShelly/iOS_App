#ifndef JOI_GRAD_SHOPPING_CART_CPP_ORDER_H
#define JOI_GRAD_SHOPPING_CART_CPP_ORDER_H

#include <ostream>

class Order {
public:
    Order(double original_total,
          double total_discount,
          double final_price ,
          int loyalty_pints_earned)
    : original_total_(original_total),
    total_discount_(total_discount),
    final_price_(final_price),
    loyalty_points_(loyalty_pints_earned)
    {}

    double GetOriginalTotal() { return original_total_; }
    
    double GetTotalDiscount() { return total_discount_; }
    
    double GetFinalPrice() { return final_price_; }

    int GetLoyaltyPoints() { return loyalty_points_; }

    friend std::ostream &operator<<(std::ostream &os, const Order &order) {
        os << "Original price: " << order.original_total_ << "\n"
        << "Total discount " << order.total_discount_ << "\n"
        << "Final price " << order.final_price_ << "\n"
        << "Loyalty points earned " << order.loyalty_points_ << "\n";
        return os;
    }

private:
    double original_total_;
    double total_discount_;
    double final_price_;
    int loyalty_points_;
};

#endif //JOI_GRAD_SHOPPING_CART_CPP_ORDER_H
