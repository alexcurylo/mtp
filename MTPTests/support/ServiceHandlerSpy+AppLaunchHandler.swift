// @copyright Trollwerks Inc.

@testable import MTP

extension ServiceHandlerSpy: AppLaunchHandler {

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ServiceProviderInstances.appServiceInstance = ApplicationServiceSpy()
        ServiceProviderInstances.dataServiceInstance = DataServiceSpy()
        ServiceProviderInstances.locServiceInstance = LocationServiceSpy()
        ServiceProviderInstances.logServiceInstance = LoggingServiceSpy()
        ServiceProviderInstances.netServiceInstance = NetworkServiceSpy()
        ServiceProviderInstances.noteServiceInstance = NotificationServiceSpy()
        ServiceProviderInstances.reportServiceInstance = ReportingServiceSpy()
        ServiceProviderInstances.styleServiceInstance = StyleServiceSpy()

        return true
    }

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
