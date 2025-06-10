//
//  DownloadFile.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/10.
//

import Foundation

/// A downloadable file.
struct DownloadFile: Codable, Identifiable, Equatable {
  var id: String { return name }
  let name: String
  let size: Int
  let date: Date
  static let empty = DownloadFile(name: "", size: 0, date: Date())
}

/// Download information for a given file.
struct DownloadInfo: Identifiable, Equatable {
  let id: UUID
  let name: String
  var progress: Double
}
