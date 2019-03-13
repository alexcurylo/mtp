// @copyright Trollwerks Inc.

@testable import MTP

extension SpyServiceHandler: AppLaunchHandler {

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ServiceProviderInstances.logServiceInstance = SpyLoggingService()
        ServiceProviderInstances.appServiceInstance = SpyApplicationService()
        ServiceProviderInstances.dataServiceInstance = SpyDataService()
        ServiceProviderInstances.mtpServiceInstance = SpyMTPNetworkService()

        return true
    }

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
