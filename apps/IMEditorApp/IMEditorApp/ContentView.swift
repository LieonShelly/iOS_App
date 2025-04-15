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
    @State private var rotationAngle: Angle = .zero
    
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
                    .onChange(of: scale) {_, newValue in
                        // 计算缩放因子 - 确保1.0是无缩放状态
                        let scaleFactor = Float(newValue)
                        renderer.zoom(factor: scaleFactor)
                    }
                    .onChange(of: translation) {_, newValue in
                        let offset = SIMD3<Float>(Float(CGFloat(newValue.x ) *  UIScreen.main.nativeScale), Float(CGFloat(-newValue.y) *  UIScreen.main.nativeScale), 1)
                        renderer.pan(deltaX: offset.x, deltaY: offset.y)
                    }
                    .onChange(of: rotationAngle) {_,  newValue in
                        print("rotationAngle: \(newValue)")
                        renderer.rotate(Float(newValue.radians))
                    }
                
                // 裁剪框层 (固定位置)
                Color.clear
                    .overlay(
                        CropOverlayView(cropRect: $cropRect, scale: $scale, translation: $translation, rotationAngle: $rotationAngle)
                    )
                    .allowsHitTesting(true)
                    .onChange(of: cropRect) {_,  newRect in
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
