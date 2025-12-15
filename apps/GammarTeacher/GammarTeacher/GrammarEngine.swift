//
//  GrammarEngine.swift
//  GammarTeacher
//
//  Created by Renjun Li on 2025/12/15.
//
import Foundation
import MLX
import MLXLLM       // ✅ 对应你截图里的库名
import MLXLMCommon  // ✅ 必须引入，核心逻辑在这里
import Tokenizers

actor GrammarEngine {
    
    // 新版 API 使用 ModelContainer 来持有模型
    private var modelContainer: ModelContainer?
    
    var isReady: Bool { modelContainer != nil }
    
    /// 加载本地模型
    func loadModel(from localPath: String) async throws {
        let modelDirectory = URL(fileURLWithPath: localPath)
        
        // 1. 创建配置
        // 指向你下载的模型文件夹
        let configuration = ModelConfiguration(directory: modelDirectory)
        
        // 2. 加载模型 (使用 Factory)
        // ⚠️ 关键修正：新版本必须用 LLMModelFactory.shared.loadContainer
        let container = try await LLMModelFactory.shared.loadContainer(configuration: configuration) { progress in
            // 这里可以打印加载进度，比如: print("Loading: \(progress.fractionCompleted)")
        }
        
        self.modelContainer = container
        print("✅ Model loaded successfully from \(localPath)")
    }
    
    /// 核心功能：流式生成纠错建议
    func fixGrammar(for text: String) -> AsyncStream<String> {
        return AsyncStream { continuation in
            Task {
                guard let container = modelContainer else {
                    continuation.finish()
                    return
                }
                
                // 1. 构建 Prompt
                let prompt = buildLlama3Prompt(userText: text)
                
                // 2. 准备生成参数
                // GenerateParameters 位于 MLXLMCommon 中
                let parameters = GenerateParameters(maxTokens: 512, temperature: 0.2)
                
                // 3. 开始推理
                do {
                    // ⚠️ 关键修正：新版本使用 container.perform 来确保线程安全
                    let _ = try await container.perform { context in
                        
                        // 3.1 处理输入
                        let input = try await context.processor.prepare(input: .init(prompt: prompt))
                        
                        // 3.2 调用生成函数 (MLXLMCommon.generate)
                        return try MLXLMCommon.generate(
                            input: input,
                            parameters: parameters,
                            context: context
                        ) { tokens in
                            
                            // 3.3 解码 Token 为文本
                            let text = context.tokenizer.decode(tokens: tokens)
                            continuation.yield(text)
                            
                            // 返回 .more 继续生成，返回 .stop 停止
                            return .more
                        }
                    }
                    print("Generation completed.")
                    
                } catch {
                    print("❌ Generation error: \(error)")
                }
                
                continuation.finish()
            }
        }
    }
    
    private func buildLlama3Prompt(userText: String) -> String {
        // 升级版 System Prompt
        let systemMessage = """
            You are an expert English teacher. 
            First, provide the corrected version of the user's text in **Bold**.
            Second, analyze the mistakes briefly in a bulleted list.
            If the text is already correct, praise the user.
            """
        
        return """
            <|begin_of_text|><|start_header_id|>system<|end_header_id|>
            
            \(systemMessage)<|eot_id|><|start_header_id|>user<|end_header_id|>
            
            \(userText)<|eot_id|><|start_header_id|>assistant<|end_header_id|>
            """
    }
}
