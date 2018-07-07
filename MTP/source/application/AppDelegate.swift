// @copyright Trollwerks Inc.

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if !UIApplication.isTesting {
            MSAppCenter.start("20cb945f-58b9-4544-a059-424aa3b86820",
                              withServices: [MSDistribute.self,
                                             MSCrashes.self,
                                             MSAnalytics.self])
        }

        configureSettingsDisplay()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("INFO: \(type(of: self)) applicationDidReceiveMemoryWarning")
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

private extension AppDelegate {

    func configureSettingsDisplay() {
        StringKey.infoDictionaryKeys.copyToUserDefaults()
    }
}
