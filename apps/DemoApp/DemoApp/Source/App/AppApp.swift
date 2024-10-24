//
//  AppApp.swift
//  App
//
//  Created by Renjun Li on 2024/7/26.
//

import SwiftUI
import SwiftData
import UIComponent

@main
struct AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Transaction.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            FullScreenActionSheetHome()
        }
    }
}
