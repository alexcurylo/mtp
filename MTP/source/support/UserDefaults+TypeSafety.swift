// @copyright Trollwerks Inc.

import UIKit

struct StringKey: Hashable, RawRepresentable, ExpressibleByStringLiteral {

    static let cfBuildDate: StringKey = "CFBuildDate"
    static let cfBundleShortVersionString: StringKey = "CFBundleShortVersionString"
    static let cfBundleVersion: StringKey = "CFBundleVersion"

    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(stringLiteral value: String) {
        self.rawValue = value
    }

    static var infoDictionaryKeys: [StringKey] {
        return [.cfBuildDate, .cfBundleShortVersionString, .cfBundleVersion]
    }

    var infoDictionaryString: String? {
        return Bundle.main.object(forInfoDictionaryKey: rawValue) as? String
    }
}

extension Array where Element == StringKey {

    func copyToUserDefaults() {
        let defaults = UserDefaults.standard
        forEach { defaults[$0] = $0.infoDictionaryString }
        defaults.synchronize()
    }
}

extension UserDefaults {

    func set<T>(_ value: T?, forKey key: StringKey) {
        set(value, forKey: key.rawValue)
    }

    func value<T>(forKey key: StringKey) -> T? {
        return value(forKey: key.rawValue) as? T
    }

    func register(defaults: [StringKey: Any]) {
        let mapped = Dictionary(uniqueKeysWithValues: defaults.map { key, value -> (String, Any) in
            if let color = value as? UIColor {
                return (key.rawValue, NSKeyedArchiver.archivedData(withRootObject: color))
            } else {
                return (key.rawValue, value)
            }
        })

        register(defaults: mapped)
    }
}

extension UserDefaults {

    subscript<T>(key: StringKey) -> T? {
        get { return value(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    subscript(key: StringKey) -> Bool {
        get { return bool(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    subscript(key: StringKey) -> Int {
        get { return integer(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    subscript(key: StringKey) -> Double {
        get { return double(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    subscript(key: StringKey) -> Float {
        get { return float(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    subscript(key: StringKey) -> CGFloat {
        get { return CGFloat(float(forKey: key) as Float) }
        set { set(newValue, forKey: key.rawValue) }
    }
}

extension UserDefaults {

    func bool(forKey key: StringKey) -> Bool {
        return bool(forKey: key.rawValue)
    }

    func integer(forKey key: StringKey) -> Int {
        return integer(forKey: key.rawValue)
    }

    func float(forKey key: StringKey) -> Float {
        return float(forKey: key.rawValue)
    }

    func float(forKey key: StringKey) -> CGFloat {
        return CGFloat(float(forKey: key) as Float)
    }

    func double(forKey key: StringKey) -> Double {
        return double(forKey: key.rawValue)
    }

    func url(forKey key: StringKey) -> URL? {
        return url(forKey: key.rawValue)
    }

    func date(forKey key: StringKey) -> Date? {
        return object(forKey: key.rawValue) as? Date
    }

    func string(forKey key: StringKey) -> String? {
        return string(forKey: key.rawValue)
    }

    func set(_ color: UIColor, forKey key: StringKey) {
        let data = NSKeyedArchiver.archivedData(withRootObject: color)
        set(data, forKey: key.rawValue)
    }

    func color(forKey key: StringKey) -> UIColor? {
        return data(forKey: key.rawValue)
            .flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) as? UIColor }
    }
}
