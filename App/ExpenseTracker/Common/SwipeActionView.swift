//
//  SwiftActionView.swift
//  App
//
//  Created by Renjun Li on 2024/8/25.
//

import SwiftUI

struct SwipeActionView<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var isEnable: Bool = true
    @State private var scrollOffset: CGFloat = .zero
    @Environment(\.colorScheme) private var scheme
    @ActionBuilder private var actions: [SwipeAction]
    private var cornorRadius: CGFloat = 0
    private var direction: SwipeDirection = .trailing
    private var viewId: UUID = .init()
    
    init(
        cornorRadius: CGFloat, 
        direction: SwipeDirection, 
        @ViewBuilder content: () -> (Content), 
        @ActionBuilder actions: () -> [SwipeAction]
    ) {
        self.cornorRadius = cornorRadius
        self.direction = direction
        self.content = content()
        self.actions = actions()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: .zero) {
                    content
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0))
                        .containerRelativeFrame(.horizontal)
                        .background(scheme == .dark ? .black : .white)
                        .background {
                            if let firstAction = actions.first {
                                Rectangle()
                                    .fill(firstAction.tint)
                                    .opacity(scrollOffset == .zero ? 0 : 1)
                            }
                        }
                        .id(viewId)
                        .transition(.identity)
                        .overlay {
                            GeometryReader {
                                let minX = $0.frame(in: .scrollView(axis: .horizontal)).minX
                                Color.clear
                                    .preference(key: OffsetKey.self, value: minX)
                                    .onPreferenceChange(OffsetKey.self, perform: {
                                        scrollOffset = $0
                                    })
                            }
                        }
                    
                    actionsButtons {
                        withAnimation(.snappy) {
                            proxy.scrollTo(viewId, anchor: direction == .trailing ? .topLeading : .topTrailing)
                        }
                    }
                    .opacity(scrollOffset == .zero ? 0 : 1)
                }
                .scrollTargetLayout()
                .visualEffect { content, proxy in
                    content.offset(x: scrollOffset(proxy))
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .background {
                if let lastAction = actions.last {
                    Rectangle()
                        .fill(lastAction.tint)
                        .opacity(scrollOffset == .zero ? 0 : 1)
                }
            }
            .clipShape(.rect(cornerRadius: cornorRadius))
            .rotationEffect(.init(degrees: direction == .leading ? 180 : 0))
        }
        .allowsHitTesting(isEnable)
        .transition(CustomTransition())
    }
    
    func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return  (minX > 0 ? -minX : 0)
    }
    
    @ViewBuilder
    func actionsButtons(_  resetPosition: @escaping () -> ()) -> some View {
        Rectangle()
            .fill(.red)
            .frame(width: CGFloat(actions.count) * 100)
            .overlay(alignment: direction.aligment) {
                HStack(spacing: .zero) {
                    ForEach(actions) { button in
                        Button(action: {
                            Task {
                                isEnable = false
                                resetPosition()
                                try? await Task.sleep(for: .seconds(0.25))
                                button.action()
                                isEnable = false
                            }
                           
                        }) {
                            Image(systemName: button.icon)
                                .font(button.iconFont)
                                .foregroundStyle(button.iconTint)
                                .frame(width: 100)
                                .frame(maxHeight: .infinity)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .background(button.tint)
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0))
                    }
                }
            }
    }
    
 
    @resultBuilder
    struct ActionBuilder {
        static func buildBlock(_ components: SwipeAction...) -> [SwipeAction] {
            components
        }
    }
    
    enum SwipeDirection {
        case leading
        case trailing
        
        var aligment: Alignment {
            switch self {
            case .leading:
                    .leading
            case .trailing:
                    .trailing
            }
        }
    }
    
    struct OffsetKey: PreferenceKey {
        static var defaultValue: CGFloat { .zero }
        
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}


struct SwipeAction: Identifiable {
    private(set) var id: UUID = .init()
    var tint: Color
    var icon: String
    var iconFont: Font = .title
    var iconTint: Color = .white
    var isEnabled: Bool = true
    var action: () -> ()
}

struct CustomTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content.mask {
            GeometryReader {
                let size = $0.size
                Rectangle()
                    .offset(y: phase == .identity ? 0 : -size.height)
            }
            .containerRelativeFrame(.horizontal)
        }
    }
}
