// @copyright Trollwerks Inc.

import CoreLocation

extension CLLocationCoordinate2D: Equatable {

    public static func == (lhs: CLLocationCoordinate2D,
                           rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    static var zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    var isZero: Bool {
        return self == .zero
    }
}
