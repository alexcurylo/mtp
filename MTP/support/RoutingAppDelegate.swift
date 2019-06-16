// @copyright Trollwerks Inc.

import CloudKit
import Intents
import UIKit

// swiftlint:disable file_length

// Adopt to be constructed at app startup
protocol AppHandler { }

// Adopt more protocols to have notifications routed to your handler

protocol AppLaunchHandler: AppHandler {
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
}

protocol AppStateHandler: AppHandler {
    func applicationWillEnterForeground(_ application: UIApplication)
    func applicationDidBecomeActive(_ application: UIApplication)
    func applicationWillResignActive(_ application: UIApplication)
    func applicationDidEnterBackground(_ application: UIApplication)
    func applicationWillTerminate(_ application: UIApplication)
}

protocol AppOpenURLHandler: AppHandler {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
}

protocol AppMemoryHandler: AppHandler {
    func applicationDidReceiveMemoryWarning(_ application: UIApplication)
}

protocol AppTimeChangeHandler: AppHandler {
    func applicationSignificantTimeChange(_ application: UIApplication)
}

protocol AppStatusBarHandler: AppHandler {
    func application(_ application: UIApplication,
                     willChangeStatusBarOrientation newStatusBarOrientation: UIInterfaceOrientation,
                     duration: TimeInterval)
    func application(_ application: UIApplication,
                     didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation)
    func application(_ application: UIApplication,
                     willChangeStatusBarFrame newStatusBarFrame: CGRect)
    func application(_ application: UIApplication,
                     didChangeStatusBarFrame oldStatusBarFrame: CGRect)
}

protocol AppNotificationsHandler: AppHandler {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error)
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

protocol AppBackgroundFetchHandler: AppHandler {
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

protocol AppBackgroundURLSessionHandler: AppHandler {
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void)
}

protocol AppShortcutHandler: AppHandler {
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void)
}

protocol AppWatchHandler: AppHandler {
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     handleWatchKitExtensionRequest userInfo: [AnyHashable: Any]?,
                     // swiftlint:disable:next discouraged_optional_collection
                     reply: @escaping ([AnyHashable: Any]?) -> Void)
}

protocol AppHealthHandler: AppHandler {
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication)
}

protocol AppSiriHandler: AppHandler {
    func application(_ application: UIApplication,
                     handle intent: INIntent,
                     completionHandler: @escaping (INIntentResponse) -> Void)
}

protocol AppContentHandler: AppHandler {
    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication)
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication)
}

protocol AppExtensionHandler: AppHandler {
    func application(_ application: UIApplication,
                     // swiftlint:disable:next line_length
                     shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool
}

protocol AppRestorationHandler: AppHandler {
    func application(_ application: UIApplication,
                     viewControllerWithRestorationIdentifierPath identifierComponents: [Any],
                     coder: NSCoder) -> UIViewController?
    func application(_ application: UIApplication,
                     shouldSaveApplicationState coder: NSCoder) -> Bool
    func application(_ application: UIApplication,
                     shouldRestoreApplicationState coder: NSCoder) -> Bool
    func application(_ application: UIApplication,
                     willEncodeRestorableStateWith coder: NSCoder)
    func application(_ application: UIApplication,
                     didDecodeRestorableStateWith coder: NSCoder)
}

protocol AppContinuityHandler: AppHandler {
    func application(_ application: UIApplication,
                     willContinueUserActivityWithType userActivityType: String) -> Bool
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     // swiftlint:disable:next discouraged_optional_collection
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    func application(_ application: UIApplication,
                     didFailToContinueUserActivityWithType userActivityType: String,
                     error: Error)
    func application(_ application: UIApplication,
                     didUpdate userActivity: NSUserActivity)
}

protocol AppCloudKitHandler: AppHandler {
    func application(_ application: UIApplication,
                     userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata)
}

// Override `RoutingAppDelegate` to return app's list of `handlers`

// swiftlint:disable:next type_body_length
open class RoutingAppDelegate: UIResponder, UIApplicationDelegate {

    typealias Handlers = [AppHandler]

    @objc static var shared: RoutingAppDelegate = {
        // swiftlint:disable:next force_cast
        return UIApplication.shared.delegate as! RoutingAppDelegate
    }()

    public var window: UIWindow?

    var handlers: Handlers {
        fatalError("Incorrect RoutingAppDelegate usage: subclass and override `handlers`")
    }

    static func handler<T>(type: T.Type) -> T? {
        return RoutingAppDelegate.shared.handlers.firstOf(type: T.self)
    }

