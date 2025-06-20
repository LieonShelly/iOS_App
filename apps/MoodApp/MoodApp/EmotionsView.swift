//
//  EmotionsView.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/19.
//

import SwiftUI

struct EmotionsView: View {
    let sampleTags = ["Excited", "Relaxed", "Proud", "Hopeful", "Happy", "Enthusiatic", "Refreshed", "Gloomy", "Lonely", "Anxious", "Sad", "Tired", "Annoyed", "Burdensome", "Bored", "Stressed"]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Emotions")
                .foregroundStyle(MoodColor.textPrimary.color)
                .font(.moodFont(forTextStyle: .titleTiny))
            
            TagListView(
                tags: sampleTags.map { Tag(value: $0) },
                textColor: .textPrimary,
                backgroundColor: .backgroundGray,
                selectedTextColor: .backgroundWhite,
                selectedBackgroundColor: MoodColor.primary.color,
                cornorRadius: 10,
                font: .moodFont(forTextStyle: .bodySmall)
            )
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    EmotionsView()
}


