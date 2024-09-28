//
//  InputField.swift
//  UIComponent
//
//  Created by Renjun Li on 2024/9/28.
//

import SwiftUI

struct InputField: View {
    @Binding private var text: String
    @State private var isHiddenClose: Bool = true
    private let placeholder: String
    private let maxInputCount: Int
    
    init(text: Binding<String>,
         placeholder: String,
         maxInputCount: Int) {
        self._text = text
        self.placeholder = placeholder
        self.maxInputCount = maxInputCount
    }
    
    var body: some View {
        HStack {
            HStack {
                TextField(text: $text) {
                    HStack {
                        Text(placeholder)
                            .foregroundStyle(.red)
                    }
                }
                .tint(.black)
                Spacer()
                Button {
                    self.text = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                        .opacity(isHiddenClose ? 0 : 1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
//        .frame(minHeight: 40)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray)
        }
        .onChange(of: text) { oldValue, newValue in
            withAnimation {
                isHiddenClose = newValue.isEmpty
            }
            if newValue.count > maxInputCount {
                text = String(newValue.prefix(maxInputCount))
            }
        }
    }
}

struct InputFieldView: View {
    @State var text: String = ""
    
    var body: some View {
        InputField(text: $text,
                   placeholder: "请输入",
                   maxInputCount: 4)
            .padding()
    }
}

#Preview(body: {
    InputFieldView()
})
