//
//  ScanModel.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/13.
//

import Foundation

class ScanModel: ObservableObject {
    private var counted = 0
    private var started = Date()
    
    @MainActor @Published var scheduled = 0
    @MainActor @Published var countPerSecond: Double = 0
    @MainActor @Published var completed = 0
    @Published var total: Int
    @MainActor @Published var isCollaborating = false
    
    init(total: Int, localName: String) {
        self.total = total
    }
    
    func runAllTasks() async throws {
        started = Date()
        
        try await withThrowingTaskGroup(of: Result<String, Error>.self) { [unowned self] group in
            let batchSize = 4
            
            for index in 0..<batchSize {
                group.addTask {
                    await self.worker(number: index)
                }
            }
            
            // 1
            var index = batchSize
            
            // 2
            for try await result in group {
                switch result {
                case .success(let result):
                    print("Completed:\(result)")
                case .failure(let error):
                    print("Failed: \(error.localizedDescription)")
                }
                
                // 3
                if index < total {
                    group.addTask { [index] in
                        await self.worker(number: index)
                    }
                    index += 1
                }
            }
            
            await MainActor.run {
                completed = 0
                countPerSecond = 0
                scheduled = 0
            }
        }
    }
    
    func worker(number: Int) async -> Result<String, Error> {
        await onScheduled()
        
        let task = ScanTask(input: number)
        let result: Result<String, Error>
        do {
            result = try .success(await task.run())
        } catch {
            result = .failure(error)
        }
        
        await onTaskCompleted()
        return result
    }
    
}

extension ScanModel {
    @MainActor
    private func onTaskCompleted() {
        completed += 1
        counted += 1
        scheduled -= 1
        
        countPerSecond = Double(counted) / Date().timeIntervalSince(started)
    }
    
    @MainActor
    private func onScheduled() {
        scheduled += 1
    }
}
