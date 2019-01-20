// @copyright Trollwerks Inc.

import Foundation

// version of Location found in WHS on staging

struct WHSLocation: Codable {
    let countryId: Int
    let countryName: String
    let id: Int
    let locationName: String
    let regionId: Int
    let regionName: String
}

extension WHSLocation: CustomStringConvertible {

    public var description: String {
        return "\(String(describing: countryName)) (\(String(describing: countryId)))"
    }
}

extension WHSLocation: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < WHSLocation: \(description):
        countryId: \(String(describing: countryId))
        countryName: \(String(describing: countryName))
        id: \(id)
        location_name: \(locationName)
        region_id: \(String(describing: regionId))
        region_name: \(String(describing: regionName))
        /Location >
        """
    }
}
