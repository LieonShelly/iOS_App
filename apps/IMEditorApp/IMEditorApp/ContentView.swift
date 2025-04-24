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
    @StateObject private var menuViewModel: ClippingMenuViewModel = .init()
    @State private var maxRect: CGRect = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 图像视图 (底层)
                renderView(geometry)
                
                // 裁剪框层 (固定位置)
                cropView(geometry)
                
                // 控制按钮 (顶层)
                menuView(geometry)
            }
        }
    }
    
    
    func renderView(_ geometry: GeometryProxy) -> some View {
        MetalImageView(renderer: renderer)
            .onAppear(perform: {
                renderer.loadTexture()
                renderer.display(in: geometry.size.sizeInMetal)
                imageFrame = renderer.getImageFrame(in: geometry.size)
                cropRect = imageFrame
                maxRect = imageFrame
                menuViewModel.didUpdateProgress = { index, progress in
                    switch index {
                    case 0: renderer.rotate((-Float.pi + 2 * Float.pi * Float(progress)))
                    case 1: renderer.rotateY((-Float.pi + 2 * Float.pi * Float(progress)))
                    case 2: renderer.rotateX((-Float.pi + 2 * Float.pi * Float(progress)))
                    default: break
                    }
                }
                
            })
            .onChange(of: scale) {_, newValue in
                let scaleFactor = Float(newValue)
                renderer.zoom(factor: scaleFactor)
            }
            .onChange(of: translation) {_, newValue in
                let offset = SIMD3<Float>(Float(CGFloat(newValue.x / geometry.size.width)), -Float(CGFloat(newValue.y / geometry.size.height)), 1)
                renderer.pan(deltaX: offset.x, deltaY: offset.y)
            }
            .onChange(of: rotationAngle) {_,  newValue in
                renderer.rotate(Float(newValue.radians))
            }
    }
    
    func cropView(_ geometry: GeometryProxy) -> some View {
        Color.clear
            .overlay(
                CropOverlayView(cropRect: $cropRect, scale: $scale, translation: $translation, rotationAngle: $rotationAngle, maxRect: $maxRect)
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
    }
    
    func menuView(_ geometry: GeometryProxy) -> some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "square.and.arrow.down.fill")
                    .foregroundStyle(AppColor.primary)
                    .onTapGesture {
                        renderer.newerCrop(cropRect) { result in
                            
                        }
                    }
                
                Image(systemName: "arrow.trianglehead.clockwise.rotate.90")
                    .foregroundStyle(AppColor.primary)
                    .onTapGesture {
                        renderer.resetTransform()
                    }
                
            }
            .padding(.horizontal, 20)
            Spacer()
            ClippingMenu(viewModel: menuViewModel)
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
