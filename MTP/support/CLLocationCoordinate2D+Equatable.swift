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

    /// Equality operator
    ///
    /// - Parameters:
    ///   - lhs: A thing
    ///   - rhs: Another thing
    /// - Returns: Equality
    public static func == (lhs: CLLocationCoordinate2D,
                           rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D {

    /// Empty coordinate value
    static var zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    /// Is coordinate empty?
    var isZero: Bool {
        return self == .zero
    }

    /// CLLocation constructor convenience
    var location: CLLocation {
        return CLLocation(latitude: latitude,
                          longitude: longitude)
    }

    /// Distance calculation
    ///
    /// - Parameter from: CLLocationCoordinate2D
    /// - Returns: Distance
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        return location.distance(from: from.location)
    }

    /// Distance calculation
    ///
    /// - Parameter from: CLLocation
    /// - Returns: Distance
    func distance(from: CLLocation) -> CLLocationDistance {
        return location.distance(from: from)
    }
}

extension CLLocationDistance {

    /// Range appropriate formatting of kilometers
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

/// Helper for determining region needed to show map cluster annotations
struct ClusterRegion {

    private var left: CLLocationDegrees = 0
    private var top: CLLocationDegrees = 0
    private var right: CLLocationDegrees = 0
    private var bottom: CLLocationDegrees = 0

    private var latitudeDelta: CLLocationDegrees {
        return (bottom + 90) - (top + 90)
    }
    private var longitudeDelta: CLLocationDegrees {
        return (right + 180) - (left + 180)
    }

    /// Accessor for size to fit on screen
    var maxDelta: CLLocationDegrees {
        return max(latitudeDelta, longitudeDelta)
    }

    /// Construct region from coordinates
    ///
    /// - Parameter coordinates: Coordinates
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

    /// Construct region from an annotation
    ///
    /// - Parameter mappables: MappablesAnnotation
    init(mappables: MappablesAnnotation) {
        let coordinates = mappables.mappables.map { $0.coordinate }
        self.init(coordinates: coordinates)
    }
}
