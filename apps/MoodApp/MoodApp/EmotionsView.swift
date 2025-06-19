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
            TagListView(tags: sampleTags)
                .padding()
        }
    }
    
}


extension String {
    func size(withFont font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: attributes)
    }
}

#Preview {
    EmotionsView()
}


