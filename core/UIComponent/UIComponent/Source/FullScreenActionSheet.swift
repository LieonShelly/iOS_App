//
//  FullScreenActionSheet.swift
//  UIComponent
//
//  Created by Renjun Li on 2024/10/20.
//

import SwiftUI

public struct FullScreenActionSheetHome: View {
    @State private var isPresented: Bool = false
    
    public init() { }
    
    public var body: some View {
        Button("Tap：\(isPresented)") {
            isPresented = true
        }
        .translucentFullScreenCover(isPresented: $isPresented) {
            ActionSheet(isPresented: $isPresented, title: "First")
        }

    }
}

struct ActionSheet: View {
    @Binding private var isPresented: Bool
    let title: String
    
    init(isPresented: Binding<Bool>, title: String) {
        self._isPresented = isPresented
        self.title = title
    }
    
    var body: some View {
        VStack {
            Button(title) {
                isPresented = true
            }
            
            Button("Close") {
                isPresented = false
            }
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .background(.white)

    }
        
}



public extension View {
    func translucentFullScreenCover(isPresented: Binding<Bool>,
                                    sheetContent: @escaping () -> some View) -> some View {
        modifier(TranslucentFullScreenModifier(isPresented: isPresented, sheetContent: sheetContent))
    }
}

struct TranslucentFullScreenModifier<Sheet: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> Sheet
    
    @State private var fullScreenCoverIsPresented: Bool = false
    @State private var showing: Bool = false
    
    init(isPresented: Binding<Bool>, sheetContent: @escaping () -> Sheet) {
        self._isPresented = isPresented
        self.sheetContent = sheetContent
    }
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $fullScreenCoverIsPresented) {
                ZStack {
                    Color.black.opacity(showing ? 0.5 : 0)
                        .onTapGesture {
                            isPresented = false
                        }
                       
                    VStack {
                        Spacer()
                        if showing {
                            sheetContent()
                                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                                .onDisappear(perform: {
                                    fullScreenCoverIsPresented = false
                                })
                               
                        }
                    }
                }
                .background(FullScreenCoverBackgroundRemovalView())
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    setShowing(true)
                }
            }
            .onChange(of: isPresented) { isPresented in
                if isPresented {
                    fullScreenCoverIsPresented = true
                } else {
                    setShowing(false)
                }
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
    }
    
    func setShowing(_ showing: Bool) {
        withAnimation(.easeInOut) {
            self.showing = showing
        }
    }
}


struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {
    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        return BackgroundRemovalView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}


#Preview {
    FullScreenActionSheetHome()
}
