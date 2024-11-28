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
 
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            Button {
                openWindow(id: "popupWindow")
            } label: {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("New window!")
            }
        }
        .padding()
        .onAppear {
        }
    }
}

#Preview {
    ContentView()
}
