// @copyright Trollwerks Inc.

import CoreLocation

struct Place: Codable {
    let active: String
    let countVisitors: Int? // not in staging
    let country: String
    let id: Int
    let img: String? // not in dive sites
    let lat: UncertainValue<Double, String> // Double in staging, String in production
    let location: PlaceLocation
    let locationId: UncertainValue<Int, String> // Int in staging, String in production
    let long: UncertainValue<Double, String> // Double in staging, String in production
    let notes: String? // not in dive sites
    let rank: Int
    let title: String
    let url: String
    let visitors: Int
}

extension Place: CustomStringConvertible {

    public var description: String {
        return title
    }
}

extension Place: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Place: \(description):
        active: \(String(describing: active))
        count_visitors: \(String(describing: countVisitors))
        country: \(country)
        id: \(id)
        img: \(String(describing: img))
        lat: \(String(describing: lat))
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        long: \(String(describing: long))
        notes: \(String(describing: notes))
        rank: \(rank)
        title: \(title)
        url: \(url)
        visitors: \(visitors)
        /Place >
        """
    }
}

extension Place {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat.doubleValue ?? 0,
            longitude: long.doubleValue ?? 0
        )
    }

    var subtitle: String { return "" }
}
