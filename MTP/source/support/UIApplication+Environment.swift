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
}

enum LaunchArgument: String {
    case uiTestingMode
}

extension ProcessInfo {

    static func arguments(contain argument: LaunchArgument) -> Bool {
        return processInfo.arguments.contains(argument.rawValue)
    }
}
