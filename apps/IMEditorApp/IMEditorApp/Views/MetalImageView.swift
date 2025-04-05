//
//  MetalImageView.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/5.
//

import SwiftUI
import MetalKit

struct MetalImageView: UIViewRepresentable {
    let renderer: MetalRenderer

    func makeUIView(context: Context) -> MTKView {
        return renderer.metalView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        // 可在此响应 SwiftUI 状态更新
    }
}
