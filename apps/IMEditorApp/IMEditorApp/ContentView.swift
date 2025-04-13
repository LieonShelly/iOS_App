//
//  ContentView.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/5.
//

import SwiftUI
import simd

struct ContentView: View {
    @StateObject var renderer = CropRender()
    @State private var cropRect: CGRect = .zero
    @State private var scale: CGFloat = .zero
    @State private var translation: CGPoint = .zero
    @State private var imageFrame: CGRect = .zero
    @State private var debounceItem: DispatchWorkItem?
    @State private var deltaX: Float = 0
    @State private var deltaY: Float = 0
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 图像视图 (底层)
                MetalImageView(renderer: renderer)
                    .onAppear(perform: {
                        renderer.updateCanvasSize(geometry.size.sizeInMetal)
                        renderer.loadTexture()
                        renderer.display(in: CGSize(width: geometry.size.width - 20, height: geometry.size.height - 20).sizeInMetal)
                        imageFrame = renderer.getImageFrame(in: geometry.size)
                        cropRect = imageFrame
                    })
                    .onChange(of: scale) { newValue in
                        // 计算缩放因子 - 确保1.0是无缩放状态
                        let scaleFactor = Float(newValue)
                        renderer.zoom(factor: scaleFactor)
                    }
                    .onChange(of: translation) { newValue in
                        let martrix = Martrix.screenToMetalDeltaMartrix(geometry.size)
                        let offset = martrix * SIMD3<Float>(Float(newValue.x), Float(newValue.y), 1)
                        renderer.pan(deltaX: offset.x, deltaY: offset.y)
                    }
                
                // 裁剪框层 (固定位置)
                Color.clear
                    .overlay(
                        CropOverlayView(cropRect: $cropRect, scale: $scale, translation: $translation)
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
                           let screenToMetalMartrix = Martrix.screenToMetalMartrix(geometry.size)
                            let leftTop = screenToMetalMartrix * SIMD3<Float>(Float(cropRect.origin.x), Float(cropRect.origin.y), 1)
                            let bottomRight = screenToMetalMartrix * SIMD3<Float>(Float(cropRect.maxX), Float(cropRect.maxY), 1)
                            renderer.crop(
                                CGRect(origin: CGPoint(x: CGFloat(leftTop.x), y: CGFloat(leftTop.y)),
                                       size: CGSize(width: CGFloat(bottomRight.x - leftTop.x),
                                                    height: CGFloat(leftTop.y - bottomRight.y))),
                                completion: { success in
                                    if success {
                                        renderer.display(in: CGSize(width: geometry.size.width - 20, height: geometry.size.width - 20).sizeInMetal)
                                        imageFrame = renderer.getImageFrame(in: geometry.size)
                                        cropRect = imageFrame
                                    }
                                })
                            return
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
                    
                    HStack {
                        Button("deltaX: + 0.1") {
                            renderer.pan(deltaX: 0.1, deltaY: 0)
                        }
                        Button("deltaY: + 0.1") {
                            renderer.pan(deltaX: 0, deltaY: 0.1)
                        }
                    }
                }
            }
        }
        .onAppear {
            let screenSize: CGSize = CGSize(width: 100, height: 100)
            let martrix = Martrix.screenToMetalMartrix(screenSize)
            
            print(martrix * SIMD3<Float>(0, 0, 1))
            print(martrix * SIMD3<Float>(50, 50, 1))
            print(martrix * SIMD3<Float>(100, 100,1))
            print(martrix * SIMD3<Float>(100, 0,1))
            print(martrix *  SIMD3<Float>(0, 100,1))
            print("=========")
            print(martrix.inverse *  SIMD3<Float>(0, 0,1))
            print(martrix.inverse *  SIMD3<Float>(1, -1,1))
            print(martrix.inverse *  SIMD3<Float>(-1, 1,1))
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
