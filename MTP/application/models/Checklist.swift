// @copyright Trollwerks Inc.

import UIKit

enum Checklist: String, CaseIterable {

    case locations
    case uncountries
    case whss
    case beaches
    case golfcourses
    case divesites
    case restaurants

    var path: String {
        return "me/checklists/" + rawValue
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

    var visits: [Int] {
        // swiftlint:disable:next discouraged_optional_collection
        let visits: [Int]?
        switch self {
        case .locations:
            visits = gestalt.checklists?.locations
        case .uncountries:
            visits = gestalt.checklists?.uncountries
        case .whss:
            visits = gestalt.checklists?.whss
        case .beaches:
            visits = gestalt.checklists?.beaches
        case .golfcourses:
            visits = gestalt.checklists?.golfcourses
        case .divesites:
            visits = gestalt.checklists?.divesites
        case .restaurants:
            visits = gestalt.checklists?.restaurants
        }
        return visits ?? []
    }

    var places: [PlaceInfo] {
        let places: [PlaceInfo]
        switch self {
        case .locations:
            places = gestalt.locations
        case .uncountries:
            places = gestalt.uncountries
        case .whss:
            places = gestalt.whss
        case .beaches:
            places = gestalt.beaches
        case .golfcourses:
            places = gestalt.golfcourses
        case .divesites:
            places = gestalt.divesites
        case .restaurants:
            places = gestalt.restaurants
        }
        return places
    }

    func isVisited(id: Int) -> Bool {
        return visits.contains(id)
    }

    func set(id: Int,
             visited: Bool) {
        guard isVisited(id: id) != visited else { return }

        gestalt.checklists?.set(list: self,
                                id: id,
                                visited: visited)
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

    var isGrouped: Bool {
        return hierarchy.isGrouped
    }

    var isSubgrouped: Bool {
        return hierarchy.isSubgrouped
    }

    var isSubtitled: Bool {
        return hierarchy.isSubtitled
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
