//
//  QuizViewModel.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/18.
//


import SwiftUI
import SwiftData

@Observable // Swift 5.9+ 新宏，如果是老版本SwiftUI用 ObservableObject
class QuizViewModel {
    // 状态定义
    enum SessionState {
        case idle           // 闲置/结束
        case questioning    // 正在提问
        case success        // 答对了
        case punishment     // 罚写模式
    }
    
    // 数据源
    private var reviewQueue: [WordItem] = []
    
    // 当前状态
    var currentState: SessionState = .idle
    var currentWord: WordItem?
    var userInput: String = ""
    var punishmentCount: Int = 0
    let requiredRepetitions = 3 // 设为3遍
    
    // 界面反馈文案
    var feedbackMessage: String = ""
    
    /// 开始一个新的复习会话
    func startSession(words: [WordItem]) {
        self.reviewQueue = words.shuffled() // 暂时随机乱序
        nextWord()
    }
    
    /// 切换到下一个词
    private func nextWord() {
        guard !reviewQueue.isEmpty else {
            currentState = .idle
            feedbackMessage = "Session Complete!"
            currentWord = nil
            return
        }
        
        currentWord = reviewQueue.removeFirst()
        currentState = .questioning
        userInput = ""
        feedbackMessage = "Type the English word"
        punishmentCount = 0
    }
    
    /// 提交答案（核心逻辑）
    func submitAnswer() {
        guard let word = currentWord else { return }
        
        let input = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let target = word.spelling.lowercased()
        
        switch currentState {
        case .questioning:
            if input == target {
                // ✅ 答对了
                SoundManager.shared.playSuccess()
                currentState = .success
                feedbackMessage = "Correct! ✅"
                
                // 延迟 0.8秒 自动跳下一个，给用户一种流畅感
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.nextWord()
                }
            } else {
                // ❌ 答错了 -> 进入罚写模式
                SoundManager.shared.playError()
                enterPunishmentMode()
            }
            
        case .punishment:
            if input == target {
                // 罚写正确
                SoundManager.shared.playSuccess()
                punishmentCount += 1
                userInput = "" // 清空输入框让用户继续打
                
                if punishmentCount >= requiredRepetitions {
                    // 罚写完成，放行
                    feedbackMessage = "Recovered! Moving on..."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.nextWord()
                    }
                }
            } else {
                // 罚写又错了？(这里可以设计得更变态，比如重置计数，暂时先只报错)
                SoundManager.shared.playError()
                // 震动反馈或视觉提示
            }
            
        default:
            break
        }
    }
    
    private func enterPunishmentMode() {
        currentState = .punishment
        userInput = ""
        punishmentCount = 0
        // 在罚写模式下，我们直接显示正确答案给用户照抄
    }
}