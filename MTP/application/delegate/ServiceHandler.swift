// @copyright Trollwerks Inc.

import UIKit

struct ServiceHandler: AppHandler { }

extension ServiceHandler: AppLaunchHandler {

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // other services may log
        ServiceProviderInstances.logServiceInstance = SwiftyBeaverLoggingService()

        ServiceProviderInstances.appServiceInstance = UIApplication.shared
        ServiceProviderInstances.dataServiceInstance = DataServiceImpl()
        ServiceProviderInstances.locServiceInstance = LocationServiceImpl()
        ServiceProviderInstances.mtpServiceInstance = MoyaMTPNetworkService()
        ServiceProviderInstances.noteServiceInstance = NotificationServiceImpl()

        return true
    }

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

struct SpyServiceHandler: AppHandler { }

// SpyServiceHandler+AppLaunchHandler in test target sets spy instances
