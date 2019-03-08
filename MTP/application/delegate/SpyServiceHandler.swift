// @copyright Trollwerks Inc.

import Foundation

struct SpyServiceHandler: AppHandler {

    static var shared: SpyServiceHandler? {
        return RoutingAppDelegate.shared.handlers.firstOf(type: self)
    }

    let dependencies: [AppHandler.Type] = []
}
