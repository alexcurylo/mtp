// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import CloudKit
@testable import MTP
import XCTest

final class RoutingAppDelegateTests: XCTestCase {

    private let liveApp = UIApplication.shared

    func testRuntimeApplicationDelegation() {
        XCTAssertTrue(liveApp.delegate is RoutingAppDelegate)
        XCTAssertEqual(liveApp.delegate as? RoutingAppDelegate, RoutingAppDelegate.shared)
        XCTAssertNotNil(RoutingAppDelegate.shared.window)
        XCTAssertNotNil(RoutingAppDelegate.shared.handlers)
    }

    func testAppLaunchHandlerManagement() throws {
        let mock = MockActualDelegate()

        let willFinish = mock.application(liveApp,
                                          willFinishLaunchingWithOptions: nil)
        XCTAssertTrue(willFinish)
        let didFinish = mock.application(liveApp,
                                         didFinishLaunchingWithOptions: nil)
        XCTAssertTrue(didFinish)

        XCTAssertEqual(mock.totalCalls, 2)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppLaunchHandler.self))
        XCTAssertEqual(handler.callCountWillFinish, 1)
        XCTAssertEqual(handler.callCountDidFinish, 1)
    }

    func testAppStateHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.applicationWillEnterForeground(liveApp)
        mock.applicationDidBecomeActive(liveApp)
        mock.applicationWillResignActive(liveApp)
        mock.applicationDidEnterBackground(liveApp)
        mock.applicationWillTerminate(liveApp)

        XCTAssertEqual(mock.totalCalls, 5)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppStateHandler.self))
        XCTAssertEqual(handler.callCountWillEnterForeground, 1)
        XCTAssertEqual(handler.callCountDidBecomeActive, 1)
        XCTAssertEqual(handler.callCountWillResignActive, 1)
        XCTAssertEqual(handler.callCountDidEnterBackground, 1)
        XCTAssertEqual(handler.callCountWillTerminate, 1)
    }

    func testAppOpenURLHandlerManagement() throws {
        let mock = MockActualDelegate()

        let didOpen = mock.application(liveApp,
                                       open: try unwrap(URL(string: "test.com")),
                                       options: [:])

        XCTAssertTrue(didOpen)
        XCTAssertEqual(mock.totalCalls, 1)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppOpenURLHandler.self))
        XCTAssertEqual(handler.callCountOpen, 1)
    }

    func testAppMemoryHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.applicationDidReceiveMemoryWarning(liveApp)

        XCTAssertEqual(mock.totalCalls, 1)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppMemoryHandler.self))
        XCTAssertEqual(handler.callCountDidReceiveMemoryWarning, 1)
    }

    func testAppTimeChangeHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.applicationSignificantTimeChange(liveApp)

        XCTAssertEqual(mock.totalCalls, 1)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppTimeChangeHandler.self))
        XCTAssertEqual(handler.callCountSignificantTimeChange, 1)
    }

    func testAppStatusBarHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.application(liveApp,
                         willChangeStatusBarOrientation: .portrait,
                         duration: 1)
        mock.application(liveApp,
                         didChangeStatusBarOrientation: .portrait)
        mock.application(liveApp,
                         willChangeStatusBarFrame: .zero)
        mock.application(liveApp,
                         didChangeStatusBarFrame: .zero)

        XCTAssertEqual(mock.totalCalls, 4)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppStatusBarHandler.self))
        XCTAssertEqual(handler.callCountWillChangeStatusBarOrientation, 1)
        XCTAssertEqual(handler.callCountDidChangeStatusBarOrientation, 1)
        XCTAssertEqual(handler.callCountWillChangeStatusBarFrame, 1)
        XCTAssertEqual(handler.callCountDidChangeStatusBarFrame, 1)
    }

    func testAppNotificationsHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.application(liveApp,
                         didRegisterForRemoteNotificationsWithDeviceToken: Data())
        mock.application(liveApp,
                         didFailToRegisterForRemoteNotificationsWithError: NSError(domain: "testing", code: -1))
        mock.application(liveApp,
                         didReceiveRemoteNotification: [:]) { _ in }

        XCTAssertEqual(mock.totalCalls, 3)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppNotificationsHandler.self))
        XCTAssertEqual(handler.callCountDidRegisterForRemoteNotificationsWithDeviceToken, 1)
        XCTAssertEqual(handler.callCountDidFailToRegisterForRemoteNotificationsWithError, 1)
        XCTAssertEqual(handler.callCountDidReceiveRemoteNotificationWithFetch, 1)
    }

    func testAppBackgroundFetchHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.application(liveApp) { _ in }

        XCTAssertEqual(mock.totalCalls, 1)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppBackgroundFetchHandler.self))
        XCTAssertEqual(handler.callCountPerformFetchWithCompletionHandler, 1)
    }

    func testAppBackgroundURLSessionHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.application(liveApp,
                         handleEventsForBackgroundURLSession: "identifier") {}

        XCTAssertEqual(mock.totalCalls, 1)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppBackgroundURLSessionHandler.self))
        XCTAssertEqual(handler.callCountHandleEventsForBackgroundURLSession, 1)
    }

    func testAppShortcutHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.application(liveApp,
                         performActionFor: UIApplicationShortcutItem(type: "test", localizedTitle: "test")) { _ in }

        XCTAssertEqual(mock.totalCalls, 1)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppShortcutHandler.self))
        XCTAssertEqual(handler.callCountPerformAction, 1)
    }

    func testAppWatchHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.application(liveApp,
                         handleWatchKitExtensionRequest: [:]) { _ in }

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppWatchHandler.self))
        XCTAssertEqual(handler.callCountHandleRequest, 1)
    }

    func testAppHealthHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.applicationShouldRequestHealthAuthorization(liveApp)

        XCTAssertEqual(mock.totalCalls, 1)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppHealthHandler.self))
        XCTAssertEqual(handler.callCountShouldRequest, 1)
    }

    func testAppContentHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.applicationProtectedDataWillBecomeUnavailable(liveApp)
        mock.applicationProtectedDataDidBecomeAvailable(liveApp)

        XCTAssertEqual(mock.totalCalls, 2)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppContentHandler.self))
        XCTAssertEqual(handler.callCountWillBecomeUnavailable, 1)
        XCTAssertEqual(handler.callCountDidBecomeAvailable, 1)
    }

    func testAppExtensionHandlerManagement() throws {
        let mock = MockActualDelegate()

        let shouldAllow = mock.application(liveApp,
                                           shouldAllowExtensionPointIdentifier: .keyboard)
        XCTAssertTrue(shouldAllow)

        XCTAssertEqual(mock.totalCalls, 1)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppExtensionHandler.self))
        XCTAssertEqual(handler.callCountShouldAllow, 1)
    }

    func testAppRestorationHandlerManagement() throws {
        let mock = MockActualDelegate()

        let controller = mock.application(liveApp,
                                          viewControllerWithRestorationIdentifierPath: [],
                                          coder: NSCoder())
        XCTAssertNotNil(controller)
        let shouldSave = mock.application(liveApp,
                                          shouldSaveApplicationState: NSCoder())
        XCTAssertTrue(shouldSave)
        let shouldRestore = mock.application(liveApp,
                                             shouldRestoreApplicationState: NSCoder())
        XCTAssertTrue(shouldRestore)
        mock.application(liveApp,
                         willEncodeRestorableStateWith: NSCoder())
        mock.application(liveApp,
                         didDecodeRestorableStateWith: NSCoder())

        XCTAssertEqual(mock.totalCalls, 5)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppRestorationHandler.self))
        XCTAssertEqual(handler.callCountViewController, 1)
        XCTAssertEqual(handler.callCountShouldSave, 1)
        XCTAssertEqual(handler.callCountShouldRestore, 1)
        XCTAssertEqual(handler.callCountWillEncode, 1)
        XCTAssertEqual(handler.callCountDidDecode, 1)
    }

    func testAppContinuityHandlerManagement() throws {
        let mock = MockActualDelegate()

        let willContinue = mock.application(liveApp,
                                            willContinueUserActivityWithType: "type")
        XCTAssertTrue(willContinue)
        let continued = mock.application(liveApp,
                                         continue: NSUserActivity(activityType: "type")) { _ in
        }
        XCTAssertTrue(continued)
        mock.application(liveApp,
                         didFailToContinueUserActivityWithType: "type",
                         error: NSError(domain: "testing", code: -1))
        mock.application(liveApp,
                         didUpdate: NSUserActivity(activityType: "type"))

        XCTAssertEqual(mock.totalCalls, 4)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppContinuityHandler.self))
        XCTAssertEqual(handler.callCountWillContinue, 1)
        XCTAssertEqual(handler.callCountContinue, 1)
        XCTAssertEqual(handler.callCountDidFailToContinue, 1)
        XCTAssertEqual(handler.callCountDidUpdate, 1)
    }

    func testAppCloudKitHandlerManagement() throws {
        let mock = MockActualDelegate()

        mock.application(liveApp,
                         userDidAcceptCloudKitShareWith: CKShare.Metadata())

        XCTAssertEqual(mock.totalCalls, 1)

        let handler = try unwrap(mock.handlers.firstOf(type: MockAppCloudKitHandler.self))
        XCTAssertEqual(handler.callCountDidAccept, 1)
    }
}

