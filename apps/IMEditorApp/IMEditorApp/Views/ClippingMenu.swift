//
//  ClippingMenu.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/21.
//

import SwiftUI

struct ClippingMenu: View {
    @ObservedObject var viewModel: ClippingMenuViewModel
    
    init(viewModel: ClippingMenuViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            menuList.padding(.horizontal, 20)
            Slider(value: $viewModel.selectedProgress, label: {
                Text("\(viewModel.selectedProgress)")
            }, minimumValueLabel: {
                Text("\(0)")
            }, maximumValueLabel: {
                Text("\(100)")
            })
            .tint(AppColor.primary)
            .padding(.horizontal, 20)
            
            Text("\(viewModel.selectedProgress)")
                .padding(.bottom, 20)
        }
    }
    
    
    @ViewBuilder var menuList: some View {
        let menuWidth: CGFloat = 50
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .zero) {
                        Color.clear.frame(width: proxy.size.width * 0.5 - menuWidth * 0.5)
                        HStack {
                            ForEach(viewModel.menuList) { element in
                                Image(systemName: element.iconName)
                                    .foregroundStyle(element.isSelect ? AppColor.primary : AppColor.secondary)
                                    .frame(width: menuWidth, height: menuWidth)
                                    .id(element.index)
                                    .onTapGesture {
                                        viewModel.onTapItem(element)
                                        withAnimation(.bouncy) {
                                            scrollProxy.scrollTo(element.index, anchor: .center)
                                        }
                                    }
                            }
                        }
                        Color.clear.frame(width: proxy.size.width * 0.5 - menuWidth * 0.5)
                    }
                }
            }
        }
        .frame(height: 50)
    }
    
}
