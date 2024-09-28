//
//  PopView.swift
//  App
//
//  Created by Renjun Li on 2024/9/5.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func popView<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> (),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            PopViewModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                viewContent: content
            )
        )
    }
}

fileprivate struct PopViewModifier<ViewContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var onDismiss: () -> ()
    @ViewBuilder var viewContent: ViewContent
    @State private var presenFullScreenCover: Bool = false
    @State private var animateView: Bool = false
    
    func body(content: Content) -> some View {
        let screenHeight = screenSize.height
        let animateView = animateView
        
        content
            .fullScreenCover(isPresented: $presenFullScreenCover, onDismiss: onDismiss) {
                ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.25))
                    .ignoresSafeArea()
                    .opacity(animateView ? 1 : 0)
                    .onTapGesture {
                        isPresented = false
                    }
                
                viewContent
                    .visualEffect({ content, proxy in
                        content
                            .offset(y: offset(proxy, screenHeight: screenHeight, animateView: animateView))
                    })
                    .presentationBackground(.clear)
                    .task {
                        guard !animateView else { return }
                        withAnimation(.easeIn(duration: 0.25)) {
                            self.animateView = true
                        }
                    }
                    .ignoresSafeArea(.container, edges: .all)
            }
        }
        .onChange(of: isPresented) { oldValue, newValue in
            if newValue {
                toggleView(true)
            } else {
                Task {
                    withAnimation(.snappy(duration: 0.45, extraBounce: 0)) {
                        self.animateView = false
                    }
                    try? await Task.sleep(for: .seconds(0.45))
                    toggleView(false)
                }
            }
        }
    }
    
    func toggleView(_ status: Bool) {
        var transcation = SwiftUI.Transaction()
        transcation.disablesAnimations = true
        withTransaction(transcation) {
            presenFullScreenCover = status
        }
    }
    
    nonisolated func offset(_ proxy: GeometryProxy, screenHeight: CGFloat, animateView: Bool) -> CGFloat {
        let viewHeight = proxy.size.height
        return animateView ? 0 : (viewHeight + screenHeight) / 2
    }
    
    var screenSize: CGSize {
        if let screenSize = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return screenSize
        }
        return .zero
    }
}