// MARK: - Mock of RoutingAppDelegate-required subclass

private class MockActualDelegate: RoutingAppDelegate {

    private let allHandlerTypes: [MockAppHandler] = [
        MockAppLaunchHandler(),
        MockAppStateHandler(),
        MockAppOpenURLHandler(),
        MockAppMemoryHandler(),
        MockAppTimeChangeHandler(),
        MockAppStatusBarHandler(),
        MockAppNotificationsHandler(),
        MockAppBackgroundFetchHandler(),
        MockAppBackgroundURLSessionHandler(),
        MockAppShortcutHandler(),
        MockAppWatchHandler(),
        MockAppHealthHandler(),
        MockAppContentHandler(),
        MockAppExtensionHandler(),
        MockAppRestorationHandler(),
        MockAppContinuityHandler(),
        MockAppCloudKitHandler()
    ]

    override var handlers: RoutingAppDelegate.Handlers {
        return allHandlerTypes
    }

    var totalCalls: Int {
        return allHandlerTypes.map { $0.callCount }.reduce(0, +)
    }
}

// MARK: - Mocks of AppHandler-derived protocols

private class MockAppHandler: AppHandler {

    var dependencies: [AppHandler.Type] { return [] }

    var callCount: Int = 0
}

private class MockAppLaunchHandler: MockAppHandler, AppLaunchHandler {

