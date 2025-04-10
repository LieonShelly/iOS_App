//
//  CropRender.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/10.
//
import MetalKit
import Foundation


class CropRender: MetalRenderer {
    var scale: Float = 1
    var offsetX: Float = 0.0
    var offsetY: Float = 0.0

    private var displaySize: CGSize = .zero
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
        if newScale >= 1.0 && newScale <= 5.0 {
            scale = newScale
            updateVertices()
        }
    }
    
    // 平移图像
    func pan(deltaX: Float, deltaY: Float) {
        // 计算最大偏移量，确保不会将图像移出视图太多
        let maxOffsetX = scale - 1.0
        let maxOffsetY = scale - 1.0
        
        offsetX += deltaX
        offsetY += deltaY
        
        // 限制偏移范围
        offsetX = max(-maxOffsetX, min(maxOffsetX, offsetX))
        offsetY = max(-maxOffsetY, min(maxOffsetY, offsetY))
        
        updateVertices()
    }
    
    // 重置缩放和平移
    func resetTransform() {
        scale = 1.0
        offsetX = 0.0
        offsetY = 0.0
        updateVertices()
    }
    
    // 更新顶点缓冲区
    private func updateVertices() {
        if let texture = texture {
            let imageSize = CGSize(width: texture.width, height: texture.height)
            // 使用上次保存的视图大小或默认值
            let viewSize = displaySize != .zero ?
                          CGSize(width: displaySize.width * 2, height: displaySize.height * 2) :
                          CGSize(width: 2, height: 2) // 默认归一化坐标系
            setupVertices(for: imageSize, in: viewSize)
        }
    }


    // 裁剪图像
    func cropImage(fromX: Int, fromY: Int, width: Int, height: Int, completion: @escaping (Bool) -> Void) {
        guard let sourceTexture = texture else {
            completion(false)
            return
        }
        
        // 确保裁剪区域在有效范围内
        let validFromX = max(0, min(fromX, sourceTexture.width - 1))
        let validFromY = max(0, min(fromY, sourceTexture.height - 1))
        let validWidth = min(width, sourceTexture.width - validFromX)
        let validHeight = min(height, sourceTexture.height - validFromY)
        
        // 创建目标纹理描述符
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: sourceTexture.pixelFormat,
            width: validWidth,
            height: validHeight,
            mipmapped: false
        )
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
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
                self?.texture = croppedTexture
                self?.imageSize = CGSize(width: validWidth, height: validHeight)
                self?.resetTransform()
                self?.isCropped = true
                completion(true)
            }
        }
        
        // 提交命令缓冲区
        commandBuffer.commit()
    }
}
