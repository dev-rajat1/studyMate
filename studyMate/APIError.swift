//
//  APIError.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Custom Error enum for handling all network & AI operations cleanly.
//

import Foundation

/// Custom error types for API and Network operations.
/// Conforms to LocalizedError so we can show user-friendly messages in alerts.
enum APIError: LocalizedError {
    case invalidURL
    case noInternet
    case serverError(String)
    case decodingFailed
    case aiDisabled
    case missingData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API endpoint URL is invalid. Please check your settings."
        case .noInternet:
            return "No internet connection. Please check your network and try again."
        case .serverError(let message):
            return "Server Error: \(message)"
        case .decodingFailed:
            return "Failed to process the response from AI server."
        case .aiDisabled:
            return "AI features are disabled in Settings. Please enable them to continue."
        case .missingData:
            return "Please add some tasks or notes first to generate a summary or quiz."
        }
    }
}
