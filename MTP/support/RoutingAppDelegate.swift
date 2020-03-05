// @copyright Trollwerks Inc.

import CloudKit
import Intents
import UIKit

// swiftlint:disable file_length

/// Adopt to be constructed at app startup
protocol AppHandler { }

/// Adopt to have launch notifications routed
protocol AppLaunchHandler: AppHandler {

    /// willFinishLaunchingWithOptions
    /// - Parameters:
    ///   - application: Application
    ///   - launchOptions: Launch options
    /// - Returns: Success
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    /// didFinishLaunchingWithOptions
    /// - Parameters:
    ///   - application: Application
    ///   - launchOptions: Launch options
    /// - Returns: Success
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
}

/// Adopt to have state notifications routed
protocol AppStateHandler: AppHandler {

    /// Enter foreground handler
    /// - Parameter application: Application
    func applicationWillEnterForeground(_ application: UIApplication)
    /// Become active handler
    /// - Parameter application: Application
    func applicationDidBecomeActive(_ application: UIApplication)
    /// Resign active handler
    /// - Parameter application: Application
    func applicationWillResignActive(_ application: UIApplication)
    /// Enter background handler
    /// - Parameter application: Application
    func applicationDidEnterBackground(_ application: UIApplication)
    /// Terminate handler
    /// - Parameter application: Application
    func applicationWillTerminate(_ application: UIApplication)
}

/// Adopt to have open URL notifications routed
protocol AppOpenURLHandler: AppHandler {

    /// Open URL handler
    /// - Parameters:
    ///   - app: Application
    ///   - url: URL
    ///   - options: Options
    /// - Returns: Success
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
}

/// Adopt to have memory warning notifications routed
protocol AppMemoryHandler: AppHandler {

    /// Memory warning handler
    /// - Parameter application: Application
    func applicationDidReceiveMemoryWarning(_ application: UIApplication)
}

/// Adopt to have time change notifications routed
protocol AppTimeChangeHandler: AppHandler {

    /// App time change handler
    /// - Parameter application: Application
    func applicationSignificantTimeChange(_ application: UIApplication)
}

/// Adopt to have remote notifications routed
protocol AppNotificationsHandler: AppHandler {

    /// didRegisterForRemoteNotificationsWithDeviceToken
    /// - Parameters:
    ///   - application: Application
    ///   - deviceToken: Token
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    /// didFailToRegisterForRemoteNotificationsWithError
    /// - Parameters:
    ///   - application: Application
    ///   - error: Error
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error)
    /// didReceiveRemoteNotification
    /// - Parameters:
    ///   - application: Application
    ///   - userInfo: Info
    ///   - completionHandler: Callback
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

/// Adopt to have background URL session notifications routed
protocol AppBackgroundURLSessionHandler: AppHandler {

    /// handleEventsForBackgroundURLSession
    /// - Parameters:
    ///   - application: Application
    ///   - identifier: Identifier
    ///   - completionHandler: Callback
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void)
}

/// Adopt to have shortcut notifications routed
protocol AppShortcutHandler: AppHandler {

    /// performActionFor shortcutItem
    /// - Parameters:
    ///   - application: Application
    ///   - shortcutItem: Item
    ///   - completionHandler: Callback
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void)
}

/// Adopt to have watch notifications routed
protocol AppWatchHandler: AppHandler {

    /// handleWatchKitExtensionRequest
    /// - Parameters:
    ///   - application: Application
    ///   - userInfo: Info
    ///   - reply: Reply
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     handleWatchKitExtensionRequest userInfo: [AnyHashable: Any]?,
                     // swiftlint:disable:next discouraged_optional_collection
                     reply: @escaping ([AnyHashable: Any]?) -> Void)
}

/// Adopt to have health notifications routed
protocol AppHealthHandler: AppHandler {

    /// applicationShouldRequestHealthAuthorization
    /// - Parameter application: Application
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication)
}

/// Adopt to have Siri notifications routed
protocol AppSiriHandler: AppHandler {

    /// handle intent
    /// - Parameters:
    ///   - application: Application
    ///   - intent: Intent
    ///   - completionHandler: Callback
    func application(_ application: UIApplication,
                     handle intent: INIntent,
                     completionHandler: @escaping (INIntentResponse) -> Void)
}

