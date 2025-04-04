//
//  MetalRenderer.swift
//  IMEditor
//
//  Created by Renjun Li on 2025/4/4.
//

import MetalKit

class MetalRenderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var texture: MTLTexture?
    
    // 缩放和平移属性
    var scale: Float = 1.0
    var offsetX: Float = 0.0
    var offsetY: Float = 0.0
    
    // 记录图像原始尺寸和显示尺寸
    private var imageSize: CGSize = .zero
    private var displaySize: CGSize = .zero
    
    // 是否显示裁剪后的图像
    var isCropped: Bool = false
    
    init(mtkView: MTKView) {
        super.init()
        self.device = MTLCreateSystemDefaultDevice()
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.delegate = self
        commandQueue = device.makeCommandQueue()
        setupPipeline(mtkView) // 2️⃣ 配置 Metal 渲染管线
        loadTexture()           // 3️⃣ 加载图片纹理
    }
    
    // 2️⃣ 配置 Metal 渲染管线
    func setupPipeline(_ view: MTKView) {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Error: Failed to load Metal shader library")
        }
        
        let vertexFunction = library.makeFunction(name: "vertexShader")
        let fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.vertexDescriptor = createVertexDescriptor() // 配置 MTLVertexDescriptor
        view.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Error: Failed to create pipeline state - \(error)")
        }
    }
    
    // 3️⃣ 设置 MTLVertexDescriptor
    func createVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2  // 位置 (x, y)
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        vertexDescriptor.attributes[1].format = .float2  // 纹理坐标 (u, v)
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 2
        vertexDescriptor.attributes[1].bufferIndex = 0

        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 4
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        
        return vertexDescriptor
    }
    
    // 4️⃣ 加载图片纹理
    func loadTexture() {
        guard let image = UIImage(named: "test.png")?.cgImage else {
            print("Failed to load test.png")
            return
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        do {
            texture = try textureLoader.newTexture(cgImage: image, options: nil)
            if let texture = texture {
                imageSize = CGSize(width: texture.width, height: texture.height)
            }
            print("Texture loaded successfully!")  // Debug log
        } catch {
            print("Failed to load texture: \(error)")
        }
    }
    
    // 5️⃣ 渲染
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let texture = texture else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        commandEncoder?.setRenderPipelineState(pipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func setupVertices(for imageSize: CGSize, in viewSize: CGSize) {
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        
        // 计算左右两侧各20pt的间距对应的规范化坐标
        let padding: CGFloat = 20.0
        let paddingRatio = (padding * 2) / viewSize.width
        let maxWidth = 1.0 - paddingRatio
        
        var scaleX: Float = Float(maxWidth)
        var scaleY: Float = 1.0
        
        let effectiveViewAspect = viewSize.width * (1.0 - paddingRatio) / viewSize.height
        
        if imageAspect > effectiveViewAspect {
            // 图像宽度适应屏幕宽度减去padding
            scaleY = Float(effectiveViewAspect / imageAspect)
        } else {
            // 图像高度适应屏幕高度
            scaleX = Float(imageAspect / viewAspect * maxWidth)
        }
        
        // 保存显示尺寸
        self.displaySize = CGSize(width: Double(scaleX * 2), height: Double(scaleY * 2))
        
        // 应用缩放和偏移
        let zoomedScaleX = scaleX * scale
        let zoomedScaleY = scaleY * scale
        
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

    // 获取图像实际显示区域
    func getImageFrame(in viewSize: CGSize) -> CGRect {
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        
        // 计算左右两侧各20pt的间距
        let padding: CGFloat = 20.0
        let maxWidth = viewSize.width - padding * 2
        
        var displayWidth: CGFloat = maxWidth
        var displayHeight: CGFloat = viewSize.height
        
        let effectiveViewAspect = maxWidth / viewSize.height
        
        if imageAspect > effectiveViewAspect {
            // 图像宽度适应屏幕宽度减去padding
            displayHeight = maxWidth / imageAspect
        } else {
            // 图像高度适应屏幕高度
            displayWidth = imageAspect * viewSize.height
            if displayWidth > maxWidth {
                displayWidth = maxWidth
                displayHeight = displayWidth / imageAspect
            }
        }
        
        let x = (viewSize.width - displayWidth) / 2
        let y = (viewSize.height - displayHeight) / 2
        
        return CGRect(x: x, y: y, width: displayWidth, height: displayHeight)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        if let texture = texture {
             let imageSize = CGSize(width: texture.width, height: texture.height)
             setupVertices(for: imageSize, in: size)
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
