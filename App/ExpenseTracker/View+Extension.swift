//
//  View+Extension.swift
//  App
//
//  Created by Renjun Li on 2024/8/19.
//

import SwiftUI

extension View {
    func hSpacing(_ alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
  
    func vSpacing(_ alignment: Alignment = .center) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
//    
//    var safeArea: UIEdgeInsets {
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            return windowScene.keyWindow?.safeAreaInsets ?? .zero
//        }
//        return .zero
//    }
    
    var currencySymbol: String {
        let locale = Locale.current
        return locale.currencySymbol ?? ""
    }
}

extension Double {
    func currencyString(_ allowedDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = allowedDigits
        return formatter.string(from: .init(value: self)) ?? ""
    }
}


