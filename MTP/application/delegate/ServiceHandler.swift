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
        ServiceProviderInstances.netServiceInstance = NetworkServiceImpl()
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

struct ServiceHandlerStub: AppHandler { }

extension ServiceHandlerStub: AppLaunchHandler {

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // other services may log
        ServiceProviderInstances.logServiceInstance = SwiftyBeaverLoggingService()

        ServiceProviderInstances.appServiceInstance = UIApplication.shared
        ServiceProviderInstances.dataServiceInstance = DataServiceImpl()
        ServiceProviderInstances.locServiceInstance = LocationServiceImpl()
        ServiceProviderInstances.netServiceInstance = NetworkServiceStub()
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

struct ServiceHandlerSpy: AppHandler { }

// ServiceHandlerSpy+AppLaunchHandler in test target sets spy instances
