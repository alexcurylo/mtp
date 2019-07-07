// @copyright Trollwerks Inc.

import MapKit
import RealmMapView
import RealmSwift

protocol Mappable {

    var map: MapInfo? { get }
}

extension Mappable {

    var placeCoordinate: CLLocationCoordinate2D {
        return map?.coordinate ?? .zero
    }

    var placeCountry: String {
        return map?.country ?? ""
    }

    var placeImageUrl: URL? {
        return map?.imageUrl
    }

    var placeLocation: Location? {
        return map?.location
    }

    var placeRegion: String {
        return map?.region ?? ""
    }

    var placeTitle: String {
        return map?.title ?? ""
    }

    var placeVisitors: Int {
        return map?.visitors ?? 0
    }

    var placeWebUrl: URL? {
        return map?.website.mtpWebsiteUrl
    }
}

@objcMembers final class MapInfo: Object, ServiceProvider {

    dynamic var checklistValue: Int = Checklist.locations.rawValue
    var checklist: Checklist {
        //swiftlint:disable:next force_unwrapping
        get { return Checklist(rawValue: checklistValue)! }
        set { checklistValue = newValue.rawValue }
    }
    dynamic var checklistId: Int = 0
    dynamic var country: String = ""
    dynamic var image: String = ""
    dynamic var latitude: CLLocationDegrees = 0
    dynamic var location: Location?
    dynamic var longitude: CLLocationDegrees = 0
    dynamic var region: String = ""
    dynamic var subtitle: String = ""
    dynamic var title: String = ""
    dynamic var visitors: Int = 0
    dynamic var website: String = ""

    dynamic var dbKey: String = ""

    override static func primaryKey() -> String? {
        return "dbKey"
    }

    static func key(list: Checklist, id: Int) -> String {
        return "'list=\(list.rawValue)?id=\(id)'"
    }

    static func configure(map: RealmMapView) {
        map.entityName = typeName
        map.latitudeKeyPath = "latitude"
        map.longitudeKeyPath = "longitude"
        map.subtitleKeyPath = "subtitle"
        map.titleKeyPath = "title"
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude,
                                      longitude: longitude)
    }

    var isVisited: Bool {
        get {
            return checklist.isVisited(id: checklistId)
        }
        set {
            checklist.set(visited: newValue, id: checklistId)
            loc.update(place: self)
        }
    }

    func reveal(callout: Bool) {
        loc.reveal(place: self, callout: callout)
    }

    var nearest: MapInfo? {
        return loc.nearest(list: checklist,
                           id: checklistId,
                           to: coordinate)
    }

    var imageUrl: URL? {
        return image.mtpImageUrl
    }

    convenience init(checklist: Checklist,
                     place: PlaceJSON,
                     realm: RealmController) {
        self.init()

        self.checklist = checklist
        checklistId = place.id
        image = place.img ?? ""
        latitude = place.lat
        longitude = place.long
        subtitle = ""
        title = place.title
        visitors = place.visitors
        website = place.url
        location = realm.location(id: place.location.id)
        country = location?.placeCountry ?? L.unknown()
        region = location?.placeRegion ?? L.unknown()

        dbKey = MapInfo.key(list: checklist, id: checklistId)
    }

    convenience init(checklist: Checklist,
                     checklistId: Int,
                     image: String,
                     latitude: CLLocationDegrees,
                     locationId: Int,
                     longitude: CLLocationDegrees,
                     title: String,
                     visitors: Int,
                     website: String,
                     realm: RealmController) {
        self.init()

        self.checklist = checklist
        self.checklistId = checklistId
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
        self.subtitle = ""
        self.title = title
        self.visitors = visitors
        self.website = website
        location = realm.location(id: locationId)
        country = location?.placeCountry ?? L.unknown()
        region = location?.placeRegion ?? L.unknown()

        dbKey = MapInfo.key(list: checklist, id: checklistId)
    }

    convenience init(checklist: Checklist,
                     checklistId: Int,
                     country: String,
                     image: String,
                     latitude: CLLocationDegrees,
                     location: Location?,
                     longitude: CLLocationDegrees,
                     region: String,
                     subtitle: String,
                     title: String,
                     visitors: Int,
                     website: String) {
        self.init()

        self.checklist = checklist
        self.checklistId = checklistId
        self.country = country
        self.image = image
        self.latitude = latitude
        self.location = location
        self.longitude = longitude
        self.region = region
        self.subtitle = subtitle
        self.title = title
        self.visitors = visitors
        self.website = website

        dbKey = MapInfo.key(list: checklist, id: checklistId)
    }
}

extension String {

    var mtpImageUrl: URL? {
        guard !isEmpty else { return nil }

        if hasPrefix("http") {
            return URL(string: self)
        } else {
            let target = MTP.picture(uuid: self, size: .any)
            return target.requestUrl
        }
    }

    var mtpWebsiteUrl: URL? {
        guard !isEmpty else { return nil }

        if hasPrefix("http") {
            return URL(string: self)
        } else {
            return URL(string: "http://\(self)")
        }
    }
}
