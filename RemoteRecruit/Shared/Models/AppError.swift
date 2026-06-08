//
//  AppError.swift
//  RemoteRecruit
//
//  Created by Shoeb Khan on 08/06/26.
//


import Foundation

/// Represents application-level errors with user-friendly messages
enum AppError: Error, LocalizedError, Equatable {
    case network(NetworkError)
    case decoding(Error)
    case invalidURL
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network(let networkError):
            return networkError.errorDescription
        case .decoding:
            return "Failed to process data. Please try again."
        case .invalidURL:
            return "Invalid request URL."
        case .unknown(let message):
            return message
        }
    }

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
