#ifndef JOI_GRAD_SHOPPING_CART_CPP_PRODUCT_H
#define JOI_GRAD_SHOPPING_CART_CPP_PRODUCT_H

#include <string>

class Product {
public:
    Product() {};

    Product(double price, std::string product_code, std::string name) : price_(price),
                                                                        product_code_(std::move(product_code)),
                                                                        name_(std::move(name)) {}

    double GetPrice() const { return price_; }

    std::string GetProductCode() const { return product_code_; }

    std::string GetName() const { return name_; }

private:
    const double price_ = 0;
    const std::string product_code_;
    const std::string name_;
};

#endif //JOI_GRAD_SHOPPING_CART_CPP_PRODUCT_H
