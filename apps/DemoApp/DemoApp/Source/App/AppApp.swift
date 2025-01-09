//
//  AppApp.swift
//  App
//
//  Created by Renjun Li on 2024/7/26.
//

import SwiftUI
import SwiftData
import UIComponent
import Charts

@main
struct AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Transaction.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            DemoContentView()
        }
    }
}


struct DemoContentView: View {
    @State var items: [Int] = [1, 2, 3, 4, 5, 6, 7, 9, 91, 10, 11]
    @State var isRefreshing: Bool = false
    
    var body: some View {
        LazyVStack {
            ForEach(items, id: \.self) { index in
                HStack {
                    Text("index\(index) - \(UUID().uuidString)")
                    VStack {
                        Rectangle().fill(.red)
                            .frame(width: 50, height: 50)
                        
                        Rectangle().fill(.blue)
                            .frame(width: 50, height: 50)
                    }
                    VStack {
                        Rectangle().fill(.yellow)
                        Rectangle().fill(.purple)
                    }
                }
            }
        }
        .refreshable(isRefreshing: $isRefreshing) {
            refresh()
        }
    }
    
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
            items = [1, 2, 3, 4, 5, 6, 7, 9, 9, 10, 11].shuffled()
            self.isRefreshing = false
        })
    }
    
}

public extension View {
    @ViewBuilder
    func refreshable(threshold: CGFloat = 80,
                     isRefreshing: Binding<Bool>,
                     refreshHandler: @escaping (() -> Void)) -> some View {
        modifier(
            Refreshable(
                threshold: threshold,
                isRefreshing: isRefreshing,
                refreshHandler: refreshHandler
            )
        )
    }
}

public struct Refreshable: ViewModifier {
    private var isRefreshing: Binding<Bool>
    private let threshold: CGFloat
    private let refreshHandler: (() -> Void)?
    
    public init(threshold: CGFloat = 80,
                isRefreshing: Binding<Bool>,
                refreshHandler: (() -> Void)? = nil) {
        self.isRefreshing = isRefreshing
        self.threshold = threshold
        self.refreshHandler = refreshHandler
    }
    
    public func body(content: Content) -> some View {
        RefreshableScrollView(
            threshold: threshold,
            isRefreshing: isRefreshing,
            content: { content },
            refreshHandler: refreshHandler
        )
    }
}

private struct RefreshableScrollView<Content: View>: View {
    @State private var preOffset: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var rotation: Angle = .degrees(0)
    @Binding private var isRefreshing: Bool
    @State var isLoading: Bool = false
    @State var state: RefreshState = .idle
    private let threshold: CGFloat
    private let content: Content
    private let refreshHandler: (() -> Void)?
    
    enum RefreshState {
        case willRefresh // offset > threshold, preOffset <= threshold
        case refreshing // offset <= threshold, preOffset > threshold
        case idle
    }
    
    init(threshold: CGFloat = 80,
         isRefreshing: Binding<Bool>,
         @ViewBuilder content: () -> Content,
         refreshHandler: (() -> Void)? = nil) {
        self.threshold = threshold
        self._isRefreshing = isRefreshing
        self.content = content()
        self.refreshHandler = refreshHandler
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .top) {
                PositionView(viewType: .moving)
                content.alignmentGuide(
                    .top,
                    computeValue: { _ in
                        isLoading ? -threshold + max(0, offset) : 0
                    }
                )
                headerView
            }
        }
        .background(PositionView(viewType: .fixed))
        .onPreferenceChange(RefreshPreferenceTypes.RefreshPreferenceKey.self) { values in
            self.calculate(values)
        }
        .onChange(of: state) { newState in
            switch newState {
            case .willRefresh:
                break
            case .refreshing:
                withAnimation(.easeIn(duration: 5), completionCriteria: .removed) {
                    isLoading = true
                } completion: {
                    refreshHandler?()
                    isRefreshing = true
                }
            case .idle:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        isLoading = false
                    }
                }
            }
        }
        .onChange(of: isRefreshing) { isRefreshing in
            if !isRefreshing {
                state = .idle
            }
        }
    }
    
    var headerView: some View {
        HStack(alignment: .center) {
            Group {
                if isLoading {
                    PorscheSpinner()
                } else {
                    Spinner(degress: rotation)
                }
            }
            .offset(y: isLoading ? -max(0, offset) : -threshold)
            
        }
        .frame(height: threshold)
    }
    
    private func calculate(_ values: [RefreshPreferenceTypes.RefreshPreferenceData]) {
        DispatchQueue.main.async {
            let movingBounds = values.first(where: { $0.viewType == .moving })?.bounds ?? .zero
            let fixedBounds = values.first(where: { $0.viewType == .fixed })?.bounds ?? .zero
            offset = movingBounds.minY - fixedBounds.minY
            rotation = headerRotation(offset)
            if state == .idle, offset > threshold, preOffset <= threshold {
                state = .willRefresh
            } else if state == .willRefresh, offset <= threshold, preOffset > threshold {
                state = .refreshing
            }
            preOffset = offset
        }
    }
    
    private func headerRotation(_ offset: CGFloat) -> Angle {
        let height = Double(self.threshold)
        let distance = Double(offset)
        let value = max(min(distance - (height * 0.6), height * 0.4), 0)
        return .degrees(360 * value / (height * 0.4))
    }
}

private struct Spinner: View {
    var degress: Angle = .degrees(69)
    var size: CGFloat = 20
    
    var body: some View {
        Rectangle()
            .fill(.red)
            .frame(width: 20, height: 20)
            .frame(width: size, height: size)
            .rotationEffect(degress)
    }
}


private struct PorscheSpinner: View {
    var degress: Angle = .degrees(69)
    var size: CGFloat = 20
    @State private var isLoading = false
    
    var body: some View {
           ZStack {
               GeometryReader { geometry in
                   let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                   
                   Rectangle()
                       .fill(.yellow)
                       .frame(width: size, height: size)
                       .position(center) // 固定黄色矩形的中心
                   
                   Rectangle()
                       .fill(.blue)
                       .frame(width: size, height: size)
                       .position(center) // 固定蓝色矩形的中心
                       .rotationEffect(.degrees(isLoading ? 360 : 0), anchor: .center)
                       .animation(
                        .linear(duration: 1.2).repeatForever(autoreverses: false),
                           value: isLoading
                       )
               }
               .frame(width: size, height: size)
           }
           .onAppear { isLoading = true }
       }
}

private struct PositionView: View {
    let viewType: RefreshPreferenceTypes.ViewType
    var body: some View {
        GeometryReader { proxy in
            Color
                .clear
                .preference(key: RefreshPreferenceTypes.RefreshPreferenceKey.self,
                            value: [RefreshPreferenceTypes.RefreshPreferenceData(viewType: viewType, bounds: proxy.frame(in: .global))])
        }
    }
}

private enum RefreshPreferenceTypes {
    enum ViewType: Int {
        case fixed
        case moving
    }
    
    struct RefreshPreferenceData: Equatable {
        let viewType: ViewType
        let bounds: CGRect
    }
    
    struct RefreshPreferenceKey: PreferenceKey {
        static var defaultValue: [RefreshPreferenceData] = []
        static func reduce(value: inout [RefreshPreferenceData],
                           nextValue: () -> [RefreshPreferenceData]) {
            value.append(contentsOf: nextValue())
        }
    }
}
