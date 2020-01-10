// @copyright Trollwerks Inc.

import CommonCrypto
import UIKit

/// Convenience for localizable string typesafe access
typealias L = R.string.localizable
// swiftlint:disable:previous type_name

extension String {

    /// Partially mask email address with "*"
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

    /// Verify email is valid
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let valid = NSPredicate(format: "SELF MATCHES %@", regex)
        return valid.evaluate(with: self)
    }

    /// Verify name exists
    var isValidName: Bool {
        let stripped = trimmingCharacters(in: .whitespacesAndNewlines)
        return stripped.split(separator: " ").count > 1
    }

    /// Verify password matches MTP conditions
    var isValidPassword: Bool {
        return count >= 6 // as per signup.blade.php
    }

    /// Create attributed string with specified traits
    /// - Parameters:
    ///   - font: Font
    ///   - color: Color
    /// - Returns: Attributed string
    func attributed(font: UIFont,
                    color: UIColor) -> NSAttributedString {
        let attributes = NSAttributedString.attributes(
            color: color,
            font: font
        )
        return NSAttributedString(string: self, attributes: attributes)
    }

    /// Convert HTML doc to NSAttributedString if possible
    /// - Parameters:
    ///   - font: default font
    ///   - color: default color
    /// - Returns: Attributed string if possible
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

    private var htmlAttributes: (NSAttributedString?, NSDictionary?) {
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

    private func htmlAttributed(using font: UIFont,
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

    private func htmlAttributed(family: String?,
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

    /// Hash for analytics user identifier
    var md5Value: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)

        if let data = data(using: .utf8) {
            _ = data.withUnsafeBytes { body -> String in
                CC_MD5(body.baseAddress, CC_LONG(data.count), &digest)
                return ""
            }
        }

        return (0 ..< length).reduce(into: "") {
            $0 += String(format: "%02x", digest[$1])
        }
    }

    /// Return filename from a path
    var file: String {
        return components(separatedBy: "/").last ?? ""
    }

    /// Truncates the string to the specified length number of characters
    /// and appends an optional trailing string if longer.
    /// - Parameters:
    ///   - length: Desired maximum length of a string
    ///   - trailing: A 'String' that will be appended after the truncation
    /// - Returns: Truncated String
    func truncate(length: Int,
                  trailing: String = "…") -> String {
        return (count > length) ? prefix(length) + trailing : self
    }

    /// Initialize with StaticString such as `#file`
    /// - Parameter staticString: Compile time string
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}

extension String: LocalizedError {

    /// Treat a String as self documenting Error
    public var errorDescription: String? { return self }
}

private extension Formatter {

    static let grouping = NumberFormatter {
        $0.usesGroupingSeparator = true
        $0.numberStyle = .decimal
        $0.locale = Locale.current
    }
}

extension Int {

    /// Format in local grouping style
    var grouped: String {
        return Formatter.grouping.string(for: self) ?? ""
    }
}

extension NSAttributedString {

    /// For strongly typing attribute dictionaries
    typealias Attributes = [NSAttributedString.Key: Any]

    /// Wrap attribute values in Attributes
    /// - Parameters:
    ///   - color: Color
    ///   - font: Font
    /// - Returns: Attributes with color and/or font
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

    /// Convenience Range of entire string
    var fullRange: NSRange {
        return NSRange(string.startIndex..<string.endIndex, in: string)
    }
}

extension UIFont {

    /// Provide assignment attribute
    var attributes: NSAttributedString.Attributes {
        return [NSAttributedString.Key.font: self]
    }
}

private extension UIColor {

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

    /// Allow string subscripting by Int closed range
    /// - Parameter bounds: Range to subscript
    subscript(bounds: CountableClosedRange<Int>) -> SubSequence {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(start, offsetBy: bounds.count)
        return self[start..<end]
    }

    /// Allow string subscripting by Int range
    /// - Parameter bounds: Range to subscript
    subscript(bounds: CountableRange<Int>) -> SubSequence {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(start, offsetBy: bounds.count)
        return self[start..<end]
    }
}

extension NSMutableAttributedString {

    /// Self with whitespace trimmed from beginning and end
    var trimmed: NSAttributedString {
        guard let result = mutableCopy() as? NSMutableAttributedString else { return self }
        result.trimCharacters(in: .whitespacesAndNewlines)
        return result
    }

    func trimCharacters(in set: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: set)

        while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: set)
        }

        range = (string as NSString).rangeOfCharacter(from: set, options: .backwards)
        while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: set, options: .backwards)
        }
    }
}
