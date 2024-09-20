//
//  Carousel.swift
//  UIComponent
//
//  Created by Renjun Li on 2024/9/12.
//

import SwiftUI

struct CarouselItemModel {
    let id: Int
    let name: String
    let image: Image
}

public struct CarouselView: View {
    let spacing: CGFloat = 16
    let widthOfHiddenCards: CGFloat = 20
    let cardHeight: CGFloat = 180
    @State var currentIndex: Int = 0
    @State var isDragging: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    public init(currentIndex: Int = 0) {
        self.currentIndex = currentIndex
    }
    
    let items = [
        CarouselItemModel(id: 0, name: "1. description.", image: Image("image1")),
        CarouselItemModel(id: 1, name: "2. description.", image: Image("image2")),
        CarouselItemModel(id: 2, name: "3. description.", image: Image("image3")),
        CarouselItemModel(id: 3, name: "4. description", image: Image("image4")),
        CarouselItemModel(id: 4, name: "4. description", image: Image("image4")),
        CarouselItemModel(id: 5, name: "4. description", image: Image("image4")),
        CarouselItemModel(id: 6, name: "4. description", image: Image("image4")),
        CarouselItemModel(id: 7, name: "4. description", image: Image("image4")),
    ]
    
    public var body: some View {
        ScrollView {
            Carousel(
                itemInterSpacing: spacing,
                widthOfHiddenItems: widthOfHiddenCards,
                currentIndex: $currentIndex,
                data: items,
                dataId: \.id) { item in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.red)
                        .frame(height: cardHeight)
                        .frame(maxWidth: .infinity)
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .frame(maxWidth: .infinity)
                }
                .frame(height: cardHeight)
            Button {
                currentIndex += 1
                if currentIndex >= items.count {
                    currentIndex = 0
                }
            } label: {
                Text("\(currentIndex)")
            }
        }
    }
}

public struct Carousel<Data, ID, Content> : View where Data: RandomAccessCollection, Content: View, ID: Hashable {
    private let content: (Data.Element) -> Content
    private let itemInterSpacing: CGFloat
    private let widthOfHiddenItems: CGFloat
    private let itemWidth: CGFloat
    private let data: Data
    private let dataId: KeyPath<Data.Element, ID>
    @Binding private var currentIndex: Int
    @State private var dragOffset: CGFloat = .zero
    @GestureState private var isGesturePressed: Bool = false
    
    public init(itemInterSpacing: CGFloat,
         widthOfHiddenItems: CGFloat,
         currentIndex: Binding<Int>,
         data: Data,
         dataId: KeyPath<Data.Element, ID>,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.content = content
        self.itemInterSpacing = itemInterSpacing
        self.widthOfHiddenItems = widthOfHiddenItems
        self.itemWidth = UIScreen.main.bounds.width - (widthOfHiddenItems * 2) - (itemInterSpacing * 2)
        self.data = data
        self.dataId = dataId
        self._currentIndex = currentIndex
    }

    public var body: some View {
        GeometryReader { proxy in
            let itemWidth = proxy.size.width - (widthOfHiddenItems * 2) - (itemInterSpacing * 2)
            HStack(alignment: .center, spacing: itemInterSpacing) {
                ForEach(data, id: dataId) {
                    content($0)
                        .frame(width: itemWidth)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
            .offset(x: xOffset(itemWidth))
            .animation(.spring, value: xOffset(itemWidth))
            .gesture(
                DragGesture()
                    .updating($isGesturePressed, body: { value, gestureState, transaction in
                        gestureState = true
                    })
                  .onChanged({ currentState in
                        let totalMovement = itemWidth + itemInterSpacing
                        var offset: CGFloat = totalMovement
                        if currentState.translation.width > 0 {
                            offset = min(offset, currentState.translation.width)
                        } else {
                            offset = max(-offset, currentState.translation.width)
                        }
                        self.dragOffset = currentState.translation.width
                    })
                    .onEnded { value in
                        self.dragOffset = .zero
                        let dragThreshold: CGFloat = itemWidth / 5
                        var activeIndex = self.currentIndex
                        if value.translation.width > dragThreshold {
                            activeIndex -= 1
                        }
                        if value.translation.width < -dragThreshold {
                            activeIndex += 1
                        }
                        let numberOfItems = data.count
                        self.currentIndex = max(0, min(activeIndex, Int(numberOfItems) - 1))
                    }
            )
            .onChange(of: isGesturePressed) { oldValue, newValue in
                if !newValue, self.dragOffset != .zero {
                    self.dragOffset = .zero
                }
            }
        }
    }
    
    func xOffset(_ itemWidth: CGFloat) -> CGFloat {
        let leftPadding = widthOfHiddenItems + itemInterSpacing
        let totalMovement = itemWidth + itemInterSpacing
        let activeOffset = (totalMovement * CGFloat(currentIndex))
        let calcOffset = leftPadding - activeOffset + CGFloat(self.dragOffset)
        return calcOffset
    }
}


#Preview {
    CarouselView()
}
