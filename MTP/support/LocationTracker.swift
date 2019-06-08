// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

enum PermissionTrigger {
    case ask
    case dontAsk
}

protocol LocationTracker: ServiceProvider {

    func accessRefused()
    func alertLocationAccessNeeded()
    func authorization(changed: CLAuthorizationStatus)
    func location(changed: CLLocation)
}

extension LocationTracker {

    @discardableResult func start(tracking ask: PermissionTrigger) -> CLAuthorizationStatus {
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
                alertLocationAccessNeeded()
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

extension LocationTracker where Self: UIViewController {

    func alertLocationAccessNeeded() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

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
            self.app.open(url)
        })

        present(alert, animated: true, completion: nil)
    }
}
