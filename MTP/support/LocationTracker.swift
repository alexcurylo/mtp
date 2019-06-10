// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

protocol LocationTracker: PlaceAnnotationDelegate, ServiceProvider {

    func accessRefused()
    func alertLocationAccessNeeded()
    func annotations(changed list: Checklist,
                     added: Set<PlaceAnnotation>,
                     removed: Set<PlaceAnnotation>)
    func authorization(changed: CLAuthorizationStatus)
    func location(changed: CLLocation)
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
            self.app.launch(url: url)
        })

        present(alert, animated: true, completion: nil)
    }
}
