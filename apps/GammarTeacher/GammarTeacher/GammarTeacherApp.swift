//
//  GammarTeacherApp.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/15.
//

import SwiftUI
import SwiftData

@main
struct GammarTeacherApp: App {
    var body: some Scene {
        WindowGroup {
            WordImporterContentView()
        }
        .modelContainer(for: WordItem.self)
    }
}
