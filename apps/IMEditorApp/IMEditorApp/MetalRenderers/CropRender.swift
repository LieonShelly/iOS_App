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
    var scale: Float = 1.0
    var offsetX: Float = 0.0
    var offsetY: Float = 0.0
    var isCropped: Bool = false
    

    override  func setupVertices(for imageSize: CGSize, in viewSize: CGSize) {
        let viewSize = CGSize(width: viewSize.width, height: viewSize.height)
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        
        // 计算图像在画布中的显示尺寸
        var displayWidth: CGFloat = viewSize.width
        var displayHeight: CGFloat = viewSize.height
        
        if imageAspect > viewAspect {
            // 图像比视图更宽，以宽度为基准
            displayHeight = viewSize.width / imageAspect
        } else {
            // 图像比视图更高，以高度为基准
            displayWidth = viewSize.height * imageAspect
        }
        
        // 计算归一化坐标系中的缩放因子
        let normalizedScaleX = Float(displayWidth / canvasSize.width)
        let normalizedScaleY = Float(displayHeight / canvasSize.height)
        
        
        // 应用当前的缩放和平移
        let zoomedScaleX = normalizedScaleX * scale
        let zoomedScaleY = normalizedScaleY * scale
        
        // 保存当前顶点坐标（归一化坐标系）
        currentVertices = [
            CGPoint(x: CGFloat(-zoomedScaleX + offsetX), y: CGFloat(zoomedScaleY + offsetY)),     // 左上角
            CGPoint(x: CGFloat(-zoomedScaleX + offsetX), y: CGFloat(-zoomedScaleY + offsetY)),    // 左下角
            CGPoint(x: CGFloat(zoomedScaleX + offsetX), y: CGFloat(-zoomedScaleY + offsetY)),     // 右下角
            CGPoint(x: CGFloat(zoomedScaleX + offsetX), y: CGFloat(zoomedScaleY + offsetY))       // 右上角
        ]
        
        // 创建顶点数据（位置 + 纹理坐标）
        let quadVertices: [Float] = [
            // 位置 (x, y)                    纹理坐标 (u, v)
            -zoomedScaleX + offsetX,  zoomedScaleY + offsetY,    0.0, 0.0,  // 左上角
            -zoomedScaleX + offsetX, -zoomedScaleY + offsetY,    0.0, 1.0,  // 左下角
             zoomedScaleX + offsetX, -zoomedScaleY + offsetY,    1.0, 1.0,  // 右下角
             zoomedScaleX + offsetX,  zoomedScaleY + offsetY,    1.0, 0.0   // 右上角
        ]
        
        let indices: [UInt16] = [ 0, 1, 2,  2, 3, 0 ]  // 三角形索引

        vertexBuffer = device.makeBuffer(bytes: quadVertices, length: quadVertices.count * MemoryLayout<Float>.size, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
    }
    
    // 缩放图像
    func zoom(factor: Float) {
        let newScale = scale * factor
        // 限制缩放范围
        if newScale >= 0.1 && newScale <= 5.0 {
            scale = newScale
            updateVertices()
        }
    }
    
    // 平移图像
    func pan(deltaX: Float, deltaY: Float) {
        print("deltaX:\(deltaX) - deltaY:\(deltaY)")
        let sensitivityFactor = 1.0 / scale
        
        let adjustedDeltaX = deltaX * sensitivityFactor
        let adjustedDeltaY = deltaY * sensitivityFactor
        
        offsetX += adjustedDeltaX
        offsetY += adjustedDeltaY
        
        // 更新顶点
        updateVertices()
    }
    
    // 重置缩放和平移
    func resetTransform() {
        scale = 1.0
        offsetX = 0.0
        offsetY = 0.0
    }
    
    // 更新顶点缓冲区
    private func updateVertices() {
        guard let texture = texture else { return }
        let imageSize = CGSize(width: texture.width, height: texture.height)
        
        // 使用当前显示尺寸或合理的默认值
        let viewSize = displaySize != .zero ? 
            displaySize : 
            CGSize(width: canvasSize.width * 2, height: canvasSize.height * 2)
        
        // 重新计算顶点
        setupVertices(for: imageSize, in: viewSize)
    }

    // 裁剪图像
    func cropImage(fromX: Int, fromY: Int, width: Int, height: Int, completion: @escaping (Bool) -> Void) {
        guard let sourceTexture = texture else {
            completion(false)
            return
        }
        
        // 考虑缩放和平移因素，重新计算真实的裁剪区域
        let imageWidth = sourceTexture.width
        let imageHeight = sourceTexture.height
        
        let normalizedFromX = (Float(fromX) / Float(imageWidth)) * 2.0 - 1.0
        let normalizedFromY = 1.0 - (Float(fromY) / Float(imageHeight)) * 2.0

        let adjustedNormalizedFromX = (normalizedFromX - offsetX) / scale
        let adjustedNormalizedFromY = (normalizedFromY - offsetY) / scale
        
        let adjustedFromX = Int(((adjustedNormalizedFromX + 1.0) / 2.0) * Float(imageWidth))
        let adjustedFromY = Int(((1.0 - adjustedNormalizedFromY) / 2.0) * Float(imageHeight))
        
        let adjustedWidth = Int(Float(width) / scale)
        let adjustedHeight = Int(Float(height) / scale)
        
        let validFromX = max(0, min(adjustedFromX, sourceTexture.width - 1))
        let validFromY = max(0, min(adjustedFromY, sourceTexture.height - 1))
        let validWidth = min(adjustedWidth, sourceTexture.width - validFromX)
        let validHeight = min(adjustedHeight, sourceTexture.height - validFromY)
        
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
        let region = MTLRegion(
            origin: MTLOrigin(x: validFromX, y: validFromY, z: 0),
            size: MTLSize(width: validWidth, height: validHeight, depth: 1)
        )
        
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

    // 根据裁剪框位置更新图像位置
    func updateImagePosition(for cropRect: CGRect, in viewSize: CGSize) {
        guard let texture = texture else { return }
        
        // 获取图像在视图中的显示尺寸
        let imageSize = CGSize(width: texture.width, height: texture.height)
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        
        // 计算图像在视图中的实际显示尺寸
        var displayWidth: CGFloat = viewSize.width
        var displayHeight: CGFloat = viewSize.height
        
        if imageAspect > viewAspect {
            displayHeight = viewSize.width / imageAspect
        } else {
            displayWidth = viewSize.height * imageAspect
        }
        
        // 计算图像在视图中的实际位置（居中显示）
        let imageX = (viewSize.width - displayWidth) / 2
        let imageY = (viewSize.height - displayHeight) / 2
        
        // 计算裁剪框在图像坐标系中的位置（相对于图像左上角）
        let cropInImageX = (cropRect.minX - imageX) / displayWidth
        let cropInImageY = (cropRect.minY - imageY) / displayHeight
        
        // 计算裁剪框中心在图像坐标系中的位置（归一化到[0,1]范围）
        let cropCenterInImageX = cropInImageX + (cropRect.width / displayWidth) / 2
        let cropCenterInImageY = cropInImageY + (cropRect.height / displayHeight) / 2
        
        // 计算需要移动的距离，使裁剪框内容居中
        // 由于裁剪框中心应该在视图中心(0,0)，所以需要移动的距离就是裁剪框中心的负值
        offsetX = -Float(cropCenterInImageX * 2 - 1)
        offsetY = -Float(cropCenterInImageY * 2 - 1)
        
        // 更新顶点
        setupVertices(for: imageSize, in: viewSize)
    }

    
}
