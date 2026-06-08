//
//  APIEnvironment.swift
//  RemoteRecruit
//
//  Created by Project
//

import Foundation

/// Defines the API environment configuration.
/// Easily switch between Dev, Staging, and Production environments.
enum APIEnvironment: String, CaseIterable {
    case development
    case staging
    case production

    /// Base URL for the API. For the development environment we use the
    /// public Muse API. The original implementation mistakenly included a
    /// query string which caused the `URLComponents` in `APIEndpoint` to
    /// produce malformed URLs. The base URL should only contain the scheme
    /// and host.
    var baseURL: String {
        switch self {
        case .development:
            return "https://jobdataapi.com/api/"
        case .staging:
            return "https://staging.api.remoterecruit.com/v1"
        case .production:
            return "https://api.remoterecruit.com/v1"
        }
    }

    /// Extra headers specific to each environment
    var additionalHeaders: [String: String] {
        switch self {
        case .development:
            return ["X-Environment": "development"]
        case .staging:
            return ["X-Environment": "staging"]
        case .production:
            return ["X-Environment": "production"]
        }
    }

    /// Whether to use certificate pinning (only for production)
    var useCertificatePinning: Bool {
        switch self {
        case .production:
            return true
        case .development, .staging:
            return false
        }
    }

    var timeoutInterval: TimeInterval {
        switch self {
        case .development:
            return 60
        case .staging:
            return 45
        case .production:
            return 30
        }
    }

    /// Max retry attempts based on environment
    var maxRetryCount: Int {
        switch self {
        case .development:
            return 3
        case .staging:
            return 2
        case .production:
            return 2
        }
    }
}
