//
//  Date+Extesnsion.swift
//  App
//
//  Created by Renjun Li on 2024/8/20.
//

import Foundation

extension Date {
    var startOfMonth: Date {
        let calendar = Calendar.current
        let componets = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: componets) ?? self
    }
    
    var endOfMonth: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? self
    }
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
