//
//  RoundedCorners.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/19.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self.modifier(RoundedCorners(radius: radius, corners: corners))
    }
}

struct RoundedCorners: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangleWithCorners(radius: radius, corners: corners))
    }
}

struct RoundedRectangleWithCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
