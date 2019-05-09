// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

enum PermissionTrigger {
    case ask
    case dontAsk
}

protocol LocationTracker: CLLocationManagerDelegate, ServiceProvider {

    var locationManager: CLLocationManager { get }

    func alertLocationAccessNeeded()
}

extension LocationTracker {

    @discardableResult func start(tracking ask: PermissionTrigger) -> CLAuthorizationStatus {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
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
                                      style: .default,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: Localized.allowLocationAccess(),
                                      style: .cancel) { _ -> Void in
            self.app.open(settingsAppURL)
        })

        present(alert, animated: true, completion: nil)
    }
}
