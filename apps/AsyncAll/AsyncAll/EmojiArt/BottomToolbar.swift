//
//  BottomToolbar.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/18.
//

import SwiftUI

struct BottomToolbar: View {
    @EnvironmentObject var model: EmojiArtModel
    
    @State var onDiskAccessCount = 0
    @State var inMemoryAccessCount = 0
    
    var body: some View {
        HStack {
            Button(action: {
                Task {
                    await ImageDatabase.shared.clear()
                }
            }, label: {
                Image(systemName: "folder.badge.minus")
            })
            
            Button(action: {
                Task {
                    await ImageDatabase.shared.clearInMemoryAssets()
                    try await model.loadImages()
                }
            }, label: {
                Image(systemName: "square.stack.3d.up.slash")
            })
            
            Spacer()
            Text("Access: \(onDiskAccessCount) from disk, \(inMemoryAccessCount) in memory")
                .font(.monospaced(.caption)())
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 5)
        .task {
            guard let memoryAccessSequence =  ImageDatabase.shared.imageLoader.inMemoryAccess else {
                return
            }
            for await count in memoryAccessSequence {
                inMemoryAccessCount = count
            }
        }
    }
}
