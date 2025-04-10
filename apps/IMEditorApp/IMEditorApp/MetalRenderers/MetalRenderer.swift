//
//  CropRenderer.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/5.
//

import MetalKit
import Foundation

class MetalRenderer: NSObject, ObservableObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var texture: MTLTexture?
    let metalView: MTKView
    var currentVertices: [CGPoint] = []
    var canvasSize: CGSize = .zero
    var imageSize: CGSize = .zero
    
    override init() {
        self.device = MTLCreateSystemDefaultDevice()
        metalView = MTKView(frame: .zero, device: device)
        metalView.device = device
        metalView.colorPixelFormat = .bgra8Unorm
        commandQueue = device.makeCommandQueue()
        super.init()
        metalView.delegate = self
        setupPipeline(metalView)
    }
    
    func updateCanvasSize(_ size: CGSize) {
        self.canvasSize = CGSize(width: size.width, height: size.height)
    }
    
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
    
    func display(in viewSize: CGSize) {
        guard let texture else { return }
        let imageSize = CGSize(width: texture.width, height: texture.height)
        setupVertices(for: imageSize, in: viewSize)
    }
    
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
        
        print("normalizedScaleX:\(normalizedScaleX) - normalizedScaleY:\(normalizedScaleY)")
        
        // 应用当前的缩放和平移
        let zoomedScaleX: Float = normalizedScaleX
        let zoomedScaleY: Float = normalizedScaleY
        
        // 保存当前顶点坐标（归一化坐标系）
        currentVertices = [
            CGPoint(x: CGFloat(-zoomedScaleX), y: CGFloat(zoomedScaleY)),     // 左上角
            CGPoint(x: CGFloat(-zoomedScaleX), y: CGFloat(-zoomedScaleY)),    // 左下角
            CGPoint(x: CGFloat(zoomedScaleX), y: CGFloat(-zoomedScaleY)),     // 右下角
            CGPoint(x: CGFloat(zoomedScaleX ), y: CGFloat(zoomedScaleY))       // 右上角
        ]
        
        // 创建顶点数据（位置 + 纹理坐标）
        let quadVertices: [Float] = [
            // 位置 (x, y)                    纹理坐标 (u, v)
            -zoomedScaleX,  zoomedScaleY,    0.0, 0.0,  // 左上角
            -zoomedScaleX, -zoomedScaleY,    0.0, 1.0,  // 左下角
             zoomedScaleX, -zoomedScaleY,    1.0, 1.0,  // 右下角
             zoomedScaleX,  zoomedScaleY,    1.0, 0.0   // 右上角
        ]
        
        let indices: [UInt16] = [ 0, 1, 2,  2, 3, 0 ]  // 三角形索引

        vertexBuffer = device.makeBuffer(bytes: quadVertices, length: quadVertices.count * MemoryLayout<Float>.size, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
    }

    func getImageFrame(in viewSize: CGSize) -> CGRect {
        // 使用保存的当前顶点坐标
        let screenVertices = currentVertices.map { vertex in
            CGPoint(
                x: (vertex.x + 1) * viewSize.width / 2,
                y: (1 - vertex.y) * viewSize.height / 2
            )
        }
        
        // 计算边界框
        let minX = screenVertices.map { $0.x }.min() ?? 0
        let minY = screenVertices.map { $0.y }.min() ?? 0
        let maxX = screenVertices.map { $0.x }.max() ?? 0
        let maxY = screenVertices.map { $0.y }.max() ?? 0
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        if let texture = texture {
//             let imageSize = CGSize(width: texture.width, height: texture.height)
//             setupVertices(for: imageSize, in: size)
//         }
    }
}
