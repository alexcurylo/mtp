// @copyright Trollwerks Inc.

import UIKit

struct ActionHandler: AppHandler, ServiceProvider {

    static var shared: ActionHandler? {
        return RoutingAppDelegate.shared.handlers.firstOf(type: self)
    }

    let dependencies: [AppHandler.Type] = []
}

extension ActionHandler: AppOpenURLHandler {

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return handleFacebookURL(app: app, open: url, options: options)
    }
}

extension ActionHandler: AppStateHandler {

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
