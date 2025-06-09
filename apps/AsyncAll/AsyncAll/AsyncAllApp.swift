//
//  AsyncAllApp.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/9.
//

import SwiftUI

@main
struct AsyncAllApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: HomeViewModel())
        }
    }
}
