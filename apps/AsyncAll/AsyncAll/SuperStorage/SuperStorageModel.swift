//
//  SuperStorageModel.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/9.
//

import SwiftUI
import Foundation

class SuperStorageModel: ObservableObject {
  @Published var downloads: [DownloadInfo] = []
  @TaskLocal static var supportsPartrialDownloads = false
  
  func download(file: DownloadFile) async throws -> Data {
    guard let url = URL(string: "http://localhost:8080/files/download?\(file.name)") else {
      throw "Could not create the URL."
    }
    await addDownload(name: file.name)
    
    let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
    
    await updateDownload(name: file.name, progress: 1.0)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error"
    }
    return data
  }
  
  func downloadWithProgress(file: DownloadFile) async throws -> Data {
    return try await downloadWithProgress(fileName: file.name, name: file.name, size: file.size, offset: nil)
  }
  
  private func downloadWithProgress(fileName: String, name: String, size: Int, offset: Int? = nil) async throws -> Data {
    guard let url = URL(string: "http://localhost:8080/files/download?\(fileName)") else {
      throw "Could not create the URL."
    }
    await addDownload(name: name)
    let result: (downloadStream: URLSession.AsyncBytes, response: URLResponse)
    if let offset {
      let urlRequest = URLRequest(url: url, offset: offset, length: size)
      result = try await URLSession.shared.bytes(for: urlRequest, delegate: nil)
      guard (result.response as? HTTPURLResponse)?.statusCode == 206 else {
        throw "The server responded with an error"
      }
    } else {
      result = try await URLSession.shared.bytes(from: url, delegate: nil)
      guard (result.response as? HTTPURLResponse)?.statusCode == 200 else {
        throw "The server responded with an error"
      }
    }
    var asyncDownloadIterator = result.downloadStream.makeAsyncIterator()
    var accmulator = ByteAccumulator(name: name, size: size)
    
    while await !stopDownloads, !accmulator.checkCompleted() {
      while !accmulator.isBatchCompleted,
            let byte = try await asyncDownloadIterator.next() {
        accmulator.append(byte)
      }
      let progress = accmulator.progress
      Task.detached(priority: .medium) {
        await self.updateDownload(name: name, progress: progress)
      }
      print(accmulator.description)
    }
    if await stopDownloads, !Self.supportsPartrialDownloads {
      throw  CancellationError()
    }
    return accmulator.data
  }
  
  func multiDownloadWithProgress(file: DownloadFile) async throws -> Data {
    func partInfo(index: Int, of count: Int) -> (offset: Int, size: Int, name: String) {
      let standardPartSize = Int((Double(file.size) / Double(count)).rounded(.up))
      let partOffset = index * standardPartSize
      let partSize = min(standardPartSize, file.size - partOffset)
      let partName = "\(file.name)(part \(index + 1)"
      return (offset: partOffset, size: partSize, name: partName)
    }
    let total = 4
    let parts = (0 ..< total).map { partInfo(index: $0, of: total)}
    
    async let part1 = downloadWithProgress(fileName: file.name, name: parts[0].name, size: parts[0].size, offset: parts[0].offset)
    async let part2 = downloadWithProgress(fileName: file.name, name: parts[1].name, size: parts[1].size, offset: parts[1].offset)
    async let part3 = downloadWithProgress(fileName: file.name, name: parts[2].name, size: parts[2].size, offset: parts[2].offset)
    async let part4 = downloadWithProgress(fileName: file.name, name: parts[3].name, size: parts[3].size, offset: parts[3].offset)
    
    return try await[part1, part2, part3, part4].reduce(Data(), +)
  }
  
  func avaiableFiles() async throws -> [DownloadFile] {
    guard let url = URL(string: "http://localhost:8080/files/list") else {
      throw "Could not create the URL."
    }
    let (data, response) = try await URLSession.shared.data(from: url)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error"
    }
    guard let list = try? JSONDecoder().decode([DownloadFile].self, from: data) else {
      throw "The server response was not recognized"
    }
    return list
  }
  
  func status() async throws -> String {
    guard let url = URL(string: "http://localhost:8080/files/status") else {
      throw "Could not create the URL."
    }
    let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error."
    }
    return String(decoding: data, as: UTF8.self)
  }
  
  @MainActor var stopDownloads = false
  
  @MainActor
  func reset() {
    stopDownloads = false
    downloads.removeAll()
  }
}

extension SuperStorageModel {
  @MainActor func updateDownload(name: String, progress: Double) {
    if let index = downloads.firstIndex(where: {$0.name == name}) {
      var info = downloads[index]
      info.progress = progress
      downloads[index] = info
    }
  }
  
  @MainActor func addDownload(name: String) {
    let downloadInfo = DownloadInfo(id: UUID(), name: name, progress: 0.0)
    downloads.append(downloadInfo)
  }
}

