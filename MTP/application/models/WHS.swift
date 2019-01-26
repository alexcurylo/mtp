// @copyright Trollwerks Inc.

import CoreLocation

struct WHS: Codable {
    let active: String? // not in staging
    let countVisitors: Int? // not in staging
    let id: Int
    let lat: UncertainValue<Double, String> // Double in staging, String in production
    let location: PlaceLocation
    let locationId: UncertainValue<Int, String> // Int in staging, String in production
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
        active: \(String(describing: active))
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
        return gestalt.whss.count
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat.doubleValue ?? 0,
            longitude: long.doubleValue ?? 0
        )
    }

    var subtitle: String { return "" }
}
