//
//  ContentView.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/15.
//
import SwiftUI

struct ContentView: View {
    // ⚠️ 必填：请把这里替换为你终端里下载模型的那个文件夹路径
    // 例如: "/Users/yourname/Documents/AI-Projects/Llama-3.2-3B-Instruct-4bit"
    // 你可以在 Finder 里找到那个文件夹，按住 Option 键右键 -> "Copy as Pathname"
    let MODEL_PATH = "/Users/renjunli/Downloads/Llama-3.2-3B-Instruct-4bit"
    
    @State private var inputText = "I has a apple and he go too school yesterday." // 这是一个故意写错的测试句
    @State private var outputText = ""
    @State private var isLoading = false
    @State private var isModelLoaded = false
    @State private var statusMessage = "Waiting to load model..."
    
    // 初始化引擎
    let engine = GrammarEngine()
    
    var body: some View {
        HStack(spacing: 0) {
            // 左边：输入区
            VStack(alignment: .leading) {
                Text("Original Text")
                    .font(.headline)
                    .padding(.top)
                TextEditor(text: $inputText)
                    .font(.body)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()
            
            Divider()
            
            // 右边：AI 修正区
            VStack(alignment: .leading) {
                Text("AI Correction")
                    .font(.headline)
                    .padding(.top)
                    .foregroundStyle(.blue)
                
                ScrollView {
                    Text(LocalizedStringKey(outputText)) // 👈 关键：用 LocalizedStringKey 触发 Markdown 解析
                        .font(.body)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .animation(.default, value: outputText) // 添加一点流畅的动画
                }
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
                
                // 底部状态栏与按钮
                HStack {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.5)
                    }
                    
                    Button("Fix Grammar ✨") {
                        runCorrection()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isModelLoaded || isLoading)
                }
                .padding(.top)
            }
            .padding()
        }
        .frame(minWidth: 800, minHeight: 500)
        .task {
            // App 启动时自动加载模型
            await loadAI()
        }
    }
    
    func loadAI() {
        Task {
            statusMessage = "Loading 3B Model into Memory..."
            do {
                try await engine.loadModel(from: MODEL_PATH)
                isModelLoaded = true
                statusMessage = "Model Ready (Quantized 4-bit)"
            } catch {
                statusMessage = "Error loading model: \(error.localizedDescription)"
                print(error)
            }
        }
    }
    
    func runCorrection() {
        guard isModelLoaded else { return }
        
        isLoading = true
        outputText = "" // 清空上一次结果
        statusMessage = "Generating..."
        
        Task {
            // 这是一个异步流，字会一个一个蹦出来
            for await token in await engine.fixGrammar(for: inputText) {
                outputText += token
            }
            isLoading = false
            statusMessage = "Done."
        }
    }
}
