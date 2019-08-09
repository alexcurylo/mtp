// @copyright Trollwerks Inc.

import UIKit

extension UIApplication {

    /// Executing in background?
    var isBackground: Bool {
        return applicationState != .active
    }
    /// Executing in foreground?
    var isForeground: Bool {
        return applicationState == .active
    }

    /// Executing in production environment?
    static var isProduction: Bool {
        return !isTesting
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
        return ProcessInfo.arguments(contain: .takingScreenshots)
    }

    /// Executing in test enviroment?
    static var isTesting: Bool {
        return isUITesting || isUnitTesting
    }

    /// Executing in UI test enviroment?
    static var isUITesting: Bool {
        return ProcessInfo.arguments(contain: .uiTesting)
    }

    /// Executing in unit test enviroment?
    static var isUnitTesting: Bool {
        return NSClassFromString("XCTestCase") != nil
    }
}
