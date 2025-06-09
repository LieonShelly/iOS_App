/// Copyright (c) 2023 Kodeco Inc.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CoreLocation
import Combine
import UIKit

/// The app model that communicates with the server.
@MainActor
class BlabberModel: ObservableObject {
  var username = ""
  var urlSession = URLSession.shared
  private let manager = CLLocationManager()
  private var delegate: ChatLocationDelegate?
  var sleep: (Int) async throws -> Void = {
    try await Task.sleep(for: .seconds($0))
  }
  
  nonisolated init() {
  }

  /// Current live updates
  @Published var messages: [Message] = []

  /// Shares the current user's address in chat.
  func shareLocation() async throws {
    let location: CLLocation = try await withCheckedThrowingContinuation { [weak self] continuation in
      self?.delegate = ChatLocationDelegate(manager: manager, continuation: continuation)
      if manager.authorizationStatus == .authorizedWhenInUse {
        manager.startUpdatingLocation()
      }
    }
    print(location.description)
    manager.stopUpdatingLocation()
    delegate = nil
    let address: String = try await
    withCheckedThrowingContinuation { continuation in
      AddressEncoder.addressFor(location: location) { address, error in
        switch (address, error) {
        case (nil, let error?):
          continuation.resume(throwing: error)
        case (let address?, nil):
          continuation.resume(returning: address)
        case (nil, nil):
          continuation.resume(throwing: "Address encoding failed")
        case let (address?, error?):
          continuation.resume(returning: address)
          print(error)
        }
      }
    }
    try await say("📍 \(address)")
  }

  /// Does a countdown and sends the message.
  func countdown(to message: String) async throws {
    let sleep = self.sleep
    guard !message.isEmpty else { return }
    var countDown = 3
    let counter = AsyncStream<String> {
      guard countDown >= 0 else { return nil}
      do {
        try await sleep(1)
      } catch {
        return nil
      }
      defer { countDown -= 1}
      if countDown == 0 {
        return "🎉 " + message
      } else {
        return "\(countDown)..."
      }
    }
    for try await element in counter {
      try await say(element)
    }
  }

  /// Start live chat updates
  func chat() async throws {
    guard
      let query = username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
      let url = URL(string: "http://localhost:8080/chat/room?\(query)")
      else {
      throw "Invalid username"
    }

    let (stream, response) = try await liveURLSession.bytes(from: url, delegate: nil)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error."
    }

    print("Start live updates")

    try await withTaskCancellationHandler(operation: {
      try await readMessages(stream: stream)
    }, onCancel: {
      print("End live updates")
      Task { @MainActor in
        messages = []
      }
    })
  }

  /// Reads the server chat stream and updates the data model.
  private func readMessages(stream: URLSession.AsyncBytes) async throws {
    var iterator = stream.lines.makeAsyncIterator()
    guard let first = try await iterator.next() else {
      throw "No response from server"
    }
    guard let data = first.data(using: .utf8), let status = try? JSONDecoder().decode(ServerStatus.self, from: data) else {
      throw "Invalid response from server"
    }
    messages.append(
      Message(message: "\(status.activeUsers) active users")
    )
    
    let notification = Task {
      await observeAppStatus()
    }
    defer {
      notification.cancel()
    }
    for try await line in stream.lines {
      if let data = line.data(using: .utf8), let update = try? JSONDecoder().decode(Message.self, from: data) {
        messages.append(update)
      }
    }
  }
  
  func observeAppStatus() async {
    Task {
      for await _ in NotificationCenter.default
        .notifications(for: UIApplication.willResignActiveNotification) {
        try? await say("\(username) went away", isSystemMessage: true)
      }
    }
    
    Task {
      for await _ in NotificationCenter.default
        .notifications(for: UIApplication.didBecomeActiveNotification) {
        try? await say("\(username) come back", isSystemMessage: true)
      }
    }
  }

  /// Sends the user's message to the chat server
  func say(_ text: String, isSystemMessage: Bool = false) async throws {
    guard
      !text.isEmpty,
      let url = URL(string: "http://localhost:8080/chat/say")
    else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = try JSONEncoder().encode(
      Message(id: UUID(), user: isSystemMessage ? nil : username, message: text, date: Date())
    )

    let (_, response) = try await urlSession.data(for: request, delegate: nil)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error."
    }
  }

  /// A URL session that goes on indefinitely, receiving live updates.
  private var liveURLSession: URLSession = {
    var configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = .infinity
    return URLSession(configuration: configuration)
  }()
}

extension AsyncSequence {
  func forEach(_ body: (Element) async throws -> Void) async throws {
    for try await element in self {
      try await body(element)
    }
  }
}

import Combine

extension Publisher {
  var asAsyncStream: AsyncThrowingStream<Output, Error> {
    AsyncThrowingStream(Output.self) { continuation in
      let cancelable = sink { completion in
        switch completion {
        case .finished:
          continuation.finish()
        case .failure(let error):
          continuation.finish(throwing: error)
        }
      } receiveValue: { output in
        continuation.yield(output)
      }
      continuation.onTermination = { @Sendable _ in
        cancelable.cancel()
      }
    }
  }
}

enum Test {
  case test
  func test() async throws {
    let stream = Timer.publish(every: 1, on: .main, in: .default)
      .autoconnect()
      .asAsyncStream
    for try await v in stream {
      print(v)
    }
  }
  
  func testNotification() {
   let task = Task {
      let backgroundNotifications = NotificationCenter.default.notifications(named: UIApplication.didEnterBackgroundNotification)
      for await notification in backgroundNotifications {
        print(notification)
      }
    }
    
    // .....
    
    task.cancel()
  }
  
  func asyncMethod() async throws -> Bool {
    try await Task.sleep(for: .seconds(1))
    return true
  }
  
  
  func work() async throws -> String {
    var s = ""
    for c in "Hello" {
      //      guard Task.isCancelled else { return s}
      try Task.checkCancellation()
      await Task.sleep(NSEC_PER_SEC)
      print("Append:\(c)")
      s.append(c)
    }
    return s
  }
  
  func work(_ text: String) async throws -> String {
    var s = ""
    for c in text {
      if Task.isCancelled {
        print("Cancelled: \(text)")
      }
      try await Task.sleep(for: .seconds(1))
      print("Append:\(c)")
      s.append(c)
    }
    return s
  }
  
  func group() async  {
    do {
      let value: String = try await withThrowingTaskGroup(of: String.self) { group in
        group.addTask {
          try await withThrowingTaskGroup(of: String.self) { inner in
            inner.addTask {
              try await work("hello")
            }
            inner.addTask {
              try await work("world!")
            }
            try await Task.sleep(for: .seconds(1))
            inner.cancelAll()
            return try await inner.reduce([], { $0 + [$1]}).joined(separator: " ")
          }
        }
        group.addTask {
          try await work("Swift Concurrency")
        }
        return try await group.reduce([], {$0 + [$1]}).joined(separator: " ")
      }
      print(value)
    } catch {
      print("Error:\(error)")
    }
  }
}


