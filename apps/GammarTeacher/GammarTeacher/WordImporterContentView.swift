//
//  ContentView 2.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/18.
//


import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Query(sort: \WordItem.createdTime, order: .reverse) private var words: [WordItem]
    @Environment(\.modelContext) private var modelContext
    
    @State private var isImporting = false
    @State private var importResult: String = ""
    @State private var showingAlert = false
    @State private var isSelectingModel = false
    @State private var modelPath: String? = UserDefaults.standard.string(forKey: "modelPath")
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                Text("Total Words: \(words.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                List(words) { word in
                    VStack(alignment: .leading) {
                        Text(word.spelling)
                            .font(.headline)
                        Text(word.chineseDefinition.replacingOccurrences(of: "\n", with: " "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 250, ideal: 300)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isImporting = true }) {
                        Label("Import JSON", systemImage: "square.and.arrow.down")
                    }
                }
                
                // 清空数据库按钮 (测试用)
                ToolbarItem {
                    Button(action: clearAllData) {
                        Label("Clear All", systemImage: "trash")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        // 传入所有单词进行测试（后续会改成传入 SRS 筛选后的单词）
                        PracticeView(wordsToPractice: words)
                    } label: {
                        Label("Start Session", systemImage: "play.fill")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button(action: { isSelectingModel = true }) {
                        Label("Select Model", systemImage: "cpu")
                    }
                }
            }
        } detail: {
            Text("Select a word to preview detail")
        }
        // 文件选择器配置
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                // 安全访问文件权限
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                
                do {
                    let (added, skipped) = try JSONImporter.shared.importJSON(from: url, into: modelContext)
                    importResult = "Success: \(added) added, \(skipped) skipped (duplicates)."
                    showingAlert = true
                } catch {
                    importResult = "Error: \(error.localizedDescription)"
                    showingAlert = true
                }
            case .failure(let error):
                importResult = "Import Failed: \(error.localizedDescription)"
                showingAlert = true
            }
        }
        .fileImporter(
            isPresented: $isSelectingModel,
            allowedContentTypes: [.folder], // 选择文件夹
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                // 获取权限
                guard url.startAccessingSecurityScopedResource() else { return }
                // 注意：实际开发中需要处理 Security Scoped Bookmark 以便下次自动加载
                // 这里简化处理，直接存路径字符串（重启可能失效，需手动重选，MVP足够）
                let path = url.path(percentEncoded: false)
                modelPath = path
                UserDefaults.standard.set(path, forKey: "modelPath")
                url.stopAccessingSecurityScopedResource()
            case .failure(let error):
                print(error)
            }
        }
        
        .alert("Import Status", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importResult)
        }
    }
    
    private func clearAllData() {
        try? modelContext.delete(model: WordItem.self)
    }
}
