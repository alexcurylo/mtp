// @copyright Trollwerks Inc.

import UIKit

public enum LoggingLevel: Int {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
}

protocol LoggingService {

    func custom(level: LoggingLevel,
                message: @autoclosure () -> Any,
                file: String,
                function: String,
                line: Int,
                context: Any?)
}

extension LoggingService {

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

extension UIStoryboardSegue {

    var name: String {
        return identifier ?? "<unnamed>"
    }
}
