//
//  ContentView.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.gray.frame(height: UIScreen.main.bounds.height)
            AddMoodView()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
