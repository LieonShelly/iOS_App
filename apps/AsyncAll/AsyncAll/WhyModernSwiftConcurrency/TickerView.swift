//
//  TickerView.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/9.
//

import SwiftUI

struct TickerView: View {
    let selectedSymbols: [String]
    @EnvironmentObject var model: LittleJohnModel
    @Environment(\.presentationMode) var presentationMode
    @State var lastErrorMesssage: String = "" {
        didSet { isDisplayingError = true }
    }
    @State var isDisplayingError = false
    
    var body: some View {
        List {
            Section(content: {
                ForEach(model.tickerSymbols, id: \.name) { symbolName in
                    HStack {
                        Text(symbolName.name)
                        Spacer()
                            .frame(maxWidth: .infinity)
                        Text(String(format: "%.3 f", arguments: [symbolName.value]))
                    }
                }
            }, header: {
                Label(" Live", systemImage: "clock.arrow.2.circlepath")
                    .foregroundStyle(Color(UIColor.systemGreen))
                    .font(.custom("FantasqueSansMono-Regular", size: 42))
                    .padding(.bottom, 20)
            })
        }
        .alert("Error", isPresented: $isDisplayingError, actions: {
            Button("Close", role: .cancel) {}
        }, message: {
            Text(lastErrorMesssage)
        })
        .listStyle(.plain)
        .font(.custom("FantasqueSansMono-Regular", size: 18))
        .padding(.horizontal)
        .task {
            do {
                try await model.startTicker(selectedSymbols)
            } catch {
                lastErrorMesssage = error.localizedDescription
            }
        }
        .onChange(of: model.tickerSymbols.count) { oldValue, newValue in
            if newValue == 0 {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
