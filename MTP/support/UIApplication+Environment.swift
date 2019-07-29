// @copyright Trollwerks Inc.

import UIKit

extension UIApplication {

    var isBackground: Bool {
        return applicationState != .active
    }
    var isForeground: Bool {
        return applicationState == .active
    }

    static var isProduction: Bool {
        return !isTesting
    }

    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    static var isTakingScreenshots: Bool {
        return ProcessInfo.arguments(contain: .takingScreenshots)
    }

    static var isTesting: Bool {
        return isUITesting || isUnitTesting
    }

    static var isUITesting: Bool {
        return ProcessInfo.arguments(contain: .uiTesting)
    }

    static var isUnitTesting: Bool {
        return NSClassFromString("XCTestCase") != nil
    }
}
