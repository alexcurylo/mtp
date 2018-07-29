// @copyright Trollwerks Inc.

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

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
        logFacebookActivate()
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return handleFacebookURL(app: app, open: url, options: options)
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        log.warning("\(type(of: self)) applicationDidReceiveMemoryWarning")
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

private extension AppDelegate {

    func configureSettingsDisplay() {
        StringKey.infoDictionarySettingsKeys.copyToUserDefaults()
    }

    func configureAppearance() {
        UINavigationBar.set(transparency: .transparent)
    }
}
