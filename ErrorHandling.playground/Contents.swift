//: Playground - noun: a place where people can play

import UIKit

class TEST {
    var a: String?
}

let test = TEST()
test.a = "hi"

print(test.a!)

func change(_ txt: TEST) {
    txt.a = "beach"
}

change(test)

print(test.a!)

enum ShoppingCartError: Error {
    case cartIsFull
    case emptyCart
}

struct Item {
    var price: Double
    var name: String
}

class LiteShoppingCart {
    var items: [Item] = []

    func addItem(item: Item) throws {
//        guard items.count < 5 else {
//            throw ShoppingCartError.cartIsFull
//        }

        if items.count > 4 {
            throw ShoppingCartError.cartIsFull
        }

        items.append(item)
    }

    func checkout() throws {
        guard items.count > 0 else {
            throw ShoppingCartError.emptyCart
        }
    }
}

let shoppingCart = LiteShoppingCart()

do {
    try shoppingCart.addItem(item: Item(price: 10, name: "Product 1"))
    try shoppingCart.addItem(item: Item(price: 10, name: "Product 2"))
    try shoppingCart.addItem(item: Item(price: 10, name: "Product 3"))
    try shoppingCart.addItem(item: Item(price: 10, name: "Product 4"))
    try shoppingCart.addItem(item: Item(price: 10, name: "Product 5"))
    try shoppingCart.addItem(item: Item(price: 10, name: "Product 6"))

    try shoppingCart.checkout()
} catch ShoppingCartError.cartIsFull {

    print("Couldn't add new items because the cart is full")

} catch ShoppingCartError.emptyCart {

    print("The shopping cart is empty!")

}

