// @copyright Trollwerks Inc.

import CoreLocation

enum LocationPermission {
    case always
    case whenInUse
}

protocol LocationService {

    var here: CLLocationCoordinate2D? { get }

    func insert<T>(tracker: T) where T: LocationTracker, T: Hashable
    func remove<T>(tracker: T) where T: LocationTracker, T: Hashable

    func request(permission: LocationPermission)
    func start(permission: LocationPermission)
}

extension LocationService {
}

final class LocationServiceImpl: LocationService {

    private lazy var handler: LocationHandler = {
        // swiftlint:disable:next force_unwrapping
        return RoutingAppDelegate.handler(type: LocationHandler.self)!
    }()

    private lazy var manager: CLLocationManager = {
        handler.locationManager
    }()

    var here: CLLocationCoordinate2D? {
        return handler.last?.coordinate ?? manager.location?.coordinate
    }

    func insert<T>(tracker: T) where T: LocationTracker, T: Hashable {
        handler.insert(tracker: tracker)
    }

    func remove<T>(tracker: T) where T: LocationTracker, T: Hashable {
        handler.remove(tracker: tracker)
    }

    func request(permission: LocationPermission) {
        guard CLLocationManager.locationServicesEnabled() else { return }

        switch permission {
        case .always:
            manager.requestAlwaysAuthorization()
        case.whenInUse:
            manager.requestWhenInUseAuthorization()
        }
    }

    func start(permission: LocationPermission) {
        guard CLLocationManager.locationServicesEnabled() else { return }

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
