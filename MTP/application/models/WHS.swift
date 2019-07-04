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

@objcMembers final class WHS: Object, ServiceProvider {

    dynamic var countryName: String = ""
    dynamic var id: Int = 0
    dynamic var lat: Double = 0
    dynamic var long: Double = 0
    dynamic var parentId: Int = 0
    dynamic var placeImage: String = ""
    dynamic var placeLocation: Location?
    dynamic var placeVisitors: Int = 0
    dynamic var regionName: String = ""
    dynamic var title: String = ""
    dynamic var unescoId: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: WHSJSON,
                      with controller: RealmController) {
        guard from.active == "Y" else { return nil }
        self.init()

        id = from.id
        lat = from.lat
        long = from.long
        parentId = from.parentId ?? 0
        let format = "https://whc.unesco.org/uploads/sites/gallery/original/site_%04d_0001.jpg"
        placeImage = String(format: format, from.id)
        placeVisitors = from.visitors
        title = from.title
        unescoId = from.unescoId

        let locationId = from.location?.id ?? from.locationId
        if let location = controller.location(id: locationId) {
            countryName = location.countryName
            regionName = location.regionName
        } else if let country = controller.country(id: locationId) {
            log.error("placed in country: WHS \(id)")
            countryName = country.countryName
            // patch "Swiss Alps Jungfrau-Aletsch" for now
            regionName = "Europe"
        } else {
            log.error("missing location: WHS \(id)")
            countryName = L.unknown()
            regionName = L.unknown()
        }
    }

    override var description: String {
        return title
    }
}

extension WHS: PlaceInfo {

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

    var placeIsMappable: Bool {
        switch id {
        case 275, // Jesuit Missions of the Guaranis
             1_133, // Primeval Beech Forests of the Carpathians
             1_187: // Struve Geodetic Arc
            return false
        default:
            return true
        }
    }

    var placeParent: PlaceInfo? {
        return parent
    }

    var placeRegion: String {
        return regionName
    }

    var placeTitle: String {
        return title
    }

    var placeWebUrl: URL? {
        let link = "https://whc.unesco.org/en/list/\(unescoId)"
        return URL(string: link)
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
        return Checklist.whss.isVisited(id: id)
    }
}
