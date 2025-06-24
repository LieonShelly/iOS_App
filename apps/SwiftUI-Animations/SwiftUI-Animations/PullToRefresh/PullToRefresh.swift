//
//  PullToRefresh.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/24.
//

import SwiftUI

struct PullToRefresh: Equatable {
    var progress: Double
    var state: AnimationState
}

enum AnimationState: Int {
    case idle
    case pulling
    case ongoing
    case preparingFinish
    case finishing
}

func after(_ seconds: Double, execute: @escaping () -> Void) {
    Task {
        let delay = UInt64(seconds * Double(NSEC_PER_SEC))
        try await Task.sleep(nanoseconds: delay)
        execute()
    }
}

extension UIScreen {
    static var halfWidth: CGFloat {
        main.bounds.width / 2
    }
}
