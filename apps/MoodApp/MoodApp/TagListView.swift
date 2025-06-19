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
}


class TagListViewModel: ObservableObject {
    @Published var tag: [Tag] = []
    @Published var rows: [[Tag]] = []
    let itemSpacing: CGFloat = 10
    let rowSpacing: CGFloat = 20
    let textInset: EdgeInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
    let font: UIFont = UIFont.systemFont(ofSize: 16)
    
    func update(_ tags: [String]) {
        
    }
    
    
    
}

struct TagListView: View {
    let tags: [String]
    let itemSpacing: CGFloat = 10
    let rowSpacing: CGFloat = 20
    let textInset: EdgeInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
    let font: UIFont = UIFont.systemFont(ofSize: 16)
    
    @StateObject var viewModel: TagListViewModel
    
    init(tags: [String]) {
        self.tags = tags
        self._viewModel = .init(wrappedValue: TagListViewModel())
        self.viewModel.update(tags)
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var rows: [[String]] = [[]]
        for tag in tags {
            let textWidth = tag.size(withFont: font).width
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
                    ForEach(rows[rowIndex], id: \.self) { tag in
                        tagView(tag)
                    }
                }
            }
        }
    }
    
    private func tagView(_ tag: String) -> some View {
        Text(tag)
            .font(.system(size: 16))
            .foregroundStyle(MoodColor.textPrimary.color)
            .padding(textInset)
            .background(MoodColor.backgroundGray.color)
            .cornerRadius(10)
    }
}
