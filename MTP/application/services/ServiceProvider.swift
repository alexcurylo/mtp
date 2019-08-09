// @copyright Trollwerks Inc.

// https://medium.com/@neobeppe/how-to-dismantle-a-massive-singleton-ios-app-a3fb75f7d18f

/// Provider of application-wide services
protocol ServiceProvider {

    /// ApplicationService
    var app: ApplicationService { get }
    /// DataService
    var data: DataService { get }
    /// LocationService
    var loc: LocationService { get }
    /// LoggingService
    var log: LoggingService { get }
    /// NetworkService
    var net: NetworkService { get }
    /// NotificationService
    var note: NotificationService { get }
    /// StyleService
    var style: StyleService { get }
}

extension ServiceProvider {

    // override to return mocks/stubs
    // defaults set by ServiceHandler or ServiceHandlerSpy

    /// ApplicationService
    var app: ApplicationService {
        return ServiceProviderInstances.appServiceInstance
    }

    /// DataService
    var data: DataService {
        return ServiceProviderInstances.dataServiceInstance
    }

    /// LocationService
    var loc: LocationService {
        return ServiceProviderInstances.locServiceInstance
    }

    /// LoggingService
    var log: LoggingService {
        return ServiceProviderInstances.logServiceInstance
    }

    /// NetworkService
    var net: NetworkService {
        return ServiceProviderInstances.netServiceInstance
    }

    /// NotificationService
    var note: NotificationService {
        return ServiceProviderInstances.noteServiceInstance
    }

    /// StyleService
    var style: StyleService {
        return ServiceProviderInstances.styleServiceInstance
    }
}

/// To be set up at application startup time
enum ServiceProviderInstances {

    // swiftlint:disable implicitly_unwrapped_optional

    /// ApplicationService
    static var appServiceInstance: ApplicationService!
    /// DataService
    static var dataServiceInstance: DataService!
    /// LocationService
    static var locServiceInstance: LocationService!
    /// LoggingService
    static var logServiceInstance: LoggingService!
    /// NetworkService
    static var netServiceInstance: NetworkService!
    /// NotificationService
    static var noteServiceInstance: NotificationService!
    /// StyleService
    static var styleServiceInstance: StyleService!
}
