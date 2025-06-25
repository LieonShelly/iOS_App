//
//  HeaderView.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/25.
//

import SwiftUI

struct HeaderView: View {
    @Environment(\.dismiss) var dismiss
    var namespace: Namespace.ID
    var event: Event
    var offset: CGFloat
    var collapsed: Bool
    
    var body: some View {
        ZStack {
            AsyncImage(
                url: event.team.sport.imageURL,
                content: { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(height: max(Constants.minHeaderHeight, Constants.headerHeight + offset))
                        .clipped()
                        .cornerRadius(collapsed ? 0 : Constants.cornersRadius)
                        .shadow(radius: 2)
                        .overlay {
                            RoundedRectangle(cornerRadius: collapsed ? 0 : Constants.cornersRadius)
                                .fill(.black.opacity(collapsed ? 0.4 : 0.2))
                        }
                },
                placeholder: {
                    ProgressView().frame(height: Constants.headerHeight)
                }
            )
            
            VStack(alignment: .leading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                          .resizable()
                          .scaledToFit()
                          .frame(height: Constants.iconSizeS)
                          .clipped()
                          .foregroundColor(.white)
                        
                        if collapsed {
                            Text(event.team.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .matchedGeometryEffect(
                                    id: "title",
                                    in: namespace,
                                    properties: .position
                                )
                        } else {
                            Spacer()
                        }
                    }
                        .frame(height: 36)
                        .padding(.top, UIApplication.safeAreaTopInset + Constants.spacingS)
                }
                
                Spacer()
                
                if collapsed {
                    HStack {
                        Image(systemName: "calendar")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(height: Constants.iconSizeS)
                            .foregroundStyle(.white)
                            .clipped()
                            .matchedGeometryEffect(id: "icon", in: namespace)
                        
                        Text(event.date)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .matchedGeometryEffect(
                                id: "date",
                                in: namespace,
                                properties: .position
                            )
                    }
                    .padding(.leading, Constants.spacingM)
                    .padding(.bottom, Constants.spacingM)
                }
            }
            .padding(.horizontal)
            .frame(height: max(Constants.minHeaderHeight, Constants.headerHeight + offset))
        }
    }
}


struct HeaderView_Previews: PreviewProvider {
  @Namespace static var namespace;

  static var previews: some View {
    HeaderView(
      namespace: namespace,
      event: Event(team: teams[0], location: "Somewhere", ticketsLeft: 345),
      offset: -0,
      collapsed: true
    )
  }
}
