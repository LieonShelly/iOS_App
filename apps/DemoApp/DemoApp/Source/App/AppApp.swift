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
            DemoLineView()
        }
    }
}

struct DemoLineView: View {
    enum Constants {
        static let startRounding: Double = 10
        static let spacingBetweenBars: CGFloat = 4
        static let graphHeight: CGFloat = 143
        static let gridNumberOffset: CGFloat = 24
        static let viewHeight: CGFloat = 241
        static let yNumberH: CGFloat = 20
        static let ySpacing: CGFloat = 21
        static let lineH: CGFloat = 0.5
        static let chartH = yNumberH * 4 + ySpacing * 3
    }
    
    var gridLineMax: Int = 10
    var yNumbers: [Int] {
        [
            gridLineMax,
            gridLineMax * 2 / 3,
            gridLineMax * 1 / 3,
            0
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            titleView
            graphView
        }
        .background(.yellow)
        .roundedCorner(8, corners: .allCorners)
        .padding()
    }
    
    var graphView: some View {
        HStack(spacing: .zero) {
            ZStack {
                GridLineView(
                    lineCount: yNumbers.count,
                    chartH: Constants.chartH,
                    lineH: 0.5
                )
//                .background(.red)
//                barView
            }
            yAxisTextView
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    var yAxisTextView: some View {
        YAxisTextView(chartH: Constants.chartH, numbers: yNumbers)
    }
    
    var titleView: some View {
        HStack {
            Text("title")
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            
            Text("kWh")
                //.bodySmallWithSecondary()
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20 + 10)
    }
}

struct YAxisTextView: View {
    let chartH: CGFloat
    let numbers: [Int]
    let textH: CGFloat = 20
    let maxNumberLeading: CGFloat = 8
    @State private var maxNumberRect: CGRect = .zero
    
    var body: some View {
        let sortNumbers = numbers.sorted(by: { $0 < $1 })
        let maxValue = "\(sortNumbers.last ?? 0)"
        VStack(spacing: spacing) {
            HStack {
                Text(maxValue)
                   // .bodySmallWithSecondary()
                    .currentRect($maxNumberRect)
            }
            .padding(.leading, maxNumberLeading)
            
            ForEach(sortNumbers.prefix(sortNumbers.count - 1).reversed(), id: \.self) { number in
                HStack {
                    Text("\(number)")
                        //.bodySmallWithSecondary()
                }
                .frame(height: textH)
                .frame(maxWidth: maxNumberRect.width + maxNumberLeading, alignment: .trailing)
            }
        }
        .frame(height: chartH)
    }
    
    var spacing: CGFloat {
        (chartH - textH * CGFloat(numbers.count - 1)) / CGFloat(numbers.count - 1)
    }
}

struct GridLineView: View {
    let lineCount: Int
    let chartH: CGFloat
    let lineH: CGFloat
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0 ..< lineCount, id: \.self) { _ in
                PreciseDivider(color: .gray, lineWidth: lineH)
            }
        }
        .allowsHitTesting(false)
    }
    
    var spacing: CGFloat {
        (chartH - lineH * CGFloat(lineCount - 1)) / CGFloat(lineCount - 1)
    }
}

struct PreciseDivider: View {
    var color: Color = .gray
    var lineWidth: CGFloat = 0.5 // 设置线宽
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let y = geometry.size.height / 2 // 居中绘制线条
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
            }
            .stroke(color, lineWidth: lineWidth)
        }
        .frame(height: lineWidth) // 高度设置为线宽
    }
}



extension View {
    func currentRect(_ rect: Binding<CGRect>, coordinateSpace: CoordinateSpace = .global) -> some View {
        overlay(content: {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: PositionPreferenceKey.self, value: geometry.frame(in: .global))
            }
        })
        .onPreferenceChange(PositionPreferenceKey.self) { value in
            rect.wrappedValue = value
        }
    }
}

private struct PositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}



public struct RoundedCorner: Shape {
    let radius: CGFloat
    let corners: UIRectCorner
    
    public init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }
    
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

public extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func roundedBorder(_ radius: CGFloat, corners: UIRectCorner = .allCorners, borderColor: Color, borderWidth: CGFloat) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
            .overlay { RoundedRectangle(cornerRadius: radius).stroke(borderColor, lineWidth: borderWidth) }
    }
}
