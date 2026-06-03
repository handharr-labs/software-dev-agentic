---
platform: ios
project: ios-talenta
discipline: engineering
topic: utilities
pattern: logger
---

## Theory

**Logger** is the centralized logging abstraction with severity levels. All log output goes through this interface.

**Invariants:**
- Severity levels: `debug`, `info`, `warning`, `error` — each with distinct routing (debug stripped in production)
- No `print` / `console.log` / `Log.d` calls at call sites — always use the Logger interface
- Sensitive data (tokens, PII) must never appear in log output
- The implementation routes to Crashlytics or the platform crash reporter for `error`-level events

**When to use:** Any layer that needs diagnostic output. Inject `Logger` — never call the platform logging API directly.

---

## Logger

Centralized logging with severity levels.

```swift
// Core/Logger/Logger.swift
import OSLog

enum LogLevel: Int, Comparable {
    case verbose = 0, debug = 1, info = 2, warning = 3, error = 4
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool { lhs.rawValue < rhs.rawValue }
}

protocol Logger {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
}

extension Logger {
    func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .verbose, file: file, function: function, line: line)
    }
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}

final class ConsoleLogger: Logger {
    private let minLevel: LogLevel
    private let osLogger: OSLog.Logger

    init(minLevel: LogLevel = .debug) {
        self.minLevel = minLevel
        self.osLogger = OSLog.Logger(subsystem: Bundle.main.bundleIdentifier ?? "app", category: "general")
    }

    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        guard level >= minLevel else { return }
        let filename = (file as NSString).lastPathComponent
        osLogger.log(level: level.osLogType, "\(level.emoji) [\(filename):\(line)] \(function): \(message)")
    }
}

enum Log {
    nonisolated(unsafe) static var shared: Logger = ConsoleLogger()
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) { shared.debug(message, file: file, function: function, line: line) }
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) { shared.info(message, file: file, function: function, line: line) }
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) { shared.warning(message, file: file, function: function, line: line) }
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) { shared.error(message, file: file, function: function, line: line) }
}
```
