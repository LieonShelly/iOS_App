//
//  SymbolRow.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/9.
//

import SwiftUI

struct SymbolRow: View {
    let symbolName: String
    @Binding var selected: Set<String>
    
    var body: some View {
        Button(action: {
            if !selected.insert(symbolName).inserted {
                selected.remove(symbolName)
            }
        }, label: {
            HStack {
                HStack {
                    if selected.contains(symbolName) {
                        Image(systemName: "checkmark")
                    }
                }
                .frame(width: 20)
                
                Text(symbolName)
                    .fontWeight(.bold)
            }
        })
    }
}

struct Header: View {
    var body: some View {
        Label(" LittleJohn", systemImage: "chart.bar.xaxis")
          .foregroundColor(.green)
          .font(.custom("FantasqueSansMono-Regular", size: 34))
          .padding(.bottom, 20)
    }
}
