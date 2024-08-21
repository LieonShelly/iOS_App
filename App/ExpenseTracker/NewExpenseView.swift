//
//  NewExpenseView.swift
//  App
//
//  Created by Renjun Li on 2024/8/20.
//

import SwiftUI

struct NewExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    var editTransactoion: Transaction?
    @State private var title: String = ""
    @State private var remarks: String = ""
    @State private var amount: Double = .zero
    @State private var dateAdded: Date = .now
    @State private var category: Category = .expense
    @State var tint: TintColor = tints.randomElement()!
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Preview")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .hSpacing(.leading)
                
                TransactionCardView(transaction: .init(
                    title: title,
                    remarks: remarks,
                    amount: amount, 
                    dateAdded: dateAdded,
                    category: category,
                    tintColor: tint)
                )
                
                customSection(title: "Title", hint: "Magic keyboard", value: $title)
                customSection(title: "Remarks", hint: "Appele Product", value: $remarks)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Amount && Category")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .hSpacing(.leading)
                    
                    HStack(spacing: 15) {
                        HStack(spacing: 4) {
                            Text(currencySymbol)
                                .font(.callout.bold())
                            TextField("0.0", value: $amount, formatter: numberFormatter)
                                .keyboardType(.decimalPad)
                        }
                      
                            .padding(.horizontal, 15)
                            .padding(.vertical, 12)
                            .background(.background, in: .rect(cornerRadius: 10))
                            .frame(maxWidth: 130)
                           
                        
                        categoryCheckBox()
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Date")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .hSpacing(.leading)
                    
                    DatePicker("", selection: $dateAdded, displayedComponents: [.date])
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .background(.background, in: .rect(cornerRadius: 10))
                        .frame(maxWidth: 130)
                }
            }
            .padding(15)
        }
        .navigationTitle("Add Transaction")
        .background(.gray.opacity(0.15))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    save()
                }
            }
        }
        .onAppear {
            if let editTransactoion {
                title = editTransactoion.title
                remarks = editTransactoion.remarks
                amount = editTransactoion.amount
                dateAdded = editTransactoion.dateAdded
                category = Category(rawValue: editTransactoion.category) ?? .expense
                if let tint = tints.first(where: { $0.color == editTransactoion.tintColor }) {
                    self.tint = tint
                }
            }
        }
    }
    
    func categoryCheckBox() -> some View {
        HStack {
            ForEach(Category.allCases, id: \.rawValue) { category in
                HStack(spacing: 5) {
                    ZStack {
                        Image(systemName: "circle")
                            .font(.title3)
                            .foregroundStyle(appTint)
                        
                        if self.category == category {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundStyle(appTint)
                        }
                    }
                    Text(category.rawValue)
                        .font(.caption)
                }
                .contentShape(.rect)
                .onTapGesture {
                    self.category = category
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .hSpacing(.leading)
        .background(.background, in: .rect(cornerRadius: 10))
    }
    
    func customSection(title: String, hint: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
                .hSpacing(.leading)
            
            TextField(hint, text: value)
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(.background, in: .rect(cornerRadius: 10))
        }
    }
    
    func save() {
        if editTransactoion != nil {
            editTransactoion?.title = title
            editTransactoion?.remarks = remarks
            editTransactoion?.amount = amount
            editTransactoion?.category = category.rawValue
            editTransactoion?.tintColor = tint.color
            editTransactoion?.dateAdded = dateAdded
            
        } else {
            let transaction = Transaction(title: title, remarks: remarks, amount: amount, dateAdded: dateAdded, category: category, tintColor: tint)
            context.insert(transaction)
        }
     
        dismiss()
    }
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }
}

#Preview {
    NavigationStack {
        NewExpenseView()
    }
    
}
