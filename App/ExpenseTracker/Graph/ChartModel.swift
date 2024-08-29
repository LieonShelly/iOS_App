//
//  ChartModel.swift
//  App
//
//  Created by Renjun Li on 2024/8/21.
//

import Foundation

struct ChartGroup: Identifiable {
    let id: UUID = .init()
    var date: Date
    var categories: [ChartCategory]
    var totalIncome: Double
    var totalExpense: Double
}

struct ChartCategory: Identifiable {
    let id: UUID = .init()
    var category: Category
    var totalValue: Double
}
