//
//  CardView.swift
//  App
//
//  Created by Renjun Li on 2024/8/20.
//

import SwiftUI

struct CardView: View {
    var income: Double
    var expense: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(.background)
            
            VStack(spacing: .zero) {
                HStack(spacing: 12) {
                    Text("\((income - expense).currencyString())")
                        .font(.title.bold())
                    
                    Image(systemName: expense > income ? "chart.line.downtrend.xyaxis" : "chart.line.uptrend.xyaxis")
                        .font(.title3)
                        .foregroundStyle(expense > income ? .red : .green)
                }
                .padding(.bottom, 25)
                
                HStack(spacing: .zero) {
                    ForEach(Category.allCases, id: \.rawValue) { category in
                        let symbolImage = category == .income ? "arrow.down" : "arrow.up"
                        let tint = category == .income ? Color.green : Color.red
                        
                        HStack(spacing: 10, content: {
                            Image(systemName: symbolImage)
                                .font(.callout.bold())
                                .foregroundStyle(tint)
                                .frame(width: 35, height: 35)
                                .background {
                                    Circle().fill(tint.opacity(0.25).gradient)
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                                
                                Text((category == .income ? income : expense).currencyString(0))
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                            if category == .income {
                                Spacer(minLength: 10)
                            }
                        })
                    }
                }
            }
            .padding(25)
            .padding(.top, 15)
        }
    }
}

#Preview {
    CardView(income: 100, expense: 200)
}
