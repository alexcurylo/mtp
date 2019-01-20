// @copyright Trollwerks Inc.

import JWTDecode
import UIKit

var gestalt = UserDefaults.standard

protocol Gestalt: Observable {

    var checklistLocations: [Int] { get set }
    var checklistUNCountries: [Int] { get set }
    var email: String { get set }
    var lastUserRefresh: Date? { get set }
    var locations: [Location] { get set }
    var name: String { get set }
    var password: String { get set }
    var rankingsFilter: UserFilter? { get set }
    var token: String { get set }
    var user: User? { get set }
    var whs: [WHS] { get set }
}
extension Gestalt {

    mutating func logOut() {
        FacebookButton.logOut()
        email = ""
        token = ""
        name = ""
        password = ""
        user = nil
    }

    var isLoggedIn: Bool {
        guard !token.isEmpty,
              let jwt = try? decode(jwt: token),
              let expiry = jwt.expiresAt else { return false }
        // https://github.com/auth0/JWTDecode.swift/issues/70
        let expired = expiry > Date().toUTC
        if expired {
            log.debug("token expired -- should we be refreshing somehow?")
        }
        return expired
    }
}

// MARK: - Observable

enum GestaltChange: String {
    case locations
    case user
    case whs
}

extension Notification.Name {
    static let gestaltChange = Notification.Name("GestaltChange")
}

extension Gestalt {

    var statusKey: StatusKey {
        return .change
    }

    var notification: Notification.Name {
        return .gestaltChange
    }

    func newUserObserver(handler: @escaping NotificationHandler) -> Observer {
        return ObserverImpl(notification: notification,
                            key: statusKey,
                            value: GestaltChange.user.rawValue,
                            notify: handler)
    }

    func newLocationsObserver(handler: @escaping NotificationHandler) -> Observer {
        return ObserverImpl(notification: notification,
                            key: statusKey,
                            value: GestaltChange.locations.rawValue,
                            notify: handler)
    }

    func newWHSObserver(handler: @escaping NotificationHandler) -> Observer {
        return ObserverImpl(notification: notification,
                            key: statusKey,
                            value: GestaltChange.whs.rawValue,
                            notify: handler)
    }
}
