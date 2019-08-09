// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

/// Adopt to handle location related events
protocol LocationTracker: Mapper, ServiceProvider {

    /// User refused access
    func accessRefused()
    /// Show alert asking for authorization
    func alertLocationAccessNeeded()
    /// Authorization changed
    ///
    /// - Parameter changed: New status
    func authorization(changed: CLAuthorizationStatus)
    /// Location changed
    ///
    /// - Parameter changed: New location
    func location(changed: CLLocation)
}

extension LocationTracker where Self: UIViewController {

    /// Show alert asking for authorization
    func alertLocationAccessNeeded() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

        let alert = UIAlertController(
            title: L.needLocationAccess(),
            message: L.locationAccessRequired(),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: L.cancel(),
                                      style: .cancel) { _ in
            self.accessRefused()
        })
        alert.addAction(UIAlertAction(title: L.allowLocationAccess(),
                                      style: .default) { _ in
            self.app.launch(url: url)
        })

        present(alert, animated: true, completion: nil)
    }
}
