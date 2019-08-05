// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

struct WHSJSON: Codable {

    fileprivate let active: String
    /// UUID of main image
    let featuredImg: String?
    let id: Int
    let lat: Double
    let location: PlaceLocation?
    let locationId: Int?
    let long: Double
    let parentId: Int?
    let rank: Int
    let title: String
    let unescoId: Int
    let visitors: Int
}

extension WHSJSON: CustomStringConvertible {

    public var description: String {
        return "\(String(describing: title)) (\(String(describing: unescoId)))"
    }
}

extension WHSJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < WHSJSON: \(description):
        active: \(active)
        featuredImg: \(String(describing: featuredImg))
        id: \(id)
        lat: \(lat)
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        long: \(long)
        parentId: \(String(describing: parentId))
        rank: \(rank)
        title: \(title)
        unescoId: \(unescoId)
        visitors: \(visitors)
        /WHSJSON >
        """
    }
}

/// Realm representation of a WHS place
@objcMembers final class WHS: Object, PlaceMappable, ServiceProvider {

    enum Parents: Int {
        case jesuitMissionsOfTheGuaranis = 275
        case primevalBeechForestsOfTheCarpathians = 1_133
        case struveGeodeticArc = 1_187
    }
    enum Children: Int {
        case tornea = 1_595 // Finland - Struve Geodetic Arc
    }
    enum Singles: Int {
        case angkor = 668
    }

    /// Link to the Mappable object for this location
    dynamic var map: Mappable?
    dynamic var parentId: Int = 0
    dynamic var placeId: Int = 0
    dynamic var unescoId: Int = 0

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "placeId"
    }

    /// Constructor from MTP endpoint data
    convenience init?(from: WHSJSON,
                      // swiftlint:disable:previous function_body_length
                      realm: RealmDataController) {
        guard from.active == "Y" else { return nil }
        self.init()

        let website = "https://whc.unesco.org/en/list/\(from.unescoId)"
        let image: String
        if let featured = from.featuredImg, !featured.isEmpty {
            image = featured
        } else {
            let picture = "https://whc.unesco.org/uploads/sites/gallery/original/site_%04d_0001.jpg"
            image = String(format: picture, from.id)
        }
        let locationId = from.location?.id ?? from.locationId
        let location = realm.location(id: locationId)
        let country: String
        let region: String
        let subtitle: String
        if let location = location {
            country = location.placeCountry
            region = location.placeRegion
            subtitle = location.description
        } else if let notLocation = realm.country(id: locationId) {
            log.error("placed in country: WHS \(placeId)")
            country = notLocation.placeCountry
            region = L.unknown()
            subtitle = country
        } else {
            log.error("missing location: WHS \(placeId)")
            country = L.unknown()
            region = L.unknown()
            subtitle = ""
        }
        map = Mappable(checklist: .whss,
                       checklistId: from.id,
                       country: country,
                       image: image,
                       latitude: from.lat,
                       location: location,
                       longitude: from.long,
                       region: region,
                       subtitle: subtitle,
                       title: from.title,
                       visitors: from.visitors,
                       website: website)
        parentId = from.parentId ?? 0
        placeId = from.id
        unescoId = from.unescoId
    }

    override var description: String {
        return placeTitle
    }
}

extension WHS: PlaceInfo {

    var placeParent: PlaceInfo? {
        return parent
    }
}

extension WHS {

    var hasParent: Bool {
        return parentId != 0
    }

    var parent: WHS? {
        if hasParent {
            return data.get(whs: parentId)
        }
        return nil
    }

    var visited: Bool {
        return Checklist.whss.isVisited(id: placeId)
    }
}
