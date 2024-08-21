//
//  Graphs.swift
//  App
//
//  Created by Renjun Li on 2024/8/18.
//

import SwiftUI
import SwiftData
import Charts

struct Graphs: View {
    @Query(animation: .snappy) private var transactions: [Transaction]
    @State private var chartGroups: [ChartGroup] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    chartView()
                        .padding(20)
                        .padding(.top, 10)
                        .frame(height: 200)
                        .background(.background, in: .rect(cornerRadius: 10))
                }
                .padding(15)
            }
            .navigationTitle("Graphs")
            .background(.gray.opacity(0.15))
            .onAppear {
                createGroup()
            }
        }
    }
    
    func chartView() -> some View {
        Chart {
            ForEach(chartGroups) { group in
                ForEach(group.categories) { chart in
                    BarMark(x: .value("Month", group.date.format("MM yy")),
                            y: .value(chart.category.rawValue, chart.totalValue),
                            width: 20
                    )
                    .position(by: .value("Category", chart.category.rawValue), axis: .horizontal)
                    .foregroundStyle(by: .value("Category", chart.category.rawValue))
                }
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 4)
        .chartLegend(position: .bottom, alignment: .trailing)
        .chartForegroundStyleScale(range: [Color.green.gradient, Color.red.gradient])
    }
    
    func createGroup() {
        Task.detached(priority: .high) {
            let calendar = Calendar.current
            let groupedByDate = await Dictionary(grouping: transactions) { transaction in
                let components = calendar.dateComponents([.month, .year], from: transaction.dateAdded)
                return components
            }
            let sortedGroups = groupedByDate.sorted {
                let date1 = calendar.date(from: $0.key) ?? .init()
                let date2 = calendar.date(from: $1.key) ?? .init()
                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }
            
            let chartGroups = sortedGroups.compactMap { dict -> ChartGroup? in
                let date = calendar.date(from: dict.key) ?? .init()
                let income = dict.value.filter({ $0.category == Category.income.rawValue})
                let expense = dict.value.filter({ $0.category == Category.expense.rawValue})
                
                let incomeTotalValue = total(income, category: .income)
                let expenseTotalValue = total(expense, category: .expense)
                return .init(date: date, categories: [
                    .init(category: .income, totalValue: incomeTotalValue),
                    .init(category: .expense, totalValue: expenseTotalValue)
                ], totalIncome: incomeTotalValue, totalExpense: expenseTotalValue)
            }
            
            await MainActor.run {
                self.chartGroups = chartGroups
            }
            
        }
    }
}
