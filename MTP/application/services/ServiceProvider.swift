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

    var app: ApplicationService {
        return UIApplication.isUnitTesting ? ServiceProviderInstances.appServiceInstance
                                           : ServiceProviderInstances.appServiceSpy
    }

    var data: DataService {
        return UIApplication.isUnitTesting ? ServiceProviderInstances.dataServiceInstance
                                           : ServiceProviderInstances.dataServiceSpy
    }

    var log: LoggingService {
        return UIApplication.isUnitTesting ? ServiceProviderInstances.logServiceInstance
                                           : ServiceProviderInstances.logServiceSpy
    }

    var mtp: MTPNetworkService {
        return UIApplication.isUnitTesting ? ServiceProviderInstances.mtpServiceInstance
                                           : ServiceProviderInstances.mtpServiceSpy
    }
}

enum ServiceProviderInstances {

    static let appServiceInstance = UIApplication.shared
    static let dataServiceInstance = DataServiceImpl()
    static let logServiceInstance = SwiftyBeaverLoggingService()
    static let mtpServiceInstance = MoyaMTPNetworkService()

    // swiftlint:disable implicitly_unwrapped_optional
    static var appServiceSpy: ApplicationService!
    static var dataServiceSpy: DataService!
    static var logServiceSpy: LoggingService!
    static var mtpServiceSpy: MTPNetworkService!
}
