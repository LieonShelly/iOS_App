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
    var startScale: Float = 1.0
    var targetSacale: Float = 1.0
    var animationDuration: Float = 0.5
    var animationStartTime: CFTimeInterval = 0
    var displaylink: CADisplayLink?
    
    func zoom(factor: Float) {
        let newScale = scale * factor
        if newScale >= 0.1 && newScale <= 5.0 {
            scale = newScale
            updateVertices()
        }
    }
    
    func didEndDrag() {
        if scale < 1.0 {
            startScaleAnimation(newScale: 1.0)
        } else if scale > 3.0 {
            startScaleAnimation(newScale: 3.0)
        }
    }
    
    func prepan(deltaX: Float, deltaY: Float) {
        print("deltaX:\(deltaX) - deltaY:\(deltaY)")
        offsetX += deltaX
        offsetY += deltaY
        updateVertices()
    }
    
    
    func pan(deltaX: Float) {
        let sensitivityFactor = 1.0 / scale
        let adjustedDeltaX = deltaX * sensitivityFactor
        offsetX += adjustedDeltaX
        updateVertices()
    }
    
    func pan(deltaY: Float) {
        let sensitivityFactor = 1.0 / scale

        let adjustedDeltaY = deltaY * sensitivityFactor

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
        offsetX = 0.0
        offsetY = 0.0
        angle = 0.0
        angleX = 0.0
        angleY = 0
        startScaleAnimation(newScale: 1.0)
    }
    
    func startScaleAnimation(newScale: Float) {
        startScale = scale
        targetSacale = newScale
        animationStartTime = CACurrentMediaTime()
        
        displaylink?.invalidate()
        displaylink = CADisplayLink(target: self, selector: #selector(updateScaleAnimation))
        displaylink?.add(to: .main, forMode: .common)
    }
    
    @objc func updateScaleAnimation() {
        let curretTime = CACurrentMediaTime()
        let elapsed = Float(curretTime - animationStartTime)
        if elapsed >= animationDuration {
            scale = targetSacale
            displaylink?.invalidate()
            displaylink = nil
        } else {
            var progress = elapsed / animationDuration
            progress = AnimationCurve.easeInOut.apply(to: progress)
            scale = startScale + (targetSacale - startScale) * progress
            updateVertices()
            metalView.draw()
        }
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
        
        let imageAspect = Float(imageSize.width / imageSize.height)
        var cropLeft: Float = -1 * viewAspect
        var cropRight: Float = 1 * viewAspect
        var cropTop: Float = 1
        var cropBottom: Float = -1
        
        if imageAspect > viewAspect {
            cropLeft = -1
            cropRight = 1
            cropTop =  (1.0 / viewAspect)
            cropBottom = -(1.0 / viewAspect)
            
        }
        let cropProjection = float4x4(orthographicLeft: cropLeft, right: cropRight, bottom: cropBottom, top: cropTop, near: -1, far: 1)
        uniforms.transform = cropProjection * modelMatrix
        
        let metalPoint = currentVertices.map { uniforms.transform * SIMD4<Float>(Float($0.x), Float($0.y), 0, 1) }
        print("after transform metalPoint:\(metalPoint)")
    }
    
    
    
    func newCrop(_ cropRectInView: CGRect, completion: @escaping (Bool) -> Void) {
        let viewSize = metalView.drawableSize
        let cropRectInView = CGRect(x: cropRectInView.origin.x * UIScreen.main.nativeScale,
                                    y: cropRectInView.origin.y * UIScreen.main.nativeScale,
                                    width: cropRectInView.width * UIScreen.main.nativeScale,
                                    height: cropRectInView.height * UIScreen.main.nativeScale)
        // 1. 将 cropRect 从 UIKit 坐标转换为 Metal 坐标中心为 (0,0)
        let viewAspect: Float = Float(viewSize.width / viewSize.height)
        let imageAspect = Float(imageSize.width / imageSize.height)
        var cropLeft = (Float(cropRectInView.minX) / Float(viewSize.width)) * 2 * viewAspect - viewAspect
        var cropRight = (Float(cropRectInView.maxX) / Float(viewSize.width)) * 2 * viewAspect - viewAspect
        var cropTop = (1.0 - Float(cropRectInView.minY) / Float(viewSize.height)) * 2.0 - 1.0
        var cropBottom = (1.0 - Float(cropRectInView.maxY) / Float(viewSize.height)) * 2.0 - 1.0
        
        if imageAspect > viewAspect {
            cropLeft = (Float(cropRectInView.minX) / Float(viewSize.width)) * 2.0 - 1.0
            cropRight = (Float(cropRectInView.maxX) / Float(viewSize.width)) * 2.0 - 1.0
            cropTop = (1.0 - Float(cropRectInView.minY) / Float(viewSize.height)) * 2.0 * (1.0 / viewAspect) - (1.0 / viewAspect)
            cropBottom = (1.0 - Float(cropRectInView.maxY) / Float(viewSize.height)) * 2.0 * (1.0 / viewAspect) - (1.0 / viewAspect)
            
        }
        let cropProjection = float4x4(orthographicLeft: cropLeft, right: cropRight, bottom: cropBottom, top: cropTop, near: -1, far: 1)
        var cropTransform = cropProjection * modelMatrix
        
        
        // 2. 创建裁剪目标纹理
        let cropPixelWidth = Int(cropRectInView.size.width)
        let cropPixelHeight = Int(cropRectInView.size.height)
        
        let outputDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                  width: cropPixelWidth,
                                                                  height: cropPixelHeight,
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
        encoder.setVertexBytes(&cropTransform, length: MemoryLayout<float4x4>.size, index: 1)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: indexBuffer.length / MemoryLayout<UInt16>.stride,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer,
                                      indexBufferOffset: 0)
        encoder.endEncoding()
        
        commandBuffer.addCompletedHandler { _ in
            self.saveTextureToFile(outputTexture, filename: "cropped.png")
            completion(true)
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


