//
//  LittleJohnModel.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/9.
//

import SwiftUI

@MainActor
class LittleJohnModel: ObservableObject {
    @Published private(set) var tickerSymbols: [Stock] = []
    
    func startTicker(_ selectedSymbols: [String]) async throws {
        guard let url = URL(string: "http://localhost:8080/littlejohn/ticker?\(selectedSymbols.joined(separator: ","))") else {
          throw "The URL could not be created."
        }
        let (stream, response) = try await liveURLSession.bytes(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw "The server responded with an error"
        }
        for try await line in stream.lines {
            let sortedSymbols = try JSONDecoder()
                .decode([Stock].self, from: Data(line.utf8))
                .sorted(by: {$0.name < $1.name})
            tickerSymbols = sortedSymbols
            print("updated:\(Date())")
        }
        tickerSymbols = []
    }
    
    func availableSymbols() async throws -> [String] {
        guard let url = URL(string: "http://localhost:8080/littlejohn/symbols") else {
            throw "The url could not be created"
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw "The server responded woth an error"
        }
        return try JSONDecoder().decode([String].self, from: data)
    }
    
    private lazy var liveURLSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = .infinity
        return URLSession(configuration: configuration)
    }()
}

extension String: Error {}


struct Stock: Hashable, Codable {
  let name: String
  let value: Double
}
