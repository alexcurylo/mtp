// @copyright Trollwerks Inc.

import MapKit
import RealmSwift

// swiftlint:disable file_length

/// A Place that is showable on map
protocol PlaceMappable {

    /// The Mappable to use for display
    var map: Mappable? { get }
}

extension PlaceMappable {

    /// Coordinate for plotting on map
    var placeCoordinate: CLLocationCoordinate2D {
        return map?.coordinate ?? .zero
    }

    /// UN country containing place
    var placeCountry: String {
        return map?.country ?? ""
    }

    /// UUID of main image to display for place
    var placeImageUrl: URL? {
        return map?.imageUrl
    }

    /// MTP location containing place
    var placeLocation: Location? {
        return map?.location
    }

    /// Region containing the country
    var placeRegion: String {
        return map?.region ?? ""
    }

    /// Title to display to user
    var placeTitle: String {
        return map?.title ?? ""
    }

    /// Number of MTP visitors
    var placeVisitors: Int {
        return map?.visitors ?? 0
    }

    /// for non-MTP locations, page to load in More Info screen
    var placeWebUrl: URL? {
        return map?.placeWebUrl
    }
}

/// Actions that a Mappable displayer can handle
protocol Mapper {

    /// Show Add Photo screen
    /// - Parameter mappable: Place
    func add(photo mappable: Mappable)
    /// Show Add Post screen
    /// - Parameter mappable: Place
    func add(post mappable: Mappable)
    /// Close callout
    /// - Parameter mappable: Place
    func close(mappable: Mappable)
    /// Notify of visit
    /// - Parameters:
    ///   - mappable: Place
    ///   - triggered: Date
    func notify(mappable: Mappable, triggered: Date)
    /// Reveal on map
    /// - Parameters:
    ///   - mappable: Place
    ///   - callout: Show callout
    func reveal(mappable: Mappable, callout: Bool)
    /// Show Directions selector
    /// - Parameter mappable: Place
    func show(directions mappable: Mappable)
    /// Show Show More screen
    /// - Parameter mappable: Place
    func show(more mappable: Mappable)
    /// Show Nearby screen
    /// - Parameter mappable: Place
    func show(nearby mappable: Mappable)
    /// Update
    /// - Parameter mappable: Place
    func update(mappable: Mappable)
}

/// Realm representation of a mappable place
@objcMembers class Mappable: Object, ServiceProvider {

    /// Typealias for fluency
    typealias Key = String
    /// Typealias for fluency
    typealias Reference = ThreadSafeReference<Mappable>

    /// checklistValue
    dynamic var checklistValue: Int = Checklist.beaches.rawValue
    /// checklist
    var checklist: Checklist {
        // swiftlint:disable:next force_unwrapping
        get { return Checklist(rawValue: checklistValue)! }
        set { checklistValue = newValue.rawValue }
    }
    /// checklistId
    dynamic var checklistId: Int = 0
    /// country
    dynamic var country: String = ""
    /// image
    dynamic var image: String = ""
    /// latitude
    dynamic var latitude: CLLocationDegrees = 0
    /// location
    dynamic var location: Location?
    /// longitude
    dynamic var longitude: CLLocationDegrees = 0
    /// region
    dynamic var region: String = ""
    /// subtitle
    dynamic var subtitle: String = ""
    /// title
    dynamic var title: String = ""
    /// visible
    dynamic var visible: Bool = true
    /// visitors
    dynamic var visitors: Int = 0
    /// website
    dynamic var website: String = ""

    /// dbKey
    dynamic var dbKey: Key = ""

