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
        CardListView(data: $cardList, dataId: \.self) { item in
            VStack(alignment: .leading, spacing: 8) {
                // 电量显示
                Text("360 kWh")
                    .font(.system(size: 20, weight: .medium))
                
                HStack(alignment: .bottom, spacing: 4) {
                    // 当前价格
                    Text("¥")
                        .font(.system(size: 14))
                        .baselineOffset(2)
                    Text("599")
                        .font(.system(size: 20, weight: .medium))
                    // 原价
                    Text("¥957.6")
                        .font(.system(size: 12))
                        .strikethrough()
                        .foregroundColor(.gray)
                }
                
                // 分割虚线
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: CGPoint(x: 20, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width - 20, y: 0))
                    }
                    .stroke(style: StrokeStyle(
                        lineWidth: 1,
                        dash: [4, 4]
                    ))
                    .foregroundColor(.red.opacity(0.2))
                }
                .frame(height: 1)
                .padding(.vertical, 8)
                
                // 有效期
                Text("有效期: 365天")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.red)
                    .overlay(content: {
                        Image(.cardBg)
                            .resizable()
                            .scaledToFill()
                    })
                    .overlay(alignment: .topTrailing, content: {
                        Text("限购")
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.red)
                    })
                .clipShape(RoundedRectangle(cornerRadius: 8))
            )
            .padding(16)
        }
        .frame(height: 124)
        .padding(.top, 20)
        .background(.white)
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
            .fill(Color(.shadow))
            .offset(y: -8)
            .blur(radius: 20)
            .frame(height: 13)
    }
    
    var body: some View {
        VStack {
            cardHeader
            carListView
        }
    }
    
    var cardHeader: some View {
        ZStack(alignment: .bottom) {
            shadowView
            headerView
            cornorView
        }
        .clipped()
    }
    @ViewBuilder
    var headerView: some View {
        let width = UIScreen.main.bounds.width - 20 * 2
        let height = width * 88.0 / 335.0
        VStack(alignment: .leading, spacing: .zero) {
            Image(.logo)
                .frame(width: 116, height: 8)
                .padding(.top, 16)
                .padding(.leading, 16)
                .background(.red)
            
            Text("保时捷尊享充电卡")
                .font(.subheadline)
                .padding(.top, 16)
                .padding(.leading, 16)
            Spacer()
        }
        .frame(height: height)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .top, content: {
            Rectangle()
                .frame(width: width, height: width * 438 / 1005)
                .overlay(alignment: .top, content: {
                    Image(.cardBg)
                        .resizable()
                        .scaledToFit()
                })
                .clipShape(RoundedRectangle(cornerRadius: 8))
        })
        .padding(.horizontal, 20)
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
