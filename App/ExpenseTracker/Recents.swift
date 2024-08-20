//
//  Recents.swift
//  App
//
//  Created by Renjun Li on 2024/8/18.
//

import SwiftUI

struct Recents: View {
    @AppStorage("userName") private var userName: String = ""
    @State private var startDate: Date = .now.startOfMonth
    @State private var endDate: Date = .now.endOfMonth
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
                        Section {
                            Button {
                                
                            } label: {
                                Text("\(startDate.format("dd - MM yy")) to \(endDate.format("dd - MM yy"))")
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            }
                            .hSpacing(.leading)
                            
                            CardView(income: 100, expense: 200)

                        } header: {
                            headerView(size)
                        }
                    }
                    .padding(15)
                }
                .background(.gray.opacity(0.15))
            }
        }
    }
    
    @ViewBuilder
    func headerView(_ size: CGSize) -> some View {
        HStack(spacing: 20, content: {
            VStack(alignment: .leading, spacing: 5) {
                Text("Welcome!")
                    .font(.title.bold())
                if !userName.isEmpty {
                    Text(userName)
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
            .visualEffect({ content, proxy in
                content.scaleEffect(headerScale(size, proxy: proxy), anchor: .topLeading)
            })
            
            Spacer()
            NavigationLink {
                
            } label: {
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
                    .background(appTint.gradient, in: .circle)
                    .contentShape(.circle)
            }
        })
        .padding(.bottom, userName.isEmpty ? 10 : 5)
        .background {
            VStack(spacing: .zero) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                Divider()
            }
            .visualEffect({ content, geometry in
                content.opacity(headerBGOpacity(geometry))
            })
            .padding(.horizontal, -15)
            .padding(.top, -(safeArea().top + 15))
        }
    }
    
    func headerBGOpacity(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY + safeArea().top
        return minY > 0 ? 0 : (-minY / 15)
    }
    
    func headerScale(_ size: CGSize, proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        let screenHeight = size.height
        
        let progress = minY / screenHeight
        let scale = min(max(progress, 0), 1) * 0.6
        return 1 + scale
    }
}


#Preview {
    ContentView()
}
 
