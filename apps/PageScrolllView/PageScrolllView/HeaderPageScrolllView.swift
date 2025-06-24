//
//  PageLabel.swift
//  PageScrolllView
//
//  Created by Renjun Li on 2025/6/21.
//

import SwiftUI

struct PageLabel {
    var title: String
    var symbolImage: String
}

@resultBuilder
struct PageLabelBuilder {
    static func buildBlock(_ components: PageLabel...) -> [PageLabel] {
        components.compactMap { $0 }
    }
}


struct HeaderPageScrolllView<Header: View, Pages: View>: View {
    var displaySymbols: Bool = false
    @ViewBuilder var header: Header
    @PageLabelBuilder var labels: [PageLabel]
    @ViewBuilder var pages: Pages
    @State private var activeTab: String?
    @State private var headerHeight: CGFloat = 0
    @State private var scrollGeometories: [ScrollGeometry]
    @State private var scrollPositions: [ScrollPosition]
    let onRefresh: () async -> Void
    @State private var mainScrollDisbaled: Bool = false
    @State private var mainScrollGeometry: ScrollGeometry = .init()
    @State private var mainScrollPhrase: ScrollPhase = .idle
    
    init(
        displaySymbols: Bool,
        @ViewBuilder header: @escaping () -> Header,
        @PageLabelBuilder labels: @escaping () -> [PageLabel],
        @ViewBuilder pages: @escaping () -> Pages,
        onRefresh: @escaping () async -> Void
    ) {
        self.displaySymbols = displaySymbols
        self.header = header()
        self.labels = labels()
        self.pages = pages()
        self.onRefresh = onRefresh
        let count = labels().count
        self._scrollGeometories = .init(initialValue: .init(repeating: .init(), count: count))
        self._scrollPositions = .init(initialValue: .init(repeating: .init(), count: count))
    }
    
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ScrollView(.horizontal) {
                HStack(spacing: .zero) {
                    Group(subviews: pages) { collection in
                        if collection.count != labels.count {
                            Text("TabViews and labels doest not match")
                        } else {
                            ForEach(labels, id: \.title) { label in
                                pageScrollView(
                                    label: label,
                                    size: size,
                                    collection: collection
                                )
                            }
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $activeTab)
            .scrollIndicators(.hidden)
            .scrollDisabled(mainScrollDisbaled)
            .allowsHitTesting(mainScrollPhrase == .idle)
            .onScrollPhaseChange({ oldPhase, newPhase in
                mainScrollPhrase = newPhase
            })
            .onScrollGeometryChange(for: ScrollGeometry.self, of: { $0 }, action: { oldValue, newValue in
                mainScrollGeometry = newValue
            })
            .mask({
                Rectangle()
                    .ignoresSafeArea(.all, edges: .bottom )
            })
            .onAppear {
                guard activeTab == nil else { return }
                activeTab = labels.first?.title
            }
        }
    }
    
    var horizontalScrolldDisaleGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                mainScrollDisbaled = true
            }
            .onEnded { _ in
                mainScrollDisbaled = false
            }
    }
    
    @ViewBuilder
    func pageScrollView(label: PageLabel, size: CGSize, collection: SubviewsCollection) -> some View {
        let index = labels.firstIndex(where: { $0.title == label.title }) ?? 0
        ScrollView {
            LazyVStack(spacing: .zero, pinnedViews: [.sectionHeaders]) {
                
                ZStack {
                    if activeTab == label.title {
                        header
                            .visualEffect({ content, proxy in
                                content.offset(x: -proxy.frame(in: .scrollView(axis: .horizontal)).minX )
                            })
                            .onGeometryChange(for: CGFloat.self) {
                            $0.size.height
                        } action: { oldValue, newValue in
                            headerHeight = newValue
                        }
                        .transition(.identity)
                    } else {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: headerHeight)
                            .transition(.identity)
                    }
                }
                Section(content: {
                    collection[index]
                        .frame(minHeight: size.height - 40, alignment: .top)
                }, header: {
                    ZStack {
                        if activeTab == label.title {
                            customTabbar()
                                .visualEffect({ content, proxy in
                                    content.offset(x: -proxy.frame(in:   .scrollView(axis: .horizontal)).minX )
                                })
                                .transition(.identity)
                        } else {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(height: 40)
                                .transition(.identity)
                        }
                    }
                    .simultaneousGesture(horizontalScrolldDisaleGesture)
                  
                })
            }
        }
        .onScrollGeometryChange(for: ScrollGeometry.self, of: { $0 }, action: { oldValue, newValue in
            scrollGeometories[index] = newValue
            if newValue.offsetY < 0 {
                resetScrollView(label)
            }
        })
        .scrollPosition($scrollPositions[index])
        .onScrollPhaseChange({ oldPhase, newPhase in
            let geometry = scrollGeometories[index]
            let maxOffset = min(geometry.offsetY, headerHeight)
            if newPhase == .idle && maxOffset <= headerHeight {
                updateOtherScrollViews(label, to: maxOffset)
            }
            if newPhase == .idle && mainScrollDisbaled {
                mainScrollDisbaled = false
            }
        })
        .frame(width: size.width)
        .scrollClipDisabled()
        .refreshable {
            await onRefresh()
        }
    }
    
    @ViewBuilder
    func customTabbar() -> some View {
        let progress = mainScrollGeometry.offsetX / mainScrollGeometry.containerSize.width
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 0) {
                ForEach(labels, id: \.title) { label in
                    Group {
                        if displaySymbols {
                            Image(systemName: label.symbolImage)
                        } else {
                            Text(label.title)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(activeTab == label.title ? Color.primary : .gray)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            activeTab = label.title
                        }
                    }
                }
            }
            
            Capsule()
                .frame(width: 50, height: 4)
                .containerRelativeFrame(.horizontal) { value, _ in
                    return value / CGFloat(labels.count)
                }
                .visualEffect { content, proxy in
                    content.offset(x: proxy.size.width * progress)
                }
        }
       
        .frame(height: 40)
        .background(.background)
    }
    
    func resetScrollView(_ from: PageLabel) {
        for index in labels.indices {
            let label = labels[index]
            if label.title != from.title {
                scrollPositions[index].scrollTo(y: 0)
            }
        }
    }
    
    func updateOtherScrollViews(_ from: PageLabel, to: CGFloat) {
        for index in labels.indices {
            let label = labels[index]
            let offset = scrollGeometories[index].offsetY
            let wantsUpdate = offset < headerHeight || to < headerHeight
            
            if wantsUpdate && label.title != from.title {
                scrollPositions[index].scrollTo(y: to)
            }
        }
    }
}


extension ScrollGeometry {
    init() {
        self.init(contentOffset: .zero, contentSize: .zero, contentInsets: .init(.zero), containerSize: .zero)
    }
    
    var offsetY: CGFloat {
        contentOffset.y + contentInsets.top
    }
    
    var offsetX: CGFloat {
        contentOffset.x + contentInsets.leading
    }
}
