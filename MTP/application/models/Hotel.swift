// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

/// Hotel API result
struct HotelJSON: Codable {

    fileprivate let active: String
    fileprivate let brand: String
    fileprivate let address: String
    fileprivate let featuredImg: String
    fileprivate let id: Int
    fileprivate let lat: Double
    fileprivate let locationId: Int? // asked to default this to 0 not null
    fileprivate let long: Double
    fileprivate let phone: String
    fileprivate let rank: Int
    fileprivate let title: String
    fileprivate let url: String
    fileprivate let visitors: Int
    // "created_at": null
    // "updated_at": "2019-10-02 11:45:06"
}

extension HotelJSON: CustomStringConvertible {

    var description: String {
        return title
    }
}

extension HotelJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < HotelJSON: \(description):
        active: \(active)
        brand: \(brand)
        address: \(String(describing: address))
        featuredImg: \(String(describing: featuredImg))
        id: \(id)
        lat: \(lat)
        locationId: \(String(describing: locationId))
        long: \(long)
        phone: \(phone)
        rank: \(rank)
        title: \(title)
        url: \(url)
        visitors: \(visitors)
        /HotelJSON >
        """
    }
}

/// Realm representation of a hotel place
@objcMembers final class Hotel: Object, PlaceInfo, PlaceMappable, ServiceProvider {

    /// Link to the Mappable object for this location
    dynamic var map: Mappable?

    /// Address
    dynamic var address: String = ""
    /// Brand
    dynamic var brand: String = ""
    /// placeId
    dynamic var placeId: Int = 0
    /// Phone
    dynamic var phone: String = ""
    /// Difficulty rank
    dynamic var rank: Int = 0

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "placeId"
    }

    /// Constructor from MTP endpoint data
    convenience init?(from: HotelJSON,
                      realm: RealmDataController) {
        guard from.active == "Y" else { return nil }
        self.init()

        if from.locationId == nil {
            log.warning("Hotel \(from.id) missing location: \(from)")
        }
        map = Mappable(checklist: .hotels,
                       checklistId: from.id,
                       image: from.featuredImg,
                       latitude: from.lat,
                       locationId: from.locationId ?? 0,
                       longitude: from.long,
                       title: from.title,
                       visitors: from.visitors,
                       website: from.url,
                       realm: realm)
        address = from.address
        brand = from.brand
        placeId = from.id
        phone = from.phone
        rank = from.rank
    }

    override var description: String {
        return placeTitle
    }

    var brandName: String {
        switch brand {
        case "aman":
            return L.brandAman()
        case "four_seasons_hotel":
            return L.brandFourSeasons()
        case "jumeriah":
            return L.brandJumeriah()
        case "leading_hotels":
            return L.brandLeadingHotels()
        case "mandarin_oriental":
            return L.brandMandarin()
        case "oberoi":
            return L.brandOberoi()
        case "one_only":
            return L.brandOneOnly()
        case "ritz_carlton":
            return L.brandRitzCarlton()
        case "six_senses":
            return L.brandSixSenses()
        case "small_luxury_hotels":
            return L.brandSmallLuxury()
        case "st_regis":
            return L.brandStRegis()
        case "taj":
            return L.brandTaj()
        case "the_peninsula":
            return L.brandPeninsula()
        case "waldorf_astoria":
            return L.brandWaldorfAstoria()
        default:
            log.error("need brand name: \(brand)")
            return L.unknown()
        }
    }
}
