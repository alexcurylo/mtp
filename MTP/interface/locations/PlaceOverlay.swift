// @copyright Trollwerks Inc.

import MapKit

final class PlaceOverlay: MKPolygon {

    var color: UIColor = Checklist.locations.marker
    private var locationId = 0

    func shows(place: MapInfo) -> Bool {
        return place.checklist == .locations &&
               place.checklistId == locationId
    }

    static func overlays(place: MapInfo,
                         world: WorldMap) -> [PlaceOverlay] {
        guard place.checklist == .locations else { return [] }

        return world.coordinates(location: place.checklistId).map {
            create(place: place, coordinates: $0)
        }
    }

    // as of iOS 12 SDK MKPolygon has no designated initializers
    static func create(place: MapInfo,
                       coordinates: [CLLocationCoordinate2D]) -> PlaceOverlay {
        var coords = coordinates
        let overlay = PlaceOverlay(coordinates: &coords,
                                   count: coords.count).with {
            $0.locationId = place.checklistId
            $0.color = place.isVisited ? .visited : Checklist.locations.marker
        }
        return overlay
    }
}
