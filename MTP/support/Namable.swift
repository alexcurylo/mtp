// @copyright Trollwerks Inc.

import Foundation

/// Wrapper to produce type names for identifers and the like
protocol Namable {

    /// name from instance
    var typeName: String { get }
    /// name from class
    static var typeName: String { get }
}

extension Namable {

    /// name from instance
    var typeName: String {
        return String(describing: type(of: self))
    }

    /// name from class
    static var typeName: String {
        return String(describing: self)
    }
}

extension Array: Namable {}
extension NSObject: Namable {}
