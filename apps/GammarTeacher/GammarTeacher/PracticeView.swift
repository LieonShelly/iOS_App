//
//  PracticeView.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/18.
//


import SwiftUI

struct PracticeView: View {
    @State private var viewModel = QuizViewModel()
    let wordsToPractice: [WordItem]

    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            
            if let word = viewModel.currentWord {
                VStack(spacing: 10) {
                    Text(word.chineseDefinition)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    if viewModel.currentState == .punishment {
                        VStack {
                            Text("Copy this:")
                                .foregroundStyle(.secondary)
                            Text(word.spelling)
                                .font(.system(size: 40, weight: .bold, design: .monospaced))
                                .foregroundStyle(.red)
                                .tracking(2) // 增加字间距，看清拼写
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("??????")
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(height: 150)
                
                VStack(spacing: 15) {
                    TextField("", text: $viewModel.userInput)
                        .font(.system(size: 32, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(nsColor: .controlBackgroundColor))
                                .stroke(borderColor, lineWidth: 2)
                        )
                        .frame(maxWidth: 400)
                        .focused($isInputFocused)
                        .onSubmit {
                            viewModel.submitAnswer()
                        }
                    
                    Text(statusText)
                        .font(.headline)
                        .foregroundStyle(statusColor)
                        .animation(.easeInOut, value: viewModel.currentState)
                }
                
            } else {
                // --- 结束或初始状态 ---
                VStack {
                    Text("Ready?")
                        .font(.largeTitle)
                    Button("Start Practice") {
                        viewModel.startSession(words: wordsToPractice)
                        isInputFocused = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .padding()
        .onAppear {
            // 页面加载自动开始
            if !wordsToPractice.isEmpty {
                viewModel.startSession(words: wordsToPractice)
                isInputFocused = true
            }
        }
    }
    
    // --- 辅助 UI 逻辑 ---
    
    var borderColor: Color {
        switch viewModel.currentState {
        case .questioning: return .gray.opacity(0.3)
        case .success: return .green
        case .punishment: return .red
        default: return .clear
        }
    }
    
    var statusText: String {
        switch viewModel.currentState {
        case .punishment:
            return "Punishment Repetition: \(viewModel.punishmentCount) / \(viewModel.requiredRepetitions)"
        case .success:
            return "Correct!"
        default:
            return "Press Enter to Submit"
        }
    }
    
    var statusColor: Color {
        switch viewModel.currentState {
        case .punishment: return .red
        case .success: return .green
        default: return .secondary
        }
    }
}
