//
//  DownloadView.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/10.
//
import SwiftUI


struct DownloadView: View {
  let file: DownloadFile
  @EnvironmentObject var model: SuperStorageModel
  @State var fileData: Data?
  @State var isDownloadActive = false
  @State var duration = ""
  @State var downloadTask: Task<Void, Error>? {
    didSet {
      timerTask?.cancel()
      guard isDownloadActive else { return }
      let startime = Date().timeIntervalSince1970
      let timerSequence = Timer.publish(every: 1, tolerance: 1, on: .main, in: .common)
        .autoconnect()
        .map { date -> String in
          let duration = Int(date.timeIntervalSince1970 - startime)
          return "\(duration)s"
        }
        .values
      
      timerTask = Task {
        for await duration in timerSequence {
          self.duration = duration
        }
      }
    }
  }
  @State var timerTask: Task<Void, Error>?
  
  var body: some View {
    List {
      FileDetails(
        file: file,
        isDownloading: !model.downloads.isEmpty,
        isDownloadActive: $isDownloadActive,
        downloadSingleAction: {
          isDownloadActive = true
          Task {
            do {
              fileData = try await model.download(file: file)
            } catch {}
            isDownloadActive = false
          }
        },
        downloadWithUpdatesAction: {
          isDownloadActive = true
          downloadTask = Task {
            do {
              try await SuperStorageModel
                .$supportsPartrialDownloads
                .withValue(file.name.hasSuffix(".jpeg")) {
                  fileData = try await model.downloadWithProgress(file: file)
                }
            } catch {}
            isDownloadActive = false
          }
        },
        downloadMultipleAction: {
          isDownloadActive = true
          Task {
            do {
              fileData = try await model.multiDownloadWithProgress(file: file)
            } catch {}
            isDownloadActive = false
          }
        }
      )
      
      if !model.downloads.isEmpty {
        Downloads(downloads: model.downloads)
      }
      if !duration.isEmpty {
        Text("Duration:\(duration)")
          .font(.caption)
      }
      if let fileData {
        FilePreview(fileData: fileData)
      }
    }
    .animation(.easeIn(duration: 0.33), value: model.downloads)
    .listStyle(.insetGrouped)
    .toolbar {
      Button(
        action: {
          model.stopDownloads = true
          timerTask?.cancel()
        },
        label: { Text("Cancel All")}
      )
      .disabled(model.downloads.isEmpty)
    }
    .onDisappear {
      fileData = nil
      model.reset()
      downloadTask?.cancel()
    }
  }
}
