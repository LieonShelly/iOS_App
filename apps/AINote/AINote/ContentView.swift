//
//  ContentView.swift
//  AINote
//
//  Created by Renjun Li on 2024/11/27.
//

import SwiftUI
import Cocoa
import ApplicationServices

struct ContentView: View {
    @StateObject private var shortcutManager = ShortcutManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
        }
    }
}

#Preview {
    ContentView()
}
