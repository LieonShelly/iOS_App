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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("modelPath") var storedModelPath: String = ""
    
    // 兼容旧接口
    var wordsToPractice: [WordItem]
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()
            topBar
            answerView
        }
        .onAppear {
            initializeSession()
        }
    }
    
    var topBar: some View {
        
        // Layer 3: 顶部工具栏 (悬浮在最上层，钉在顶部)
        VStack {
            HStack {
                Spacer() // 把按钮推到右边
                if viewModel.currentState != .idle {
                    Button(action: {
                        SoundManager.shared.speak(viewModel.currentWord?.spelling ?? "")
                    }) {
                        Image(systemName: "speaker.wave.2.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("s", modifiers: .command)
                    .help("Cmd+S to Speak")
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer() // 这个 Spacer 很关键，它把上面的 HStack 顶到了最上方
        }
    }
    
    func wordInfoView(_ word: WordItem) -> some View {
        // 1. 问题提示区 (AI 解释 / 音标 / 例句)
        VStack(spacing: 16) {
            
            // B. 核心解释
            if let explanation = word.aiExplanation, !explanation.isEmpty {
                Text(explanation)
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            } else if viewModel.isGeneratingAI {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("AI Analyzing...")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }
            }
            
            // 降级显示中文
            Text(word.chineseDefinition)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            // C. 例句
            if let example = word.aiExampleSentence, !example.isEmpty {
                Text(example)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal)
        .onTapGesture {
            SoundManager.shared.speak(word.spelling)
        }
        
    }
    
    func inputView(_ word: WordItem) -> some View {
        // 2. 输入交互区
        VStack(spacing: 20) {
            
            // 答案提示 (仅在罚写或评分时显示)
            if viewModel.currentState == .punishment || viewModel.currentState == .grading {
                Text(word.spelling)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundStyle(viewModel.currentState == .punishment ? .red : .green)
                    .tracking(3)
                    .transition(.opacity.combined(with: .scale))
            } else {
                // 占位，防止界面高度跳动
                Text(" ")
                    .font(.system(size: 48))
            }
            
            // 评分按钮组 (Grading Mode)
            if viewModel.currentState == .grading {
                HStack(spacing: 16) {
                    SRSButton(title: "Again", shortcut: "1", color: .red) { viewModel.applyGrading(.again) }
                    SRSButton(title: "Hard", shortcut: "2", color: .orange) { viewModel.applyGrading(.hard) }
                    SRSButton(title: "Good", shortcut: "3", color: .blue) { viewModel.applyGrading(.good) }
                    SRSButton(title: "Easy", shortcut: "4", color: .green) { viewModel.applyGrading(.easy) }
                }
                .padding(.top, 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                // 输入框 (Typing Mode)
                ZStack(alignment: .bottom) {
                    TextField("", text: $viewModel.userInput)
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .focused($isInputFocused)
                        .foregroundStyle(viewModel.currentState == .punishment ? .red : .primary)
                        .onSubmit { viewModel.submitAnswer() }
                        .onChange(of: viewModel.userInput) { oldValue, newValue in
                            if oldValue != newValue { SoundManager.shared.playKeyClick() }
                        }
                    
                    // 底部装饰线
                    Rectangle()
                        .frame(height: 4)
                        .foregroundStyle(borderColor)
                        .cornerRadius(2)
                }
                .frame(maxWidth: 500)
            }
        }
    }
    
    func punishmentView() -> some View {
        Text("Punishment: \(viewModel.punishmentCount) / \(viewModel.requiredRepetitions)")
            .font(.headline)
            .foregroundStyle(.red.opacity(0.8))
            .padding(8)
            .background(.red.opacity(0.1))
            .cornerRadius(8)
    }
    
    func idleView() -> some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green.gradient)
                .symbolEffect(.bounce, value: viewModel.feedbackMessage)
            
            Text(viewModel.feedbackMessage.isEmpty ? "Ready to Review?" : "Session Complete!")
                .font(.system(size: 40, weight: .bold))
            
            if viewModel.feedbackMessage == "All due words reviewed!" {
                Text("Great job! Come back later.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: {
                if viewModel.currentState == .idle && viewModel.feedbackMessage.isEmpty {
                    viewModel.startSession(context: modelContext)
                    isInputFocused = true
                } else {
                    dismiss()
                }
            }) {
                Text(viewModel.currentState == .idle && viewModel.feedbackMessage.isEmpty ? "Start Session" : "Back to List")
                    .font(.title2)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
        }
    }
    
    var answerView: some View {
        VStack {
            if let word = viewModel.currentWord {
                // === 答题界面 ===
                VStack(spacing: 40) {
                    wordInfoView(word)
                    inputView(word)
                    if viewModel.currentState == .punishment {
                        punishmentView()
                    }
                }
                .frame(maxWidth: 800, maxHeight: 1000)
            } else {
              idleView()
            }
        }
        
    }
    
    private func initializeSession() {
        if !storedModelPath.isEmpty {
            Task {
                await viewModel.loadModel(path: storedModelPath)
                viewModel.startSession(context: modelContext)
                isInputFocused = true
            }
        } else {
            viewModel.startSession(context: modelContext)
            isInputFocused = true
        }
    }
    
    var borderColor: Color {
        switch viewModel.currentState {
        case .punishment: return .red
        case .grading: return .green
        default: return .secondary.opacity(0.3)
        }
    }
}


struct SRSButton: View {
    let title: String
    let shortcut: KeyEquivalent
    let color: Color
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(String(describing: shortcut))
                    .font(.caption)
                    .opacity(0.6)
            }
            .frame(width: 80, height: 60)
            .background(color.opacity(isHovering ? 0.2 : 0.1))
            .foregroundStyle(color)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .keyboardShortcut(shortcut, modifiers: [])
        .onHover { isHovering = $0 }
        .scaleEffect(isHovering ? 1.05 : 1.0)
        .animation(.spring(duration: 0.2), value: isHovering)
    }
}

// 保留旧的 GradeButton 以防其他地方引用，虽然现在 PracticeView 用的是 SRSButton
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
