//
//  MusicHome.swift
//  App
//
//  Created by Renjun Li on 2024/8/17.
//

import SwiftUI

struct MusicHome: View {
    @State private var expandShape: Bool = false
    @Namespace private var animation
    
    var body: some View {
        TabView {
            sampleTab(title: "Listen Now", icon: "play.circle.fill")
            sampleTab(title: "Browse", icon: "square.grid.2x2.fill")
            sampleTab(title: "Radio", icon: "dot.radiowaves.left.and.right")
            sampleTab(title: "Music", icon: "play.square.stack")
            sampleTab(title: "Search", icon: "magnifyingglass")
        }
        .tint(.red)
        .safeAreaInset(edge: .bottom) {
            customBottomSheet()
        }
        .overlay {
            if expandShape {
                ExpandBottomSheet(expnadSheet: $expandShape, animation: animation)
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: -5)))
            }
        }
 
    }
    
    func customBottomSheet() -> some View {
        ZStack {
            VStack {
                if expandShape {
                    Rectangle()
                        .fill(.clear)
                } else {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            MusicInfo(expandSheet: $expandShape, animation: animation)
                        }
                        .matchedGeometryEffect(id: "BGIVEW", in: animation)
                }
            }
        }
        .frame(height: 70)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 1)
                .offset(y: -5)
        }
        .offset(y: -49)
    }
    
    @ViewBuilder
    func sampleTab(title: String, icon: String) -> some View {
        ScrollView {
            Text(title)
                .padding(.top, 25)
        }
            .tabItem {
                Image(systemName: icon)
              
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbar(expandShape ? .hidden : .visible, for: .tabBar)
    }
}

struct MusicInfo: View {
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                if !expandSheet {
                    GeometryReader {
                        let size = $0.size
                        Image("Artwork")
                            .resizable()
                            .background(.red)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: expandSheet ? 15 : 5, style: .continuous))
                        
                    }
                    .matchedGeometryEffect(id: "ARTWORK", in: animation)
                }
            }
            .frame(width: 45, height: 45)
          
            .frame(width: 45, height: 45)
            
            Text("Look what you made me do")
                .fontWeight(.semibold)
                .lineLimit(1)
                .padding(.horizontal, 15)
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "pause.fill")
                    .font(.title2)
                
            }
            Button {
                
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
                
            }

        }
        .foregroundStyle(.primary)
        .padding(.horizontal)
        .padding(.bottom, 5)
        .frame(height: 70)
        .containerShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                expandSheet = true
            }
        }
    }
    
}

#Preview {
    MusicHome()
        .preferredColorScheme(.dark)
}


struct ExpandBottomSheet: View {
    @Binding var expnadSheet: Bool
    var animation: Namespace.ID
    @State private var animateContent: Bool = false
    @State var offsetY: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let safeArea = proxy.safeAreaInsets
            ZStack {
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(content: {
                        Rectangle()
                            .fill(Color.gray)
                            .opacity(animateContent ? 1 : 0)
                    })
                    .overlay(alignment: .top) {
                        MusicInfo(expandSheet: $expnadSheet, animation: animation)
                            .allowsTightening(false)
                            .opacity(animateContent ? 0 : 1)
                    }
                    .matchedGeometryEffect(id: "BGIVEW", in: animation)
                
                VStack(spacing: 15) {
                    Capsule()
                        .fill(.yellow)
                        .frame(width: 40, height: 5)
                        .opacity(animateContent ? 1: 0)
                        .offset(y: animateContent ? 0 : size.height)
                    
                    GeometryReader {
                        let size = $0.size
                        Image("ArtWork")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .background(.red)
                            .clipShape(RoundedRectangle(cornerRadius: animateContent ? 15 : 5, style: .continuous))
                    }
                    .matchedGeometryEffect(id: "ARTWORK", in: animation)
                    .frame(height: size.width - 50)
                    .padding(.vertical, size.height < 700 ? 10 : 30)
                    
                    playerView(size)
                        .offset(y: animateContent ? 0 : size.height)
                }
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()
            }
            .contentShape(Rectangle())
            .offset(y: offsetY)
            .gesture(DragGesture()
                .onChanged({ value in
                    let translationY = value.translation.height
                    offsetY = translationY > 0 ? translationY : 0
                })
                    .onEnded({ value in
                        withAnimation {
                            if offsetY > size.height * 0.4 {
                                animateContent = false
                                expnadSheet = false
                            } else {
                                offsetY = .zero
                            }
                           
                        }
                    })
            )
            .ignoresSafeArea(.all)
        }
       
        .onAppear {
            withAnimation {
                animateContent =  true
            }
        }
    }
    
    
    func playerView(_ mainSize: CGSize) -> some View {
        GeometryReader {
            let size = $0.size
            let spacing = size.height * 0.04
            VStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    HStack(alignment: .center, spacing: 4) {
                        Text("Look What you Made me do")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Tayler swift")
                            .foregroundStyle(.gray)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .padding(12)
                                .background {
                                    Circle()
                                        .fill()
                                        .environment(\.colorScheme, .light)
                                }
                        }
                    }
                    
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .light)
                        .frame(height: 5)
                        .padding(.top, spacing)
                    
                    HStack {
                        Text("0:00")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer(minLength: 0)
                        Text("3:00")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                }
                .frame(height: size.height / 2.5)
                HStack(spacing: size.width * 0.18) {
                    Button {
                        
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(size.height < 300 ? .title3 : .title)
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "pause.fill")
                            .font(size.height < 300 ? .title3 : .title)
                    }
                    
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(size.height < 300 ? .title3 : .title)
                    }

                }
                .foregroundColor(.white)
                .frame(maxHeight: .infinity)
            }
        }
    }
}

