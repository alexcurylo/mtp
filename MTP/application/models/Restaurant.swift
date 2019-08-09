// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

/// Restaurant API result
struct RestaurantJSON: Codable {

    fileprivate let active: String
    fileprivate let address: String?
    fileprivate let country: String?
    fileprivate let externalId: String
    fileprivate let featuredImg: String?
    fileprivate let id: Int
    fileprivate let isTop100: Int
    fileprivate let lat: Double
    fileprivate let location: PlaceLocation?
    fileprivate let locationId: Int
    fileprivate let long: Double
    fileprivate let rank: Int
    fileprivate let rankTop100: Int?
    fileprivate let restid: Int
    fileprivate let stars: Int
    fileprivate let title: String
    fileprivate let url: String
    fileprivate let visitors: Int
}

extension RestaurantJSON: CustomStringConvertible {

    var description: String {
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

/// Realm representation of a restaurant place
@objcMembers final class Restaurant: Object, PlaceInfo, PlaceMappable {

    /// Link to the Mappable object for this location
    dynamic var map: Mappable?
    /// placeId
    dynamic var placeId: Int = 0

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "placeId"
    }

    /// Constructor from MTP endpoint data
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
