// @copyright Trollwerks Inc.

import Foundation

struct Beach: Codable {
    let active: String
    let countVisitors: Int? // not in staging
    let country: String
    let id: Int
    let img: String
    let lat: UncertainValue<Double, String> // Double in staging, String in production
    let location: PlaceLocation
    let locationId: UncertainValue<Int, String> // Int in staging, String in production
    let long: UncertainValue<Double, String> // Double in staging, String in production
    let notes: String
    let rank: Int
    let title: String
    let url: String
    let visitors: Int
}

extension Beach: CustomStringConvertible {

    public var description: String {
        return title
    }
}

extension Beach: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Beach: \(description):
        active: \(String(describing: active))
        count_visitors: \(String(describing: countVisitors))
        country: \(country)
        id: \(id)
        lat: \(String(describing: lat))
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        long: \(String(describing: long))
        notes: \(notes)
        rank: \(rank)
        title: \(title)
        url: \(url)
        visitors: \(visitors)
        /Beach >
        """
    }
}

extension Beach {

    static var count: Int {
        return gestalt.beaches.count
    }
}
