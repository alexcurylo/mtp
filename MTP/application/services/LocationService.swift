// @copyright Trollwerks Inc.

import CoreLocation

enum LocationPermission {
    case always
    case whenInUse
}

enum PermissionTrigger {
    case ask
    case dontAsk
}

protocol LocationService: ServiceProvider {

    var here: CLLocationCoordinate2D? { get }
    var inside: Location? { get }

    func nearest(list: Checklist,
                 id: Int,
                 to coordinate: CLLocationCoordinate2D) -> PlaceAnnotation?

    func annotations() -> Set<PlaceAnnotation>
    func annotations(list: Checklist) -> Set<PlaceAnnotation>

    func insert<T>(tracker: T) where T: LocationTracker, T: Hashable
    func remove<T>(tracker: T) where T: LocationTracker, T: Hashable

    func request(permission: LocationPermission)
    func start(permission: LocationPermission)

    func inject(handler: LocationHandler)
}

extension LocationService {

    @discardableResult func start(tracker: LocationTracker?) -> CLAuthorizationStatus {
        let ask: PermissionTrigger = tracker == nil ? .dontAsk : .ask
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            loc.start(permission: .always)
            if ask == .ask {
                note.authorizeNotifications { _ in }
            }
        case .authorizedWhenInUse:
            loc.start(permission: .whenInUse)
            if ask == .ask {
                loc.request(permission: .always)
            }
        case .denied, .restricted:
            if ask == .ask {
                tracker?.alertLocationAccessNeeded()
            }
        case .notDetermined:
            if ask == .ask {
                loc.request(permission: .whenInUse)
            }
        @unknown default:
            log.error("handle authorization status \(status)!")
        }
        return status
    }
}

final class LocationServiceImpl: LocationService {

    private var handler: LocationHandler?
    private var manager: CLLocationManager?

    func inject(handler: LocationHandler) {
        self.handler = handler
        manager = handler.locationManager
        start(tracker: nil)
    }

    var here: CLLocationCoordinate2D? {
        return handler?.lastCoordinate?.coordinate ?? manager?.location?.coordinate
    }

    var inside: Location? {
        return data.get(location: handler?.lastInside)
    }

    func annotations() -> Set<PlaceAnnotation> {
        return handler?.annotations(list: nil) ?? []
    }

    func annotations(list: Checklist) -> Set<PlaceAnnotation> {
        return handler?.annotations(list: list) ?? []
    }

    func nearest(list: Checklist,
                 id: Int,
                 to coordinate: CLLocationCoordinate2D) -> PlaceAnnotation? {
        var distance: CLLocationDistance = 99_999
        let visited = list.visited
        var nearest: PlaceAnnotation?
        for other in annotations(list: list) {
            guard !visited.contains(other.id),
                  other.id != id else { continue }

            let otherDistance = other.coordinate.distance(from: coordinate)
            if otherDistance < distance {
                nearest = other
                distance = otherDistance
            }
        }
        return nearest
    }

    func insert<T>(tracker: T) where T: LocationTracker, T: Hashable {
        handler?.insert(tracker: tracker)
    }

    func remove<T>(tracker: T) where T: LocationTracker, T: Hashable {
        handler?.remove(tracker: tracker)
    }

    func request(permission: LocationPermission) {
        guard CLLocationManager.locationServicesEnabled(),
              let manager = manager else { return }

        switch permission {
        case .always:
            manager.requestAlwaysAuthorization()
        case.whenInUse:
            manager.requestWhenInUseAuthorization()
        }
    }

    func start(permission: LocationPermission) {
        guard CLLocationManager.locationServicesEnabled(),
            let manager = manager else { return }

        switch permission {
        case .always:
            manager.startUpdatingLocation()
            manager.allowsBackgroundLocationUpdates = true
            manager.pausesLocationUpdatesAutomatically = false
            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                manager.startMonitoringSignificantLocationChanges()
            }
        case .whenInUse:
            manager.startUpdatingLocation()
        }
    }
}
