//
//  StartCardViewLiveActivity.swift
//  StartCardView
//
//  Created by Renjun Li on 2024/8/22.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct StartCardViewAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct StartCardViewLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StartCardViewAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension StartCardViewAttributes {
    fileprivate static var preview: StartCardViewAttributes {
        StartCardViewAttributes(name: "World")
    }
}

extension StartCardViewAttributes.ContentState {
    fileprivate static var smiley: StartCardViewAttributes.ContentState {
        StartCardViewAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: StartCardViewAttributes.ContentState {
         StartCardViewAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: StartCardViewAttributes.preview) {
   StartCardViewLiveActivity()
} contentStates: {
    StartCardViewAttributes.ContentState.smiley
    StartCardViewAttributes.ContentState.starEyes
}