    // MARK: - All members of UIApplicationDelegate as found in 12.0 SDK

    public func applicationDidFinishLaunching(_ application: UIApplication) {
        handlers.of(type: AppLaunchHandler.self)
                .forEach { _ = $0.application(application,
                                              didFinishLaunchingWithOptions: nil)
                }
    }

    public func application(_ application: UIApplication,
                            // swiftlint:disable:next discouraged_optional_collection line_length
                            willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return handlers.of(type: AppLaunchHandler.self)
                       .map { $0.application(application,
                                             willFinishLaunchingWithOptions: launchOptions)
                       }
                       .allSatisfy { $0 }
    }

    public func application(_ application: UIApplication,
                            // swiftlint:disable:next discouraged_optional_collection line_length
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return handlers.of(type: AppLaunchHandler.self)
                       .map { $0.application(application,
                                             didFinishLaunchingWithOptions: launchOptions)
                       }
                       .allSatisfy { $0 }
    }

    public func applicationWillEnterForeground(_ application: UIApplication) {
        handlers.of(type: AppStateHandler.self)
                .forEach { $0.applicationWillEnterForeground(application) }
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        handlers.of(type: AppStateHandler.self)
                .forEach { $0.applicationDidBecomeActive(application) }
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        handlers.of(type: AppStateHandler.self)
                .forEach { $0.applicationWillResignActive(application) }
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        handlers.of(type: AppStateHandler.self)
                .forEach { $0.applicationDidEnterBackground(application) }
    }

     public func applicationWillTerminate(_ application: UIApplication) {
        handlers.of(type: AppStateHandler.self)
                .forEach { $0.applicationWillTerminate(application) }
    }

    public func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
     return handlers.of(type: AppOpenURLHandler.self)
                    .map { $0.application(app,
                                          open: url,
                                          options: options)
                    }
                    .contains { $0 }
    }

    public func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        handlers.of(type: AppMemoryHandler.self)
                .forEach { $0.applicationDidReceiveMemoryWarning(application) }
    }

    public func applicationSignificantTimeChange(_ application: UIApplication) {
        handlers.of(type: AppTimeChangeHandler.self)
                .forEach { $0.applicationSignificantTimeChange(application) }
    }

    public func application(_ application: UIApplication,
                            willChangeStatusBarOrientation newStatusBarOrientation: UIInterfaceOrientation,
                            duration: TimeInterval) {
        handlers.of(type: AppStatusBarHandler.self)
                .forEach { $0.application(application,
                                          willChangeStatusBarOrientation: newStatusBarOrientation,
                                          duration: duration)
                }
    }

    public func application(_ application: UIApplication,
                            didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation) {
        handlers.of(type: AppStatusBarHandler.self)
                 .forEach { $0.application(application,
                                           didChangeStatusBarOrientation: oldStatusBarOrientation)
                 }
    }

    public func application(_ application: UIApplication,
                            willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        handlers.of(type: AppStatusBarHandler.self)
                 .forEach { $0.application(application,
                                           willChangeStatusBarFrame: newStatusBarFrame)
                 }
    }

    public func application(_ application: UIApplication,
                            didChangeStatusBarFrame oldStatusBarFrame: CGRect) {
        handlers.of(type: AppStatusBarHandler.self)
                .forEach { $0.application(application,
                                          didChangeStatusBarFrame: oldStatusBarFrame)
                }
    }

    public func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        handlers.of(type: AppNotificationsHandler.self)
                .forEach { $0.application(application,
                                          didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
                }
    }

    public func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
        handlers.of(type: AppNotificationsHandler.self)
                .forEach { $0.application(application,
                                          didFailToRegisterForRemoteNotificationsWithError: error)
                }
    }

    public func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handlers.of(type: AppNotificationsHandler.self)
                 .forEach { $0.application(application,
                                           didReceiveRemoteNotification: userInfo,
                                           fetchCompletionHandler: completionHandler)
                 }
    }

    public func application(_ application: UIApplication,
                            // swiftlint:disable:next line_length
                            performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handlers.of(type: AppBackgroundFetchHandler.self)
                .forEach { $0.application(application,
                                          performFetchWithCompletionHandler: completionHandler)
                }
    }

    public func application(_ application: UIApplication,
                            handleEventsForBackgroundURLSession identifier: String,
                            completionHandler: @escaping () -> Void) {
        handlers.of(type: AppBackgroundURLSessionHandler.self)
                .forEach { $0.application(application,
                                          handleEventsForBackgroundURLSession: identifier,
                                          completionHandler: completionHandler)
                }
    }

    public func application(_ application: UIApplication,
                            performActionFor shortcutItem: UIApplicationShortcutItem,
                            completionHandler: @escaping (Bool) -> Void) {
        handlers.of(type: AppShortcutHandler.self)
                .forEach { $0.application(application,
                                          performActionFor: shortcutItem,
                                          completionHandler: completionHandler)
                }
    }

    public func application(_ application: UIApplication,
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

    public func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        handlers.of(type: AppHealthHandler.self)
                .forEach { $0.applicationShouldRequestHealthAuthorization(application) }
    }

    public func application(_ application: UIApplication,
                            handle intent: INIntent,
                            completionHandler: @escaping (INIntentResponse) -> Void) {
        handlers.of(type: AppSiriHandler.self)
            .forEach { $0.application(application,
                                      handle: intent,
                                      completionHandler: completionHandler)
            }
    }

    public func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        handlers.of(type: AppContentHandler.self)
                .forEach { $0.applicationProtectedDataWillBecomeUnavailable(application) }
    }

    public func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        handlers.of(type: AppContentHandler.self)
                .forEach { $0.applicationProtectedDataDidBecomeAvailable(application) }
    }

