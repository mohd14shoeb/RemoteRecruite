//
//  NetworkClient.swift
//  RemoteRecruit
//
//  Created by Project
//

import Foundation

/// Protocol defining the network layer interface.
/// Makes the network layer testable and swappable.
protocol NetworkClientProtocol {
    /// Makes a network request and decodes the response.
    /// - Parameter endpoint: The API endpoint configuration.
    /// - Returns: Decoded response of type T.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T

    /// Makes a network request and returns raw data.
    /// - Parameter endpoint: The API endpoint configuration.
    /// - Returns: Raw response data.
    func requestData(_ endpoint: APIEndpoint) async throws -> Data

    /// Updates the current environment (dev/staging/production).
    func setEnvironment(_ environment: APIEnvironment)
}

/// Production network client using URLSession with async/await.
///
/// **Features:**
/// - Network connectivity detection before each request
/// - Detailed request/response logging with timing
/// - Multi-environment support (Dev, Staging, Production)
/// - Query parameters support
/// - Retry logic with exponential backoff for transient failures
/// - Proper error mapping with actionable messages
final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private var environment: APIEnvironment
    private let logger: Logger
    private let networkDetector: NetworkDetectorProtocol

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        environment: APIEnvironment = .development,
        logger: Logger = .shared,
        networkDetector: NetworkDetectorProtocol = NetworkDetector.shared
    ) {
        self.session = session
        self.decoder = decoder
        self.environment = environment
        self.logger = logger
        self.networkDetector = networkDetector
    }

    // MARK: - Environment

    func setEnvironment(_ environment: APIEnvironment) {
        self.environment = environment
        logger.info("Environment switched to: \(environment.rawValue)", category: "Network")
    }

    // MARK: - Public Methods

    /// Makes a network request and decodes the response.
    /// Includes:
    /// 1. Connectivity check before the request
    /// 2. Request logging with full details
    /// 3. Response/error logging with timing
    /// 4. Retry logic with exponential backoff for transient failures
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await performRequestWithLogging(endpoint)
        return try decoder.decode(T.self, from: data)
    }

    /// Makes a network request and returns raw data.
    func requestData(_ endpoint: APIEndpoint) async throws -> Data {
        return try await performRequestWithLogging(endpoint)
    }

    // MARK: - Private Methods

    /// Performs the full request lifecycle:
    /// 1. Build URLRequest from endpoint
    /// 2. Check network connectivity
    /// 3. Log the outgoing request
    /// 4. Execute with retry logic
    /// 5. Log the response or error
    private func performRequestWithLogging(_ endpoint: APIEndpoint) async throws -> Data {
        guard let urlRequest = endpoint.urlRequest(for: environment) else {
            logger.error("Failed to build URLRequest for endpoint: \(endpoint)", category: "Network")
            throw AppError.invalidURL
        }

        // Step 1: Check network connectivity before making the request
        logger.debug("Checking network connectivity...", category: "Network")
        do {
            try networkDetector.checkConnectivity()
        } catch {
            // Log that the request was blocked due to no network
            logger.logRequestBlocked(urlRequest)
            throw error // This will be AppError.network(.noInternet)
        }

        // Step 2: Log the outgoing request with full details
        logger.logRequest(urlRequest)

        // Step 3: Perform the request with timing
        let startTime = Date()

        do {
            let data = try await performRequestWithRetry(urlRequest)

            // Step 4: Log the successful response with timing
            let duration = Date().timeIntervalSince(startTime)
            logger.info("✅ Request completed in \(String(format: "%.2f", duration))s", category: "Network")

            return data
        } catch {
            // Step 5: Log the error with timing
            let duration = Date().timeIntervalSince(startTime)
            logger.logNetworkError(error, request: urlRequest, duration: duration)
            throw error
        }
    }

    private func performRequestWithRetry(_ urlRequest: URLRequest) async throws -> Data {
        var lastError: Error?
        let maxRetries = environment.maxRetryCount

        for attempt in 0...maxRetries {
            if attempt > 0 {
                logger.info("Retry attempt \(attempt)/\(maxRetries) for \(urlRequest.url?.absoluteString ?? "nil")", category: "Network")
            }

            do {
                return try await performRequest(urlRequest)
            } catch let error as AppError {
                if shouldRetry(error: error) {
                    lastError = error
                    if attempt < maxRetries {
                        // Exponential backoff: 500ms, 1s, 2s...
                        let delay = UInt64(pow(2.0, Double(attempt))) * 500_000_000
                        logger.debug("Retrying in \(Double(delay) / 1_000_000_000)s...", category: "Network")
                        try await Task.sleep(nanoseconds: delay)
                        continue
                    }
                } else {
                    // Don't retry on client errors (4xx)
                    logger.debug("Not retrying - non-retryable error: \(error.errorDescription ?? "unknown")", category: "Network")
                    throw error
                }
            } catch {
                lastError = error
                if attempt < maxRetries {
                    let delay = UInt64(pow(2.0, Double(attempt))) * 500_000_000
                    try await Task.sleep(nanoseconds: delay)
                    continue
                }
            }
        }

        let finalError = lastError ?? AppError.unknown("Request failed after \(maxRetries) retries.")
        logger.error("All \(maxRetries) retries exhausted. Final error: \(finalError.localizedDescription)", category: "Network")
        throw finalError
    }

    private func performRequest(_ urlRequest: URLRequest) async throws -> Data {
        let (data, response): (Data, URLResponse)

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError {
            throw AppError.network(mapURLError(error))
        } catch {
            throw AppError.unknown(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.network(.invalidResponse)
        }

        // Log the response with status code and data
        logger.logResponse(httpResponse, data: data, duration: 0)

        try validateHTTPResponse(httpResponse)

        return data
    }

    // MARK: - Response Validation

    private func validateHTTPResponse(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 400:
            logger.warning("Bad request (400) to \(response.url?.absoluteString ?? "nil")", category: "Network")
            throw AppError.network(.badRequest)
        case 401:
            logger.warning("Unauthorized (401) - Session may have expired", category: "Network")
            throw AppError.network(.unauthorized)
        case 403:
            logger.warning("Forbidden (403) - Access denied", category: "Network")
            throw AppError.network(.forbidden)
        case 404:
            logger.warning("Not found (404) - Resource missing", category: "Network")
            throw AppError.network(.notFound)
        case 429:
            logger.warning("Rate limited (429)", category: "Network")
            throw AppError.network(.timeout)
        case 500...599:
            logger.error("Server error (\(response.statusCode))", category: "Network")
            throw AppError.network(.serverError(statusCode: response.statusCode))
        default:
            logger.warning("Unexpected status code: \(response.statusCode)", category: "Network")
            throw AppError.network(.invalidResponse)
        }
    }

    // MARK: - Error Mapping

    private func mapURLError(_ error: URLError) -> NetworkError {
        let networkError: NetworkError

        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            networkError = .noInternet
            logger.error("No internet connection detected", category: "Network")
        case .timedOut:
            networkError = .timeout
            logger.warning("Request timed out", category: "Network")
        case .cancelled:
            networkError = .cancelled
            logger.info("Request was cancelled", category: "Network")
        case .badURL, .unsupportedURL:
            networkError = .badRequest
            logger.error("Invalid URL: \(error.localizedDescription)", category: "Network")
        case .secureConnectionFailed, .serverCertificateUntrusted, .serverCertificateHasBadDate:
            networkError = .serverError(statusCode: error.code.rawValue)
            logger.error("SSL/Security error: \(error.localizedDescription)", category: "Network")
        default:
            networkError = .serverError(statusCode: error.code.rawValue)
            logger.error("Network error (\(error.code.rawValue)): \(error.localizedDescription)", category: "Network")
        }

        return networkError
    }

    private func shouldRetry(error: AppError) -> Bool {
        guard case .network(let networkError) = error else {
            return false
        }
        switch networkError {
        case .badRequest, .unauthorized, .forbidden, .notFound, .invalidResponse, .cancelled:
            return false
        case .serverError, .timeout, .noInternet:
            return true
        }
    }
}