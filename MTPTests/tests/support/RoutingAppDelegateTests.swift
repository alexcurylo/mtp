// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import CloudKit
import Intents
@testable import MTP
import XCTest

final class RoutingAppDelegateTests: TestCase {

    private let liveApp = UIApplication.shared

    func testRuntimeApplicationDelegation() {
        XCTAssertTrue(liveApp.delegate is RoutingAppDelegate)
        XCTAssertEqual(liveApp.delegate as? RoutingAppDelegate, RoutingAppDelegate.shared)
        XCTAssertNotNil(RoutingAppDelegate.shared.window)
        XCTAssertNotNil(RoutingAppDelegate.shared.handlers)
    }

    func testAppLaunchHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        let willFinish = mock.application(liveApp,
                                          willFinishLaunchingWithOptions: nil)
        XCTAssertTrue(willFinish)
        let didFinish = mock.application(liveApp,
                                         didFinishLaunchingWithOptions: nil)
        XCTAssertTrue(didFinish)

        // then
        XCTAssertEqual(mock.totalCalls, 2)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppLaunchHandler.self))
        XCTAssertEqual(handler.callCountWillFinish, 1)
        XCTAssertEqual(handler.callCountDidFinish, 1)
    }

    func testAppStateHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        mock.applicationWillEnterForeground(liveApp)
        mock.applicationDidBecomeActive(liveApp)
        mock.applicationWillResignActive(liveApp)
        mock.applicationDidEnterBackground(liveApp)
        mock.applicationWillTerminate(liveApp)

        // then
        XCTAssertEqual(mock.totalCalls, 5)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppStateHandler.self))
        XCTAssertEqual(handler.callCountWillEnterForeground, 1)
        XCTAssertEqual(handler.callCountDidBecomeActive, 1)
        XCTAssertEqual(handler.callCountWillResignActive, 1)
        XCTAssertEqual(handler.callCountDidEnterBackground, 1)
        XCTAssertEqual(handler.callCountWillTerminate, 1)
    }

    func testAppOpenURLHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        let didOpen = mock.application(liveApp,
                                       open: try XCTUnwrap(URL(string: "test.com")),
                                       options: [:])

        // then
        XCTAssertTrue(didOpen)
        XCTAssertEqual(mock.totalCalls, 1)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppOpenURLHandler.self))
        XCTAssertEqual(handler.callCountOpen, 1)
    }

    func testAppMemoryHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        mock.applicationDidReceiveMemoryWarning(liveApp)

        // then
        XCTAssertEqual(mock.totalCalls, 1)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppMemoryHandler.self))
        XCTAssertEqual(handler.callCountDidReceiveMemoryWarning, 1)
    }

    func testAppTimeChangeHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        mock.applicationSignificantTimeChange(liveApp)

        // then
        XCTAssertEqual(mock.totalCalls, 1)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppTimeChangeHandler.self))
        XCTAssertEqual(handler.callCountSignificantTimeChange, 1)
    }

    func testAppNotificationsHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        mock.application(liveApp,
                         didRegisterForRemoteNotificationsWithDeviceToken: Data())
        mock.application(liveApp,
                         didFailToRegisterForRemoteNotificationsWithError: NSError(domain: "testing", code: -1))
        mock.application(liveApp,
                         didReceiveRemoteNotification: [:]) { _ in }

        // then
        XCTAssertEqual(mock.totalCalls, 3)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppNotificationsHandler.self))
        XCTAssertEqual(handler.callCountDidRegisterForRemoteNotificationsWithDeviceToken, 1)
        XCTAssertEqual(handler.callCountDidFailToRegisterForRemoteNotificationsWithError, 1)
        XCTAssertEqual(handler.callCountDidReceiveRemoteNotificationWithFetch, 1)
    }

    func testAppBackgroundURLSessionHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        mock.application(liveApp,
                         handleEventsForBackgroundURLSession: "identifier") {}

        // then
        XCTAssertEqual(mock.totalCalls, 1)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppBackgroundURLSessionHandler.self))
        XCTAssertEqual(handler.callCountHandleEventsForBackgroundURLSession, 1)
    }

    func testAppShortcutHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        mock.application(liveApp,
                         performActionFor: UIApplicationShortcutItem(type: "test", localizedTitle: "test")) { _ in }

        // then
        XCTAssertEqual(mock.totalCalls, 1)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppShortcutHandler.self))
        XCTAssertEqual(handler.callCountPerformAction, 1)
    }

    func testAppWatchHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        mock.application(liveApp,
                         handleWatchKitExtensionRequest: [:]) { _ in }

        // then
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppWatchHandler.self))
        XCTAssertEqual(handler.callCountHandleRequest, 1)
    }

    func testAppHealthHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        mock.applicationShouldRequestHealthAuthorization(liveApp)

        // then
        XCTAssertEqual(mock.totalCalls, 1)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppHealthHandler.self))
        XCTAssertEqual(handler.callCountShouldRequest, 1)
    }

    func testAppSiriHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()
        let intent = INPauseWorkoutIntent(workoutName: nil)

        // when
        mock.application(liveApp, handle: intent) { _ in }

        // then
        XCTAssertEqual(mock.totalCalls, 1)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppSiriHandler.self))
        XCTAssertEqual(handler.callCountShouldHandle, 1)
    }

    func testAppContentHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        mock.applicationProtectedDataWillBecomeUnavailable(liveApp)
        mock.applicationProtectedDataDidBecomeAvailable(liveApp)

        // then
        XCTAssertEqual(mock.totalCalls, 2)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppContentHandler.self))
        XCTAssertEqual(handler.callCountWillBecomeUnavailable, 1)
        XCTAssertEqual(handler.callCountDidBecomeAvailable, 1)
    }

    func testAppExtensionHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        let shouldAllow = mock.application(liveApp,
                                           shouldAllowExtensionPointIdentifier: .keyboard)
        XCTAssertTrue(shouldAllow)

        // then
        XCTAssertEqual(mock.totalCalls, 1)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppExtensionHandler.self))
        XCTAssertEqual(handler.callCountShouldAllow, 1)
    }

    func testAppRestorationHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        let controller = mock.application(liveApp,
                                          viewControllerWithRestorationIdentifierPath: [],
                                          coder: NSCoder())
        XCTAssertNotNil(controller)
        let shouldSave = mock.application(liveApp,
                                          shouldSaveApplicationState: NSCoder())
        XCTAssertTrue(shouldSave)
        let shouldSecureSave = mock.application(liveApp,
                                                shouldSaveSecureApplicationState: NSCoder())
        XCTAssertTrue(shouldSecureSave)
        let shouldRestore = mock.application(liveApp,
                                             shouldRestoreApplicationState: NSCoder())
        XCTAssertTrue(shouldRestore)
        let shouldSecureRestore = mock.application(liveApp,
                                                   shouldRestoreSecureApplicationState: NSCoder())
        XCTAssertTrue(shouldSecureRestore)
        mock.application(liveApp,
                         willEncodeRestorableStateWith: NSCoder())
        mock.application(liveApp,
                         didDecodeRestorableStateWith: NSCoder())

        // then
        XCTAssertEqual(mock.totalCalls, 7)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppRestorationHandler.self))
        XCTAssertEqual(handler.callCountViewController, 1)
        XCTAssertEqual(handler.callCountShouldSave, 1)
        XCTAssertEqual(handler.callCountShouldRestore, 1)
        XCTAssertEqual(handler.callCountWillEncode, 1)
        XCTAssertEqual(handler.callCountDidDecode, 1)
    }

    func testAppContinuityHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
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

        // then
        XCTAssertEqual(mock.totalCalls, 4)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppContinuityHandler.self))
        XCTAssertEqual(handler.callCountWillContinue, 1)
        XCTAssertEqual(handler.callCountContinue, 1)
        XCTAssertEqual(handler.callCountDidFailToContinue, 1)
        XCTAssertEqual(handler.callCountDidUpdate, 1)
    }

    func testAppCloudKitHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()

        // when
        mock.application(liveApp,
                         userDidAcceptCloudKitShareWith: CKShare.Metadata())

        // then
        XCTAssertEqual(mock.totalCalls, 1)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppCloudKitHandler.self))
        XCTAssertEqual(handler.callCountDidAccept, 1)
    }

    #if ADOPT_UISCENESESSION
    func testSceneSessionHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate()
        // swiftlint:disable:next force_unwrapping
        let session = SceneDelegate.hostSession!
        // swiftlint:disable:next force_unwrapping
        let options = SceneDelegate.hostOptions!

        // when
        _ = mock.application(liveApp,
                             configurationForConnecting: session,
                             options: options)
        mock.application(liveApp,
                         didDiscardSceneSessions: [])

        // then
        XCTAssertEqual(mock.totalCalls, 2)
        let handler = try XCTUnwrap(mock.handlers.firstOf(type: MockAppSceneSessionHandler.self))
        XCTAssertEqual(handler.callCountConfig, 1)
        XCTAssertEqual(handler.callCountDiscard, 1)
    }

    func testEmptySceneSessionHandlerManagement() throws {
        // given
        let mock = MockRoutingAppDelegate(empty: true)
        // swiftlint:disable:next force_unwrapping
        let session = SceneDelegate.hostSession!
        // swiftlint:disable:next force_unwrapping
        let options = SceneDelegate.hostOptions!

        // when
        _ = mock.application(liveApp,
                             configurationForConnecting: session,
                             options: options)
    }
    #endif
}

