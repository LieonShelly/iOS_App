//
//  Martrix.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/13.
//

import simd
import Foundation
import CoreGraphics

enum Matrix {
    static func screenToMetalMartrix(_ screenSize: CGSize) -> float3x3 {
         let sx = 2.0 / Float(screenSize.width)
         let sy = -2.0 / Float(screenSize.height)
         
         let tx: Float = -1.0
         let ty: Float = 1.0
        let scale = float3x3(
            [sx, 0, 0],
            [0, sy, 0],
            [0, 0, 1]
        )
        let translation = float3x3(
            [1, 0, 0],
            [0, 1, 0],
            [tx, ty, 1]
            
        )
        return translation * scale
     }
    
    static func metalToScreen(_ screenSize: CGSize) -> float3x3 {
        screenToMetalMartrix(screenSize).inverse
    }
    
    static func screenToMetalDeltaMartrix(_ screenSize: CGSize) -> float3x3 {
        let sx = 2.0 / Float(screenSize.width)
        let sy = -2.0 / Float(screenSize.height)
        let scale = float3x3(
            [sx, 0, 0],
            [0, sy, 0],
            [0, 0, 1]
        )
        return scale
    }
    
    static func rotationMartrix(_ radians: Float) -> float3x3 {
        let cosA = cos(radians)
        let sinA = sin(radians)
        return float3x3(
            [cosA, sinA, 0],
            [-sinA, cosA, 0],
            [0, 0 , 1]
        )
    }
    
    static func scaleMartrix(_ scale: Float) -> float3x3 {
        let sx = scale
        let sy = scale
        let scale = float3x3(
            [sx, 0, 0],
            [0, sy, 0],
            [0, 0, 1]
        )
        return scale
    }
    
    static func scaleMartrix(scaleX: Float, scaleY: Float) -> float3x3 {
        let sx = scaleX
        let sy = scaleY
        let scale = float3x3(
            [sx, 0, 0],
            [0, sy, 0],
            [0, 0, 1]
        )
        return scale
    }
    
    static func translationMartrix(tx: Float, ty: Float) -> float3x3 {
        let translation = float3x3(
            [1, 0, 0],
            [0, 1, 0],
            [tx, ty, 1]
        )
        return translation
    }
}


extension float3x3 {
    init(scaleX: Float, scaleY: Float) {
        self = float3x3(
            [scaleX, 0, 0],
            [0, scaleY, 0],
            [0, 0, 1]
        )
    }
}

extension float3x3 {
    static func orthographic(width: Float, height: Float) -> float3x3 {
        // 映射 [0, width] -> [-1, 1]， [0, height] -> [-1, 1]
        let scaleX: Float = 2.0 / width
        let scaleY: Float = 2.0 / height

        return float3x3(rows: [
            SIMD3<Float>(scaleX,     0,        0),
            SIMD3<Float>(0,     scaleY,        0),
            SIMD3<Float>(-1,       -1,         1)  // 原点从左上角移到中心
        ])
    }
    
    init(orthographic rect: CGRect, near: Float, far: Float) {
        let left = Float(rect.origin.x)
        let right = Float(rect.origin.x + rect.width)
        let top = Float(rect.origin.y)
        let bottom = Float(rect.origin.y - rect.height)
        let X = float3(2 / (right - left), 0, 0)
        let Y = float3(0, 2 / (top - bottom), 0)
        let Z = float3(0, 0, 1 / (far - near))
        let W = float4(
            (left + right) / (left - right),
            (top + bottom) / (bottom - top),
            near / (near - far),
            1)
      self.init()
      columns = (X, Y, Z)
    }
}


extension float4x4 {
    init(orthographic rect: CGRect, near: Float, far: Float) {
        let left = Float(rect.origin.x)
        let right = Float(rect.origin.x + rect.width)
        let top = Float(rect.origin.y)
        let bottom = Float(rect.origin.y - rect.height)
        let X = SIMD4<Float>(2 / (right - left), 0, 0, 0)
        let Y = SIMD4<Float>(0, 2 / (top - bottom), 0, 0)
        let Z = SIMD4<Float>(0, 0, 1 / (far - near), 0)
        let W = SIMD4<Float>(
          (left + right) / (left - right),
          (top + bottom) / (bottom - top),
          near / (near - far),
          1)
        self.init()
        columns = (X, Y, Z, W)
    }
    
    init(orthographicLeft: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) {
        let X = SIMD4<Float>(2 / (right - orthographicLeft), 0, 0, 0)
        let Y = SIMD4<Float>(0, 2 / (top - bottom), 0, 0)
        let Z = SIMD4<Float>(0, 0, 1 / (far - near), 0)
        let W = SIMD4<Float>(
          (orthographicLeft + right) / (orthographicLeft - right),
          (top + bottom) / (bottom - top),
          near / (near - far),
          1)
        self.init()
        columns = (X, Y, Z, W)
    }
    
    
    init(scaleX: Float, scaleY: Float) {
        self = float4x4(
            [scaleX, 0, 0, 0],
            [0, scaleY, 0, 0],
            [0,     0,  1, 0],
            [0,     0,  1,  1]
        )
    }
    
