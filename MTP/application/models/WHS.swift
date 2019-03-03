// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

struct WHSJSON: Codable {

    let active: String
    let id: Int
    let lat: Double
    let location: PlaceLocation? // nil in 1154?
    let locationId: Int? // nil in 1159?
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
    dynamic var regionName: String = ""
    dynamic var title: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: WHSJSON) {
        guard from.active == "Y" else { return nil }
        self.init()

        countryName = from.location?.countryName ?? Localized.unknown()
        id = from.id
        lat = from.lat
        long = from.long
        parentId = from.parentId ?? 0
        regionName = from.location?.regionName ?? Localized.unknown()
        title = from.title
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

    var placeParent: PlaceInfo? {
        if hasParent {
            return data.get(whs: parentId)
        }
        return nil
    }

    var placeRegion: String {
        return regionName
    }

    var placeSubtitle: String {
        return ""
    }

    var placeTitle: String {
        return title
    }
}

extension WHS {

    var hasParent: Bool {
        return parentId != 0
    }
}
