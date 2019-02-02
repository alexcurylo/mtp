// @copyright Trollwerks Inc.

import UIKit

enum Checklist: String, CaseIterable, ServiceProvider {

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

    var hierarchy: Hierarchy {
        switch self {
        case .locations:
            return .regionSubgrouped
        case .uncountries:
            return .region
        case .whss:
            return .country
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

    var isGrouped: Bool {
        return hierarchy.isGrouped
    }

    var isSubgrouped: Bool {
        return hierarchy.isSubgrouped
    }

    var isSubtitled: Bool {
        return hierarchy.isSubtitled
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

    var path: String {
        return "me/checklists/" + rawValue
    }

    func set(id: Int,
             visited: Bool) {
        guard isVisited(id: id) != visited else { return }

        data.checklists?.set(list: self,
                             id: id,
                             visited: visited)
    }

    func rank(of user: User? = nil) -> Int {
        guard let user = user ?? data.user else { return 0 }

        switch self {
        case .locations:
            return user.rankLocations
        case .uncountries:
            return user.rankUncountries
        case .whss:
            return user.rankWhss
        case .beaches:
            return user.rankBeaches
        case .golfcourses:
            return user.rankGolfcourses
        case .divesites:
            return user.rankDivesites
        case .restaurants:
            return user.rankRestaurants
        }
    }

    func remaining(of user: User? = nil) -> Int {
        return status(of: user).remaining
    }

    func status(of user: User? = nil) -> Status {
        let total: Int
        switch self {
        case .locations:
            total = data.locations.count
        case .uncountries:
            total = data.uncountries.count
        case .whss:
            total = data.whss.count
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

    func visited(of user: User? = nil) -> Int {
        guard let user = user ?? data.user else { return 0 }

        switch self {
        case .locations:
            return user.scoreLocations
        case .uncountries:
            return user.scoreUncountries
        case .whss:
            return user.scoreWhss
        case .beaches:
            return user.scoreBeaches
        case .golfcourses:
            return user.scoreGolfcourses
        case .divesites:
            return user.scoreDivesites
        case .restaurants:
            return user.scoreRestaurants
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
    case region
    case regionSubgrouped // region/country if 1 else region/country/locations
    case regionSubtitled

    var isGrouped: Bool {
        return self == .country
    }

    var isSubgrouped: Bool {
        return self == .regionSubgrouped
    }

    var isSubtitled: Bool {
        return self == .regionSubtitled
    }
}
