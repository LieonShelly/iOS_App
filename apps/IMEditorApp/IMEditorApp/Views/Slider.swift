//
//  Slider.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/19.
//

import SwiftUI

struct SliderData: Identifiable {
    var id: String = UUID().uuidString
    let isHighlight: Bool
    let index: Int
}

struct SliderView: View {
    @Binding var progress: CGFloat
    @State private var list: [SliderData] = []
    @State private var scrollOffset: CGFloat = 0
    @State private var initialPosition: CGFloat?
    @State private var header: SliderData?
    @State private var footer: SliderData?
    @State private var content: [SliderData] = []
    @State private var isInnerUpdate: Bool = false
    private var didUpdateProgress: ((CGFloat) -> Void)?
    
    init(progress: Binding<CGFloat>, didUpdateProgress: ((CGFloat) -> Void)? = nil) {
        self._progress = progress
        self.didUpdateProgress = didUpdateProgress
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            centerLine
            sliderView
        }
    }
    
    var sliderView: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear(perform: {
                                    initialPosition = proxy.frame(in: .global).minX
                                    scrollViewProxy.scrollTo(10, anchor: .center)
                                })
                                .onChange(of: proxy.frame(in: .global).minX) { oldValue, newValue in
                                    if let initia = initialPosition {
                                        scrollOffset = initia - newValue
                                        let progress = scrollOffset / (CGFloat(list.count + 1) * 10.0)
                                        didUpdateProgress?(progress)
                                    }
                            }
                            .frame(width: 0, height: 0)
                        }
                        HStack(spacing: .zero) {
                            Color.clear.frame(width: proxy.size.width * 0.5)
                            if let hader = header {
                                SliderRowHeader(isHighlight: hader.isHighlight, width: 5)
                                    .id(hader.index)
                                
                            }
                             ForEach(content) { element in
                                 SliderRow(isHighlight: element.isHighlight, width: 10)
                                     .id(element.index)
                                     
                             }
                            if let footer = footer {
                                SliderRowFooter(isHighlight: footer.isHighlight, width: 5)
                                    .id(footer.index)
                            }
                           
                            Color.clear.frame(width: proxy.size.width * 0.5)
                        }
                        
                    }
                    .onAppear {
                        if list.isEmpty {
                            for index in  0 ..< 50 {
                                list.append(SliderData(isHighlight: false, index: index))
                            }
                            header = list.removeFirst()
                            footer = list.removeLast()
                            content = list
                        }
                    }
                    .onChange(of: progress) { oldValue, newValue in
                        let index = Int(CGFloat(list.count + 2) * newValue)
                        withAnimation {
                            scrollViewProxy.scrollTo(index, anchor: .leading)
                        }
                    }
                }
                
            }
            
        }
        .frame(height: 10)
     
    }
    
    var centerLine: some View {
        Rectangle()
            .fill(.red)
            .frame(width: 1, height: 50)
    }
}

struct SliderRow: View {
    let isHighlight: Bool
    let width: CGFloat
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(isHighlight ? .black : .gray)
                .frame(width: 1)
        }
        .frame(width: width)
      
    }
}

struct SliderRowHeader: View {
    let isHighlight: Bool
    let width: CGFloat
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(isHighlight ? .black : .gray)
                .frame(width: 1)
                .padding(.leading, 3)
            Spacer()
        }
        .frame(width: width)
      
    }
}

struct SliderRowFooter: View {
    let isHighlight: Bool
    let width: CGFloat
    
    var body: some View {
        HStack {
            Spacer()
            Rectangle()
                .fill(isHighlight ? .black : .gray)
                .frame(width: 1)
                .padding(.trailing, 3)
          
        }
        .frame(width: width)
      
    }
}


struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct ClipSliderEntity {
    let minValue: CGFloat
    let maxValue: CGFloat
    let currentValue: CGFloat
}
