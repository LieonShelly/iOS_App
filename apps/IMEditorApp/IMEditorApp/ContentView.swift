//
//  ContentView.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/5.
//

import SwiftUI

struct ContentView: View {
    @StateObject var renderer = MetalRenderer()
    @State private var cropRect = CGRect(x: 100, y: 100, width: 200, height: 200)
    
    var body: some View {
        ZStack {
            MetalImageView(renderer: renderer)
                .edgesIgnoringSafeArea(.all)

            CropOverlayView(cropRect: $cropRect)

            VStack {
                Spacer()
                HStack {
                    Button("应用裁剪") {
                        // 将 cropRect 传给 MetalRenderer 做裁剪
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .onAppear {
        }
    }
}

#Preview {
    ContentView()
}
