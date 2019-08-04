// @copyright Trollwerks Inc.

import Foundation

typealias NotificationHandler = ([AnyHashable: Any]) -> Void

@objc protocol Observer {

    var notification: Notification.Name { get }
    var key: String { get }
    var value: String { get }

    func subscribe()
    func unsubscribe()
}

class ObserverImpl: Observer {

    let notification: Notification.Name
    let key: String
    let value: String
    let notify: NotificationHandler

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

    func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receive(notification:)),
            name: notification,
            object: nil
        )
    }

    func unsubscribe() {
        NotificationCenter.default.removeObserver(
            self,
            name: notification,
            object: nil
        )
    }

    @objc func receive(notification: Notification) {
        if let userInfo = notification.userInfo,
           let status = userInfo[key] as? String,
           value == status {
            notify(userInfo)
        }
    }
}

enum StatusKey: String {
    case change
    case value
}

protocol Observable {

    var statusKey: StatusKey { get }
    var notification: Notification.Name { get }

    func notify(observers changed: String,
                info: [AnyHashable: Any])
}

extension Observable {

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
