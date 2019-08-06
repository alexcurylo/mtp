// @copyright Trollwerks Inc.

import UIKit

struct ServiceHandler: AppHandler { }

extension ServiceHandler: AppLaunchHandler {

    /// willFinishLaunchingWithOptions handler
    ///
    /// - Parameters:
    ///   - application: UIApplication
    ///   - launchOptions: Options
    /// - Returns: Success
    public func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // swiftlint:disable:previous discouraged_optional_collection

        // other services may log
        ServiceProviderInstances.logServiceInstance = SwiftyBeaverLoggingService()

        ServiceProviderInstances.appServiceInstance = UIApplication.shared
        ServiceProviderInstances.dataServiceInstance = DataServiceImpl()
        ServiceProviderInstances.locServiceInstance = LocationServiceImpl()
        ServiceProviderInstances.netServiceInstance = NetworkServiceImpl()
        ServiceProviderInstances.noteServiceInstance = NotificationServiceImpl()
        ServiceProviderInstances.styleServiceInstance = StyleServiceImpl()

        return true
    }

    /// didFinishLaunching handler
    ///
    /// - Parameters:
    ///   - application: UIApplication
    ///   - launchOptions: Options
    /// - Returns: Success
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // swiftlint:disable:previous discouraged_optional_collection
        return true
    }
}

struct ServiceHandlerStub: AppHandler { }

extension ServiceHandlerStub: AppLaunchHandler {

    /// willFinishLaunchingWithOptions handler
    ///
    /// - Parameters:
    ///   - application: UIApplication
    ///   - launchOptions: Options
    /// - Returns: Success
    public func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // swiftlint:disable:previous discouraged_optional_collection

        // other services may log
        ServiceProviderInstances.logServiceInstance = ConsoleLoggingService()

        ServiceProviderInstances.appServiceInstance = UIApplication.shared
        ServiceProviderInstances.dataServiceInstance = DataServiceStub()
        ServiceProviderInstances.locServiceInstance = LocationServiceStub()
        ServiceProviderInstances.netServiceInstance = NetworkServiceStub()
        ServiceProviderInstances.noteServiceInstance = NotificationServiceStub()
        ServiceProviderInstances.styleServiceInstance = StyleServiceImpl()

        return true
    }

    /// didFinishLaunching handler
    ///
    /// - Parameters:
    ///   - application: UIApplication
    ///   - launchOptions: Options
    /// - Returns: Success
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // swiftlint:disable:previous discouraged_optional_collection
        return true
    }
}

/// Forward declaration for handler construction in app delegate
/// ServiceHandlerSpy+AppLaunchHandler in test target sets spy instances
struct ServiceHandlerSpy: AppHandler { }
