//
//  DialogExampleView.swift
//  App
//
//  Created by Renjun Li on 2024/9/5.
//

import SwiftUI

struct DialogExampleView: View {
    @State private var showPopup: Bool = false
    @State private var inputText: String = ""
    
    var body: some View {
        NavigationStack {
            Button("Unlock") {
                showPopup.toggle()
            }
            .navigationTitle("Documents")
        }
        .sheet(isPresented: $showPopup, content: {
            VStack {
                Text("Edit")
                Text("You can change the name of your device here.")
                TextField("Place", text: $inputText)
                    .padding(.horizontal, 20)
                HStack {
                    Button("Cancel") {
                        showPopup.toggle()
                    }
                    
                    Button("Save") {
                        showPopup.toggle()
                    }
                }
            }
            
            .frame(height: 400)
            .frame(maxWidth: .infinity)
            .background(.white)
            .presentationDetents([.height(400)])
        })

    }
}

struct CustomAlertWithTextField: View {
    @Binding var show: Bool
    var onUnlock: (String) -> ()
    @State private var password: String = ""
    
    
    var body: some View {
        VStack(spacing: .zero) {
            Image(systemName: "person.bage.key.fill")
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 65, height: 65)
                .background {
                    Circle()
                        .fill(.blue.gradient)
                        .background {
                            Circle()
                                .fill(.background)
                                .padding(-5)
                        }
                }
            
            Text("Locked File")
                .fontWeight(.semibold)
            
            Text("This file has been locked by user, pls enter the password")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.top, 5)
            
            SecureField("password", text: $password)
                .padding(.vertical, 19)
                .padding(.horizontal, 15)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.bar)
                }
                .padding(.vertical, 10)
            
            HStack(spacing: 10) {
                Button {
                    show = false
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.red.gradient)
                        }
                }
                
                Button {
                    show = true
                    onUnlock(password)
                } label: {
                    Text("Unlock")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.gradient)
                        }
                }
            }
            
        }
        .frame(width: 250)
        .padding([.horizontal, .bottom], 25)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(.background)
                .padding(.top, 25)
        }
    }
}

#Preview {
    DialogExampleView()
}
