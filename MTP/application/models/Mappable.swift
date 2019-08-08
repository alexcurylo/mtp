// @copyright Trollwerks Inc.

import MapKit
import RealmMapView
import RealmSwift

// swiftlint:disable file_length

/// A Place that is showable on map
protocol PlaceMappable {

    /// The Mappable to use for display
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

    /// MTP location containing place
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

/// Actions that a Mappable displayer can handle
protocol Mapper {

    /// Close
    ///
    /// - Parameter mappable: Place
    func close(mappable: Mappable)
    /// Notify
    ///
    /// - Parameters:
    ///   - mappable: Place
    ///   - triggered: Date
    func notify(mappable: Mappable, triggered: Date)
    /// Reveal
    ///
    /// - Parameters:
    ///   - mappable: Place
    ///   - callout: Show callout
    func reveal(mappable: Mappable, callout: Bool)
    /// Show
    ///
    /// - Parameter mappable: Place
    func show(mappable: Mappable)
    /// Update
    ///
    /// - Parameter mappable: Place
    func update(mappable: Mappable)
}

/// Realm representation of a mappable place
@objcMembers final class Mappable: Object, ServiceProvider {

    typealias Key = String
    typealias Reference = ThreadSafeReference<Mappable>

    dynamic var checklistValue: Int = Checklist.beaches.rawValue
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

    dynamic var dbKey: Key = ""

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "dbKey"
    }

    static func key(item: Checklist.Item) -> Key {
        return Key.key(item: item)
    }

    /// Configure for display
    static func configure(map: RealmMapView) {
        map.entityName = typeName
        map.latitudeKeyPath = "latitude"
        map.longitudeKeyPath = "longitude"
        // title always shows above our custom callout
        //map.titleKeyPath = "title"
        // mark subtitle .visible and set it to title
        map.subtitleKeyPath = "title"
    }

    var item: Checklist.Item {
        return (list: checklist, id: checklistId)
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
        return checklist.isVisited(id: checklistId)
    }

    var isDismissed: Bool {
        get { return checklist.isDismissed(id: checklistId) }
        set { checklist.set(dismissed: newValue, id: checklistId) }
    }

    func reveal(callout: Bool) {
        loc.reveal(mappable: self, callout: callout)
    }

    func show() {
        loc.show(mappable: self)
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

    var reference: Reference {
        return ThreadSafeReference(to: self)
    }

    convenience init(checklist: Checklist,
                     place: PlaceJSON,
                     realm: RealmDataController) {
        self.init()

        self.checklist = checklist
        checklistId = place.id
        image = place.featuredImg ?? ""
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
                     realm: RealmDataController) {
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
                  realm: RealmDataController) {
        location = realm.location(id: locationId)
        country = location?.placeCountry ?? L.unknown()
        region = location?.placeRegion ?? L.unknown()
        subtitle = location?.description ?? ""

        dbKey = Mappable.key(item: item)

        #if DEBUG
        if image.isEmpty {
            log.warning("imageless \(checklist.key) \(checklistId): \(title)")
        }
        #endif
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

        dbKey = Mappable.key(item: item)
    }

    var isHere: Bool {
        switch checklist {
        case .locations:
            return data.worldMap.contains(coordinate: loc.here ?? .zero,
                                          location: checklistId)
        default:
            return distance < checklist.triggerDistance
        }
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

    /// Equality operator
    ///
    /// - Parameter object: Other object
    /// - Returns: equality
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Mappable else { return false }
        guard !isSameObject(as: other) else { return true }

        let same = dbKey == other.dbKey &&
                   checklistValue == other.checklistValue &&
                   checklistId == other.checklistId &&
                   country == other.country &&
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
            loc.notify(mappable: self, triggered: Date())
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

// MARK: - Private

private extension Mappable {

    var isTriggered: Bool {
        get { return checklist.isTriggered(id: checklistId) }
        set { checklist.set(triggered: newValue, id: checklistId) }
    }

    var canTrigger: Bool {
        return !isDismissed && !isVisited
    }

    func update(triggered: Bool) {
        if triggered && canTrigger {
            isTriggered = true
            loc.notify(mappable: self, triggered: Date())
        }
    }
}

extension Mappable.Key: ServiceProvider {

    static func key(item: Checklist.Item) -> Mappable.Key {
        return "list=\(item.list.rawValue)?id=\(item.id)"
    }

    var item: Checklist.Item {
        return (list: checklist, id: checklistId)
    }

    var checklist: Checklist {
        guard let range = range(of: #"list=[0-9]+"#,
                                options: .regularExpression) else {
            log.error("Can't find list in \(self)")
            return .beaches
        }

        let match = String(self[range])
        let number = String(match[5...match.count - 1])
        let value = Int(number) ?? 0
        return Checklist(rawValue: value) ?? .beaches
    }

    var checklistId: Int {
        guard let range = range(of: #"id=[0-9]+"#,
                                options: .regularExpression) else {
            log.error("Can't find id in \(self)")
            return 0
        }

        let match = String(self[range])
        let number = String(match[3...match.count - 1])
        return Int(number) ?? 0
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
