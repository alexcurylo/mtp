// @copyright Trollwerks Inc.

import UIKit

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
    /// ReportingService
    var report: ReportingService { get }
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

    /// ReportingService
    var report: ReportingService {
        return ServiceProviderInstances.reportServiceInstance
    }

    /// StyleService
    var style: StyleService {
        return ServiceProviderInstances.styleServiceInstance
    }
}

extension UIViewController: ServiceProvider {

    /// Report screen name
    /// - Parameter name: Name of screen
    func report(screen name: String) {
        guard UIApplication.isProduction else { return }
        report.screen(name: name, vc: classForCoder)
    }

    /// Opt out of Dark Mode
    func setLightMode() {
        // placeholder for if/when `UIUserInterfaceStyle` is rejected
        //if #available(iOS 13.0, *) {
            //RoutingAppDelegate.shared.window?.overrideUserInterfaceStyle = .light
            //overrideUserInterfaceStyle = .light
        //}
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
    /// ReportingService
    static var reportServiceInstance: ReportingService!
    /// StyleService
    static var styleServiceInstance: StyleService!
}

/// Convenience for service injection, in-constructor operaionts, etc.
struct Services: ServiceProvider { }
