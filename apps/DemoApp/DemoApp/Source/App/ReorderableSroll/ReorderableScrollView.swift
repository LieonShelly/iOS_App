//
//  ReorderableScrollView.swift
//  App
//
//  Created by Renjun Li on 2024/9/6.
//

import SwiftUI

@available(iOS 18.0, *)
struct ReorderableScrollView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(0.5).ignoresSafeArea()
                ReorderableScrollHomeView(safeArea: proxy.safeAreaInsets)
            }
        }
       
    }
}


@available(iOS 18.0, *)
struct ReorderableScrollHomeView: View {
    var safeArea: EdgeInsets
    @State private var controls: [ReorderableControl] = [
        .init(sysmbol: "square.and.arrow.up.circle.fill", title: "Aipresadf"),
        .init(sysmbol: "square.and.arrow.up.badge.clock.fill", title: "square.and.arrow.up.badge.clock.fill"),
        .init(sysmbol: "square.and.arrow.down.on.square.fill", title: "square.and.arrow.down.on.square.fill"),
        .init(sysmbol: "arrowshape.backward.circle.fill", title: "arrowshape.backward.circle.fill"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "gauge.with.dots.needle.50percent"),
        .init(sysmbol: "fan.badge.automatic", title: "fan.badge.automatic"),
        .init(sysmbol: "key.radiowaves.forward.fill", title: "key.radiowaves.forward.fill"),
        .init(sysmbol: "car", title: "car"),
        .init(sysmbol: "bolt.car.circle", title: "bolt.car.circle"),
        .init(sysmbol: "parkingsign.radiowaves.left.and.right", title: "parkingsign.radiowaves.left.and.right"),
        .init(sysmbol: "arrowshape.backward.circle.fill", title: "arrowshape.backward.circle.fill1"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "3"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "4"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "5"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "6"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "7"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "8"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "9"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "10"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "11"),
        .init(sysmbol: "gauge.with.dots.needle.50percent", title: "12"),
    ]
    @State private var selectedControl: ReorderableControl?
    @State private var selectedControlScale: CGFloat = 1.0
    @State private var selectedControlFrame: CGRect = .zero
    @State private var hapticsTrigger: Bool = false
    @State private var offset: CGSize = .zero
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var currentScrollOffset: CGFloat = .zero
    @State private var lastActiveScrollOffset: CGFloat = .zero
    @State private var topRegion: CGRect = .zero
    @State private var bottomRegion: CGRect = .zero
    @State private var scrollTimer: Timer?
    @State private var maxScrollSize: CGFloat = .zero
    
    var body: some View {
        ScrollView(.vertical) {
            // LazyVStack
            LazyVGrid(columns: Array(repeating: GridItem(), count: 1), spacing: 20) {
                ForEach($controls) { $control in
                    ReorderableScrollContentView(control: control)
                        .opacity(selectedControl?.id == control.id ? 0 : 1)
                        .onGeometryChange(for: CGRect.self) {
                            $0.frame(in: .global)
                        } action: { newValue in
                            if selectedControl?.id == control.id {
                                selectedControlFrame = newValue
                            }
                            control.frame = newValue
                        }
                        .gesture(customCombinedGesture(control))
                }
            }
            .padding(25)
        }
        .scrollPosition($scrollPosition)
        .onScrollGeometryChange(for: CGFloat.self, of: { proxy in
            proxy.contentOffset.y + proxy.contentInsets.top
        }, action: { oldValue, newValue in
            currentScrollOffset = newValue
        })
        .onScrollGeometryChange(for: CGFloat.self, of: { proxy in
            proxy.contentSize.height - proxy.containerSize.height
        }, action: { oldValue, newValue in
            maxScrollSize = newValue
        })
        .overlay(alignment: .topLeading) {
            if let selectedControl {
                ReorderableScrollContentView(control: selectedControl)
                    .frame(width: selectedControl.frame.width, height: selectedControl.frame.height)
                    .scaleEffect(selectedControlScale)
                    .offset(x: selectedControl.frame.minX, y: selectedControl.frame.minY)
                    .offset(offset)
                    .ignoresSafeArea()
                    .transition(.identity)
            }
        }
        .overlay(alignment: .top, content: {
            Rectangle()
                .fill(.clear)
                .frame(height: 20 + safeArea.top)
                .onGeometryChange(for: CGRect.self, of: {
                    $0.frame(in: .global)
                }) { newValue in
                    topRegion = newValue
                }
                .offset(y: -safeArea.top)
                .allowsTightening(false)
        })
        .overlay(alignment: .bottom, content: {
            Rectangle()
                .fill(.clear)
                .frame(height: 20 + safeArea.bottom)
                .onGeometryChange(for: CGRect.self, of: {
                    $0.frame(in: .global)
                }) { newValue in
                    bottomRegion = newValue
                }
                .offset(y: safeArea.bottom)
                .allowsTightening(false)
        })
        .allowsTightening(selectedControl == nil)
        .sensoryFeedback(.impact, trigger: hapticsTrigger)
    }
    
