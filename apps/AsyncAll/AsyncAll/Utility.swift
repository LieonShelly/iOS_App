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
    if counter % failingEvery == 0 {
      counter = 0
      throw Error()
    }
  }
}

import UIKit
import Accelerate

struct ResizeError: Error { }

func resize(_ data: Data, to size: CGSize) throws -> UIImage {
  guard let cgImage = UIImage(data: data)?.cgImage,
    let colorSpace = cgImage.colorSpace else {
      throw ResizeError()
    }

  var format = vImage_CGImageFormat(
    bitsPerComponent: UInt32(cgImage.bitsPerComponent),
    bitsPerPixel: UInt32(cgImage.bitsPerPixel),
    colorSpace: Unmanaged.passRetained(colorSpace),
    bitmapInfo: cgImage.bitmapInfo,
    version: 0,
    decode: nil,
    renderingIntent: cgImage.renderingIntent
  )

  var buffer = vImage_Buffer()
  vImageBuffer_InitWithCGImage(&buffer, &format, nil, cgImage, vImage_Flags(kvImageNoFlags))

  var destinationBuffer = try vImage_Buffer(width: Int(200), height: Int(200), bitsPerPixel: format.bitsPerPixel)

  defer { destinationBuffer.free() }

  _ = withUnsafePointer(to: buffer) { sourcePointer in
    vImageScale_ARGB8888(sourcePointer, &destinationBuffer, nil, vImage_Flags(kvImageNoFlags))
  }

  let destinationCGImage = vImageCreateCGImageFromBuffer(
    &buffer, &format, nil, nil, vImage_Flags(kvImageNoFlags), nil
  )

  guard let destinationCGImage = destinationCGImage else {
    throw ResizeError()
  }

  return UIImage(cgImage: destinationCGImage.takeRetainedValue())
}
