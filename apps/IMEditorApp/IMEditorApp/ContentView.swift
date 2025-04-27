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
    @State private var imageFrame: CGRect = .zero
    @State private var debounceItem: DispatchWorkItem?
    @State private var rotationAngle: Angle = .zero
    @StateObject private var menuViewModel: ClippingMenuViewModel = .init()
    @State private var maxRect: CGRect = .zero
    @State private var lastOffsetPx: CGPoint = .zero
    
    var body: some View {
        VStack(spacing: .zero) {
            header
            GeometryReader { geometry in
                ZStack {
                    renderView(geometry)
                    cropView(geometry)
                }
            }
            Rectangle().fill(.blue).frame(height: 40)
        }
    }
    
    
    func renderView(_ geometry: GeometryProxy) -> some View {
        MetalImageView(renderer: renderer)
            .onAppear(perform: {
                renderer.loadTexture()
                renderer.display(in: geometry.size.sizeInMetal)
                imageFrame = renderer.getImageFrame(in: geometry.size)
                cropRect = imageFrame
                maxRect = geometry.frame(in: .global)
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
            .onChange(of: rotationAngle) {_,  newValue in
                renderer.rotate(Float(newValue.radians))
            }
    }
    @State var lastTx: Float = 0
    @State var lastTy: Float = 0
    func cropView(_ geometry: GeometryProxy) -> some View {
        Color.clear
            .overlay(
                CropOverlayView(
                    cropRect: $cropRect,
                    scale: $scale,
                    rotationAngle: $rotationAngle,
                    getmaxRect: {
                        return renderer.getImageFrame(in: geometry.size)
                    },
                    didUpdateTranslation: { deltaPx, didEnd in
                        let frame = renderer.getImageFrame(in: geometry.size)
                        // 模拟平移后的rect
                        let attempted = frame.offsetBy(dx: deltaPx.x, dy: deltaPx.y)
                        
                        var actualDx = deltaPx.x
                        var actualDy = deltaPx.y
                        
                        if deltaPx.x > 0 {
                            // 向右拖，左边缘不能超出
                            if attempted.minX > cropRect.minX {
                                actualDx = cropRect.minX - frame.minX
                            }
                        } else if deltaPx.x < 0 {
                            if attempted.maxX < cropRect.maxX {
                                actualDx = cropRect.maxX - frame.maxX
                            }
                        }
                        
                        if deltaPx.y > 0 {
                            // 向下拖
                            if attempted.minY > cropRect.minY {
                                actualDy = cropRect.minY - frame.minY
                            }
                        } else if deltaPx.y < 0 {
                            // 向上拖
                            if attempted.maxY < cropRect.maxY {
                                actualDy = cropRect.maxY - frame.maxY
                            }
                        }
                        
                        let tdx = Float(actualDx / geometry.size.width)
                        let tdy = -Float(actualDy / geometry.size.height)
                        renderer.prepan(deltaX: tdx, deltaY: tdy)
                    }
                )
            )
            .allowsHitTesting(true)
    }
    
    var header: some View {
        HStack {
            Spacer()
            Image(systemName: "square.and.arrow.down.fill")
                .foregroundStyle(AppColor.primary)
                .onTapGesture {
                    renderer.startScaleAnimation(newScale: 3.0)
                }
            
            Image(systemName: "arrow.trianglehead.clockwise.rotate.90")
                .foregroundStyle(AppColor.primary)
                .onTapGesture {
                    renderer.resetTransform()
                }
            
        }
        .padding(.horizontal, 20)
    }
    
    func menuView(_ geometry: GeometryProxy) -> some View {
        VStack {
           
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
