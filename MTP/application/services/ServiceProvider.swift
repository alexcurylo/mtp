// @copyright Trollwerks Inc.

import UIKit

// https://medium.com/@neobeppe/how-to-dismantle-a-massive-singleton-ios-app-a3fb75f7d18f

protocol ServiceProvider {

    var app: ApplicationService { get }
    var data: DataService { get }
    var loc: LocationService { get }
    var log: LoggingService { get }
    var net: NetworkService { get }
    var note: NotificationService { get }
}

extension ServiceProvider {

    // override to return mocks/stubs
    // defaults set by ServiceHandler or ServiceHandlerSpy

    var app: ApplicationService {
        return ServiceProviderInstances.appServiceInstance
    }

    var data: DataService {
        return ServiceProviderInstances.dataServiceInstance
    }

    var loc: LocationService {
        return ServiceProviderInstances.locServiceInstance
    }

    var log: LoggingService {
        return ServiceProviderInstances.logServiceInstance
    }

    var net: NetworkService {
        return ServiceProviderInstances.netServiceInstance
    }

    var note: NotificationService {
        return ServiceProviderInstances.noteServiceInstance
    }
}

enum ServiceProviderInstances {

    // swiftlint:disable implicitly_unwrapped_optional
    static var appServiceInstance: ApplicationService!
    static var dataServiceInstance: DataService!
    static var locServiceInstance: LocationService!
    static var logServiceInstance: LoggingService!
    static var netServiceInstance: NetworkService!
    static var noteServiceInstance: NotificationService!
}
