// @copyright Trollwerks Inc.

@testable import MTP

extension SpyServiceHandler: AppLaunchHandler {

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ServiceProviderInstances.appServiceInstance = SpyApplicationService()
        ServiceProviderInstances.dataServiceInstance = SpyDataService()
        ServiceProviderInstances.locServiceInstance = SpyLocationService()
        ServiceProviderInstances.logServiceInstance = SpyLoggingService()
        ServiceProviderInstances.mtpServiceInstance = SpyMTPNetworkService()
        ServiceProviderInstances.noteServiceInstance = SpyNotificationService()

        return true
    }

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
