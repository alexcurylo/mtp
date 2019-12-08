// @copyright Trollwerks Inc.

import UIKit

/// Streamline configuration closures/functions
protocol Withable {

    /// Anything initializable conforms
    init()
}

extension Withable {

    /// Construct a new instance and configure
    /// - Parameter configure: configuration closure/function
    /// - Returns: configured object
    init(with configure: (inout Self) -> Void) {
        self.init()
        configure(&self)
    }

    /// Construct a copy and configure
    /// - Parameter configure: configuration closure/function
    /// - Returns: configured copy of object
    func with(_ configure: (inout Self) -> Void) -> Self {
        var copy = self
        configure(&copy)
        return copy
    }
}

extension Optional where Wrapped: Withable {

    /// Construct a copy or original and configure
    /// - Parameter configure: configuration closure/function
    /// - Returns: configured object
    func with(_ configure: (inout Wrapped) -> Void) -> Wrapped {
        switch self {
        // swiftlint:disable:next explicit_init
        case .none: return Wrapped.init(with: configure)
        case .some(let object): return object.with(configure)
        }
    }
}

/// Apply to all Foundation + UIKit objects by default
extension NSObject: Withable {}
