// @copyright Trollwerks Inc.

import UIKit

protocol ServiceProvider {

    var app: ApplicationService { get }
    var log: LoggingService { get }

    var networkService: NetworkService { get }
    var dataService: DataService { get }
    var userService: UserService { get }
}

extension ServiceProvider {

    var app: ApplicationService {
        return ServiceProviderInstances.appServiceInstance
    }
    var log: LoggingService {
        return ServiceProviderInstances.logServiceInstance
    }

    var networkService: NetworkService {
        return ServiceProviderInstances.networkServiceInstance
    }
    var dataService: DataService {
        return ServiceProviderInstances.dataServiceInstance
    }
    var userService: UserService {
        return ServiceProviderInstances.userServiceInstance
    }
}
protocol NetworkService { }
struct NetworkServiceImpl: NetworkService { }
protocol DataService { }
struct DataServiceImpl: DataService { }
protocol UserService { }
struct UserServiceImpl: UserService { }

private enum ServiceProviderInstances {
    static let appServiceInstance = UIApplication.shared
    static let logServiceInstance = SwiftyBeaverLoggingService()

    static let networkServiceInstance = NetworkServiceImpl()
    static let dataServiceInstance = DataServiceImpl()
    static let userServiceInstance = UserServiceImpl()
}

protocol ApplicationService {

    func open(_ url: URL)
}

extension UIApplication: ApplicationService {

    func open(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}
