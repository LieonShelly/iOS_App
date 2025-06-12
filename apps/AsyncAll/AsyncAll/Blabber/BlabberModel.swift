//
//  BlabberModel.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/10.
//

import Foundation
import CoreLocation
import Combine
import UIKit


@MainActor
class BlabberModel: ObservableObject {
  var username: String = ""
  var urlSession = URLSession.shared
  @Published var message: [Message] = []
  private let manager = CLLocationManager()
  private var delegate: ChatLocationDelegate?
  
  nonisolated init() {}
  
  func shareLocation() async throws {
    let location: CLLocation = try await
    withCheckedThrowingContinuation {[weak self] continuation in
      guard let self else { return }
      self.delegate = ChatLocationDelegate(manager: manager, continuation: continuation)
      if manager.authorizationStatus == .authorizedWhenInUse {
        manager.startUpdatingLocation()
      }
    }
    print(location.description)
    manager.stopUpdatingLocation()
    delegate = nil
    let address: String = try await withCheckedThrowingContinuation { continuation in
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
  
  func chat() async throws {
    guard
      let query = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
      let url = URL(string: "http://localhost:8080/chat/room?\(query)")
    else {
      throw "Invalid username"
    }
    let (stream, response) = try await liveURLSession.bytes(from: url)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error."
    }
    print("Start live updates")
    
    
    try await  withTaskCancellationHandler {
      try await readMessages(stream: stream)
    } onCancel: {
      print("End live updates")
      Task { @MainActor in
        message = []
      }
    }
  }
  
  private func readMessages(stream: URLSession.AsyncBytes) async throws {
    var iterator = stream.lines.makeAsyncIterator()
    guard let first = try await iterator.next() else {
      throw "NO response from server"
    }
    guard let data = first.data(using: .utf8), let status = try? JSONDecoder().decode(ServerStatus.self, from: data) else {
      throw "Invalid response from server"
    }
    message.append(Message(message: "\(status.activeUsers) active users"))
    
    let notifications = Task {
      await observeAppStatus()
    }
    defer {
      notifications.cancel()
    }
    for try await line in stream.lines {
      if let data = line.data(using: .utf8), let update = try? JSONDecoder().decode(Message.self, from: data) {
        message.append(update)
      }
    }
  }
  
  private func observeAppStatus() async {
    Task {
      for await _ in NotificationCenter.default.notifications(for: UIApplication.didBecomeActiveNotification) {
        try await say("\(username) come back", isSystemMessage: true)
      }
    }
    Task {
      for await _ in NotificationCenter.default.notifications(for: UIApplication.willResignActiveNotification) {
        try await say("\(username) wen away", isSystemMessage: true)
      }
    }
  }
  
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
    let (_, response) = try await urlSession.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error"
    }
  }
    
  func countdown(to message: String) async throws {
    guard !message.isEmpty else { return }
    var countdown = 3
    let counter = AsyncStream<String> {
      guard countdown >= 0 else { return nil }
      do {
        try await Task.sleep(for: .seconds(1))
      } catch {
        return nil
      }
      defer { countdown -= 1}
      if countdown == 0 {
        return "🎉 " + message
      } else {
        return "\(countdown)..."
      }
    }
    try await counter.forEach { element in
      try await say(element)
    }
  }
  
  
  private var liveURLSession: URLSession = {
    var configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = .infinity
    return URLSession(configuration: configuration)
  }()
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
