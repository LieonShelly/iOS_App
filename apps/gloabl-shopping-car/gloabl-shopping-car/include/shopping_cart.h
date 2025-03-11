#ifndef JOI_GRAD_SHOPPING_CART_CPP_SHOPPING_CART_H
#define JOI_GRAD_SHOPPING_CART_CPP_SHOPPING_CART_H

#include <ostream>
#include <vector>
#include "./customer.h"
#include "./product.h"
#include "./order.h"

class ShoppingCart {
public:
    ShoppingCart(Customer &customer, const std::vector<Product> &products) : customer_(customer), products_(products) {}

    void AddProduct(Product product) {
        products_.push_back(product);
    }

    Order Checkout();

    friend std::ostream &operator<<(std::ostream &os, const ShoppingCart &cart);

private:
    std::vector<Product> products_;
    Customer &customer_;
};

#endif //JOI_GRAD_SHOPPING_CART_CPP_SHOPPING_CART_H
