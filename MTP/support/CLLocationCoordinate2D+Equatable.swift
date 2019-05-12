// @copyright Trollwerks Inc.

import CoreLocation

extension CLLocationCoordinate2D: Codable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D: Equatable {

    public static func == (lhs: CLLocationCoordinate2D,
                           rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D {

    static var zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    var isZero: Bool {
        return self == .zero
    }

    var location: CLLocation {
        return CLLocation(latitude: latitude,
                          longitude: longitude)
    }

    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        return location.distance(from: from.location)
    }

    func distance(from: CLLocation) -> CLLocationDistance {
        return location.distance(from: from)
    }
}
