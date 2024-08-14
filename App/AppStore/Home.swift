//
//  Home.swift
//  App
//
//  Created by Renjun Li on 2024/8/14.
//

import SwiftUI

struct Today: Identifiable {
    let artWork: String
    let id: String
    let platformTitle: String
    let bannerTitlte: String
    let appLogo: String
}

struct Home: View {
    var items: [Today] = [.init(artWork: "", id: "1", platformTitle: "APPLE", bannerTitlte: "Smash your rivals in LEGO Brawls", appLogo: ""),
                          .init(artWork: "", id: "2", platformTitle: "APPLE", bannerTitlte: "Smash your rivals in LEGO Brawls", appLogo: "")]
    let dummyText = """
        var items: [Today] = [.init(artWork: "", id: "1", platformTitle: "APPLE", bannerTitlte: "Smash your rivals in LEGO Brawls", appLogo: ""),
                              .init(artWork: "", id: "2", platformTitle: "APPLE", bannerTitlte: "Smash your rivals in LEGO Brawls", appLogo: "")]
    """
    
    @State var currentItem: Today?
    @State var showDetailPage: Bool = false
    
    // matched Geometry Effect
    @Namespace var animation
    @Namespace var scroll
    
    // detail animation properties
    @State var animatedView: Bool = false
    @State var animatedContent: Bool = false
    @State var scollOffset: CGFloat = 0
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 30) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MONDAY 4 APRIL")
                            .font(.callout)
                            .foregroundStyle(.gray)
                        
                        Text("Today")
                            .font(.largeTitle.bold())
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                    }

                }
                .padding(.bottom)
                .padding(.horizontal)
                .opacity(showDetailPage ? 0 : 1)
                
                ForEach(items) { item in
                    Button {
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                            currentItem = item
                            showDetailPage = true
                        }
                    } label: {
                        cardView(item: item)
                            .scaleEffect(currentItem?.id == item.id && showDetailPage ? 1 : 0.93)
                    }
                    .buttonStyle(ScaledButtonStyle())
                    .opacity(showDetailPage ? (currentItem?.id == item.id  ? 1 : 0) : 1)
                }
            }
            .padding(.vertical)
        }
        .overlay {
            if let currentItem = currentItem, showDetailPage {
                detailView(item: currentItem)
                    .ignoresSafeArea(.container, edges: .top)
            }
        }
        .background(alignment: .top) {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.gray)
                .frame(height: animatedView ? nil : 350, alignment: .top)
                .scaleEffect(animatedView ? 1 : 0.93)
                .opacity(animatedView ? 1 : 0)
                .ignoresSafeArea()
        }
    }
    
    func cardView(item: Today) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            ZStack(alignment: .topLeading) {
                GeometryReader { proxy in
                    let size = proxy.size
                    Image(item.artWork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .background(Color.red)
                        .clipShape(CustomCornor(corners: [.topLeft, .topRight], radius: 15))
                }
                .frame(height: 400)
                
                LinearGradient(
                    colors: [
                        .black.opacity(0.5),
                        .black.opacity(0.2),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.platformTitle.uppercased())
                        .font(.callout)
                        .fontWeight(.semibold)
                    
                    Text(item.bannerTitlte)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.leading)
                }
                .foregroundColor(.primary)
                .padding()
                .offset(y: currentItem?.id == item.id && animatedView ? safeArea().top : 0)
            }
            HStack(spacing: 12) {
                Image(item.appLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .frame(width: 60, height: 60, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.platformTitle.uppercased())
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Text(item.platformTitle)
                        .fontWeight(.bold)
                    
                    Text(item.platformTitle)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("GET")
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background {
                            Capsule().fill(.ultraThinMaterial)
                        }
                }

            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.gray)
        }
        .matchedGeometryEffect(id: item.id, in: animation)
    }
    
    func detailView(item: Today) -> some View {
        ScrollView {
            VStack {
                cardView(item: item)
                    .scaleEffect(animatedView ? 1 : 0.93)
                
                VStack(spacing: 15) {
                    Text(dummyText)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(10)
                        .padding(.bottom, 20)
                    
                    Divider()
                    
                    Button {
                        
                    } label: {
                        Label {
                            Text("Share Story")
                        } icon: {
                            Image(systemName: "square.and.arrow.up.fill")
                        }
                        .foregroundColor(.primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(.ultraThinMaterial)
                        }

                    }

                }
                .padding()
                .offset(y: scollOffset > 0 ? scollOffset : 0)
                .opacity(animatedContent ? 1 : 0)
                .scaleEffect(animatedContent ? 1 : 0, anchor: .top)
            }
            .offset(y: scollOffset > 0 ? -scollOffset : 0)
            .offset(offset: $scollOffset)
        }
        .coordinateSpace(name: "SCROLL")
        .overlay(alignment: .topTrailing, content: {
            Button {
                // closing view
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7) ) {
                    animatedView = false
                    animatedContent = false
                }
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7).delay(0.05)) {
                    currentItem = nil
                    showDetailPage = false
                }
                
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .padding()
            .padding(.top, safeArea().top)
//            .offset(y: -10)
            .opacity(animatedView ? 1 : 0)

        })
        .onAppear {
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7) ) {
                animatedView = true
            }
            
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7).delay(0.1)) {
                animatedContent = true
            }
        }
//        .transition(.identity)4
    }
}


#Preview {
    Home()
        .preferredColorScheme(.dark)
}


struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.easeIn, value: configuration.isPressed)
    }
}

extension View {
    func safeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        return safeArea
    }
    
    func offset(offset: Binding<CGFloat>) -> some View {
        return self.overlay {
            GeometryReader { proxy in
                let minY = proxy.frame(in: .named("SCROLL")).minY
                Color.clear
                    .preference(key: OffsetKey.self, value: minY)
            }
        }
        .onPreferenceChange(OffsetKey.self) { value in
            offset.wrappedValue = value
        }
    }
}


struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
