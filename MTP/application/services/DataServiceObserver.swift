// @copyright Trollwerks Inc.

import Foundation

/// Changes that can be listened for
enum DataServiceChange: String {

    /// beaches
    case beaches
    /// brands
    case brands
    /// blockedPhotos
    case blockedPhotos
    /// blockedPosts
    case blockedPosts
    /// blockedPosts
    case blockedUsers
    /// dismissed
    case dismissed
    /// divesites
    case divesites
    /// golfcourses
    case golfcourses
    /// hotels
    case hotels
    /// locationPhotos
    case locationPhotos
    /// locationPosts
    case locationPosts
    /// locations
    case locations
    /// milestones
    case milestones
    /// notified
    case notified
    /// photoPages
    case photoPages
    /// posts
    case posts
    /// rankings
    case rankings
    /// restaurants
    case restaurants
    /// scorecard
    case scorecard
    /// triggered
    case triggered
    /// uncountries
    case uncountries
    /// updated
    case updated
    /// user
    case user
    /// userId
    case userId
    /// visited
    case visited
    /// whss
    case whss
}

private class DataServiceObserver: ObserverImpl {

    static let notification = Notification.Name("DataServiceChange")
    static let statusKey = StatusKey.change

    init(of change: DataServiceChange,
         notify: @escaping NotificationHandler) {
        // swiftlint:disable:next empty_line_after_super
        super.init(notification: DataServiceObserver.notification,
                   key: DataServiceObserver.statusKey,
                   value: change.rawValue,
                   notify: notify)
    }
}

extension DataService {

    /// Type of change generated
    var statusKey: StatusKey {
        DataServiceObserver.statusKey
    }

    /// Name of change
    var notification: Notification.Name {
        DataServiceObserver.notification
    }

    /// Notify change listeners
    /// - Parameters:
    ///   - change: DataServiceChange
    ///   - object: Attachment if any
    func notify(change: DataServiceChange,
                object: Any? = nil) {
        var info: [AnyHashable: Any] = [:]
        if let object = object {
            info[StatusKey.value.rawValue] = object
        }
        notify(observers: change.rawValue, info: info)
    }

    /// Create data change observer
    /// - Parameters:
    ///   - of: DataServiceChange
    ///   - handler: Handler
    /// - Returns: Observer
    func observer(of change: DataServiceChange,
                  handler: @escaping NotificationHandler) -> Observer {
        DataServiceObserver(of: change, notify: handler)
    }
}

extension Checklist {

    /// Create data change observer
    /// - Parameter handler: Handler
    /// - Returns: Observer
    func observer(handler: @escaping NotificationHandler) -> Observer {
        DataServiceObserver(of: change, notify: handler)
    }

    private var change: DataServiceChange {
        switch self {
        case .beaches:
            return .beaches
        case .divesites:
            return .divesites
        case .golfcourses:
            return .golfcourses
        case .hotels:
            return .hotels
        case .locations:
            return .locations
        case .restaurants:
            return .restaurants
        case .uncountries:
            return .uncountries
        case .whss:
            return .whss
        }
    }
}
