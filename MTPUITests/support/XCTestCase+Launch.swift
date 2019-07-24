// @copyright Trollwerks Inc.

import XCTest

extension XCTestCase {

    func launch(arguments: [LaunchArgument] = [],
                settings: [LaunchSetting] = []) {
        continueAfterFailure = false
        let app = XCUIApplication()
        let allArguments = arguments + [.uiTesting]
        app.launchArguments += allArguments.map { $0.rawValue }
        settings.map { $0.setting }.forEach { setting in
            app.launchEnvironment.merge(setting) { _, last in last }
        }

        app.apply(arguments: allArguments)
        app.launch()
    }
}

extension XCUIApplication {

    func apply(arguments: [LaunchArgument]) {
        arguments.forEach { $0.apply(to: self) }
    }
}

extension LaunchArgument {

    func apply(to app: XCUIApplication) {
        switch self {
        case .takingScreenshots:
            Snapshot.setupSnapshot(app)
        case .uiTesting:
            break
        }
    }
}
