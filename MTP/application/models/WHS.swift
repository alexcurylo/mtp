// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

struct WHSJSON: Codable {

    let active: String
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

    dynamic var map: Mappable?
    dynamic var parentId: Int = 0
    dynamic var placeId: Int = 0
    dynamic var unescoId: Int = 0

    override static func primaryKey() -> String? {
        return "placeId"
    }

    convenience init?(from: WHSJSON,
                      realm: RealmController) {
        guard from.active == "Y" else { return nil }
        self.init()

        let website = "https://whc.unesco.org/en/list/\(from.unescoId)"
        let picture = "https://whc.unesco.org/uploads/sites/gallery/original/site_%04d_0001.jpg"
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
                       image: String(format: picture, from.id),
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

    var placeIsMappable: Bool {
        switch placeId {
        case Parents.jesuitMissionsOfTheGuaranis.rawValue,
             Parents.primevalBeechForestsOfTheCarpathians.rawValue,
             Parents.struveGeodeticArc.rawValue:
            return false
        default:
            return true
        }
    }

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
