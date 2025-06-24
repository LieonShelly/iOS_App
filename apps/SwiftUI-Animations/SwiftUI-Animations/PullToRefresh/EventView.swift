//
//  EventView.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/24.
//

import SwiftUI

struct EventView: View {
    let event: Event
    
    var body: some View {
        VStack {
            AsyncImage(
                url: event.team.sport.imageURL,
                content: { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .clipped()
                },
                placeholder: {
                    ProgressView().frame(height: 100)
                }
            ).id(event.id)
            HStack {
                VStack(alignment: .leading) {
                    Text(event.location)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(event.team.name)
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                    HStack {
                        Text(event.date.uppercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        if event.ticketsLeft > 0 {
                            Text("🎫 \(event.ticketsLeft) tickets left")
                                .font(.caption)
                                .foregroundColor(event.ticketsLeft > 200 ? .primary : .red)
                        } else {
                            Text("Sold out".uppercased())
                                .font(.bold(.caption)())
                                .foregroundColor(.red)
                        }
                    }
                }
                .layoutPriority(100)
                Spacer()

                if event.ticketsLeft > 0 {
                  Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .cornerRadius(10)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(.gray.opacity(0.1), lineWidth: 1.5)
        )
        .padding([.top, .horizontal])
    }
}
