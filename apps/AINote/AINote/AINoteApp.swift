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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            Button("One") {
                currentNumber = "1"
            }
            
            Button("Two") {
                currentNumber = "2"
            }

            
            Button("Three") {
                currentNumber = "3"
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        
       
    }
}