    init(translationX: Float, translationY: Float) {
        self = float4x4(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [translationX, translationY, 0, 1]
        )
    }
    
    init(translationX: Float, translationY: Float, translationZ: Float) {
        self = float4x4(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [translationX, translationY, translationZ, 1]
        )
    }
    
    init(rotationAngle: Float) {
        self = float4x4(rows: [
            SIMD4<Float>(cos(rotationAngle), -sin(rotationAngle), 0, 0),
            SIMD4<Float>(sin(rotationAngle), cos(rotationAngle), 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1),
        ])
    }
    
    static var identity: float4x4 {
        return matrix_identity_float4x4
    }
    
    init(mirrorX: Bool, mirrorY: Bool) {
        let scaleX: Float = mirrorX ? -1 : 1
        let scaleY: Float = mirrorY ? -1 : 1
        self.init()
        let X = SIMD4<Float>(scaleX, 0.0, 0.0, 0.0)
        let Y = SIMD4<Float>(0, scaleY, 0.0, 0.0)
        let Z = SIMD4<Float>(0, 0.0, 1.0, 0.0)
        let W = SIMD4<Float>(0, 0.0, 0.0, 1.0)
        self.init()
        columns =  (
            X, Y, Z, W
        )
    }
    
    init(shearX: Float, shearY: Float) {
        let X = SIMD4<Float>(1, shearX, 0, 0)
        let Y = SIMD4<Float>(shearY, 1, 0, 0)
        let Z = SIMD4<Float>(0, 0.0, 1.0, 0.0)
        let W = SIMD4<Float>(0, 0.0, 0.0, 1.0)
        self.init()
        columns =  (
            X, Y, Z, W
        )
    }
    
    
    
}


extension float4x4 {
    init(angleZ: Float) {
        let cosA = cos(angleZ)
        let sinA = sin(angleZ)
        self.init()
        columns = (
            SIMD4<Float>(cosA, -sinA, 0, 0),
            SIMD4<Float>(sinA, cosA, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }
    
    init(perspectiveFov fov: Float, aspect: Float, near: Float, far: Float, lhs: Bool = true) {
        let yScale = 1 / tan(fov * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = far / zRange
        let wz = -near * far / zRange
        
        self.init(columns: (
            SIMD4<Float>(xScale, 0,      0,   0),
            SIMD4<Float>(0,      yScale, 0,   0),
            SIMD4<Float>(0,      0,      zScale, 1),
            SIMD4<Float>(0,      0,      wz,   0)
        ))
    }
    
    static func makePerspectiveCropMatrix(cropRect: CGRect, near: Float, far: Float) -> float4x4 {
        // 裁剪区域的缩放和平移（NDC -> crop rect）
          let scaleX = 2.0 / Float(cropRect.width)
          let scaleY = 2.0 / Float(cropRect.height)
          let offsetX = -(Float(cropRect.midX) * scaleX)
          let offsetY = -(Float(cropRect.midY) * scaleY)
          
          // 注意：顺序是先缩放再平移
          let scaleMatrix = float4x4(columns: (
              SIMD4<Float>(scaleX, 0, 0, 0),
              SIMD4<Float>(0, scaleY, 0, 0),
              SIMD4<Float>(0, 0, 1, 0),
              SIMD4<Float>(0, 0, 0, 1)
          ))
          
          let translationMatrix = float4x4(columns: (
              SIMD4<Float>(1, 0, 0, 0),
              SIMD4<Float>(0, 1, 0, 0),
              SIMD4<Float>(0, 0, 1, 0),
              SIMD4<Float>(offsetX, offsetY, 0, 1)
          ))
          
          return scaleMatrix * translationMatrix
    }
    
    init(eye: float3, center: float3, up: float3) {
      let z = normalize(center - eye)
      let x = normalize(cross(up, z))
      let y = cross(z, x)

      let X = float4(x.x, y.x, z.x, 0)
      let Y = float4(x.y, y.y, z.y, 0)
      let Z = float4(x.z, y.z, z.z, 0)
      let W = float4(-dot(x, eye), -dot(y, eye), -dot(z, eye), 1)

      self.init()
      columns = (X, Y, Z, W)
    }

    
    init(angleY: Float) {
        let cosA = cos(angleY)
        let sinA = sin(angleY)
        self.init()
        columns = (
            SIMD4<Float>(cosA, 0, -sinA, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(sinA, 0, cosA, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }
    
    init(angleX: Float) {
        let cosA = cos(angleX)
        let sinA = sin(angleX)
        self.init()
        columns = (
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, cosA, -sinA, 0),
            SIMD4<Float>(0, sinA, cosA, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }
    
}
