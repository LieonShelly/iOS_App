//
//  WordEngine.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/19.
//

import Foundation
import MLX
import MLXLLM
import MLXLMCommon
import Tokenizers

actor WordEngine {
    
    private var modelContainer: ModelContainer?
    
    var isReady: Bool { modelContainer != nil }
    
    func loadModel(from localPath: String) async throws {
        let modelDirectory = URL(fileURLWithPath: localPath)
        let configuration = ModelConfiguration(directory: modelDirectory)
        let container = try await LLMModelFactory.shared.loadContainer(configuration: configuration) { progress in
        }
        self.modelContainer = container
    }
    
    /// 生成单词解释 (流式输出)
    func explainWord(_ word: String) -> AsyncStream<String> {
        return AsyncStream { continuation in
            Task {
                guard let container = modelContainer else {
                    continuation.finish()
                    return
                }
                
                // 使用专门的 Prompt
                let prompt = buildVocabPrompt(word: word)
                
                //稍微增加一点 token 上限，防止解释被截断
                let parameters = GenerateParameters(maxTokens: 256, temperature: 0.6)
                
                do {
                    let _ = try await container.perform { context in
                        let input = try await context.processor.prepare(input: .init(prompt: prompt))
                        var lastDecodedText = ""
                        
                        return try MLXLMCommon.generate(
                            input: input,
                            parameters: parameters,
                            context: context
                        ) { tokens in
                            if Task.isCancelled { return .stop }
                            let currentText = context.tokenizer.decode(tokens: tokens)
                            
                            // 增量计算 logic (和你之前的代码一样)
                            let newText: String
                            if currentText.count > lastDecodedText.count {
                                let index = currentText.index(currentText.startIndex, offsetBy: lastDecodedText.count)
                                newText = String(currentText[index...])
                            } else {
                                newText = ""
                            }
                            lastDecodedText = currentText
                            
                            if newText.contains("<|eot_id|>") || newText.contains("<|end_of_text|>") {
                                return .stop
                            }
                            
                            if !newText.isEmpty {
                                continuation.yield(newText)
                            }
                            return .more
                        }
                    }
                } catch {
                    print("❌ Explain error: \(error)")
                }
                continuation.finish()
            }
        }
    }
    
    /// 构建背单词专用的 Prompt
    private func buildVocabPrompt(word: String) -> String {
        let systemMessage = """
                You are a helpful English vocabulary tutor.
                Please explain the word provided by the user in simple English suitable for a learner.
                
                Strict Rules:
                1. Provide a simple definition.
                2. Provide one synonym.
                3. Provide one example sentence.
                4. **CRITICAL: DO NOT mention the word "\(word)" itself in your explanation.** Use "It" or "The word" instead.
                5. Keep it concise (under 50 words).
                """
        
        return """
                <|begin_of_text|><|start_header_id|>system<|end_header_id|>
                
                \(systemMessage)<|eot_id|><|start_header_id|>user<|end_header_id|>
                
                \(word)<|eot_id|><|start_header_id|>assistant<|end_header_id|>
                """
    }
}
