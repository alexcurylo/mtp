// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

protocol LocationTracker: PlaceAnnotationDelegate, ServiceProvider {

    func accessRefused()
    func alertLocationAccessNeeded()
    func authorization(changed: CLAuthorizationStatus)
    func location(changed: CLLocation)

    //func close(mappable: Mappable)
    func notify(mappable: Mappable)
    func reveal(mappable: Mappable?, callout: Bool)
    //func show(mappable: Mappable)
    func update(mappable: Mappable)
}

extension LocationTracker where Self: UIViewController {

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
