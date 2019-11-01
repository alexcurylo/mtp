// @copyright Trollwerks Inc.

import UserNotifications

/// Abstract UNUserNotificationCenter for testing
protocol UNUserNotificationCenterProtocol: AnyObject {

    func add(_ request: UNNotificationRequest)
    func add(_ request: UNNotificationRequest,
             withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func getNotificationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void)
    func requestAuthorization(options: UNAuthorizationOptions,
                              completionHandler: @escaping (Bool, Error?) -> Void)
}

extension UNUserNotificationCenterProtocol {

    func add(_ request: UNNotificationRequest) {
        add(request, withCompletionHandler: nil)
    }
}

extension UNUserNotificationCenter: UNUserNotificationCenterProtocol {

    func getNotificationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        getNotificationSettings { completionHandler($0.authorizationStatus) }
    }
}

#if DEBUG

/// Stub for testing
final class UNUserNotificationCenterStub: UNUserNotificationCenterProtocol {

    func add(_ request: UNNotificationRequest,
             withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        completionHandler?(nil)
    }

    func getNotificationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        completionHandler(.authorized)
    }

    func requestAuthorization(options: UNAuthorizationOptions,
                              completionHandler: @escaping (Bool, Error?) -> Void) {
        completionHandler(true, nil)
    }
}

#endif
