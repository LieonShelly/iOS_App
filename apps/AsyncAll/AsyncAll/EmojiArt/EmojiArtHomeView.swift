//
//  EmojiArtHomeView.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/16.
//

import SwiftUI

struct EmojiArtHomeView: View {
    @StateObject private var model: EmojiArtModel
    @State private var isVerified: Bool = false
    
    init() {
        self._model = .init(wrappedValue: EmojiArtModel())
    }
    
    var body: some View {
        VStack {
            if isVerified {
                EmojiArtListView()
            } else {
                EmojiArtLoadingView(isVerified: $isVerified)
            }
        }
        .transition(.opacity)
        .animation(.linear, value: isVerified)
        .environmentObject(model)
    }
}
