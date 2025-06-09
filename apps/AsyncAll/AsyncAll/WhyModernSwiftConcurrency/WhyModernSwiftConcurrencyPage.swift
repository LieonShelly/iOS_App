//
//  WhyModernSwiftConcurrencyPage.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/9.
//
import SwiftUI

struct WhyModernSwiftConcurrencyPage: View {
    let model: LittleJohnModel
    @State var symbols: [String] = []
    @State var selected: Set<String> = []
    @State var lastErrorMessage: String = "" {
        didSet { isDisplayingError = true }
    }
    @State var isDisplayingError = false
    @State var isDisplayingTicker = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(content: {
                    if symbols.isEmpty {
                        ProgressView().padding()
                    }
                    ForEach(symbols, id: \.self) { symbolName in
                        SymbolRow(symbolName: symbolName, selected: $selected)
                    }
                    .font(.custom("FantasqueSansMono-Regular", size: 18))
                }, header: Header.init
                )
            }
            .listStyle(.plain)
            .statusBarHidden(true)
            .toolbar {
                Button("Live ticker") {
                    if !selected.isEmpty {
                        isDisplayingTicker = true
                    }
                }
                .disabled(selected.isEmpty)
            }
            .alert("Error", isPresented: $isDisplayingError, actions: {
                Button("Close", role: .cancel) {}
            }, message: {
                Text(lastErrorMessage)
            })
            .padding(.horizontal)
            .task {
                guard symbols.isEmpty else { return }
                do {
                    symbols = try await model.availableSymbols()
                } catch {
                    lastErrorMessage = error.localizedDescription
                }
            }
            .navigationDestination(isPresented: $isDisplayingTicker) {
                TickerView(selectedSymbols: .init(selected))
                    .environmentObject(model)
            }
        }
    }
}
