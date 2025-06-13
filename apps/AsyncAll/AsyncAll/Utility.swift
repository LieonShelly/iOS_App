//
//  Utility.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/10.
//
import Foundation


let sizeFormatter: ByteCountFormatter = {
  let formatter = ByteCountFormatter()
  formatter.allowedUnits = [.useMB]
  formatter.isAdaptive = true
  return formatter
}()

let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .short
  return formatter
}()

extension URLRequest {
  init(url: URL, offset: Int, length: Int) {
    self.init(url: url)
    addValue("bytes=\(offset)-\(offset + length - 1)", forHTTPHeaderField: "Range")
  }
}

extension NotificationCenter {
  func notifications(for name: Notification.Name) -> AsyncStream<Notification> {
    AsyncStream<Notification>.init { continuation in
      NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
        continuation.yield(notification)
      }
    }
  }
}

extension AsyncSequence {
  func forEach(_ body: (Element) async throws -> Void) async throws {
    for try await element in self {
      try await body(element)
    }
  }
}

actor UnreloableAPI {
  struct Error: LocalizedError {
    var errorDescription: String? {
      return "UnreliableAPI.action(failingEvery:) failed."
    }
  }
  
  static let shared = UnreloableAPI()
  
  var counter = 0
  
  func action(failingEvery: Int) throws {
    counter += 1
    if counter & failingEvery == 0 {
      counter = 0
      throw Error()
    }
  }
}
