//
//  EventLocationAndDate.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/25.
//

import SwiftUI

struct EventLocationAndDate: View {
    var namespace: Namespace.ID
    var event: Event
    var collapsed: Bool
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: Constants.spacingS) {
                Image(systemName: "location.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: Constants.iconSizeL)
                    .clipped()
                
                Text(event.location)
                    .lineLimit(1)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                
                Spacer()
            }
            HStack(spacing: Constants.spacingS) {
                if !collapsed {
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(height: Constants.iconSizeL)
                        .clipped()
                        .matchedGeometryEffect(id: "icon", in: namespace)
                    
                    Text(event.date)
                        .lineLimit(1)
                        .fontWeight(.heavy)
                        .font(.subheadline)
                        .matchedGeometryEffect(id: "date", in: namespace, properties: .position)
                }
                Spacer()
            }
        }
        .padding()
    }
}
