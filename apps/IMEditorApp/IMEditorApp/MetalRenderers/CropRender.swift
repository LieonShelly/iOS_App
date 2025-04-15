//
//  CropRender.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/10.
//
import MetalKit
import Foundation
import CoreImage
import ImageIO
import UniformTypeIdentifiers
import simd

class CropRender: MetalRenderer {
    var scale: Float = 1
    var offsetX: Float = 0.0
    var offsetY: Float = 0.0
    var isCropped: Bool = false
    var angle: Float = 0.0
    var modelMatrix: float4x4 = .identity
  
    
    func zoom(factor: Float) {
        let newScale = scale * factor
        if newScale >= 0.1 && newScale <= 5.0 {
            scale = newScale
            updateVertices()
        }
    }
    
    func pan(deltaX: Float, deltaY: Float) {
        print("deltaX:\(deltaX) - deltaY:\(deltaY)")
        let sensitivityFactor = 1.0 / scale
        
        let adjustedDeltaX = deltaX * sensitivityFactor
        let adjustedDeltaY = deltaY * sensitivityFactor
        
        offsetX += adjustedDeltaX
        offsetY += adjustedDeltaY
        updateVertices()
    }
    
    func rotate(_ angleRadians: Float) {
        self.angle += angleRadians
        updateVertices()
    }
    
    func resetTransform() {
        scale = 1.0
        offsetX = 0.0
        offsetY = 0.0
    }
    
    private func updateVertices() {
        guard let texture = texture else { return }
        let imageSize = CGSize(width: texture.width, height: texture.height)
        let viewSize = displaySize != .zero ?
        displaySize :
        CGSize(width: canvasSize.width * UIScreen.main.nativeScale, height: canvasSize.height * UIScreen.main.nativeScale)
        setupVertices(for: imageSize, in: viewSize)
    }
    
    
    override func setupVertices(for imageSize: CGSize, in viewSize: CGSize) {
        super.setupVertices(for: imageSize, in: viewSize)
        
        // ⬇️ 模型变换：缩放、旋转、平移
        let scaleMatrix = float4x4(scaleX: scale, scaleY: scale)
        let translationMatrix = float4x4(translationX: offsetX, translationY: offsetY)
        let rotationMatrix = float4x4(rotationAngle: angle)
        self.modelMatrix = translationMatrix * rotationMatrix * scaleMatrix
        
        // ⬇️ 正交投影矩阵：从屏幕空间映射到 Metal 的 NDC 空间（-1 ~ 1）
        let viewAspect = Float(viewSize.width / viewSize.height)
        let projectionMatrix = float4x4(
            orthographicLeft:  -viewAspect,
            right: viewAspect,
            bottom: -1.0,
            top: 1,
            near: -1,
            far: 1
        )
        uniforms.transform = projectionMatrix * modelMatrix

    }
    
    func newCrop(_ cropRectInView: CGRect, completion: @escaping (Bool) -> Void) {
        let viewSize = metalView.drawableSize
        let cropRectInView = CGRect(x: cropRectInView.origin.x * UIScreen.main.nativeScale,
                                    y: cropRectInView.origin.y * UIScreen.main.nativeScale,
                                    width: cropRectInView.width * UIScreen.main.nativeScale,
                                    height: cropRectInView.height * UIScreen.main.nativeScale)
        
        // 1. 将 cropRect 从 UIKit 坐标转换为 Metal 坐标中心为 (0,0)
        let viewAspect = Float(viewSize.width / viewSize.height)
        let cropLeft = (Float(cropRectInView.minX) / Float(viewSize.width)) * 2 * viewAspect - viewAspect
        let cropRight = (Float(cropRectInView.maxX) / Float(viewSize.width)) * 2 * viewAspect - viewAspect
        let cropTop = (1.0 - Float(cropRectInView.minY) / Float(viewSize.height)) * 2.0 - 1.0
        let cropBottom = (1.0 - Float(cropRectInView.maxY) / Float(viewSize.height)) * 2.0 - 1.0

        
        let cropProjection = float4x4(orthographicLeft: cropLeft, right: cropRight, bottom: cropBottom, top: cropTop, near: -1, far: 1)
        var cropTransform = cropProjection * modelMatrix
        
        
        // 2. 创建裁剪目标纹理
        let cropPixelWidth = Int(cropRectInView.size.width * UIScreen.main.scale)
        let cropPixelHeight = Int(cropRectInView.size.height * UIScreen.main.scale)
        
        let outputDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                  width: cropPixelWidth,
                                                                  height: cropPixelHeight,
                                                                  mipmapped: false)
        outputDesc.usage = [.renderTarget, .shaderRead, .shaderWrite]
        guard let outputTexture = device.makeTexture(descriptor: outputDesc) else {
            return
        }
        
        guard let renderPassDescriptor = makeRenderPassDescriptor(for: outputTexture) else { return  }


        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            return
        }
        
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBytes(&cropTransform, length: MemoryLayout<float4x4>.size, index: 1)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: indexBuffer.length / MemoryLayout<UInt16>.stride,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer,
                                      indexBufferOffset: 0)
        encoder.endEncoding()
        self.saveTextureToFile(texture!, filename: "source.png")
        commandBuffer.addCompletedHandler { _ in
            self.saveTextureToFile(outputTexture, filename: "out.png")
            
        }
        
        commandBuffer.commit()
    }
    
    func makeRenderPassDescriptor(for texture: MTLTexture) -> MTLRenderPassDescriptor? {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        return descriptor
    }

}
