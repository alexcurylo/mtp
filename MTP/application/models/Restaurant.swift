// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

struct RestaurantJSON: Codable {

    let active: String
    let address: String?
    let country: String?
    let externalId: String
    let id: Int
    let img: String
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
        id: \(id)
        img: \(img)
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

@objcMembers final class Restaurant: Object {

    dynamic var countryName: String = ""
    dynamic var id: Int = 0
    dynamic var lat: Double = 0
    dynamic var long: Double = 0
    dynamic var placeImage: String = ""
    dynamic var placeLocation: Location?
    dynamic var placeVisitors: Int = 0
    dynamic var regionName: String = ""
    dynamic var title: String = ""
    dynamic var website: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: RestaurantJSON,
                      with controller: RealmController) {
        guard from.active == "Y" else {
            return nil
        }
        self.init()

        let locationId = from.location?.id ?? from.locationId
        placeLocation = controller.location(id: locationId)
        countryName = placeLocation?.countryName ?? Localized.unknown()
        id = from.id
        lat = from.lat
        long = from.long
        placeImage = from.img
        placeVisitors = from.visitors
        regionName = placeLocation?.regionName ?? Localized.unknown()
        title = from.title
        website = from.url
    }

    override var description: String {
        return title
    }
}

extension Restaurant: PlaceInfo {

    var placeCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
    }

    var placeCountry: String {
        return countryName
    }

    var placeId: Int {
        return id
    }

    var placeRegion: String {
        return regionName
    }

    var placeTitle: String {
        return title
    }

    var placeWebUrl: URL? {
        return website.mtpWebsiteUrl
    }
}