    func customCombinedGesture(_ control: ReorderableControl) -> some Gesture {
        LongPressGesture(minimumDuration: 0.25)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
            .onChanged { value in
                switch value {
                case .second(let status, let value):
                    if status {
                        if selectedControl == nil {
                            selectedControl = control
                            selectedControlFrame = control.frame
                            lastActiveScrollOffset = currentScrollOffset
                            hapticsTrigger.toggle()
                            withAnimation(.smooth) {
                                selectedControlScale = 1.05
                            }
                        }
                        if let value {
                            offset = value.translation
                            let location = value.location
                            checkAndScroll(location)
                        }
                    }
                default: break
                }
            }
            .onEnded { _ in
                scrollTimer?.invalidate()
                withAnimation(.snappy(duration: 0.25, extraBounce: 0), completionCriteria: .logicallyComplete) {
                    selectedControl?.frame = selectedControlFrame
                    selectedControlScale = 1.0
                    offset = .zero
                } completion: {
                    selectedControl = nil
                    scrollTimer = nil
                    lastActiveScrollOffset = 0
                }

            }
    }
    
    private func checkAndSwapeItem(_ location: CGPoint) {
        if let currentIndex = controls.firstIndex(where: { $0.id == selectedControl?.id }),
           let fallingIndex = controls.firstIndex(where: { $0.frame.contains(location )}) {
            withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                (controls[currentIndex], controls[fallingIndex]) = (controls[fallingIndex], controls[currentIndex])
            }
        }
    }
    
    private func checkAndScroll(_ location: CGPoint) {
        let topStatus = topRegion.contains(location)
        let bottomStatus = bottomRegion.contains(location)
        if topStatus || bottomStatus {
            guard scrollTimer == nil else {
                return
            }
            
            scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                if topStatus {
                    lastActiveScrollOffset = max(lastActiveScrollOffset - 10, 0)
                } else {
                    lastActiveScrollOffset = min(lastActiveScrollOffset + 10, maxScrollSize)
                }
                scrollPosition.scrollTo(y: lastActiveScrollOffset)
                checkAndSwapeItem(location)
            })
        } else {
            scrollTimer?.invalidate()
            scrollTimer = nil
            checkAndSwapeItem(location)
        }
    }
}

struct ReorderableScrollContentView: View {
    let control: ReorderableControl
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: control.sysmbol)
                .font(.title)
            
            Text(control.title)
            
            Spacer()
        }
        .padding(.horizontal, 15)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        }
    }
}

struct ReorderableControl: Identifiable {
    let id: UUID = UUID()
    let sysmbol: String
    let title: String
    var frame: CGRect = .zero
}

@available(iOS 18.0, *)
#Preview {
    ReorderableScrollView()
}
