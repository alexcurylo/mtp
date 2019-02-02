// @copyright Trollwerks Inc.

import JWTDecode
import UIKit

protocol DataService: AnyObject, Observable, ServiceProvider {

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
    var rankingsPages: [String: RankingsPage] { get set }
    var restaurants: [Restaurant] { get set }
    var token: String { get set }
    var uncountries: [Location] { get set }
    var user: User? { get set }
    var whss: [WHS] { get set }
}

// MARK: - User state

extension DataService {

    func logOut() {
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

enum DataServiceChange: String {

    case checklists
    case user
    // and the contents of Checklist
}

final class DataServiceObserver: ObserverImpl {

    static let notification = Notification.Name("DataServiceChange")
    static let statusKey = StatusKey.change

    init(of value: DataServiceChange,
         notify: @escaping NotificationHandler) {
        super.init(notification: DataServiceObserver.notification,
                   key: DataServiceObserver.statusKey,
                   value: value.rawValue,
                   notify: notify)
    }

    init(of value: Checklist,
         notify: @escaping NotificationHandler) {
        super.init(notification: DataServiceObserver.notification,
                   key: DataServiceObserver.statusKey,
                   value: value.rawValue,
                   notify: notify)
    }
}

extension DataService {

    var statusKey: StatusKey {
        return DataServiceObserver.statusKey
    }

    var notification: Notification.Name {
        return DataServiceObserver.notification
    }

    func userObserver(handler: @escaping NotificationHandler) -> Observer {
        return DataServiceObserver(of: .user, notify: handler)
    }

    func checklistsObserver(handler: @escaping NotificationHandler) -> Observer {
        return DataServiceObserver(of: .checklists, notify: handler)
    }
}

extension Checklist {

    func observer(handler: @escaping NotificationHandler) -> Observer {
        return DataServiceObserver(of: self, notify: handler)
    }
}
