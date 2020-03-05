// @copyright Trollwerks Inc.

import XCTest

extension XCTestCase {

    var app: XCUIApplication { XCUIApplication() }

    func printHierarchy() {
        app.printHierarchy()
    }

    // disable wait for idle
    // https://stackoverflow.com/questions/41277026/disabling-waiting-for-idle-state-in-ui-testing-of-ios-apps

    func launch(arguments: [LaunchArgument] = [],
                settings: [LaunchSetting] = []) {
        continueAfterFailure = false
        let allArguments = arguments + [.uiTesting]
        let app = self.app
        app.launchArguments += allArguments.map { $0.rawValue }
        settings.map { $0.setting }.forEach { setting in
            app.launchEnvironment.merge(setting) { _, last in last }
        }

        app.apply(arguments: allArguments)
        app.launch()
    }

    func wait(for seconds: TimeInterval) {
        let wait = XCTestExpectation(description: "wait")
        _ = XCTWaiter.wait(for: [wait], timeout: seconds)
    }

    func delete(_ count: Int) -> String {
        String(repeating: XCUIKeyboardKey.delete.rawValue,
               count: count)
    }
}

extension XCUIApplication {

    func apply(arguments: [LaunchArgument]) {
        arguments.forEach { $0.apply(to: self) }
    }

    func printHierarchy() {
        print("hierarchy: \(description)\n\(debugDescription)")
    }
}

extension LaunchArgument {

    func apply(to app: XCUIApplication) {
        switch self {
        case .takingScreenshots:
            Snapshot.setupSnapshot(app)
        case .disableAnimations,
             .disableWaitIdle,
             .uiTesting:
            break
        }
    }
}
