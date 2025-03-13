#include <iostream>
#include <vector>
#include "../include/product.h"
#include "../include/customer.h"
#include "../include/shopping_cart.h"

int main() {
    Product normal(100, "NORMAL", "normal");
    Product product1(10.0, "DIS_10_PRODUCT1", "product 1");
    Product product2(20.0, "DIS_10_PRODUCT2", "product 2");

    std::vector<Product> products;
    products.push_back(normal);
    products.push_back(product1);
    products.push_back(product2);

    Customer customer("A Customer");

    ShoppingCart shopping_cart(customer, products);
    Product product3(30.0, "DIS_10_PRODUCT3", "product 3");
    shopping_cart.AddProduct(product3);
    
    Product product4(300.0, "DISCOUNT_50_PER_100", "product 4");
    shopping_cart.AddProduct(product4);
    
    std::cout << shopping_cart << std::endl;

    Order order = shopping_cart.Checkout();
    std::cout << order << std::endl;

}
