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
import SwiftUI

class CropRender: MetalRenderer {
    var scale: Float = 1
    var offsetX: Float = 0.0
    var offsetY: Float = 0.0
    var isCropped: Bool = false
    var angle: Float = 0.0
    var isHorizonMirror: Bool = false
    var modelMatrix: float4x4 = .identity
    var viewMatrix: float4x4 = .identity
    var perspective: float4x4 = .identity
    var shearX: Float = 1
    var angleY: Float = 0
    var angleX: Float = 0
    var cropPipelineState: MTLRenderPipelineState!
    var fullscreenQuadVB: MTLBuffer!
    
    override init() {
        super.init()
        let quad: [Float] = [
          -1,  1,     0,0,
          -1, -1,     0,0,
           1,  1,     0,0,
           1, -1,     0,0,
        ]
        fullscreenQuadVB = device.makeBuffer(bytes: quad, length: quad.count * MemoryLayout<Float>.size, options: [])
    }
    
    override func setupPipeline(_ view: MTKView) {
        super.setupPipeline(view)
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Error: Failed to load Metal shader library")
        }
        
        let vertexFunction = library.makeFunction(name: "cropVertext")
        let fragmentFunction = library.makeFunction(name: "cropFragment")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.vertexDescriptor = createVertexDescriptor() // 配置 MTLVertexDescriptor
        view.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        do {
            cropPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Error: Failed to create pipeline state - \(error)")
        }
        
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
        self.angle = angleRadians
        updateVertices()
    }
    
    func rotateY(_ angleRadians: Float) {
        self.angleY = angleRadians
        updateVertices()
    }
    
    func rotateX(_ angleRadians: Float) {
        self.angleX = angleRadians
        updateVertices()
    }
    
    func mirror() {
        self.isHorizonMirror = !isHorizonMirror
        updateVertices()
    }
    
    func shear(xAngle: Float) {
        self.shearX = xAngle
    }
    
    func resetTransform() {
        scale = 1.0
        offsetX = 0.0
        offsetY = 0.0
        angle = 0.0
        angleX = 0.0
        angleY = 0
        updateVertices()
    }
    
    private func updateVertices() {
        guard let texture = texture else { return }
        let imageSize = CGSize(width: texture.width, height: texture.height)
        let viewSize = metalView.drawableSize
        setupVertices(for: imageSize, in: viewSize)
    }
    
    override func setupVertices(for imageSize: CGSize, in viewSize: CGSize) {
        super.setupVertices(for: imageSize, in: viewSize)
        let viewAspect = Float(viewSize.width / viewSize.height)
        // ⬇️ 模型变换：缩放、旋转、平移
        let translation = float4x4(translationX: offsetX, translationY: offsetY)
        let scaleMatrix = float4x4(scaleX: scale, scaleY: scale)
        let zRotationMatrix = float4x4(angleZ: angle)
        let yRotationMatrix = float4x4(angleY: angleY)
        let XRotationMatrix = float4x4(angleX: angleX)
        let rotationMatrix = zRotationMatrix * yRotationMatrix * XRotationMatrix
        let mirrorMatrix = float4x4(mirrorX: isHorizonMirror, mirrorY: false)

        self.modelMatrix = rotationMatrix * scaleMatrix * translation * mirrorMatrix
        
        viewMatrix = float4x4(eye: .init(x: 0, y: 0, z: -2), center: .zero, up: .init(x: 0, y: 1, z: 0))
        
        let perspective = float4x4(perspectiveFov: Float(Angle(degrees: 70).radians), aspect: viewAspect, near: 1, far: 2000)
        
        uniforms.transform = perspective * viewMatrix * modelMatrix
        
        let metalPoint = currentVertices.map { uniforms.transform * SIMD4<Float>(Float($0.x), Float($0.y), 0, 1) }
        print("after transform metalPoint:\(metalPoint)")
    }
    
    func newCrop(_ cropRectInView: CGRect, completion: @escaping (Bool) -> Void) {
        let viewSize = metalView.drawableSize
        let cropRectInView = CGRect(x: cropRectInView.origin.x * UIScreen.main.nativeScale,
                                    y: cropRectInView.origin.y * UIScreen.main.nativeScale,
                                    width: cropRectInView.width * UIScreen.main.nativeScale,
                                    height: cropRectInView.height * UIScreen.main.nativeScale)
        
        
        // 2. 创建裁剪目标纹理
        let offScreenWidth = Int(viewSize.width)
        let offScreenHeight = Int(viewSize.height)
        
        let outputDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                  width: offScreenWidth,
                                                                  height: offScreenHeight,
                                                                  mipmapped: false)
        outputDesc.usage = [.renderTarget, .shaderRead, .shaderWrite]
        guard let outputTexture = device.makeTexture(descriptor: outputDesc) else {
            completion(false)
            return
        }
        
        guard let renderPassDescriptor = makeRenderPassDescriptor(for: outputTexture) else { 
            completion(false)
            return  
        }


        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            completion(false)
            return
        }
        
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBytes(&uniforms.transform, length: MemoryLayout<float4x4>.size, index: 1)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: indexBuffer.length / MemoryLayout<UInt16>.stride,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer,
                                      indexBufferOffset: 0)
        encoder.endEncoding()
        
        commandBuffer.addCompletedHandler { _ in
            self.saveTextureToFile(outputTexture, filename: "offscreen.png")
            self.copTexture(cropRectInMetal: cropRectInView, source: outputTexture)
            completion(true)
        }
        
        commandBuffer.commit()
    }
    
    func copTexture(cropRectInMetal: CGRect, source: any MTLTexture) {
        let viewSize = metalView.drawableSize
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        let pxX = Int(cropRectInMetal.minX)
        let pxY = Int(cropRectInMetal.minY)
        let pxW = Int(cropRectInMetal.width)
        let pxH = Int(cropRectInMetal.height)
        
        let croppedDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                   width: Int(cropRectInMetal.width),
                                                                   height: Int(cropRectInMetal.height),
                                                                  mipmapped: false)
        croppedDesc.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        guard let croppedTexture = device.makeTexture(descriptor: croppedDesc) else {
            return
        }
        
        let blit = commandBuffer.makeBlitCommandEncoder()
        let origin = MTLOrigin(x: pxX, y: pxY, z: 0)
        let size   = MTLSize( width: pxW, height: pxH, depth: 1 )
        blit?.copy(
            from: source,
            sourceSlice: 0,
            sourceLevel: 0,
            sourceOrigin: origin,
            sourceSize: size,
            to: croppedTexture,
            destinationSlice: 0,
            destinationLevel: 0,
            destinationOrigin: .init(x: 0, y: 0, z: 0)
        )
        blit?.endEncoding()
        commandBuffer.addCompletedHandler { _ in
            self.saveTextureToFile(croppedTexture, filename: "croppedTexture.png")
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
    
    func newerCrop(_ cropRectInView: CGRect, completion: @escaping (Bool) -> Void) {
        let cropRectInView = CGRect(x: cropRectInView.origin.x * UIScreen.main.nativeScale,
                                    y: cropRectInView.origin.y * UIScreen.main.nativeScale,
                                    width: cropRectInView.width * UIScreen.main.nativeScale,
                                    height: cropRectInView.height * UIScreen.main.nativeScale)
        
        let viewSize = metalView.drawableSize
        let w = Float(viewSize.width)
        let h = Float(viewSize.height)

        // 1) pixel → normalized [0…1]
        let u0 = Float(cropRectInView.minX) / w
        let v0 = Float(cropRectInView.minY) / h
        let u1 = Float(cropRectInView.maxX) / w
        let v1 = Float(cropRectInView.maxY) / h

        // 2) normalized → NDC [–1…+1]
        let cropLeft   =  u0*2 - 1
        let cropRight  =  u1*2 - 1
        let cropBottom =  1 - v1*2   // flip Y because screen Y=0 is top
        let cropTop    =  1 - v0*2

        // Now your quad vertex positions (in NDC) become:
        let quad: [Float] = [
          //   x,           y,    padX, padY
            cropLeft,  cropTop,    0,    0,
            cropLeft,  cropBottom, 0,    0,
            cropRight, cropTop,    0,    0,
            cropRight, cropBottom, 0,    0,
        ]
        fullscreenQuadVB = device.makeBuffer(bytes: quad,
                                         length: quad.count * MemoryLayout<Float>.size,
                                         options: [])
        
        let scale = UIScreen.main.nativeScale
        let pxRect = CGRect(x: cropRectInView.origin.x * scale, y: cropRectInView.origin.y * scale,
                            width: cropRectInView.width * scale, height: cropRectInView.height * scale)
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: Int(pxRect.width), height: Int(pxRect.height), mipmapped: false)
        desc.usage = [.renderTarget, .shaderRead]
        guard let outTex = device.makeTexture(descriptor: desc), let passDesc = makeRenderPassDescriptor(for: outTex) else { return }
        
        guard let cmdBuf = commandQueue.makeCommandBuffer(), let encoder = cmdBuf.makeRenderCommandEncoder(descriptor: passDesc) else { return }
        
        encoder.setRenderPipelineState(cropPipelineState) // 传入cropPipelineState
        encoder.setVertexBuffer(fullscreenQuadVB, offset: 0, index: 0)
        
        var inv = uniforms.transform.inverse
        encoder.setVertexBytes(&inv, length: MemoryLayout<float4x4>.stride, index: 1)
        encoder.setFragmentTexture(texture!, index: 0)
        encoder.setFragmentBytes(&inv, length: MemoryLayout<float4x4>.stride, index: 1)
        
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()
        
        cmdBuf.addCompletedHandler { _ in
            self.saveTextureToFile(outTex, filename: "newerCrop.png")
        }
        cmdBuf.commit()
        
    }

}
