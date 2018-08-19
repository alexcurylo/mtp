// @copyright Trollwerks Inc.

import UIKit

let log = Logger.self

enum Logger {

    static func verbose(_ message: @autoclosure () -> Any,
                        _ file: String = #file,
                        _ function: String = #function,
                        line: Int = #line,
                        context: Any? = nil) {
        swiftyBeaver.custom(level: .verbose,
                            message: message,
                            file: file,
                            function: function,
                            line: line,
                            context: context)
    }

    static func debug(_ message: @autoclosure () -> Any,
                      _ file: String = #file,
                      _ function: String = #function,
                      line: Int = #line,
                      context: Any? = nil) {
        swiftyBeaver.custom(level: .debug,
                            message: message,
                            file: file,
                            function: function,
                            line: line,
                            context: context)
    }

    static func info(_ message: @autoclosure () -> Any,
                     _ file: String = #file,
                     _ function: String = #function,
                     line: Int = #line,
                     context: Any? = nil) {
        swiftyBeaver.custom(level: .info,
                            message: message,
                            file: file,
                            function: function,
                            line: line,
                            context: context)
    }

    static func warning(_ message: @autoclosure () -> Any,
                        _ file: String = #file,
                        _ function: String = #function,
                        line: Int = #line,
                        context: Any? = nil) {
        swiftyBeaver.custom(level: .warning,
                            message: message,
                            file: file,
                            function: function,
                            line: line,
                            context: context)
    }

    static func error(_ message: @autoclosure () -> Any,
                      _ file: String = #file,
                      _ function: String = #function,
                      line: Int = #line,
                      context: Any? = nil) {
        swiftyBeaver.custom(level: .error,
                            message: message,
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
