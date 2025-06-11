//
//  ChatView.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/10.
//

import SwiftUI

struct ChatView: View {
  @ObservedObject var model: BlabberModel
  @FocusState var focused: Bool
  @State var message: String = ""
  @State var lastErrorMessage = "" {
    didSet {
      isDisplayingError = true
    }
  }
  @State var isDisplayingError = false
  @Environment(\.presentationMode) var presentationMode
  
  var body: some View {
    VStack {
      ScrollView(.vertical) {
        ScrollViewReader { reader in
          ForEach($model.message) { message in
            MessageView(message: message, myUser: model.username)
          }
          .onChange(of: model.message.count) { oldValue, newValue in
            guard let last = model.message.last else { return }
            
            withAnimation(.easeOut) {
              reader.scrollTo(last.id, anchor: .bottomTrailing)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      HStack {
        Button(action: {}, label: {
          Image(systemName: "location.circle.fill")
            .font(.title)
            .foregroundColor(Color.gray)
        })
        
        Button(action: {}, label: {
          Image(systemName: "timer")
            .font(.title)
            .foregroundColor(Color.gray)
        })
        
        TextField(text: $message, prompt: Text("Message")) {
          Text("Enter message")
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .focused($focused)
        .onSubmit {
          Task {
            try await model.say(message)
            message = ""
          }
          focused = true
        }
        
        Button(action: {
          Task {
            try await model.say(message)
            message = ""
          }
        }, label: {
          Image(systemName: "arrow.up.circle.fill")
            .font(.title)
        })
      }
    }
    .padding()
    .onAppear {
      focused = true
    }
    .alert("Error", isPresented: $isDisplayingError, actions: {
      Button("CLose", role: .cancel) {
        self.presentationMode.wrappedValue.dismiss()
      }
    }, message: {
      Text(lastErrorMessage)
    })
    .task {
      do {
        try await model.chat()
      } catch {
        lastErrorMessage = error.localizedDescription
      }
    }
  }
}
