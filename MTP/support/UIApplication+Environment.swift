// @copyright Trollwerks Inc.

import UIKit

extension UIApplication {

    /// Executing in background?
    var isBackground: Bool {
        applicationState != .active
    }
    /// Executing in foreground?
    var isForeground: Bool {
        applicationState == .active
    }

    /// Executing in production environment?
    static var isProduction: Bool {
        !isTesting
    }

    /// Executing in simulator?
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    /// Executing under fastlane screenshotting?
    static var isTakingScreenshots: Bool {
        ProcessInfo.arguments(contain: .takingScreenshots)
    }

    /// Executing in test enviroment?
    static var isTesting: Bool {
        isUITesting || isUnitTesting
    }

    /// Executing in UI test enviroment?
    static var isUITesting: Bool {
        ProcessInfo.arguments(contain: .uiTesting)
    }

    /// Executing in unit test enviroment?
    static var isUnitTesting: Bool {
        NSClassFromString("XCTestCase") != nil
    }
}

// MARK: - Development

extension UIApplication {

    #if DEBUG
    /// Development aid for clearing device cache
    static func clearLaunchScreenCache() {
        let cache = NSHomeDirectory()+"/Library/SplashBoard"
        // swiftlint:disable:next force_try
        try! FileManager.default.removeItem(atPath: cache)
    }
    #endif
}
