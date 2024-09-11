//
//  Recents.swift
//  App
//
//  Created by Renjun Li on 2024/8/18.
//

import SwiftUI
import SwiftData

struct Recents: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @AppStorage("userName") private var userName: String = ""
    @State private var startDate: Date = .now.startOfMonth
    @State private var endDate: Date = .now.endOfMonth
    @State private var selectedCategory: Category = .expense
    @State private var showFilterView: Bool = false
    @State private var totalIncome: Double = 0
    @State private var totalExpense: Double = 0
    @Namespace private var animation
    @Query(sort: [SortDescriptor(\Transaction.dateAdded, order: .reverse)], animation: .snappy)
    private var transactions: [Transaction]
    
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
                        Section {
                            filterView
                            CardView(income: totalIncome, expense: totalExpense)
                            segmentControl.padding(.bottom, 10)
                            listView
                        } header: {
                            headerView(size)
                        }
                    }
                    .padding(15)
                }
                .background(.gray.opacity(0.15))
                .blur(radius: showFilterView ? 8 : 0)
                .disabled(showFilterView)
            }
            .overlay {
                if showFilterView {
                    DateFilterView(start: startDate, end: endDate, onSubmit: { start, end in
                        startDate = start
                        endDate = end
                        showFilterView = false
                    }, onClose: {
                        showFilterView = false
                    })
                        .transition(.move(edge: .leading))
                }
             
            }
            .animation(.snappy, value: showFilterView)
        }
    }
    
    var filterView: some View {
        Button {
            showFilterView = true
        } label: {
            Text("\(startDate.format("dd - MM yyyy")) to \(endDate.format("dd - MM yyyy"))")
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .hSpacing(.leading)
    }
    
    var listView: some View {
        ForEach(transactions.filter { $0.category == selectedCategory.rawValue }) { transaction in
            SwipeActionView(cornorRadius: 15, direction: .leading, content: {
                NavigationLink {
                    NewExpenseView(editTransactoion: transaction)
                } label: {
                    TransactionCardView(transaction: transaction)
                }
                .buttonStyle(.plain)
            }, actions: {
                SwipeAction(tint: .blue, icon: "star.fill") {
                    print("Delete")
                }
                SwipeAction(tint: .red, icon: "trash.fill") {
                    print("Delete")
                    withAnimation(.snappy) {
                        modelContext.delete(transaction)
                    }
                }
            })
        }
        .onAppear {
            fetchData()
        }
    }
    
    @ViewBuilder
    func headerView(_ size: CGSize) -> some View {
        HStack(spacing: 20, content: {
            VStack(alignment: .leading, spacing: 5) {
                Text("Welcome!")
                    .font(.title.bold())
                if !userName.isEmpty {
                    Text(userName)
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
            .visualEffect({ content, proxy in
                content.scaleEffect(headerScale(size, proxy: proxy), anchor: .topLeading)
            })
            
            Spacer()
            NavigationLink {
                NewExpenseView()
            } label: {
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
                    .background(appTint.gradient, in: .circle)
                    .contentShape(.circle)
            }
        })
        .padding(.bottom, userName.isEmpty ? 10 : 5)
        .background {
            VStack(spacing: .zero) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                Divider()
            }
            .visualEffect({ content, geometry in
                content.opacity(headerBGOpacity(geometry))
            })
            .padding(.horizontal, -15)
            .padding(.top, -(safeArea().top + 15))
        }
    }
    nonisolated
    func headerBGOpacity(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY + safeArea().top
        return minY > 0 ? 0 : (-minY / 15)
    }
    
    nonisolated
    func headerScale(_ size: CGSize, proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        let screenHeight = size.height
        
        let progress = minY / screenHeight
        let scale = min(max(progress, 0), 1) * 0.6
        return 1 + scale
    }
    
    var segmentControl: some View {
        HStack(spacing: .zero) {
            ForEach(Category.allCases, id: \.rawValue) { categor in
                Text(categor.rawValue)
                    .hSpacing()
                    .padding(.vertical, 10)
                    .background {
                        if categor == selectedCategory {
                            Capsule()
                                .fill(.background)
                                .matchedGeometryEffect(id: "ACTIVEDTAB", in: animation)
                        }
                    }
                    .contentShape(.capsule)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            selectedCategory = categor
                        }
                    }
            }
        }
        .background(.gray.opacity(0.15), in: .capsule)
        .padding(.top, 5)
    }
    
    func fetchData() {
        totalIncome = transactions.filter({ $0.category == Category.income.rawValue}).map { $0.amount }.reduce(0, { $0 + $1 })
        totalExpense = transactions.filter({ $0.category == Category.expense.rawValue}).map { $0.amount }.reduce(0, { $0 + $1 })
    }
}


#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
 

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Transaction.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = container.mainContext
        if try modelContext.fetch(FetchDescriptor<Transaction>()).isEmpty {
            sampleTransactions.forEach { container.mainContext.insert($0) }
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()


private var sampleTransactions: [Transaction] = [
    .init(title: "Apple", remarks: "Apple subscribe", amount: 200, dateAdded: Date(), category: .expense, tintColor: .init(color: "Red", value: .red)),
    .init(title: "Apple", remarks: "Apple subscribe", amount: 200, dateAdded: Date(), category: .expense, tintColor: .init(color: "Blue", value: .blue)),
    .init(title: "Apple", remarks: "Apple subscribe", amount: 200, dateAdded: Date(), category: .expense, tintColor: .init(color: "Red", value: .yellow)),
    .init(title: "Apple", remarks: "Apple subscribe", amount: 200, dateAdded: Date(), category: .expense, tintColor: .init(color: "Red", value: .pink)),
    .init(title: "Apple", remarks: "Apple subscribe", amount: 200, dateAdded: Date(), category: .expense, tintColor: .init(color: "Red", value: .red)),
    .init(title: "Apple", remarks: "Apple subscribe", amount: 200, dateAdded: Date(), category: .expense, tintColor: .init(color: "Red", value: .red)),
    .init(title: "App", remarks: "Apple subscribe income", amount: 200, dateAdded: Date(), category: .income, tintColor: .init(color: "Red", value: .red)),
    .init(title: "App", remarks: "Apple subscribe income", amount: 200, dateAdded: Date(), category: .income, tintColor: .init(color: "Red", value: .pink)),
    .init(title: "App", remarks: "Apple subscribe income", amount: 200, dateAdded: Date(), category: .income, tintColor: .init(color: "Red", value: .yellow)),
    .init(title: "App", remarks: "Apple subscribe income", amount: 200, dateAdded: Date(), category: .income, tintColor: .init(color: "Red", value: .purple)),
    .init(title: "App", remarks: "Apple subscribe income", amount: 200, dateAdded: Date(), category: .income, tintColor: .init(color: "Red", value: .red)),
    
]
