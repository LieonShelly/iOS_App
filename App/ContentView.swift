//
//  ContentView.swift
//  App
//
//  Created by Renjun Li on 2024/7/26.
//

import SwiftUI
import SwiftData

class ContentViewModel: ObservableObject {
    
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @AppStorage("isFirstTime") private var isFirstTime: Bool = true
    @State private var activeTab: Tab = .recents
    @StateObject var viewModel: ContentViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: ContentViewModel())
    }

    var body: some View {
        TabView(selection: $activeTab) {
            Recents()
                .tag(Tab.recents)
                .tabItem {
                    Tab.recents.tabContent
                }
            
            Search()
                .tag(Tab.search)
                .tabItem {
                    Tab.search.tabContent
                }
            
            Graphs()
                .tag(Tab.charts)
                .tabItem {
                    Tab.charts.tabContent
                }
            
            Settings()
                .tag(Tab.settings)
                .tabItem {
                    Tab.settings.tabContent
                }
        }
        .environmentObject(viewModel)
        .tint(appTint)
        .sheet(isPresented: $isFirstTime) {
            IntroScreen()
                .interactiveDismissDisabled()
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
