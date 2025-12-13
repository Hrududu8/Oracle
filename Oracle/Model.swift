//
//  Model.swift
//  Oracle
//
//  Created by Rukesh Korde on 12/9/25.
//

import Foundation
import FoundationModels

enum OracleStatus: CustomStringConvertible {
    
    
    case ready, guardRailViolation, decodingError, rateLimitError, unknownError
    
    var description: String {
        switch self {
        case .ready:
            return "Ready"
        case .guardRailViolation:
            return "Guardrail Violation"
        case .decodingError:
            return "Decoding Error"
        case .rateLimitError:
            return "Rate Limit Error"
        default:
            return "Unknown Error"
        }
    }
}

@Observable
class Oracle {
    
    private var session = LanguageModelSession()
    
    var isReady: Bool { session.isResponding }
    var isResponding: Bool { session.isResponding }
    
    
    struct OracleAvailable {
        var isAvailable = false
        var reason = "Loading..."
    }
    
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
    
    func checkAvailability() -> Oracle.OracleAvailable {
        switch SystemLanguageModel.default.availability {
        //TODO: replace these with an enum
        case .available:
            return OracleAvailable(isAvailable: true, reason: "")
        case .unavailable(.appleIntelligenceNotEnabled):
            return OracleAvailable(isAvailable: false, reason: "Please enable Apple Intelligence in your device settings.")
        case .unavailable(.deviceNotEligible):
            return OracleAvailable(isAvailable: false, reason: "Device not eligible for this model.")
        case .unavailable(.modelNotReady):
            return OracleAvailable(isAvailable: false, reason: "Model not ready.")
        }
    }
    
}

