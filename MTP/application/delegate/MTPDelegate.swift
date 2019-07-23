// @copyright Trollwerks Inc.

import UIKit

@UIApplicationMain
final class MTPDelegate: RoutingAppDelegate {

    enum Runtime {
        case production
        case uiTesting
        case unitTesting
    }

    override var handlers: Handlers {
        return runtimeHandlers
    }

    private var runtimeHandlers: Handlers = {
        let runtime: Runtime
        switch (UIApplication.isUITesting, UIApplication.isUnitTesting) {
        case (true, _):
            runtime = .uiTesting
        case (_, true):
            runtime = .unitTesting
        default:
            runtime = .production
        }
        return MTPDelegate.runtimeHandlers(for: runtime)
    }()

    static func runtimeHandlers(for runtime: Runtime) -> Handlers {
        switch runtime {
        case .production:
            return [
                ServiceHandler(),
                LaunchHandler(),
                StateHandler(),
                ActionHandler(),
                NotificationsHandler(),
                LocationHandler()
            ]
        case .uiTesting:
            return [
                ServiceHandlerStub(),
                LaunchHandler(),
                StateHandler(),
                ActionHandler(),
                NotificationsHandler(),
                LocationHandler()
            ]
        case .unitTesting:
            return [ ServiceHandlerSpy() ]
        }
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
