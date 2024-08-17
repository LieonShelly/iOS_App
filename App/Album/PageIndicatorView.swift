//
//  PageIndicatorView.swift
//  App
//
//  Created by Renjun Li on 2024/8/16.
//

import SwiftUI

struct PageIndicatorView: View {
    @Environment(SharedData.self) private var sharedData
    @Namespace private var animation
    var onClose: (() -> Void)?
    
    var body: some View {
        let progress = sharedData.progress
        HStack(spacing: 8) {
            ForEach(1...4, id: \.self) { index in
                Circle()
                    .opacity(index == 1 ? 0 :1)
                    .overlay {
                        if index == 1 {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 10))
                        }
                    }
                    .frame(width: 7, height: 7)
                    .foregroundStyle(sharedData.activePage == index ? Color.primary : .gray)
            }
        }
        .blur(radius: progress * 5)
        .opacity(1.0 - (progress * 4))
        .overlay(alignment: .center) {
            customBottomBar()
                .fixedSize()
                .blur(radius: (1 - progress) * 5)
                .opacity(progress)
        }
        .offset(y: -30 - (30 * progress))
    }
    
    func customBottomBar() -> some View {
        HStack(spacing: 10) {
            HStack(spacing: .zero) {
                ForEach(["Year", "Month", "All"], id: \.self) { category in
                    Button {
                       
                    } label: {
                        Text(category)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 6)
                            .background {
                                if sharedData.selectedCategory == category {
                                    Capsule()
                                        .fill(.gray.opacity(0.5))
                                        .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                                }
                            }
                    }

                }
            }
            .background(.ultraThinMaterial, in: .capsule)
            
            Button {
                onClose?()
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 35, height: 35)
                    .background(.ultraThinMaterial, in: .capsule)
            }
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    AlbumContentView()
}
