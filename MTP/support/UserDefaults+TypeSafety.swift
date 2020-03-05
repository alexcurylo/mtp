// @copyright Trollwerks Inc.

import UIKit

/// Typesafe wrapper for stringly typed APIs
struct StringKey: Hashable, RawRepresentable, ExpressibleByStringLiteral {

    /// Info.plist application version
    static let appVersion: StringKey = "CFBundleShortVersionString"
    /// Info.plist application build
    static let appBuild: StringKey = "CFBundleVersion"

    /// Text value
    var rawValue: String

    /// Raw value constructor
    /// - Parameter rawValue: Key string
    init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// String literal constructor
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
        [
            .appVersion,
            .appBuild,
        ]
    }

    /// Settings key value from Info.plist
    var infoString: String? {
        Bundle.main.object(forInfoDictionaryKey: rawValue) as? String
    }

    /// Settings key value from UserDefaults
    var string: String? {
        UserDefaults.standard.string(forKey: rawValue)
    }
}

private extension Array where Element == StringKey {

    func copyToUserDefaults() {
        let defaults = UserDefaults.standard
        forEach { defaults[$0] = $0.infoString }
        defaults.synchronize()
    }
}

extension UserDefaults {

    /// Typed value setting
    /// - Parameter key: Key string
    func set<T>(_ value: T?, forKey key: StringKey) {
        set(value, forKey: key.rawValue)
    }

    /// Typed value access
    /// - Parameter key: Key string
    func value<T>(forKey key: StringKey) -> T? {
        value(forKey: key.rawValue) as? T
    }

    /// Default setting convenience
    /// - Parameter defaults: Defaults
    func register(defaults: [StringKey: Any]) {
        let mapped = defaults.map { key, value -> (String, Any) in
            if let color = value as? UIColor {
                return (key.rawValue, NSKeyedArchiver.archivedData(withRootObject: color))
            }
            return (key.rawValue, value)
        }

        register(defaults: Dictionary(uniqueKeysWithValues: mapped))
    }
}

extension UserDefaults {

    /// Typed subscript access
    /// - Parameter key: Key string
    subscript<T>(key: StringKey) -> T? {
        get { value(forKey: key) }
        set { set(newValue, forKey: key) }
    }

    /// Bool subscript access
    /// - Parameter key: Key string
    subscript(key: StringKey) -> Bool {
        get { bool(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// Int subscript access
    /// - Parameter key: Key string
    subscript(key: StringKey) -> Int {
        get { integer(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// Double subscript access
    /// - Parameter key: Key string
    subscript(key: StringKey) -> Double {
        get { double(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// Float subscript access
    /// - Parameter key: Key string
    subscript(key: StringKey) -> Float {
        get { float(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// CGFloat subscript access
    /// - Parameter key: Key string
    subscript(key: StringKey) -> CGFloat {
        get { cgFloat(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }

    /// Color subscript access
    /// - Parameter key: Key string
    subscript(key: StringKey) -> UIColor? {
        get { color(forKey: key) }
        set { set(color: newValue, forKey: key) }
    }

    /// URL subscript access
    /// - Parameter key: Key string
    subscript(key: StringKey) -> URL? {
        get { url(forKey: key) }
        set { set(newValue, forKey: key.rawValue) }
    }
}

extension UserDefaults {

    /// Bool access convenience
    /// - Parameter key: Key string
    /// - Returns: Bool
    func bool(forKey key: StringKey) -> Bool {
        bool(forKey: key.rawValue)
    }

    /// Int access convenience
    /// - Parameter key: Key string
    /// - Returns: Int
    func integer(forKey key: StringKey) -> Int {
        integer(forKey: key.rawValue)
    }

    /// Float access convenience
    /// - Parameter key: Key string
    /// - Returns: Float
    func float(forKey key: StringKey) -> Float {
        float(forKey: key.rawValue)
    }

    /// CGFloat access convenience
    /// - Parameter key: Key string
    /// - Returns: CGFloat
    func cgFloat(forKey key: StringKey) -> CGFloat {
        CGFloat(double(forKey: key.rawValue))
    }

    /// double access convenience
    /// - Parameter key: Key string
    /// - Returns: double
    func double(forKey key: StringKey) -> Double {
        double(forKey: key.rawValue)
    }

    /// URL access convenience
    /// - Parameter key: Key string
    /// - Returns: URL if present
    func url(forKey key: StringKey) -> URL? {
        url(forKey: key.rawValue)
    }

    /// Color setting convenience
    /// - Parameters:
    ///   - color: Value to store
    ///   - key: Key string
    func set(color: UIColor?, forKey key: StringKey) {
        if let color = color {
            let data = NSKeyedArchiver.archivedData(withRootObject: color)
            set(data, forKey: key.rawValue)
        } else {
            set(nil, forKey: key.rawValue)
        }
    }

    /// Color access convenience
    /// - Parameter key: Key string
    /// - Returns: UIColor if present
    func color(forKey key: StringKey) -> UIColor? {
        data(forKey: key.rawValue)
            .flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) as? UIColor }
    }
}

extension UserDefaults {

    /// Set Codable object into UserDefaults
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    func set<T: Codable>(object: T,
                         forKey: String) throws {
        let jsonData = try JSONEncoder().encode(object)
        set(jsonData, forKey: forKey)
    }

    /// Get Codable object from UserDefaults
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    func get<T: Codable>(objectType: T.Type,
                         forKey: String) throws -> T? {
        guard let result = value(forKey: forKey) as? Data else {
            return nil
        }
        return try JSONDecoder().decode(objectType, from: result)
    }
}
