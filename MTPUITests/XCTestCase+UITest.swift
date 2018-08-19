// @copyright Trollwerks Inc.

import XCTest

extension XCTestCase {

    func launch(arguments: [LaunchArgument] = [],
                settings: [LaunchSetting] = []) {
        let allArguments = arguments + [.uiTestingMode]

        let app = XCUIApplication()
        app.launchArguments += allArguments.map { $0.rawValue }
        settings.map { $0.setting }.forEach { setting in
            app.launchEnvironment.merge(setting) { _, last in last }
        }

        app.launch()
    }
}
