// @copyright Trollwerks Inc.

import UIKit

/// Our routing application delegate
@UIApplicationMain final class MTPDelegate: RoutingAppDelegate {

    /// Runtime environments our app delegate recognizes
    enum Runtime {
        /// Active user input
        case production
        /// Executing UI tests
        case uiTesting
        /// Executing unit tests
        case unitTesting
    }

    /// Handlers for the active environment
    override var handlers: Handlers {
        return runtimeHandlers
    }

    private var runtimeHandlers: Handlers = {
        var runtime: Runtime = .production
        if UIApplication.isUITesting {
            runtime = .uiTesting
        } else if UIApplication.isUnitTesting {
            runtime = .unitTesting
        }
        return MTPDelegate.runtimeHandlers(for: runtime)
    }()

    /// Handlers for environment
    ///
    /// - Parameter runtime: Environment descriptor
    /// - Returns: Appropriate handler collection
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
        #if DEBUG
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
        #else
        default:
            return []
        #endif
        }
    }
}
