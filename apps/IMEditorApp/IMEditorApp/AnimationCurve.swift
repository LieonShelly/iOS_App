//
//  AnimationCurve.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/27.
//

import Foundation

enum AnimationCurve {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case spring
    
    func apply(to value: Float) -> Float {
        switch self {
        case .linear:
            return value
        case .easeIn:
            return pow(value, 3)
        case .easeOut:
            return 1 - pow(1 - value, 3)
        case .easeInOut:
            if value < 0.5 {
                return 4 * value * value * value
            } else {
                let adjustment = (2 * value) - 2
                return 0.5 * adjustment * adjustment * adjustment + 1
            }
        case .spring:
            return springCurve(value)
        }
    }
    
    private func springCurve(_ t: Float) -> Float {
        let damping: Float = 5.0
        let frequency: Float = 8.0
        let amplitude: Float = 0.15
        return 1 + (amplitude * exp(-damping * t) * cos(frequency * t * 2 * .pi))
    }
}
