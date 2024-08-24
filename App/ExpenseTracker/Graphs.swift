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
                    
                    ForEach(chartGroups) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.date.format("MMM yy"))
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .hSpacing(.leading)
                            
                            NavigationLink {
                                ListOfExpanse(moth: group.date)
                            } label: {
                                CardView(income: group.totalIncome, expense: group.totalExpense)
                            }
                        }
                    }
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
        .chartYAxis(content: {
            AxisMarks(position: .leading) { value in
                let doubleValue = value.as(Double.self) ?? 0
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    Text("\(axixLabel(doubleValue))")
                }
            }
        })
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
    
    func axixLabel(_ value: Double) -> String {
        let intValue = Int(value)
        let kvalue = Int(value) / 1000
        return intValue < 1000 ? "\(intValue)" : "\(kvalue)K"
    }
}

struct ListOfExpanse: View {
    let moth: Date
    @State private var incomeList: [Transaction] = []
    @State private var expenseList: [Transaction] = []
    @Environment(\.modelContext) private var modelContext;
    
    init(moth: Date) {
        self.moth = moth
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 15) {
                    Section {
                        ForEach(incomeList, id: \.id) { transaction in
                            NavigationLink {
                                NewExpenseView(editTransactoion: transaction)
                            } label: {
                                TransactionCardView(transaction: transaction)
                            }
                        }
                        
                    } header: {
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .hSpacing(.leading)
                    }
                    
                    Section {
                        ForEach(expenseList, id: \.id) { transaction in
                            NavigationLink {
                                NewExpenseView(editTransactoion: transaction)
                            } label: {
                                TransactionCardView(transaction: transaction)
                            }
                        }
                        
                    } header: {
                        Text("Expense")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .hSpacing(.leading)
                    }
                }
                .padding(15)
            }
        }
        .buttonStyle(.plain)
        .background(.gray.opacity(0.15))
        .navigationTitle(moth.format("MM yy"))
        .navigationDestination(for: Transaction.self) { transacton in
            TransactionCardView(transaction: transacton)
        }
        .onAppear {
            incomeList = (try? modelContext.fetch(Transaction.fetchDescriptor(startDate: moth.startOfMonth, endDate: moth.endOfMonth, category: .income))) ?? []
            expenseList = (try? modelContext.fetch(Transaction.fetchDescriptor(startDate: moth.startOfMonth, endDate: moth.endOfMonth, category: .expense))) ?? []
        }
    }
    
}


struct DataService {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchTransactions(
        startDate: Date,
        endDate: Date,
        category: Category
    ) -> [Transaction] {
        let category = category.rawValue
        let predicate1 = #Predicate<Transaction> { transtion in
            return transtion.dateAdded >= startDate && transtion.dateAdded <= endDate &&
            transtion.category == category
        }
       let descriptor1 = FetchDescriptor<Transaction>(predicate: predicate1, sortBy: [.init(\.dateAdded, order: .forward)])
        return (try? modelContext.fetch(descriptor1)) ?? []
    }
}

extension Transaction {
    
    static func fetchDescriptor(startDate: Date, endDate: Date, category: Category) -> FetchDescriptor<Transaction> {
        let category = category.rawValue
        let predicate1 = #Predicate<Transaction> { transtion in
            return transtion.dateAdded >= startDate && transtion.dateAdded <= endDate &&
            transtion.category == category
        }
       let descriptor1 = FetchDescriptor<Transaction>(predicate: predicate1, sortBy: [.init(\.dateAdded, order: .forward)])
        return descriptor1
    }
}
