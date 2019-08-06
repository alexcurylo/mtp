// @copyright Trollwerks Inc.

import UIKit

struct StringKey: Hashable, RawRepresentable, ExpressibleByStringLiteral {

    private static let cfBundleShortVersionString: StringKey = "CFBundleShortVersionString"
    private static let cfBundleVersion: StringKey = "CFBundleVersion"

    /// Text value
    var rawValue: String

    /// Raw value constructor
    ///
    /// - Parameter rawValue: Key string
    init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// String literal constructor
    ///
    /// - Parameter value: Key string
    init(stringLiteral value: String) {
        self.rawValue = value
    }

    /// Fill in values displayed in Settings app
    static func configureSettingsDisplay() {
        StringKey.infoDictionarySettingsKeys.copyToUserDefaults()
    }

    /// Settings keys we expect to find in Info.plist
    static var infoDictionarySettingsKeys: [StringKey] {
        return [.cfBundleShortVersionString,
                .cfBundleVersion]
    }

    fileprivate var infoDictionaryString: String? {
        return Bundle.main.object(forInfoDictionaryKey: rawValue) as? String
    }
}

private extension Array where Element == StringKey {

    func copyToUserDefaults() {
        let defaults = UserDefaults.standard
        forEach { defaults[$0] = $0.infoDictionaryString }
        defaults.synchronize()
    }
}

extension UserDefaults {

    /// Typed value setting
    ///
    /// - Parameter key: Key string
    func set<T>(_ value: T?, forKey key: StringKey) {
        set(value, forKey: key.rawValue)
    }

    /// Typed value access
    ///
    /// - Parameter key: Key string
    func value<T>(forKey key: StringKey) -> T? {
        return value(forKey: key.rawValue) as? T
    }

    /// Default setting convenience
    ///
    /// - Parameter defaults: Defaults
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

    /// Typed subscript access
    ///
    /// - Parameter key: Key string
    subscript<T>(key: StringKey) -> T? {
        get { return value(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// Bool subscript access
    ///
    /// - Parameter key: Key string
    subscript(key: StringKey) -> Bool {
        get { return bool(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// Int subscript access
    ///
    /// - Parameter key: Key string
    subscript(key: StringKey) -> Int {
        get { return integer(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// Double subscript access
    ///
    /// - Parameter key: Key string
    subscript(key: StringKey) -> Double {
        get { return double(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// Float subscript access
    ///
    /// - Parameter key: Key string
    subscript(key: StringKey) -> Float {
        get { return float(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// CGFloat subscript access
    ///
    /// - Parameter key: Key string
    subscript(key: StringKey) -> CGFloat {
        get { return CGFloat(float(forKey: key) as Float) }
        set { set(newValue, forKey: key.rawValue) }
    }
}

extension UserDefaults {

    /// Bool access convenience
    ///
    /// - Parameter key: Key string
    /// - Returns: Bool
    func bool(forKey key: StringKey) -> Bool {
        return bool(forKey: key.rawValue)
    }

    /// Int access convenience
    ///
    /// - Parameter key: Key string
    /// - Returns: Int
    func integer(forKey key: StringKey) -> Int {
        return integer(forKey: key.rawValue)
    }

    /// Float access convenience
    ///
    /// - Parameter key: Key string
    /// - Returns: Float
    func float(forKey key: StringKey) -> Float {
        return float(forKey: key.rawValue)
    }

    /// CGFloat access convenience
    ///
    /// - Parameter key: Key string
    /// - Returns: CGFloat
    func float(forKey key: StringKey) -> CGFloat {
        return CGFloat(float(forKey: key) as Float)
    }

    /// double access convenience
    ///
    /// - Parameter key: Key string
    /// - Returns: double
    func double(forKey key: StringKey) -> Double {
        return double(forKey: key.rawValue)
    }

    /// URL access convenience
    ///
    /// - Parameter key: Key string
    /// - Returns: URL if present
    func url(forKey key: StringKey) -> URL? {
        return url(forKey: key.rawValue)
    }

    /// Date access convenience
    ///
    /// - Parameter key: Key string
    /// - Returns: Date if present
    func date(forKey key: StringKey) -> Date? {
        return object(forKey: key.rawValue) as? Date
    }

    /// String access convenience
    ///
    /// - Parameter key: Key string
    /// - Returns: String if present
    func string(forKey key: StringKey) -> String? {
        return string(forKey: key.rawValue)
    }

    /// Color setting convenience
    ///
    /// - Parameters:
    ///   - color: Value to store
    ///   - key: Key string
    func set(_ color: UIColor, forKey key: StringKey) {
        let data = NSKeyedArchiver.archivedData(withRootObject: color)
        set(data, forKey: key.rawValue)
    }

    /// Color access convenience
    ///
    /// - Parameter key: Key string
    /// - Returns: UIColor if present
    func color(forKey key: StringKey) -> UIColor? {
        return data(forKey: key.rawValue)
            .flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) as? UIColor }
    }
}

extension UserDefaults {

    /// Set Codable object into UserDefaults
    ///
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    func set<T: Codable>(object: T, forKey: String) throws {

        let jsonData = try JSONEncoder().encode(object)

        set(jsonData, forKey: forKey)
    }

    /// Get Codable object into UserDefaults
    ///
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    func get<T: Codable>(objectType: T.Type, forKey: String) throws -> T? {

        guard let result = value(forKey: forKey) as? Data else {
            return nil
        }

        return try JSONDecoder().decode(objectType, from: result)
    }
}
