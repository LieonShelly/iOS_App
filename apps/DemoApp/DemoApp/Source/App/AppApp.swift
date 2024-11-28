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

struct MonthlyHoursOfSunshine: Identifiable {
    var city: String
    var date: Date
    var hoursOfSunshine: Double
    
    var id: String = UUID().uuidString


    init(city: String, month: Int, hoursOfSunshine: Double) {
        let calendar = Calendar.autoupdatingCurrent
        self.city = city
        self.date = calendar.date(from: DateComponents(year: 2020, month: month))!
        self.hoursOfSunshine = hoursOfSunshine
    }
}


struct DemoContentView: View {
    
    let data: [MonthlyHoursOfSunshine] = [
        MonthlyHoursOfSunshine(city: "Seattle", month: 1, hoursOfSunshine: 7.3),

        MonthlyHoursOfSunshine(city: "Seattle", month: 1, hoursOfSunshine: 2),
       
        MonthlyHoursOfSunshine(city: "Seattle", month: 2, hoursOfSunshine: 7.3),
        // ...
//        MonthlyHoursOfSunshine(city: "Seattle", month: 3, hoursOfSunshine: 7.1),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 4, hoursOfSunshine: 7.1),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 5, hoursOfSunshine: 7.1),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 6, hoursOfSunshine: 7.1),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 7, hoursOfSunshine: 7.1),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 8, hoursOfSunshine: 7.1),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 9, hoursOfSunshine: 7.3),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 10, hoursOfSunshine: 7.3),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 11, hoursOfSunshine: 7.3),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 12, hoursOfSunshine: 7.3),
        MonthlyHoursOfSunshine(city: "Seattle", month: 17, hoursOfSunshine: 7.2),
        MonthlyHoursOfSunshine(city: "Seattle", month: 13, hoursOfSunshine: 2),
        MonthlyHoursOfSunshine(city: "Seattle", month: 14, hoursOfSunshine: 7.3),
        MonthlyHoursOfSunshine(city: "Seattle", month: 15, hoursOfSunshine: 7.3),
        MonthlyHoursOfSunshine(city: "Seattle", month: 16, hoursOfSunshine: 7.2),
        MonthlyHoursOfSunshine(city: "Seattle", month: 17, hoursOfSunshine: 7.2),
        MonthlyHoursOfSunshine(city: "Seattle", month: 18, hoursOfSunshine: 7.2),
        MonthlyHoursOfSunshine(city: "Seattle", month: 19, hoursOfSunshine: 7.2),
        MonthlyHoursOfSunshine(city: "Seattle", month: 20, hoursOfSunshine: 7.2),
        
//        MonthlyHoursOfSunshine(city: "Seattle", month: 21, hoursOfSunshine: 7.1),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 22, hoursOfSunshine: 7.1),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 23, hoursOfSunshine: 7.1),
        
        MonthlyHoursOfSunshine(city: "Seattle", month: 24, hoursOfSunshine: 0),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 25, hoursOfSunshine: 0),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 26, hoursOfSunshine: 0),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 27, hoursOfSunshine: 0),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 28, hoursOfSunshine: 0),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 29, hoursOfSunshine: 0),
//        MonthlyHoursOfSunshine(city: "Seattle", month: 30, hoursOfSunshine: 0),
        MonthlyHoursOfSunshine(city: "Seattle", month: 31, hoursOfSunshine: 0),
        MonthlyHoursOfSunshine(city: "Seattle", month: 32, hoursOfSunshine: 5),
    ]
    
    var fittingDomain: ClosedRange<Double> {
        var maxValue = (data.map { $0.hoursOfSunshine }.max() ?? 0) * 1.25
        maxValue = roundUpToNextMultipleOf3(value: maxValue)
        maxValue = maxValue > 3 ? maxValue : 3

        return 0 ... maxValue
    }
    
    var yAxisValues: [Double] {
        var array: [Double] = []
        var maxValue = (data.map { $0.hoursOfSunshine }.max() ?? 1) * 1.25
        
        maxValue = roundUpToNextMultipleOf3(value: maxValue)
        
        if maxValue > 3 {
            array.append(maxValue)
            array.append(maxValue / 3 * 2)
            array.append(maxValue / 3)
      
            array.append(0)
       
          
          
        } else {
            array = [0, 1, 2, 3]
        }
        
        return array
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
    
    var body: some View {
        Chart(data) {
            AreaMark(x: .value("Index", index($0)),
                     y: .value("Value", $0.hoursOfSunshine))
            .interpolationMethod(.monotone)
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [
                    Color.red.opacity(0.8),
                    Color.red.opacity(0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom))
            
            LineMark(
                x: .value("Index", index($0)),
                y: .value("Hours of Sunshine", $0.hoursOfSunshine)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(by: .value("City", $0.city))
        }
        .chartYScale(domain: fittingDomain)
        .chartXAxis(content: {
            AxisMarks { _ in
            }
        })
        .chartYAxis(content: {
            AxisMarks(preset: .inset, position: .trailing, values: yAxisValues) { _ in
                AxisGridLine(
                    centered: true,
                    stroke: StrokeStyle(
                        lineWidth: 0.5,
                        lineCap: .square
                    )
                )
                .foregroundStyle(.red)
            }
        })
        
        .frame(height: 300)
        .padding(.horizontal, 20)
        .onAppear {
            
            let uniqueMeasurementPoints = measurementPoints.removingDuplicatesByTimestamp()
            print(uniqueMeasurementPoints)

        }
    }
    
    func index(_ data: MonthlyHoursOfSunshine) -> Int {
        return self.data.firstIndex(where: { $0.id == data.id}) ?? 0
    }
}

public struct AggregatedPowerCurveV2DTO: Codable, Equatable {
    let sessionId: Int
    let startTimeStamp: String
    let endTimeStamp: String
    let measurementPoints: [MeasurementPoint]
}

// MARK: - MeasurementPoint
public struct MeasurementPoint: Codable, Equatable {
    let timestamp: String
    let energyGrid: TotalEnergy
    let energySolar: TotalEnergy
    let energy: TotalEnergy
    let energyCost: TotalEnergy
}

// MARK: - TotalEnergy
public struct TotalEnergy: Codable, Equatable {
    let value: Double
    let zero: Bool
}


extension Array where Element == MeasurementPoint {
    func removingDuplicatesByTimestamp() -> [MeasurementPoint] {
        var seenTimestamps = Set<String>()
        return self.filter { measurementPoint in
            if seenTimestamps.contains(measurementPoint.timestamp) {
                return false
            } else {
                seenTimestamps.insert(measurementPoint.timestamp)
                return true
            }
        }
    }
}

// 使用示例
var measurementPoints: [MeasurementPoint] = [
    MeasurementPoint(timestamp: "2024-11-22T10:00:00", energyGrid: TotalEnergy(value: 10, zero: false), energySolar: TotalEnergy(value: 20, zero: false), energy: TotalEnergy(value: 30, zero: false), energyCost: TotalEnergy(value: 5, zero: false)),
    MeasurementPoint(timestamp: "2024-11-22T13:00:00", energyGrid: TotalEnergy(value: 15, zero: false), energySolar: TotalEnergy(value: 25, zero: false), energy: TotalEnergy(value: 35, zero: false), energyCost: TotalEnergy(value: 10, zero: false)),
    MeasurementPoint(timestamp: "2024-11-22T11:00:00", energyGrid: TotalEnergy(value: 12, zero: false), energySolar: TotalEnergy(value: 22, zero: false), energy: TotalEnergy(value: 32, zero: false), energyCost: TotalEnergy(value: 7, zero: false))
]
