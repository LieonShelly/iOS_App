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
