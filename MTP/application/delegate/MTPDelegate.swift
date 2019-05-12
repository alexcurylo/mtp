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
            ActionHandler(),
            NotificationsHandler()
        ]
    }
}
