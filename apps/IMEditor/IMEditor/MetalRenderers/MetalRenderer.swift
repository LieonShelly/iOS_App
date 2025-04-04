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
        
        var scaleX: Float = 1.0
        var scaleY: Float = 1.0
        
        if imageAspect > viewAspect {
            scaleY = Float(viewAspect / imageAspect)
        } else {
            scaleX = Float(imageAspect / viewAspect)
        }
        
        let quadVertices: [Float] = [
            // 位置 (x, y)        纹理坐标 (u, v)
            -scaleX,  scaleY,    0.0, 0.0,  // 左上角
            -scaleX, -scaleY,    0.0, 1.0,  // 左下角
             scaleX, -scaleY,    1.0, 1.0,  // 右下角
             scaleX,  scaleY,    1.0, 0.0   // 右上角
        ]
        
        let indices: [UInt16] = [ 0, 1, 2,  2, 3, 0 ]  // 三角形索引

        vertexBuffer = device.makeBuffer(bytes: quadVertices, length: quadVertices.count * MemoryLayout<Float>.size, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
    }

    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        if let texture = texture {
             let imageSize = CGSize(width: texture.width, height: texture.height)
             setupVertices(for: imageSize, in: size)
         }
    }
}
