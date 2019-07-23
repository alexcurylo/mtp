// @copyright Trollwerks Inc.

import UIKit

protocol Exposable {

    var identifier: String { get }
}

extension Exposable {

    var identifier: String {
        let reflected = String(reflecting: type(of: self)) + "_\(self)"
        return reflected.replacingOccurrences(of: "\"", with: "")
    }

    func expose(item: UIAccessibilityIdentification?) {
        guard let item = item else { return }
        item.accessibilityIdentifier = identifier
    }
}

extension UIAccessibilityIdentification {

    func expose(id: Exposable?) {
        guard let id = id else { return }
        accessibilityIdentifier = id.identifier
    }
}

enum MainTabBar: Exposable {
    case bar
    case locations
    case rankings
    case profile
}
