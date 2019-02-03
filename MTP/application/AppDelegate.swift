// @copyright Trollwerks Inc.

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, ServiceProvider {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureLogging()

        configureAppCenter()

        configureSettingsDisplay()

        configureFacebook(app: application, options: launchOptions ?? [:])

        configureAppearance()

        log.verbose("didFinishLaunchingWithOptions")

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        mtp.refreshFromWebsite()

        logFacebookActivate()
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return handleFacebookURL(app: app, open: url, options: options)
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        log.warning("applicationDidReceiveMemoryWarning")
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    #if PUSH_NOTIFICATIONS
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MSPush.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        MSPush.didFailToRegisterForRemoteNotificationsWithError(error)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let result: Bool = MSPush.didReceiveRemoteNotification(userInfo)
        if result {
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    #endif
}

private extension AppDelegate {

    func configureSettingsDisplay() {
        StringKey.infoDictionarySettingsKeys.copyToUserDefaults()
    }

    func configureAppearance() {
        style.standard.styleAppearance()
    }
}
