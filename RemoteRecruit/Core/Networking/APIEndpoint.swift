//
//  APIEndpoint.swift
//  RemoteRecruit
//
//  Created by Project
//

import Foundation

/// Defines all API endpoints in a centralized, type-safe manner.
/// To add a new endpoint, simply add a new case with its configuration.
enum APIEndpoint {
    // MARK: - Jobs Endpoints
    case jobs

    // MARK: - HTTP Method
    var method: HTTPMethod {
        switch self {
        case .jobs:
            return .GET
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .jobs:
            return "jobs"
        }
    }

    // MARK: - Query Parameters
    var queryItems: [URLQueryItem]? {
        switch self {

        default:
            return nil
        }
    }

    // MARK: - Headers
    var headers: [String: String] {
        var defaultHeaders: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        // Add auth token if available
        if let token = AuthTokenManager.shared.accessToken {
            defaultHeaders["Authorization"] = "Bearer \(token)"
        }

        return defaultHeaders
    }

    // MARK: - URL Building
    /// Builds the full URL for the given environment
    func url(for environment: APIEnvironment) -> URL? {
        var components = URLComponents(string: environment.baseURL + path)

        // Add query items
        if let queryItems = queryItems, !queryItems.isEmpty {
            if components?.queryItems == nil {
                components?.queryItems = queryItems
            } else {
                components?.queryItems?.append(contentsOf: queryItems)
            }
        }

        return components?.url
    }

    /// Builds the URLRequest for the given environment
    func urlRequest(for environment: APIEnvironment) -> URLRequest? {
        guard let url = url(for: environment) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = environment.timeoutInterval

        // Set headers
        var allHeaders = headers
        environment.additionalHeaders.forEach { allHeaders[$0.key] = $0.value }
        request.allHTTPHeaderFields = allHeaders

        return request
    }
}

// MARK: - CustomStringConvertible
extension APIEndpoint: CustomStringConvertible {
    var description: String {
        return "\(method.rawValue) \(path)"
    }
}

// MARK: - Auth Token Manager
/// Simple token manager for storing and retrieving auth tokens.
/// In production, use Keychain services for secure storage.
final class AuthTokenManager {
    static let shared = AuthTokenManager()

    private(set) var accessToken: String?
    private(set) var refreshToken: String?

    private init() {}

    func setTokens(access: String, refresh: String) {
        accessToken = access
        refreshToken = refresh
    }

    func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }

    var isAuthenticated: Bool {
        accessToken != nil
    }
}
