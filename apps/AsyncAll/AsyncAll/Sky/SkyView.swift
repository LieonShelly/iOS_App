//
//  SkyView.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/13.
//

import SwiftUI

struct SkyView: View {
    @ObservedObject var scanModel = ScanModel(total: 20, localName: UIDevice.current.name)
    @State var isScanning = false
    
    @State var lastMessage = "" {
        didSet {
            isDisplayingMessage = true
        }
    }
    @State var isDisplayingMessage = false
    
    var titleView: some View {
        Text("s|2 |2k|0 |1y|3")
          .font(.custom("Datalegreya-Gradient", size: 36, relativeTo: .largeTitle))
    }
    
    var body: some View {
        VStack {
            titleView
            
            Text("Scanning deep space")
                .font(.subheadline)
            
            ScanningView(
                total: $scanModel.total,
                completed: $scanModel.completed,
                perSecond: $scanModel.countPerSecond,
                scheduled: $scanModel.scheduled
            )
            
            Button(action: {
                Task {
                    isScanning = true
                    do {
                        let start = Date().timeIntervalSinceReferenceDate
                        try await scanModel.runAllTasks()
                        let end = Date().timeIntervalSinceReferenceDate
                        lastMessage = String(
                          format: "Finished %d scans in %.2f seconds.",
                          scanModel.total,
                          end - start
                        )
                    } catch {
                        lastMessage = error.localizedDescription
                    }
                    isScanning = false
                }
                
            }, label: {
                HStack(spacing: 6) {
                    if isScanning {
                        ProgressView()
                    }
                    Text("Engage systems")
                }
            })
            .buttonStyle(.bordered)
            .disabled(isScanning)
        }
        .alert("Message", isPresented: $isDisplayingMessage, actions: {
          Button("Close", role: .cancel) { }
        }, message: {
          Text(lastMessage)
        })
        .padding()
        .statusBar(hidden: true)
    }
}

