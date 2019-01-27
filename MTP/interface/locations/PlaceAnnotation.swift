// @copyright Trollwerks Inc.

import MapKit

final class PlaceAnnotation: NSObject, MKAnnotation {

    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    var type: Checklist
    var identifier: String {
        return type.rawValue
    }

    init(type: Checklist,
         coordinate: CLLocationCoordinate2D,
         title: String = "",
         subtitle: String = "") {
        self.type = type
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }

    override var hash: Int {
        return title.hashValue ^ identifier.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlaceAnnotation else {
            return false
        }
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
}

extension CLLocationCoordinate2D: Equatable {

    public static func == (lhs: CLLocationCoordinate2D,
                           rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
