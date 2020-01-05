// @copyright Trollwerks Inc.

import UIKit

/// Stub for startup construction
struct ServiceHandler: AppHandler {

    /// Global accessor
    static var services: ServiceHandler? {
        RoutingAppDelegate.handler(type: Self.self)
    }
}

extension ServiceHandler: AppLaunchHandler {

    /// willFinishLaunchingWithOptions handler
    /// - Parameters:
    ///   - application: UIApplication
    ///   - launchOptions: Options
    /// - Returns: Success
    func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // other services may log during construction
        ServiceProviderInstances.logServiceInstance = SwiftyBeaverLoggingService()

        ServiceProviderInstances.appServiceInstance = UIApplication.shared
        ServiceProviderInstances.dataServiceInstance = DataServiceImpl()
        ServiceProviderInstances.locServiceInstance = LocationServiceImpl()
        ServiceProviderInstances.netServiceInstance = NetworkServiceImpl()
        ServiceProviderInstances.noteServiceInstance = NotificationServiceImpl()
        ServiceProviderInstances.reportServiceInstance = FirebaseReportingService()
        ServiceProviderInstances.styleServiceInstance = StyleServiceImpl()

        // post-construction setup
        ServiceProviderInstances.dataServiceInstance.validate()

        return true
    }

    /// didFinishLaunching handler
    /// - Parameters:
    ///   - application: UIApplication
    ///   - launchOptions: Options
    /// - Returns: Success
    func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }
}

// MARK: - Testing

#if DEBUG
/// :nodoc:
struct ServiceHandlerStub: AppLaunchHandler {

    /// :nodoc:
    func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // other services may log
        ServiceProviderInstances.logServiceInstance = ConsoleLoggingService()

        ServiceProviderInstances.appServiceInstance = UIApplication.shared
        ServiceProviderInstances.dataServiceInstance = DataServiceStub()
        ServiceProviderInstances.locServiceInstance = LocationServiceStub()
        ServiceProviderInstances.netServiceInstance = NetworkServiceStub()
        ServiceProviderInstances.noteServiceInstance = NotificationServiceStub()
        ServiceProviderInstances.reportServiceInstance = ReportingServiceStub()
        ServiceProviderInstances.styleServiceInstance = StyleServiceImpl()

        return true
    }

    /// :nodoc:
    func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if let token = ProcessInfo.setting(string: .token),
           let data = token.data(using: String.Encoding.utf8),
           let delegate = application.delegate {
            delegate.application?(application,
                                  didRegisterForRemoteNotificationsWithDeviceToken: data)
        }

        return true
    }
}
#endif
