//
//  Martrix.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/13.
//

import simd
import Foundation

enum Martrix {
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
      self.init()
      columns = (X, Y, Z)
    }
}
