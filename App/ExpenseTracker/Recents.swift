//
//  Recents.swift
//  App
//
//  Created by Renjun Li on 2024/8/18.
//

import SwiftUI
import SwiftData

struct Recents: View {
    @AppStorage("userName") private var userName: String = ""
    @State private var startDate: Date = .now.startOfMonth
    @State private var endDate: Date = .now.endOfMonth
    @State private var selectedCategory: Category = .expense
    @State private var showFilterView: Bool = false
    @Namespace private var animation
    
    @Query(sort: [SortDescriptor(\Transaction.dateAdded, order: .reverse)], animation: .snappy)
    private var transactions: [Transaction]
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
                        Section {
                            Button {
                                showFilterView = true
                            } label: {
                                Text("\(startDate.format("dd - MM yy")) to \(endDate.format("dd - MM yy"))")
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            }
                            .hSpacing(.leading)
                            
                            CardView(income: 100, expense: 200)
                            
                            segmentControl
                                .padding(.bottom, 10)
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
}


#Preview {
    ContentView()
}
 
