//
//  Logger.swift
//  RemoteRecruit
//
//  Created by Project
//

import Foundation
import os

/// Log levels for filtering log messages
enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3

    var label: String {
        switch self {
        case .debug:   return "🔍 DEBUG"
        case .info:    return "ℹ️ INFO"
        case .warning: return "⚠️ WARNING"
        case .error:   return "❌ ERROR"
        }
    }

    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Centralized logger for the entire app.
/// Logs to both console (with emoji indicators) and Apple's unified logging system (OSLog).
/// Supports filtering by minimum log level and category.
final class Logger {

    // MARK: - Shared Instance
    static let shared = Logger()

    // MARK: - Configuration
    /// Minimum log level to display. Default: .debug (show all)
    var minimumLogLevel: LogLevel = .debug

    /// Whether to enable console logging (for debugging)
    var enableConsoleLogging: Bool = true

    /// Whether to enable OSLog (Apple's unified logging)
    var enableOSLog: Bool = true

    /// Maximum body length to print (to avoid flooding console)
    var maxBodyLength: Int = 2000

    // MARK: - Private Properties
    private let dateFormatter: DateFormatter
    private let lock = NSLock()

    // MARK: - Initialization
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone.current
    }

    // MARK: - Public Logging Methods

    /// Log a debug message.
    func debug(_ message: String, category: String = "General", file: String = #file, line: Int = #line) {
        log(level: .debug, message: message, category: category, file: file, line: line)
    }

    /// Log an info message.
    func info(_ message: String, category: String = "General", file: String = #file, line: Int = #line) {
        log(level: .info, message: message, category: category, file: file, line: line)
    }

    /// Log a warning message.
    func warning(_ message: String, category: String = "General", file: String = #file, line: Int = #line) {
        log(level: .warning, message: message, category: category, file: file, line: line)
    }

    /// Log an error message.
    func error(_ message: String, category: String = "General", file: String = #file, line: Int = #line) {
        log(level: .error, message: message, category: category, file: file, line: line)
    }

    // MARK: - Network-Specific Logging

    /// Log an outgoing network request with full details.
    func logRequest(_ request: URLRequest) {
        guard enableConsoleLogging else { return }

        let timestamp = dateFormatter.string(from: Date())
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "nil"
        let headers = request.allHTTPHeaderFields ?? [:]
        let bodyString = request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "nil"

        let headerString = headers.map { "  \($0.key): \($0.value)" }.joined(separator: "\n")

        var logMessage = """
        ┌──────────────────────────────────────────────────────────
        │ 🌐 NETWORK REQUEST
        │ 📅 \(timestamp)
        │ 📍 \(method) \(url)
        │ 📋 Headers:
        \(headerString.isEmpty ? "  (none)" : headerString)
        """

        if bodyString != "nil", !bodyString.isEmpty {
            let truncatedBody = bodyString.count > maxBodyLength
                ? String(bodyString.prefix(maxBodyLength)) + "... [truncated]"
                : bodyString
            logMessage += "\n│ 📦 Body:\n│   \(truncatedBody)"
        }

        logMessage += "\n└──────────────────────────────────────────────────────────"

        print(logMessage)
        logToOSLog(level: .info, message: "REQUEST: \(method) \(url)", category: "Network")
    }

    /// Log a successful network response with full details.
    func logResponse(_ response: HTTPURLResponse, data: Data, duration: TimeInterval) {
        guard enableConsoleLogging else { return }

        let timestamp = dateFormatter.string(from: Date())
        let statusCode = response.statusCode
        let url = response.url?.absoluteString ?? "nil"
        let headers = response.allHeaderFields as? [String: String] ?? [:]
        let statusEmoji = (200...299).contains(statusCode) ? "✅" : "⚠️"

        let bodyString = String(data: data, encoding: .utf8) ?? "nil"
        let truncatedBody = bodyString.count > maxBodyLength
            ? String(bodyString.prefix(maxBodyLength)) + "... [truncated]"
            : bodyString

        let headerString = headers.map { "  \($0.key): \($0.value)" }.joined(separator: "\n")

        let logMessage = """
        ┌──────────────────────────────────────────────────────────
        │ \(statusEmoji) NETWORK RESPONSE
        │ 📅 \(timestamp)
        │ 📍 \(url)
        │ 📋 Status: \(statusCode)
        │ ⏱ Duration: \(String(format: "%.2f", duration))s
        │ 📋 Headers:
        \(headerString.isEmpty ? "  (none)" : headerString)
        │ 📦 Response Body:
        │   \(truncatedBody)
        └──────────────────────────────────────────────────────────
        """

        print(logMessage)
        logToOSLog(level: .info, message: "RESPONSE: \(statusCode) from \(url)", category: "Network")
    }

    /// Log a network error with full details.
    func logNetworkError(_ error: Error, request: URLRequest, duration: TimeInterval) {
        guard enableConsoleLogging else { return }

        let timestamp = dateFormatter.string(from: Date())
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "nil"

        let errorDescription: String
        if let appError = error as? AppError {
            errorDescription = appError.errorDescription ?? "Unknown app error"
        } else if let localizedError = error as? LocalizedError {
            errorDescription = localizedError.errorDescription ?? error.localizedDescription
        } else {
            errorDescription = error.localizedDescription
        }

        let logMessage = """
        ┌──────────────────────────────────────────────────────────
        │ ❌ NETWORK ERROR
        │ 📅 \(timestamp)
        │ 📍 \(method) \(url)
        │ ⏱ Duration: \(String(format: "%.2f", duration))s
        │ 🚨 Error: \(errorDescription)
        │ 🔍 Type: \(type(of: error))
        │ 📄 Details: \(error.localizedDescription)
        └──────────────────────────────────────────────────────────
        """

        print(logMessage)
        logToOSLog(level: .error, message: "ERROR: \(method) \(url) - \(errorDescription)", category: "Network")
    }

    // MARK: - Connectivity Logging

    /// Log network connectivity status change.
    func logConnectivityChange(isConnected: Bool, interface: String) {
        let status = isConnected ? "✅ Connected" : "❌ Disconnected"
        let message = "Network connectivity changed: \(status) (Interface: \(interface))"
        print("📡 \(message)")
        logToOSLog(level: .info, message: message, category: "Connectivity")
    }

    /// Log that a request was blocked due to no network.
    func logRequestBlocked(_ request: URLRequest) {
        let url = request.url?.absoluteString ?? "nil"
        let message = "🚫 Request blocked: No network connection - \(url)"
        print("┌──────────────────────────────────────────────────────────")
        print("│ \(message)")
        print("└──────────────────────────────────────────────────────────")
        logToOSLog(level: .warning, message: message, category: "Connectivity")
    }

    // MARK: - Private Methods

    private func log(level: LogLevel, message: String, category: String, file: String, line: Int) {
        guard level >= minimumLogLevel else { return }

        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent

        let formattedMessage = "\(level.label) [\(category)] [\(fileName):\(line)] \(timestamp) › \(message)"

        if enableConsoleLogging {
            print(formattedMessage)
        }

        if enableOSLog {
            logToOSLog(level: level, message: formattedMessage, category: category)
        }
    }

    private func logToOSLog(level: LogLevel, message: String, category: String) {
        let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.remoterecruit", category: category)
        let type: OSLogType

        switch level {
        case .debug:
            type = .debug
        case .info:
            type = .info
        case .warning:
            type = .fault
        case .error:
            type = .error
        }

        os_log("%{public}@", log: osLog, type: type, message)
    }
}

// MARK: - Global Convenience Function
/// Easy-to-use global logger function for quick debugging.
func LogDebug(_ message: String, category: String = "General", file: String = #file, line: Int = #line) {
    Logger.shared.debug(message, category: category, file: file, line: line)
}

func LogInfo(_ message: String, category: String = "General", file: String = #file, line: Int = #line) {
    Logger.shared.info(message, category: category, file: file, line: line)
}

func LogWarning(_ message: String, category: String = "General", file: String = #file, line: Int = #line) {
    Logger.shared.warning(message, category: category, file: file, line: line)
}

func LogError(_ message: String, category: String = "General", file: String = #file, line: Int = #line) {
    Logger.shared.error(message, category: category, file: file, line: line)
}