// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

struct GeoJSON: Codable {

    struct Feature: Codable {

        // swiftlint:disable:next nesting
        struct Geometry: Codable {

            let coordinates: [[CLLocationCoordinate2D]]
            let type: String

            func validate() throws {
                guard type == "Polygon" else { throw "wrong geometry type" }
                guard !coordinates.isEmpty else { throw "invalid coordinates" }
            }
        }

        // swiftlint:disable:next nesting
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

struct WorldMap: ServiceProvider {

    let locations: [GeoJSON.Feature]

    typealias Bounds = (west: Double, north: Double, east: Double, south: Double)

    let mapBox: Bounds = (west: -182, north: 84, east: 184, south: -91 )
    #if RECALCULATE_MAPBOX
    static var calcBox: Bounds = (0, 0, 0, 0)
    #endif

    init() {
        do {
            guard let file = R.file.worldMapGeojson() else { throw "missing map file" }
            let data = try Data(contentsOf: file)
            let geoJson = try JSONDecoder.mtp.decode(GeoJSON.self,
                                                     from: data)
            locations = geoJson.features.compactMap {
                $0.properties.isValid ? $0 : nil
            }
        } catch {
            locations = []
        }
    }

    func draw(with width: CGFloat) -> UIImage? {
        let outline = width > 700
        let offset: Double
        if outline {
            let center: Double
            if Int(UIScreen.main.scale) % 2 == 0 {
                center = 1 / Double(UIScreen.main.scale * 2)
            } else {
                center = 0
            }
            offset = 0.5 - center
        } else {
            offset = 0.0
        }
        let origin = CLLocationCoordinate2D(latitude: mapBox.north + offset,
                                            longitude: mapBox.west + offset)

        let boxWidth = mapBox.east - mapBox.west
        let scale = width / CGFloat(boxWidth)
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        let boxHeight = mapBox.north - mapBox.south
        let clipAntarctica: CGFloat = 0.94
        let height = width * CGFloat(boxHeight / boxWidth) * clipAntarctica
        let size = CGSize(width: width, height: height.rounded(.down))

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setLineWidth(outline ? 1 / UIScreen.main.scale : 1)
        UIColor.white.setStroke()

        let visits = data.checklists?.locations ?? []
        locations.forEach { location in
            guard let path = location.path(at: origin) else { return }
            path.apply(scaleTransform)

            let visited = visits.contains(location.properties.locid)
            let color: UIColor = visited ? .azureRadiance : .lightGray
            color.setFill()
            path.fill()
            if outline {
                path.stroke()
            }
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        validate()
        return image
    }

    func validate() {
        #if RECALCULATE_MAPBOX
        assert(mapBox.west == WorldMap.calcBox.west.rounded(.down))
        assert(mapBox.north == WorldMap.calcBox.north.rounded(.up))
        assert(mapBox.east == WorldMap.calcBox.east.rounded(.up))
        assert(mapBox.south == WorldMap.calcBox.south.rounded(.down))
        #endif
    }
}

extension GeoJSON.Feature {

    func path(at origin: CLLocationCoordinate2D) -> UIBezierPath? {

        let path = UIBezierPath()
        geometry.coordinates.first?.forEach { coordinate in
            #if RECALCULATE_MAPBOX
            WorldMap.calcBox.west = min(WorldMap.calcBox.west, coordinate.longitude)
            WorldMap.calcBox.north = max(WorldMap.calcBox.north, coordinate.latitude)
            WorldMap.calcBox.east = max(WorldMap.calcBox.east, coordinate.longitude)
            WorldMap.calcBox.south = min(WorldMap.calcBox.south, coordinate.latitude)
            #endif

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