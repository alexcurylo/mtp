// @copyright Trollwerks Inc.

import UIKit

@UIApplicationMain
final class MTPDelegate: RoutingAppDelegate {

    // MTPDelegate.init() constructs these at _UIApplicationMainPreparations time
    // Adopt AppLaunchHandler for calls at FinishLaunching times when Foundation exists
    private let allHandlers: Handlers = MTPDelegate.runtimeHandlers()

    // swiftlint:disable:next discouraged_optional_boolean
    class func runtimeHandlers(forUnitTests: Bool? = nil) -> Handlers {
        var runtimeHandlers: Handlers = [
        ]

        let forUnitTests = forUnitTests ?? UIApplication.isUnitTesting
        if forUnitTests {
            runtimeHandlers += [
                SpyServiceHandler()
            ] as Handlers
        } else {
            runtimeHandlers += [
                ActionHandler(),
                LaunchHandler()
            ] as Handlers
        }

        return runtimeHandlers
    }

    override var handlers: Handlers {
        return allHandlers
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