/// Adopt to have data notifications routed
protocol AppContentHandler: AppHandler {

    /// applicationProtectedDataWillBecomeUnavailable
    /// - Parameter application: Application
    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication)
    /// applicationProtectedDataDidBecomeAvailable
    /// - Parameter application: Application
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication)
}

/// Adopt to have extension notifications routed
protocol AppExtensionHandler: AppHandler {

    /// shouldAllowExtensionPointIdentifier
    /// - Parameters:
    ///   - application: Application
    ///   - extensionPointIdentifier: Identifier
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     // swiftlint:disable:next line_length
                     shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool
}

/// Adopt to have restoration notifications routed
protocol AppRestorationHandler: AppHandler {

    /// viewControllerWithRestorationIdentifierPath
    /// - Parameters:
    ///   - application: Application
    ///   - identifierComponents: Components
    ///   - coder: Coder
    /// - Returns: UIViewController
    func application(_ application: UIApplication,
                     viewControllerWithRestorationIdentifierPath identifierComponents: [Any],
                     coder: NSCoder) -> UIViewController?
    /// shouldSaveApplicationState
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     shouldSaveApplicationState coder: NSCoder) -> Bool
    /// shouldSaveSecureApplicationState
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     shouldSaveSecureApplicationState coder: NSCoder) -> Bool
    /// shouldRestoreApplicationState
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     shouldRestoreApplicationState coder: NSCoder) -> Bool
    /// shouldRestoreSecureApplicationState
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     shouldRestoreSecureApplicationState coder: NSCoder) -> Bool
    /// willEncodeRestorableStateWith
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    func application(_ application: UIApplication,
                     willEncodeRestorableStateWith coder: NSCoder)
    /// didDecodeRestorableStateWith
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    func application(_ application: UIApplication,
                     didDecodeRestorableStateWith coder: NSCoder)
}

/// Adopt to have continuity notifications routed
protocol AppContinuityHandler: AppHandler {

    /// willContinueUserActivityWithType
    /// - Parameters:
    ///   - application: Application
    ///   - userActivityType: Activity
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     willContinueUserActivityWithType userActivityType: String) -> Bool
    /// continue userActivity
    /// - Parameters:
    ///   - application: Application
    ///   - userActivity: Activity
    ///   - restorationHandler: Handler
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     // swiftlint:disable:next discouraged_optional_collection
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    /// didFailToContinueUserActivityWithType
    /// - Parameters:
    ///   - application: Application
    ///   - userActivityType: Activity
    ///   - error: Error
    func application(_ application: UIApplication,
                     didFailToContinueUserActivityWithType userActivityType: String,
                     error: Error)
    /// didUpdate userActivity
    /// - Parameters:
    ///   - application: Application
    ///   - userActivity: Activity
    func application(_ application: UIApplication,
                     didUpdate userActivity: NSUserActivity)
}

/// Adopt to have CloudKit notifications routed
protocol AppCloudKitHandler: AppHandler {

    /// userDidAcceptCloudKitShareWith
    /// - Parameters:
    ///   - application: Application
    ///   - cloudKitShareMetadata: Metadata
    func application(_ application: UIApplication,
                     userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata)
}

#if ADOPT_UISCENESESSION
/// Adopt to have UISceneSession notifications routed
protocol AppSceneSessionHandler: AppHandler {

    /// configurationForConnecting
    /// - Parameters:
    ///   - application: Application
    ///   - connectingSceneSession: Session
    ///   - options: Options
    /// - Returns: Configuration
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration
    /// didDiscardSceneSessions
    /// - Parameters:
    ///   - application: Application
    ///   - sceneSessions: Sessions
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>)
}
#endif

/// Override `RoutingAppDelegate` to return app's list of `handlers`
class RoutingAppDelegate: UIResponder, UIApplicationDelegate {

    /// Collection of AppHandlers that override provides
    typealias Handlers = [AppHandler]

    /// Typed access to global delegate
    @objc static var shared: RoutingAppDelegate = {
        // swiftlint:disable:next force_cast
        UIApplication.shared.delegate as! RoutingAppDelegate
    }()

