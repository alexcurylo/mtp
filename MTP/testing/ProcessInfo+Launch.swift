// @copyright Trollwerks Inc.

import UIKit

/// Arguments that UI tests can pass on launch
enum LaunchArgument: String {

    /// Disable UI animations
    case disableAnimations
    /// Disable waitForQuiescenceIncludingAnimationsIdle
    case disableWaitIdle
    /// Taking screenshots with fastlane
    case takingScreenshots
    /// Launched by UI tests
    case uiTesting
}

/// Setting keys that UI tests can pass on launch
enum LaunchSettingKey: String {

    /// Whether to present as logged in
    case loggedIn
    /// Token for notifications
    case token
}

/// Settings that UI tests can pass on launch
enum LaunchSetting {

    /// Whether to present as logged in
    case loggedIn(Bool)
    /// Token for notifications
    case token(String)

    /// Conventionally a LaunchSettingKey case
    var key: String {
        switch self {
        case .loggedIn:
            return LaunchSettingKey.loggedIn.rawValue
        case .token:
            return LaunchSettingKey.token.rawValue
        }
    }

    /// Encoding of setting value
    var value: String {
        switch self {
        case .loggedIn(let loggedIn):
            return "\(loggedIn)"
        case .token(let token):
            return "\(token)"
        }
    }

    /// Construct setting for launch dictionary
    var setting: [String: String] {
        [key: value]
    }
}

extension ProcessInfo {

    /// Test for argument existence
    /// - Parameter argument: argument to look for
    /// - Returns: Whether found
    static func arguments(contain argument: LaunchArgument) -> Bool {
        processInfo.arguments.contains(argument.rawValue)
    }

    /// String-extracting convenience
    /// - Parameter key: Key to look for
    /// - Returns: String value if found
    static func setting(string key: LaunchSettingKey) -> String? {
        processInfo.environment[key.rawValue]
    }

    /// Bool-extracting convenience
    /// - Parameter key: Key to look for
    /// - Returns: Bool value if found
    static func setting(bool key: LaunchSettingKey) -> Bool? {
        // swiftlint:disable:previous discouraged_optional_boolean
        guard let value = processInfo.environment[key.rawValue] else { return nil }
        return Bool(value)
    }

    /// Apply launch arguments
    static func startup() {
        if arguments(contain: .disableAnimations) {
            UIView.setAnimationsEnabled(false)
        }
        // if arguments(contain: .disableWaitIdle) { _dispatchOnceSwizzleWaitIdle }

        _ = ProcessInfo.setting(bool: .loggedIn)
        _ = ProcessInfo.setting(string: .token)
    }

    /// for swizzling out waitForQuiescenceIncludingAnimationsIdle
    //@objc fileprivate static func doNothing() { return }
}

/* does not appear to find XCUIApplicationProcess in Xcode 11
private let _dispatchOnceSwizzleWaitIdle: Void = {
    let waitMethod = Selector(("waitForQuiescenceIncludingAnimationsIdle:"))
    guard let uiTestRunner = objc_getClass("XCUIApplicationProcess") as? AnyClass,
          let original = class_getInstanceMethod(uiTestRunner,
                                                 waitMethod),
          let replaced = class_getInstanceMethod(ProcessInfo.self,
                                                 #selector(ProcessInfo.doNothing))  else {
        return
    }
    method_exchangeImplementations(original, replaced)
}()
*/
