//
//  BlabberLoginView.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/10.
//



import SwiftUI

struct BlabberLoginView: View {
  @AppStorage("username") var usernanme = ""
  @State var isDisplayingChat = false
  @State var model = BlabberModel()
  
  
  var body: some View {
    VStack {
      Text("Blabber")
        .font(.custom("Lemon", size: 48))
        .foregroundColor(Color.teal)
      
      HStack {
        TextField(text: $usernanme, prompt: Text("Username")) {}
          .textFieldStyle(RoundedBorderTextFieldStyle())
        
        Button(action: {
          model.username = usernanme
          self.isDisplayingChat = true
        }, label: {
          Image(systemName: "arrow.right.circle.fill")
            .font(.title)
            .foregroundStyle(.teal)
        })
        .sheet(isPresented: $isDisplayingChat) {
          ChatView(model: model)
        }
      }.padding(.horizontal)
      
    }
    .statusBarHidden()
  }
}
