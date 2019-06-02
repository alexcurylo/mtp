// @copyright Trollwerks Inc.

import CoreLocation
import UIKit
import UserNotifications

enum PermissionTrigger {
    case ask
    case dontAsk
}

protocol LocationTracker: CLLocationManagerDelegate, ServiceProvider {

    var locationManager: CLLocationManager { get }

    func alertLocationAccessNeeded()
    func accessRefused()
}

extension LocationTracker {

    @discardableResult func start(tracking ask: PermissionTrigger) -> CLAuthorizationStatus {
        locationManager.delegate = self
        locationManager.distanceFilter = 15
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.pausesLocationUpdatesAutomatically = false
                if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                    locationManager.startMonitoringSignificantLocationChanges()
                }
            }
            if ask == .ask {
                authorizeNotifications { _ in }
            }
        case .authorizedWhenInUse:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
            if ask == .ask {
                locationManager.requestAlwaysAuthorization()
            }
        case .denied, .restricted:
            if ask == .ask {
                alertLocationAccessNeeded()
            }
        case .notDetermined:
            if ask == .ask {
                locationManager.requestWhenInUseAuthorization()
            }
        @unknown default:
            log.error("handle authorization status \(status)!")
        }
        return status
    }

    func authorizeNotifications(then: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            then(granted)
        }
    }
}

extension LocationTracker where Self: UIViewController {

    func alertLocationAccessNeeded() {
        //swiftlint:disable:next force_unwrapping
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!

        let alert = UIAlertController(
            title: Localized.needLocationAccess(),
            message: Localized.locationAccessRequired(),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: Localized.cancel(),
                                      style: .cancel) { _ in
            self.accessRefused()
        })
        alert.addAction(UIAlertAction(title: Localized.allowLocationAccess(),
                                      style: .default) { _ in
            self.app.open(settingsAppURL)
        })

        present(alert, animated: true, completion: nil)
    }
}
