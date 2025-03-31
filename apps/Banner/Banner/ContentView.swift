//
//  ContentView.swift
//  Banner
//
//  Created by Renjun Li on 2025/3/28.
//

import SwiftUI

struct ContentView: View {
    
    @State var currentIndex: Int = 0
    @State var cardList: [Int] = [0, 1, 2, 3, 4]
    
    var body: some View {
        
        CardListView(data: $cardList, dataId: \.self) { item in
            HStack {
                Text("\(item)")
            }
            .frame(height: 124)
            .frame(maxWidth: .infinity)
            .background(content: {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.red)
            })
        }
        .frame(height: 124)
       
    }
}

#Preview {
    ContentView()
}




public struct CardListView<Data, ID, Content>: View where Data: RandomAccessCollection & Equatable, Content: View, ID: Hashable {
    @Binding private var data: Data
    @State private var content: (Data.Element) -> Content
    @State private var dataId: KeyPath<Data.Element, ID>
    private let innerLeadingPadding: CGFloat
    private let widthOfHiddenItems: CGFloat
    private let itemSpacing: CGFloat
    
    
    public init(leadingPadding: CGFloat = 20,
                itemInterSpacing: CGFloat = 12,
                widthOfHiddenItems: CGFloat = 90,
                data: Binding<Data>,
                dataId: KeyPath<Data.Element, ID>,
                @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.content = content
        self._data = data
        self.dataId = dataId
        self.innerLeadingPadding = leadingPadding - itemInterSpacing
        self.widthOfHiddenItems = widthOfHiddenItems
        self.itemSpacing = itemInterSpacing
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                let itemWidth = (proxy.size.width - itemSpacing * 2 - widthOfHiddenItems) / 2.0
                LazyHStack(alignment: .center, spacing: itemSpacing) {
                    Spacer(minLength: innerLeadingPadding)
                    ForEach(data, id: dataId) {
                        content($0)
                            .frame(width: itemWidth)
                    }
                }
            }
        }
    }
}
