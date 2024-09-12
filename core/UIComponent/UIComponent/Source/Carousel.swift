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

struct CarouselView: View {
    let spacing: CGFloat = 16
    let widthOfHiddenCards: CGFloat = 20
    let cardHeight: CGFloat = 180
    
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
    
    var body: some View {
        Carousel(
            spacing: spacing,
            widthOfHiddenCards: widthOfHiddenCards,
            data: items,
            dataId: \.id) { item in
                RoundedRectangle(cornerRadius: 10)
                    .fill(.red)
                    .frame(height: cardHeight)
                    .frame(maxWidth: .infinity)
            }
    }
}

public class UIStateModel: ObservableObject {
    @Published var activeCard: Int = 0
    @Published var screenDrag: Float = 0.0
}

struct Carousel<Data, ID, Content> : View where Data: RandomAccessCollection, Content: View, ID: Hashable {
    private let content: (Data.Element) -> Content
    private let spacing: CGFloat
    private let widthOfHiddenCards: CGFloat
    private let cardWidth: CGFloat
    private let data: Data
    private let dataId: KeyPath<Data.Element, ID>
    @State private var activeCard: Int = 0
    @State private var screenDrag: Float = 0.0
    
    init(spacing: CGFloat,
         widthOfHiddenCards: CGFloat,
         data: Data,
         dataId: KeyPath<Data.Element, ID>,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.content = content
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.cardWidth =  UIScreen.main.bounds.width - (widthOfHiddenCards * 2) - (spacing * 2)
        self.data = data
        self.dataId = dataId
    }

    var body: some View {
        GeometryReader { proxy in
             HStack(alignment: .center, spacing: spacing) {
                 ForEach(data, id: dataId) {
                     content($0)
                         .frame(width: cardWidth)
                 }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
            .offset(x: xOffset)
            .animation(.spring, value: xOffset)
            .gesture(
                DragGesture()
                    .onChanged({ currentState in
                        let totalMovement = cardWidth + spacing
                        var offset: CGFloat = totalMovement
                        
                        if currentState.translation.width > 0 {
                            offset = min(offset, currentState.translation.width)
                        } else {
                            offset = max(-offset, currentState.translation.width)
                        }
                        
                        self.screenDrag = Float(currentState.translation.width)
                    })
                    .onEnded { value in
                        self.screenDrag = 0
                        let dragThreshold: CGFloat = cardWidth / 3
                        var activeIndex = self.activeCard
                        if value.translation.width > dragThreshold {
                            activeIndex -= 1
                        }
                        if value.translation.width < -dragThreshold {
                            activeIndex += 1
                        }
                        let numberOfItems = data.count
                        self.activeCard = max(0, min(activeIndex, Int(numberOfItems) - 1))
                    }
            )
        }
    }
    
    var xOffset: CGFloat {
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
        let activeOffset = (totalMovement * CGFloat(activeCard))
        let calcOffset = leftPadding - activeOffset + CGFloat(screenDrag)
        return calcOffset
    }
}


#Preview {
    CarouselView()
}