    var callCountWillFinish: Int = 0
    var callCountDidFinish: Int = 0

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        callCount += 1
        callCountWillFinish += 1
        return true
    }
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        callCount += 1
        callCountDidFinish += 1
        return true
    }
}

private class MockAppStateHandler: MockAppHandler, AppStateHandler {

    var callCountWillEnterForeground: Int = 0
    var callCountDidBecomeActive: Int = 0
    var callCountWillResignActive: Int = 0
    var callCountDidEnterBackground: Int = 0
    var callCountWillTerminate: Int = 0

    func applicationWillEnterForeground(_ application: UIApplication) {
        callCount += 1
        callCountWillEnterForeground += 1
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        callCount += 1
        callCountDidBecomeActive += 1
    }
    func applicationWillResignActive(_ application: UIApplication) {
        callCount += 1
        callCountWillResignActive += 1
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        callCount += 1
        callCountDidEnterBackground += 1
    }
    func applicationWillTerminate(_ application: UIApplication) {
        callCount += 1
        callCountWillTerminate += 1
    }
}

private class MockAppOpenURLHandler: MockAppHandler, AppOpenURLHandler {

    var callCountOpen: Int = 0

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        callCount += 1
        callCountOpen += 1
        return true
    }
}

private class MockAppMemoryHandler: MockAppHandler, AppMemoryHandler {

    var callCountDidReceiveMemoryWarning: Int = 0

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        callCount += 1
        callCountDidReceiveMemoryWarning += 1
    }
}

private class MockAppTimeChangeHandler: MockAppHandler, AppTimeChangeHandler {

    var callCountSignificantTimeChange: Int = 0

    func applicationSignificantTimeChange(_ application: UIApplication) {
        callCount += 1
        callCountSignificantTimeChange += 1
    }
}

private class MockAppStatusBarHandler: MockAppHandler, AppStatusBarHandler {

    var callCountWillChangeStatusBarOrientation: Int = 0
    var callCountDidChangeStatusBarOrientation: Int = 0
    var callCountWillChangeStatusBarFrame: Int = 0
    var callCountDidChangeStatusBarFrame: Int = 0

    func application(_ application: UIApplication,
                     willChangeStatusBarOrientation newStatusBarOrientation: UIInterfaceOrientation,
                     duration: TimeInterval) {
        callCount += 1
        callCountWillChangeStatusBarOrientation += 1
    }
    func application(_ application: UIApplication,
                     didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation) {
        callCount += 1
        callCountDidChangeStatusBarOrientation += 1
    }
    func application(_ application: UIApplication,
                     willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        callCount += 1
        callCountWillChangeStatusBarFrame += 1
    }
    func application(_ application: UIApplication,
                     didChangeStatusBarFrame oldStatusBarFrame: CGRect) {
        callCount += 1
        callCountDidChangeStatusBarFrame += 1
    }
}

private class MockAppNotificationsHandler: MockAppHandler, AppNotificationsHandler {

    var callCountDidRegisterForRemoteNotificationsWithDeviceToken: Int = 0
    var callCountDidFailToRegisterForRemoteNotificationsWithError: Int = 0
    var callCountDidReceiveRemoteNotification: Int = 0
    var callCountDidReceiveRemoteNotificationWithFetch: Int = 0
    var callCountDidReceiveRemoteNotificationWithCompletion: Int = 0

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        callCount += 1
        callCountDidRegisterForRemoteNotificationsWithDeviceToken += 1
    }
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        callCount += 1
        callCountDidFailToRegisterForRemoteNotificationsWithError += 1
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        callCount += 1
        callCountDidReceiveRemoteNotificationWithFetch += 1
    }
}

