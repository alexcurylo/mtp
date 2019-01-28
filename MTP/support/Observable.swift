// @copyright Trollwerks Inc.

import Foundation

typealias NotificationHandler = () -> Void

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

    deinit {
        unsubscribe()
    }

    func subscribe() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveNotification(_:)),
                                               name: notification,
                                               object: nil)
    }

    func unsubscribe() {
        NotificationCenter.default.removeObserver(self,
                                                  name: notification,
                                                  object: nil)
    }

    @objc func receiveNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let status = userInfo[key] as? String,
           value == status {
            notify()
        }
    }
}

enum StatusKey: String {
    case change
}

protocol Observable {

    var statusKey: StatusKey { get }
    var notification: Notification.Name { get }

    func notifyObservers(about changeTo: String)
}

extension Observable {

    func notifyObservers(about changeTo: String) {
        NotificationCenter.default.post(name: notification,
                                        object: self,
                                        userInfo: [statusKey.rawValue: changeTo])
    }
}
