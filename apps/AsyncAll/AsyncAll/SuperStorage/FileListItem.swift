//
//  FileListItem.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/10.
//

import SwiftUI

struct FileListItem: View {
    let file: DownloadFile
    
    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                Text(file.name)
                Spacer()
                Image(systemName: "chevron.right")
            }
            HStack {
                Image(systemName: "photo")
                Text(sizeFormatter.string(fromByteCount: Int64(file.size)))
                Text(" ")
                Text(dateFormatter.string(from: file.date))
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.bottom, 10)
            .font(.caption)
            .foregroundColor(Color.primary)
        }
    }
}
