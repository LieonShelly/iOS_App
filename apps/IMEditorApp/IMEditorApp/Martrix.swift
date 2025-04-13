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
}

