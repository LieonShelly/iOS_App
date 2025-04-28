//
//  ContentView.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/5.
//

import SwiftUI
import simd

struct ContentView: View {
    var body: some View {
        WatermarkHomeView()
    }
}

#Preview {
    ContentView()
}


extension CGSize {
    var sizeInMetal: CGSize {
        CGSize(width: width * UIScreen.main.nativeScale, height: height * UIScreen.main.nativeScale)
    }
    
    var sizeInScreen: CGSize {
        CGSize(width: width / UIScreen.main.nativeScale, height: height / UIScreen.main.nativeScale)
    }
}
