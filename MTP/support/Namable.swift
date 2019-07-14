// @copyright Trollwerks Inc.

import Foundation

protocol Namable {

    var typeName: String { get }
    static var typeName: String { get }
}

extension Namable {

    var typeName: String {
        return String(describing: type(of: self))
    }

    static var typeName: String {
        return String(describing: self)
    }
}

extension Array: Namable {}
extension NSObject: Namable {}
