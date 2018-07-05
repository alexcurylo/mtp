// @copyright Trollwerks Inc.

import UIKit

extension UIApplication {

    static var isUnitTesting: Bool {
        let isUnitTesting = NSClassFromString("XCTestCase") != nil
        return isUnitTesting
    }

    static var isUITesting: Bool {
        let isUITesting = ProcessInfo.processInfo.arguments.contains(LaunchArguments.uiTestingMode.rawValue)
        return isUITesting
    }

    static var isTesting: Bool {
        return isUITesting || isUnitTesting
    }
}

enum LaunchArguments: String {
    case uiTestingMode
}
