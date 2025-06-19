//
//  TagListView.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/19.
//

import SwiftUI

struct Tag {
    var isSelected: Bool = false
    var value: String
    let tagId: String = UUID().uuidString
}

struct TagListView: View {
    @State var tags: [Tag]
    var didTapTag: ((Tag) -> Void)?
    
    let itemSpacing: CGFloat = 10
    let rowSpacing: CGFloat = 20
    let textInset: EdgeInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
    let font: UIFont = UIFont.systemFont(ofSize: 16)
    
    
    init(tags: [Tag], didTapTag: ((Tag) -> Void)? = nil) {
        self.tags = tags
        self.didTapTag = didTapTag
    }
    
    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var rows: [[Tag]] = [[]]
        for tag in tags {
            let textWidth = tag.value.size(withFont: font).width
            let tagWidth = textWidth + textInset.leading + textInset.trailing
            let currentWidth = width + tagWidth
            
            if currentWidth >= geometry.size.width {
                rows.append([tag])
                width = tagWidth
            } else {
                width += tagWidth + itemSpacing
                rows[rows.count - 1].append(tag)
            }
            
        }
        return VStack(alignment: .center, spacing: rowSpacing) {
            ForEach(0 ..< rows.count, id: \.self) { rowIndex in
                HStack(alignment: .center, spacing: itemSpacing) {
                    ForEach(rows[rowIndex], id: \.value) { tag in
                        tagView(tag)
                    }
                }
            }
        }
    }
    
    private func tagView(_ tag: Tag) -> some View {
        Text(tag.value)
            .font(Font(font))
            .foregroundStyle(tag.isSelected ? MoodColor.backgroundWhite.color : MoodColor.textPrimary.color)
            .padding(textInset)
            .background(tag.isSelected ? MoodColor.primary.color : MoodColor.backgroundGray.color)
            .cornerRadius(10)
            .onTapGesture {
                guard let index = tags.firstIndex(where: { $0.tagId == tag.tagId }) else { return }
                var newTags = tags.map { Tag(value: $0.value) }
                newTags[index].isSelected = !newTags[index].isSelected
                tags = newTags
                didTapTag?(newTags[index])
            }
    }
}
