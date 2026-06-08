//
//  DependencyContainer.swift
//  RemoteRecruit
//
//  Created by Project
//

import Foundation

/// Simple dependency injection container.
/// Manages the creation and lifecycle of all services.
/// Easily extendable - register new services as needed.
   
final class DependencyContainer {

    // MARK: - Shared Instance
    static let shared = DependencyContainer()

    // MARK: - Properties
    private var _networkClient: NetworkClientProtocol?
    private var _jobService: JobServiceProtocol?
    private var currentEnvironment: APIEnvironment = .development

    var networkClient: NetworkClientProtocol {
        if let client = _networkClient {
            return client
        }
        let client = NetworkClient(environment: currentEnvironment)
        _networkClient = client
        return client
    }

    var jobService: JobServiceProtocol {
        if let service = _jobService {
            return service
        }
        let service = JobService(networkClient: networkClient)
        _jobService = service
        return service
    }

    // MARK: - Initialization
    private init() {}

    // MARK: - Configuration

    /// Configure the API environment (Dev, Staging, Production)
    func setEnvironment(_ environment: APIEnvironment) {
        currentEnvironment = environment
        if let client = _networkClient as? NetworkClient {
            client.setEnvironment(environment)
        } else {
            _networkClient = NetworkClient(environment: environment)
        }
    }

    /// Switch between mock and production services.
    /// - Parameter useMock: true for MockJobService, false for real JobService
//    func configureForTesting(useMock: Bool = true) {
//        if useMock {
//            _jobService = MockJobService(delay: 200_000_000)
//        } else {
//            _jobService = JobService(networkClient: networkClient)
//        }
//    }

    /// Register a custom Jobs service (useful for injecting mocks in tests).
    func registerJobService(_ service: JobServiceProtocol) {
        _jobService = service
    }

    /// Register a custom network client.
    func registerNetworkClient(_ client: NetworkClientProtocol) {
        _networkClient = client
    }

    /// Reset all services (useful for tearing down between tests).
    func reset() {
        _networkClient = nil
        _jobService = nil
        currentEnvironment = .development
    }
}
