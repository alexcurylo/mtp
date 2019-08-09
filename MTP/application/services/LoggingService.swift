// @copyright Trollwerks Inc.

import UIKit

/// Type of log statement
public enum LoggingLevel: Int, CustomStringConvertible {

    /// Verbose
    case verbose
    /// Debug
    case debug
    /// Info
    case info
    /// Warning
    case warning
    /// Error
    case error

    public var description: String {
        return ["💬", "🛠️", "📌", "⚠️", "💥"][rawValue]
    }
}

/// Wraps a single logging statement implmentation
protocol LoggingService {

    /// Wrap point for log API integration
    ///
    /// - Parameters:
    ///   - level: LoggingLevel
    ///   - message: Describable autoclosure
    ///   - file: File marker
    ///   - function: Function marker
    ///   - line: Line marker
    ///   - context: If service requires such
    func custom(level: LoggingLevel,
                message: @autoclosure () -> Any,
                file: String,
                function: String,
                line: Int,
                context: Any?)
}

extension LoggingService {

    /// Todo logging convenience
    ///
    /// - Parameters:
    ///   - message: String
    ///   - file: File marker
    ///   - function: Function marker
    ///   - line: Line marker
    func todo(_ message: String,
              _ file: String = #file,
              _ function: String = #function,
              line: Int = #line) {
        custom(level: .verbose,
               message: "TODO: " + message,
               file: file,
               function: function,
               line: line,
               context: nil)
    }

    /// Verbose logging wrapper
    ///
    /// - Parameters:
    ///   - message: String
    ///   - file: File marker
    ///   - function: Function marker
    ///   - line: Line marker
    ///   - context: If service requires such
    func verbose(_ message: @autoclosure () -> Any,
                 _ file: String = #file,
                 _ function: String = #function,
                 line: Int = #line,
                 context: Any? = nil) {
        custom(level: .verbose,
               message: message(),
               file: file,
               function: function,
               line: line,
               context: context)
    }

    /// Debug logging wrapper
    ///
    /// - Parameters:
    ///   - message: String
    ///   - file: File marker
    ///   - function: Function marker
    ///   - line: Line marker
    ///   - context: If service requires such
    func debug(_ message: @autoclosure () -> Any,
               _ file: String = #file,
               _ function: String = #function,
               line: Int = #line,
               context: Any? = nil) {
        custom(level: .debug,
               message: message(),
               file: file,
               function: function,
               line: line,
               context: context)
    }

    /// Info logging wrapper
    ///
    /// - Parameters:
    ///   - message: String
    ///   - file: File marker
    ///   - function: Function marker
    ///   - line: Line marker
    ///   - context: If service requires such
    func info(_ message: @autoclosure () -> Any,
              _ file: String = #file,
              _ function: String = #function,
              line: Int = #line,
              context: Any? = nil) {
        custom(level: .info,
               message: message(),
               file: file,
               function: function,
               line: line,
               context: context)
    }

    /// Warning logging wrapper
    ///
    /// - Parameters:
    ///   - message: String
    ///   - file: File marker
    ///   - function: Function marker
    ///   - line: Line marker
    ///   - context: If service requires such
    func warning(_ message: @autoclosure () -> Any,
                 _ file: String = #file,
                 _ function: String = #function,
                 line: Int = #line,
                 context: Any? = nil) {
        custom(level: .warning,
               message: message(),
               file: file,
               function: function,
               line: line,
               context: context)
    }

    /// Error logging wrapper
    ///
    /// - Parameters:
    ///   - message: String
    ///   - file: File marker
    ///   - function: Function marker
    ///   - line: Line marker
    ///   - context: If service requires such
    func error(_ message: @autoclosure () -> Any,
               _ file: String = #file,
               _ function: String = #function,
               line: Int = #line,
               context: Any? = nil) {
        custom(level: .error,
               message: message(),
               file: file,
               function: function,
               line: line,
               context: context)
    }
}

/// Wraps console print
struct ConsoleLoggingService: LoggingService {

    func custom(level: LoggingLevel,
                message: @autoclosure () -> Any,
                file: String,
                function: String,
                line: Int,
                context: Any?) {
        // copy file:line for ⌘⇧O
        print("⏱\(timestamp) \(level)\(message()) 📂\(file.file):\(line) ⚙️\(function)")
    }

    private var timestamp: String {
        return DateFormatter.stampTime.string(from: Date())
    }
}

private extension String {

    var file: String {
        return components(separatedBy: "/").last ?? ""
    }
}

extension UIStoryboardSegue {

    /// Describe unnamed segues
    var name: String {
        return identifier ?? "<unnamed>"
    }
}
