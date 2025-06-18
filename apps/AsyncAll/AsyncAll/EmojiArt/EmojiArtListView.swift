//
//  EmojiArtListView.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/16.
//

import SwiftUI

struct EmojiArtListView: View {
    @EnvironmentObject var model: EmojiArtModel
    
    /// The latest error message.
    @State var lastErrorMessage = "None" {
      didSet {
        isDisplayingError = true
      }
    }
    @State var isDisplayingError = false

    @State var isDisplayingPreview = false
    @State var selected: ImageFile?
    
    var colums: [GridItem] = [
        GridItem(.flexible(minimum: 50, maximum: 120)),
        GridItem(.flexible(minimum: 50, maximum: 120)),
        GridItem(.flexible(minimum: 50, maximum: 120)),
    ]
    
    var body: some View {
        VStack {
            Text("Emoji Art")
              .font(.custom("YoungSerif-Regular", size: 36))
              .foregroundColor(.pink)
            
            GeometryReader { geo in
                ScrollView {
                    LazyVGrid(columns: colums, spacing: 2) {
                        ForEach(model.imageFeed) { image in
                            
                            VStack(alignment: .center, spacing: 20) {
                                Button(action: {
                                    selected = image
                                }, label: {
                                    ThumbImage(file: image)
                                        .frame(width: geo.size.width / 3 * 0.75, height: geo.size.width / 3 * 0.75)
                                        .clipped()
                                        .padding(.horizontal, 2)
                                        .padding(.vertical, 4)
                                })
                                
                                Text(image.name)
                                  .fontWeight(.bold)
                                  .font(.caption)
                                  .foregroundColor(.gray)
                                  .lineLimit(2)

                                Text(String(format: "$%.2f", image.price))
                                  .font(.caption2)
                                  .foregroundColor(.black)
                            }
                            .frame(height: geo.size.width / 3 + 20, alignment: .top)
                        }
                    }
                }
            }
            .alert("Error", isPresented: $isDisplayingError, actions: {
              Button("Close", role: .cancel) { }
            }, message: {
              Text(lastErrorMessage)
            })
            .sheet(isPresented: $isDisplayingPreview, onDismiss: {
                selected = nil
            }, content: {
                if let selected {
                    DetailsView(file: selected)
                }
            })
            .onChange(of: selected) { oldValue, newValue in
                isDisplayingPreview = newValue != nil
            }
            
            BottomToolbar()
        }
    }
}