private class MockAppBackgroundFetchHandler: MockAppHandler, AppBackgroundFetchHandler {

    var callCountPerformFetchWithCompletionHandler: Int = 0

    func application(_ application: UIApplication,
                     // swiftlint:disable:next line_length
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        callCount += 1
        callCountPerformFetchWithCompletionHandler += 1
    }
}

private class MockAppBackgroundURLSessionHandler: MockAppHandler, AppBackgroundURLSessionHandler {

    var callCountHandleEventsForBackgroundURLSession: Int = 0

    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Swift.Void) {
        callCount += 1
        callCountHandleEventsForBackgroundURLSession += 1
    }
}

private class MockAppShortcutHandler: MockAppHandler, AppShortcutHandler {

    var callCountPerformAction: Int = 0

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Swift.Void) {
        callCount += 1
        callCountPerformAction += 1
    }
}

private class MockAppWatchHandler: MockAppHandler, AppWatchHandler {

    var callCountHandleRequest: Int = 0

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     handleWatchKitExtensionRequest userInfo: [AnyHashable: Any]?,
                     // swiftlint:disable:next discouraged_optional_collection
                     reply: @escaping ([AnyHashable: Any]?) -> Swift.Void) {
        callCount += 1
        callCountHandleRequest += 1
    }
}

private class MockAppHealthHandler: MockAppHandler, AppHealthHandler {

    var callCountShouldRequest: Int = 0

    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        callCount += 1
        callCountShouldRequest += 1
    }
}

private class MockAppContentHandler: MockAppHandler, AppContentHandler {

    var callCountWillBecomeUnavailable: Int = 0
    var callCountDidBecomeAvailable: Int = 0

    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        callCount += 1
        callCountWillBecomeUnavailable += 1
    }
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        callCount += 1
        callCountDidBecomeAvailable += 1
    }
}

private class MockAppExtensionHandler: MockAppHandler, AppExtensionHandler {

    var callCountShouldAllow: Int = 0

    func application(_ application: UIApplication,
                     // swiftlint:disable:next line_length
                     shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        callCount += 1
        callCountShouldAllow += 1
        return true
    }
}

private class MockAppRestorationHandler: MockAppHandler, AppRestorationHandler {

    var callCountViewController: Int = 0
    var callCountShouldSave: Int = 0
    var callCountShouldRestore: Int = 0
    var callCountWillEncode: Int = 0
    var callCountDidDecode: Int = 0

    func application(_ application: UIApplication,
                     viewControllerWithRestorationIdentifierPath identifierComponents: [Any],
                     coder: NSCoder) -> UIViewController? {
        callCount += 1
        callCountViewController += 1
        return UIViewController()
    }
    func application(_ application: UIApplication,
                     shouldSaveApplicationState coder: NSCoder) -> Bool {
        callCount += 1
        callCountShouldSave += 1
        return true
    }
    func application(_ application: UIApplication,
                     shouldRestoreApplicationState coder: NSCoder) -> Bool {
        callCount += 1
        callCountShouldRestore += 1
        return true
    }
    func application(_ application: UIApplication,
                     willEncodeRestorableStateWith coder: NSCoder) {
        callCount += 1
        callCountWillEncode += 1
    }
    func application(_ application: UIApplication,
                     didDecodeRestorableStateWith coder: NSCoder) {
        callCount += 1
        callCountDidDecode += 1
    }
}

private class MockAppContinuityHandler: MockAppHandler, AppContinuityHandler {

    var callCountWillContinue: Int = 0
    var callCountContinue: Int = 0
    var callCountDidFailToContinue: Int = 0
    var callCountDidUpdate: Int = 0

    func application(_ application: UIApplication,
                     willContinueUserActivityWithType userActivityType: String) -> Bool {
        callCount += 1
        callCountWillContinue += 1
        return true
    }
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     // swiftlint:disable:next discouraged_optional_collection
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Swift.Void) -> Bool {
        callCount += 1
        callCountContinue += 1
        return true
    }
    func application(_ application: UIApplication,
                     didFailToContinueUserActivityWithType userActivityType: String,
                     error: Error) {
        callCount += 1
        callCountDidFailToContinue += 1
    }
    func application(_ application: UIApplication,
                     didUpdate userActivity: NSUserActivity) {
        callCount += 1
        callCountDidUpdate += 1
    }
}

private class MockAppCloudKitHandler: MockAppHandler, AppCloudKitHandler {

    var callCountDidAccept: Int = 0

    func application(_ application: UIApplication,
                     userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        callCount += 1
        callCountDidAccept += 1
    }
}
