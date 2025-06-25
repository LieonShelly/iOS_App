//
//  TicketView.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/25.
//

import SwiftUI

struct TicketView: View {
    let info: TicketsInfo
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(info.type)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .lineLimit(2)
                    .foregroundColor(Constants.orange)
                
                Text(info.left > 0 ? "🎫 Tickets left \(info.left)" : "SOLD OUT")
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text("💵 From $\(info.price)")
                    .font(.caption)
            }
            .padding(.leading, Constants.spacingL)
        }
        .frame(height: 100)
        .background(
            Image("ticket")
                .resizable()
                .frame(width: UIScreen.halfWidth * 0.9, height: 100)
                .scaledToFill()
                .clipped()
                .shadow(radius: 0.5)
        )
        .padding(.horizontal)
    }
}