// MARK: - Mock of RoutingAppDelegate-required subclass

private class MockRoutingAppDelegate: RoutingAppDelegate {

    private let empty: Bool

    private let allHandlerTypes: [MockAppHandler] = [
        MockAppLaunchHandler(),
        MockAppStateHandler(),
        MockAppOpenURLHandler(),
        MockAppMemoryHandler(),
        MockAppTimeChangeHandler(),
        MockAppNotificationsHandler(),
        MockAppBackgroundURLSessionHandler(),
        MockAppShortcutHandler(),
        MockAppWatchHandler(),
        MockAppHealthHandler(),
        MockAppSiriHandler(),
        MockAppContentHandler(),
        MockAppExtensionHandler(),
        MockAppRestorationHandler(),
        MockAppContinuityHandler(),
        MockAppCloudKitHandler(),
        // MockAppSceneSessionHandler()
    ]

    override var handlers: RoutingAppDelegate.Handlers {
        empty ? [] : allHandlerTypes
    }

    var totalCalls: Int {
        empty ? 0 : allHandlerTypes.map { $0.callCount }.reduce(0, +)
    }

    override init() {
        self.empty = false
        super.init()
    }

    init(empty: Bool) {
        self.empty = empty
        super.init()
    }
}

// MARK: - Mocks of AppHandler-derived protocols

