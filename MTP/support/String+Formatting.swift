// @copyright Trollwerks Inc.

import UIKit

typealias Localized = R.string.localizable

extension String {

    var hiddenName: String {
        let pieces = components(separatedBy: "@")
        guard pieces.count > 1,
            let name = pieces.first,
            name.count > 2,
            let first = name.first,
            let last = name.last else {
                return self
        }
        let middle = name.dropFirst().dropLast().map { _ in "*" }.joined()
        let rest = dropFirst(name.count)
        return "\(first)\(middle)\(last)\(rest)"
    }

    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let valid = NSPredicate(format: "SELF MATCHES %@", regex)
        return valid.evaluate(with: self)
    }

    var isValidName: Bool {
        let stripped = trimmingCharacters(in: .whitespacesAndNewlines)
        return stripped.split(separator: " ").count > 1
    }

    var isValidPassword: Bool {
        return count >= 6 // as per signup.blade.php
    }
}

extension Formatter {

    static let grouping = NumberFormatter {
        $0.usesGroupingSeparator = true
        $0.numberStyle = .decimal
        $0.locale = Locale.current
    }
}

extension Int {

    var grouped: String {
        return Formatter.grouping.string(for: self) ?? ""
    }
}

extension NSAttributedString {

    typealias Attributes = [NSAttributedString.Key: Any]

    static func attributes(color: UIColor? = nil,
                           font: UIFont? = nil) -> Attributes {
        var attributes = NSAttributedString.Attributes()

        if let color = color {
            attributes[.foregroundColor] = color
        }
        if let font = font {
            attributes[.font] = font
        }

        return attributes
    }
}
