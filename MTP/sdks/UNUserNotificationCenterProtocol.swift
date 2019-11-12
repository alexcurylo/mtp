// @copyright Trollwerks Inc.

import UserNotifications

/// Abstract UNUserNotificationCenter for testing
protocol UNUserNotificationCenterProtocol: AnyObject {

    /// Add notification request without completion handler
    /// - Parameter request: UNNotificationRequest
    func add(_ request: UNNotificationRequest)
    /// Add notification request
    /// - Parameters:
    ///   - request: UNNotificationRequest
    ///   - completionHandler: Completion
    func add(_ request: UNNotificationRequest,
             withCompletionHandler completionHandler: ((Error?) -> Void)?)
    /// Request notification status
    /// - Parameter completionHandler: Completion
    func getNotificationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void)
    /// Request user authorization
    /// - Parameters:
    ///   - options: UNAuthorizationOptions
    ///   - completionHandler: Completion
    func requestAuthorization(options: UNAuthorizationOptions,
                              completionHandler: @escaping (Bool, Error?) -> Void)
}

extension UNUserNotificationCenterProtocol {

    /// Add request without completion handler
    /// - Parameter request: UNNotificationRequest
    func add(_ request: UNNotificationRequest) {
        add(request, withCompletionHandler: nil)
    }
}

extension UNUserNotificationCenter: UNUserNotificationCenterProtocol {

    /// Request notification status
    /// - Parameter completionHandler: Completion
    func getNotificationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        getNotificationSettings { completionHandler($0.authorizationStatus) }
    }
}

#if DEBUG

/// Stub for testing
final class UNUserNotificationCenterStub: UNUserNotificationCenterProtocol {

    /// :nodoc:
    func add(_ request: UNNotificationRequest,
             withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        completionHandler?(nil)
    }

    /// :nodoc:
    func getNotificationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        completionHandler(.authorized)
    }

    /// :nodoc:
    func requestAuthorization(options: UNAuthorizationOptions,
                              completionHandler: @escaping (Bool, Error?) -> Void) {
        completionHandler(true, nil)
    }
}

#endif
