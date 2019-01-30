// @copyright Trollwerks Inc.

import JWTDecode
import UIKit

var gestalt = UserDefaults.standard

protocol Gestalt: Observable {

    var beaches: [Place] { get set }
    var checklists: Checklists? { get set }
    var divesites: [Place] { get set }
    var email: String { get set }
    var etags: [String: String] { get set }
    var golfcourses: [Place] { get set }
    var locations: [Location] { get set }
    var name: String { get set }
    var password: String { get set }
    var rankingsFilter: UserFilter? { get set }
    var rankingsPage: RankingsPage? { get set }
    var restaurants: [Restaurant] { get set }
    var token: String { get set }
    var uncountries: [Country] { get set }
    var user: User? { get set }
    var whss: [WHS] { get set }
}

// MARK: - User state

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

    case checklists
    case user
    // and the contents of Checklist
}

extension Notification.Name {
    static let gestaltChange = Notification.Name("GestaltChange")
}

final class GestaltObserver: ObserverImpl {

    init(of value: GestaltChange,
         notify: @escaping NotificationHandler) {
        super.init(notification: gestalt.notification,
                   key: gestalt.statusKey,
                   value: value.rawValue,
                   notify: notify)
    }

    init(of value: Checklist,
         notify: @escaping NotificationHandler) {
        super.init(notification: gestalt.notification,
                   key: gestalt.statusKey,
                   value: value.rawValue,
                   notify: notify)
    }
}

extension Gestalt {

    var statusKey: StatusKey {
        return .change
    }

    var notification: Notification.Name {
        return .gestaltChange
    }

    func userObserver(handler: @escaping NotificationHandler) -> Observer {
        return GestaltObserver(of: .user, notify: handler)
    }

    func checklistsObserver(handler: @escaping NotificationHandler) -> Observer {
        return GestaltObserver(of: .checklists, notify: handler)
    }
}

extension Checklist {

    func observer(handler: @escaping NotificationHandler) -> Observer {
        return GestaltObserver(of: self, notify: handler)
    }
}
