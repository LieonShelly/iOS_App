//
//  WaterMarkRenderer.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/28.
//

import Foundation
import MetalKit
import Foundation
import CoreImage
import ImageIO
import UniformTypeIdentifiers
import simd
import SwiftUI

class WaterMarkRenderer: MetalRenderer {
    private var watermarkTexture: MTLTexture?
    private var watermarkVB: MTLBuffer?
    private var watermarkUniform: Uniforms = .init(transform: .identity)
    private var watermarkIndexBuffer: MTLBuffer!
    
    func loadWaterMark() {
        let textureLoader = MTKTextureLoader(device: device)
        watermarkTexture = try? textureLoader.newTexture(name: "watermark", scaleFactor: 1.0, bundle: nil)
        
        let halfW: Float = 0.5 / 2.0
        let halfH: Float = 0.5 / 2.0

        let transform: float4x4 = .identity

        let topLeft     = transform * SIMD4<Float>(-halfW,  halfH, 0, 1)
        let bottomLeft  = transform * SIMD4<Float>(-halfW, -halfH, 0, 1)
        let bottomRight = transform * SIMD4<Float>( halfW, -halfH, 0, 1)
        let topRight    = transform * SIMD4<Float>( halfW,  halfH, 0, 1)

        let watermarkVertices: [Float] = [
            topLeft.x,     topLeft.y,     0.0, 0.0,
            bottomLeft.x,  bottomLeft.y,  0.0, 1.0,
            bottomRight.x, bottomRight.y, 1.0, 1.0,
            topRight.x,    topRight.y,    1.0, 0.0
        ]
        
        
        let indices: [UInt16] = [ 0, 1, 2,  2, 3, 0 ]  // 三角形索引

        watermarkVB = device.makeBuffer(bytes: watermarkVertices, length: watermarkVertices.count * MemoryLayout<Float>.size, options: [])
        watermarkIndexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
        
    }
    
    override func setupVertices(for imageSize: CGSize, in viewSize: CGSize) {
        super.setupVertices(for: imageSize, in: viewSize)
        let viewAspect = Float(viewSize.width / viewSize.height)
        let modelMatrix = float4x4.identity
        
        let imageAspect = Float(imageSize.width / imageSize.height)
        var cropLeft: Float = -1 * viewAspect
        var cropRight: Float = 1 * viewAspect
        var cropTop: Float = 1
        var cropBottom: Float = -1
        
        if imageAspect > viewAspect {
            cropLeft = -1
            cropRight = 1
            cropTop =  (1.0 / viewAspect)
            cropBottom = -(1.0 / viewAspect)
            
        }
        let cropProjection = float4x4(orthographicLeft: cropLeft, right: cropRight, bottom: cropBottom, top: cropTop, near: -1, far: 1)
        uniforms.transform = cropProjection * modelMatrix
        
        let metalPoint = currentVertices.map { uniforms.transform * SIMD4<Float>(Float($0.x), Float($0.y), 0, 1) }
        print("after transform metalPoint:\(metalPoint)")
    }
    
    override func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let texture = texture else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setViewport(MTLViewport(originX: 0, originY: 0,
                                                width: Double(view.drawableSize.width),
                                              height: Double(view.drawableSize.height),
                                              znear: 0, zfar: 1))
        
        commandEncoder?.setRenderPipelineState(pipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        
        commandEncoder?.setVertexBuffer(watermarkVB, offset: 0, index: 0)
        commandEncoder?.setVertexBytes(&watermarkUniform, length: MemoryLayout<Uniforms>.stride, index: 1)
        commandEncoder?.setFragmentTexture(watermarkTexture, index: 0)
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: watermarkIndexBuffer, indexBufferOffset: 0)
        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
    
    
}
