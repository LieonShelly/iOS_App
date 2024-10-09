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


struct CurveChartHome: View {
    
    var yAxisValues: [Double] {
        return  [0, 4, 8, 12]
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
    
    
    var body: some View {
        
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
//        VStack {
//            Chart {
//                ForEach(weight) { data in
//                    AreaMark(
//                        x: .value("Day", data.date, unit: .day),
//                        yStart: .value("WeightLow", 0),
//                        yEnd: .value("WeightLow",  data.weight)
//                    )
//                  .foregroundStyle(gradientColor)
//                }
//            }
//            .chartLegend(.hidden)
//            .chartXAxis {
//                AxisMarks { _ in
//                }
//            }
//            .chartYAxis(content: {
//                AxisMarks(preset: .inset, position: .leading, values: yAxisValues) { value in
//                    AxisValueLabel(anchor: .leading) {
//                        Text("kW")
//                            .foregroundStyle(Color.red)
//                        
//                    }
//                    
//                    
//                    AxisGridLine()
//                }
//              
//                
//                AxisMarks(preset: .inset, position: .trailing, values: yAxisValues) { value in
//                    
//                    
//                    AxisValueLabel(anchor: .bottomTrailing, horizontalSpacing: 0) {
//                        Text("\(value.as(Int.self) ?? 0)")
//                    }
//                    .foregroundStyle(.red)
//                    .offset(x: 0)
//                   
//                }
//            })
//            .frame(height: 192)
//            .background(Color.yellow.opacity(0.1))
//            .overlay(alignment: .topLeading) {
//                Text("Overlay")
//                    .padding(.top, 10)
//                    .padding(.leading, 10)
//            }
//        }
        .padding(.horizontal, 20)
        
       
      
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
