// @copyright Trollwerks Inc.

import CoreLocation

/// What kind of permission to ask the user for
///
/// - always: after initial grant
/// - whenInUse: when in use - initially
enum LocationPermission {
    case always
    case whenInUse
}

/// Interactivity control on permission check
///
/// - ask: Ask user for permission
/// - dontAsk: Don't ask user for permission
enum PermissionTrigger {
    case ask
    case dontAsk
}

/// Track distances to places
typealias Distances = [String: CLLocationDistance]

/// Provides location-related functionality
protocol LocationService: Mapper, ServiceProvider {

    var here: CLLocationCoordinate2D? { get }
    var inside: Location? { get }
    var distances: Distances { get }

    func distance(to: Mappable) -> CLLocationDistance
    func nearest(list: Checklist,
                 id: Int,
                 to coordinate: CLLocationCoordinate2D) -> Mappable?

    func request(permission: LocationPermission)
    func start(permission: LocationPermission)

    func insert<T>(tracker: T) where T: LocationTracker, T: Hashable
    func remove<T>(tracker: T) where T: LocationTracker, T: Hashable

    func inject(handler: LocationHandler)

    func checkDistances()
}

extension LocationService {

    func distance(to: Mappable) -> CLLocationDistance {
        return distances[to.dbKey] ?? 0
    }

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

class LocationServiceImpl: LocationService {

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

    var distances: Distances {
        return handler?.distances ?? [:]
    }

    func nearest(list: Checklist,
                 id: Int,
                 to coordinate: CLLocationCoordinate2D) -> Mappable? {
        var distance: CLLocationDistance = 99_999
        let visited = list.visited
        var nearest: Mappable?
        for other in data.get(mappables: list) {
            guard !visited.contains(other.checklistId),
                  other.checklistId != id else { continue }

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

    func checkDistances() {
        handler?.checkDistances()
    }
}

// MARK: - Mapper

extension LocationServiceImpl: Mapper {

    func close(mappable: Mappable) {
        handler?.broadcast(mappable: mappable) { $0.close(mappable: $1) }
    }

    func notify(mappable: Mappable, triggered: Date) {
        handler?.broadcast(mappable: mappable) { $0.notify(mappable: $1, triggered: triggered) }
    }

    func reveal(mappable: Mappable, callout: Bool) {
        handler?.broadcast(mappable: mappable) { $0.reveal(mappable: $1, callout: callout) }
    }

    func show(mappable: Mappable) {
        handler?.broadcast(mappable: mappable) { $0.show(mappable: $1) }
    }

    func update(mappable: Mappable) {
        handler?.broadcast(mappable: mappable) { $0.update(mappable: $1) }
    }
}

final class LocationServiceStub: LocationServiceImpl {

    override func request(permission: LocationPermission) { }

    override func start(permission: LocationPermission) { }
}
