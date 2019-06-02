// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

// swiftlint:disable file_length

struct ChecklistFlags: Codable, Equatable {

    var beaches: Bool = true
    var divesites: Bool = true
    var golfcourses: Bool = true
    var locations: Bool = true
    var restaurants: Bool = true
    var uncountries: Bool = true
    var whss: Bool = true
}

// swiftlint:disable:next type_body_length
enum Checklist: String, Codable, CaseIterable, ServiceProvider {

    case locations
    case uncountries
    case whss
    case beaches
    case golfcourses
    case divesites
    case restaurants

    typealias Status = (visited: Int, remaining: Int)

    var background: UIColor {
        let background: UIColor?
        switch self {
        case .locations:
            background = R.color.locations()
        case .uncountries:
            background = R.color.uncountries()
        case .whss:
            background = R.color.whss()
        case .beaches:
            background = R.color.beaches()
        case .golfcourses:
            background = R.color.golfcourses()
        case .divesites:
            background = R.color.divesites()
        case .restaurants:
            background = R.color.restaurants()
        }
        // swiftlint:disable:next force_unwrapping
        return background!
    }

    var dismissed: [Int] {
        guard let dismissed = data.dismissed else { return [] }

        switch self {
        case .locations:
            return dismissed.locations
        case .uncountries:
            return dismissed.uncountries
        case .whss:
            return dismissed.whss
        case .beaches:
            return dismissed.beaches
        case .golfcourses:
            return dismissed.golfcourses
        case .divesites:
            return dismissed.divesites
        case .restaurants:
            return dismissed.restaurants
        }
    }

    var image: UIImage {
        let image: UIImage?
        switch self {
        case .locations:
            image = R.image.listMTP()
        case .uncountries:
            image = R.image.listUN()
        case .whss:
            image = R.image.listWHS()
        case .beaches:
            image = R.image.listBeaches()
        case .golfcourses:
            image = R.image.listGolf()
        case .divesites:
            image = R.image.listDive()
        case .restaurants:
            image = R.image.listRestaurants()
        }
        // swiftlint:disable:next force_unwrapping
        return image!
    }

    func hasChildren(id: Int) -> Bool {
        switch self {
        case .whss:
            return data.hasChildren(whs: id)
        default:
            return false
        }
    }

    func hasVisitedChildren(id: Int) -> Bool {
        switch self {
        case .whss:
            return data.hasVisitedChildren(whs: id)
        default:
            return false
        }
    }

    func hasParent(id: Int) -> Bool {
        switch self {
        case .whss:
            return data.get(whs: id)?.hasParent ?? false
        default:
            return false
        }
    }

    func isDismissed(id: Int) -> Bool {
        return dismissed.contains(id)
    }

    func isTriggered(id: Int) -> Bool {
        return triggered.contains(id)
    }

    func isVisited(id: Int) -> Bool {
        return visited.contains(id)
    }

    func place(id: Int) -> PlaceInfo? {
        return places.first { $0.placeId == id }
    }

    var places: [PlaceInfo] {
        let places: [PlaceInfo]
        switch self {
        case .locations:
            places = data.locations
        case .uncountries:
            places = data.uncountries
        case .whss:
            places = data.whss
        case .beaches:
            places = data.beaches
        case .golfcourses:
            places = data.golfcourses
        case .divesites:
            places = data.divesites
        case .restaurants:
            places = data.restaurants
        }
        return places
    }

    func set(dismissed: Bool,
             id: Int) {
        guard isDismissed(id: id) != dismissed else { return }

        if data.dismissed == nil {
            data.dismissed = Checked()
        }
        data.dismissed?.set(list: self,
                            id: id,
                            dismissed: dismissed)
        set(triggered: false, id: id)
    }

    func set(triggered: Bool,
             id: Int) {
        guard isTriggered(id: id) != triggered else { return }

        if data.triggered == nil {
            data.triggered = Checked()
        }
        data.triggered?.set(list: self,
                            id: id,
                            triggered: triggered)
    }

    func set(visited: Bool,
             id: Int) {
        guard self != .uncountries,
              isVisited(id: id) != visited else { return }

        data.visited?.set(list: self,
                          id: id,
                          visited: visited)
        set(dismissed: false, id: id)
        set(triggered: false, id: id)
    }

