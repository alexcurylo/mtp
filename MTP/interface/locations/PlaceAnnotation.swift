// @copyright Trollwerks Inc.

import MapKit

protocol PlaceAnnotationDelegate: AnyObject {

    func close(place: PlaceAnnotation)
    func notify(place: PlaceAnnotation)
    func reveal(place: PlaceAnnotation?,
                callout: Bool)
    func show(place: PlaceAnnotation)
    func update(place: PlaceAnnotation)
}

final class PlaceAnnotation: NSObject, MKAnnotation, ServiceProvider {

    // MKAnnotation -- suppress callout title
    @objc dynamic var coordinate: CLLocationCoordinate2D
    let title: String? = nil
    var subtitle: String? { return name }
    // MKAnnotationView
    var reuseIdentifier: String {
        return list.rawValue
    }

    let id: Int
    let list: Checklist
    let name: String
    let country: String
    let countryId: Int
    let imageUrl: URL?
    let webUrl: URL?
    let visitors: Int
    var canPost: Bool {
        return list == .locations
    }

    private weak var delegate: PlaceAnnotationDelegate?

    var distance: CLLocationDistance = 0

    init?(list: Checklist,
          info: PlaceInfo,
          coordinate: CLLocationCoordinate2D,
          delegate: PlaceAnnotationDelegate) {
        guard !coordinate.isZero else { return nil }

        self.list = list
        self.delegate = delegate
        self.coordinate = coordinate
        self.id = info.placeId
        self.name = info.placeTitle
        self.country = info.placeSubtitle
        self.countryId = info.placeCountryId
        self.visitors = info.placeVisitors
        self.imageUrl = info.placeImageUrl
        self.webUrl = info.placeWebUrl

        super.init()
    }

    var nearest: PlaceAnnotation? {
        return loc.nearest(list: list,
                           id: id,
                           to: coordinate)
    }

    override var hash: Int {
        return title.hashValue ^ reuseIdentifier.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlaceAnnotation else { return false }
        guard other !== self else { return true }

        return list == other.list &&
               id == other.id
    }

    override var description: String {
        return "\(list) \(name)"
    }

    override var debugDescription: String {
        return """
        PlaceAnnotation: \(list) \(id) - \
        \(subtitle ?? "?")
        """
    }

    var marker: UIColor {
        return visited ? .visited : list.marker
    }

    var listImage: UIImage {
        return list.image
    }

    private lazy var visited: Bool = {
        list.isVisited(id: id)
    }()

    var isVisited: Bool {
        get { return visited }
        set {
            visited = newValue
            list.set(visited: newValue, id: id)
            delegate?.update(place: self)
        }
    }

    func reveal(callout: Bool) {
        delegate?.reveal(place: self, callout: callout)
    }

    func close() {
        delegate?.close(place: self)
    }

    func show() {
        delegate?.show(place: self)
    }

    func setDistance(from: CLLocationCoordinate2D) {
        distance = coordinate.distance(from: from)
    }

    func triggerDistance() {
        guard list.triggerDistance > 0 else { return }

        let triggered = distance < list.triggerDistance
        update(triggered: triggered)
    }

    func trigger(contains: CLLocationCoordinate2D,
                 map: WorldMap) {
        guard list == .locations else { return }

        let triggered = map.contains(coordinate: contains,
                                     location: id)
        update(triggered: triggered)
    }
}

private extension PlaceAnnotation {

    var isDismissed: Bool {
        get { return list.isDismissed(id: id) }
        set { list.set(dismissed: newValue, id: id) }
    }

    var isTriggered: Bool {
        get { return list.isTriggered(id: id) }
        set { list.set(triggered: newValue, id: id) }
    }

    var canTrigger: Bool {
        return !isDismissed && !isTriggered && !isVisited
    }

    func update(triggered: Bool) {
        if triggered && canTrigger {
            isTriggered = true
            delegate?.notify(place: self)
        }
    }
}
