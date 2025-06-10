//
//  StorageListView.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/9.
//

import SwiftUI

struct StorageListView: View {
  let model: SuperStorageModel
  @State var files: [DownloadFile] = []
  @State var status = ""
  @State var selected = DownloadFile.empty {
    didSet {
      isDisplayingDownload = true
    }
  }
  @State var isDisplayingDownload = false
  @State var lastErrorMessage = "None" {
    didSet {
      isDisplayingError = true
    }
  }
  @State var isDisplayingError = false
  
  var body: some View {
    VStack {
      List {
        Section(content: {
          if files.isEmpty {
            ProgressView().padding()
          }
          ForEach(files) { file in
            Button(
              action: {
                selected = file
              },
              label: {
                FileListItem(file: file)
              }
            )
          }
        }, header: {
          Label(" SuperStorage", systemImage: "externaldrive.badge.icloud")
            .font(.custom("SerreriaSobria", size: 27))
            .foregroundColor(.accentColor)
            .padding(.bottom, 20)
        }, footer: {
          Text(status)
        })
      }
      .listStyle(.insetGrouped)
      .animation(.easeOut(duration: 0.33), value: files)
    }
    .alert("Error", isPresented: $isDisplayingError, actions: {
      Button("Close", role: .cancel) {}
    }, message: {
      Text(lastErrorMessage)
    })
    .task {
      guard files.isEmpty else { return }
      do {
        async let files = try model.avaiableFiles()
        async let status = try model.status()
        let (fileResult, statusResult) = try await (files, status)
        self.files = fileResult
        self.status = statusResult
      } catch {
        lastErrorMessage = error.localizedDescription
      }
    }
    .navigationDestination(
      isPresented: $isDisplayingDownload,
      destination: {
        DownloadView(file: selected).environmentObject(model)
      })
  }
}
