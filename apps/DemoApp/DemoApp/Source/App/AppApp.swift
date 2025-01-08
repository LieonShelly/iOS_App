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
    @State var items: [Int] = [1, 2, 3, 4, 5, 6, 7, 9, 9, 10, 11]
    @State var isRefreshing: Bool = false
    
    var body: some View {
        LazyVStack {
            ForEach(items, id: \.self) { index in
                HStack {
                    Text("index\(index)")
                }
                .frame(height: 40)
            }
        }
        .refreshable(isRefreshing: $isRefreshing) {
            refresh()
        }
    }
    
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
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
    @State var state: RefreshState = .idle
    @State var rectH: CGFloat = 0
    private let threshold: CGFloat
    private let content: Content
    private let refreshHandler: (() -> Void)?
    @State private var scrollOffset: CGFloat = 0
    @State private var contentOffset: CGFloat = 0
    @State private var isEligable: Bool = false
    @State private var progress: CGFloat = 0
    
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
                VStack(spacing: .zero) {
                    Rectangle()
                        .fill(.red)
                        .frame(height: rectH)
                        .overlay(content: {
                            Rectangle()
                                .fill(.black)
                                .frame(width: 20, height: 20)
                                .rotationEffect(rotation)
                        })
                       
                        .offset(y: isEligable ? -contentOffset : -scrollOffset )
                    content
                }
            }
        }
        .background(PositionView(viewType: .fixed))
        .onPreferenceChange(RefreshPreferenceTypes.RefreshPreferenceKey.self) { values in
            self.calculate(values)
        }
        .onChange(of: state) { newState in
            switch newState {
            case .refreshing:
                refreshHandler?()
                isRefreshing = true
                rectH = threshold
                
            case .idle:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        rectH = 0
                        progress = 0
                    }
                }
            default: break
            }
        }
        .onChange(of: isRefreshing) { isRefreshing in
            if !isRefreshing {
                state = .idle
            }
        }
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
            contentOffset = offset
           
            if !isEligable {
                scrollOffset = offset
            }
            switch state {
            case .willRefresh:
                rectH = threshold
            case .refreshing:
                rectH = threshold
                isEligable = offset > threshold
            case .idle:
                progress = headerProgress(offset)
                rectH = progress * threshold
            }
            preOffset = offset
            print("calculate-rectH:\(rectH) - offset:\(offset) -state:\(state)")
        }
    }
    
    private func headerRotation(_ offset: CGFloat) -> Angle {
        let height = Double(self.threshold)
        let distance = Double(offset)
        let value = max(min(distance - (height * 0.6), height * 0.4), 0)
        return .degrees(360 * value / (height * 0.4))
    }
    
    private func headerProgress(_ offset: CGFloat) -> CGFloat {
        let height = Double(self.threshold)
        let distance = Double(offset)
        let value = max(min(distance - (height * 0.6), height * 0.4), 0)
        return value / (height * 0.4)
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

