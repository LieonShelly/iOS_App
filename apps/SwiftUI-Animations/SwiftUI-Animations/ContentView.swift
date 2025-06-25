//
//  ContentView.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/24.
//

import SwiftUI

struct ContentView: View {
    @State var events: [Event] = []
    @State var pullToRefresh = PullToRefresh(progress: 0, state: .idle)
    private let ease: Animation = .easeInOut(duration: Constants.timeForTheBallToReturn)
    private let spring: Animation = .interpolatingSpring(stiffness: 80, damping: 4)
    @State var filterShown = false
    @State var selectedSports: Set<Sport> = []
    @State var unfilteredEvents: [Event] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollViewGeometryReader(pullToRefresh: $pullToRefresh) {
                    await update()
                }
                
                ZStack(alignment: .top) {
                    BallView(pullToRefresh: $pullToRefresh)
                    VStack {
                        FilterView(selectedSports: $selectedSports, isShown: filterShown)
                            .padding(.top)
                            .zIndex(1)
                        LazyVStack {
                            ForEach(events) { event in
                               NavigationLink(
                                destination: EventDetailsView(event: event), label: {
                                   EventView(event: event)
                               })
                               .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .offset(
                        y: [.ongoing, .preparingFinish].contains(pullToRefresh.state) ? Constants.maxOffset : 0
                    )
                    .animation(pullToRefresh.state != .finishing ? spring : ease, value: pullToRefresh.state)
                }
            }
            .navigationTitle("SportFan")
            .toolbar {
                ToolbarItem {
                    Button {
                        withAnimation(
                            filterShown
                            ? .easeInOut
                            : .interpolatingSpring(
                                stiffness: 20,
                                damping: 3
                            ).speed(2.5)
                        ) {
                            filterShown.toggle()
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(Constants.orange)
                    }
                }
            }
            .onChange(of: selectedSports) { _,_ in filter() }
        }
    }
    
    @MainActor
    func update() async {
        unfilteredEvents = await fetchMoreEvents(toAppend: events)
        filter()
    }
    
    func filter() {
        withAnimation(.interpolatingSpring(stiffness: 30, damping: 8).speed(1.5)) {
            events = selectedSports.isEmpty ? unfilteredEvents : unfilteredEvents.filter { selectedSports.contains($0.team.sport )}
        }
    }
}

#Preview {
    ContentView()
}
