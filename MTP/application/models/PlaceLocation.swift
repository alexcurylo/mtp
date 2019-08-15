// @copyright Trollwerks Inc.

import Foundation

/// version of Location found in place results
struct PlaceLocation: Codable {

    /// countryId
    let countryId: Int
    /// countryName
    let countryName: String
    /// id
    let id: Int
    /// locationName
    let locationName: String
    /// regionId
    let regionId: Int
    /// regionName
    let regionName: String
}

extension PlaceLocation: CustomStringConvertible {

    var description: String {
        return "\(String(describing: countryName)) (\(String(describing: countryId)))"
    }
}

extension PlaceLocation: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PlaceLocation: \(description)
        countryId: \(String(describing: countryId))
        countryName: \(String(describing: countryName))
        id: \(id)
        location_name: \(locationName)
        region_id: \(String(describing: regionId))
        region_name: \(String(describing: regionName))
        /PlaceLocation >
        """
    }
}
