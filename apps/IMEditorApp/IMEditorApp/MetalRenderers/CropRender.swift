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

class CropRender: MetalRenderer {
    var scale: Float = 1
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
    }
    
    // 更新顶点缓冲区
    private func updateVertices() { }

    // 保存纹理为图片文件（用于调试）
    func saveTextureToFile(_ texture: MTLTexture, filename: String) {
        let width = texture.width
        let height = texture.height
        let bytesPerRow = width * 4 // 假设是RGBA格式
        
        // 创建缓冲区来存储纹理数据
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        defer { data.deallocate() }
        
        // 从纹理读取数据
        texture.getBytes(
            data,
            bytesPerRow: bytesPerRow,
            from: MTLRegionMake2D(0, 0, width, height),
            mipmapLevel: 0
        )
        
        // 创建CGImage
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            print("Failed to create CGContext")
            return
        }
        
        guard let cgImage = context.makeImage() else {
            print("Failed to create CGImage")
            return
        }
        
        // 保存为PNG文件
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        if let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) {
            CGImageDestinationAddImage(destination, cgImage, nil)
            if CGImageDestinationFinalize(destination) {
                print("Image saved to: \(url.path)")
            } else {
                print("Failed to save image")
            }
        }
    }

    // 裁剪图像
    func cropImage(fromX: Int, fromY: Int, width: Int, height: Int, completion: @escaping (Bool) -> Void) {
        guard let sourceTexture = texture else {
            completion(false)
            return
        }
        
        // 保存源纹理用于调试
        saveTextureToFile(sourceTexture, filename: "source_texture.png")
        
        // 确保裁剪区域在有效范围内
        let validFromX = max(0, min(fromX, sourceTexture.width - 1))
        let validFromY = max(0, min(fromY, sourceTexture.height - 1))
        let validWidth = min(width, sourceTexture.width - validFromX)
        let validHeight = min(height, sourceTexture.height - validFromY)
        
        print("Crop region: x=\(validFromX), y=\(validFromY), width=\(validWidth), height=\(validHeight)")
        
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
