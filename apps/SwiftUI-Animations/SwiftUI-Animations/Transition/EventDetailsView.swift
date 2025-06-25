//
//  EventDetailsView.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/25.
//

import SwiftUI

struct EventDetailsView: View {
    let event: Event
    @State private var upcomingEvents: [Event] = []
    @State private var info: [TicketsInfo] = []
    @State private var properties: [TicketsInfo: (Double, Double)] = [:]
    @State var seatingChartVisible = false
    @State private var offset: CGFloat = 0
    @State private var collapsed = false
    @Namespace var namespace
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                HeaderView(
                    namespace: namespace,
                    event: event,
                    offset: offset,
                    collapsed: collapsed
                )
                Spacer()
            }
            .zIndex(1)
            
            ScrollView {
                ZStack {
                    HeaderGeometryReader(
                        offset: $offset,
                        collapsed: $collapsed
                    )
                    
                    VStack {
                        Spacer()
                            .frame(height: Constants.headerHeight)
                        
                        if !collapsed {
                            Text(event.team.name)
                              .frame(maxWidth: .infinity, alignment: .leading)
                              .font(.title2)
                              .fontWeight(.black)
                              .foregroundColor(.primary)
                              .padding()
                              .matchedGeometryEffect(id: "title", in: namespace, properties: .position)
                              .zIndex(2)
                        }
                        
                        Text(event.team.description)
                          .font(.footnote)
                          .foregroundColor(.secondary)
                          .padding(.horizontal)
                        
                        EventLocationAndDate(
                            namespace: namespace,
                            event: event,
                            collapsed: collapsed
                        )
                        
                        if !collapsed {
                            Button {
                                seatingChartVisible = true
                            } label: {
                                Text("Seating Chart")
                                    .lineLimit(1)
                                    .foregroundStyle(.white)
                                    .frame(minWidth: UIScreen.halfWidth / 2)
                                    .padding(.horizontal)
                                    .background {
                                        RoundedRectangle(cornerRadius: 36)
                                            .fill(Constants.orange)
                                            .shadow(radius: 2)
                                            .frame(height: 48)
                                            .frame(width: max(Constants.floatingButtonWidth, min(UIScreen.halfWidth * 1.5, UIScreen.halfWidth * 1.5 + offset * 2)))
                                    }
                                    .matchedGeometryEffect(id: "button", in: namespace, properties: .position)
                            }
                            .padding(.vertical, Constants.spacingM)
                        }
                        
                        Text("Available Tickets")
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .font(.title3)
                          .fontWeight(.black)
                          .foregroundColor(.primary)
                          .padding()
                    
                        LazyVGrid(columns: [GridItem(), GridItem()]) {
                            ForEach(info, id: \.type) { info in
                                TicketView(info: info)
                                    .padding(.top, properties[info]?.0 ?? 0)
                                    .rotationEffect(.degrees(properties[info]?.1 ?? 0))
                            }
                        }
                        .padding()
                    }
                }
            }
            .task {
                fetchTicketsAndUpcommingEvents()
            }
        }
        .toolbar(.hidden)
        .edgesIgnoringSafeArea(.top)
    }
    
    private func fetchTicketsAndUpcommingEvents() {
        let info = getTicketsInfo(for: event)
        info.forEach {
            properties[$0] = (.random(in: -16 ..< -5), .random(in: -10 ... 10))
        }
        self.info = info
        upcomingEvents = (0..<5).map { _ in makeEvent(for: event.team) }
    }
}



extension UIApplication {
    static var safeAreaTopInset: CGFloat {
        return UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive && $0 is UIWindowScene }
            .flatMap { $0 as? UIWindowScene }?.windows
            .first { $0.isKeyWindow }?
            .safeAreaInsets.top ?? 0
    }
}

