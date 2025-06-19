//
//  LayoutConstants.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/19.
//

import UIKit

enum LayoutConstants {
    static var safeArea: UIEdgeInsets {
        let keyWindow = UIApplication.shared.keyWindow
        return keyWindow?.safeAreaInsets ?? .zero
    }
}
