// @copyright Trollwerks Inc.

import MapKit

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

extension CLLocationDistance {

    var formatted: String {
        let km = self / 1_000
        let formatted: String
        switch km {
        case ..<1:
            formatted = String(format: "%.2f", km)
        case ..<10:
            formatted = String(format: "%.1f", km)
        default:
            formatted = Int(km).grouped
        }
        return L.km(formatted)
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

    init(cluster: MKClusterAnnotation) {
        if let first = cluster.memberAnnotations.first?.coordinate {
            left = first.longitude
            top = first.latitude
            right = first.longitude
            bottom = first.latitude
        }
        for next in cluster.memberAnnotations.dropFirst() {
            left = min(left, next.coordinate.longitude)
            top = min(top, next.coordinate.latitude)
            right = max(right, next.coordinate.longitude)
            bottom = max(bottom, next.coordinate.latitude)
        }
    }
}

extension MKClusterAnnotation {

    var region: ClusterRegion {
        return ClusterRegion(cluster: self)
    }
}
