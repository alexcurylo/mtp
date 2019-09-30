// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

/// GeoJSON file definition
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

/// World map definition
struct WorldMap: ServiceProvider {

    private let locations: [GeoJSON.Feature]

    private typealias Bounds = (west: Double, north: Double, east: Double, south: Double)

    private let mapBox: Bounds = (west: -182, north: 84, east: 184, south: -91 )
    #if RECALCULATE_MAPBOX
    private static var calcBox: Bounds = (0, 0, 0, 0)
    #endif

    /// :nodoc:
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

    /// Draw world map for profile
    /// - Parameters:
    ///   - visits: Visited locations
    ///   - width: Rendering width
    /// - Returns: Map image
    func draw(visits: [Int],
              width: CGFloat) -> UIImage? {
        let renderWidth: CGFloat = 2000 //width
        let outline = false //width > 700
        let offset: Double
        if outline && false {
            let center: Double
            if Int(UIScreen.main.scale).isMultiple(of: 2) {
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
        let scale = renderWidth / CGFloat(boxWidth)
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        let boxHeight = mapBox.north - mapBox.south
        let clipAntarctica: CGFloat = 0.94
        let height = renderWidth * CGFloat(boxHeight / boxWidth) * clipAntarctica
        let size = CGSize(width: renderWidth, height: height.rounded(.down))

        let image = renderImage(visits: visits,
                                origin: origin,
                                size: size,
                                scaleTransform: scaleTransform,
                                outline: outline)
        renderPDF(visits: visits,
                  origin: origin,
                  size: size,
                  scaleTransform: scaleTransform,
                  outline: outline)

        validate()
        return image
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

    static var _maps = 1

    func renderPDF(visits: [Int],
                   origin: CLLocationCoordinate2D,
                   size: CGSize,
                   scaleTransform: CGAffineTransform,
                   outline: Bool) {
        return
        //let pdfData = NSMutableData()
        //UIGraphicsBeginPDFContextToData(pdfData, aView.bounds , nil)

        guard let path = try? "map\(WorldMap._maps).pdf".desktopURL().path else { return }
        WorldMap._maps += 1
        let bounds = CGRect(origin: .zero, size: size)
        UIGraphicsBeginPDFContextToFile(path, bounds, [:])

        UIGraphicsBeginPDFPage()

        render(visits: visits,
               origin: origin,
               size: size,
               scaleTransform: scaleTransform,
               outline: outline)

        UIGraphicsEndPDFContext()
    }

    /*
    -(UIImage *)renderPDFPageToImage:(int)pageNumber//NSOPERATION?
    {
     //you may not want to permanently (app life) retain doc ref

     CGSize size = CGSizeMake(x,y);
     UIGraphicsBeginImageContext(size);
     CGContextRef context = UIGraphicsGetCurrentContext();

     CGContextTranslateCTM(context, 0, 750);
     CGContextScaleCTM(context, 1.0, -1.0);

     CGPDFPageRef page;  //Move to class member

        page = CGPDFDocumentGetPage (myDocumentRef, pageNumber);
        CGContextDrawPDFPage (context, page);

     UIImage * pdfImage = UIGraphicsGetImageFromCurrentImageContext();//autoreleased
     UIGraphicsEndImageContext();
     return pdfImage;

    }
    */

    func renderImage(visits: [Int],
                     origin: CLLocationCoordinate2D,
                     size: CGSize,
                     scaleTransform: CGAffineTransform,
                     outline: Bool) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        render(visits: visits,
               origin: origin,
               size: size,
               scaleTransform: scaleTransform,
               outline: outline)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func render(visits: [Int],
                origin: CLLocationCoordinate2D,
                size: CGSize,
                scaleTransform: CGAffineTransform,
                outline: Bool) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setShouldAntialias(true)
        context.setLineWidth(0)
        UIColor.white.setStroke()
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
