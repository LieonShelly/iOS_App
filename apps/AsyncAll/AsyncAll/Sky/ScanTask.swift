//
//  ScanTask.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/13.
//

import Foundation

struct ScanTask: Identifiable {
    let id: UUID
    let input: Int
    
    init(id: UUID = UUID(), input: Int) {
        self.id = id
        self.input = input
    }
    
    func run() async throws -> String {
        try await UnreloableAPI.shared.action(failingEvery: 10)
        await Task(priority: .medium) {
            await withUnsafeContinuation { continuation in
                Thread.sleep(forTimeInterval: 1)
                continuation.resume()
            }
        }.value
        
        return "\(input)"
    }
}
