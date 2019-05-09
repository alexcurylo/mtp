// @copyright Trollwerks Inc.

import FBSDKCoreKit
import UIKit

struct StateHandler: AppHandler, ServiceProvider { }

extension StateHandler: AppStateHandler {

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        mtp.refreshEverything()

        logFacebookActivate()
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

// MARK: - Facebook

extension StateHandler {

    func logFacebookActivate() {
        AppEvents.activateApp()
    }
}
