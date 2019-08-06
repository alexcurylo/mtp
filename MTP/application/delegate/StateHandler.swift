// @copyright Trollwerks Inc.

import UIKit

/// Handle things to do on application state changes
struct StateHandler: AppHandler, ServiceProvider { }

extension StateHandler: AppStateHandler {

    /// Enter foreground handler
    ///
    /// - Parameter application: Application
    func applicationWillEnterForeground(_ application: UIApplication) { }

    /// Become active handler
    ///
    /// - Parameter application: Application
    func applicationDidBecomeActive(_ application: UIApplication) { }

    /// Resign active handler
    ///
    /// - Parameter application: Application
    func applicationWillResignActive(_ application: UIApplication) { }

    /// Enter background handler
    ///
    /// - Parameter application: Application
    func applicationDidEnterBackground(_ application: UIApplication) {
        //loc.checkDistances()
    }

    /// Terminate handler
    ///
    /// - Parameter application: Application
    func applicationWillTerminate(_ application: UIApplication) { }
}
