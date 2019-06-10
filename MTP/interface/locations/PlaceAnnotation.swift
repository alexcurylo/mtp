// @copyright Trollwerks Inc.

import MapKit

protocol PlaceAnnotationDelegate: AnyObject {

    func close(place: PlaceAnnotation)
    func notify(place: PlaceAnnotation)
    func reveal(place: PlaceAnnotation?,
                callout: Bool)
    func show(place: PlaceAnnotation)
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

    let list: Checklist
    weak var delegate: PlaceAnnotationDelegate?
    let id: Int
    let name: String
    let country: String
    let visitors: Int
    let image: String

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
        self.visitors = info.placeVisitors
        self.image = info.placeImage

        super.init()
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

    var background: UIColor {
        return list.background
    }

    var listImage: UIImage {
        return list.image
    }

    var isDismissed: Bool {
        get { return list.isDismissed(id: id) }
        set { list.set(dismissed: newValue, id: id) }
    }

    var isTriggered: Bool {
        get { return list.isTriggered(id: id) }
        set { list.set(triggered: newValue, id: id) }
    }

    var isVisited: Bool {
        get { return list.isVisited(id: id) }
        set { list.set(visited: newValue, id: id) }
    }

    func reveal(callout: Bool) {
        delegate?.reveal(place: self, callout: callout)
    }

    func show() {
        delegate?.show(place: self)
    }

    var imageUrl: URL? {
        guard !image.isEmpty else { return nil }

        if image.hasPrefix("http") {
            return URL(string: image)
        } else {
            let target = MTP.picture(uuid: image, size: .any)
            return target.requestUrl
        }
    }

    @discardableResult func setDistance(from: CLLocationCoordinate2D, trigger: Bool) -> Bool {
        distance = coordinate.distance(from: from)
        return trigger ? check(trigger: from) : false
    }

    var canTrigger: Bool {
        return !isDismissed && !isTriggered && !isVisited
    }

    func check(trigger: CLLocationCoordinate2D) -> Bool {
        let triggered: Bool
        switch list {
        case .locations:
            triggered = canTrigger &&
                        data.worldMap.contains(coordinate: trigger,
                                               location: id)
        default:
            triggered = distance < list.triggerDistance && canTrigger
        }
        if triggered {
            isTriggered = true
            delegate?.notify(place: self)
        }
        return triggered
    }

    var formattedDistance: String {
        let km = distance / 1_000
        let formatted: String
        switch km {
        case ..<1:
            formatted = String(format: "%.2f", km)
        case ..<10:
            formatted = String(format: "%.1f", km)
        default:
            formatted = Int(km).grouped
        }
        return Localized.km(formatted)
    }

    override var description: String {
        return """
        PlaceAnnotation: \(list) - \
        \(subtitle ?? "?")
        """
    }
}
