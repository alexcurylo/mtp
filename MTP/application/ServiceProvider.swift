// @copyright Trollwerks Inc.

import UIKit

protocol ServiceProvider {

    var app: ApplicationService { get }
    var log: LoggingService { get }
    var mtp: MTPNetworkService { get }
}

extension ServiceProvider {

    var app: ApplicationService {
        return ServiceProviderInstances.appServiceInstance
    }
    var log: LoggingService {
        return ServiceProviderInstances.logServiceInstance
    }
    var mtp: MTPNetworkService {
        return ServiceProviderInstances.mtpServiceInstance
    }
}

private enum ServiceProviderInstances {
    static let appServiceInstance = UIApplication.shared
    static let logServiceInstance = SwiftyBeaverLoggingService()
    static let mtpServiceInstance = MoyaMTPNetworkService()
}
