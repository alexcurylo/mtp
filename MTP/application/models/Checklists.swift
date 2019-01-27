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

    func set(id: Int,
             visited: Bool) {
        guard visits.contains(id) != visited else { return }

        gestalt.checklists?.set(list: self,
                                id: id,
                                visited: visited)
    }
}

struct Checklists: Codable {
    var beaches: [Int]
    var divesites: [Int]
    var golfcourses: [Int]
    var locations: [Int]
    var restaurants: [Int]
    var uncountries: [Int]
    var whss: [Int]

    mutating func set(list: Checklist,
                      id: Int,
                      visited: Bool) {
        switch list {
        case .locations:
            set(visits: &locations, id: id, visited: visited)
        case .uncountries:
            set(visits: &uncountries, id: id, visited: visited)
        case .whss:
            set(visits: &whss, id: id, visited: visited)
        case .beaches:
            set(visits: &beaches, id: id, visited: visited)
        case .golfcourses:
            set(visits: &golfcourses, id: id, visited: visited)
        case .divesites:
            set(visits: &divesites, id: id, visited: visited)
        case .restaurants:
            set(visits: &restaurants, id: id, visited: visited)
        }
        MTPAPI.check(list: list, id: id, visited: visited)
    }

    func set(visits: inout [Int],
             id: Int,
             visited: Bool) {
        guard visits.contains(id) != visited else { return }
        if visited {
            visits.append(id)
        } else if let index = visits.index(of: id) {
            visits.remove(at: index)
        }
    }
}

extension Checklists: CustomStringConvertible {

    public var description: String {
        return """
        \(beaches.count) beaches \
        \(divesites.count) divesites \
        \(golfcourses.count) golfcourses \
        \(locations.count) locations \
        \(restaurants.count) restaurants \
        \(uncountries.count) uncountries \
        \(whss.count) whss
        """
    }
}

extension Checklists: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Checklists::
        beaches: \(beaches.debugDescription)
        divesites: \(divesites.debugDescription)
        golfcourses: \(golfcourses.debugDescription)
        locations: \(locations.debugDescription)
        restaurants: \(restaurants.debugDescription)
        uncountries: \(uncountries.debugDescription)
        whss: \(whss.debugDescription)
        /Checklists >
        """
    }
}

extension Hashable where Self: CaseIterable {

    var index: Self.AllCases.Index {
        // swiftlint:disable:next force_unwrapping
        return type(of: self).allCases.firstIndex(of: self)!
    }
}
