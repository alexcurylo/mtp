// @copyright Trollwerks Inc.

import UIKit

/// Stub for startup construction
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
        ServiceProviderInstances.reportServiceInstance = FirebaseReportingService()
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

// MARK: - Testing

#if DEBUG
/// :nodoc:
struct ServiceHandlerStub: AppLaunchHandler {

    /// :nodoc:
    func application(
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
        ServiceProviderInstances.reportServiceInstance = ReportingServiceStub()
        ServiceProviderInstances.styleServiceInstance = StyleServiceImpl()

        return true
    }

    /// :nodoc:
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // swiftlint:disable:previous discouraged_optional_collection

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
