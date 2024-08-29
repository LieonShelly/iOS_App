//
//  ScrollableTabr.swift
//  App
//
//  Created by Renjun Li on 2024/8/29.
//

import SwiftUI

struct ScrollableTabr: View {
    @State private var tabs: [TabModel] = [
        .init(id: TabModel.Tab.research),
        .init(id: TabModel.Tab.depolyment),
        .init(id: TabModel.Tab.analytics),
        .init(id: TabModel.Tab.audience),
        .init(id: TabModel.Tab.privacy),
    ]
    @State private var activeTab: TabModel.Tab = TabModel.Tab.research
    @State private var tabBarScrollState: TabModel.Tab?
    @State private var mainScrollState: TabModel.Tab?
    @State private var progress: CGFloat = .zero
    
    var body: some View {
        VStack {
            customeTabbar()
            contentView()
        }
    }
    
    func customeTabbar() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach($tabs) { $tab in
                    Button(action: {
                        withAnimation(.snappy) {
                            activeTab = tab.id
                            mainScrollState = tab.id
                            tabBarScrollState = tab.id
                        }
                    }) {
                        Text(tab.id.rawValue)
                            .padding(.vertical, 12)
                            .foregroundStyle(activeTab == tab.id ? Color.primary : Color.gray)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .rect { rect in
                        tab.size = rect.size
                        tab.minX = rect.minX
                    }
                }
            }
        }
        .scrollPosition(id: .init(get: {
            return tabBarScrollState
        }, set: { _, _ in
            
        }))
        .overlay(alignment: .bottom, content: {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 1)
                
                let inputRange = tabs.indices.compactMap { return CGFloat($0) }
                let outputRange = tabs.compactMap { return $0.size.width }
                let outputPositionRange = tabs.compactMap { return $0.minX }
                let indicatorWidth = progress.interpotate(inputRange: inputRange, outputRange: outputRange)
                let indicatorPosition = progress.interpotate(inputRange: inputRange, outputRange: outputPositionRange)
                
                Rectangle()
                    .fill(.primary)
                    .frame(width: indicatorWidth, height: 1.5)
                    .offset(x: indicatorPosition)
            }
        })
        .safeAreaPadding(.horizontal, 15)
        .scrollIndicators(.hidden)
    }
    
    func contentView() -> some View {
        GeometryReader {
            let size = $0.size
            ScrollView(.horizontal) {
                LazyHStack(spacing: .zero) {
                    ForEach(tabs) { tab in
                        Text(tab.id.rawValue)
                            .frame(width: size.width, height: size.height)
                            .contentShape(.rect)
                    }
                }
                .scrollTargetLayout()
                .rect { rect in
                    progress = -rect.minX / size.width
                }
            }
            .scrollPosition(id: $mainScrollState)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .onChange(of: mainScrollState) { oldValue, newValue in
                if let newValue {
                    withAnimation(.snappy) {
                        tabBarScrollState = newValue
                        activeTab = newValue
                    }
                }
            }
        }
    }
}


#Preview {
    ScrollableTabr()
}


struct TabModel: Identifiable {
    private(set) var id: Tab
    var size: CGSize = .zero
    var minX: CGFloat = .zero
    
    enum Tab: String, CaseIterable {
        case research = "research"
        case depolyment = "depolyment"
        case analytics = "analytics"
        case audience = "audience"
        case privacy = "privacy"
    }
}


struct RectKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    
    @ViewBuilder
    func rect(completion: @escaping (CGRect) -> ()) -> some View {
        self.overlay {
            GeometryReader {
                let rect = $0.frame(in: .scrollView(axis: .horizontal))
                Color.clear
                    .preference(key: RectKey.self, value: rect)
                    .onPreferenceChange(RectKey.self, perform: completion)
            }
        }
    }
}

extension CGFloat {
    func interpotate(inputRange: [CGFloat], outputRange: [CGFloat]) -> CGFloat {
        let x = self
        let length = inputRange.count - 1
        if x <= inputRange[0] {
            return outputRange[0]
        }
        for index in 1 ... length {
            let x1 = inputRange[index - 1]
            let x2 = inputRange[index]
            
            let y1 = outputRange[index - 1]
            let y2 = outputRange[index]
            
            if x <= inputRange[index] {
                let y = y1 + (y2 - y1) / (x2 - x1) * (x - x1)
                return y
            }
        }
        return outputRange[length]
    }
}
