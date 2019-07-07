// @copyright Trollwerks Inc.

import UIKit

protocol ApplicationService {

    func launch(url: URL)

    func route(to annotation: PlaceAnnotation)
    func route(to mapInfo: MapInfo)
    func route(to user: User?)
    func route(to route: Route)

    func endEditing()
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

    func route(to mapInfo: MapInfo) {
        MainTBC.current?.route(to: mapInfo)
    }

    func route(to user: User?) {
        MainTBC.current?.route(to: user)
    }

    func route(to route: Route) {
        MainTBC.current?.route(to: route)
    }

    func endEditing() {
        UIApplication.shared.sendAction(
            #selector(UIApplication.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil)
    }
}
