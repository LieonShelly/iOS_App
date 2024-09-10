//
//  Item.swift
//  App
//
//  Created by Renjun Li on 2024/7/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
