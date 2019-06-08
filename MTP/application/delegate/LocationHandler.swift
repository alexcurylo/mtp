// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

final class LocationHandler: NSObject, AppHandler, ServiceProvider {

    let locationManager = CLLocationManager {
        $0.distanceFilter = 10
        $0.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    var last: CLLocation?

    private var trackers: Set<AnyHashable> = []

    func insert<T>(tracker: T) where T: LocationTracker, T: Hashable {
        trackers.insert(AnyHashable(tracker))
    }

    func remove<T>(tracker: T) where T: LocationTracker, T: Hashable {
        trackers.remove(tracker)
    }
}

// MARK: - AppLaunchHandler

extension LocationHandler: AppLaunchHandler {

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationManager.delegate = self

        return true
    }

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let options = launchOptions ?? [:]

        if options.keys.contains(.location) {
        }

        return true
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationHandler: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let now = locations.last else { return }
        let updateFilter = CLLocationDistance(20)
        if let last = last,
           last.distance(from: now) < updateFilter {
            return
        }

        last = now
        DispatchQueue.main.async {
            self.trackers.forEach {
                ($0 as? LocationTracker)?.location(changed: now)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateHeading newHeading: CLHeading) {
    }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    }

    func locationManager(_ manager: CLLocationManager,
                         didDetermineState state: CLRegionState,
                         for region: CLRegion) {
    }
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
    }
    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion) {
    }
    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
    }
    func locationManager(_ manager: CLLocationManager,
                         rangingBeaconsDidFailFor region: CLBeaconRegion,
                         withError error: Error) {
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        log.error(#function)
    }

    func locationManager(_ manager: CLLocationManager,
                         didStartMonitoringFor region: CLRegion) {
    }
    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        log.error(#function)
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {

        DispatchQueue.main.async {
            self.trackers.forEach {
                ($0 as? LocationTracker)?.authorization(changed: status)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didFinishDeferredUpdatesWithError error: Error?) {
        log.error(#function)
    }

    func locationManager(_ manager: CLLocationManager,
                         didVisit visit: CLVisit) {
    }
}
