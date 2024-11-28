//
//  AINoteApp.swift
//  AINote
//
//  Created by Renjun Li on 2024/11/27.
//

import SwiftUI

@main
struct AINoteApp: App {
    @State var currentNumber: String = "1"
    @Environment(\.openWindow) private var openWindow
    @StateObject private var shortcutManager = ShortcutManager()
    @StateObject private var mouseManager = MouseKeyManager()
    
    var body: some Scene {
        
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            Button("One") {
                currentNumber = "1"
            }
            
            Button("Two") {
                currentNumber = "2"
            }

            
            Button("HomeWindow") {
                openWindow(id: "homeWindow")
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        
        
        WindowGroup(id: "homeWindow") {
            ContentView()
        }
        
        WindowGroup(id: "popupWindow") {
            PopupContentView()
        }
        
       
    }
}


