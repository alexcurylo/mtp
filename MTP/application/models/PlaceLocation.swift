// @copyright Trollwerks Inc.

import Foundation

/// version of Location found in place results
struct PlaceLocation: Codable {

    fileprivate let countryId: Int
    fileprivate let countryName: String
    /// id
    let id: Int
    fileprivate let locationName: String
    fileprivate let regionId: Int
    fileprivate let regionName: String
}

extension PlaceLocation: CustomStringConvertible {

    var description: String {
        return "\(String(describing: countryName)) (\(String(describing: countryId)))"
    }
}

extension PlaceLocation: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PlaceLocation: \(description):
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
