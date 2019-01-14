// @copyright Trollwerks Inc.

import Foundation

struct WHS: Codable {
    let active: String
    let countVisitors: Int? // not in staging
    let id: Int
    let lat: UncertainValue<Double, String> // Double in staging, String in production
    let location: Location
    let locationId: String
    let long: UncertainValue<Double, String> // Double in staging, String in production
    let title: String
    let unescoId: Int
    let visitors: Int
}

extension WHS: CustomStringConvertible {

    public var description: String {
        return "\(String(describing: title)) (\(String(describing: unescoId)))"
    }
}

extension WHS: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Location: \(description):
        active: \(active)
        count_visitors: \(String(describing: countVisitors))
        id: \(id)
        lat: \(String(describing: lat))
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        long: \(String(describing: long))
        title: \(title)
        unescoId: \(unescoId)
        visitors: \(visitors)
        /Location >
        """
    }
}

extension WHS {

    static var count: Int {
        return gestalt.whs.count
    }
}
