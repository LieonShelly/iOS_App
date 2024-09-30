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
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 12, day: 15)
        let endComponents = DateComponents(year: 2021, month: 12, day: 30, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
        ...
        calendar.date(from:endComponents)!
    }()
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 700)
            DatePicker("Enter your birthday",
                       selection: $date,
                       in: dateRange,
                       displayedComponents: [.date]
            )
            .padding()
            .datePickerStyle(.graphical)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color.red)
            .padding()
            Spacer()
                .frame(height: 700)
        }
       
        
        
        
     
    }
    
    @State private var date = Date.now
}

#Preview(body: {
    InputFieldView()
})



struct CustomDatePickerSyle: DatePickerStyle {
    
    var date: Date
    var text: String?
    @Binding var isDatePickerVisible: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: "calendar")
            Text(text ?? "")
            Text(date, formatter: DateFormatter.customFormatter)
                .foregroundStyle(.blue)
                .font(.body)
        }
        .onTapGesture {
            withAnimation(.bouncy) {
                isDatePickerVisible.toggle()
            }
        }
        
    }
}

/// Maybe declare your custom formatter too
extension DateFormatter {
    static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM:d:yyyy"
        return formatter
    }()
}
