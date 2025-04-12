//
//  ContentView.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/5.
//

import SwiftUI

struct ContentView: View {
    @StateObject var renderer = CropRender()
    @State private var cropRect: CGRect = .zero
    @State private var imageFrame: CGRect = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 图像视图 (底层)
                MetalImageView(renderer: renderer)
                    .onAppear(perform: {
                        renderer.updateCanvasSize(geometry.size.sizeInMetal)
                        renderer.loadTexture()
                        renderer.display(in: CGSize(width: geometry.size.width - 20, height: geometry.size.width - 20).sizeInMetal)
                        imageFrame = renderer.getImageFrame(in: geometry.size)
                        cropRect = imageFrame
                    })
                
                // 裁剪框层 (固定位置)
                Color.clear
                    .overlay(
                        CropOverlayView(cropRect: $cropRect)
                    )
                    .allowsHitTesting(true)
                    .onChange(of: cropRect) { newRect in
                        // Ensure crop rect stays within image bounds
                        let boundedRect = CGRect(
                            x: max(imageFrame.minX, min(newRect.minX, imageFrame.maxX - newRect.width)),
                            y: max(imageFrame.minY, min(newRect.minY, imageFrame.maxY - newRect.height)),
                            width: min(newRect.width, imageFrame.width),
                            height: min(newRect.height, imageFrame.height)
                        )
                        if boundedRect != newRect {
                            cropRect = boundedRect
                        }
                    }
                
                // 控制按钮 (顶层)
                VStack {
                    Spacer()
                    HStack {
                        Button("应用裁剪") {
                            // Convert screen coordinates to image coordinates
                            let normalizedX = (cropRect.minX - imageFrame.minX) / imageFrame.width
                            let normalizedY = (cropRect.minY - imageFrame.minY) / imageFrame.height
                            let normalizedWidth = cropRect.width / imageFrame.width
                            let normalizedHeight = cropRect.height / imageFrame.height
                            
                            let imageX = Int(normalizedX * CGFloat(renderer.texture?.width ?? 0))
                            let imageY = Int(normalizedY * CGFloat(renderer.texture?.height ?? 0))
                            let imageWidth = Int(normalizedWidth * CGFloat(renderer.texture?.width ?? 0))
                            let imageHeight = Int(normalizedHeight * CGFloat(renderer.texture?.height ?? 0))
                            
                            renderer.cropImage(fromX: imageX, fromY: imageY, width: imageWidth, height: imageHeight) { success in
                                if success {
                                    renderer.display(in: CGSize(width: geometry.size.width - 20, height: geometry.size.width - 20).sizeInMetal)
                                    imageFrame = renderer.getImageFrame(in: geometry.size)
                                    cropRect = imageFrame
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
        }
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
