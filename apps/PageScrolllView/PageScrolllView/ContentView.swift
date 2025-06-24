//
//  ContentView.swift
//  PageScrolllView
//
//  Created by Renjun Li on 2025/6/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HeaderPageScrolllView(
            displaySymbols: false,
            header: {
                Rectangle()
                    .fill(.blue.gradient)
                    .cornerRadius(10)
                    .frame(height: 350)
                
            },
            labels: {
                PageLabel(title: "Posts", symbolImage: "square.grid.3x3.fill")
                PageLabel(title: "Reels", symbolImage: "square.grid.3x3.fill")
                PageLabel(title: "Tagged", symbolImage: "square.grid.3x3.fill")
            },
            pages: {
                Text("Posts")
                Text("Reels")
                Text("Tagged")
            },
          onRefresh: {
            
        })
    }
}

#Preview {
    ContentView()
}
 
