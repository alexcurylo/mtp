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

    let image: String?
    let country: String?
    let visitors: Int
    let list: Checklist
    let id: Int

    // updated with user position or when NearbyVC displayed
    var distance: CLLocationDistance = 0

    weak var delegate: PlaceAnnotationDelegate?

    init?(list: Checklist,
          id: Int,
          coordinate: CLLocationCoordinate2D,
          delegate: PlaceAnnotationDelegate,
          title: String,
          country: String,
          visitors: Int,
          image: String) {
        guard !coordinate.isZero else { return nil }

        self.coordinate = coordinate
        self.subtitle = title

        self.list = list
        self.id = id
        self.delegate = delegate
        self.country = country
        self.visitors = visitors
        self.image = image

        super.init()
    }

    override var hash: Int {
        return title.hashValue ^ reuseIdentifier.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlaceAnnotation else { return false }
        guard other !== self else { return true }

        return list == other.list &&
               id == other.id &&
               coordinate == other.coordinate &&
               subtitle == other.subtitle &&
               country == other.country &&
               image == other.image
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
        guard let image = image, !image.isEmpty else { return nil }

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
        \(subtitle ?? "?"), \
        \(country ?? "?"))
        """
    }
}
