// @copyright Trollwerks Inc.

import UIKit

/// Stub for startup construction
struct StateHandler: AppHandler, ServiceProvider { }

extension StateHandler: AppStateHandler {

    /// Enter foreground handler
    /// - Parameter application: Application
    func applicationWillEnterForeground(_ application: UIApplication) { }

    /// Become active handler
    /// - Parameter application: Application
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        net.refreshEverything()
    }

    /// Resign active handler
    /// - Parameter application: Application
    func applicationWillResignActive(_ application: UIApplication) { }

    /// Enter background handler
    /// - Parameter application: Application
    func applicationDidEnterBackground(_ application: UIApplication) { }

    /// Terminate handler
    /// - Parameter application: Application
    func applicationWillTerminate(_ application: UIApplication) { }
}
