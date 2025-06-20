//
//  EmotionsView.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/19.
//

import SwiftUI

struct EmotionsView: View {
    let sampleTags = ["VisionKitVisionKitVisionKitVisionKit", "VisionKitVisionKitVisionKitVisionKit", "SwiftUI", "Combine", "CoreData", "Metal", "UIKit", "UIKit", "VisionKitVisionKitVisionKitVisionKit", "RealityKit"]
    
    var body: some View {
        ScrollView {
            TagListView(
                tags: sampleTags.map { Tag(value: $0) },
                textColor: .textPrimary,
                backgroundColor: .backgroundGray,
                selectedTextColor: .backgroundWhite,
                selectedBackgroundColor: MoodColor.primary.color,
                cornorRadius: 10,
                font: .moodFont(forTextStyle: .titleTiny)
            )
                .padding()
        }
    }
    
}


#Preview {
    EmotionsView()
}