    /// Application's window
    var window: UIWindow?

    /// Override point to produce app handlers
    var handlers: Handlers { [] }

    /// Typed access to unique handler
    /// - Parameter type: Handler type
    /// - Returns: First instance of type if found
    static func handler<T>(type: T.Type) -> T? {
        RoutingAppDelegate.shared.handlers.firstOf(type: T.self)
    }
}

// MARK: - All members of UIApplicationDelegate as found in 12.0 SDK -

extension RoutingAppDelegate {

    /// willFinishLaunchingWithOptions
    /// - Parameters:
    ///   - application: Application
    ///   - launchOptions: Launch options
    /// - Returns: Success
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        handlers.of(type: AppLaunchHandler.self)
                .map { $0.application(application,
                                      willFinishLaunchingWithOptions: launchOptions)
                }
                .allSatisfy { $0 }
    }

    /// didFinishLaunchingWithOptions
    /// - Parameters:
    ///   - application: Application
    ///   - launchOptions: Launch options
    /// - Returns: Success
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        handlers.of(type: AppLaunchHandler.self)
                .map { $0.application(application,
                                      didFinishLaunchingWithOptions: launchOptions)
                }
                .allSatisfy { $0 }
    }

    /// Enter foreground handler
    /// - Parameter application: Application
    func applicationWillEnterForeground(_ application: UIApplication) {
        handlers.of(type: AppStateHandler.self)
                .forEach { $0.applicationWillEnterForeground(application) }
    }

    /// Become active handler
    /// - Parameter application: Application
    func applicationDidBecomeActive(_ application: UIApplication) {
        handlers.of(type: AppStateHandler.self)
                .forEach { $0.applicationDidBecomeActive(application) }
    }

    /// Resign active handler
    /// - Parameter application: Application
    func applicationWillResignActive(_ application: UIApplication) {
        handlers.of(type: AppStateHandler.self)
                .forEach { $0.applicationWillResignActive(application) }
    }

    /// Enter background handler
    /// - Parameter application: Application
    func applicationDidEnterBackground(_ application: UIApplication) {
        handlers.of(type: AppStateHandler.self)
                .forEach { $0.applicationDidEnterBackground(application) }
    }

    /// Terminate handler
    /// - Parameter application: Application
    func applicationWillTerminate(_ application: UIApplication) {
        handlers.of(type: AppStateHandler.self)
                .forEach { $0.applicationWillTerminate(application) }
    }

    /// Open URL handler
    /// - Parameters:
    ///   - app: Application
    ///   - url: URL
    ///   - options: Options
    /// - Returns: Success
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
     handlers.of(type: AppOpenURLHandler.self)
             .map { $0.application(app,
                                   open: url,
                                   options: options)
             }
             .contains { $0 }
    }

    /// Memory warning handler
    /// - Parameter application: Application
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        handlers.of(type: AppMemoryHandler.self)
                .forEach { $0.applicationDidReceiveMemoryWarning(application) }
    }

    /// App time change handler
    /// - Parameter application: Application
    func applicationSignificantTimeChange(_ application: UIApplication) {
        handlers.of(type: AppTimeChangeHandler.self)
                .forEach { $0.applicationSignificantTimeChange(application) }
    }

    /// didRegisterForRemoteNotificationsWithDeviceToken
    /// - Parameters:
    ///   - application: Application
    ///   - deviceToken: Token
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        handlers.of(type: AppNotificationsHandler.self)
                .forEach { $0.application(application,
                                          didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
                }
    }

    /// didFailToRegisterForRemoteNotificationsWithError
    /// - Parameters:
    ///   - application: Application
    ///   - error: Error
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        handlers.of(type: AppNotificationsHandler.self)
                .forEach { $0.application(application,
                                          didFailToRegisterForRemoteNotificationsWithError: error)
                }
    }

    /// didReceiveRemoteNotification
    /// - Parameters:
    ///   - application: Application
    ///   - userInfo: Info
    ///   - completionHandler: Callback
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handlers.of(type: AppNotificationsHandler.self)
                 .forEach { $0.application(application,
                                           didReceiveRemoteNotification: userInfo,
                                           fetchCompletionHandler: completionHandler)
                 }
    }

    /// handleEventsForBackgroundURLSession
    /// - Parameters:
    ///   - application: Application
    ///   - identifier: Identifier
    ///   - completionHandler: Callback
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        handlers.of(type: AppBackgroundURLSessionHandler.self)
                .forEach { $0.application(application,
                                          handleEventsForBackgroundURLSession: identifier,
                                          completionHandler: completionHandler)
                }
    }

    /// performActionFor shortcutItem
    /// - Parameters:
    ///   - application: Application
    ///   - shortcutItem: Item
    ///   - completionHandler: Callback
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        handlers.of(type: AppShortcutHandler.self)
                .forEach { $0.application(application,
                                          performActionFor: shortcutItem,
                                          completionHandler: completionHandler)
                }
    }

    /// handleWatchKitExtensionRequest
    /// - Parameters:
    ///   - application: Application
    ///   - userInfo: Info
    ///   - reply: Reply
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     handleWatchKitExtensionRequest userInfo: [AnyHashable: Any]?,
                     // swiftlint:disable:next discouraged_optional_collection
                     reply: @escaping ([AnyHashable: Any]?) -> Void) {
        handlers.of(type: AppWatchHandler.self)
                .forEach { $0.application(application,
                                          handleWatchKitExtensionRequest: userInfo,
                                          reply: reply)
                }
    }

    /// applicationShouldRequestHealthAuthorization
    /// - Parameter application: Application
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        handlers.of(type: AppHealthHandler.self)
                .forEach { $0.applicationShouldRequestHealthAuthorization(application) }
    }

    /// handle intent
    /// - Parameters:
    ///   - application: Application
    ///   - intent: Intent
    ///   - completionHandler: Callback
    func application(_ application: UIApplication,
                     handle intent: INIntent,
                     completionHandler: @escaping (INIntentResponse) -> Void) {
        handlers.of(type: AppSiriHandler.self)
            .forEach { $0.application(application,
                                      handle: intent,
                                      completionHandler: completionHandler)
            }
    }

    /// applicationProtectedDataWillBecomeUnavailable
    /// - Parameter application: Application
    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        handlers.of(type: AppContentHandler.self)
                .forEach { $0.applicationProtectedDataWillBecomeUnavailable(application) }
    }

    /// applicationProtectedDataDidBecomeAvailable
    /// - Parameter application: Application
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        handlers.of(type: AppContentHandler.self)
                .forEach { $0.applicationProtectedDataDidBecomeAvailable(application) }
    }

    /// shouldAllowExtensionPointIdentifier
    /// - Parameters:
    ///   - application: Application
    ///   - extensionPointIdentifier: Identifier
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     // swiftlint:disable:next line_length
                     shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        handlers.of(type: AppExtensionHandler.self)
                .map { $0.application(application,
                                      shouldAllowExtensionPointIdentifier: extensionPointIdentifier)
                }
                .allSatisfy { $0 }
    }

    /// viewControllerWithRestorationIdentifierPath
    /// - Parameters:
    ///   - application: Application
    ///   - identifierComponents: Components
    ///   - coder: Coder
    /// - Returns: UIViewController
    func application(_ application: UIApplication,
                     viewControllerWithRestorationIdentifierPath identifierComponents: [Any],
                     coder: NSCoder) -> UIViewController? {
        handlers
            .of(type: AppRestorationHandler.self)
            .compactMap { $0.application(application,
                                         viewControllerWithRestorationIdentifierPath: identifierComponents,
                                         coder: coder)
            }
            .first
    }

    /// shouldSaveApplicationState -- deprecated in 13.2
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     shouldSaveApplicationState coder: NSCoder) -> Bool {
        handlers.of(type: AppRestorationHandler.self)
                .map { $0.application(application,
                                      shouldSaveApplicationState: coder)
                }
                .contains { $0 }
    }

    /// shouldSaveSecureApplicationState
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        handlers.of(type: AppRestorationHandler.self)
                .map { $0.application(application,
                                      shouldSaveSecureApplicationState: coder)
                }
                .contains { $0 }
    }

    /// shouldRestoreApplicationState -- deprecated in 13.2
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     shouldRestoreApplicationState coder: NSCoder) -> Bool {
        handlers.of(type: AppRestorationHandler.self)
                .map { $0.application(application,
                                      shouldRestoreApplicationState: coder)
                }
                .contains { $0 }
    }

    /// shouldRestoreSecureApplicationState
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        handlers.of(type: AppRestorationHandler.self)
                .map { $0.application(application,
                                      shouldRestoreSecureApplicationState: coder)
                }
                .contains { $0 }
    }

    /// willEncodeRestorableStateWith
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    func application(_ application: UIApplication,
                     willEncodeRestorableStateWith coder: NSCoder) {
        handlers.of(type: AppRestorationHandler.self)
                .forEach { $0.application(application,
                                          willEncodeRestorableStateWith: coder)
                }
    }

    /// didDecodeRestorableStateWith
    /// - Parameters:
    ///   - application: Application
    ///   - coder: Coder
    func application(_ application: UIApplication,
                     didDecodeRestorableStateWith coder: NSCoder) {
        handlers.of(type: AppRestorationHandler.self)
                .forEach { $0.application(application,
                                          didDecodeRestorableStateWith: coder)
                }
    }

    /// willContinueUserActivityWithType
    /// - Parameters:
    ///   - application: Application
    ///   - userActivityType: Activity
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     willContinueUserActivityWithType userActivityType: String) -> Bool {
        handlers.of(type: AppContinuityHandler.self)
                .map { $0.application(application,
                                      willContinueUserActivityWithType: userActivityType)
                }
                .contains { $0 }
    }

    /// continue userActivity
    /// - Parameters:
    ///   - application: Application
    ///   - userActivity: Activity
    ///   - restorationHandler: Handler
    /// - Returns: Permission
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     // swiftlint:disable:next discouraged_optional_collection
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        handlers.of(type: AppContinuityHandler.self)
                .map { $0.application(application,
                                      continue: userActivity,
                                      restorationHandler: restorationHandler)
                }
                .contains { $0 }
    }

    /// didFailToContinueUserActivityWithType
    /// - Parameters:
    ///   - application: Application
    ///   - userActivityType: Activity
    ///   - error: Error
    func application(_ application: UIApplication,
                     didFailToContinueUserActivityWithType userActivityType: String,
                     error: Error) {
        handlers.of(type: AppContinuityHandler.self)
                .forEach { $0.application(application,
                                          didFailToContinueUserActivityWithType: userActivityType,
                                          error: error)
                }
    }

    /// didUpdate userActivity
    /// - Parameters:
    ///   - application: Application
    ///   - userActivity: Activity
    func application(_ application: UIApplication,
                     didUpdate userActivity: NSUserActivity) {
        handlers.of(type: AppContinuityHandler.self)
                .forEach { $0.application(application,
                                          didUpdate: userActivity)
                }
    }

    /// userDidAcceptCloudKitShareWith
    /// - Parameters:
    ///   - application: Application
    ///   - cloudKitShareMetadata: Metadata
    func application(_ application: UIApplication,
                     userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        handlers.of(type: AppCloudKitHandler.self)
                .forEach { $0.application(application,
                                          userDidAcceptCloudKitShareWith: cloudKitShareMetadata)
                }
    }

    #if ADOPT_UISCENESESSION
    /// configurationForConnecting
    /// - Parameters:
    ///   - application: Application
    ///   - connectingSceneSession: Session
    ///   - options: Options
    /// - Returns: Configuration
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configs = handlers
            .of(type: AppSceneSessionHandler.self)
            .compactMap { $0.application(application,
                                         configurationForConnecting: connectingSceneSession,
                                         options: options)
            }
        return configs.first ?? connectingSceneSession.configuration
    }

    /// didDiscardSceneSessions
    /// - Parameters:
    ///   - application: Application
    ///   - sceneSessions: Sessions
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        handlers.of(type: AppSceneSessionHandler.self)
                .forEach { $0.application(application,
                                          didDiscardSceneSessions: sceneSessions)
                }
    }
    #endif
}
