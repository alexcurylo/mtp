// @copyright Trollwerks Inc.

import UIKit

extension UIApplication {

    static var isUnitTesting: Bool {
        let isUnitTesting = NSClassFromString("XCTestCase") != nil
        return isUnitTesting
    }

    static var isUITesting: Bool {
        let isUITesting = ProcessInfo.arguments(contain: .uiTestingMode)
        return isUITesting
    }

    static var isTesting: Bool {
        return isUITesting || isUnitTesting
    }

    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}

enum LaunchArgument: String {
    case uiTestingMode
}

enum LaunchSettingKey: String {
    case loggedIn
}

enum LaunchSetting {
    case loggedIn(Bool)

    var key: String {
        switch self {
        case .loggedIn:
            return LaunchSettingKey.loggedIn.rawValue
        }
    }

    var value: String {
        switch self {
        case .loggedIn(let loggedIn):
            return "\(loggedIn)"
        }
    }

    var setting: [String: String] {
        switch self {
        case .loggedIn:
            return [key: value]
        }
    }
}

extension ProcessInfo {

    static func arguments(contain argument: LaunchArgument) -> Bool {
        return processInfo.arguments.contains(argument.rawValue)
    }

    static func settings(contain setting: LaunchSetting) -> Bool {
        return processInfo.environment[setting.key] == setting.value
    }

    static func setting(string key: LaunchSettingKey) -> String? {
        return processInfo.environment[key.rawValue]
    }

    // swiftlint:disable:next discouraged_optional_boolean
    static func setting(bool key: LaunchSettingKey) -> Bool? {
        guard let value = processInfo.environment[key.rawValue] else { return nil }
        return Bool(value)
    }
}
