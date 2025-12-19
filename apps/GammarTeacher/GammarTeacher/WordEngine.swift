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
                let parameters = GenerateParameters(maxTokens: 512, temperature: 0.6)
                
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
    
    private func buildVocabPrompt(word: String) -> String {
        // 1. 修改模板：移除了 phonetic 字段
        let jsonTemplate = """
            {
                "definition": "...",
                "example": "...",
                "synonym": "..."
            }
            """
        
        // 2. 修改指令：移除了关于音标编码的规则，保留了核心规则
        let systemMessage = """
            You are a strict data extraction assistant. 
            Output JSON only.
            
            Rules:
            1. Output valid JSON exactly matching the template below.
            2. Keep the "definition" and "example" in simple, readable English.
            3. **CRITICAL**: Do not mention the word "\(word)" itself in the "definition" field. Use "It" or "The word" instead.
            4. Format:
            \(jsonTemplate)
            """
        
        return """
            <|begin_of_text|><|start_header_id|>system<|end_header_id|>
            
            \(systemMessage)<|eot_id|><|start_header_id|>user<|end_header_id|>
            
            \(word)<|eot_id|><|start_header_id|>assistant<|end_header_id|>
            """
    }
}
