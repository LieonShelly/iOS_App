//
//  ContentView.swift
//  Banner
//
//  Created by Renjun Li on 2025/3/28.
//

import SwiftUI

struct TopMaskShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 开始绘制路径 - 从左上角开始
        path.move(to: CGPoint(x: 8, y: 0))
        
        // 画到右上角
        path.addLine(to: CGPoint(x: rect.width - 8, y: 0))
        
        let height: CGFloat = 12.38
        path.addLine(to: CGPoint(x: rect.width / 2, y: height))
        
        // 闭合路径 - 回到左上角
        path.closeSubpath()
        
        return path
    }
}


struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


struct ContentView: View {
    
    @State var currentIndex: Int = 0
    @State var cardList: [Int] = [0, 1, 2, 3, 4]
    
    var carListView: some View {
        
        VStack(spacing: 0) {
            CardListView(data: $cardList, dataId: \.self) { item in
                HStack {
                    Text("\(item)")
                        .foregroundColor(.white)
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
        .padding(.top, 20)
        .background(.white)
    }
    
    var header: some View {
        Rectangle()
            .fill(.black)
            .frame(height: 80)
            .clipShape(RoundedCornerShape(radius: 10, corners: [.topLeft, .topRight]))
            .padding(.horizontal, 20)
    }
    
    var cornorView: some View {
        Rectangle()
            .fill(.white)
            .frame(height: 13)
            .mask(
                Rectangle()
                    .clipShape(RoundedCornerShape(radius: 8, corners: [.topLeft, .topRight]))
                    .overlay(
                        TopMaskShape()
                            .blendMode(.destinationOut)
                    )
            )
    }
    
    var shadowView: some View {
        RoundedCornerShape(radius: 8, corners: [.topLeft, .topRight])
            .fill(Color.shadow)
            .offset(y: -12)
            .blur(radius: 20)
            .frame(height: 13)
    }
    
    var body: some View {
        
        VStack(spacing: .zero) {
            ZStack(alignment: .bottom) {
                shadowView
                header
                cornorView
            }
            carListView
            
            Spacer()
        }
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
