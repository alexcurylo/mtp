// @copyright Trollwerks Inc.

import MapKit

/// Add Codable compliance to CLLocationCoordinate2D
extension CLLocationCoordinate2D: Codable {

    /// Initialize with decoder
    ///
    /// - Parameter decoder: Decoder
    /// - Throws: Decoding error
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }

    /// Encode to encoder
    ///
    /// - Parameter encoder: Encoder
    /// - Throws: Encoding error
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
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

extension CLLocationDistance {

    var formatted: String {
        let km = self / 1_000
        let formatted: String
        switch km {
        case ..<1:
            let grouped = Int(self).grouped
            formatted = L.meters(grouped)
        case ..<10:
            let tenths = String(format: "%.1f", km)
            formatted = L.kilometers(tenths)
        default:
            let grouped = Int(km).grouped
            formatted = L.kilometers(grouped)
        }
        return formatted
    }
}

struct ClusterRegion {

    var left: CLLocationDegrees = 0
    var top: CLLocationDegrees = 0
    var right: CLLocationDegrees = 0
    var bottom: CLLocationDegrees = 0

    var latitudeDelta: CLLocationDegrees {
        return (bottom + 90) - (top + 90)
    }
    var longitudeDelta: CLLocationDegrees {
        return (right + 180) - (left + 180)
    }
    var maxDelta: CLLocationDegrees {
        return max(latitudeDelta, longitudeDelta)
    }

    init(coordinates: [CLLocationCoordinate2D]) {
        if let first = coordinates.first {
            left = first.longitude
            top = first.latitude
            right = first.longitude
            bottom = first.latitude
        }
        for next in coordinates.dropFirst() {
            left = min(left, next.longitude)
            top = min(top, next.latitude)
            right = max(right, next.longitude)
            bottom = max(bottom, next.latitude)
        }
    }

    init(cluster: MKClusterAnnotation) {
        let coordinates = cluster.memberAnnotations.map { $0.coordinate }
        self.init(coordinates: coordinates)
    }

    init(mappables: MappablesAnnotation) {
        let coordinates = mappables.mappables.map { $0.coordinate }
        self.init(coordinates: coordinates)
    }
}
