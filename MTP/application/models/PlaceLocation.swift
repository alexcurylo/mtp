// @copyright Trollwerks Inc.

import Foundation

/// version of Location found in place and user results
struct PlaceLocation: Codable, Equatable {

    /// countryId
    let countryId: Int?
    /// countryName
    let countryName: String?
    /// id
    let id: Int
    /// locationName
    let locationName: String?
    /// regionId
    let regionId: Int?
    /// regionName
    let regionName: String?
}

extension PlaceLocation: CustomStringConvertible {

    var description: String {
        let country = countryName ?? ""
        let location = locationName ?? ""
        if !country.isEmpty
           && !location.isEmpty
           && country != location {
            return L.locationDescription(location, country)
        }
        if !location.isEmpty { return location }
        if !country.isEmpty { return country }
        return L.unknown()
    }
}

extension PlaceLocation: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PlaceLocation: \(description)
        countryId: \(String(describing: countryId))
        countryName: \(String(describing: countryName))
        id: \(id)
        location_name: \(String(describing: locationName))
        region_id: \(String(describing: regionId))
        region_name: \(String(describing: regionName))
        /PlaceLocation >
        """
    }
}
