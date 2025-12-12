//
//  Model.swift
//  Oracle
//
//  Created by Rukesh Korde on 12/9/25.
//

import Foundation
import FoundationModels

@Observable
class Oracle {
    
    private var session = LanguageModelSession()
    
    func generateResponse(to prompt: String) async -> String {
        var reply: String
        do {
            reply = try await session.respond(to: prompt).content
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .guardrailViolation(let context):
                reply = "Guardrail violation: \(context.debugDescription)"
            case .decodingFailure(let context):
                reply = "Decoding error: \(context.debugDescription)"
            case .rateLimited(let context):
                reply = "Rate limit exceed: \(context.debugDescription)"
            default:
                reply = "Other error: \(error.localizedDescription)"
            }
            if let failureReason = error.failureReason {
                reply += "\nFailure reason: \(failureReason)"
            }
            if let recoverySuggestion = error.recoverySuggestion {
                reply += "\nRecovery suggestion: \(recoverySuggestion)"
            }
        }
        catch {
            fatalError("Failed to generate response")
        }
        return reply
    }
    
    func checkAvailability() -> String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Please enable Apple Intelligence in your device settings."
        case .unavailable(.deviceNotEligible):
            return "Device not eligible"
        case .unavailable(.modelNotReady):
            return "Model not ready"
        }
    }
    
}

