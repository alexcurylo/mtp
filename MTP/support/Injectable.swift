// @copyright Trollwerks Inc.

import Foundation

/// Dependency injection template
protocol Injectable {

    /// Information to inject
    associatedtype Model

    /// Inject dependencies
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self

    /// Injection enforcement
    /// viewDidLoad is a good place to check Model and IBOutlets
    func requireInjections()
}

extension Optional {

    /// Catastrophic unwrap
    ///
    /// - Parameters:
    ///   - file: Diagnostic filename
    ///   - line: Diagnostic line number
    /// - Returns: Wrapped value
    @discardableResult func require(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Wrapped {
        guard let self = self else {
            let message = "Required value nil: \(file): \(line)"
            preconditionFailure(message)
        }

        return self
    }
}

extension Optional where Wrapped == String {

    /// Convenience function identifying populated value
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension Optional where Wrapped: Collection {

    /// Convenience function identifying populated value
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

/// Generic error for unexpectedly nil optionals
struct UnwrapError<T>: LocalizedError {

    let file: StaticString
    let line: UInt
    var errorDescription: String? {
        return "failed to unwrap \(T.self) at line \(line) in file \(file)."
    }
}

/// Throw error on unwrapping optional
///
/// - Parameters:
///   - optional: The Optional to unwrap
///   - file: Diagnostic filename
///   - line: Diagnostic line number
/// - Returns: Wrapped value
/// - Throws: UnwrapError if nil
func unwrap<T>(_ optional: @autoclosure () -> T?,
               file: StaticString = #file,
               line: UInt = #line) throws -> T {
    guard let value = optional() else {
        throw UnwrapError<T>(file: file, line: line)
    }
    return value
}
