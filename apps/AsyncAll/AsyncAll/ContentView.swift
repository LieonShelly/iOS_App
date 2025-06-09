//
//  ContentView.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/9.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    @StateObject var littleJohnModel: LittleJohnModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        self._littleJohnModel = .init(wrappedValue: LittleJohnModel())
    }
    
    var body: some View {
        NavigationStack {
            List(viewModel.list) { item in
                NavigationLink {
                    switch item.page {
                    case .whyModernSwiftConcurrency:
                        WhyModernSwiftConcurrencyPage(model: littleJohnModel)
                    default: EmptyView()
                    }
                } label: {
                    HStack {
                        Text("\(item.name)")
                            .font(.body)
                            .padding(.leading, 20)
                        Spacer()
                    }
                }
            }
            .navigationTitle("AsyncDemo")
        }
      
    }
}



#Preview {
    ContentView(viewModel: HomeViewModel())
}
