// @copyright Trollwerks Inc.

import UIKit

struct ChecklistFlags: Codable, Equatable {

    var beaches: Bool = true
    var divesites: Bool = true
    var golfcourses: Bool = true
    var locations: Bool = true
    var restaurants: Bool = true
    var uncountries: Bool = true
    var whss: Bool = true
}

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

    func isVisited(id: Int) -> Bool {
        return visits.contains(id)
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

    func set(id: Int,
             visited: Bool) {
        guard isVisited(id: id) != visited else { return }

        data.checklists?.set(list: self,
                             id: id,
                             visited: visited)
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
            total = data.locations.count
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
        let complete = visited(of: user)
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

    func visited(of user: UserInfo) -> Int {
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

    var visits: [Int] {
        guard let checklists = data.checklists else { return [] }

        switch self {
        case .locations:
            return checklists.locations
        case .uncountries:
            return checklists.uncountries
        case .whss:
            return checklists.whss
        case .beaches:
            return checklists.beaches
        case .golfcourses:
            return checklists.golfcourses
        case .divesites:
            return checklists.divesites
        case .restaurants:
            return checklists.restaurants
        }
    }
}

enum Hierarchy {
    case country
    case parent
    case region
    case regionSubgrouped // region/country if 1 else region/country/locations
    case regionSubtitled

    var isGrouped: Bool {
        return self == .country
    }

    var isShowingChildren: Bool {
        return self == .parent
    }

    var isSubgrouped: Bool {
        return self == .regionSubgrouped
    }

    var isSubtitled: Bool {
        return self == .regionSubtitled
    }

    var isShowingCountries: Bool {
        switch self {
        case .country,
             .parent,
             .regionSubgrouped:
            return true
        case .region,
             .regionSubtitled:
            return false
        }
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

    var isGrouped: Bool {
        return hierarchy.isGrouped
    }

    var isShowingChildren: Bool {
        return hierarchy.isShowingChildren
    }

    var isSubgrouped: Bool {
        return hierarchy.isSubgrouped
    }

    var isSubtitled: Bool {
        return hierarchy.isSubtitled
    }

    var isShowingCountries: Bool {
        return hierarchy.isShowingCountries
    }
}
