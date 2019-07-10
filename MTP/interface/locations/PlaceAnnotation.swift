// @copyright Trollwerks Inc.

import MapKit

protocol PlaceAnnotationDelegate: AnyObject {

    func close(place: PlaceAnnotation)
    func notify(place: PlaceAnnotation)
    func reveal(place: PlaceAnnotation, callout: Bool)
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
        return checklist.key
    }

    let checklistId: Int
    let checklist: Checklist
    let name: String
    let country: String
    let countryId: Int
    let imageUrl: URL?
    let placeWebUrl: URL?
    let visitors: Int
    var canPost: Bool {
        return checklist == .locations
    }

    private weak var delegate: PlaceAnnotationDelegate?

    var distance: CLLocationDistance = 0

    init?(list: Checklist,
          info: PlaceInfo,
          coordinate: CLLocationCoordinate2D,
          delegate: PlaceAnnotationDelegate) {
        guard !coordinate.isZero else { return nil }

        self.checklist = list
        self.delegate = delegate
        self.coordinate = coordinate
        self.checklistId = info.placeId
        self.name = info.placeTitle
        self.country = info.placeSubtitle
        self.countryId = info.placeCountryId
        self.visitors = info.placeVisitors
        self.imageUrl = info.placeImageUrl
        self.placeWebUrl = info.placeWebUrl

        super.init()
    }

    override var hash: Int {
        return title.hashValue ^ reuseIdentifier.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlaceAnnotation else { return false }
        guard other !== self else { return true }

        return checklist == other.checklist &&
               checklistId == other.checklistId
    }

    override var description: String {
        return "\(checklist) \(name)"
    }

    override var debugDescription: String {
        return """
        PlaceAnnotation: \(checklist) \(checklistId) - \
        \(subtitle ?? "?")
        """
    }

    var marker: UIColor {
        return visited ? .visited : checklist.marker
    }

    var listImage: UIImage {
        return checklist.image
    }

    private lazy var visited: Bool = {
        checklist.isVisited(id: checklistId)
    }()

    var isVisited: Bool {
        get { return visited }
        set {
            visited = newValue
            checklist.set(visited: newValue, id: checklistId)
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

    var mappable: Mappable? {
        return data.get(mappable: checklist, id: checklistId)
    }
}

private extension PlaceAnnotation {

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
            delegate?.notify(place: self)
        }
    }
}
