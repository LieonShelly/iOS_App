//
//  CustomCornor.swift
//  App
//
//  Created by Renjun Li on 2024/8/14.
//

import SwiftUI

struct CustomCornor: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    nonisolated func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
