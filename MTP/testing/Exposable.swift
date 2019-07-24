// @copyright Trollwerks Inc.

import UIKit

protocol Exposable {

    var identifier: String { get }
}

extension Exposable {

    var identifier: String {
        return "\(String(describing: type(of: self))).\(self)"
    }

    func expose(item: UIAccessibilityIdentification?) {
        guard let item = item else { return }
        item.accessibilityIdentifier = identifier
    }
}

extension UIAccessibilityIdentification {

    func expose(as exposable: Exposable?) {
        guard let identifier = exposable?.identifier else { return }
        accessibilityIdentifier = identifier
    }
}

enum MainTBCs: Exposable {
    case bar
    case locations
    case rankings
    case myProfile
}

enum LocationsVCs: Exposable {
    case nav
    case filter
    case nearby
}
