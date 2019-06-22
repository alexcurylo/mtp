// @copyright Trollwerks Inc.

import MapKit

final class PlaceOverlay: MKPolygon {

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var place: PlaceAnnotation!

    var color: UIColor { return place.marker }

    func shows(view: PlaceAnnotationView) -> Bool {
        return view.shows(annotation: place)
    }

    // as of iOS 12 SDK MKPolygon has no designated initializers
    static func create(place: PlaceAnnotation,
                       coordinates: [CLLocationCoordinate2D]) -> PlaceOverlay {
        var coords = coordinates
        let overlay = PlaceOverlay(coordinates: &coords,
                                   count: coords.count)
        overlay.place = place
        return overlay
    }
}
