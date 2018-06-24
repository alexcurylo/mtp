// @copyright Trollwerks Inc.

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
