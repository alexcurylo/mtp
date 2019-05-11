// @copyright Trollwerks Inc.

import MapKit

protocol PlaceAnnotationDelegate: AnyObject {

    func close(callout: PlaceAnnotation)
    func show(location: PlaceAnnotation)
}

final class PlaceAnnotation: NSObject, MKAnnotation {

    // MKAnnotation -- suppress callout title
    @objc dynamic var coordinate: CLLocationCoordinate2D
    let title: String? = nil
    let subtitle: String?

    let image: String?
    let country: String?
    let visitors: Int
    let type: Checklist
    let id: Int
    var identifier: String {
        return type.rawValue
    }

    weak var delegate: PlaceAnnotationDelegate?

    init?(type: Checklist,
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

        self.type = type
        self.id = id
        self.delegate = delegate
        self.country = country
        self.visitors = visitors
        self.image = image

        super.init()
    }

    override var hash: Int {
        return title.hashValue ^ identifier.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlaceAnnotation else { return false }
        guard other !== self else { return true }

        return type == other.type &&
               id == other.id &&
               coordinate == other.coordinate &&
               subtitle == other.subtitle &&
               country == other.country &&
               image == other.image
    }

    var background: UIColor {
        return type.background
    }

    var listImage: UIImage {
        return type.image
    }

    var isVisited: Bool {
        get {
            return type.isVisited(id: id)
        }
        set {
            if type != .uncountries {
                type.set(id: id, visited: newValue)
            }
        }
    }

    func show() {
        delegate?.show(location: self)
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
}
