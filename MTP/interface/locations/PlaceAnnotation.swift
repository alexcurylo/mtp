// @copyright Trollwerks Inc.

import MapKit

protocol PlaceAnnotationDelegate: AnyObject {

    func show(location: PlaceAnnotation)
}

final class PlaceAnnotation: NSObject, MKAnnotation {

    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

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
          subtitle: String) {
        guard !coordinate.isZero else { return nil }

        self.type = type
        self.id = id
        self.coordinate = coordinate
        self.delegate = delegate
        self.title = title
        self.subtitle = subtitle

        super.init()
    }

    override var hash: Int {
        return title.hashValue ^ identifier.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlaceAnnotation else { return false }
        guard other !== self else { return true }

        return coordinate == other.coordinate &&
               title == other.title &&
               subtitle == other.subtitle &&
               type == other.type
    }

    var background: UIColor {
        return type.background
    }

    var image: UIImage {
        return type.image
    }

    var visited: Bool {
        get {
            return type.isVisited(id: id)
        }
        set {
            type.set(id: id, visited: newValue)
        }
    }

    func show() {
        delegate?.show(location: self)
    }
}
