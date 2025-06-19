//
//  AddMoodView.swift
//  MoodApp
//
//  Created by Renjun Li on 2025/6/19.
//


import SwiftUI

struct AddMoodView: View {
    enum Constants {
        static let headerH: CGFloat = 150
        static let containerMaxPadding: CGFloat = 40
        static let containerMinPadding: CGFloat = 0
        static let containerMaxTopPadding: CGFloat = 80
    }
    @State private var expand: Bool = false
    var body: some View {
        ZStack(alignment: .top) {
            contentView
            headerView
        }
      
        .frame(width: expand ? UIScreen.main.bounds.width : UIScreen.main.bounds.width - Constants.containerMaxPadding *  2)
        .frame(height: expand ? UIScreen.main.bounds.height - Constants.containerMaxTopPadding: Constants.headerH)
        .background(content: {
            RoundedRectangle(cornerRadius: 10)
                .fill(.clear)
        })
        .frame(maxHeight: .infinity, alignment: .bottom)
        .animation(.easeInOut(duration: 0.5), value: expand)
       
    }
    
    var emojiView: some View {
        GeometryReader { proxy in
            let iconW: CGFloat = 40
            let horizontInset: CGFloat = 20
            let spacing = (proxy.size.width - iconW * 5 - horizontInset * 2) / 4
            HStack(spacing: spacing) {
                RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                    .fill(.yellow)
                    .frame(width: iconW, height: iconW)
                    .onTapGesture {
                        expand.toggle()
                    }

                RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                    .fill(.red)
                    .fill(expand ? Color.green : Color.red)
                    .frame(width: iconW, height: iconW)
                    .onTapGesture {
                        expand.toggle()
                    }
                
                Button {} label: {
                    RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                        .fill(.yellow)
                        .frame(width: iconW, height: iconW)
                }
                
                Button {} label: {
                    RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                        .fill(.purple)
                        .frame(width: iconW, height: iconW)
                }
                
                Button {} label: {
                    RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                        .fill(.pink)
                        .frame(width: iconW, height: iconW)
                }
                
            }
            .padding(.vertical, 20)
            .padding(.horizontal, horizontInset)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(height: 70)
       
    }
    
    var headerView: some View {
        GeometryReader { proxy in
            VStack(spacing: .zero) {
                Text("What is your mood")
                    .padding(.top, 20)
               emojiView
            }
            .frame(width: proxy.size.width)
            .background(MoodColor.backgroundWhite.color)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
        }
        .frame(height: Constants.headerH)
        .background(.clear)
    }
    
    var contentView: some View {
        GeometryReader { proxy in
            VStack {
                FontPanel()
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(MoodColor.backgroundWhite.color)
            .background(.red)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
           
        }
        .frame(height: expand ? UIScreen.main.bounds.height - Constants.containerMaxTopPadding : 0)
    }
}
