//
//  PhotoScrollView.swift
//  App
//
//  Created by Renjun Li on 2024/8/15.
//

import SwiftUI

@available(iOS 18.0, *)
struct PhotoScrollView: View {
    var size: CGSize
    var safeArea: EdgeInsets
    @Environment(SharedData.self) private var sharedData
    @State private var scrollPosition: ScrollPosition = .init()
    
    var body: some View {
        let screenH = size.height + safeArea.top + safeArea.bottom
        let minH = screenH * 0.4
        ScrollView(.horizontal) {
            LazyHStack(alignment: .bottom, spacing: .zero) {
                gridePhotoScrollView
                    .frame(width: size.width)
                    .id(1)
                
                Group {
                    strechableView(.blue)
                        .id(2)
                    strechableView(.yellow)
                        .id(3)
                    strechableView(.purple)
                        .id(4)
                }
                .frame(height: screenH - minH)
            }
            .safeAreaPadding(.bottom, safeArea.bottom + 20)
            .scrollTargetLayout()
            .offset(y: sharedData.canPullUp ? sharedData.photoScrollOffset : 0)
        }
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: .init(get: {
            return sharedData.activePage
        }, set: {
            if let newValue = $0 { sharedData.activePage = newValue }
        }))
        .scrollDisabled(sharedData.isExpanded)
        .frame(height: screenH)
        .frame(height: screenH - (minH - (minH * sharedData.progress)), alignment: .bottom)
        .overlay(alignment: .bottom) {
            PageIndicatorView {
                Task {
                    if sharedData.photoScrollOffset != 0 {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            scrollPosition.scrollTo(edge: .bottom)
                        }
                        try? await Task.sleep(for: .seconds(0.13))
                    }
                    withAnimation(.easeIn(duration: 0.25)) {
                        sharedData.progress = 0
                        sharedData.isExpanded = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var gridePhotoScrollView: some View {
        if #available(iOS 18.0, *) {
            ScrollView(.vertical) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(spacing: 4), count: 3),
                    spacing: 4) {
                        ForEach(1 ... 30, id: \.self) { _ in
                            Rectangle()
                                .fill(.red)
                                .frame(height: 120)
                        }
                    }
                    .scrollTargetLayout()
                    .offset(y: sharedData.progress * -(safeArea.bottom + 20))
            }
            .defaultScrollAnchor(.bottom)
            .scrollClipDisabled()
            .scrollPosition($scrollPosition )
            .scrollDisabled(!sharedData.isExpanded)
            .onScrollGeometryChange(for: CGFloat.self) { proxy in
                proxy.contentOffset.y - proxy.contentSize.height + proxy.containerSize.height
            } action: { oldValue, newValue in
                sharedData.photoScrollOffset = newValue
            }
        }

    }
    
    func strechableView(_ color: Color) -> some View {
        GeometryReader {
            let minY = $0.frame(in: .scrollView(axis: .vertical)).minY
            let size = $0.size
            
            Rectangle()
                .fill(color)
                .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0))
                .offset(y: (minY > 0 ? -minY : 0))
        }
        .frame(width: size.width)
    }
}


#Preview {
    AlbumContentView()
}
