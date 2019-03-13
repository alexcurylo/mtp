// @copyright Trollwerks Inc.

@testable import MTP

// swiftlint:disable let_var_whitespace
final class SpyLoggingService: LoggingService {

    var invokedCustom = false
    var invokedCustomCount = 0
    func custom(level: LoggingLevel,
                message: @autoclosure () -> Any,
                file: String,
                function: String,
                line: Int,
                context: Any?) {
        invokedCustom = true
        invokedCustomCount += 1
    }
}
