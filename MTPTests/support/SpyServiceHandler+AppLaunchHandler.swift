// @copyright Trollwerks Inc.

@testable import MTP

extension SpyServiceHandler: AppLaunchHandler {

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ServiceProviderInstances.appServiceSpy = SpyApplicationService()
        ServiceProviderInstances.dataServiceSpy = SpyDataService()
        ServiceProviderInstances.logServiceSpy = SpyLoggingService()
        ServiceProviderInstances.mtpServiceSpy = SpyMTPNetworkService()

        return true
    }

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