    func rank(of user: UserJSON? = nil) -> Int {
        guard let user = user ?? data.user else { return 0 }

        switch self {
        case .locations:
            return user.rankLocations ?? 0
        case .uncountries:
            return user.rankUncountries ?? 0
        case .whss:
            return user.rankWhss ?? 0
        case .beaches:
            return user.rankBeaches ?? 0
        case .golfcourses:
            return user.rankGolfcourses ?? 0
        case .divesites:
            return user.rankDivesites ?? 0
        case .restaurants:
            return user.rankRestaurants ?? 0
        }
    }

    func remaining(of user: UserInfo) -> Int {
        return status(of: user).remaining
    }

    func status(of user: UserInfo) -> Status {
        let total: Int
        switch self {
        case .locations:
            total = data.locations.filter { $0.id > 0 }.count
        case .uncountries:
            total = data.uncountries.count
        case .whss:
            total = data.whss.filter { !$0.hasParent }.count
        case .beaches:
            total = data.beaches.count
        case .golfcourses:
            total = data.golfcourses.count
        case .divesites:
            total = data.divesites.count
        case .restaurants:
            total = data.restaurants.count
        }
        let complete = visits(of: user)
        return (complete, total - complete)
    }

    var title: String {
        switch self {
        case .locations:
            return Localized.locations()
        case .uncountries:
            return Localized.uncountries()
        case .whss:
            return Localized.whss()
        case .beaches:
            return Localized.beaches()
        case .golfcourses:
            return Localized.golfcourses()
        case .divesites:
            return Localized.divesites()
        case .restaurants:
            return Localized.restaurants()
        }
    }

    var category: String {
        switch self {
        case .locations:
            return Localized.location()
        case .uncountries:
            return Localized.uncountry()
        case .whss:
            return Localized.whs()
        case .beaches:
            return Localized.beach()
        case .golfcourses:
            return Localized.golfcourse()
        case .divesites:
            return Localized.divesite()
        case .restaurants:
            return Localized.restaurant()
        }
    }

    func visits(of user: UserInfo) -> Int {
        switch self {
        case .locations:
            return user.visitLocations
        case .uncountries:
            return user.visitUncountries
        case .whss:
            return user.visitWhss
        case .beaches:
            return user.visitBeaches
        case .golfcourses:
            return user.visitGolfcourses
        case .divesites:
            return user.visitDivesites
        case .restaurants:
            return user.visitRestaurants
        }
    }

    func order(of user: UserInfo) -> Int {
        switch self {
        case .locations:
            return user.orderLocations
        case .uncountries:
            return user.orderUncountries
        case .whss:
            return user.orderWhss
        case .beaches:
            return user.orderBeaches
        case .golfcourses:
            return user.orderGolfcourses
        case .divesites:
            return user.orderDivesites
        case .restaurants:
            return user.orderRestaurants
        }
    }

    var visited: [Int] {
        guard let visited = data.visited else { return [] }

        switch self {
        case .locations:
            return visited.locations
        case .uncountries:
            return visited.uncountries
        case .whss:
            return visited.whss
        case .beaches:
            return visited.beaches
        case .golfcourses:
            return visited.golfcourses
        case .divesites:
            return visited.divesites
        case .restaurants:
            return visited.restaurants
        }
    }

    var triggerDistance: CLLocationDistance {
        switch self {
        case .locations:
            return 1_600
        case .uncountries:
            return 0
        case .whss:
            return 1_600
        case .beaches:
            return 1_600
        case .golfcourses:
            return 1_600
        case .divesites:
            return 1_600
        case .restaurants:
            return 20
        }
    }

    var triggered: [Int] {
        guard let triggered = data.triggered else { return [] }

        switch self {
        case .locations:
            return triggered.locations
        case .uncountries:
            return triggered.uncountries
        case .whss:
            return triggered.whss
        case .beaches:
            return triggered.beaches
        case .golfcourses:
            return triggered.golfcourses
        case .divesites:
            return triggered.divesites
        case .restaurants:
            return triggered.restaurants
        }
    }
}

enum Hierarchy {
    case parent
    case region
    case regionSubgrouped // region/country if 1 else region/country/locations
    case regionSubtitled

    var isSubtitled: Bool {
        return self == .regionSubtitled
    }
}

extension Checklist {

    var hierarchy: Hierarchy {
        switch self {
        case .locations:
            return .regionSubgrouped
        case .uncountries:
            return .region
        case .whss:
            return .parent
        case .beaches:
            return .regionSubtitled
        case .golfcourses:
            return .regionSubtitled
        case .divesites:
            return .regionSubtitled
        case .restaurants:
            return .regionSubtitled // by region/country/location on website
        }
    }

    var isSubtitled: Bool {
        return hierarchy.isSubtitled
    }
}