    /// Realm unique identifier
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "dbKey"
    }

    /// Unique key for database
    /// - Parameter item: Item
    /// - Returns: Unique key
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

    /// Convenience item accessor
    var item: Checklist.Item {
        return (list: checklist, id: checklistId)
    }

    /// Convenience coordinate accessor
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude,
                                      longitude: longitude)
    }

    /// Convenience marker accessor
    var marker: UIColor {
        return isVisited ? .visited : checklist.marker
    }

    /// Convenience listImage accessor
    var listImage: UIImage {
        return checklist.image
    }

    /// Convenience isVisited accessor
    var isVisited: Bool {
        return checklist.isVisited(id: checklistId)
    }

    /// Convenience isDismissed accessor
    var isDismissed: Bool {
        get { return checklist.isDismissed(id: checklistId) }
        set { checklist.set(dismissed: newValue, id: checklistId) }
    }

    /// Reveal on map
    /// - Parameter callout: Whether to pop up info
    func reveal(callout: Bool) {
        loc.reveal(mappable: self, callout: callout)
    }

    /// Go tot Show More screen
    func show() {
        loc.show(more: self)
    }

    /// Convenience nearest accessor
    var nearest: Mappable? {
        return loc.nearest(list: checklist,
                           id: checklistId,
                           to: coordinate)
    }

    /// Convenience imageUrl accessor
    var imageUrl: URL? {
        return image.mtpImageUrl
    }

    /// for non-MTP locations, page to load in More Info screen
    var placeWebUrl: URL? {
        return website.mtpWebsiteUrl
    }

    /// Convenience canPost accessor
    var canPost: Bool {
        return checklist == .locations
    }

    /// Convenience distance accessor
    var distance: CLLocationDistance {
        return loc.distance(to: self)
    }

    /// Thread safe reference
    var reference: Reference {
        return ThreadSafeReference(to: self)
    }

    /// Intialize by injection
    /// - Parameters:
    ///   - checklist: Checklist
    ///   - checklistId: Int
    ///   - image: String
    ///   - latitude: CLLocationDegrees
    ///   - locationId: Int
    ///   - longitude: CLLocationDegrees
    ///   - title: String
    ///   - visitors: Int
    ///   - website: String
    ///   - realm: RealmDataController
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

    /// Fill in location related data
    /// - Parameters:
    ///   - locationId: Int
    ///   - realm: RealmDataController
    func complete(locationId: Int,
                  realm: RealmDataController) {
        if let location = realm.location(id: locationId) {
            country = location.placeCountry
            region = location.placeRegion
            subtitle = location.description
        } else if let notLocation = realm.country(id: locationId) {
            log.warning("\(checklist) \(checklistId) '\(title)' placed in country: \(notLocation.placeCountry)")
            country = notLocation.placeCountry
            region = L.unknown()
            subtitle = country
        } else {
            log.warning("\(checklist) \(checklistId) '\(title)' missing location \(locationId)")
            country = L.unknown()
            region = L.unknown()
            subtitle = ""
        }

        dbKey = Mappable.key(item: item)

        #if DEBUG
        if image.isEmpty {
            log.warning("imageless \(checklist.key) \(checklistId): \(title)")
        }
        #endif
    }

    /// Intialize by injection
    /// - Parameters:
    ///   - checklist: Checklist
    ///   - checklistId: Int
    ///   - country: String
    ///   - image: String
    ///   - latitude: CLLocationDegrees
    ///   - location: Location
    ///   - longitude: CLLocationDegrees
    ///   - region: String
    ///   - subtitle: String
    ///   - title: String
    ///   - visitors: Int
    ///   - website: String
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

    /// Test visitability
    var isHere: Bool {
        switch checklist {
        case .locations:
            return data.worldMap.contains(coordinate: loc.here ?? .zero,
                                          location: checklistId)
        default:
            return distance < checklist.triggerDistance
        }
    }

    /// Trigger visit notification
    /// - Parameter distance: Distance
    func trigger(distance: CLLocationDistance) {
        guard checklist.triggerDistance > 0 else { return }

        let triggered = distance < checklist.triggerDistance
        update(triggered: triggered)
    }

    /// Trigger visit notification
    /// - Parameters:
    ///   - contains: Coordinate
    ///   - world: World Map
    /// - Returns: whether triggered
    func trigger(contains: CLLocationCoordinate2D,
                 world: WorldMap) -> Bool {
        guard checklist == .locations else { return false }

        let contains = world.contains(coordinate: contains,
                                      location: checklistId)
        update(triggered: contains)
        return contains
    }

    /// Equality operator
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
    /// Test nearby triggering
    func _testTriggeredNearby() {
        update(triggered: true)
    }

    /// Test background triggering
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

    /// Unique key for database
    /// - Parameter item: Item
    /// - Returns: Unique key
    static func key(item: Checklist.Item) -> Mappable.Key {
        return "list=\(item.list.rawValue)?id=\(item.id)"
    }

    /// item
    var item: Checklist.Item {
        return (list: checklist, id: checklistId)
    }

    /// checklist
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

    /// checklistId
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

    /// Image URL from a MTP UUID
    var mtpImageUrl: URL? {
        guard !isEmpty else { return nil }

        if hasPrefix("http") {
            return URL(string: self)
        } else {
            let target = MTP.picture(uuid: self, size: .any)
            return target.requestUrl
        }
    }

    /// Sanitize URL string
    var mtpWebsiteUrl: URL? {
        guard !isEmpty else { return nil }

        if hasPrefix("http") {
            return URL(string: self)
        } else {
            return URL(string: "http://\(self)")
        }
    }
}
