// @copyright Trollwerks Inc.

import Foundation

/// Callback to observe changes
typealias NotificationHandler = ([AnyHashable: Any]) -> Void

/// Simple implementation of Observer pattern
@objc protocol Observer {

    /// name of our notiication
    var notification: Notification.Name { get }
    /// type of change
    var key: String { get }
    /// associated value
    var value: String { get }

    /// Begin observing
    func subscribe()
    /// Stop observing
    func unsubscribe()
}

/// Notification Center based Observer
class ObserverImpl: Observer {

    /// name of our notiication
    let notification: Notification.Name
    /// type of change
    let key: String
    /// associated value
    let value: String

    private let notify: NotificationHandler

    /// Create an Observer
    ///
    /// - Parameters:
    ///   - notification: name of our notiication
    ///   - key: type of change
    ///   - value: associated value
    ///   - notify: observing callback
    init(notification: Notification.Name,
         key: StatusKey,
         value: String,
         notify: @escaping NotificationHandler) {

        self.notification = notification
        self.key = key.rawValue
        self.value = value
        self.notify = notify

        subscribe()
    }

    /// Remove observers
    deinit {
        unsubscribe()
    }

    /// Begin observing
    func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receive(notification:)),
            name: notification,
            object: nil
        )
    }

    /// Stop observing
    func unsubscribe() {
        NotificationCenter.default.removeObserver(
            self,
            name: notification,
            object: nil
        )
    }

    /// Shim Notification to callback
    ///
    /// - Parameter notification: Notification Center note
    @objc func receive(notification: Notification) {
        if let userInfo = notification.userInfo,
           let status = userInfo[key] as? String,
           value == status {
            notify(userInfo)
        }
    }
}

/// Information types sent with notificaton
///
/// - change: type of change
/// - value: associated value
enum StatusKey: String {
    case change
    case value
}

/// Adopt tp publish changes
protocol Observable {

    
    /// Type of change generated
    var statusKey: StatusKey { get }
    /// Name of change
    var notification: Notification.Name { get }

    /// Trigger observing action
    ///
    /// - Parameters:
    ///   - changed: What changed
    ///   - info: Attached info
    func notify(observers changed: String,
                info: [AnyHashable: Any])
}

extension Observable {

    /// Trigger observing action
    ///
    /// - Parameters:
    ///   - changed: What changed
    ///   - info: Attached info
    func notify(observers changed: String,
                info: [AnyHashable: Any] = [:]) {
        var userInfo = info
        userInfo[statusKey.rawValue] = changed
        NotificationCenter.default.post(
            name: notification,
            object: self,
            userInfo: userInfo)
    }
}
