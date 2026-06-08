//
//  NetworkDetector.swift
//  RemoteRecruit
//
//  Created by Project
//

import Foundation
import Network
import Combine

/// Protocol for network connectivity checking.
/// Enables mocking network state in tests.
protocol NetworkDetectorProtocol {
    /// Whether the device currently has network connectivity.
    var isConnected: Bool { get }

    /// The current network interface type (WiFi, cellular, etc.)
    var interfaceType: NWInterface.InterfaceType? { get }

    /// Checks connectivity and throws an error if not connected.
    /// Call this before making network requests.
    func checkConnectivity() throws

    /// Starts monitoring network connectivity changes.
    func startMonitoring()

    /// Stops monitoring network connectivity changes.
    func stopMonitoring()
}

/// Monitors network connectivity using Apple's Network framework (NWPathMonitor).
/// Provides real-time connectivity status and interface type information.
/// Automatically blocks requests when there is no network connection.
final class NetworkDetector: NetworkDetectorProtocol, ObservableObject {

    // MARK: - Singleton
    static let shared = NetworkDetector()

    // MARK: - Published Properties
    /// Whether the device is connected to the network.
    @Published private(set) var isConnected: Bool = true

    /// The current network interface type (WiFi, cellular, wired, loopback, other).
    @Published private(set) var interfaceType: NWInterface.InterfaceType? = nil

    // MARK: - Private Properties
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.remoterecruit.networkmonitor", qos: .background)
    private let logger = Logger.shared

    // MARK: - Initialization
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    /// Checks connectivity and throws `AppError.network(.noInternet)` if not connected.
    /// Call this at the start of any network request.
    func checkConnectivity() throws {
        guard isConnected else {
            logger.warning("Network check failed: No internet connection", category: "Network")
            throw AppError.network(.noInternet)
        }
    }

    /// Starts monitoring network path changes.
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let isConnected = path.status == .satisfied
            let interface = self.resolveInterface(from: path)

            DispatchQueue.main.async {
                self.isConnected = isConnected
                self.interfaceType = interface
            }

            let interfaceName = interface?.debugDescription ?? "unknown"
            self.logger.logConnectivityChange(isConnected: isConnected, interface: interfaceName)
        }
        monitor.start(queue: queue)
    }

    /// Stops monitoring network path changes.
    func stopMonitoring() {
        monitor.cancel()
    }

    // MARK: - Private Methods

    /// Resolves the primary network interface from the path.
    private func resolveInterface(from path: NWPath) -> NWInterface.InterfaceType? {
        let interfaces: [NWInterface.InterfaceType] = [.wifi, .cellular, .wiredEthernet, .loopback]
        for interface in interfaces where path.usesInterfaceType(interface) {
            return interface
        }
        return nil
    }
}

// MARK: - Mock Network Detector for Testing
/// A mock network detector that simulates connectivity states for testing.
final class MockNetworkDetector: NetworkDetectorProtocol {

    /// Set this to false to simulate no network connection.
    var simulatedIsConnected: Bool = true

    /// Simulated interface type.
    var simulatedInterfaceType: NWInterface.InterfaceType? = .wifi

    var isConnected: Bool {
        simulatedIsConnected
    }

    var interfaceType: NWInterface.InterfaceType? {
        simulatedInterfaceType
    }

    func checkConnectivity() throws {
        guard simulatedIsConnected else {
            throw AppError.network(.noInternet)
        }
    }

    func startMonitoring() {
        // No-op for mock
    }

    func stopMonitoring() {
        // No-op for mock
    }

    /// Simulates a connectivity change.
    func simulateConnectivityChange(isConnected: Bool, interface: NWInterface.InterfaceType? = nil) {
        simulatedIsConnected = isConnected
        if let interface = interface {
            simulatedInterfaceType = interface
        }
    }
}

// MARK: - InterfaceType Debug Description
extension NWInterface.InterfaceType: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .wifi:
            return "WiFi"
        case .cellular:
            return "Cellular"
        case .wiredEthernet:
            return "Wired Ethernet"
        case .loopback:
            return "Loopback"
        case .other:
            return "Other"
        @unknown default:
            return "Unknown"
        }
    }
}
