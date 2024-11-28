//
//  MouseKeyManager.swift
//  AINote
//
//  Created by Renjun Li on 2024/11/28.
//

import Foundation
import HotKey
import ScreenCaptureKit
import AppKit
import SwiftUI

class MouseKeyManager: ObservableObject {
    var window: NSWindow?
    var lastClickTime: TimeInterval = 0
    
    init() {
        self.addObserver()
    }
    
    func addObserver() {
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] event in
           
            self?.handleMouseClick(event: event)
        }
    }
    
    private func handleMouseClick(event: NSEvent) {
        let currentTime = event.timestamp
        let timeSinceLastClick = currentTime - lastClickTime
        if timeSinceLastClick <= NSEvent.doubleClickInterval {
            showWindow(at: event.locationInWindow)
        }
        lastClickTime = currentTime
    }
    
    private func showWindow(at position: NSPoint) {
        let flippedPosition = NSPoint(x: position.x, y: position.y)
        if let window {
            window.setFrameOrigin(position)
            window.level = .floating
            window.makeKeyAndOrderFront(nil)
        } else {
            let window = NSWindow(contentRect: NSRect(x: flippedPosition.x, y: flippedPosition.y, width: 300, height: 200),
                                  styleMask: [.borderless],
                                  backing: .buffered,
                                  defer: false)
            window.contentView = NSHostingController(rootView: PopupContentView()).view
            window.level = .floating
            window.backgroundColor = .clear
            window.makeKeyAndOrderFront(nil)
            self.window = window
        }
     
    }
}
