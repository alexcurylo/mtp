// @copyright Trollwerks Inc.

import Foundation

protocol Injectable {

    associatedtype Model

    @discardableResult func inject(model: Model) -> Self

    // viewDidLoad is a good place to check Model and IBOutlets
    func requireInjections()
}

extension Optional {

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
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

struct UnwrapError<T>: LocalizedError {

    let file: StaticString
    let line: UInt
    var errorDescription: String? {
        return "failed to unwrap \(T.self) at line \(line) in file \(file)."
    }
}

func unwrap<T>(_ optional: @autoclosure () -> T?,
               file: StaticString = #file,
               line: UInt = #line) throws -> T {
    guard let value = optional() else {
        throw UnwrapError<T>(file: file, line: line)
    }
    return value
}
