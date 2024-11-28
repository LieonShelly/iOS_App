//
//  File.swift
//  AINote
//
//  Created by Renjun Li on 2024/11/28.
//

import SwiftUI

struct PopupContentView: View {
    var body: some View {
        VStack {
            Text("Hello, SwiftUI Window!")
                .font(.headline)
                .padding()
            Button("Close") {
                NSApplication.shared.keyWindow?.close()
            }
            .padding()
        }
        .background(.white)
        .frame(width: 300, height: 200)
    }
}
