//
//  ActionSheet.swift
//  UIComponent
//
//  Created by Renjun Li on 2024/9/23.
//

import SwiftUI

public struct ActionSheetHome: View {
    @State private var isPreseneted: Bool = false
    @State private var presenFullScreenCover: Bool = false
    @State private var animateView: Bool = true
    
    public init(isPreseneted: Bool = false) {
        self.isPreseneted = isPreseneted
    }
    
    public var body: some View {
        let screenHeight = UIScreen.main.bounds.height
        let animateView = animateView
        
        VStack {
            Button("Show") {
                isPreseneted = true
            }
        }
    }
}


