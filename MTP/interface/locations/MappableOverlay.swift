// @copyright Trollwerks Inc.

import MapKit

final class MappableOverlay: MKPolygon {

    var color: UIColor = Checklist.locations.marker
    private var locationId = 0

    var renderer: MKOverlayRenderer {
        return MKPolygonRenderer(polygon: self).with {
            $0.fillColor = color.withAlphaComponent(0.25)
            $0.strokeColor = color.withAlphaComponent(0.5)
            $0.lineWidth = 1
        }
    }

    func shows(mappable: Mappable) -> Bool {
        return mappable.checklist == .locations &&
               mappable.checklistId == locationId
    }

    static func overlays(mappable: Mappable,
                         world: WorldMap) -> [MappableOverlay] {
        guard mappable.checklist == .locations else { return [] }

        return world.coordinates(location: mappable.checklistId).map {
            create(mappable: mappable, coordinates: $0)
        }
    }

    // as of iOS 12 SDK MKPolygon has no designated initializers
    static func create(mappable: Mappable,
                       coordinates: [CLLocationCoordinate2D]) -> MappableOverlay {
        var placeholder = coordinates
        let overlay = MappableOverlay(coordinates: &placeholder,
                                      count: coordinates.count).with {
            $0.locationId = mappable.checklistId
            $0.color = mappable.isVisited ? .visited : Checklist.locations.marker
        }
        return overlay
    }
}

extension Mappable {

    var overlays: [MappableOverlay] {
        return MappableOverlay.overlays(mappable: self,
                                        world: data.worldMap)
    }
}
