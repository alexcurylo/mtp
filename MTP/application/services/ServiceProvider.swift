// @copyright Trollwerks Inc.

import UIKit

// https://medium.com/@neobeppe/how-to-dismantle-a-massive-singleton-ios-app-a3fb75f7d18f

protocol ServiceProvider {

    var app: ApplicationService { get }
    var data: DataService { get }
    var log: LoggingService { get }
    var mtp: MTPNetworkService { get }
}

extension ServiceProvider {

    // override to return mocks/stubs
    // defaults set by ServiceHandler or SpyServiceHandler

    var app: ApplicationService {
        return ServiceProviderInstances.appServiceInstance
    }

    var data: DataService {
        return ServiceProviderInstances.dataServiceInstance
    }

    var log: LoggingService {
        return ServiceProviderInstances.logServiceInstance
    }

    var mtp: MTPNetworkService {
        return ServiceProviderInstances.mtpServiceInstance
    }
}

enum ServiceProviderInstances {

    // swiftlint:disable implicitly_unwrapped_optional
    static var appServiceInstance: ApplicationService!
    static var dataServiceInstance: DataService!
    static var logServiceInstance: LoggingService!
    static var mtpServiceInstance: MTPNetworkService!
}
