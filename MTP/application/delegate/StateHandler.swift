// @copyright Trollwerks Inc.

import UIKit

struct StateHandler: AppHandler, ServiceProvider { }

extension StateHandler: AppStateHandler {

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        mtp.refreshEverything()
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
