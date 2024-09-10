//
//  Ablum.swift
//  App
//
//  Created by Renjun Li on 2024/8/15.
//

import SwiftUI

@available(iOS 18.0, *)
struct AlbumContentView: View {
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            AlbumHome(size: size, safeArea: safeArea)
        }
    }
}

@available(iOS 18.0, *)
struct AlbumHome: View {
    var size: CGSize
    var safeArea: EdgeInsets
    var sharedData = SharedData()
    
    var body: some View {
        let minH = (size.height + safeArea.top + safeArea.bottom) * 0.4
        let mainOffset = sharedData.mainOffset
        
        ScrollView {
            VStack(spacing: 10) {
                PhotoScrollView(size: size, safeArea: safeArea)
                OtherContents()
                    .padding(.top, -30)
                    .offset(y: sharedData.progress * 30)
            }
            .offset(y: sharedData.canPullDown ? 0 : mainOffset < 0 ? -mainOffset : 0)
            .offset(y: mainOffset < 0 ? mainOffset : 0)
        }
        .onScrollGeometryChange(for: CGFloat.self, of: { proxy in
            proxy.contentOffset.y
        }, action: { oldValue, newValue in
            sharedData.mainOffset = newValue
        })
        .scrollDisabled(sharedData.isExpanded)
        .environment(sharedData)
        .gesture(
            CustomerGesture(isEnabled: true, handle: { gesture in
                let state = gesture.state
                let velocity = gesture.velocity(in: gesture.view).y
                let translation = gesture.translation(in: gesture.view).y
                let isScrolling = state == .began || state == .changed
                if state == .began {
                    sharedData.canPullDown = velocity > 0 && sharedData.mainOffset == -safeArea.top
                    sharedData.canPullUp = velocity < 0 && sharedData.photoScrollOffset == 0
                }
                if isScrolling {
                    if sharedData.canPullDown && !sharedData.isExpanded {
                        let progress = max(min((translation / minH), 1), 0)
                        sharedData.progress = progress
                    }
                    if sharedData.canPullUp && sharedData.isExpanded {
                        let progress = max(min((-translation / minH), 1), 0)
                        sharedData.progress = 1 - progress
                    }
                } else {
                    withAnimation(.smooth(duration: 0.35, extraBounce: 0)) {
                        if sharedData.canPullDown && !sharedData.isExpanded {
                            if translation > 0 {
                                sharedData.isExpanded = true
                                sharedData.progress = 1
                            }
                        }
                        if sharedData.canPullUp && sharedData.isExpanded {
                            if translation < 0 {
                                sharedData.isExpanded = false
                                sharedData.progress = 0
                            }
                        }
                    }
                }
            })
        )
        .background(.gray.opacity(0.05))
    }
}

@available(iOS 18.0, *)
#Preview {
    AlbumContentView()
}
