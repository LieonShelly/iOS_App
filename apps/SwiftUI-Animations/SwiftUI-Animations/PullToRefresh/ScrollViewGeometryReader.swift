//
//  ScrollViewGeometryReader.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/24.
//

import SwiftUI

struct ScrollViewGeometryReader: View {
    @Binding var pullToRefresh: PullToRefresh
    let update: () async -> Void

    @State private var startOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader<Color> { proxy in
            Task { caculateOffset(from: proxy) }
            return Color.clear
        }
        .task {
            await update()
        }
    }
    
    private func caculateOffset(from proxy: GeometryProxy) {
        let currentOffset = proxy.frame(in: .global).minY
        switch pullToRefresh.state {
        case .idle:
            startOffset = currentOffset
            pullToRefresh.state = .pulling
            
        case .pulling where pullToRefresh.progress < 1:
            pullToRefresh.progress = min(1, (currentOffset - startOffset) / Constants.maxOffset)
            
        case .pulling:
            pullToRefresh.state = .ongoing
            pullToRefresh.progress = 0
            Task {
                await update()
                pullToRefresh.state = .preparingFinish
                after(Constants.timeForTheBallToReturn) {
                    pullToRefresh.state = .finishing
                    after(Constants.timeForTheBallToRollOut) {
                        pullToRefresh.state = .idle
                        startOffset = 0
                    }
                }
            }
        default: return
        }
    }
}
