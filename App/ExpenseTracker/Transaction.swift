//
//  Transaction.swift
//  App
//
//  Created by Renjun Li on 2024/8/18.
//

import SwiftUI

enum Category: String, CaseIterable {
    case income = "Income"
    case expense = "Expense"
}

struct TintColor: Identifiable {
    let id: UUID = .init()
    var color: String
    var value: Color
}

var tints: [TintColor] = [
    .init(color: "Red", value: .red),
    .init(color: "Blue", value: .blue),
    .init(color: "Pink", value: .pink),
    .init(color: "Purple", value: .purple),
    .init(color: "Brown", value: .brown),
    .init(color: "Orange", value: .orange),
]

struct Transaction: Identifiable {
    let id: UUID = .init()
    let title: String
    let remarks: String
    let amount: Double
    let dateAdded: Date
    let category: String
    var tintColor: String
    
    
    init(title: String, remarks: String, amount: Double, dateAdded: Date, category: Category, tintColor: TintColor) {
        self.title = title
        self.remarks = remarks
        self.amount = amount
        self.dateAdded = dateAdded
        self.category = category.rawValue
        self.tintColor = tintColor.color
    }
    
    var color: Color {
        return tints.first(where: { $0.color == tintColor })?.value ?? appTint
    }
}


var sampleTransactions: [Transaction] = [
    .init(title: "Magic Keyboard", remarks: "Apple Product", amount: 129, dateAdded: .now, category: .expense, tintColor: tints.randomElement()!),
    .init(title: "Apple Music", remarks: "Subscription", amount: 10.99, dateAdded: .now, category: .expense, tintColor: tints.randomElement()!),
    .init(title: "iCloud", remarks: "Subscription", amount: 5.55, dateAdded: .now, category: .expense, tintColor: tints.randomElement()!),
    .init(title: "Payment", remarks: "Payment Recieved", amount: 2232, dateAdded: .now, category: .income, tintColor: tints.randomElement()!),
    ]
