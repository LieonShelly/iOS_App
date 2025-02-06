//
//  DemoContentView.swift
//  DemoApp
//
//  Created by Renjun Li on 2025/1/9.
//

import SwiftUI
import UIComponent

struct DemoContentView: View {
    @State var items: [Int] = [1, 2, 3, 4, 5, 6, 7, 9, 91, 10, 11]
    @State var isRefreshing: Bool = false
    
    var body: some View {
        LazyVStack {
            ForEach(items, id: \.self) { index in
                HStack {
                    Text("index\(index) - \(UUID().uuidString)")
                    VStack {
                        Rectangle().fill(.red)
                            .frame(width: 50, height: 50)
                        
                        Rectangle().fill(.blue)
                            .frame(width: 50, height: 50)
                    }
                    VStack {
                        Rectangle().fill(.yellow)
                        Rectangle().fill(.purple)
                    }
                }
            }
        }
        .refreshable(isRefreshing: $isRefreshing) {
            refresh()
        }
    }
    
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
            items = [1, 2, 3, 4, 5, 6, 7, 9, 9, 10, 11].shuffled()
            self.isRefreshing = false
        })
    }
    
}

