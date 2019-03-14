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

struct WorldMap {

    let locations: [GeoJSON.Feature]

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

    func draw(with bounds: CGRect) -> UIImage? {
        let kLatitudeDistance: CGFloat = 200
        let kLongitudeDistance: CGFloat = 200
        let kLongitudeLatitudeRatio: CGFloat = 1.23
        let scaleHorizontal = bounds.width / kLongitudeDistance
        let scaleVertical = bounds.height / kLatitudeDistance
        let scale = min(scaleHorizontal, scaleVertical)
        let scaleTransform = CGAffineTransform(scaleX: scale,
                                               y: scale * kLongitudeLatitudeRatio)

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setLineWidth(0.3)

        locations.forEach { $0.draw(with: scaleTransform) }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension GeoJSON.Feature {

    var path: UIBezierPath? {
        let kLeftLongitude: CLLocationDegrees = -180
        let kTopLatitude: CLLocationDegrees = 90

        let path = UIBezierPath()
        geometry.coordinates.first?.forEach { coordinate in
            let point = CGPoint(x: coordinate.longitude - kLeftLongitude,
                                y: kTopLatitude - coordinate.latitude)
            if path.isEmpty {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()

        return path
    }

    func draw(with transform: CGAffineTransform) {
        guard let outline = path else { return }
        outline.apply(transform)

        UIColor.green.setFill()
        outline.fill()

        UIColor.red.setStroke()
        outline.stroke()
    }
}
