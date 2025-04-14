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

    override func setupVertices(for imageSize: CGSize, in viewSize: CGSize) {
        let viewSize = CGSize(width: viewSize.width, height: viewSize.height)
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        
        var displayWidth: CGFloat = viewSize.width
        var displayHeight: CGFloat = viewSize.height
        
        if imageAspect > viewAspect {
            displayHeight = viewSize.width / imageAspect
        } else {
            displayWidth = viewSize.height * imageAspect
        }
        
        // ⬇️ 模型变换：缩放、旋转、平移
        let scaleX = Float(displayWidth) * scale
        let scaleY = Float(displayHeight) * scale
        let scaleMatrix = Martrix.scaleMartrix(scaleX: scaleX, scaleY: scaleY)
        let rotationMatrix = Martrix.rotationMartrix(angle)
        let translationMatrix = Martrix.translationMartrix(tx: offsetX, ty: offsetY)
        let modelMatrix = translationMatrix * rotationMatrix * scaleMatrix
        
        // ⬇️ 正交投影矩阵：从屏幕空间映射到 Metal 的 NDC 空间（-1 ~ 1）
        let projectionMatrix = float3x3(orthographic: CGRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height), near: -1, far: 1)
        let transform = projectionMatrix * modelMatrix
        
        let halfW: Float = 0.5
        let halfH: Float = 0.5
        
        let topLeft = transform * SIMD3<Float>(-halfW,  halfH, 1)
        let bottomLeft = transform * SIMD3<Float>(-halfW, -halfH, 1)
        let bottomRight = transform * SIMD3<Float>( halfW, -halfH, 1)
        let topRight = transform * SIMD3<Float>( halfW,  halfH, 1)
       
        currentVertices = [
            CGPoint(x: CGFloat(topLeft.x), y: CGFloat(topLeft.y)),
            CGPoint(x: CGFloat(bottomLeft.x), y: CGFloat(bottomLeft.y)),
            CGPoint(x: CGFloat(bottomRight.x), y: CGFloat(bottomRight.y)),
            CGPoint(x: CGFloat(topRight.x), y: CGFloat(topRight.y))
        ]

        let quadVertices: [Float] = [
            topLeft.x,     topLeft.y,     0.0, 0.0,
            bottomLeft.x,  bottomLeft.y,  0.0, 1.0,
            bottomRight.x, bottomRight.y, 1.0, 1.0,
            topRight.x,    topRight.y,    1.0, 0.0
        ]
        
        let indices: [UInt16] = [ 0, 1, 2,  2, 3, 0 ]  // 三角形索引

        vertexBuffer = device.makeBuffer(bytes: quadVertices, length: quadVertices.count * MemoryLayout<Float>.size, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
    }
    
    func zoom(factor: Float) {
        let newScale = scale * factor
        if newScale >= 0.1 && newScale <= 5.0 {
            scale = newScale
            updateVertices()
        }
    }
    
    func pan(deltaX: Float, deltaY: Float) {
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
            CGSize(width: canvasSize.width * 2, height: canvasSize.height * 2)
        setupVertices(for: imageSize, in: viewSize)
    }

    func crop(_ cropRectInMetal: CGRect,  completion: @escaping (Bool) -> Void) {
        guard let sourceTexture = texture else { return }
        let minX = currentVertices.map {$0.x}.min()!
        let maxX = currentVertices.map {$0.x}.max()!
        let minY = currentVertices.map {$0.y}.min()!
        let maxY = currentVertices.map {$0.y}.max()!
        let imageRectInMetal = CGRect(x: minX, y: maxY, width: maxX - minX, height: maxY - minY)
        let relativeX = (cropRectInMetal.origin.x - imageRectInMetal.origin.x) / imageRectInMetal.width
        let relativeY = abs(cropRectInMetal.origin.y - imageRectInMetal.origin.y) / imageRectInMetal.height
        let relativeW = cropRectInMetal.width / imageRectInMetal.width
        let relativehH = cropRectInMetal.height / imageRectInMetal.height
     
        let validFromX = max(0, min(Int(Float(relativeX) * Float(sourceTexture.width)), sourceTexture.width - 1))
        let validFromY = max(0, min(Int(Float(relativeY) * Float(sourceTexture.height)), sourceTexture.height - 1))
        let validWidth = min(Int(Float(relativeW) * Float(sourceTexture.width)), sourceTexture.width - validFromX)
        let validHeight = min(Int(Float(relativehH) * Float(sourceTexture.height)), sourceTexture.height - validFromY)
        
        let region = MTLRegion(
            origin: MTLOrigin(x: validFromX,
                              y: validFromY,
                              z: 0),
            size: MTLSize(width: validWidth,
                          height: validHeight,
                          depth: 1)
        )
        
        // 创建目标纹理描述符
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: sourceTexture.pixelFormat,
            width: validWidth,
            height: validHeight,
            mipmapped: false
        )
        
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        textureDescriptor.storageMode = .shared
        
        guard let croppedTexture = device.makeTexture(descriptor: textureDescriptor) else {
            completion(false)
            return
        }
        
        // 创建命令缓冲区
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            completion(false)
            return
        }
        
        // 创建裁剪区域
        
        // 创建Blit编码器用于复制纹理区域
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            completion(false)
            return
        }
        
        // 复制源纹理的一部分到目标纹理
        blitEncoder.copy(
            from: sourceTexture,
            sourceSlice: 0,
            sourceLevel: 0,
            sourceOrigin: region.origin,
            sourceSize: region.size,
            to: croppedTexture,
            destinationSlice: 0,
            destinationLevel: 0,
            destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0)
        )
        
        blitEncoder.endEncoding()
        
        // 完成命令缓冲区并设置完成回调
        commandBuffer.addCompletedHandler { [weak self] _ in
            DispatchQueue.main.async {
                // 保存裁剪后的纹理用于调试
                self?.saveTextureToFile(croppedTexture, filename: "cropped_texture.png")
                
                // 确保在设置新纹理之前清除旧纹理
                self?.texture = nil
                self?.texture = croppedTexture
                self?.imageSize = CGSize(width: validWidth, height: validHeight)
                // 重置变换
                self?.resetTransform()
                self?.isCropped = true
                completion(true)
            }
        }
        
        // 提交命令缓冲区
        commandBuffer.commit()
        
        // 等待命令缓冲区完成
        commandBuffer.waitUntilCompleted()
    }
}
