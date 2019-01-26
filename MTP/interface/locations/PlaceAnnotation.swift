// @copyright Trollwerks Inc.

import MapKit

final class PlaceAnnotation: NSObject, MKAnnotation {

    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    var type: Checklist

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
        return title.hashValue ^ subtitle.hashValue ^ type.rawValue.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? PlaceAnnotation {
            return title == other.title &&
                   subtitle == other.subtitle &&
                   type == other.type
        } else {
            return false
        }
    }
}
