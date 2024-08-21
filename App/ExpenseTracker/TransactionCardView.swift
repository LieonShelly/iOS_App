//
//  TransactoonCardView.swift
//  App
//
//  Created by Renjun Li on 2024/8/20.
//

import SwiftUI

struct TransactionCardView: View {
    @Environment(\.modelContext) private var context
    
    var transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(String(transaction.title.prefix(1)))")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 45, height: 45)
                .background(transaction.color.gradient, in: .circle)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .foregroundStyle(.primary)
                
                Text(transaction.remarks)
                    .font(.caption)
                    .foregroundStyle(.primary.secondary)
                
                Text(transaction.dateAdded.format("dd MM yyyy"))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .lineLimit(1)
            .hSpacing(.leading)
            
            Text(transaction.amount.currencyString(2))
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(.background, in: .rect(cornerRadius: 10))
    }
    
    
    func delete() {
        context.delete(transaction)
    }
}


#Preview {
    ContentView()
}
