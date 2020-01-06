// @copyright Trollwerks Inc.

/// MTP world/UN country GeoJSON file definition
struct GeoJSON: Codable {

    /// A CLLocationDegrees rectangle
    typealias Bounds = (west: CLLocationDegrees,
                        north: CLLocationDegrees,
                        east: CLLocationDegrees,
                        south: CLLocationDegrees)

    /// Point list for a Polygon
    typealias Polygon = [[CLLocationCoordinate2D]]
    // Point list for a MultiPolygon
    typealias MultiPolygon = [Polygon]

    /// A path which is part of a location
    struct Feature: Codable {

        fileprivate struct Geometry: Codable {

            // swiftlint:disable:next nesting
            private enum GeometryType: String, Codable {
                case polygon = "Polygon"
                case multiPolygon = "MultiPolygon"
            }

            // swiftlint:disable:next nesting
            private enum CodingKeys: CodingKey {
                case coordinates
                case type
            }

            private let type: GeometryType
            fileprivate let polygons: MultiPolygon

            init(from decoder: Decoder) throws {
                 let values = try decoder.container(keyedBy: CodingKeys.self)
                 type = try values.decode(GeometryType.self, forKey: .type)
                switch type {
                case .multiPolygon:
                    polygons = try values.decode(MultiPolygon.self, forKey: .coordinates)
                case .polygon:
                    let polygon = try values.decode(Polygon.self, forKey: .coordinates)
                    polygons = [polygon]
                }
             }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(type.rawValue, forKey: .type)
                switch type {
                case .multiPolygon:
                    try container.encode(polygons, forKey: .coordinates)
                case .polygon:
                    try container.encode(polygons[0], forKey: .coordinates)
                }
            }

            fileprivate func validate() throws {

                func validate(polygon: Polygon) throws {
                    guard !polygon.isEmpty else { throw "empty polygon" }
                    guard polygon.count == 1 else { throw ">1 polygon" }
                }

                switch type {
                case .multiPolygon:
                    try polygons.forEach { try validate(polygon: $0) }
                case .polygon:
                    try validate(polygon: polygons[0])
                }
            }
        }

        fileprivate struct Properties: Codable {

            private let locationName: String
            fileprivate let locid: Int

            fileprivate var isValid: Bool {
                // 9 completely empty, plus "Vietnam" with locid 0
                return !locationName.isEmpty && locid > 0
            }

           fileprivate func validate() throws {
                guard isValid else { throw "invalid properties" }
           }
        }

        fileprivate let geometry: Geometry
        private let id: String
        fileprivate let properties: Properties
        private let type: String

        fileprivate func validate() throws {
            guard type == "Feature" else { throw "wrong feature type" }
            try properties.validate()
            try geometry.validate()
        }
    }

    private let features: [Feature]
    private let type: String

    private func validate() throws {
        guard type == "FeatureCollection" else { throw "wrong file type" }
        try features.forEach { try $0.validate() }
    }
}

/// Calculates display box specifications
struct MapBoxCalculator {

    /// Bounds calculated from parsing GeoJSON file
    var bounds: GeoJSON.Bounds = (0, 0, 0, 0)

    fileprivate mutating func add(coordinate: CLLocationCoordinate2D) {
        bounds.west = min(bounds.west, coordinate.longitude)
        bounds.north = max(bounds.north, coordinate.latitude)
        bounds.east = max(bounds.east, coordinate.longitude)
        bounds.south = min(bounds.south, coordinate.latitude)
    }

    /// Sanity checking
    func validate() -> Bool {
        #if targetEnvironment(simulator)
        let expected: GeoJSON.Bounds = (west: -183,
                                        north: 84,
                                        east: 184,
                                        south: -91)
        assert(expected.west == bounds.west.rounded(.down))
        assert(expected.north == bounds.north.rounded(.up))
        assert(expected.east == bounds.east.rounded(.up))
        assert(expected.south == bounds.south.rounded(.down))
        print("map box is expected with latest geojson")
        #endif
        return true
    }
}

// MARK: - Helpers

extension GeoJSON {

    var drawables: ([Feature], Bounds) {
        let locations = features.compactMap {
            $0.properties.isValid ? $0 : nil
        }

        var mbc = MapBoxCalculator()
        locations.forEach { location in
            for polygon in location.geometry.polygons {
                polygon.first?.forEach { coordinate in
                    mbc.add(coordinate: coordinate)
                }
            }
        }
        _ = mbc.validate()

        return (locations, mbc.bounds)
    }
}

extension GeoJSON.Feature {

    /// MTP ID of feature
    var mtpId: Int { properties.locid }

    /// Coordinates for map overlay
    var coordinates: [[CLLocationCoordinate2D]] {
        geometry.polygons.compactMap { $0.first }
    }

    /// Does this feature contain this coordinate?
    /// - Parameter test: Coordinate
    func contains(coordinate test: CLLocationCoordinate2D) -> Bool {
        for polygon in geometry.polygons {
            for coordinates in polygon {
                guard var pJ = coordinates.last else { continue }
                var contains = false
                for pI in coordinates {
                    if ((pI.latitude >= test.latitude) != (pJ.latitude >= test.latitude)) &&
                       (test.longitude <= (pJ.longitude - pI.longitude) *
                                          (test.latitude - pI.latitude) /
                                          (pJ.latitude - pI.latitude) +
                                          pI.longitude) {
                        contains.toggle()
                    }
                    pJ = pI
                }
                if contains {
                    return true
                }
            }
        }
        return false
    }

    /// Calculate path containing a feature
    /// - Parameter origin: Map origin
    func path(at origin: CLLocationCoordinate2D) -> UIBezierPath? {
        let multipath = UIBezierPath()

        for polygon in geometry.polygons {
            let path = UIBezierPath()
            polygon.first?.forEach { coordinate in
                let point = CGPoint(x: coordinate.longitude - origin.longitude,
                                    y: origin.latitude - coordinate.latitude)
                if path.isEmpty {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.close()
            multipath.append(path)
        }

        return multipath
    }
}
