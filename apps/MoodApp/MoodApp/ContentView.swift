//
//  ContentView.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!").foregroundStyle(MoodColor.primary.color)
            Text("Hello, world!").foregroundStyle(MoodColor.textPrimary.color)
            Text("Hello, world!").foregroundStyle(MoodColor.textSecondary.color)
            Text("Hello, world!").foregroundStyle(MoodColor.textThird.color)
            Text("Hello, world!").foregroundStyle(MoodColor.textForth.color)
            Text("Hello, world!").foregroundStyle(MoodColor.textDisable.color)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
