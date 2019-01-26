// @copyright Trollwerks Inc.

import MapKit

final class PlaceAnnotation: NSObject, MKAnnotation {

    @objc dynamic var coordinate = CLLocationCoordinate2D()
    var title: String? = ""
    var subtitle: String? = ""

    var type: Checklist

    init(type: Checklist) {
        self.type = type
        super.init()
    }
}

extension Checklist {

    var annotation: PlaceAnnotation {
        return PlaceAnnotation(type: self)
    }
}
