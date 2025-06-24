//
//  CategoryView.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/20.
//

import SwiftUI

struct CategoryView: View {
    var body: some View {
        LazyVGrid(columns: [
            .init(.flexible(minimum: 0, maximum: 100), spacing: 10),
            .init(.flexible(minimum: 0, maximum: 100), spacing: 10),
            .init(.flexible(minimum: 0, maximum: 100), spacing: 10),
        ], alignment: .center, spacing: 10) {
            CategoryItem()
            CategoryItem()
            CategoryItem()
            CategoryItem()
            CategoryItem()
            CategoryItem()
            CategoryItem()
            CategoryItem()
            CategoryItem()
        }
    }
}

struct CategoryItem: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.randam)
            .frame(width: 90, height: 100)
            .overlay {
                VStack {
                    Rectangle()
                        .fill(Color.randam)
                        .frame(width: 60, height: 60)
                    
                    Text("Work")
                        .foregroundStyle(MoodColor.textPrimary.color)
                        .font(.moodFont(forTextStyle: .bodyMediumBold))
                }
            }
    }
}

#Preview(body: {
    CategoryView()
})
