#ifndef JOI_GRAD_SHOPPING_CART_CPP_CUSTOMER_H
#define JOI_GRAD_SHOPPING_CART_CPP_CUSTOMER_H

#include <string>

class Customer {
public:
    Customer() = default;

    Customer(std::string name) : name_(std::move(name)) {}

    std::string GetName() { return name_; }

private:
    std::string name_;
};

#endif //JOI_GRAD_SHOPPING_CART_CPP_CUSTOMER_H
