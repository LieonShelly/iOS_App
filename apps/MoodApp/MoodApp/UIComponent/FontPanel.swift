//
//  FontPanel.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/19.
//

import SwiftUI

struct FontPanel: View {
    var body: some View {
        VStack {
            
            VStack {
                HStack {
                    Text("Sad")
                        .foregroundStyle(MoodColor.textPrimary.color)
                        .font(.moodFont(forTextStyle: .titleTiny))
                    Spacer()
                }
                HStack {
                    Text("Sasdfasdfasdfasdfasdfadsfasdfasdfasdad")
                        .foregroundStyle(MoodColor.textSecondary.color)
                        .font(.moodFont(forTextStyle: .bodyExtraSmall))
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Text("Sad")
                        .foregroundStyle(MoodColor.textPrimary.color)
                        .font(.moodFont(forTextStyle: .titleExtraSmall))
                    Spacer()
                }
                HStack {
                    Text("Sasdfasdfasdfasdfasdfadsfasdfasdfasdad")
                        .foregroundStyle(MoodColor.textSecondary.color)
                        .font(.moodFont(forTextStyle: .bodyExtraSmallBold))
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Text("Sad")
                        .foregroundStyle(MoodColor.textPrimary.color)
                        .font(.moodFont(forTextStyle: .titleSmall))
                    Spacer()
                }
                HStack {
                    Text("Sasdfasdfasdfasdfasdfadsfasdfasdfasdad")
                        .foregroundStyle(MoodColor.textSecondary.color)
                        .font(.moodFont(forTextStyle: .bodySmall))
                    Spacer()
                }
            }
            
            
            VStack {
                HStack {
                    Text("Sad")
                        .foregroundStyle(MoodColor.textPrimary.color)
                        .font(.moodFont(forTextStyle: .titleMedium))
                    Spacer()
                }
                HStack {
                    Text("Sasdfasdfasdfasdfasdfadsfasdfasdfasdad")
                        .foregroundStyle(MoodColor.textSecondary.color)
                        .font(.moodFont(forTextStyle: .bodySmallBold))
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Text("Sad")
                        .foregroundStyle(MoodColor.textPrimary.color)
                        .font(.moodFont(forTextStyle: .titleLarge))
                    Spacer()
                }
                HStack {
                    Text("Sasdfasdfasdfasdfasdfadsfasdfasdfasdad")
                        .foregroundStyle(MoodColor.textSecondary.color)
                        .font(.moodFont(forTextStyle: .bodyMedium))
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Text("Sad")
                        .foregroundStyle(MoodColor.textPrimary.color)
                        .font(.moodFont(forTextStyle: .titleExtraLarge))
                    Spacer()
                }
                HStack {
                    Text("Sasdfasdfasdfasdfasdfadsfasdfasdfasdad")
                        .foregroundStyle(MoodColor.textSecondary.color)
                        .font(.moodFont(forTextStyle: .bodyMediumBold))
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Text("Sad")
                        .foregroundStyle(MoodColor.textPrimary.color)
                        .font(.moodFont(forTextStyle: .titleHuge))
                    Spacer()
                }
                HStack {
                    Text("Sasdfasdfasdfasdfasdfadsfasdfasdfasdad")
                        .foregroundStyle(MoodColor.textSecondary.color)
                        .font(.moodFont(forTextStyle: .bodyLarge))
                    Spacer()
                }
            }
            
        }
        .padding()
    }
}


#Preview {
    FontPanel()
}
