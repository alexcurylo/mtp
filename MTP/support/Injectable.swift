// @copyright Trollwerks Inc.

import Foundation

protocol Injectable {

    associatedtype Model

    func inject(model: Model)

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
