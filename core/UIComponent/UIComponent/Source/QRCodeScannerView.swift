//
//  QRCodeScannerView.swift
//  UIComponent
//
//  Created by Renjun Li on 2024/10/24.
//

import SwiftUI

struct QRCodeScannerView: View {
    @State private var scanOffset: CGFloat = -100
    @State private var scanOpacity: Double = 0.0

    var body: some View {
        GeometryReader { proxy in
            let scanSize: CGFloat = 200
            let lineWidth: CGFloat = 16
            let lineH: CGFloat = 3
            let parentWidth = proxy.size.width
            let parentH = proxy.size.height
            let scanCenter = CGPoint(x: parentWidth * 0.5, y: parentH * 0.5)
            ZStack {
                Color
                    .black
                    .opacity(0.8)

                Color.white
                    .background(
                        Color.black.opacity(1)
                    )
                    .mask(
                        Rectangle()
                            .frame(width: scanSize, height: scanSize)
                            .position(x: scanCenter.x,
                                      y: scanCenter.y)
                    )
                    .overlay(
                        // 矩形角边框
                        ZStack {
                            Rectangle()
                                .frame(width: lineWidth, height: lineH) // 上边框
                                .foregroundColor(.red)
                                .offset(
                                    x: -(parentWidth * 0.5 - scanSize * 0.5) + lineWidth * 0.5,
                                    y: -scanSize * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineH, height: lineWidth) // 左边框
                                .foregroundColor(.red)
                                .offset(
                                    x: -(parentWidth * 0.5 - scanSize * 0.5) + lineH * 0.5,
                                    y: -scanSize * 0.5 + lineWidth * 0.5
                                )
                            
                            // 右上角
                            Rectangle()
                                .frame(width: lineWidth, height: lineH) // 上边框
                                .foregroundColor(.red)
                                .offset(
                                    x: scanSize * 0.5 - lineWidth * 0.5,
                                    y: -scanSize * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineH, height: lineWidth) // 右边框
                                .foregroundColor(.red)
                                .offset(
                                    x: scanSize * 0.5 - lineH * 0.5,
                                    y: -scanSize * 0.5 + lineWidth * 0.5
                                )
                            
                            // 左下角
                            Rectangle()
                                .frame(width: lineWidth, height: lineH) // 下边框
                                .foregroundColor(.red)
                                .offset(
                                    x: -(parentWidth * 0.5 - scanSize * 0.5) + lineWidth * 0.5,
                                    y: scanSize * 0.5 - lineH * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineH, height: lineWidth) // 左边框
                                .foregroundColor(.red)
                                .offset(
                                    x: -(parentWidth * 0.5 - scanSize * 0.5) + lineH * 0.5,
                                    y: scanSize * 0.5 - lineWidth * 0.5
                                )
                            
                            // 右下角
                            Rectangle()
                                .frame(width: lineWidth, height: lineH) // 下边框
                                .foregroundColor(.red)
                                .offset(
                                    x: scanSize * 0.5 - lineWidth * 0.5,
                                    y: scanSize * 0.5 - lineH * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineH, height: lineWidth) // 右边框
                                .foregroundColor(.red)
                                .offset(
                                    x: scanSize * 0.5 - lineH * 0.5,
                                    y: scanSize * 0.5 - lineWidth * 0.5
                                )
                        }
                    )
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: scanSize, height: 2)
                    .position(x: scanCenter.x, y: scanCenter.y + scanOffset)
                    .opacity(scanOpacity)
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            scanOffset = 100
                        }
                        
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) {
                            scanOpacity = 1
                            
                        }
                    }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    QRCodeScannerView()
}