private class MockAppHandler: AppHandler {

    var dependencies: [AppHandler.Type] { [] }

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

private class MockAppSiriHandler: MockAppHandler, AppSiriHandler {

    var callCountShouldHandle: Int = 0

    func application(_ application: UIApplication,
                     handle intent: INIntent,
                     completionHandler: @escaping (INIntentResponse) -> Void) {
        callCount += 1
        callCountShouldHandle += 1
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

    func application(
        _ application: UIApplication,
        shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier
    ) -> Bool {
        callCount += 1
        callCountShouldAllow += 1
        return true
    }
}

private class MockAppRestorationHandler: MockAppHandler, AppRestorationHandler {

    var callCountViewController: Int = 0
    var callCountShouldSave: Int = 0
    var callCountShouldSecureSave: Int = 0
    var callCountShouldRestore: Int = 0
    var callCountShouldSecureRestore: Int = 0
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
                     shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        callCount += 1
        callCountShouldSecureSave += 1
        return true
    }
    func application(_ application: UIApplication,
                     shouldRestoreApplicationState coder: NSCoder) -> Bool {
        callCount += 1
        callCountShouldRestore += 1
        return true
    }
    func application(_ application: UIApplication,
                     shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        callCount += 1
        callCountShouldSecureRestore += 1
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

#if ADOPT_UISCENESESSION
private class MockAppSceneSessionHandler: MockAppHandler, AppSceneSessionHandler {

    var callCountConfig: Int = 0
    var callCountDiscard: Int = 0

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        callCount += 1
        callCountConfig += 1
        return UISceneConfiguration()
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        callCount += 1
        callCountDiscard += 1
    }
}
#endif
