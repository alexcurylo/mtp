// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

struct RestaurantJSON: Codable {

    let active: String
    let address: String?
    let country: String?
    let externalId: String
    let featuredImg: String?
    let id: Int
    let isTop100: Int
    let lat: Double
    let location: PlaceLocation?
    let locationId: Int
    let long: Double
    let rank: Int
    let rankTop100: Int?
    let restid: Int
    let stars: Int
    let title: String
    let url: String
    let visitors: Int
}

extension RestaurantJSON: CustomStringConvertible {

    public var description: String {
        return title
    }
}

extension RestaurantJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < RestaurantJSON: \(description):
        active: \(active)
        address: \(String(describing: address))
        country: \(String(describing: country))
        externalId: \(externalId)
        featuredImg: \(String(describing: featuredImg))
        id: \(id)
        isTop100: \(isTop100)
        lat: \(lat)
        location: \(String(describing: location))
        locationId: \(locationId)
        long: \(long)
        rank: \(rank)
        rankTop100: \(String(describing: rankTop100))
        restid: \(restid)
        stars: \(stars)
        title: \(title)
        url: \(url)
        visitors: \(visitors)
        /RestaurantJSON >
        """
    }
}

@objcMembers final class Restaurant: Object, PlaceInfo, PlaceMappable {

    dynamic var map: Mappable?
    dynamic var placeId: Int = 0

    override static func primaryKey() -> String? {
        return "placeId"
    }

    convenience init?(from: RestaurantJSON,
                      realm: RealmDataController) {
        guard from.active == "Y" else { return nil }
        self.init()

        map = Mappable(checklist: .restaurants,
                       checklistId: from.id,
                       image: from.featuredImg ?? "",
                       latitude: from.lat,
                       locationId: from.location?.id ?? from.locationId,
                       longitude: from.long,
                       title: from.title,
                       visitors: from.visitors,
                       website: from.url,
                       realm: realm)
        placeId = from.id
    }

    override var description: String {
        return placeTitle
    }
}
