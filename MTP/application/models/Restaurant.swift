// @copyright Trollwerks Inc.

import CoreLocation

struct Restaurant: Codable {
    let active: String
    let address: String?
    let countVisitors: Int? // not in staging
    let country: String?
    let externalId: String
    let id: Int
    let img: String
    let isTop100: Int
    let lat: UncertainValue<Double, String> // Double in staging, String in production
    let location: PlaceLocation?
    let locationId: UncertainValue<Int, String> // Int in staging, String in production
    let long: UncertainValue<Double, String> // Double in staging, String in production
    let notes: String?
    let rank: Int
    let rankTop100: Int?
    let restid: UncertainValue<Int, String> // Int in staging, String in production
    let restyr: String?
    let stars: Int
    let title: String
    let url: String
    let visitors: Int
}

extension Restaurant: CustomStringConvertible {

    public var description: String {
        return title
    }
}

extension Restaurant: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Restaurant: \(description):
        active: \(String(describing: active))
        address: \(String(describing: address))
        count_visitors: \(String(describing: countVisitors))
        country: \(String(describing: country))
        externalId: \(externalId)isTop100
        id: \(id)
        isTop100: \(isTop100)
        img: \(String(describing: img))
        lat: \(String(describing: lat))
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        long: \(String(describing: long))
        notes: \(String(describing: notes))
        rank: \(rank)
        rankTop100: \(String(describing: rankTop100))
        restid: \(restid)
        restyr: \(String(describing: restyr))
        stars: \(stars)
        title: \(title)
        url: \(url)
        visitors: \(visitors)
        /Restaurant >
        """
    }
}

extension Restaurant {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat.doubleValue ?? 0,
            longitude: long.doubleValue ?? 0
        )
    }

    var subtitle: String { return "" }
}
