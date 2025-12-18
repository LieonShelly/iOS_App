//
//  QuizViewModel.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/18.
//

import SwiftUI
import SwiftData

@Observable
class QuizViewModel {
    enum SessionState {
        case idle           // 闲置
        case questioning    // 提问中
        case punishment     // 错误罚写中
        case grading        // 答对后，等待评分中 (新增状态)
    }
    
    // 数据源
    private var reviewQueue: [WordItem] = []
    var context: ModelContext? // 需要注入 Context 以保存数据
    
    // 状态
    var currentState: SessionState = .idle
    var currentWord: WordItem?
    var userInput: String = ""
    var punishmentCount: Int = 0
    let requiredRepetitions = 3
    
    var feedbackMessage: String = ""
    // 新增：AI 相关
    var aiOutputText: String = ""
    var isGeneratingAI: Bool = false
    private var engine = WordEngine() // 实例化引擎
    private var generationTask: Task<Void, Never>? // 用于取消生成任务
    
    // MARK: - API
    
    /// 开始复习：只获取 nextReviewDate <= now 的单词
    func startSession(context: ModelContext) {
        self.context = context
        
        // 1. 获取所有单词
        // (注：SwiftData 的复杂查询建议在 View 层做，这里简化为获取所有再 Filter，
        // 实际生产中应该用 Predicate 优化性能)
        do {
            let descriptor = FetchDescriptor<WordItem>(
                sortBy: [SortDescriptor(\.nextReviewDate)]
            )
            let allWords = try context.fetch(descriptor)
            
            // 2. 筛选：复习时间到了的，或者全新的
            self.reviewQueue = allWords.filter { $0.nextReviewDate <= Date.now }
            
            print("Session started. Due words: \(reviewQueue.count)")
            nextWord()
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    /// 提交拼写
    func submitAnswer() {
        guard let word = currentWord else { return }
        let input = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let target = word.spelling.lowercased()
        
        switch currentState {
        case .questioning:
            if input == target {
                // ✅ 拼写正确 -> 进入评分阶段
                SoundManager.shared.playSuccess()
                currentState = .grading
                feedbackMessage = "Correct! Rate difficulty:"
                // 注意：这里不再自动跳转，而是等用户按 1/2/3/4
            } else {
                // ❌ 拼写错误 -> 罚写模式
                SoundManager.shared.playError()
                enterPunishmentMode()
            }
            
        case .punishment:
            if input == target {
                SoundManager.shared.playSuccess()
                punishmentCount += 1
                userInput = ""
                
                if punishmentCount >= requiredRepetitions {
                    // 罚写完成 -> 强制标记为 Again (忘记)
                    applyGrading(.again)
                }
            } else {
                SoundManager.shared.playError()
            }
            
        default: break
        }
    }
    
    /// 用户打分 (或者罚写结束自动调用)
    func applyGrading(_ grade: SRSLogic.Grade) {
        guard let word = currentWord, let ctx = context else { return }
        
        // 1. 计算 SRS 结果
        let result = SRSLogic.calculate(
            grade: grade,
            currentInterval: word.interval,
            currentEaseFactor: word.easeFactor,
            currentRepetition: word.repetitionCount
        )
        
        // 2. 更新数据库模型
        word.interval = result.interval
        word.easeFactor = result.easeFactor
        word.repetitionCount = result.repetition
        
        // 计算下次复习的绝对时间 (秒 = 天 * 86400)
        // 如果是 Again(0天)，则设为 5分钟后 或 明天，这里简化为“现在”以便立即重试，或者加 1 分钟
        if result.interval == 0 {
            // 逻辑选择：如果是 Again，是否要在本次 Session 再次出现？
            // 简化版：设为 1分钟后，这样下次启动 Session 会出现；或者直接归档。
            // 这里设为 Now，意味着它还没“掌握”。
            word.nextReviewDate = Date.now
        } else {
            word.nextReviewDate = Date.now.addingTimeInterval(result.interval * 86400)
        }
        
        word.lastReviewDate = Date.now
        
        // 3. 保存
        try? ctx.save()
        
        // 4. 下一题
        nextWord()
    }
    
    private func enterPunishmentMode() {
        currentState = .punishment
        userInput = ""
        punishmentCount = 0
        feedbackMessage = "Incorrect. Punishment Mode."
    }
    
    // 2. 新增：加载模型的方法 (需要从 UI 触发)
    func loadModel(path: String) async {
        do {
            try await engine.loadModel(from: path)
            print("Model loaded successfully at \(path)")
        } catch {
            print("Failed to load model: \(error)")
        }
    }
    
    var isModelReady: Bool {
        get async { await engine.isReady }
    }
    
    // 3. 修改 nextWord() 方法，切换单词时触发 AI
    private func nextWord() {
        // 取消上一次可能的生成任务
        generationTask?.cancel()
        
        guard !reviewQueue.isEmpty else {
            currentState = .idle
            feedbackMessage = "All due words reviewed!"
            currentWord = nil
            return
        }
        
        let next = reviewQueue.removeFirst()
        currentWord = next
        currentState = .questioning
        userInput = ""
        feedbackMessage = "Type the English word"
        punishmentCount = 0
        
        // === AI 逻辑开始 ===
        // 先清空，显示中文作为兜底
        aiOutputText = ""
        
        if let cached = next.aiExplanation, !cached.isEmpty {
            // A. 有缓存：直接显示
            aiOutputText = cached
        } else {
            // B. 无缓存：开始流式生成
            startAIGeneration(for: next)
        }
    }
    
    private func startAIGeneration(for wordItem: WordItem) {
        generationTask = Task {
            isGeneratingAI = true
            aiOutputText = "AI is thinking..."
            
            // 检查模型是否加载
            let ready = await engine.isReady
            guard ready else {
                await MainActor.run {
                    aiOutputText = "Model not loaded. Showing Chinese: \(wordItem.chineseDefinition)"
                    isGeneratingAI = false
                }
                return
            }
            
            var fullText = ""
            // 开始流式接收
            await MainActor.run { aiOutputText = "" }
            
            for await segment in await engine.explainWord(wordItem.spelling) {
                if Task.isCancelled { return }
                
                await MainActor.run {
                    fullText += segment
                    self.aiOutputText = fullText
                }
            }
            
            // 生成完毕，保存到数据库缓存
            if !Task.isCancelled && !fullText.isEmpty {
                await MainActor.run {
                    wordItem.aiExplanation = fullText
                    try? context?.save() // 持久化缓存
                    isGeneratingAI = false
                }
            }
        }
    }
}
