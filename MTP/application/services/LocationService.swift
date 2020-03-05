// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

/// What kind of permission to ask the user for
enum LocationPermission {

    /// after initial grant
    case always
    /// initially
    case whenInUse
}

/// Interactivity control on permission check
enum PermissionTrigger {

    /// Ask user for permission
    case ask
    /// Don't ask user for permission
    case dontAsk
}

/// Track distances to places
typealias Distances = [String: CLLocationDistance]

/// Provides location-related functionality
protocol LocationService: Mapper, ServiceProvider {

    /// Current coordinate measured
    var current: CLLocationCoordinate2D? { get }
    /// Last coordinate measured
    var here: CLLocationCoordinate2D? { get }
    /// Last location contained in
    var inside: Location? { get }
    /// Last calculated distances
    var distances: Distances { get }

    /// Distance to a place
    /// - Parameter to: Place
    /// - Returns: Distance
    func distance(to: Mappable) -> CLLocationDistance
    /// Calculate nearest place of type
    /// - Parameters:
    ///   - list: Checklist
    ///   - id: Place ID
    ///   - coordinate: Center
    /// - Returns: Nearest place if found
    func nearest(list: Checklist,
                 id: Int,
                 to coordinate: CLLocationCoordinate2D) -> Mappable?

    /// Request permission
    /// - Parameter permission: Permission
    func request(permission: LocationPermission)
    /// Start with intended permission
    /// - Parameter permission: Permission
    func start(permission: LocationPermission)

    /// Insert a typed tracker in our listeners
    /// - Parameter tracker: New listener
    func insert<T>(tracker: T) where T: LocationTracker, T: Hashable
    /// Remove a typed tracker from our listeners
    /// - Parameter tracker: Former listener
    func remove<T>(tracker: T) where T: LocationTracker, T: Hashable

    /// Handle dependency injection
    /// - Parameter handler: Location handler
    func inject(handler: LocationHandler)

    /// Calculate distances
    func calculateDistances()
}

extension LocationService {

    /// Distance to a place
    /// - Parameter to: Place
    /// - Returns: Distance
    func distance(to: Mappable) -> CLLocationDistance {
        distances[to.dbKey] ?? 0
    }

    /// Start with tracker
    /// - Parameter tracker: Tracker
    /// - Returns: Authorization
    @discardableResult func start(tracker: LocationTracker?) -> CLAuthorizationStatus {
        let ask: PermissionTrigger = tracker == nil ? .dontAsk : .ask
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            loc.start(permission: .always)
            if ask == .ask {
                note.authorizeNotifications { granted in
                    guard granted else { return }

                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
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

/// Production implementation of LocationService
class LocationServiceImpl: LocationService {

    private var handler: LocationHandler?
    private var manager: CLLocationManager?

    /// Handle dependency injection
    /// - Parameter handler: Location handler
    func inject(handler: LocationHandler) {
        self.handler = handler
        manager = handler.locationManager
        start(tracker: nil)
    }

    /// Current coordinate measured
    var current: CLLocationCoordinate2D? {
        manager?.location?.coordinate ?? handler?.lastCoordinate?.coordinate
    }

    /// Last coordinate measured
    var here: CLLocationCoordinate2D? {
        handler?.lastCoordinate?.coordinate ?? manager?.location?.coordinate
    }

    /// Last location contained in
    var inside: Location? {
        data.get(location: handler?.lastInside)
    }

    /// Last calculated distances
    var distances: Distances {
        handler?.distances ?? [:]
    }

    /// Calculate nearest place of type
    /// - Parameters:
    ///   - list: Checklist
    ///   - id: Place ID
    ///   - coordinate: Center
    /// - Returns: Nearest place if found
    func nearest(list: Checklist,
                 id: Int,
                 to coordinate: CLLocationCoordinate2D) -> Mappable? {
        var distance: CLLocationDistance = 99_999
        let visited = list.visited
        var nearest: Mappable?
        for other in data.get(visibles: list) {
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

    /// Insert a typed tracker in our listeners
    /// - Parameter tracker: New listener
    func insert<T>(tracker: T) where T: LocationTracker, T: Hashable {
        handler?.insert(tracker: tracker)
    }

    /// Remove a typed tracker from our listeners
    /// - Parameter tracker: Former listener
    func remove<T>(tracker: T) where T: LocationTracker, T: Hashable {
        handler?.remove(tracker: tracker)
    }

    /// Request permission
    /// - Parameter permission: Permission
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

    /// Start with intended permission
    /// - Parameter permission: Permission
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

    /// Calculate distances
    func calculateDistances() {
        handler?.calculateDistances()
    }
}

// MARK: - Mapper

extension LocationServiceImpl: Mapper {

    /// Show Add Photo screen
    /// - Parameter mappable: Place
    func add(photo mappable: Mappable) {
        handler?.broadcast(mappable: mappable) { $0.add(photo: $1) }
    }

    /// Show Add Post screen
    /// - Parameter mappable: Place
    func add(post mappable: Mappable) {
        handler?.broadcast(mappable: mappable) { $0.add(post: $1) }
    }

    /// Close callout
    /// - Parameter mappable: Place
    func close(mappable: Mappable) {
        handler?.broadcast(mappable: mappable) { $0.close(mappable: $1) }
    }

    /// Notify of visit
    /// - Parameters:
    ///   - mappable: Place
    ///   - triggered: Date
    func notify(mappable: Mappable, triggered: Date) {
        handler?.broadcast(mappable: mappable) { $0.notify(mappable: $1, triggered: triggered) }
    }

    /// Reveal on map
    /// - Parameters:
    ///   - mappable: Place
    ///   - callout: Show callout
    func reveal(mappable: Mappable, callout: Bool) {
        handler?.broadcast(mappable: mappable) { $0.reveal(mappable: $1, callout: callout) }
    }

    /// Show Directions selector
    /// - Parameter mappable: Place
    func show(directions mappable: Mappable) {
        handler?.broadcast(mappable: mappable) { $0.show(directions: $1) }
    }

    /// Show Show More screen
    /// - Parameter mappable: Place
    func show(more mappable: Mappable) {
        handler?.broadcast(mappable: mappable) { $0.show(more: $1) }
    }

    /// Show Nearby screen
    /// - Parameter mappable: Place
    func show(nearby mappable: Mappable) {
        handler?.broadcast(mappable: mappable) { $0.show(nearby: $1) }
    }

    /// Update
    /// - Parameter mappable: Place
    func update(mappable: Mappable) {
        handler?.broadcast(mappable: mappable) { $0.update(mappable: $1) }
    }
}

// MARK: - Testing

#if DEBUG

/// Stub for testing
final class LocationServiceStub: LocationServiceImpl {

    /// Request permission
    /// - Parameter permission: Permission
    override func request(permission: LocationPermission) { }

    /// Start with intended permission
    /// - Parameter permission: Permission
    override func start(permission: LocationPermission) { }
}

#endif
