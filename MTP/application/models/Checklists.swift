// @copyright Trollwerks Inc.

import Foundation

enum Checklist: String {
    case beaches
    case divesites
    case golfcourses
    case locations
    case restaurants
    case uncountries
    case whss

    var path: String {
        return "me/checklists/" + rawValue
    }
}

struct Checklists: Codable {
    let beaches: [Int]
    let divesites: [Int]
    let golfcourses: [Int]
    let locations: [Int]
    let restaurants: [Int]
    let uncountries: [Int]
    let whss: [Int]
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
