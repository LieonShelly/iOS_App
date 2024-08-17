//
//  OtherContents.swift
//  App
//
//  Created by Renjun Li on 2024/8/15.
//

import SwiftUI

struct OtherContents: View {
    var body: some View {
        VStack(spacing: 10) {
            dummyView(title: "Albums", color: .yellow)
            dummyView(title: "Albums", color: .blue)
            dummyView(title: "Albums", color: .cyan)
            dummyView(title: "Albums", color: .purple)
            dummyView(title: "Albums", color: .pink)
        }
    }
    
    @ViewBuilder
    func dummyView(title: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                
            } label: {
                HStack(spacing: 6) {
                    Text(title)
                        .foregroundStyle(.primary)
                        .font(.title3.bold())
                     
                    
                    Image(systemName: "chevron.right")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                }
            }
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(1...10, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 15)
                            .fill(color)
                            .frame(width: 220, height: 120)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .scrollIndicators(.hidden)
        .safeAreaPadding(.horizontal, 15)
        .padding(.top, 15)
    }
}

#Preview {
    AlbumContentView()
}
