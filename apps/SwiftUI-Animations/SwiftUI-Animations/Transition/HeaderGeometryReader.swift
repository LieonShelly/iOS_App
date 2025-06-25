//
//  HeaderGeometryReader.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/25.
//

import SwiftUI

struct HeaderGeometryReader: View {
    @Binding var offset: CGFloat
    @Binding var collapsed: Bool
    @State var startOffset: CGFloat = 0
    
    
    var body: some View {
        GeometryReader<AnyView> { proxy in
            guard proxy.frame(in: .global).minX >= 0 else {
                return AnyView(EmptyView())
            }
            Task {
                offset = proxy.frame(in: .global).minY - startOffset
                
                withAnimation(.easeInOut) {
                    collapsed = offset < Constants.minHeaderOffset
                }
            }
            return AnyView(Color.clear.frame(height: 0)
                .task {
                    startOffset = proxy.frame(in: .global).minY
                }
            )
        }
    }
}
