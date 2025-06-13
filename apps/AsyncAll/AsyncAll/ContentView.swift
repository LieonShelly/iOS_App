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
    @StateObject var storageModel: SuperStorageModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        self._littleJohnModel = .init(wrappedValue: LittleJohnModel())
        self._storageModel = .init(wrappedValue: SuperStorageModel())
    }
    
    var body: some View {
        NavigationStack {
            List(viewModel.list) { item in
                NavigationLink {
                    switch item.page {
                    case .whyModernSwiftConcurrency:
                        WhyModernSwiftConcurrencyPage(model: littleJohnModel)
                    case .getStartedWitgAsyncWait:
                      StorageListView(model: storageModel)
                    case .asyncsequence, .asyncStream:
                      BlabberLoginView()
                    case .taskGroup:
                      SkyView()
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
