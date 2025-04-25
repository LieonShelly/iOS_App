//
//  CropRenderer.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/5.
//

import MetalKit
import Foundation
import CoreImage
import ImageIO
import UniformTypeIdentifiers

class MetalRenderer: NSObject, ObservableObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var texture: MTLTexture?
    let metalView: MTKView
    var currentVertices: [CGPoint] = []
    var imageSize: CGSize = .zero
    
    var uniforms: Uniforms = .init(transform: .identity, noTranslationT: .identity)
    
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
        commandEncoder?.setViewport(MTLViewport(originX: 0, originY: 0,
                                                width: Double(view.drawableSize.width),
                                              height: Double(view.drawableSize.height),
                                              znear: 0, zfar: 1))
        commandEncoder?.setRenderPipelineState(pipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func setupVertices(for imageSize: CGSize, in viewSize: CGSize) {
        print("setupVertices-imageSize:\(imageSize) - viewSize:\(viewSize)")
        let imageAspect = Float(imageSize.width / imageSize.height)
        let viewAspect = Float(viewSize.width / viewSize.height)

        // 在 Metal 坐标系下，View 是 [-1, 1]，我们用这个范围来计算图像显示区域
        var displayWidth: Float = 0
        var displayHeight: Float = 0

        if imageAspect > viewAspect {
            // 图像比视图宽 → 宽度对齐
            displayWidth = 2.0 // Metal 的 [-1, 1] 范围是 2 个单位宽
            displayHeight = displayWidth / imageAspect
        } else {
            // 图像比视图高 → 高度对齐
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

        print("quadVertices:\(currentVertices)")
        
        let indices: [UInt16] = [ 0, 1, 2,  2, 3, 0 ]  // 三角形索引

        vertexBuffer = device.makeBuffer(bytes: quadVertices, length: quadVertices.count * MemoryLayout<Float>.size, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
    }

    func getImageFrame(in viewSize: CGSize) -> CGRect {
        let metalPoint = currentVertices.map { uniforms.transform * SIMD4<Float>(Float($0.x), Float($0.y), 0, 1) }
            .map { vertex in
                SIMD4<Float>(vertex.x / vertex.w, vertex.y / vertex.w, vertex.z / vertex.w, vertex.w / vertex.w)
            }
        let screenVertices = metalPoint.map { vertex in
            CGPoint(
                x: (CGFloat(vertex.x) + 1) * viewSize.width / 2,
                y: (1 - CGFloat(vertex.y)) * viewSize.height / 2
            )
        }
        
        let minX = screenVertices.map { $0.x }.min() ?? 0
        let minY = screenVertices.map { $0.y }.min() ?? 0
        let maxX = screenVertices.map { $0.x }.max() ?? 0
        let maxY = screenVertices.map { $0.y }.max() ?? 0
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    
    func getImageExtent() -> float2 {
        let metalPoint = currentVertices.map { uniforms.noTranslationT * SIMD4<Float>(Float($0.x), Float($0.y), 0, 1) }
            .map { vertex in
                SIMD4<Float>(vertex.x / vertex.w, vertex.y / vertex.w, vertex.z / vertex.w, vertex.w / vertex.w)
            }
        let maxX = metalPoint.map { $0.x }.max() ?? 0
        let maxY = metalPoint.map { $0.y }.max() ?? 0
        
        return float2(maxX, maxY)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        if let texture = texture {
//             let imageSize = CGSize(width: texture.width, height: texture.height)
//             setupVertices(for: imageSize, in: size)
//         }
    }
    
    func saveTextureToFile(_ texture: MTLTexture, filename: String) {
        let width = texture.width
        let height = texture.height
        let bytesPerRow = width * 4 // 假设是RGBA格式
        
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        defer { data.deallocate() }
        
        texture.getBytes(
            data,
            bytesPerRow: bytesPerRow,
            from: MTLRegionMake2D(0, 0, width, height),
            mipmapLevel: 0
        )
        
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
}

extension CGRect {
    var rectInScreen: CGRect {
        CGRect(x: minX / UIScreen.main.nativeScale, y: minY / UIScreen.main.nativeScale, width: width / UIScreen.main.nativeScale, height: height / UIScreen.main.nativeScale)
    }
    
    var rectInMetal: CGRect {
        CGRect(x: minX * UIScreen.main.nativeScale, y: minY * UIScreen.main.nativeScale, width: width * UIScreen.main.nativeScale, height: height * UIScreen.main.nativeScale)
    }
}
