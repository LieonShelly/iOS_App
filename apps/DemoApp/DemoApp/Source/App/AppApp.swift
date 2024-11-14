//
//  AppApp.swift
//  App
//
//  Created by Renjun Li on 2024/7/26.
//

import SwiftUI
import SwiftData
import UIComponent

@main
struct AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Transaction.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            QRCodeScannerViewHome(service: ScannerService())
//            DemoContentView()
        }
    }
}


struct DemoContentView: View {
    @State private var offsetY: CGFloat = -300 // 初始位置在屏幕上方
       @State private var opacity: Double = 0.0
       @State private var isAnimating = false
       
       var body: some View {
           VStack {
               Rectangle()
                   .fill(Color.blue)
                   .frame(width: 100, height: 100)
                   .opacity(opacity)
                   .offset(y: offsetY)
                   .onAppear {
                       startAnimationSequence()
                   }
           }
       }
       
       // Animation sequence function
       private func startAnimationSequence() {
           withAnimation(
               Animation.linear(duration: 2.0)
                   .repeatForever(autoreverses: false)
           ) {
               offsetY = 300 // 将视图从上移动到底部
           }
           
           Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
               withAnimation(Animation.linear(duration: 2)) {
                   opacity = 1.0 // 前0.5秒透明度从0到1
               }
               
               DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                   withAnimation(Animation.linear(duration: 2)) {
                       opacity = 0.0 // 在1.5~2秒透明度从1到0
                   }
               }
           }
       }
}
