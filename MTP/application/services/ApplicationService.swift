// @copyright Trollwerks Inc.

import UIKit

protocol ApplicationService {

    func launch(url: URL)

    func route(to annotation: PlaceAnnotation)
    func route(to user: User?)
}

enum Route: Int {
    // tabs
    case locations = 0
    case rankings = 1
    case myProfile = 2
    // presentations
    case editProfile
}

extension UIApplication: ApplicationService {

    func launch(url: URL) {
        open(url, options: [:], completionHandler: nil)
    }

    func route(to annotation: PlaceAnnotation) {
        MainTBC.current?.route(to: annotation)
    }

    func route(to user: User?) {
        MainTBC.current?.route(to: user)
    }
}
