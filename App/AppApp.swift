//
//  AppApp.swift
//  App
//
//  Created by Renjun Li on 2024/7/26.
//

import SwiftUI
import SwiftData

@main
struct AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if #available(iOS 18.0, *) {
                AlbumContentView()
            } else {
                ContentView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