#if Do_not_implement_use_UITraitCollection_and_UITraitEnvironment_APIs
    public func application(_ application: UIApplication,
                            supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }
#endif

    public func application(_ application: UIApplication,
                            // swiftlint:disable:next line_length
                            shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        return handlers.of(type: AppExtensionHandler.self)
                       .map { $0.application(application,
                                             shouldAllowExtensionPointIdentifier: extensionPointIdentifier)
                       }
                       .allSatisfy { $0 }
    }

    public func application(_ application: UIApplication,
                            viewControllerWithRestorationIdentifierPath identifierComponents: [Any],
                            coder: NSCoder) -> UIViewController? {
        return handlers
            .of(type: AppRestorationHandler.self)
            .compactMap { $0.application(application,
                                         viewControllerWithRestorationIdentifierPath: identifierComponents,
                                         coder: coder)
            }
            .first
    }

    public func application(_ application: UIApplication,
                            shouldSaveApplicationState coder: NSCoder) -> Bool {
        return handlers.of(type: AppRestorationHandler.self)
                       .map { $0.application(application,
                                             shouldSaveApplicationState: coder)
                       }
                       .contains { $0 }
    }

    public func application(_ application: UIApplication,
                            shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return handlers.of(type: AppRestorationHandler.self)
                       .map { $0.application(application,
                                             shouldRestoreApplicationState: coder)
                       }
                       .contains { $0 }
    }

    public func application(_ application: UIApplication,
                            willEncodeRestorableStateWith coder: NSCoder) {
        handlers.of(type: AppRestorationHandler.self)
                .forEach { $0.application(application,
                                          willEncodeRestorableStateWith: coder)
                }
    }

    public func application(_ application: UIApplication,
                            didDecodeRestorableStateWith coder: NSCoder) {
        handlers.of(type: AppRestorationHandler.self)
                .forEach { $0.application(application,
                                          didDecodeRestorableStateWith: coder)
                }
    }

    public func application(_ application: UIApplication,
                            willContinueUserActivityWithType userActivityType: String) -> Bool {
        return handlers.of(type: AppContinuityHandler.self)
                       .map { $0.application(application,
                                             willContinueUserActivityWithType: userActivityType)
                       }
                       .contains { $0 }
    }

    public func application(_ application: UIApplication,
                            continue userActivity: NSUserActivity,
                            // swiftlint:disable:next discouraged_optional_collection
                            restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return handlers.of(type: AppContinuityHandler.self)
                       .map { $0.application(application,
                                             continue: userActivity,
                                             restorationHandler: restorationHandler)
                       }
                       .contains { $0 }
    }

    public func application(_ application: UIApplication,
                            didFailToContinueUserActivityWithType userActivityType: String,
                            error: Error) {
        handlers.of(type: AppContinuityHandler.self)
                .forEach { $0.application(application,
                                          didFailToContinueUserActivityWithType: userActivityType,
                                          error: error)
                }
    }

    public func application(_ application: UIApplication,
                            didUpdate userActivity: NSUserActivity) {
        handlers.of(type: AppContinuityHandler.self)
                .forEach { $0.application(application,
                                          didUpdate: userActivity)
                }
    }

    public func application(_ application: UIApplication,
                            userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        handlers.of(type: AppCloudKitHandler.self)
                .forEach { $0.application(application,
                                          userDidAcceptCloudKitShareWith: cloudKitShareMetadata)
                }
    }
}
