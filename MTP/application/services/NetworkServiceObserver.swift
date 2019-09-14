// @copyright Trollwerks Inc.

import Foundation

/// Changes that can be listened for
enum NetworkServiceChange: String {

    /// connection
    case connection
    /// progress
    case progress
    /// tasks
    case tasks
}

private class NetworkServiceObserver: ObserverImpl {

    static let notification = Notification.Name("NetworkServiceChange")
    static let statusKey = StatusKey.change

    init(of change: NetworkServiceChange,
         notify: @escaping NotificationHandler) {
        super.init(notification: NetworkServiceObserver.notification,
                   key: NetworkServiceObserver.statusKey,
                   value: change.rawValue,
                   notify: notify)
    }
}

extension NetworkService {

    /// Type of change generated
    var statusKey: StatusKey {
        return NetworkServiceObserver.statusKey
    }

    /// Name of change
    var notification: Notification.Name {
        return NetworkServiceObserver.notification
    }

    /// Notify change listeners
    ///
    /// - Parameters:
    ///   - change: NetworkServiceChange
    ///   - object: Attachment if any
    func notify(change: NetworkServiceChange,
                object: Any? = nil) {
        var info: [AnyHashable: Any] = [:]
        if let object = object {
            info[StatusKey.value.rawValue] = object
        }
        notify(observers: change.rawValue, info: info)
    }

    /// Create network change observer
    ///
    /// - Parameters:
    ///   - of: NetworkServiceChange
    ///   - handler: Handler
    /// - Returns: Observer
    func observer(of change: NetworkServiceChange,
                  handler: @escaping NotificationHandler) -> Observer {
        return NetworkServiceObserver(of: change, notify: handler)
    }
}
