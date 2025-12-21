//
//  ContentView.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/15.
//
import SwiftUI

struct GrammarContentView: View {
    @State private var inputText = "I has a apple and he go too school yesterday."
    @State private var outputText = ""
    @State private var isLoading = false
    @State private var isModelLoaded = false
    @State private var statusMessage = "Waiting to load model..."
    
   var engine = GrammarEngine()
    
    var body: some View {
        HStack(spacing: 0) {
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
            
            VStack(alignment: .leading) {
                Text("AI Correction")
                    .font(.headline)
                    .padding(.top)
                    .foregroundStyle(.blue)
                
                ScrollView {
                    Text(LocalizedStringKey(outputText))
                        .font(.body)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .animation(.default, value: outputText)
                }
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
                
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
            loadAI()
        }
    }
    
    func loadAI() {
        Task {
            statusMessage = "Loading 3B Model into Memory..."
            do {
                let modelPath = "/Users/renjunli/Downloads/Llama-3.2-3B-Instruct-4bit"
                try await engine.loadModel(from: modelPath)
                isModelLoaded = true
                statusMessage = "Model Ready (Quantized 4-bit)"
            } catch {
                statusMessage = "Error loading model: \(error.localizedDescription)"
            }
        }
    }
    
    func runCorrection() {
        guard isModelLoaded else { return }
        
        isLoading = true
        outputText = ""
        statusMessage = "Generating..."
        
        Task {
            for await token in await engine.fixGrammar(for: inputText) {
                outputText += token
            }
            isLoading = false
            statusMessage = "Done."
        }
    }
}
