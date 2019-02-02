// @copyright Trollwerks Inc.

import UIKit

protocol ServiceProvider {

    var app: ApplicationService { get }
    var log: LoggingService { get }
}

extension ServiceProvider {

    var app: ApplicationService {
        return ServiceProviderInstances.appServiceInstance
    }
    var log: LoggingService {
        return ServiceProviderInstances.logServiceInstance
    }
    }
}

private enum ServiceProviderInstances {
    static let appServiceInstance = UIApplication.shared
    static let logServiceInstance = SwiftyBeaverLoggingService()
}
