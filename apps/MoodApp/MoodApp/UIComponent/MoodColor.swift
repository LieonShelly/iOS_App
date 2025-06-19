//
//  MoodColor.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/18.
//

import UIKit
import SwiftUI

class AppBundle { }

enum MoodColor: String {
    case primary
    case backgroundWhite = "background-white"
    case backgroundYellow = "background-yellow"
    case textPrimary = "text-primary"
    case textSecondary = "text-secondary"
    case textThird = "text-third"
    case textForth = "text-forth"
    case textDisable = "text-disable"
    
    var uiColor: UIColor {
        guard let color = UIColor(named: rawValue, in: Bundle(for: AppBundle.self), compatibleWith: nil) else {
            fatalError("Color :\(rawValue) not find in Bundle")
        }
        return color
    }
    
    var color: Color {
        Color(rawValue, bundle: Bundle(for: AppBundle.self))
    }
}


