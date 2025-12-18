//
//  PracticeView.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/18.
//
import SwiftUI
import SwiftData

struct PracticeView: View {
    @State private var viewModel = QuizViewModel()
    @Environment(\.modelContext) private var modelContext // 获取环境中的 context
    @Environment(\.dismiss) private var dismiss // 退出按钮
    
    // 这里的 wordsToPractice 其实没用了，因为 ViewModel 会自己去查数据库
    // 但为了兼容入口，保留参数，但不使用它
    var wordsToPractice: [WordItem]
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            
            if let word = viewModel.currentWord {
                // --- 题目区域 ---
                VStack(spacing: 10) {
                    Text(word.chineseDefinition)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // 状态显示逻辑
                    if viewModel.currentState == .punishment || viewModel.currentState == .grading {
                        // 罚写 或 评分时，显示正确答案
                        Text(word.spelling)
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundStyle(viewModel.currentState == .punishment ? .red : .green)
                            .tracking(2)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("??????")
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(height: 150)
                
                // --- 交互区域 ---
                
                if viewModel.currentState == .grading {
                    // === 评分按钮区域 (新增) ===
                    VStack(spacing: 15) {
                        Text("How was it?")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            GradeButton(title: "1. Again", color: .red) { viewModel.applyGrading(.again) }
                            GradeButton(title: "2. Hard", color: .orange) { viewModel.applyGrading(.hard) }
                            GradeButton(title: "3. Good", color: .blue) { viewModel.applyGrading(.good) }
                            GradeButton(title: "4. Easy", color: .green) { viewModel.applyGrading(.easy) }
                        }
                    }
                    .padding()
                    // 支持键盘快捷键 1,2,3,4
                    .background {
                        Button("") { viewModel.applyGrading(.again) }.keyboardShortcut("1", modifiers: [])
                        Button("") { viewModel.applyGrading(.hard) }.keyboardShortcut("2", modifiers: [])
                        Button("") { viewModel.applyGrading(.good) }.keyboardShortcut("3", modifiers: [])
                        Button("") { viewModel.applyGrading(.easy) }.keyboardShortcut("4", modifiers: [])
                    }
                    
                } else {
                    // === 输入框区域 ===
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
                }
                
                Text(statusText)
                    .foregroundStyle(.secondary)
                
            } else {
                // --- 初始/结束状态 ---
                VStack(spacing: 20) {
                    if viewModel.feedbackMessage == "All due words reviewed!" {
                        Text("🎉 All Done for Now!")
                            .font(.largeTitle)
                        Text("Come back later for more reviews.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Ready to Review?")
                            .font(.largeTitle)
                    }
                    
                    Button(viewModel.currentState == .idle && viewModel.feedbackMessage.isEmpty ? "Start Review" : "Back to List") {
                        if viewModel.currentState == .idle && viewModel.feedbackMessage.isEmpty {
                            // 开始
                            viewModel.startSession(context: modelContext)
                            isInputFocused = true
                        } else {
                            // 结束退出
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .padding()
        .onAppear {
            // 自动开始
            viewModel.startSession(context: modelContext)
            isInputFocused = true
        }
    }
    
    // UI Helpers
    var borderColor: Color {
        switch viewModel.currentState {
        case .punishment: return .red
        default: return .gray.opacity(0.3)
        }
    }
    
    var statusText: String {
        switch viewModel.currentState {
        case .punishment:
            return "Punishment: \(viewModel.punishmentCount) / \(viewModel.requiredRepetitions)"
        default:
            return viewModel.feedbackMessage
        }
    }
}

// 简单的评分按钮组件
struct GradeButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: 80, height: 40)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
