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
    let subtitle: String?
    // MKAnnotationView
    var reuseIdentifier: String {
        return list.rawValue
    }

    let list: Checklist
    let info: PlaceInfo
    weak var delegate: PlaceAnnotationDelegate?

    var id: Int { return info.placeId }
    var country: String { return info.placeSubtitle }
    var visitors: Int { return info.placeVisitors }

    // updated with user position or when NearbyVC displayed
    var distance: CLLocationDistance = 0

    init?(list: Checklist,
          info: PlaceInfo,
          delegate: PlaceAnnotationDelegate) {
        let placeCoordinate = info.placeCoordinate
        guard !placeCoordinate.isZero else { return nil }

        self.coordinate = placeCoordinate
        self.subtitle = info.placeTitle

        self.list = list
        self.info = info
        self.delegate = delegate

        super.init()
    }

    override var hash: Int {
        return title.hashValue ^ reuseIdentifier.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlaceAnnotation else { return false }
        guard other !== self else { return true }

        return list == other.list &&
               info == other.info
    }

    var background: UIColor {
        return list.background
    }

    var listImage: UIImage {
        return list.image
    }

    var isTriggered: Bool {
        get { return list.isTriggered(id: id) }
        set {
            list.set(id: id, triggered: newValue)
            delegate?.notify(place: self)
        }
    }

    var isVisited: Bool {
        get { return list.isVisited(id: id) }
        set { list.set(id: id, visited: newValue) }
    }

    func reveal(callout: Bool) {
        delegate?.reveal(place: self, callout: callout)
    }

    func show() {
        delegate?.show(place: self)
    }

    var imageUrl: URL? {
        let image = info.placeImage
        guard !image.isEmpty else { return nil }

        if image.hasPrefix("http") {
            return URL(string: image)
        } else {
            let target = MTP.picture(uuid: image, size: .any)
            return target.requestUrl
        }
    }

    func setDistance(from: CLLocation, trigger: Bool) {
        distance = coordinate.distance(from: from)
        guard trigger,
              !isVisited,
              !isTriggered else { return }

        let triggered: Bool
        switch list {
        case .locations:
            triggered = data.worldMap.contains(coordinate: from.coordinate,
                                               location: id)
        default:
            triggered = distance < list.triggerDistance
        }
        if triggered {
            isTriggered = true
        }
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
