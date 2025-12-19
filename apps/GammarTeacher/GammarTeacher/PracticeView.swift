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
    @AppStorage("modelPath") var storedModelPath: String = ""
    var wordsToPractice: [WordItem]
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            if let word = viewModel.currentWord {
                VStack(spacing: 10) {
                    if !viewModel.aiOutputText.isEmpty {
                        Text(viewModel.aiOutputText)
                            .multilineTextAlignment(.leading)
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    
                    Text(word.chineseDefinition)
                        .font(.title)
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
                .onTapGesture {
                    SoundManager.shared.speak(word.spelling)
                }
                .overlay(alignment: .topTrailing) {
                    Button(action: {
                        SoundManager.shared.speak(word.spelling)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("s", modifiers: .command)
                }
                
                if viewModel.currentState == .grading {
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
                    
                } else {

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
                        .onChange(of: viewModel.userInput) { oldValue, newValue in
                            if oldValue != newValue {
                                SoundManager.shared.playKeyClick()
                            }
                        }
                }
                
                Text(statusText)
                    .foregroundStyle(.secondary)
                
            } else {
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
