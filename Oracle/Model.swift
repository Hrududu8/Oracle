//
//  Model.swift
//  Oracle
//
//  Created by Rukesh Korde on 12/9/25.
//

import Foundation
import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom
import Combine
import Tokenizers

@MainActor
@Observable
class LLMEvaluator {
    var output = ""
    var running = false
    
    private let modelConfig = LLMRegistry.gemma_2_2b_it_4bit
    private let parameters = GenerateParameters(temperature: 0.7)
    private var modelContainer: ModelContainer? = nil
    
    func loadModel() async throws {
        //YOU ARE HERE RUKESH.
        //I think it's trying to run the prompt
        //before the model is downloaded.
        guard modelContainer == nil else { return }
        
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
        modelContainer = try await LLMModelFactory.shared.loadContainer(
            configuration: modelConfig
        ) { progress in
            print("Downloading model: \(Int(progress.fractionCompleted * 100))%")
        }
    }
    
    func generate(prompt: String, systemPrompt: String = "You are a helpful assistant.") async {
            guard !running else { return }
            running = true
            output = "Generating..."

            do {
                try await loadModel()

                let result = try await modelContainer!.perform { context in
                    let input = try await context.processor.prepare(
                        input: .init(messages: [
                            ["role": "system", "content": systemPrompt],
                            ["role": "user", "content": prompt]
                        ])
                    )

                    return try MLXLMCommon.generate(
                        input: input,
                        parameters: parameters,
                        context: context
                    ) { tokens in
                        let partial = context.tokenizer.decode(tokens: tokens)
                        Task { @MainActor in self.output = partial }
                        return tokens.count >= 1000 ? .stop : .more
                    }
                }

                output = result.output
            } catch {
                output = "Error: \(error.localizedDescription)"
            }

            running = false
        }
    }
