// @copyright Trollwerks Inc.

import UIKit

@UIApplicationMain
final class MTPDelegate: RoutingAppDelegate {

    enum Runtime {
        case production
        case testing
    }

    override var handlers: Handlers {
        return runtimeHandlers
    }

    private var runtimeHandlers: Handlers = {
        let runtime: Runtime = UIApplication.isUnitTesting ? .testing : .production
        return MTPDelegate.runtimeHandlers(for: runtime)
    }()

    static func runtimeHandlers(for runtime: Runtime) -> Handlers {
        guard runtime == .production else {
            return [SpyServiceHandler()]
        }

        return [
            ServiceHandler(),
            LaunchHandler(),
            StateHandler(),
            ActionHandler()
        ]
    }
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
