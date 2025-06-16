//
//  Checksum.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/16.
//

import Foundation

enum Checksum {
    static var cnt = 0
    
    static func verify(_ checksum: String) async throws {
        let duration = Double.random(in: 0.5...2.5)
        try await Task.sleep(for: .seconds(duration))
    }
}
