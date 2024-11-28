//
//  ShortcutManager.swift
//  AINote
//
//  Created by Renjun Li on 2024/11/28.
//

import Foundation
import HotKey
import ScreenCaptureKit
import AppKit
import SwiftUI

class ShortcutManager: NSObject, ObservableObject {
    var hotKey: HotKey
    
    override init() {
        hotKey = HotKey(key: .r, modifiers: [.command, .option])
        hotKey.keyDownHandler = {
            print("Pressed at \(Date())")
        }
    }
}
