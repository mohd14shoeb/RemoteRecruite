//
//  NetworkError.swift
//  RemoteRecruit
//
//  Created by Project
//

import Foundation

/// Represents network-specific errors
enum NetworkError: Error, LocalizedError, Equatable {
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    case timeout
    case noInternet
    case invalidResponse
    case cancelled

    var errorDescription: String? {
        switch self {
        case .badRequest:
            return "Bad request. Please check your input."
        case .unauthorized:
            return "Session expired. Please log in again."
        case .forbidden:
            return "You don't have permission to access this resource."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .timeout:
            return "Request timed out. Please check your connection."
        case .noInternet:
            return "No internet connection. Please try again later."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .cancelled:
            return "Request was cancelled."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noInternet:
            return "Please check your Wi-Fi or cellular connection and try again."
        case .timeout:
            return "Please try again. If the problem persists, check your connection."
        case .serverError:
            return "Our servers are experiencing issues. Please try again later."
        default:
            return nil
        }
    }
}