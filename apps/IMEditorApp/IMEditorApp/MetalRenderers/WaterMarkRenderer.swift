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
    private var watermarkPipeline: MTLRenderPipelineState!

    override init() {
        super.init()
        let defaultLib = device.makeDefaultLibrary()
        let vertextFunction = defaultLib?.makeFunction(name: "vertexShader")
        let fragmentFunction = defaultLib?.makeFunction(name: "fragment_watermark")
        
        let watermarkDescriptor = MTLRenderPipelineDescriptor()
        watermarkDescriptor.vertexDescriptor = createVertexDescriptor()
        watermarkDescriptor.vertexFunction = vertextFunction
        watermarkDescriptor.fragmentFunction = fragmentFunction
        watermarkDescriptor.colorAttachments[0].pixelFormat = self.metalView.colorPixelFormat
        watermarkDescriptor.colorAttachments[0].isBlendingEnabled = true
        watermarkDescriptor.colorAttachments[0].rgbBlendOperation = .add
        watermarkDescriptor.colorAttachments[0].alphaBlendOperation = .add
        watermarkDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        watermarkDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        watermarkDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        do {
            watermarkPipeline = try device.makeRenderPipelineState(descriptor: watermarkDescriptor)
        } catch {
            fatalError("Error: Failed to create pipeline state - \(error)")
        }
       
    }
    
    func loadWaterMark() {
        let textureLoader = MTKTextureLoader(device: device)
        watermarkTexture = try? textureLoader.newTexture(name: "logo", scaleFactor: 1.0, bundle: nil)
    }
    
    override func setupVertices(for imageSize: CGSize, in viewSize: CGSize) {
        super.setupVertices(for: imageSize, in: viewSize)
        setupMainTextureTransform(imgSize: imageSize, viewSize: viewSize)
        setWatermarkTransform(for: imageSize, in: viewSize)
    }
    
    private func setWatermarkTransform(for imageSize: CGSize, in viewSize: CGSize) {
        let viewAspect = Float(viewSize.width / viewSize.height)
        let imageAspect = Float(imageSize.width / imageSize.height)
        
        // 在 Metal 坐标系下，View 是 [-1, 1]，我们用这个范围来计算图像显示区域
        var displayWidth: Float = 0
        var displayHeight: Float = 0

        if imageAspect > viewAspect {
            displayWidth = 2.0 // Metal 的 [-1, 1] 范围是 2 个单位宽
            displayHeight = displayWidth / imageAspect
        } else {
            displayHeight = 2.0
            displayWidth = displayHeight * imageAspect
        }

        let halfW = displayWidth / 2.0
        let halfH = displayHeight / 2.0

        let transform: float4x4 = .identity

        let topLeft     = transform * SIMD4<Float>(-halfW,  halfH, 0, 1)
        let bottomLeft  = transform * SIMD4<Float>(-halfW, -halfH, 0, 1)
        let bottomRight = transform * SIMD4<Float>( halfW, -halfH, 0, 1)
        let topRight    = transform * SIMD4<Float>( halfW,  halfH, 0, 1)


        let quadVertices: [Float] = [
            topLeft.x,     topLeft.y,     0.0, 0.0,
            bottomLeft.x,  bottomLeft.y,  0.0, 1.0,
            bottomRight.x, bottomRight.y, 1.0, 1.0,
            topRight.x,    topRight.y,    1.0, 0.0
        ]
        
        let indices: [UInt16] = [ 0, 1, 2,  2, 3, 0 ]  // 三角形索引

        watermarkVB = device.makeBuffer(bytes: quadVertices, length: quadVertices.count * MemoryLayout<Float>.size, options: [])
        watermarkIndexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
        
    }
    
    private func setupMainTextureTransform(imgSize: CGSize, viewSize: CGSize) {
        let viewAspect = Float(viewSize.width / viewSize.height)
        let modelMatrix = float4x4.identity
        
        let imageAspect = Float(imgSize.width / imgSize.height)
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
        
        let zRotationMatrix = float4x4(angleZ: Float(Angle(degrees: 0).radians))
        
        watermarkUniform.transform = uniforms.transform * zRotationMatrix
    }
    
    override func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let watermarkTexture,
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
        
        commandEncoder?.setRenderPipelineState(watermarkPipeline)
        commandEncoder?.setVertexBuffer(watermarkVB, offset: 0, index: 0)
        commandEncoder?.setVertexBytes(&watermarkUniform, length: MemoryLayout<Uniforms>.stride, index: 1)
        commandEncoder?.setFragmentTexture(watermarkTexture, index: 0)
        
        // 主图尺寸
        var imageSize = SIMD2<Float>(Float(imageSize.width), Float(imageSize.height))
        var watermarkSize = SIMD2<Float>(Float(watermarkTexture.width), Float(watermarkTexture.height))
        // 每个水印 tile 的尺寸（10x10 像素）
        var tileSize = SIMD2<Float>(500, 500)

        // 旋转角度（45度）
        var rotation: Float = 45
        commandEncoder?.setFragmentBytes(&imageSize, length: MemoryLayout<SIMD2<Float>>.size, index: 0)
        commandEncoder?.setFragmentBytes(&tileSize, length: MemoryLayout<SIMD2<Float>>.size, index: 1)
        commandEncoder?.setFragmentBytes(&rotation, length: MemoryLayout<Float>.size, index: 2)
        commandEncoder?.setFragmentBytes(&watermarkSize, length: MemoryLayout<SIMD2<Float>>.size, index: 3)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: watermarkIndexBuffer, indexBufferOffset: 0)
        
       
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
    
    
}
