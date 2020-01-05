// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

/// World map definition
struct WorldMap: ServiceProvider {

    /// Location ID layer style annotation
    static let locid = "locid"

    private var locationPaths: [Int: UIBezierPath] = [:]
    private var locations: [GeoJSON.Feature] = []
    private let fullWidth = CGFloat(3_000)
    private let clipAntarctica = CGFloat(0.94) // clip uneven lower edges
    private var boxWidth: Double = 0
    private var boxHeight: Double = 0
    private var origin: CLLocationCoordinate2D = .zero

    /// :nodoc:
    init() {
        do {
            guard let file = R.file.worldMapGeojson() else { throw "missing map file" }
            let data = try Data(contentsOf: file)
            let geoJson = try JSONDecoder.mtp.decode(GeoJSON.self,
                                                     from: data)
            set(world: geoJson)
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
    func render(layer: CALayer,
                visits: [Int],
                width: CGFloat) {
        shapes(layer: layer,
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
            guard location.mtpId == id else { continue }
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
                return data.get(location: location.mtpId)
            }
        }
        return nil
    }

    /// Coordinates for map overlay
    /// - Parameter id: LocationID
    /// - Returns: Coordinate list
    func coordinates(location id: Int) -> [[CLLocationCoordinate2D]] {
        locations.reduce(into: []) {
            if $1.mtpId == id { $0 += $1.coordinates }
        }
    }

    /// Update location features
    /// - Parameter map: GeoJSON file
    mutating func set(world map: GeoJSON) {
        let (features, bounds) = map.drawables
        locations = features
        boxWidth = bounds.east - bounds.west
        boxHeight = bounds.north - bounds.south
        origin = CLLocationCoordinate2D(latitude: bounds.north,
                                        longitude: bounds.west)
        locationPaths = [:]
        createLocationPaths()
    }
}

// MARK: - Private

private extension WorldMap {

    func shapes(layer: CALayer,
                visits: [Int],
                width: CGFloat) {
        let outline = width >= fullWidth
        let scale = width / CGFloat(boxWidth)
        var transform = CGAffineTransform(scaleX: scale, y: scale)

        layer.frame = CGRect(origin: .zero,
                             size: CGSize(width: width,
                                          height: height(for: width)))

        for (locid, path) in locationPaths {
            let visited = visits.contains(locid)
            let color: UIColor = visited ? .azureRadiance : .lightGray

            let shape = CAShapeLayer()
            shape.path = path.cgPath.copy(using: &transform)
            // bounds needs setting for proper hit testing
            // 63: frame (0.0, 0.0, 0.0, 0.0) bounds (0.0, 0.0, 0.0, 0.0) position ((0.0, 0.0)
            //     box (285.7144589230391, 51.89920348478381, 6.815899839575707, 4.123800016916704)
            // swiftlint:disable:next line_length
            //print("\(locid): frame \(shape.frame) bounds \(shape.bounds) position (\(shape.position)\n     box \(shape.path!.boundingBox)")
            shape.style = [Self.locid: locid]
            shape.fillColor = color.cgColor
            if outline {
                shape.lineWidth = 1
                shape.strokeColor = UIColor.white.cgColor
            }
            layer.addSublayer(shape)
        }
    }

    mutating func createLocationPaths() {
        locations.forEach { location in
            let mtpId = location.mtpId
            let path: UIBezierPath
            if let drawn = location.path(at: origin) {
                path = drawn
                if let partial = locationPaths[mtpId] {
                    partial.append(path)
                } else {
                    locationPaths[mtpId] = path
                }
            } else {
                log.error("undrawable id detected: \(mtpId)")
            }
        }
    }
}
