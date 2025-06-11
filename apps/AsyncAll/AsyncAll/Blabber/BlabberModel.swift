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
  
  nonisolated init() {}
  
  func shareLocation() async throws { }
  
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
