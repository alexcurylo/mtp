// @copyright Trollwerks Inc.

import MapKit
import RealmMapView
import RealmSwift

protocol PlaceMappable {

    var map: Mappable? { get }
}

extension PlaceMappable {

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
        return map?.placeWebUrl
    }
}

protocol Mapper {

    func close(mappable: Mappable)
    func notify(mappable: Mappable)
    func reveal(mappable: Mappable, callout: Bool)
    func show(mappable: Mappable)
    func update(mappable: Mappable)
}

@objcMembers final class Mappable: Object, ServiceProvider {

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
        // title always shows above our custom callout
        //map.titleKeyPath = "title"
        // mark subtitle .visible and set it to title
        map.subtitleKeyPath = "title"
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude,
                                      longitude: longitude)
    }

    var marker: UIColor {
        return isVisited ? .visited : checklist.marker
    }

    var listImage: UIImage {
        return checklist.image
    }

    var isVisited: Bool {
        get { return checklist.isVisited(id: checklistId) }
        set {
            checklist.set(visited: newValue, id: checklistId)
            loc.update(mappable: self)
        }
    }

    func reveal(callout: Bool) {
        loc.reveal(mappable: self, callout: callout)
    }

    var nearest: Mappable? {
        return loc.nearest(list: checklist,
                           id: checklistId,
                           to: coordinate)
    }

    var imageUrl: URL? {
        return image.mtpImageUrl
    }

    var placeWebUrl: URL? {
        return website.mtpWebsiteUrl
    }

    var canPost: Bool {
        return checklist == .locations
    }

    var distance: CLLocationDistance {
        return loc.distance(to: self)
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
        complete(locationId: place.location.id, realm: realm)
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
        self.title = title
        self.visitors = visitors
        self.website = website
        complete(locationId: locationId, realm: realm)
    }

    func complete(locationId: Int,
                  realm: RealmController) {
        location = realm.location(id: locationId)
        country = location?.placeCountry ?? L.unknown()
        region = location?.placeRegion ?? L.unknown()
        subtitle = location?.description ?? ""

        dbKey = Mappable.key(list: checklist, id: checklistId)
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

        dbKey = Mappable.key(list: checklist, id: checklistId)
    }

    func trigger(distance: CLLocationDistance) {
        guard checklist.triggerDistance > 0 else { return }

        let triggered = distance < checklist.triggerDistance
        update(triggered: triggered)
    }

    func trigger(contains: CLLocationCoordinate2D,
                 world: WorldMap) -> Bool {
        guard checklist == .locations else { return false }

        let contains = world.contains(coordinate: contains,
                                      location: checklistId)
        update(triggered: contains)
        return contains
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Mappable else { return false }
        guard !isSameObject(as: other) else { return true }

        let same = dbKey == other.dbKey &&
                   checklistValue == other.checklistValue &&
                   checklistId == other.checklistId &&
                   country == other.country &&
                   image == other.image &&
                   image == other.image &&
                   latitude == other.latitude &&
                   longitude == other.longitude &&
                   region == other.region &&
                   subtitle == other.subtitle &&
                   title == other.title &&
                   visitors == other.visitors &&
                   website == other.website &&
                   location == other.location
        return same
    }

    #if DEBUG
    func _testTriggeredNearby() {
        update(triggered: true)
    }

    func _testTrigger(background: Bool) {

        func trigger() {
            isTriggered = true
            loc.notify(mappable: self)
        }

        if background {
            UIControl().sendAction(#selector(URLSessionTask.suspend),
                                   to: UIApplication.shared,
                                   for: nil)
            DispatchQueue.main.asyncAfter(deadline: .medium) {
                trigger()
            }
        } else {
            trigger()
        }
    }
    #endif
}

private extension Mappable {

    var isDismissed: Bool {
        get { return checklist.isDismissed(id: checklistId) }
        set { checklist.set(dismissed: newValue, id: checklistId) }
    }

    var isTriggered: Bool {
        get { return checklist.isTriggered(id: checklistId) }
        set { checklist.set(triggered: newValue, id: checklistId) }
    }

    var canTrigger: Bool {
        return !isDismissed && !isTriggered && !isVisited
    }

    func update(triggered: Bool) {
        if triggered && canTrigger {
            isTriggered = true
            loc.notify(mappable: self)
        }
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
