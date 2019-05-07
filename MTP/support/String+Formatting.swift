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

    func attributed(font: UIFont,
                    color: UIColor) -> NSAttributedString {
        let attributes = NSAttributedString.attributes(
            color: color,
            font: font
        )
        return NSAttributedString(string: self, attributes: attributes)
    }

    func html2Attributed(font: UIFont,
                         color: UIColor) -> NSMutableAttributedString? {
        guard let data = data(using: String.Encoding.utf8) else { return nil }

        guard let attributed = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        ) else { return nil }

        let attributes = NSAttributedString.attributes(
            color: color,
            font: font
        )
        attributed.addAttributes(attributes, range: attributed.fullRange)

        return attributed
    }

    var htmlAttributes: (NSAttributedString?, NSDictionary?) {
        guard let data = data(using: String.Encoding.utf8) else {
            return (nil, nil)
        }

        var dict: NSDictionary?
        dict = NSMutableDictionary()

        let string = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: &dict
        )
        return (string, dict)
    }

    func htmlAttributed(using font: UIFont,
                        color: UIColor) -> NSAttributedString? {
        let htmlCSSString = "<style>" +
            "html *" +
            "{" +
            "font-size: \(font.pointSize)pt !important;" +
            "color: #\(color.hexString) !important;" +
            "font-family: \(font.familyName), Helvetica !important;" +
        "}</style> \(self)"

        guard let data = htmlCSSString.data(using: String.Encoding.utf8) else { return nil }

        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        )
    }

    func htmlAttributed(family: String?,
                        size: CGFloat,
                        color: UIColor) -> NSAttributedString? {
        let htmlCSSString = "<style>" +
            "html *" +
            "{" +
            "font-size: \(size)pt !important;" +
            "color: #\(color.hexString) !important;" +
            "font-family: \(family ?? "Helvetica"), Helvetica !important;" +
        "}</style> \(self)"

        guard let data = htmlCSSString.data(using: String.Encoding.utf8) else { return nil }

        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        )
    }
}

extension String: LocalizedError {

    public var errorDescription: String? { return self }
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

    var fullRange: NSRange {
        return NSRange(string.startIndex..<string.endIndex, in: string)
    }
}

extension UIFont {

    var attributes: NSAttributedString.Attributes {
        return [NSAttributedString.Key.font: self]
    }
}

extension UIColor {

    // swiftlint:disable:next large_tuple
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }

    var hexString: String {
        let components = rgba
        return String(format: "%02X%02X%02X",
                      (Int)(components.red * 255),
                      (Int)(components.green * 255),
                      (Int)(components.blue * 255))
    }
}

extension StringProtocol {

    subscript(bounds: CountableClosedRange<Int>) -> SubSequence {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(start, offsetBy: bounds.count)
        return self[start..<end]
    }

    subscript(bounds: CountableRange<Int>) -> SubSequence {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(start, offsetBy: bounds.count)
        return self[start..<end]
    }
}
