//
//  CurveChart.swift
//  UIComponent
//
//  Created by Renjun Li on 2024/9/30.
//

import Charts
import SwiftUI

// Data Model
struct TestWeight: Identifiable {
    var id = UUID()
    var weight: Double
    var date: Date

    init(id: UUID = UUID(), weight: Double, day: Int) {
        self.id = id
        self.weight = weight
        let calendar = Calendar.current
        self.date = calendar.date(from: DateComponents(year: 2023, month: 10, day: day))!
    }
}

// Test data
var weight: [TestWeight] = [
    TestWeight(weight: 2, day: 2),
    TestWeight(weight: 3, day: 3),
    TestWeight(weight: 4, day: 4),
    TestWeight(weight: 6, day: 5),
    TestWeight(weight: 2, day: 6),
    TestWeight(weight: 8, day: 7),
    TestWeight(weight: 11, day: 8)
]


public struct CurveChartHome: View {
    
    
    var yAxisValues: [Double] {
        return  [0, 8, 16, 24]
    }
    
    var gradientColor: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.pink.opacity(0.8),
                    Color.pink.opacity(0.01),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    public init() { }
    
    var chart: some View {
        VStack {
            Chart {
                ForEach(weight) { data in
                    AreaMark(
                        x: .value("Day", data.date, unit: .day),
                        yStart: .value("WeightLow", 0),
                        yEnd: .value("WeightLow",  data.weight)
                    )
                  .foregroundStyle(gradientColor)
                }
            }
            .chartLegend(.hidden)
            .chartXAxis {
                AxisMarks { _ in
                }
            }
            .chartYAxis(content: {
                AxisMarks(preset: .inset, position: .trailing, values: yAxisValues) { value in
                    AxisGridLine(
                        centered: true,
                        stroke: StrokeStyle(
                            lineWidth: 1,
                            lineCap: .square
                        )
                    )
                   
                }
            })
            .frame(height: 300)
            .background(Color.yellow)
            
            Text("Text").padding(.top, 50)
        }
        
        .frame(height: 300 + 50 + 20)
      
    }
    
    var chartGrid: some View {
        ZStack(alignment: .center) {
            chart
            GridLineView(lineCount: yAxisValues.count, chartH: 300, lineH: 2)
        }
    }
    
    public var body: some View {
        HStack {
            chartGrid
            YAxisTextView(
                chartH: 300, numbers: yAxisValues.map { Int($0) })
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
    
    @State private var maxTextWith: CGRect = CGRect(x: 0, y: 0, width: 24, height: 0)
    
    var lineView: some View {
        
        VStack(spacing: 40) {
            HStack {
                Rectangle()
                    .fill(Color.green)
                    .frame(height: 0.5)
                Spacer()
                    .frame(width: 8)
                Text("1000")
                    .currentRect($maxTextWith)
                
            }
            
            HStack {
                Rectangle()
                    .fill(Color.green)
                    .frame(height: 0.5)
                Spacer()
                    .frame(width: 8)
                Text("asdfasd")
                
            }
        }
       
    }
    
    func roundUpToNextMultipleOf3(value: Double) -> Double {
        let rounded = ceil(value)
        let remainder = rounded.truncatingRemainder(dividingBy: 3)
        
        return if remainder == 0.0 {
            rounded
        } else {
            rounded + (3 - remainder)
        }
    }
    
    var barChart: some View {
        
        LazyHStack(alignment: .bottom, spacing: 20) {
            GeometryReader { proxy in
                VStack(spacing: 12) {
                    BarChartCellV3(value: 100, width: 20, color: .red)
                        .frame(height: 100)
                    Text("1")
                }
            }
            
            GeometryReader { proxy in
                VStack(spacing: 12) {
                    BarChartCellV3(value: 50, width: 20, color: .red)
                        .frame(height: 100)
                    Text("1")
                }
            }
            
            GeometryReader { proxy in
                VStack(spacing: 12) {
                    BarChartCellV3(value: 80, width: 20, color: .red)
                        .frame(height: 100)
                    Text("1")
                }
            }
           
           
        }
    }
}

#Preview {
    CurveChartHome()
}


public struct BarChartCellV3: View {
    var value: Double
    var index: Int = 0
    var width: CGFloat
    var color: Color
     
    public var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(color)
                .frame(width: width, height: value)
                .clipShape(.rect(
                    topLeadingRadius: width / 2,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: width / 2
                ))
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
       
    }
}


private struct PositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    func currentRect(_ rect: Binding<CGRect>, coordinateSpace: CoordinateSpace = .global) -> some View {
        self.background(GeometryReader { geo in
            Color.clear
                .preference(key: PositionPreferenceKey.self, value: geo.frame(in: coordinateSpace))
        })
        .onPreferenceChange(PositionPreferenceKey.self) { value in
            rect.wrappedValue = value
        }
    }
}


struct YAxisTextView: View {
    let chartH: CGFloat
    let numbers: [Int]
    let textH: CGFloat = 20
    let maxNumberLeading: CGFloat = 8
    @State private var maxNumberRect: CGRect = .zero
    
    var body: some View {
        let sortNumbers = numbers.sorted(by: { $0 < $1})
        let maxValue = "\(sortNumbers.last ?? 0)"
        VStack(spacing: spacing) {
            HStack {
                Text(maxValue)
                    .foregroundStyle(Color.gray)
                    .currentRect($maxNumberRect)
            }
            .padding(.leading, maxNumberLeading)
            
            
            ForEach(sortNumbers.prefix(sortNumbers.count - 1).reversed(), id: \.self) { number in
                HStack {
                    Text("\(number)")
                        .foregroundStyle(Color.red)
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
                HStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: lineH)
                }
                .frame(height: lineH)
            }
        }
    }

    var spacing: CGFloat {
        (chartH - lineH * CGFloat(lineCount - 1)) / CGFloat(lineCount - 1)
    }
}
