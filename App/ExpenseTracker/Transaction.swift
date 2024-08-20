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
    let amount: String
    let dataAdded: String
    let category: String
    var tintColor: String
    
    
    init(title: String, remarks: String, amount: String, dataAdded: String, category: Category, tintColor: TintColor) {
        self.title = title
        self.remarks = remarks
        self.amount = amount
        self.dataAdded = dataAdded
        self.category = category.rawValue
        self.tintColor = tintColor.color
    }
    
    var color: Color {
        return tints.first(where: { $0.color == tintColor })?.value ?? appTint
    }
}
