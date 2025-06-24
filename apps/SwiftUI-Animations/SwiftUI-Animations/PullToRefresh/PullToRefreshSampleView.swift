
//
//  PullToRefreshSampleView.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/24.
//

import SwiftUI

struct PullToRefreshSampleView: View {
    @State var events: [Event] = []
    @State var pullToRefresh = PullToRefresh(progress: 0, state: .idle)
    private let ease: Animation = .easeInOut(duration: Constants.timeForTheBallToReturn)
    private let spring: Animation = .interpolatingSpring(stiffness: 80, damping: 4)
    
    var body: some View {
        ScrollView {
            ScrollViewGeometryReader(pullToRefresh: $pullToRefresh) {
                await update()
                print("Update")
            }
            
            ZStack(alignment: .top) {
                BallView(pullToRefresh: $pullToRefresh)
                LazyVStack {
                    ForEach(events) { event in
                        EventView(event: event)
                    }
                }
                .offset(
                    y: [.ongoing, .preparingFinish].contains(pullToRefresh.state) ? Constants.maxOffset : 0
                )
                .animation(pullToRefresh.state != .finishing ? spring : ease, value: pullToRefresh.state)
            }
        }
    }
    
    @MainActor
    func update() async {
        events = await fetchMoreEvents(toAppend: events)
    }
}
