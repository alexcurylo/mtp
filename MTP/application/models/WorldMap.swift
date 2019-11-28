// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

/// MTP world/UN country GeoJSON file definition
private struct GeoJSON: Codable {

    struct Feature: Codable {

        struct Geometry: Codable {

            let coordinates: [[CLLocationCoordinate2D]]
            let type: String

            func validate() throws {
                guard type == "Polygon" else { throw "wrong geometry type" }
                guard !coordinates.isEmpty else { throw "empty coordinates" }
                guard coordinates.count == 1 else { throw ">1 coordinates" }
            }
        }

        struct Properties: Codable {

            let locationName: String
            let locid: Int

            var isValid: Bool {
                // 9 completely empty, plus "Vietnam" with locid 0
                return !locationName.isEmpty && locid > 0
            }

           func validate() throws {
                guard isValid else { throw "invalid properties" }
           }
        }

        let geometry: Geometry
        let id: String
        let properties: Properties
        let type: String

        func validate() throws {
            guard type == "Feature" else { throw "wrong feature type" }
            try properties.validate()
            try geometry.validate()
        }
    }

    let features: [Feature]
    let type: String

    func validate() throws {
        guard type == "FeatureCollection" else { throw "wrong file type" }
        try features.forEach { try $0.validate() }
    }
}

private struct MapBoxCalculator {

    typealias Bounds = (west: CLLocationDegrees,
                        north: CLLocationDegrees,
                        east: CLLocationDegrees,
                        south: CLLocationDegrees)

    static let mapBox: Bounds = (west: -182, north: 84, east: 184, south: -91 )

    private var calcBox: Bounds = (0, 0, 0, 0)

    mutating func add(coordinate: CLLocationCoordinate2D) {
        calcBox.west = min(calcBox.west, coordinate.longitude)
        calcBox.north = max(calcBox.north, coordinate.latitude)
        calcBox.east = max(calcBox.east, coordinate.longitude)
        calcBox.south = min(calcBox.south, coordinate.latitude)
    }

    func validate() {
        assert(Self.mapBox.west == calcBox.west.rounded(.down))
        assert(Self.mapBox.north == calcBox.north.rounded(.up))
        assert(Self.mapBox.east == calcBox.east.rounded(.up))
        assert(Self.mapBox.south == calcBox.south.rounded(.down))
        print("map box is valid with latest geojson")
    }
}

/// For validating geometry when worldMapGeojson is updated
private var mbc: MapBoxCalculator? //= MapBoxCalculator()

/// World map definition
struct WorldMap: ServiceProvider {

    private var locationPaths: [Int: UIBezierPath] = [:]
    private let locations: [GeoJSON.Feature]
    private let fullWidth = CGFloat(3_000)
    private let clipAntarctica = CGFloat(0.94) // clip uneven lower edges
    private let boxWidth: Double
    private let boxHeight: Double
    private let origin: CLLocationCoordinate2D

    /// :nodoc:
    init() {
        let box = MapBoxCalculator.mapBox
        boxWidth = box.east - box.west
        boxHeight = box.north - box.south
        origin = CLLocationCoordinate2D(latitude: box.north,
                                        longitude: box.west)
        do {
            guard let file = R.file.worldMapGeojson() else { throw "missing map file" }
            let data = try Data(contentsOf: file)
            let geoJson = try JSONDecoder.mtp.decode(GeoJSON.self,
                                                     from: data)
            locations = geoJson.features.compactMap {
                $0.properties.isValid ? $0 : nil
            }
            createLocationPaths()
            mbc?.validate()
        } catch {
            locations = []
        }
    }

    /// Expanded view render size
    var fullSize: CGSize {
        CGSize(width: fullWidth,
               height: height(for: fullWidth))
    }

    /// Render height for width
    func height(for width: CGFloat) -> CGFloat {
        (width * CGFloat(boxHeight / boxWidth) * clipAntarctica).rounded(.down)
    }

    /// Render world map profile shapes
    /// - Parameters:
    ///   - map: UIView
    ///   - visits: Visited locations
    ///   - width: Rendering width
    func render(map: UIView,
                visits: [Int],
                width: CGFloat) {
        shapes(view: map,
               visits: visits,
               width: width)
    }

    /// Does location contain coordinate?
    /// - Parameters:
    ///   - coordinate: Coordinate
    ///   - id: Location ID
    /// - Returns: Containment
    func contains(coordinate: CLLocationCoordinate2D,
                  location id: Int) -> Bool {
        for location in locations {
            guard location.properties.locid == id else { continue }
            if location.contains(coordinate: coordinate) {
                return true
            }
        }
        return false
    }

    /// Location containing coordinate
    /// - Parameters:
    ///   - coordinate: Coordinate
    /// - Returns: Location if found
    func location(of coordinate: CLLocationCoordinate2D) -> Location? {
        for location in locations {
            if location.contains(coordinate: coordinate) {
                return data.get(location: location.properties.locid)
            }
        }
        return nil
    }

    /// Coordinates for map overlay
    /// - Parameter id: LocationID
    /// - Returns: Coordinate list
    func coordinates(location id: Int) -> [[CLLocationCoordinate2D]] {
        return locations.compactMap {
            guard $0.properties.locid == id else { return nil }
            return $0.geometry.coordinates.first
        }
    }
}

// MARK: - Private

private extension WorldMap {

    func shapes(view: UIView,
                visits: [Int],
                width: CGFloat) {
        let outline = width >= fullWidth
        let scale = width / CGFloat(boxWidth)
        var transform = CGAffineTransform(scaleX: scale, y: scale)

        for (locid, path) in locationPaths {
            let visited = visits.contains(locid)
            let color: UIColor = visited ? .azureRadiance : .lightGray

            let layer = CAShapeLayer()
            layer.path = path.cgPath.copy(using: &transform)
            // these need setting for proper hit testing?
            //let bounds = draw.cgPath.boundingBox
            //layer.position = .zero // bounds.origin
            //layer.bounds = CGRect(origin: .zero, size: bounds.size)
            layer.style = ["locid": locid]
            layer.fillColor = color.cgColor
            if outline {
                layer.lineWidth = 1
                layer.strokeColor = UIColor.white.cgColor
            }
            view.layer.addSublayer(layer)
        }
    }

    mutating func createLocationPaths() {
        locations.forEach { location in
            let id = location.id
            let path: UIBezierPath
            if let drawn = location.path(at: origin) {
                path = drawn
                let locid = location.properties.locid
                if let partial = locationPaths[locid] {
                    partial.append(path)
                } else {
                    locationPaths[locid] = path
                }
            } else {
                log.error("undrawable id detected: \(id)")
            }
        }
    }
}

// MARK: - Private

private extension GeoJSON.Feature {

    func contains(coordinate test: CLLocationCoordinate2D) -> Bool {
        for coordinates in geometry.coordinates {
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
        return false
    }

    func path(at origin: CLLocationCoordinate2D) -> UIBezierPath? {
        let path = UIBezierPath()
        geometry.coordinates.first?.forEach { coordinate in
            mbc?.add(coordinate: coordinate)
            let point = CGPoint(x: coordinate.longitude - origin.longitude,
                                y: origin.latitude - coordinate.latitude)
            if path.isEmpty {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()

        return path
    }
}
